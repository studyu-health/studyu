# StudyU deviations from Material 3 — known drift + migration targets

Handwritten from repository research (2026-08-24). Two kinds: **intentional** (StudyU chose this —
respect unless the task overrides) and **accidental** (drift — fix when touching the screen).
Each entry: what, where, M3 baseline, and the migration target.

## Accidental drift (fix when the screen is touched)

### 1. Hardcoded spacing, no token layer
- **What**: ~261 `const SizedBox(width|height: <n>)` literals in designer_v2 alone (~398 across
  designer_v2 + app, counted 2026-08-24); no spacing token file. Auth forms use 4px gaps between
  fields (`SizedBox(height: 4.0)`).
- **Where**: `designer_v2/lib/features/auth/*_form_view.dart` (4/8/16/24/12 values).
- **M3**: 8dp grid; 16–24dp between form fields.
- **Target**: named spacing constants (4/8/12/16/24/32) or a spacing token module; inter-field
  gaps ≥ 8.

### 2. Raw colors instead of colorScheme
- **What**: ~230 `Colors.*` + 26 `Color(0x…)` outside theme files. Worst: `AuthScaffold`
  `backgroundColor: Colors.white`; `AppBarTheme` `backgroundColor: Colors.white` +
  `surfaceTintColor: Colors.white`; `PrimaryButton` spinner `CircularProgressIndicator(color:
  Colors.white)`; `inputDecorationTheme` fills `Colors.white`.
- **Where**: `auth_scaffold.dart`, `designer_v2/lib/theme.dart:221-224`, `primary_button.dart`.
- **M3**: role-based colors; surfaces via `surface`/`surfaceContainer*` roles; elevation via
  surface tint.
- **Target**: `theme.colorScheme.*`; `Colors.white` → `colorScheme.surface` where role-appropriate.

### 3. Raw `TextStyle(fontSize: …)` at call sites
- **What**: ~67 `fontSize:` literals outside theme; auth views and `AuthScaffold` rebuild styles
  with `TextStyle(fontSize: theme.textTheme.bodySmall!.fontSize)` instead of reusing the style.
- **Where**: auth views, `auth_scaffold.dart:259`.
- **M3**: type scale via roles.
- **Target**: `theme.textTheme.bodySmall` (etc.) directly; only override what genuinely differs.

### 4. Non-M3 TextTheme sizes
- **What**: `designer_v2` `textTheme()` sets `bodyLarge/bodyMedium/titleMedium` 14 (M3 16/14/16),
  `displaySmall` 26 (M3 36), `displayMedium` 36 (M3 45), `displayLarge` 48 (M3 57), bold weights
  on display/headline. Open `TODO: migrate to 2021 term set` (`theme.dart:337`).
- **Where**: `designer_v2/lib/theme.dart:336-398`.
- **M3**: 15-style type scale with standard sizes/weights.
- **Target**: full term-set migration (large change, do not bundle into a screen fix — flag it).

### 5. `ElevatedButton` for the primary action
- **What**: `PrimaryButton` wraps `ElevatedButton` with `elevation: 0`.
- **Where**: `common_views/primary_button.dart`.
- **M3**: primary emphasis = `FilledButton`.
- **Target**: swap the wrapper's base widget to `FilledButton` (one change, all screens inherit),
  keep `PrimaryButton` API.

### 6. `BottomNavigationBar` (legacy) instead of `NavigationBar`
- **What**: `bottomNavigationBarTheme` configures `BottomNavigationBar`; `NavigationRailThemeData()`
  is empty; no `NavigationBarThemeData`.
- **Where**: `designer_v2/lib/theme.dart:258-267,407-409`.
- **M3**: `NavigationBar` (bottom), `NavigationRail` (side).
- **Target**: migrate theme to `NavigationBar`; keep `BottomNavigationBar` only while consumers
  use it.

### 7. `Divider(height: 1)` in forms
- **What**: all four auth forms use `Divider(height: 1)`.
- **M3**: divider default 16px vertical padding.
- **Target**: theme divider defaults; remove per-instance `height: 1`.

### 8. Hardcoded radii
- **What**: input border radius 5, `shapeMedium` 8, tooltip 2, 23 `BorderRadius.circular(...)`
  outside theme.
- **M3**: shape scale (4/8/12/16/28…).
- **Target**: theme shape; stop per-instance radii.

### 9. `Hyperlink` raw default link colors
- **What**: `linkColor = Color(0xFF0000EE)`, `visitedColor = Color(0xFF551A8B)` (browser defaults)
  while the theme's own link color is `Color(0xFF00B0FF)` — three sources of truth.
