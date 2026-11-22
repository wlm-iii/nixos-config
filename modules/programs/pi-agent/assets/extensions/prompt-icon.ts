import { performance } from "node:perf_hooks";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";
import { installWelcome } from "./lib/welcome.ts";

const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
const FRAME_INTERVAL_MS = 80;

export function formatElapsed(milliseconds: number): string {
	const seconds = Math.max(0, Math.floor(milliseconds / 1000));
	const minutes = Math.floor(seconds / 60);
	const tail = String(seconds % 60).padStart(2, "0");
	return minutes < 60 ? `${minutes}:${tail}`
		: `${Math.floor(minutes / 60)}:${String(minutes % 60).padStart(2, "0")}:${tail}`;
}

function thinkingColor(level: string) {
	switch (level) {
		case "off":
			return "thinkingOff";
		case "minimal":
			return "thinkingMinimal";
		case "low":
			return "thinkingLow";
		case "medium":
			return "thinkingMedium";
		case "high":
			return "thinkingHigh";
		case "xhigh":
			return "thinkingXhigh";
		case "max":
			return "thinkingMax";
		default:
			return "accent";
	}
}

export default function promptIconExtension(pi: ExtensionAPI) {
	let thinkingLevel = "medium";
	let working = false;
	let waiting = false;
	let enabled = true;
	let welcome: ReturnType<typeof installWelcome>;
	let startedAt: number | undefined;

	const setWorking = (active: boolean) => {
		if (active && !working) startedAt = performance.now();
		if (!active) startedAt = undefined;
		working = active;
	};

	const setPromptIcon = (ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;

		// Hide only the standard working loader, not retry/compaction messages.
		ctx.ui.setWorkingVisible(!enabled);
		if (welcome?.visible()) {
			ctx.ui.setWidget("prompt-icon", undefined);
			return;
		}
		ctx.ui.setWidget("prompt-icon", (tui) => {
			let frame = 0;
			const active = enabled && working;
			const animated = active && !waiting;
			// One timer: smooth spinner while working, a 1 Hz clock while waiting.
			const timer = active ? setInterval(() => {
				if (animated) frame = (frame + 1) % SPINNER_FRAMES.length;
				tui.requestRender();
			}, animated ? FRAME_INTERVAL_MS : 1000) : undefined;
			timer?.unref();
			return {
				render(width: number): string[] {
					const theme = ctx.ui.theme;
					const color = thinkingColor(thinkingLevel);
					let line = theme.fg(color, "π");
					if (enabled && working) {
						line += waiting
							? ` ${theme.fg("muted", "Waiting")}`
							: ` ${theme.fg(color, SPINNER_FRAMES[frame])} ${theme.fg("muted", "Working")}`;
						line += theme.fg("dim", ` · ${formatElapsed(startedAt === undefined ? 0 : performance.now() - startedAt)}`);
					}
					return width > 0 ? [truncateToWidth(line, width)] : [];
				},
				invalidate() {},
				dispose() { if (timer) clearInterval(timer); },
			};
		}, { placement: "aboveEditor" });
	};

	pi.on("session_start", (event, ctx) => {
		thinkingLevel = ctx.thinkingLevel;
		setWorking(false);
		setWorking(!ctx.isIdle());
		waiting = false;
		welcome = installWelcome(pi, ctx, event, () => setPromptIcon(ctx));
		if (working) welcome?.dismiss();
		setPromptIcon(ctx);
	});

	// Fallbacks for submissions initiated outside the prompt editor.
	pi.on("input", (_event, _ctx) => { welcome?.dismiss(); });
	pi.on("user_bash", (_event, _ctx) => { welcome?.dismiss(); });

	pi.on("thinking_level_select", (event, ctx) => {
		thinkingLevel = event.level;
		setPromptIcon(ctx);
	});

	pi.on("agent_start", (_event, ctx) => {
		setWorking(true);
		welcome?.dismiss();
		setPromptIcon(ctx);
	});

	// agent_end may be followed by retry or queued work. Stop only at settlement.
	pi.on("agent_settled", (_event, ctx) => {
		setWorking(false);
		waiting = false;
		setPromptIcon(ctx);
	});

	pi.on("ui_prompt_start", (_event, ctx) => {
		waiting = true;
		setPromptIcon(ctx);
	});
	pi.on("ui_prompt_end", (_event, ctx) => {
		waiting = false;
		setPromptIcon(ctx);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		setWorking(false);
		waiting = false;
		ctx.ui.setWidget("prompt-icon", undefined);
		ctx.ui.setWorkingVisible(true);
	});

	pi.registerCommand("prompt-spinner", {
		description: "Toggle the spinner beside π, or use on/off (resets on reload)",
		handler: async (args, ctx) => {
			if (ctx.mode !== "tui") return;
			const action = args.trim();
			if (action && action !== "on" && action !== "off") {
				ctx.ui.notify("Usage: /prompt-spinner [on|off]", "warning");
				return;
			}
			enabled = action === "on" || (action !== "off" && !enabled);
			setWorking(!ctx.isIdle());
			setPromptIcon(ctx);
		},
	});
}
