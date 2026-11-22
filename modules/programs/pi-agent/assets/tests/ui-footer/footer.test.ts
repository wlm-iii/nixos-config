import assert from "node:assert/strict";
import { test } from "node:test";
import { resolve } from "node:path";
import { pathToFileURL, fileURLToPath } from "node:url";
import type { ExtensionAPI, ExtensionContext, SessionEntry, Theme } from "@earendil-works/pi-coding-agent";
import { stripTerminalSequences, visibleWidth } from "@earendil-works/pi-tui";
import uiFooter, { displayPath } from "../../extensions/ui-footer/index.ts";
import { collectUsage, formatTokens, renderFooter, singleLine, statsFields, type FooterLayout } from "../../extensions/ui-footer/layout.ts";

const plainTheme = { fg: (_color: string, text: string) => text } as Theme;
const coloredTheme = { fg: (color: string, text: string) => `\x1b[${color === "error" ? 31 : color === "warning" ? 33 : 36}m${text}\x1b[0m` } as Theme;
const sampleTotals = { input: 97_000, output: 4_600, cacheRead: 296_000, cacheWrite: 0, cost: 1.492, latestCacheHitRate: 99.5 };
const options = { subscription: true, contextWindow: 272_000, contextPercent: 16.1, autoCompact: true };
const sampleStats = "↑97k · ↓4.6k · R296k · CH99.5% · $1.492 (sub) · 16.1%/272k (auto)";
const layout: FooterLayout = { workspace: "~/.pi · main", model: "model-name · high", permission: "Plan", stats: statsFields(sampleTotals, options, plainTheme), otherStatuses: [] };

test("preserves every requested stat with middle-dot separators", () => {
	assert.equal(layout.stats.join(" · "), sampleStats);
	const lines = renderFooter(layout, 100, plainTheme);
	assert.equal(lines.length, 2);
	assert.ok(lines[0].startsWith("~/.pi · main"));
	assert.ok(lines[0].endsWith("model-name · high"));
	assert.ok(lines[1].startsWith("Plan"));
	assert.ok(lines[1].endsWith(sampleStats));
	assert.deepEqual(lines.map(visibleWidth), [100, 100]);
});

test("narrow layouts preserve the mode and wrap all stat fields", () => {
	const lines = renderFooter(layout, 40, plainTheme);
	assert.equal(lines[1], "Plan");
	for (const field of layout.stats) assert.ok(lines.slice(2).some((line) => line.includes(field)), field);
	assert.ok(lines.every((line) => visibleWidth(line) <= 40));
});

test("ANSI and wide glyphs fit every terminal width, including zero", () => {
	const styled = { ...layout, workspace: coloredTheme.fg("dim", "~/项目 · 分支"), permission: coloredTheme.fg("warning", "Chill"), stats: statsFields(sampleTotals, options, coloredTheme), otherStatuses: ["其他状态"] };
	assert.deepEqual(renderFooter(styled, 0, coloredTheme), []);
	for (let width = 1; width <= 160; width++) {
		assert.ok(renderFooter(styled, width, coloredTheme).every((line) => visibleWidth(line) <= width), String(width));
	}
});

