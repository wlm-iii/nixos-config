import assert from "node:assert/strict";
import { test } from "node:test";
import codexStatusExtension, { runCodexStatus } from "../../extensions/codex-status/index.ts";
import type { CodexUsageSnapshot, FetchCodexUsageOptions } from "../../extensions/codex-status/usage.ts";

const ACCOUNT_ID = "account-command-test";
const ACCESS_TOKEN = makeToken(ACCOUNT_ID);

function base64Url(value: unknown): string {
	return Buffer.from(JSON.stringify(value), "utf8").toString("base64url");
}

function makeToken(accountId: string): string {
	return `${base64Url({ alg: "none" })}.${base64Url({
		"https://api.openai.com/auth": { chatgpt_account_id: accountId },
	})}.signature`;
}

interface MockOptions {
	getAuth?: () => Promise<unknown>;
	baseUrl?: string;
	mode?: string;
}

function makeContext(options: MockOptions = {}) {
	const notifications: Array<{ message: string; level: string }> = [];
	const overlays: string[][] = [];
	return {
		ctx: {
			mode: options.mode ?? "rpc",
			model: { id: "gpt-5.6-sol" },
			modelRegistry: {
				getProviderAuth: options.getAuth ?? (async () => ({ auth: { apiKey: ACCESS_TOKEN }, source: "OAuth" })),
				getProvider: () => ({ baseUrl: options.baseUrl ?? "https://chatgpt.com/backend-api" }),
			},
			ui: {
				notify: (message: string, level: string) => notifications.push({ message, level }),
				custom: async (factory: unknown) => {
					const createComponent = factory as (
						tui: unknown,
						theme: unknown,
						keybindings: unknown,
						done: (value: undefined) => void,
					) => { render(width: number): string[] };
					const component = createComponent({}, {}, {}, () => {});
					overlays.push(component.render(80));
					return undefined;
				},
			},
		},
		notifications,
		overlays,
	};
}

const SNAPSHOT: CodexUsageSnapshot = {
	planType: "plus",
	primary: { usedPercent: 20, windowSeconds: 18_000 },
	secondary: { usedPercent: 30, windowSeconds: 604_800 },
	fetchedAt: Date.now(),
};

test("extension registers only the codex-status command", () => {
	const commands: Array<{ name: string; options: unknown }> = [];
	codexStatusExtension({
		registerCommand: (name: string, options: unknown) => commands.push({ name, options }),
	} as never);
	assert.equal(commands.length, 1);
	assert.equal(commands[0]?.name, "codex-status");
	assert.match(String((commands[0]?.options as { description?: string }).description), /subscription usage/);
});

test("command fails gracefully when auth resolution throws", async () => {
	const { ctx, notifications } = makeContext({
		getAuth: async () => {
			throw new Error(`auth failure containing ${ACCESS_TOKEN}`);
		},
	});
	let fetched = false;
	await runCodexStatus(ctx as never, {
		fetchUsage: async () => {
			fetched = true;
			return SNAPSHOT;
		},
	});

	assert.equal(fetched, false);
	assert.equal(notifications.length, 1);
	assert.match(notifications[0]!.message, /Unable to resolve OpenAI Codex authentication/);
	assert.equal(notifications[0]!.message.includes(ACCESS_TOKEN), false);
});

test("command fails gracefully when auth is absent or lacks account information", async () => {
	const missing = makeContext({ getAuth: async () => undefined });
	await runCodexStatus(missing.ctx as never);
	assert.match(missing.notifications[0]!.message, /Unable to resolve OpenAI Codex authentication/);

	const malformed = makeContext({ getAuth: async () => ({ auth: { apiKey: "not-a-jwt" } }) });
	await runCodexStatus(malformed.ctx as never);
	assert.match(malformed.notifications[0]!.message, /missing account information/);
});

test("command sanitizes unexpected request failures", async () => {
	const { ctx, notifications } = makeContext();
	await runCodexStatus(ctx as never, {
		fetchUsage: async () => {
			throw new Error(`request failure containing ${ACCESS_TOKEN}`);
		},
	});

	assert.equal(notifications.length, 1);
	assert.equal(notifications[0]!.message, "[codex-status] Unable to fetch OpenAI Codex usage right now.");
	assert.equal(notifications[0]!.message.includes(ACCESS_TOKEN), false);
});

test("command uses resolved auth transiently and displays a successful result", async () => {
	const { ctx, notifications } = makeContext();
	let request: FetchCodexUsageOptions | undefined;
	await runCodexStatus(ctx as never, {
		fetchUsage: async (options) => {
			request = options;
			return SNAPSHOT;
		},
	});

	assert.equal(request?.accessToken, ACCESS_TOKEN);
	assert.equal(request?.accountId, ACCOUNT_ID);
	assert.equal(request?.baseUrl, "https://chatgpt.com/backend-api");
	assert.equal(notifications.length, 1);
	assert.match(notifications[0]!.message, /5-hour limit: 20% used · 80% remaining/);
	assert.match(notifications[0]!.message, /7-day limit: 30% used · 70% remaining/);
	assert.equal(notifications[0]!.message.includes(ACCESS_TOKEN), false);
	assert.equal(notifications[0]!.message.includes(ACCOUNT_ID), false);
});

test("TUI success uses an overlay instead of persisting auth or status", async () => {
	const { ctx, notifications, overlays } = makeContext({ mode: "tui" });
	await runCodexStatus(ctx as never, { fetchUsage: async () => SNAPSHOT });
	assert.equal(notifications.length, 0);
	assert.equal(overlays.length, 1);
	assert.equal(overlays[0]!.every((line) => line.length <= 80), true);
	assert.match(overlays[0]![0]!, /^╭─+╮$/);
	assert.match(overlays[0]!.at(-1)!, /^╰─+╯$/);
	assert.equal(
		overlays[0]!.slice(1, -1).every((line) => line.startsWith("│ ") && line.endsWith(" │")),
		true,
	);
	assert.match(overlays[0]!.join("\n"), /OpenAI Codex — Plus/);
	assert.equal(JSON.stringify(overlays).includes(ACCESS_TOKEN), false);
	assert.equal(JSON.stringify(overlays).includes(ACCOUNT_ID), false);
});
