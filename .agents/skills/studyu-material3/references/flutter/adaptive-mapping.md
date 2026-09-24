# M3 responsive/adaptive guidance → Flutter

Handwritten. M3 breakpoints and adaptive navigation guidance mapped to Flutter. M3 breakpoint
definitions live in `../material/layout.md`; this file is the Flutter translation + StudyU notes.

## M3 breakpoints (window size classes)

| M3 breakpoint | Width |
|---|---|
| Compact | < 600dp |
| Medium | 600–840dp |
| Expanded | 840–1200dp |
| Large | 1200–1600dp |
| Extra-large | > 1600dp |

StudyU **deviation**: `AuthScaffold` uses a single `_compactBreakpoint = 1000.0` with two layouts
(compact single-column / wide two-column), and `ThemeConfig` has `kMinContentWidth = 600` /
`kMaxContentWidth = 1264`. This is bespoke, not M3 breakpoint-driven. Keep M3 names in mind when
deciding what to change; do not assume 1000dp equals an M3 boundary.

## Flutter tools

| Guidance | Flutter |
|---|---|
| Branch layout on available width | `LayoutBuilder(builder: (context, constraints) => ...)` |
| Read screen size/insets | `MediaQuery.of(context).size` / `.padding` |
| Adaptive bottom nav (compact) → rail/drawer (wide) | `NavigationBar` (compact) → `NavigationRail` (medium+) — StudyU uses `BottomNavigationBar` + custom drawer today |
| Constrain content column | `ConstrainedBox(maxWidth: ...)` + center |
| Two-pane layout | `Row`/`TwoColumnLayout` (StudyU `common_views/layout_two_column.dart`) |

## StudyU adaptive patterns to reuse

- `TwoColumnLayout` (auth, dashboard, study edit) with `LayoutBuilder` breakpoint.
- `AuthScaffold`: `isCompact = constraints.maxWidth < _compactBreakpoint` → compact scrollable
  single-column (`ConstrainedBox(maxWidth: 520)`) vs wide two-column (left panel min-width 500,
  content max-width 424).
- `ThemeConfig.kMinContentWidth` / `kMaxContentWidth` for content column bounds.

When adapting an existing StudyU screen, mirror the neighboring screen's breakpoint and shell —
consistency across screens beats a novel breakpoint scheme on one screen.

## Checklist for a responsive change

- [ ] Content does not overflow at compact width (test via `flutter run` at narrow window).
- [ ] Primary action stays reachable without scrolling into a fold at compact width.
- [ ] Navigation component matches size class (bottom bar vs rail/drawer).
- [ ] Consistent with the neighboring StudyU screen's breakpoint behavior.
