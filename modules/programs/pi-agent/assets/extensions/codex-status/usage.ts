import { Buffer } from "node:buffer";

const CHATGPT_ORIGIN = "https://chatgpt.com";
const CHATGPT_ACCOUNT_CLAIM = "https://api.openai.com/auth";

export class CodexUsageError extends Error {
	constructor(message: string) {
		super(message);
		this.name = "CodexUsageError";
	}
}

export interface CodexUsageWindow {
	usedPercent: number;
	windowSeconds?: number;
	resetsAt?: number;
}

export interface CodexUsageSnapshot {
	planType?: string;
	allowed?: boolean;
	limitReached?: boolean;
	primary?: CodexUsageWindow;
	secondary?: CodexUsageWindow;
	creditBalance?: string;
	resetCredits?: number;
	fetchedAt: number;
}

export interface FetchCodexUsageOptions {
	baseUrl: string;
	accessToken: string;
	accountId: string;
	fetchImpl?: typeof fetch;
	signal?: AbortSignal;
	now?: number;
}

type JsonRecord = Record<string, unknown>;

function asRecord(value: unknown): JsonRecord | undefined {
	return typeof value === "object" && value !== null && !Array.isArray(value)
		? (value as JsonRecord)
		: undefined;
}

function finiteNumber(value: unknown): number | undefined {
	const parsed = typeof value === "number" ? value : typeof value === "string" ? Number(value) : Number.NaN;
	return Number.isFinite(parsed) ? parsed : undefined;
}

function booleanValue(value: unknown): boolean | undefined {
	return typeof value === "boolean" ? value : undefined;
}

function decodeBase64Url(value: string): string {
	const normalized = value.replace(/-/g, "+").replace(/_/g, "/");
	const padded = normalized + "=".repeat((4 - (normalized.length % 4)) % 4);
	return Buffer.from(padded, "base64").toString("utf8");
}

/** Extracts the account id in memory without retaining the OAuth token or decoded JWT. */
export function extractCodexAccountId(accessToken: string): string | undefined {
	const parts = accessToken.split(".");
	if (parts.length !== 3 || !parts[1]) return undefined;

	try {
		const payload = asRecord(JSON.parse(decodeBase64Url(parts[1])));
		const authClaim = asRecord(payload?.[CHATGPT_ACCOUNT_CLAIM]);
		const accountId = authClaim?.chatgpt_account_id;
		return typeof accountId === "string" && accountId.length > 0 ? accountId : undefined;
	} catch {
		return undefined;
	}
}

/** Build the Codex usage URL while preventing bearer-token forwarding to another host. */
export function buildCodexUsageUrl(baseUrl: string): string {
	let url: URL;
	try {
		url = new URL(baseUrl);
	} catch {
		throw new CodexUsageError("OpenAI Codex has an invalid service URL.");
	}

	if (url.origin !== CHATGPT_ORIGIN) {
		throw new CodexUsageError("Refusing to send OpenAI authentication to an unexpected service host.");
	}

	const basePath = url.pathname.replace(/\/+$/, "");
	url.pathname = `${basePath}/wham/usage`;
	url.search = "";
	url.hash = "";
	return url.toString();
}

function parseWindow(value: unknown, now: number): CodexUsageWindow | undefined {
	const window = asRecord(value);
	if (!window) return undefined;

	const usedPercent = finiteNumber(window.used_percent);
	if (usedPercent === undefined) return undefined;

	const windowSeconds = finiteNumber(window.limit_window_seconds);
	const resetAt = finiteNumber(window.reset_at);
	const resetAfterSeconds = finiteNumber(window.reset_after_seconds);
	let resetsAt: number | undefined;
	if (resetAt !== undefined) {
		resetsAt = resetAt > 1_000_000_000_000 ? resetAt : resetAt * 1000;
	} else if (resetAfterSeconds !== undefined) {
		resetsAt = now + resetAfterSeconds * 1000;
	}

	return {
		usedPercent: Math.min(100, Math.max(0, usedPercent)),
		...(windowSeconds !== undefined && windowSeconds > 0 ? { windowSeconds } : {}),
		...(resetsAt !== undefined ? { resetsAt } : {}),
	};
}

function parseCreditBalance(value: unknown): string | undefined {
	if (typeof value === "string" && value.trim().length > 0) return value.trim();
	const numeric = finiteNumber(value);
	return numeric === undefined ? undefined : String(numeric);
}

