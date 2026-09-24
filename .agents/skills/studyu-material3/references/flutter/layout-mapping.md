# M3 layout guidance → Flutter composition

Handwritten. Most M3 layout guidance maps to composition, not a single widget. This file routes
guidance → Flutter building blocks. M3 spacing/grid specifics come from
`../material/layout.md` and `../material/foundations.md`.

## Spacing & the 8dp grid

M3 spacing is on an 8dp grid (4dp for small elements). Flutter has no spacing token widget by
default; StudyU uses inline `SizedBox`. Rule: **use 8dp multiples** and prefer small named
constants over bare literals when a file repeats values.

| Intent | Flutter |
|---|---|
| Vertical gap between stacked children | `SizedBox(height: 8.0)` (or 16, 24 — 8dp multiples) |
| Horizontal gap between inline elements | `SizedBox(width: 8.0)` |
| Equal gaps in a Wrap | `Wrap(spacing: 8, runSpacing: 8)` |
| Space between form fields (M3: 16–24) | `SizedBox(height: 16)` / `24` |

StudyU **deviation**: auth forms use 4px gaps between fields (`SizedBox(height: 4.0)`) — below M3's
16–24 recommendation, and off the 8dp grid. Do not copy; when touching a form, nudge to 8/16.

## Grouping & hierarchy

| Guidance | Flutter |
|---|---|
| Group related content | `Column` / `Row` (flex), `Card`, section headings via `textTheme.titleMedium/Large` |
| Separate groups more than within | outer `Padding` / `SizedBox(height: 24–32)` between groups; 8–16 within |
| Draw attention to primary action | emphasis via `FilledButton` (+ container fill, margin) |
| Center a single narrow element (CTA) | `Center(child: ...)` |
| Constrain form width on wide screens | `ConstrainedBox(maxWidth: 520)` (StudyU `AuthScaffold` compact) |

## Alignment & positioning

| Guidance | Flutter |
|---|---|
| Left-align form labels/fields (LTR) | `CrossAxisAlignment.start` on the Column |
| Right-align a trailing affordance (Forgot password?) | `Row(mainAxisAlignment: MainAxisAlignment.end, ...)` |
| Center a heading block | `textAlign: TextAlign.center` |
| Avoid mixing alignment within a screen | pick one per group; check neighboring StudyU screens |

StudyU convention: auth forms use `CrossAxisAlignment.start` columns with a `Center`ed CTA and a
right-aligned "Forgot password?" row (`login_form_view.dart`) — this is the existing pattern,
preserve it unless the task says otherwise.

## Form composition

StudyU wraps fields in `FormTableLayout` (a `Table`). This is a known a11y deviation; apply the
migration guidance in `../studyu/deviations.md` #11 if the task touches the form.

## Wrapping & overflow

| Guidance | Flutter |
|---|---|
| Variable-width inline content (account-switch line) | `Wrap` (StudyU uses this in auth forms) |
| Long consent text | `Wrap` with `Flexible`, or `RichText`/`Text.rich` |
| Avoid overflow on narrow screens | `Flexible` / `Expanded` inside flex; `SingleChildScrollView` for tall forms |
