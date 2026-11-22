# UI footer

Repository-owned, footer-only extension for Pi 1.5.0. The existing prompt editor,
Vim integration, prompt icon, and startup header are unchanged.

```text
~/.pi · main                                      openai · model-name · high
Build       ↑97k · ↓4.6k · R296k · CH99.5% · $1.492 (sub) · 16.1%/272k (auto)
```

- Top left: home-shortened working directory, Git branch, and session name when set.
- Top right: provider (when multiple providers are available), model, and reasoning effort.
  The model name uses `bashMode` (orange in Gruvbox Dark), matching the welcome art;
  the provider remains dim and effort retains its thinking-level color.
- Bottom left: the exact colored status published by `@inobit/pi-permission` under
  `pi-permission-mode`. No mode is invented if that status is absent.
- Bottom right: Pi-style input/output/cache totals, latest-response cache hit rate,
  estimated session cost, subscription marker, context percentage/window, and
  automatic-compaction marker. Zero usage fields are omitted like the native footer.
- Other extension statuses remain visible on additional rows, sorted by key.
- On narrow terminals, workspace/model text is shortened; permission and statistics
  wrap onto additional rows instead of dropping fields.
- Context warnings follow Pi's native thresholds: warning above 70%, error above 90%.

Uses the current theme, live model/effort, cached provider auth metadata, Pi's Git
branch watcher, and in-memory session metadata/usage. It performs no direct file
reads/writes, shell execution, network requests, credential resolution, or updates.
Usage totals follow Pi 1.5's whole-session accounting, including summaries, cache
warming, and tool-reported usage; `CH` describes the latest assistant response,
not a session-wide hit rate. Virtual-model routing details are not displayed.

## Activation and rollback

The extension is auto-discovered once this branch is merged into the live checkout
and Pi is reloaded. A separate worktree does not activate it in the live checkout.
To preview before merging, start a separate Pi invocation:

```bash
pi -e /tmp/pi-ui-customization/agent/extensions/ui-footer/index.ts
```

Only preview one custom footer at a time. `/ui-footer off` restores the native
footer; `/ui-footer on` reinstates this one; `/ui-footer` toggles it. The choice
resets on `/reload`, session replacement, or restart. Remove this directory and
reload Pi for permanent rollback. No settings or package changes are required.
