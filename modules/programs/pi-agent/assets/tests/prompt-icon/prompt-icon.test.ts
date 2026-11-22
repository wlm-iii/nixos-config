import assert from "node:assert/strict";
import { performance } from "node:perf_hooks";
import { beforeEach, test } from "node:test";
import type { ExtensionAPI, ExtensionContext, SessionEntry, Theme } from "@earendil-works/pi-coding-agent";
import { stripTerminalSequences, visibleWidth } from "@earendil-works/pi-tui";
import promptIcon, { formatElapsed } from "../../extensions/prompt-icon.ts";
import { DISMISSED_ENTRY } from "../../extensions/lib/welcome.ts";

beforeEach((t) => { t.mock.method(performance, "now", () => 0); });

const plainTheme = { fg: (_color: string, text: string) => text } as Theme;
function harness(mode = "tui", fresh = false) {
	const handlers = new Map<string, Function>();
	let command: { handler: Function };
	let widget: { render(width: number): string[]; dispose(): void } | undefined;
	let renders = 0;
	let disposals = 0;
	let nativeVisible = true;
	let notifications = 0;
	let installedKey = "";
	let placement = "";
	let header: { render(width: number): string[] } | undefined;
	const submitted: string[] = [];
	const editor: { onSubmit?: (text: string) => void; getMode(): string } = { getMode: () => "insert" };
	const state = {
		idle: true, level: "high", theme: plainTheme,
		entries: (fresh ? [] : [{ type: "custom", customType: DISMISSED_ENTRY }]) as SessionEntry[],
	};
	const ctx = {
		mode,
		get thinkingLevel() { return state.level; },
		isIdle: () => state.idle,
		sessionManager: { getEntries: () => state.entries },
		ui: {
			setHeader: (factory: any) => { header = factory({}, state.theme); },
			getEditorComponent: () => () => editor,
			setEditorComponent: (factory: any) => {
				assert.equal(factory({}, state.theme, {}), editor); // Same editor, not a proxy/replacement.
				editor.onSubmit = (text) => { submitted.push(text); };
			},
			get theme() { return state.theme; },
			setWorkingVisible: (visible: boolean) => { nativeVisible = visible; },
			setWidget: (key: string, factory: any, options: { placement?: string } = {}) => {
				installedKey = key;
				placement = options.placement ?? "aboveEditor";
				if (widget) { widget.dispose(); disposals++; }
				widget = factory?.({ requestRender: () => renders++ }, state.theme);
			},
			notify: () => { notifications++; },
		},
	} as unknown as ExtensionContext;
	promptIcon({
		on: (name: string, handler: Function) => handlers.set(name, handler),
		appendEntry: (customType: string, data: unknown) => {
			state.entries.push({ type: "custom", customType, data } as SessionEntry);
		},
		registerCommand: (name: string, value: { handler: Function }) => {
			assert.equal(name, "prompt-spinner");
			command = value;
		},
	} as unknown as ExtensionAPI);
	return {
		state, handlers, editor, submitted,
		header: (width = 80) => header?.render(width),
		emit: (name: string, event = {}) => handlers.get(name)!({ reason: "startup", ...event }, ctx),
		command: (args: string) => command.handler(args, ctx),
		render: (width = 80) => widget?.render(width),
		get renders() { return renders; }, get disposals() { return disposals; },
		get visible() { return nativeVisible; }, get notifications() { return notifications; },
		get key() { return installedKey; }, get placement() { return placement; },
	};
}

test("elapsed time formats whole seconds, minutes and hours", () => {
	for (const [ms, expected] of [
		[-1000, "0:00"], [0, "0:00"], [999, "0:00"], [1000, "0:01"],
		[59_999, "0:59"], [60_000, "1:00"], [3_599_999, "59:59"],
		[3_600_000, "1:00:00"], [3_661_000, "1:01:01"], [86_400_000, "24:00:00"],
	] as const) assert.equal(formatElapsed(ms), expected);
});

test("elapsed time survives repeated starts, theme changes and spinner toggles", async (t) => {
	t.mock.timers.enable({ apis: ["setInterval"] });
	let now = 5000;
	t.mock.method(performance, "now", () => now);
	const h = harness();
	h.emit("session_start");
	h.state.idle = false;
	h.emit("agent_start");
	now += 42_000;
	h.emit("agent_start"); // Automatic retry/continuation, not a new settled run.
	assert.match(h.render()![0], /Working · 0:42$/);
	h.emit("thinking_level_select", { level: "max" });
	assert.match(h.render()![0], /Working · 0:42$/);
	await h.command("off");
	const renders = h.renders;
	now += 3000;
	t.mock.timers.tick(3000);
	assert.equal(h.renders, renders);
	await h.command("on");
	assert.match(h.render()![0], /Working · 0:45$/);
	h.emit("session_shutdown");
});

