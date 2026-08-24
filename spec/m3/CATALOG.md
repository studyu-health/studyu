# CATALOG — measured M3 drift inventory (2026-08-24)

Merged from `.agents/skills/studyu-material3/references/studyu/deviations.md` and repo
searches. This is the backlog the task specs in `tasks/` are generated from.

## Counts (rg across designer_v2/lib + app/lib)

| Pattern | Count | Deviation # |
|---|---|---|
| `SizedBox(width:|height:)` literals | 416 | 1 |
| `Colors.*` usages | 235 | 2 |
| `fontSize:` literals | 80 | 3 |
| `BorderRadius.circular(` | 30 | 8 |
| `InkWell(` | 18 | 10 (a11y subset) |
| `FormTableLayout` consumers | 27 files | 11 |
| `ElevatedButton(` in app | ~20 call sites | 5 |
| `BottomNavigationBar(` widget call sites | 0 (theme-only) | 6 |

## Hotspots

- Auth: `designer_v2/lib/features/auth/*` — 4px gaps, `Divider(height: 1)`, raw
  `Colors.white` in `auth_scaffold.dart`, unlabeled password `InkWell`
  (`auth_form_fields.dart:97-107`), wording collisions.
- Designer theme: `designer_v2/lib/theme.dart:221-224` (raw whites), `:336-398`
  (non-M3 TextTheme, open TODO "migrate to 2021 term set"), `:258-267` (legacy
  BottomNavigationBarThemeData), `:569` (third link color).
- App theme: `app/lib/theme.dart` — `primaryColor: Colors.blue`, no seed, no TextTheme,
  no dark (deviation 13).
- Wrappers: `designer_v2/lib/common_views/primary_button.dart` (ElevatedButton base,
  white spinner), `text_hyperlink.dart:11-13` (browser hex defaults),
  `form_table_layout.dart:148` (Table layout).
- Links drift: `designer_v2/lib/features/design/fitbit/fitbit_credentials_form_view.dart`
  (deviation 14).

## Screen groups (for Phase 4 tasks)

- app onboarding: `app/lib/screens/app_onboarding/*` (welcome, terms, about, preview,
  loading/error/outdated/unavailable screens, study_switch_dialogs)
- app study onboarding: `app/lib/screens/study/onboarding/*` (consent, eligibility,
  kickoff, study_selection, journey_overview, intervention_selection, study_overview)
- app dashboard/tasks: `app/lib/screens/study/dashboard/*`,
  `app/lib/screens/study/tasks/*`
- app report: `app/lib/screens/study/report/*`
- app questionnaire widgets: `app/lib/widgets/questionnaire/**`
- designer shell: `features/study/study_scaffold.dart`, `study_navbar.dart`,
  `features/dashboard/dashboard_page.dart`, `app_drawer.dart`
- designer design forms: `features/design/**` (~50 form views)
- designer monitor/analyze/recruit/dialogs: `features/{monitor,analyze,recruit,dialogs}/**`
