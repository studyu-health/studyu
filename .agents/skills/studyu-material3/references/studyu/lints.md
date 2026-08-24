# StudyU UI-drift lints — proposal + wiring

Handwritten. Static-analysis rules that objectively catch the UI drift catalogued in
`deviations.md`. Proposed as a `custom_lint` plugin (warning-level, additive — it must not break
`pre-commit-check` until StudyU chooses to adopt it).

## Current state

- Root `analysis_options.yaml`: `include: package:lint/strict.yaml` + minor overrides. No
  UI-drift rules.
- `app/analysis_options.yaml`: enables the `custom_lint` **plugin**, but `custom_lint` is NOT a
  dependency in `app/pubspec.yaml` — the plugin is inert today.
- `designer_v2/analysis_options.yaml`: uses `riverpod_lint` (not `custom_lint`).
- Consequence: both apps silently accept raw colors, inline `TextStyle`, `Divider(height:1)`,
  `ElevatedButton`-for-primary, legacy `BottomNavigationBar`.

## Target: a `studyu_lints` custom_lint plugin

Repo: `designer_v2/studyu_lints/` (or `packages/studyu_lints/` if StudyU centralizes lint packages).

```
studyu_lints/
├── pubspec.yaml          # deps: custom_lint, analyzer, analyzer_plugin, path
│                         # dev: custom_lint_test, test, matcher
├── analysis_options.yaml # include: package:lint/strict.yaml
├── lib/
│   ├── studyu_lints.dart # Plugin createPlugin() => _Plugin();
│   └── src/
│       ├── plugin.dart
│       ├── no_raw_colors_in_widgets.dart
│       ├── no_inline_text_style.dart
│       ├── no_divider_height_one.dart
│       └── prefer_filled_button_for_primary.dart
```

Wire-up (both apps): add `studyu_lints` to `dev_dependencies`, keep the `custom_lint` plugin
entry in `analysis_options.yaml`. `designer_v2` needs the `custom_lint` plugin added alongside
`riverpod_lint`.

## Rules

### 1. `no_raw_colors_in_widgets` (warning)
- **Catches**: `Colors.white`, `Colors.blue`, `Color(0xFF…)` used in widget build methods outside
  theme files.
- **Pattern**: visit `InstanceCreationExpression`/`PrefixedIdentifier` where target is
  `Colors.*`/`Color(` and enclosing declaration is a `build`/widget method and file is not
  `theme.dart`.
- **Fix message**: "Use `Theme.of(context).colorScheme.*`; raw colors bypass M3 roles
  (deviations.md #2)."

### 2. `no_inline_text_style` (warning)
- **Catches**: `TextStyle(fontSize: ...)` / bare `TextStyle(...)` outside theme files.
- **Pattern**: `InstanceCreationExpression` of `TextStyle` outside `theme.dart`/`ThemeConfig`.
- **Fix message**: "Reuse `theme.textTheme.*`; inline font sizes drift from the M3 type scale
  (deviations.md #3)."

### 3. `no_divider_height_one` (warning)
- **Catches**: `Divider(height: 1)` / `const Divider(height: 1)`.
- **Pattern**: `InstanceCreationExpression` of `Divider` with `height: 1`.
- **Fix message**: "M3 divider default has 16px vertical padding (deviations.md #7)."

### 4. `prefer_filled_button_for_primary` (info)
- **Catches**: `ElevatedButton` used where the widget is the screen's primary CTA.
- **Pattern**: `ElevatedButton` instance; `info` level because detection of "primary" is
  heuristic. Flags candidates for human review.
- **Fix message**: "M3 primary emphasis = `FilledButton`; StudyU wraps this in `PrimaryButton`
  (deviations.md #5)."

## Rollout

1. Implement the plugin in a branch; add `studyu_lints` dep to `app` first (custom_lint already
   wired there).
2. Run `flutter analyze`; expect warnings only — confirm `scripts/pre-commit-check` still passes.
3. Land as warning-level. Promote a rule to error only after the corresponding migration (e.g.
   `PrimaryButton` → `FilledButton`) is merged repo-wide.
4. Extend later: legacy `BottomNavigationBar`, `FormTableLayout`-as-Table, unlabeled `InkWell`
   toggles — same plugin.

## Verification note

Written from the `custom_lint` plugin API contract; the rules above are the spec. They must be
compiled against the pinned analyzer/custom_lint versions in a Dart-enabled environment before
shipping. This repo's agent environment may not have a Flutter SDK — see the skill's
`refresh-flutter.js` for how to validate the Flutter surface without one.
