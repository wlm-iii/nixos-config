import assert from "node:assert/strict";
import { test } from "node:test";
import {
	CodexUsageError,
	buildCodexUsageUrl,
	extractCodexAccountId,
	fetchCodexUsage,
	formatCodexUsage,
	parseCodexUsagePayload,
} from "../../extensions/codex-status/usage.ts";

const ACCOUNT_ID = "account-test-123";
const ACCESS_TOKEN = makeToken(ACCOUNT_ID);
const NOW = Date.UTC(2026, 5, 20, 12, 0, 0);

function base64Url(value: unknown): string {
	return Buffer.from(JSON.stringify(value), "utf8").toString("base64url");
}

function makeToken(accountId: string): string {
	return `${base64Url({ alg: "none" })}.${base64Url({
		"https://api.openai.com/auth": { chatgpt_account_id: accountId },
	})}.signature`;
}

function wrappedPayload() {
	return {
		rate_limits: {
			plan_type: "plus",
			rate_limit: {
				allowed: true,
				limit_reached: false,
				primary_window: {
					used_percent: 25,
					limit_window_seconds: 18_000,
					reset_at: NOW / 1000 + 3600,
				},
				secondary_window: {
					used_percent: 40.5,
					limit_window_seconds: 604_800,
					reset_after_seconds: 86_400,
				},
			},
			credits: { has_credits: true, unlimited: false, balance: "12.5" },
		},
		rate_limit_reset_credits: { available_count: 2 },
	};
}

test("extractCodexAccountId reads the account claim without retaining other token data", () => {
	assert.equal(extractCodexAccountId(ACCESS_TOKEN), ACCOUNT_ID);
	assert.equal(extractCodexAccountId("not-a-jwt"), undefined);
	assert.equal(extractCodexAccountId(`${base64Url({})}.${base64Url({})}.x`), undefined);
});

test("buildCodexUsageUrl appends the official usage path and rejects other hosts", () => {
	assert.equal(
		buildCodexUsageUrl("https://chatgpt.com/backend-api"),
		"https://chatgpt.com/backend-api/wham/usage",
	);
	assert.throws(
		() => buildCodexUsageUrl("https://example.com/backend-api"),
		/Refusing to send OpenAI authentication/,
	);
	assert.throws(
		() => buildCodexUsageUrl("https://chatgpt.com:444/backend-api"),
		/Refusing to send OpenAI authentication/,
	);
	assert.throws(() => buildCodexUsageUrl("not a url"), /invalid service URL/);
});

test("parseCodexUsagePayload supports the current wrapped response", () => {
	const result = parseCodexUsagePayload(wrappedPayload(), NOW);
	assert.equal(result.planType, "plus");
	assert.equal(result.allowed, true);
	assert.equal(result.limitReached, false);
	assert.deepEqual(result.primary, {
		usedPercent: 25,
		windowSeconds: 18_000,
		resetsAt: NOW + 3_600_000,
	});
	assert.deepEqual(result.secondary, {
		usedPercent: 40.5,
		windowSeconds: 604_800,
		resetsAt: NOW + 86_400_000,
	});
	assert.equal(result.creditBalance, "12.5");
	assert.equal(result.resetCredits, 2);
});

test("parseCodexUsagePayload supports the legacy top-level response", () => {
	const result = parseCodexUsagePayload(
		{
			plan_type: "plus",
			rate_limit: {
				primary_window: { used_percent: "10", limit_window_seconds: "18000" },
			},
			credits: { balance: 5 },
		},
		NOW,
	);
	assert.equal(result.primary?.usedPercent, 10);
	assert.equal(result.primary?.windowSeconds, 18_000);
	assert.equal(result.creditBalance, "5");
});

test("fetchCodexUsage sends auth only to ChatGPT and does not return it", async () => {
	let requestedUrl = "";
	let requestedInit: RequestInit | undefined;
	const fetchImpl = async (input: string | URL | Request, init?: RequestInit) => {
		requestedUrl = String(input);
		requestedInit = init;
		return new Response(JSON.stringify(wrappedPayload()), {
			status: 200,
			headers: { "content-type": "application/json" },
		});
	};

	const result = await fetchCodexUsage({
		baseUrl: "https://chatgpt.com/backend-api",
		accessToken: ACCESS_TOKEN,
		accountId: ACCOUNT_ID,
		fetchImpl,
		now: NOW,
	});

	assert.equal(requestedUrl, "https://chatgpt.com/backend-api/wham/usage");
	assert.equal(requestedInit?.method, "GET");
	assert.deepEqual(requestedInit?.headers, {
		Accept: "application/json",
		Authorization: `Bearer ${ACCESS_TOKEN}`,
		"ChatGPT-Account-Id": ACCOUNT_ID,
	});
	const serialized = JSON.stringify(result);
	assert.equal(serialized.includes(ACCESS_TOKEN), false);
	assert.equal(serialized.includes(ACCOUNT_ID), false);
});

test("fetchCodexUsage sanitizes network and HTTP failures", async () => {
	await assert.rejects(
		fetchCodexUsage({
			baseUrl: "https://chatgpt.com/backend-api",
			accessToken: ACCESS_TOKEN,
			accountId: ACCOUNT_ID,
			fetchImpl: async () => {
				throw new Error(`network failure containing ${ACCESS_TOKEN}`);
			},
		}),
		(error: unknown) =>
			error instanceof CodexUsageError &&
			error.message === "Unable to reach the OpenAI Codex usage service." &&
			!error.message.includes(ACCESS_TOKEN),
	);

	await assert.rejects(
		fetchCodexUsage({
			baseUrl: "https://chatgpt.com/backend-api",
			accessToken: ACCESS_TOKEN,
			accountId: ACCOUNT_ID,
			fetchImpl: async () => new Response(`secret body ${ACCESS_TOKEN}`, { status: 403 }),
		}),
		(error: unknown) =>
			error instanceof CodexUsageError &&
			error.message === "OpenAI Codex usage request failed (HTTP 403)." &&
			!error.message.includes(ACCESS_TOKEN),
	);
});

test("fetchCodexUsage handles invalid JSON and missing windows", async () => {
	await assert.rejects(
		fetchCodexUsage({
			baseUrl: "https://chatgpt.com/backend-api",
			accessToken: ACCESS_TOKEN,
			accountId: ACCOUNT_ID,
			fetchImpl: async () => new Response("not json", { status: 200 }),
		}),
		/unreadable Codex usage response/,
	);
	assert.throws(() => parseCodexUsagePayload({ rate_limits: {} }), /did not return Codex usage windows/);
});

test("formatCodexUsage presents remaining percentages without secrets", () => {
	const text = formatCodexUsage(parseCodexUsagePayload(wrappedPayload(), NOW), "gpt-5.6-sol");
	assert.match(text, /OpenAI Codex — Plus/);
	assert.match(text, /5-hour limit: 25% used · 75% remaining/);
	assert.match(text, /7-day limit: 40.5% used · 59.5% remaining/);
	assert.match(text, /Credits: 12.5/);
	assert.match(text, /Banked resets: 2/);
	assert.match(text, /Model: gpt-5.6-sol/);
	assert.equal(text.includes(ACCESS_TOKEN), false);
	assert.equal(text.includes(ACCOUNT_ID), false);
});