test("zero stats, unknown context, cache writes, subscription and warning colors", () => {
	const zero = collectUsage([]);
	assert.deepEqual(statsFields(zero, { ...options, subscription: false, contextPercent: null, autoCompact: false }, plainTheme), ["?/272k"]);
	assert.deepEqual(statsFields(zero, options, plainTheme), ["$0.000 (sub)", "16.1%/272k (auto)"]);
	assert.ok(statsFields({ ...zero, cacheWrite: 1_500 }, options, plainTheme).includes("W1.5k"));
	assert.match(statsFields(zero, { ...options, contextPercent: 75 }, coloredTheme).at(-1)!, /\x1b\[33m/);
	assert.match(statsFields(zero, { ...options, contextPercent: 95 }, coloredTheme).at(-1)!, /\x1b\[31m/);
});

test("token formatting matches Pi's boundaries", () => {
	assert.deepEqual([0, 999, 1_000, 9_999, 10_000, 999_000, 1_000_000, 10_000_000].map(formatTokens), ["0", "999", "1.0k", "10.0k", "10k", "999k", "1.0M", "10M"]);
});

function usage(input = 10, cacheRead = 90) {
	return { input, output: 5, cacheRead, cacheWrite: 0, totalTokens: input + 5 + cacheRead, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0.1 } };
}

test("accounts for assistant, tool, warming and summary usage, with latest-response cache hit rate", () => {
	const entries = [
		{ type: "message", message: { role: "assistant", usage: usage() } },
		{ type: "message", message: { role: "user", content: "not counted" } },
		{ type: "message", message: { role: "toolResult", usage: usage() } },
		{ type: "usage", usage: usage() },
		{ type: "compaction", usage: usage() },
		{ type: "branch_summary", usage: usage() },
		{ type: "message", message: { role: "assistant", usage: usage(50, 50) } },
	] as SessionEntry[];
	const totals = collectUsage(entries);
	assert.equal(totals.input, 100);
	assert.equal(totals.output, 30);
	assert.equal(totals.cacheRead, 500);
	assert.ok(Math.abs(totals.cost - 0.6) < 0.00001);
	assert.equal(totals.latestCacheHitRate, 50); // Not cumulative 500 / 600.
	entries.push({ type: "message", message: { role: "assistant", usage: usage(0, 0) } } as SessionEntry);
	assert.equal(collectUsage(entries).latestCacheHitRate, undefined);
});

test("shortens only paths actually inside home", () => {
	assert.equal(displayPath("/home/test", "/home/test"), "~");
	assert.equal(displayPath("/home/test/.pi", "/home/test"), "~/.pi");
	assert.equal(displayPath("/home/test-other", "/home/test"), "/home/test-other");
});

test("sanitizes terminal controls but preserves permission colors", () => {
	const text = "\x1b[31mYolo\x1b[0m\n\tmode\x1b[2J\x1b]0;bad title\x07";
	const clean = singleLine(text);
	assert.equal(stripTerminalSequences(clean), "Yolo mode");
	assert.ok(clean.includes("\x1b[31m"));
	assert.ok(!clean.includes("\x1b[2J"));
	assert.ok(!clean.includes("bad title"));
});

function harness(mode = "tui") {
	const handlers = new Map<string, Function>();
	const commands = new Map<string, { handler: Function }>();
	let component: any;
	let reads = 0;
	let renders = 0;
	let disposals = 0;
	let onBranch: (() => void) | undefined;
	const statuses = new Map([["pi-permission-mode", "Build"], ["z-status", "last"], ["a-status", "first"]]);
	const state = {
		leaf: "one", session: "session-a", branch: "main", name: "", oauth: false, subscriptionProvider: true,
		model: { id: "model-one", provider: "openai", reasoning: true, contextWindow: 272_000 },
		effort: "high", context: { percent: 16.1, contextWindow: 272_000 },
		settings: { compaction: { enabled: true } }, theme: plainTheme,
		entries: [{ type: "message", message: { role: "assistant", usage: usage() } }],
	};
	const ctx = {
		mode,
		get model() { return state.model; },
		get thinkingLevel() { return state.effort; },
		getContextUsage: () => state.context,
		modelRegistry: {
			isUsingOAuth: () => state.oauth,
			getProvider: () => ({ auth: { oauth: { isSubscription: state.subscriptionProvider } } }),
		},
		sessionManager: {
			getLeafId: () => state.leaf,
			getSessionId: () => state.session,
			getCwd: () => "/work/project",
			getSessionName: () => state.name,
			getEntries: () => { reads++; return state.entries; },
		},
		ui: {
			get theme() { return state.theme; },
			notify: () => {},
			setFooter: (factory: any) => {
				component?.dispose();
				component = factory?.({ requestRender: () => renders++ }, state.theme, {
					getGitBranch: () => state.branch,
					getAvailableProviderCount: () => 2,
					getExtensionStatuses: () => statuses,
					onBranchChange: (callback: () => void) => { onBranch = callback; return () => { disposals++; }; },
				});
			},
		},
	} as unknown as ExtensionContext;
	const api = {
		on: (event: string, callback: Function) => handlers.set(event, callback),
		registerCommand: (name: string, command: { handler: Function }) => commands.set(name, command),
		getSettings: () => state.settings,
	} as unknown as ExtensionAPI;
	uiFooter(api);
	return { ctx, state, statuses, handlers, commands, start: () => handlers.get("session_start")!({}, ctx),
		render: (width = 120) => component.render(width) as string[],
		branchChange: () => onBranch?.(), get component() { return component; },
		get reads() { return reads; }, get renders() { return renders; }, get disposals() { return disposals; } };
}

test("installs only in TUI and does not touch the editor or register tools", () => {
	for (const mode of ["rpc", "json", "print"]) {
		const h = harness(mode);
		h.start();
		assert.equal(h.component, undefined);
	}
	const h = harness();
	assert.deepEqual([...h.handlers.keys()], ["session_start"]);
	assert.deepEqual([...h.commands.keys()], ["ui-footer"]);
	h.start();
	assert.ok(h.component);
});

test("live model, effort, branch, mode, theme and settings updates; no duplicated statuses", () => {
	const h = harness();
	h.start();
	let lines = h.render();
	assert.ok(lines[0].includes("openai · model-one · high"));
	assert.ok(lines[1].startsWith("Build"));
	assert.equal(lines[2], "first · last");
	h.state.model.id = "model-two";
	h.state.effort = "max";
	h.state.branch = "feature/ui";
	h.state.name = "UI work";
	h.state.oauth = true;
	h.state.settings.compaction.enabled = false;
	h.statuses.set("pi-permission-mode", "\x1b[33mChill\x1b[0m");
	h.state.theme = coloredTheme;
	h.branchChange();
	assert.equal(h.renders, 1);
	lines = h.render().map(stripTerminalSequences);
	assert.ok(lines[0].includes("feature/ui · UI work"));
	assert.ok(lines[0].endsWith("model-two · max"));
	assert.ok(lines[1].startsWith("Chill"));
	assert.ok(lines[1].includes("(sub)"));
	assert.ok(!lines[1].includes("(auto)"));
	assert.equal(lines.join("").split("Chill").length - 1, 1);
	h.state.subscriptionProvider = false;
	assert.ok(!h.render().join("").includes("(sub)")); // OAuth does not necessarily mean subscription.
	h.statuses.delete("pi-permission-mode");
	assert.ok(!h.render().join("").includes("Chill")); // Never invent a permission mode.
});

test("model name uses orange while provider and thinking-level colors stay unchanged", () => {
	const h = harness();
	const colors = new Map<string, string>();
	h.state.theme = { fg: (color: string, text: string) => { colors.set(text, color); return text; } } as Theme;
	h.start();
	h.render();
	assert.equal(colors.get("model-one"), "bashMode");
	assert.equal(colors.get("openai"), "dim");
	assert.equal(colors.get("high"), "thinkingHigh");
	h.state.model.id = "model-two";
	h.state.effort = "max";
	h.render();
	assert.equal(colors.get("model-two"), "bashMode");
	assert.equal(colors.get("max"), "thinkingMax");
});

test("caches accounting between frames and refreshes on leaf/session changes", () => {
	const h = harness();
	h.start();
	h.render(); h.render();
	assert.equal(h.reads, 1);
	h.state.entries.push({ type: "message", message: { role: "assistant", usage: usage() } });
	h.state.leaf = "two";
	assert.ok(h.render()[1].includes("↑20"));
	assert.equal(h.reads, 2);
	h.state.session = "session-b";
	h.render();
	assert.equal(h.reads, 3);
	h.component.invalidate();
	h.render();
	assert.equal(h.reads, 4);
});

test("Pi 1.5's actual extension loader loads and activates the footer", async () => {
	const loaderUrl = pathToFileURL(resolve(process.env.PI_PACKAGE_DIR!, "dist/core/extensions/loader.js"));
	const { loadExtensions } = await import(loaderUrl.href);
	const path = fileURLToPath(new URL("../../extensions/ui-footer/index.ts", import.meta.url));
	const loaded = await loadExtensions([path], "/tmp");
	assert.deepEqual(loaded.errors, []);
	assert.equal(loaded.extensions.length, 1);
	const extension = loaded.extensions[0];
	assert.equal(extension.tools.size, 0);
	assert.ok(extension.commands.has("ui-footer"));
	const h = harness();
	loaded.runtime.getSettings = () => h.state.settings;
	await extension.handlers.get("session_start")[0]({ reason: "startup" }, h.ctx);
	assert.ok(h.render()[1].startsWith("Build"));
	await extension.commands.get("ui-footer").handler("off", h.ctx);
	assert.equal(h.component, undefined);
});

test("toggle restores native footer and disposes branch subscription", async () => {
	const h = harness();
	h.start();
	const command = h.commands.get("ui-footer")!;
	await command.handler("off", h.ctx);
	assert.equal(h.component, undefined);
	assert.equal(h.disposals, 1);
	await command.handler("on", h.ctx);
	assert.ok(h.component);
	await command.handler("not-an-option", h.ctx);
	assert.ok(h.component);
	await command.handler("", h.ctx);
	assert.equal(h.component, undefined);
	assert.equal(h.disposals, 2);
});