test("waiting keeps total elapsed time with a slow clock and no animated spinner", (t) => {
	t.mock.timers.enable({ apis: ["setInterval"] });
	let now = 0;
	t.mock.method(performance, "now", () => now);
	const h = harness();
	h.emit("session_start");
	h.emit("agent_start");
	now = 10_000;
	h.emit("ui_prompt_start", { kind: "custom" });
	assert.deepEqual(h.render(), ["π Waiting · 0:10"]);
	now = 11_000;
	t.mock.timers.tick(1000);
	assert.equal(h.renders, 1);
	assert.deepEqual(h.render(), ["π Waiting · 0:11"]);
	h.emit("ui_prompt_end", { kind: "custom" });
	assert.match(h.render()![0], /Working · 0:11$/);
	t.mock.timers.tick(80);
	assert.equal(h.renders, 2);
	h.emit("session_shutdown");
	t.mock.timers.tick(2000);
	assert.equal(h.renders, 2);
});

test("settlement and abort clear elapsed state; a new run starts at zero", (t) => {
	t.mock.timers.enable({ apis: ["setInterval"] });
	let now = 0;
	t.mock.method(performance, "now", () => now);
	// System-clock jumps must not affect the monotonic run clock.
	t.mock.method(Date, "now", () => -1_000_000);
	const h = harness();
	h.emit("session_start");
	for (const aborted of [false, true]) {
		h.emit("agent_start");
		assert.match(h.render()![0], /Working · 0:00$/);
		now += 3_661_000;
		assert.match(h.render()![0], /Working · 1:01:01$/);
		h.emit("agent_settled", { aborted });
		assert.deepEqual(h.render(), ["π"]);
		const renders = h.renders;
		t.mock.timers.tick(2000);
		assert.equal(h.renders, renders);
	}
});

test("activation during work starts a runtime-only clock; session reload resets it", (t) => {
	t.mock.timers.enable({ apis: ["setInterval"] });
	let now = 1000;
	t.mock.method(performance, "now", () => now);
	const h = harness();
	h.state.idle = false;
	h.emit("session_start");
	assert.match(h.render()![0], /Working · 0:00$/);
	now += 1200;
	assert.match(h.render()![0], /Working · 0:01$/);
	h.emit("session_shutdown");
	h.emit("session_start", { reason: "reload" });
	assert.match(h.render()![0], /Working · 0:00$/);
	h.emit("ui_prompt_start");
	h.emit("session_shutdown");
	t.mock.timers.tick(2000);
	assert.equal(h.renders, 0);
});

test("idle uses the existing π widget and hides only the native working row", () => {
	const h = harness();
	h.emit("session_start");
	assert.deepEqual(h.render(), ["π"]);
	assert.equal(h.key, "prompt-icon");
	assert.equal(h.placement, "aboveEditor");
	assert.equal(h.visible, false);
	h.emit("session_shutdown");
	assert.equal(h.visible, true);
	assert.equal(h.render(), undefined);
});

test("spinner animates in one row and stops on settlement, not agent_end", (t) => {
	t.mock.timers.enable({ apis: ["setInterval"] });
	const h = harness();
	h.emit("session_start");
	t.mock.timers.tick(240);
	assert.equal(h.renders, 0);
	h.emit("agent_start");
	assert.deepEqual(h.render(), ["π ⠋ Working · 0:00"]);
	t.mock.timers.tick(80);
	assert.deepEqual(h.render(), ["π ⠙ Working · 0:00"]);
	assert.equal(h.renders, 1);
	assert.equal(h.handlers.has("agent_end"), false);
	h.emit("agent_start"); // Repeated starts must replace, not accumulate timers.
	t.mock.timers.tick(80);
	assert.equal(h.renders, 2);
	h.emit("agent_settled", { aborted: false });
	assert.deepEqual(h.render(), ["π"]);
	t.mock.timers.tick(400);
	assert.equal(h.renders, 2);
});

test("abort and shutdown clear animation timers", (t) => {
	t.mock.timers.enable({ apis: ["setInterval"] });
	const h = harness();
	h.emit("session_start");
	h.emit("agent_start");
	t.mock.timers.tick(80);
	h.emit("agent_settled", { aborted: true });
	t.mock.timers.tick(80);
	assert.equal(h.renders, 1);
	h.emit("agent_start");
	t.mock.timers.tick(80);
	h.emit("session_shutdown", { reason: "reload" });
	t.mock.timers.tick(400);
	assert.equal(h.renders, 2);
	assert.equal(h.visible, true);
	assert.equal(h.render(), undefined);
	h.emit("session_start", { reason: "reload" });
	assert.deepEqual(h.render(), ["π"]);
});

test("permission questions pause animation and restore it on answer", (t) => {
	t.mock.timers.enable({ apis: ["setInterval"] });
	const h = harness();
	h.emit("session_start");
	h.emit("agent_start");
	h.emit("ui_prompt_start", { kind: "permission" });
	assert.deepEqual(h.render(), ["π Waiting · 0:00"]);
	t.mock.timers.tick(400);
	assert.equal(h.renders, 0);
	h.emit("ui_prompt_end", { kind: "permission" });
	assert.deepEqual(h.render(), ["π ⠋ Working · 0:00"]);
	t.mock.timers.tick(80);
	assert.equal(h.renders, 1);
	h.emit("session_shutdown");
});

