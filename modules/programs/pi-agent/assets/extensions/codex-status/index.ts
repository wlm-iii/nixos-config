import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import {
	CodexUsageError,
	extractCodexAccountId,
	fetchCodexUsage,
	formatCodexUsage,
	type CodexUsageSnapshot,
	type FetchCodexUsageOptions,
} from "./usage.ts";

const PROVIDER_ID = "openai-codex";
const DEFAULT_TIMEOUT_MS = 10_000;

interface CodexStatusDependencies {
	fetchUsage?: (options: FetchCodexUsageOptions) => Promise<CodexUsageSnapshot>;
	timeoutMs?: number;
}

function wrapLine(line: string, width: number): string[] {
	if (line.length <= width) return [line];
	const parts: string[] = [];
	let remaining = line;
	while (remaining.length > width) {
		let split = remaining.lastIndexOf(" ", width);
		if (split <= 0) split = width;
		parts.push(remaining.slice(0, split));
		remaining = remaining.slice(split).trimStart();
	}
	parts.push(remaining);
	return parts;
}

async function showStatus(ctx: ExtensionCommandContext, text: string): Promise<void> {
	if (ctx.mode !== "tui") {
		ctx.ui.notify(text, "info");
		return;
	}

	await ctx.ui.custom<void>(
		(_tui, _theme, _keybindings, done) => ({
			render(width: number): string[] {
				const innerWidth = Math.max(1, width - 4);
				const content = text.split("\n").flatMap((line) => wrapLine(line, innerWidth));
				content.push("", "Enter or Esc to close");
				const horizontal = "─".repeat(innerWidth + 2);
				return [
					`╭${horizontal}╮`,
					...content.map((line) => `│ ${line.padEnd(innerWidth)} │`),
					`╰${horizontal}╯`,
				];
			},
			handleInput(data: string): void {
				if (data === "\r" || data === "\n" || data === "\x1b" || data === "q") done(undefined);
			},
			invalidate(): void {},
		}),
		{
			overlay: true,
			overlayOptions: {
				anchor: "center",
				width: "80%",
				minWidth: 48,
				maxHeight: "80%",
				margin: 1,
			},
		},
	);
}

function notifyAuthFailure(ctx: ExtensionCommandContext): void {
	ctx.ui.notify("[codex-status] Unable to resolve OpenAI Codex authentication. Sign in with /login and try again.", "warning");
}

export async function runCodexStatus(
	ctx: ExtensionCommandContext,
	dependencies: CodexStatusDependencies = {},
): Promise<void> {
	let authResult: Awaited<ReturnType<typeof ctx.modelRegistry.getProviderAuth>>;
	try {
		authResult = await ctx.modelRegistry.getProviderAuth(PROVIDER_ID);
	} catch {
		notifyAuthFailure(ctx);
		return;
	}

	const accessToken = authResult?.auth.apiKey;
	if (!accessToken) {
		notifyAuthFailure(ctx);
		return;
	}

	const accountId = extractCodexAccountId(accessToken);
	if (!accountId) {
		ctx.ui.notify("[codex-status] OpenAI Codex authentication is missing account information. Sign in again with /login.", "warning");
		return;
	}

	const provider = ctx.modelRegistry.getProvider(PROVIDER_ID);
	if (!provider?.baseUrl) {
		ctx.ui.notify("[codex-status] OpenAI Codex provider configuration is unavailable.", "warning");
		return;
	}

	let snapshot: CodexUsageSnapshot;
	try {
		snapshot = await (dependencies.fetchUsage ?? fetchCodexUsage)({
			baseUrl: provider.baseUrl,
			accessToken,
			accountId,
			signal: AbortSignal.timeout(dependencies.timeoutMs ?? DEFAULT_TIMEOUT_MS),
		});
	} catch (error) {
		const message =
			error instanceof CodexUsageError
				? error.message
				: "Unable to fetch OpenAI Codex usage right now.";
		ctx.ui.notify(`[codex-status] ${message}`, "warning");
		return;
	}

	await showStatus(ctx, formatCodexUsage(snapshot, ctx.model?.id));
}

export default function codexStatusExtension(pi: ExtensionAPI) {
	pi.registerCommand("codex-status", {
		description: "Show OpenAI Codex subscription usage limits",
		handler: async (_args, ctx) => runCodexStatus(ctx),
	});
}
