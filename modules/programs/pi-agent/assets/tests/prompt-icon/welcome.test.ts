import assert from "node:assert/strict";
import { test } from "node:test";
import type { SessionEntry, Theme } from "@earendil-works/pi-coding-agent";
import type { EditorComponent } from "@earendil-works/pi-tui";
import { visibleWidth } from "@earendil-works/pi-tui";
import { DISMISSED_ENTRY, observeSubmission, shouldShowWelcome, welcomeLines } from "../../extensions/lib/welcome.ts";

const theme = { fg: (_color: string, text: string) => text } as Theme;

test("uses the exact latest artwork with two backslashes and the host version", () => {
	assert.deepEqual(welcomeLines(80, theme, "1.5.0"), [
		"", "    ==========", "      ||  ||", "      ||  ||", String.raw`      ||  \\//`, "", "    pi · v1.5.0", "",
	]);
	assert.ok(welcomeLines(80, theme, "2.0.0").includes("    pi · v2.0.0"));
	for (let width = 0; width <= 100; width++) {
		assert.ok(welcomeLines(width, theme).every((line) => visibleWidth(line) <= width));
	}
});

test("artwork and compact fallback use the theme's orange token; version stays dim", () => {
	const colors: string[] = [];
	const colored = { fg: (color: string, text: string) => { colors.push(color); return text; } } as Theme;
	welcomeLines(80, colored);
	assert.deepEqual(colors, ["bashMode", "bashMode", "bashMode", "bashMode", "dim"]);
	colors.length = 0;
	welcomeLines(10, colored);
	assert.deepEqual(colors, ["bashMode"]);
});

test("fresh/new welcome, history detection, UI marker, and resumed/forked sessions", () => {
	assert.equal(shouldShowWelcome("startup", []), true);
	assert.equal(shouldShowWelcome("new", []), true);
	assert.equal(shouldShowWelcome("reload", []), true);
	assert.equal(shouldShowWelcome("resume", []), false);
	assert.equal(shouldShowWelcome("fork", []), false);
	for (const entry of [
		{ type: "custom", customType: DISMISSED_ENTRY },
		{ type: "message", message: { role: "user" } },
		{ type: "message", message: { role: "assistant" } },
		{ type: "message", message: { role: "bashExecution" } },
		{ type: "custom_message" }, { type: "compaction" }, { type: "branch_summary" },
	]) {
		assert.equal(shouldShowWelcome("startup", [entry] as SessionEntry[]), false);
		assert.equal(shouldShowWelcome("reload", [entry] as SessionEntry[]), false);
	}
	assert.equal(shouldShowWelcome("startup", [{ type: "message", message: { role: "system" } }] as SessionEntry[]), true);
});

test("submit observer preserves text, this, return values and callback reassignment", () => {
	let observations = 0;
	const editor = {} as EditorComponent;
	observeSubmission(editor, () => observations++);
	assert.equal(editor.onSubmit, undefined);
	const seen: string[] = [];
	const result = Promise.resolve("unchanged");
	editor.onSubmit = function (this: unknown, text: string) {
		assert.equal(this, editor);
		seen.push(text);
		return result;
	};
	assert.equal(editor.onSubmit("  hello\nworld  "), result);
	assert.deepEqual(seen, ["  hello\nworld  "]);
	assert.equal(observations, 1);
	let replacementCalled = false;
	editor.onSubmit = () => { replacementCalled = true; };
	editor.onSubmit("/settings");
	assert.equal(replacementCalled, true);
	assert.equal(observations, 2);
});

test("UI observer errors cannot block dispatch; original callback errors remain intact", () => {
	const editor = {} as EditorComponent;
	observeSubmission(editor, () => { throw new Error("UI failure"); });
	let called = false;
	editor.onSubmit = () => { called = true; };
	editor.onSubmit("!pwd");
	assert.equal(called, true);
	const error = new Error("original failure");
	editor.onSubmit = () => { throw error; };
	assert.throws(() => editor.onSubmit!("/command"), (received) => received === error);
});