test("live thinking colors and theme changes, including narrow widths", (t) => {
	t.mock.timers.enable({ apis: ["setInterval"] });
	const h = harness();
	h.emit("session_start");
	h.emit("agent_start");
	const colors: string[] = [];
	h.state.theme = { fg: (color: string, text: string) => { colors.push(color); return `\x1b[36m${text}\x1b[0m`; } } as Theme;
	h.emit("thinking_level_select", { level: "max" });
	assert.equal(stripTerminalSequences(h.render()![0]), "π ⠋ Working · 0:00");
	assert.deepEqual(colors, ["thinkingMax", "thinkingMax", "muted", "dim"]);
	for (let width = 0; width <= 30; width++) {
		const lines = h.render(width)!;
		assert.ok(lines.length <= 1);
		assert.ok(lines.every((line) => visibleWidth(line) <= width));
	}
	h.emit("session_shutdown");
});

test("toggle restores native spinner while retaining π, with no timer leak", async (t) => {
	t.mock.timers.enable({ apis: ["setInterval"] });
	const h = harness();
	h.emit("session_start");
	h.state.idle = false;
	h.emit("agent_start");
	await h.command("off");
	assert.equal(h.visible, true);
	assert.deepEqual(h.render(), ["π"]);
	t.mock.timers.tick(400);
	assert.equal(h.renders, 0);
	await h.command("on");
	assert.equal(h.visible, false);
	assert.deepEqual(h.render(), ["π ⠋ Working · 0:00"]);
	await h.command("bad-argument");
	assert.equal(h.notifications, 1);
	t.mock.timers.tick(80);
	assert.equal(h.renders, 1);
	await h.command("");
	assert.equal(h.visible, true);
	t.mock.timers.tick(400);
	assert.equal(h.renders, 1);
	h.emit("session_shutdown");
});

test("non-TUI sessions never create widgets, timers or change working visibility", async (t) => {
	t.mock.timers.enable({ apis: ["setInterval"] });
	for (const mode of ["rpc", "print", "json"]) {
		const h = harness(mode);
		h.emit("session_start");
		h.emit("agent_start");
		h.emit("thinking_level_select", { level: "off" });
		h.emit("ui_prompt_start");
		h.emit("ui_prompt_end");
		await h.command("off");
		h.emit("agent_settled", { aborted: false });
		h.emit("session_shutdown");
		assert.equal(h.render(), undefined);
		assert.equal(h.visible, true);
		assert.equal(h.disposals, 0);
		t.mock.timers.tick(400);
		assert.equal(h.renders, 0);
	}
});

test("fresh session shows art only; typing/newlines do not reveal widget", () => {
	const h = harness("tui", true);
	h.emit("session_start");
	assert.ok(h.header()!.some((line) => line.includes("==========")));
	assert.equal(h.render(), undefined);
	// Draft editing has no observer: only the host's submit callback triggers it.
	assert.equal(h.handlers.has("input"), true);
	h.editor.onSubmit!(" \n ");
	assert.equal(h.render(), undefined);
	assert.equal(h.state.entries.length, 0);
	h.emit("thinking_level_select", { level: "max" });
	assert.equal(h.render(), undefined);
	h.editor.onSubmit!("/settings");
	assert.deepEqual(h.header(), []);
	assert.deepEqual(h.render(), ["π"]);
	assert.deepEqual(h.submitted, [" \n ", "/settings"]);
	assert.equal(h.state.entries.length, 1);
	assert.deepEqual((h.state.entries[0] as any).data, { dismissed: true });
	assert.equal(h.editor.getMode(), "insert");
});

test("submitted prompts, slash commands and shell commands dismiss once", () => {
	for (const text of ["hello", "/settings", "/plan", "!pwd", "!!pwd", "/not-a-real-command"]) {
		const h = harness("tui", true);
		h.emit("session_start");
		h.editor.onSubmit!(text);
		assert.deepEqual(h.header(), []);
		assert.deepEqual(h.render(), ["π"]);
		assert.deepEqual(h.submitted, [text]);
		h.emit("input");
		h.emit("user_bash");
		assert.equal(h.state.entries.length, 1);
	}
});

test("dismissed welcome stays gone on reload; new sessions show it again", () => {
	const h = harness("tui", true);
	h.emit("session_start");
	h.editor.onSubmit!("/reload");
	h.emit("session_shutdown");
	h.emit("session_start", { reason: "reload" });
	assert.deepEqual(h.header(), []);
	assert.deepEqual(h.render(), ["π"]);
	h.state.entries = [];
	h.emit("session_start", { reason: "new" });
	assert.ok(h.header()!.some((line) => line.includes("==========")));
	assert.equal(h.render(), undefined);
});

test("resumed sessions skip the welcome, even without chat messages", () => {
	for (const reason of ["resume", "fork"]) {
		const h = harness("tui", true);
		h.emit("session_start", { reason });
		assert.deepEqual(h.header(), []);
		assert.deepEqual(h.render(), ["π"]);
	}
});
