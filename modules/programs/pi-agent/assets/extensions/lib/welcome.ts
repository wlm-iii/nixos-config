import { CustomEditor, VERSION, type ExtensionAPI, type ExtensionContext, type SessionEntry, type SessionStartEvent, type Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, type EditorComponent } from "@earendil-works/pi-tui";

export const DISMISSED_ENTRY = "ui-welcome-dismissed";

export function shouldShowWelcome(reason: SessionStartEvent["reason"], entries: readonly SessionEntry[]): boolean {
	if (reason === "resume" || reason === "fork") return false;
	return !entries.some((entry) =>
		(entry.type === "custom" && entry.customType === DISMISSED_ENTRY) ||
		(entry.type === "message" && entry.message.role !== "system") ||
		entry.type === "custom_message" || entry.type === "compaction" || entry.type === "branch_summary");
}

export function welcomeLines(width: number, theme: Theme, version = VERSION): string[] {
	if (width <= 0) return [];
	if (width < 18) return [truncateToWidth(theme.fg("bashMode", "pi"), width)];
	return [
		"",
		...[
			"    ==========",
			"      ||  ||",
			"      ||  ||",
			String.raw`      ||  \\//`,
		].map((line) => theme.fg("bashMode", line)),
		"",
		theme.fg("dim", `    pi · v${version}`),
		"",
	].map((line) => truncateToWidth(line, width));
}

/** Decorate only the public submission callback, preserving the editor instance. */
export function observeSubmission(editor: EditorComponent, submitted: () => void): void {
	let delegate = editor.onSubmit;
	const forward = function (this: unknown, text: string) {
		try {
			if (text.trim()) submitted();
		} catch {
			// Presentation failures must never swallow a prompt or command.
		}
		return delegate?.call(this, text);
	};
	// Pi assigns onSubmit after creating an editor, and may assign it again.
	// Keep forwarding the latest callback, not the factory-time snapshot.
	Object.defineProperty(editor, "onSubmit", {
		configurable: true,
		enumerable: true,
		get: () => delegate ? forward : undefined,
		set: (next: EditorComponent["onSubmit"]) => { delegate = next; },
	});
}

export function installWelcome(
	pi: ExtensionAPI,
	ctx: ExtensionContext,
	event: SessionStartEvent,
	onDismiss: () => void,
): { visible(): boolean; dismiss(): void } | undefined {
	if (ctx.mode !== "tui") return undefined;
	let visible = shouldShowWelcome(event.reason, ctx.sessionManager.getEntries());
	const dismiss = () => {
		if (!visible) return;
		visible = false;
		onDismiss();
		// UI-only state, not a model-facing message. No draft or command text.
		try {
			pi.appendEntry(DISMISSED_ENTRY, { dismissed: true });
		} catch {
			ctx.ui.notify("Could not save welcome-screen state; it may reappear after reload.", "warning");
		}
	};
	// Keep an empty custom header after dismissal. undefined would restore
	// Pi's original logo and tips instead of removing them.
	ctx.ui.setHeader(() => ({
		render: (width: number) => visible ? welcomeLines(width, ctx.ui.theme) : [],
		invalidate() {},
	}));
	if (visible) {
		const previous = ctx.ui.getEditorComponent();
		ctx.ui.setEditorComponent((tui, theme, keybindings) => {
			// Decorate the current factory (e.g. pi-vim) in place, not a proxy editor.
			const editor = previous?.(tui, theme, keybindings) ??
				new CustomEditor(tui, theme, keybindings, { embedWorkingStatus: true });
			observeSubmission(editor, dismiss);
			return editor;
		});
	}
	return { visible: () => visible, dismiss };
}