/** Supports both the current wrapped response and the older top-level response shape. */
export function parseCodexUsagePayload(payload: unknown, now = Date.now()): CodexUsageSnapshot {
	const root = asRecord(payload);
	if (!root) throw new CodexUsageError("OpenAI returned an invalid Codex usage response.");

	const status = asRecord(root.rate_limits) ?? root;
	const rateLimit = asRecord(status.rate_limit);
	const credits = asRecord(status.credits);
	const resetCreditBlock = asRecord(root.rate_limit_reset_credits) ?? asRecord(status.rate_limit_reset_credits);

	const primary = parseWindow(rateLimit?.primary_window, now);
	const secondary = parseWindow(rateLimit?.secondary_window, now);
	if (!primary && !secondary) {
		throw new CodexUsageError("OpenAI did not return Codex usage windows.");
	}

	const planType = typeof status.plan_type === "string" ? status.plan_type : undefined;
	const creditBalance = parseCreditBalance(credits?.balance);
	const availableResetCredits = finiteNumber(resetCreditBlock?.available_count);

	return {
		...(planType ? { planType } : {}),
		...(booleanValue(rateLimit?.allowed) !== undefined ? { allowed: booleanValue(rateLimit?.allowed) } : {}),
		...(booleanValue(rateLimit?.limit_reached) !== undefined
			? { limitReached: booleanValue(rateLimit?.limit_reached) }
			: {}),
		...(primary ? { primary } : {}),
		...(secondary ? { secondary } : {}),
		...(creditBalance !== undefined ? { creditBalance } : {}),
		...(availableResetCredits !== undefined ? { resetCredits: Math.max(0, Math.trunc(availableResetCredits)) } : {}),
		fetchedAt: now,
	};
}

export async function fetchCodexUsage(options: FetchCodexUsageOptions): Promise<CodexUsageSnapshot> {
	const url = buildCodexUsageUrl(options.baseUrl);
	let response: Response;
	try {
		response = await (options.fetchImpl ?? fetch)(url, {
			method: "GET",
			headers: {
				Accept: "application/json",
				Authorization: `Bearer ${options.accessToken}`,
				"ChatGPT-Account-Id": options.accountId,
			},
			signal: options.signal,
		});
	} catch {
		throw new CodexUsageError("Unable to reach the OpenAI Codex usage service.");
	}

	if (!response.ok) {
		throw new CodexUsageError(`OpenAI Codex usage request failed (HTTP ${response.status}).`);
	}

	let payload: unknown;
	try {
		payload = await response.json();
	} catch {
		throw new CodexUsageError("OpenAI returned an unreadable Codex usage response.");
	}

	return parseCodexUsagePayload(payload, options.now);
}

function formatPercent(value: number): string {
	return Number.isInteger(value) ? String(value) : value.toFixed(1);
}

function formatWindowDuration(seconds: number | undefined, fallback: string): string {
	if (seconds === undefined) return fallback;
	const days = seconds / 86_400;
	if (seconds >= 86_400 && Number.isInteger(days)) return `${days}-day`;
	const hours = seconds / 3600;
	if (Number.isInteger(hours)) return `${hours}-hour`;
	return fallback;
}

function formatResetTime(resetsAt: number | undefined): string {
	if (resetsAt === undefined) return "reset time unavailable";
	return `resets ${new Date(resetsAt).toLocaleString()}`;
}

export function formatCodexUsage(snapshot: CodexUsageSnapshot, modelId?: string): string {
	const planType = snapshot.planType
		? `${snapshot.planType.charAt(0).toUpperCase()}${snapshot.planType.slice(1)}`
		: undefined;
	const lines = [`OpenAI Codex${planType ? ` — ${planType}` : ""}`];
	const windows: Array<[CodexUsageWindow | undefined, string]> = [
		[snapshot.primary, "Primary"],
		[snapshot.secondary, "Secondary"],
	];

	for (const [window, fallback] of windows) {
		if (!window) continue;
		const used = window.usedPercent;
		const remaining = Math.max(0, 100 - used);
		const label = formatWindowDuration(window.windowSeconds, fallback);
		lines.push(
			`${label} limit: ${formatPercent(used)}% used · ${formatPercent(remaining)}% remaining · ${formatResetTime(window.resetsAt)}`,
		);
	}

	if (snapshot.creditBalance !== undefined) lines.push(`Credits: ${snapshot.creditBalance}`);
	if (snapshot.resetCredits !== undefined) lines.push(`Banked resets: ${snapshot.resetCredits}`);
	if (modelId) lines.push(`Model: ${modelId}`);
	if (snapshot.limitReached) lines.push("Status: included usage limit reached");
	return lines.join("\n");
}
