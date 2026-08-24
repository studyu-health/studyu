# DECISIONS — locked choices for the M3 migration

Agents must not reopen these. To change one, a human edits this file and notes it in
ACTIVITY.md.

- D1 — Auth noun: settle on "account" in switch lines and titles; drop "workspace"
  wording in auth copy (deviation 12). en + de both updated.
- D2 — Auth labels: login CTA "Sign in", account-switch link on login "Sign up";
  signup CTA "Create account", switch link "Sign in"; forgot and recovery flows both
  use "Back to sign in"; forgot-send and recovery-submit get DISTINCT labels
  (e.g. "Send reset link" vs "Reset password").
- D3 — `PrimaryButton` keeps its public API (loading, disabled tooltip, icon); only the
  base widget changes `ElevatedButton` -> `FilledButton` (deviation 5).
- D4 — Brand `linkColor` is the single source for links; `Hyperlink` defaults to it.
  Links are the sanctioned exception to `colorScheme.primary` (deviation 9).
- D5 — Spacing tokens: introduce a named spacing constant set (4/8/12/16/24/32) per app
  package (`designer_v2/lib/common_views/spacing.dart`, `app/lib/widgets/spacing.dart`
  or nearest existing constants file); no shared cross-package import in phase 0-4.
- D6 — `app/` theme migrates to `ColorScheme.fromSeed` but does NOT import designer_v2
  tokens; it gets its own minimal seed-based theme incl. a text theme and dark variant
  (deviation 13).
- D7 — `form_table_layout.dart` is migrated screen-by-screen to labeled columns; the
  widget is deleted only after the last consumer is gone (deviation 11).
- D8 — Custom lint (`studyu_lints`) is warning-level only during the migration; it must
  never break `scripts/pre-commit-check`.
- D9 — Legacy `BottomNavigationBarThemeData` in `designer_v2/lib/theme.dart` is replaced
  by `NavigationBarThemeData`; no widget call sites exist (verified 2026-08-24), so this
  is theme-only (deviation 6).
- D10 — TextTheme term-set migration (deviation 4) is its own task and PR; no screen task
  may bundle it.
