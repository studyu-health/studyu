# Flutter limitations vs Material 3 guidance

Handwritten. Where M3 guidance has NO clean 1:1 Flutter mapping — so the agent must compose, adapt,
or label a design decision rather than look for a widget.

## No direct widget

| M3 guidance | Why Flutter has no 1:1 | What to do |
|---|---|---|
| 8dp spacing grid | No spacing token widget in Flutter | named constants + 8dp-multiple `SizedBox`/`Padding` |
| Layout (grouping, alignment, hierarchy) | Composition, not a widget | `Column`/`Row`/`Padding`/`Align`/`Wrap`/`ConstrainedBox` |
| Breakpoints (window size classes) | No built-in breakpoint system | `LayoutBuilder`/`MediaQuery` + explicit branch |
| Content density (compact vs comfortable) | No global density switch | per-screen choices via `visualDensity` or explicit sizes |
| Minimum touch target enforcement | Widgets don't auto-expand to 48dp | manual `constraints`/`padding` on small targets |
| Container/`onContainer` roles in text | M3 says containers are fills only | use the paired `on*` role for text/icons |
| Surface tone-based elevation | No elevation overlay model in M3 Flutter | use tone-based `surfaceContainer*` roles, not derived overlays |
| Do/don't guidance | Not an API | read `references/material/components/*.md` before speccing |

## Theming gaps

| M3 capability | Flutter status | Workaround |
|---|---|---|
| Dynamic color everywhere | only Android via `DynamicScheme`/`ColorScheme.fromSeed`; desktop/web opt-in | `ThemeProvider` handles it in designer_v2 |
| Theme as a token service | Flutter themes are objects, not live tokens | read from `Theme.of(context)` only; don't cache raw `Color` across brightness |
| System font/type scale | Flutter uses fixed `TextTheme` unless textScaler overridden | respect `MediaQuery.textScalerOf(context)` |
| Component tokens at runtime | Flutter bakes into widget themes | set `*ThemeData` centrally; avoid per-instance overrides everywhere |

## StudyU-specific limits

- **Two theming philosophies**: `designer_v2` has a real M3 theme; `app` has a minimal theme. A
  pattern valid in one is not valid in the other. Check which app you are in before applying
  `colorScheme`/`textTheme` lookups.
- **`reactive_forms` layer**: StudyU forms bind via `ReactiveTextField`/`ReactiveCheckbox` etc.
  M3 guidance on a control still applies, but the widget is the reactive wrapper — style it through
  `Theme`/`InputDecorationTheme`, not by replacing it with a plain `TextField`.
- **`FormTableLayout` (Table)**: M3 has no form-as-table; the pattern is a StudyU artifact with
  a11y cost. Migration path is a labeled Column — but it is a deliberate existing pattern, so flag
  it (see decision hierarchy) rather than silently rewriting every form.

## When M3 is silent

M3 does not specify: per-screen stagger/choreography timings, many spacing gaps between arbitrary
elements, some wording choices. When M3 (and StudyU) don't cover a value:

> **From M3:** (what the guidance says, if anything)
> **My design decision (not in M3):** (the value, labelled as yours)

Never present an invented number or pattern as a Material requirement.
