import type { Usage } from "@earendil-works/pi-ai";
import type { SessionEntry, Theme } from "@earendil-works/pi-coding-agent";
import { stripTerminalSequences, truncateToWidth, visibleWidth, wrapTextWithAnsi } from "@earendil-works/pi-tui";

export const PERMISSION_STATUS_KEY = "pi-permission-mode";
export const SEPARATOR = " · ";

export interface UsageTotals {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: number;
	latestCacheHitRate?: number;
}

// Match Pi 1.5's accounting: all entries, including abandoned branches,
// compaction, cache warming, and nested model usage reported by tools.
export function collectUsage(entries: readonly SessionEntry[]): UsageTotals {
	const totals: UsageTotals = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
	for (const entry of entries) {
		let usage: Usage | undefined;
		if (entry.type === "usage" || entry.type === "compaction" || entry.type === "branch_summary") {
			usage = entry.usage;
		} else if (entry.type === "message") {
			if (entry.message.role === "assistant") {
				usage = entry.message.usage;
				const prompt = usage.input + usage.cacheRead + usage.cacheWrite;
				totals.latestCacheHitRate = prompt > 0 ? (usage.cacheRead / prompt) * 100 : undefined;
			} else if (entry.message.role === "toolResult") {
				usage = entry.message.usage;
			}
		}
		if (!usage) continue;
		totals.input += usage.input;
		totals.output += usage.output;
		totals.cacheRead += usage.cacheRead;
		totals.cacheWrite += usage.cacheWrite;
		totals.cost += usage.cost.total;
	}
	return totals;
}

export function formatTokens(count: number): string {
	if (count < 1_000) return String(count);
	if (count < 10_000) return `${(count / 1_000).toFixed(1)}k`;
	if (count < 1_000_000) return `${Math.round(count / 1_000)}k`;
	if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
	return `${Math.round(count / 1_000_000)}M`;
}

// Preserve extension-provided SGR colors, but not cursor movement or OSC sequences.
export function singleLine(text: string): string {
	return text.split(/(\x1b\[[\d;:]*m)/g)
		.map((part, index) => index % 2 ? part : stripTerminalSequences(part).replace(/[\x00-\x1f\x7f-\x9f]/g, " "))
		.join("").replace(/ +/g, " ").trim();
}

export interface StatsOptions {
	subscription: boolean;
	contextWindow: number;
	contextPercent: number | null;
	autoCompact: boolean;
}

export function statsFields(totals: UsageTotals, options: StatsOptions, theme: Theme): string[] {
	const fields: string[] = [];
	if (totals.input) fields.push(`↑${formatTokens(totals.input)}`);
	if (totals.output) fields.push(`↓${formatTokens(totals.output)}`);
	if (totals.cacheRead) fields.push(`R${formatTokens(totals.cacheRead)}`);
	if (totals.cacheWrite) fields.push(`W${formatTokens(totals.cacheWrite)}`);
	if ((totals.cacheRead || totals.cacheWrite) && totals.latestCacheHitRate !== undefined) {
		fields.push(`CH${totals.latestCacheHitRate.toFixed(1)}%`);
	}
	if (totals.cost || options.subscription) {
		fields.push(`$${totals.cost.toFixed(3)}${options.subscription ? " (sub)" : ""}`);
	}
	const styled = fields.map((field) => theme.fg("dim", field));
	const percent = options.contextPercent;
	const context = `${percent === null ? "?" : `${percent.toFixed(1)}%`}/${formatTokens(options.contextWindow)}${options.autoCompact ? " (auto)" : ""}`;
	styled.push(theme.fg(percent !== null && percent > 90 ? "error" : percent !== null && percent > 70 ? "warning" : "dim", context));
	return styled;
}

function aligned(left: string, right: string, width: number): string {
	return left + " ".repeat(Math.max(0, width - visibleWidth(left) - visibleWidth(right))) + right;
}

function wrapFields(fields: string[], width: number, separator: string): string[] {
	const lines: string[] = [];
	let line = "";
	for (const field of fields) {
		const next = line ? line + separator + field : field;
		if (visibleWidth(next) <= width) {
			line = next;
			continue;
		}
		if (line) lines.push(line);
		const wrapped = wrapTextWithAnsi(field, width);
		lines.push(...wrapped.slice(0, -1));
		line = wrapped.at(-1) ?? "";
	}
	if (line) lines.push(line);
	return lines;
}

export interface FooterLayout {
	workspace: string;
	model: string;
	permission: string;
	stats: string[];
	otherStatuses: string[];
}

export function renderFooter(layout: FooterLayout, width: number, theme: Theme): string[] {
	width = Math.max(0, Math.floor(width));
	if (width === 0) return [];
	const separator = theme.fg("dim", SEPARATOR);
	const { workspace, model, permission, stats, otherStatuses } = layout;
	const lines: string[] = [];
	if (visibleWidth(workspace) + visibleWidth(model) + 2 <= width) {
		lines.push(aligned(workspace, model, width));
	} else {
		// Retain both identities on the top row, favoring the model on narrow screens.
		const modelWidth = Math.min(visibleWidth(model), Math.floor(width * 0.6));
		const leftWidth = Math.max(0, width - modelWidth - 2);
		lines.push(aligned(truncateToWidth(workspace, leftWidth), truncateToWidth(model, modelWidth), width));
	}
	const statsLine = stats.join(separator);
	if (visibleWidth(permission) + visibleWidth(statsLine) + (permission ? 2 : 0) <= width) {
		lines.push(aligned(permission, statsLine, width));
	} else {
		// Never sacrifice the permission label to make room for statistics.
		if (permission) lines.push(...wrapTextWithAnsi(permission, width));
		lines.push(...wrapFields(stats, width, separator));
	}
	lines.push(...wrapFields(otherStatuses, width, separator));
	// Last-resort width guard for a glyph wider than an extremely narrow terminal.
	return lines.map((line) => truncateToWidth(line, width));
}