- **Where**: `common_views/text_hyperlink.dart:11-13`, `designer_v2/lib/theme.dart:569`.
- **Target**: single link color from theme/`linkColor`; Hyperlink defaults to it.

### 10. Password visibility toggle is an unlabeled `InkWell`
- **What**: `InkWell` + `Icon` with `FocusNode(skipTraversal: true)` created in `build`.
- **Where**: `features/auth/auth_form_fields.dart:97-107`.
- **M3/Flutter**: labeled `IconButton` (semantics, focusable, tooltip).
- **Target**: `IconButton` with `tooltip`/`semanticLabel`; don't `skipTraversal`.

### 11. `FormTableLayout` renders forms as `Table`
- **What**: forms (auth + many designer forms) layout fields in a `Table`.
- **Where**: `common_views/form_table_layout.dart:148`, used app-wide.
- **M3**: no table-based form; forms are columns of labeled fields.
- **Target**: labeled `Column` (or `Form` + fields); migrate per-screen. A11y is the driver.

### 12. Wording inconsistencies across equivalent flows
- **What** (from `localization/app_localizations_en.dart`):
  - Login account-switch: `link_signup_description` = "Don't have an account?" + `link_signup`
    ("Sign up").
  - Signup account-switch: `link_login_description` = "Already have an account?" + `link_login`
    ("Sign in").
  - Forgot + recovery: `link_login_description2` = "Log into your workspace?" + `link_login`
    ("Sign in").
  - CTA `action_button_login` = "Sign in" **and** link `link_login` = "Sign in" — same visible
    string for two different controls (submit vs switch-link). `action_button_signup` =
    "Create account" vs link `link_signup` = "Sign up" — same destination, two verbs.
  - `action_button_password_reset` = "Reset password" is reused for BOTH the forgot-flow
    send button (`password_forgot_form_view.dart`) AND the recovery-flow submit button
    (`password_recovery_form_view.dart`) — two distinct actions, one label.
  - Terminology split: login/signup switch lines say "account" while page titles and the forgot
    line say "workspace" ("Sign in to your workspace", "Log into your workspace?") — inconsistent
    noun for the same system.
- **M3**: consistent verb/phrasing across entry points; distinct labels for distinct actions.
- **Target**: unify the account-switch phrasing; avoid the CTA/link label collision (e.g. button
  "Sign in", link "Sign up" on login; button "Create account", link "Sign in" on signup; both
  forgot/recovery use the same "Back to sign in" phrasing); give the forgot-send and
  recovery-submit distinct labels; settle one noun (account or workspace) across titles and
  switch lines.

### 13. Participant `app` theme bypasses M3
- **What**: `app/lib/theme.dart` = `ThemeData(brightness: light, primaryColor: Colors.blue,
  colorScheme: ...copyWith(primary: blue, secondary: orange))`, no seed, no TextTheme, no dark.
- **M3**: seed-based scheme.
- **Target**: migrate `app` to `ColorScheme.fromSeed`; align with designer_v2 approach where
  appropriate.

### 14. Fitbit form links don't use `Hyperlink`
- **What**: `fitbit_credentials_form_view.dart` styles inline links with
  `Theme.of(context).primaryColor` + underline instead of the shared `Hyperlink`.
- **Target**: use `Hyperlink`.

## Intentional deviations (respect unless the task overrides)

| Pattern | Intent |
|---|---|
| `PrimaryButton`/`SecondaryButton` wrapper API (loading, disabled tooltip, icon) | StudyU's action API — keep, even as base widget migrates to `FilledButton` |
| `TwoColumnLayout` + 1000px breakpoint | StudyU's responsive shell — keep, note it is not M3 breakpoint-driven |
| `ThemeConfig` alpha-muted role colors | intentional muted text — verify contrast per surface |
| `linkColor` brand color harmonization (`CustomColor` blend) | StudyU brand mechanism — links are the sanctioned exception to "use colorScheme.primary" |
| Centered primary CTA + right-aligned "Forgot password?" | established auth form layout — preserve |

## Migration ordering (low-risk first)

1. Wording/l10n fixes (12) — zero code risk.
2. `Hyperlink` link color single-source (9).
3. `PrimaryButton` → `FilledButton` base (5) — one file, broad effect.
4. Spacing constants + nudge auth gaps to 8 (1).
5. Password visibility toggle → `IconButton` (10).
6. Per-screen raw color → colorScheme (2), `Divider` (7), radii (8).
7. `FormTableLayout` → labeled Column per screen (11).
8. `TextTheme` term-set migration (4), `app` theme (13) — large, separate PRs.
