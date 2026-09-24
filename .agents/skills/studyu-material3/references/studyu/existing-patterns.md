# StudyU existing UI patterns — what to preserve

Handwritten from repository research (2026-08-24). These are the intentional, consistent patterns
the StudyU Material 3 skill should keep agents aligned with. When a task hits one of these,
reuse it as-is (decision-hierarchy level 2) rather than re-deriving from Material.

## Architecture split — know which app you are in

| App | Package | Theme | Auth? |
|---|---|---|---|
| Study Designer | `designer_v2/` | full M3 (`ThemeProvider`, `fromSeed`, dynamic color) | yes — `features/auth/` |
| Participant | `app/` | minimal (raw `Colors.blue`/`orange`, one button theme) | no — onboarding only |

Same Melos workspace, two theming realities. Never apply a `designer_v2` token assumption in `app`
code or vice versa.

## Component pair — primary / secondary actions

- `PrimaryButton` (`common_views/primary_button.dart`): wraps `ElevatedButton`, `elevation: 0`,
  optional icon, loading state, disabled tooltip. Default inner padding
  `EdgeInsets.symmetric(horizontal: 4, vertical: 8)`. Used as **the** primary CTA across auth,
  forms, dialogs.
- `SecondaryButton` (`common_views/secondary_button.dart`): wraps `OutlinedButton`.

**Use `PrimaryButton`/`SecondaryButton` for every primary/secondary action.** Do not write raw
`ElevatedButton`/`OutlinedButton` unless you need something they cannot express (then note it).

## Form shell

- `FormScaffold` + `StandardDialog` + `buildFormButtons` (Cancel + Save) — the consistent form
  pattern across designer features (`study_settings_dialog`, `fitbit_credentials_form`, report
  forms, …).
- Fields via `ReactiveTextField`/`ReactiveCheckbox`/`ReactiveSwitch` (reactive_forms) wrapped in
  `FormTableLayout` rows with labels.
- Validation messages centralized in `AuthFormController.authValidationMessages`.

## Layout / responsive shell

- `TwoColumnLayout` (`common_views/layout_two_column.dart`) — the wide-screen shell for auth,
  dashboard, study edit.
- `AuthScaffold`: `LayoutBuilder` with `_compactBreakpoint = 1000.0`; compact → scrollable
  single-column (`ConstrainedBox(maxWidth: 520)`); wide → two-column (left panel min-width 500,
  content max-width 424, `backgroundColorLeft: colorScheme.surface`, right: `colorScheme.primary`).
- `ThemeConfig.kMinContentWidth = 600` / `kMaxContentWidth = 1264` — content column bounds.

## Links

- `Hyperlink` (`common_views/text_hyperlink.dart`) — text link with url or onClick, hover/visited
  styles. Default colors are raw browser hex (`0xFF0000EE`/`0xFF551A8B`) — see deviations.
- `TextParagraph` for body copy.

## Auth flow layout (the four screens)

All four (`login`, `signup`, `password_forgot`, `password_recovery`) follow the same structure:

```
Column(crossAxisAlignment: start)
  field(s)
  [right-aligned "Forgot password?" row on login only]
  SizedBox(24)
  Center(PrimaryButton)          // the single primary CTA
  SizedBox(24)
  Divider(height: 1)
  SizedBox(12)
  Wrap(center)  [prompt text] [Hyperlink(account-switch)]
```

This structure is consistent — preserve it. The **wording inside it is inconsistent** (deviations).

## Theming access

- `ThemeProvider.of(context)` (InheritedWidget) + `ThemeSettings{sourceColor, themeMode}`.
- `colorScheme` via `ColorScheme.fromSeed`; dynamic primary via `material_color_utilities`
  `SchemeFidelity` + `MaterialDynamicColors.primary`.
- Per-component themes centralized in `designer_v2/lib/theme.dart` (card, listTile, appBar,
  bottomNav, tabBar, switch, checkbox, radio, input, tooltip, snackbar, divider, icon).
- `ThemeConfig` static helpers (`bodyTextMuted`, `bodyTextBackground`, `containerColor`, …) are
  StudyU-owned text/color tokens — reuse them when they encode the shared intent.

## Localization

- All UI strings via l10n: `tr.*` in `localization/app_localizations_{en,de}.dart`. Never hardcode
  UI text (en + de must both exist).

## What is NOT a reusable pattern (do not extend)

- `FormTableLayout` for non-tabular forms — known a11y deviation; see `deviations.md` #11.
- The participant `app`'s raw-color theme — do not copy it into new `app` screens; prefer extending
  a seed-based scheme, but do not silently import `designer_v2` tokens.
