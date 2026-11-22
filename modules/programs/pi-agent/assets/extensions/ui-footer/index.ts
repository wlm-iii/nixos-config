import { homedir } from "node:os";
import { isAbsolute, relative, sep } from "node:path";
import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { collectUsage, PERMISSION_STATUS_KEY, renderFooter, SEPARATOR, singleLine, statsFields } from "./layout.ts";

export function displayPath(cwd: string, home: string): string {
	const withinHome = relative(home, cwd);
	if (withinHome === "") return "~";
	if (withinHome === ".." || withinHome.startsWith(`..${sep}`) || isAbsolute(withinHome)) return cwd;
	return `~${sep}${withinHome}`;
}

function effortColor(level: string): Parameters<Theme["fg"]>[0] {
	switch (level) {
		case "off": return "thinkingOff";
		case "minimal": return "thinkingMinimal";
		case "low": return "thinkingLow";
		case "medium": return "thinkingMedium";
		case "high": return "thinkingHigh";
		case "xhigh": return "thinkingXhigh";
		case "max": return "thinkingMax";
		default: return "dim";
	}
}

export default function uiFooter(pi: ExtensionAPI): void {
	let enabled = true;
	const install = (ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;
		ctx.ui.setFooter((tui, _theme, footerData) => {
			const unsubscribe = footerData.onBranchChange(() => tui.requestRender());
			let cached: { leaf: string | null; session: string; usage: ReturnType<typeof collectUsage> } | undefined;
			return {
				dispose: unsubscribe,
				invalidate() { cached = undefined; },
				render(width: number): string[] {
					// Read the current theme/model/effort on each render, not the startup snapshot.
					const theme = ctx.ui.theme;
					const manager = ctx.sessionManager;
					const leaf = manager.getLeafId();
					const session = manager.getSessionId();
					if (!cached || cached.leaf !== leaf || cached.session !== session) {
						cached = { leaf, session, usage: collectUsage(manager.getEntries()) };
					}
					const dot = theme.fg("dim", SEPARATOR);
					const workspace = [displayPath(manager.getCwd(), homedir()), footerData.getGitBranch(), manager.getSessionName()]
						.filter((part): part is string => Boolean(part))
						.map((part) => theme.fg("dim", singleLine(part))).join(dot);
					const model = ctx.model;
					const modelParts = [];
					if (model && footerData.getAvailableProviderCount() > 1) {
						modelParts.push(theme.fg("dim", singleLine(model.provider)));
					}
					modelParts.push(theme.fg("bashMode", singleLine(model?.id ?? "no-model")));
					if (model?.reasoning) {
						modelParts.push(theme.fg(effortColor(ctx.thinkingLevel), ctx.thinkingLevel));
					}
					// Match native subscription labeling using cached auth *metadata* only.
					// Never resolve tokens, read auth files, or poll provider quota endpoints.
					const subscription = Boolean(model && (model.provider === "kimi-coding" ||
						(ctx.modelRegistry.isUsingOAuth(model) && ctx.modelRegistry.getProvider(model.provider)?.auth.oauth?.isSubscription === true)));
					const context = ctx.getContextUsage();
					const stats = statsFields(cached.usage, {
						subscription,
						contextWindow: context?.contextWindow ?? model?.contextWindow ?? 0,
						contextPercent: context?.percent ?? (context ? null : 0),
						autoCompact: pi.getSettings().compaction?.enabled !== false,
					}, theme);
					const statuses = footerData.getExtensionStatuses();
					return renderFooter({
						workspace,
						model: modelParts.join(dot),
						permission: singleLine(statuses.get(PERMISSION_STATUS_KEY) ?? ""),
						stats,
						otherStatuses: [...statuses.entries()]
							.filter(([key]) => key !== PERMISSION_STATUS_KEY)
							.sort(([a], [b]) => a.localeCompare(b))
							.map(([, value]) => singleLine(value)).filter(Boolean),
					}, width, theme);
				},
			};
		});
	};

	pi.on("session_start", (_event, ctx) => {
		if (enabled) install(ctx);
	});
	pi.registerCommand("ui-footer", {
		description: "Toggle the custom footer, or use on/off (until reload or session replacement)",
		handler: async (args, ctx) => {
			if (ctx.mode !== "tui") return;
			const action = args.trim();
			if (action && action !== "on" && action !== "off") {
				ctx.ui.notify("Usage: /ui-footer [on|off]", "warning");
				return;
			}
			enabled = action === "on" || (action !== "off" && !enabled);
			if (enabled) install(ctx);
			else ctx.ui.setFooter(undefined);
		},
	});
}
