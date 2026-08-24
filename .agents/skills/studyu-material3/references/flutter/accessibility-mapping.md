# M3 accessibility/interaction guidance → Flutter

Handwritten. Maps M3 accessibility and interaction guidance to Flutter semantics, focus, gestures,
autofill, and Material APIs. M3 accessibility principles live in
`../material/accessibility.md` and `../material/interaction.md`.

## Semantics

| Guidance | Flutter |
|---|---|
| Icon-only controls need labels | `IconButton(tooltip: ..., semanticLabel: ...)` — or `Semantics(label:)` on custom widgets |
| Custom widget with composed children = one focusable unit | `MergeSemantics` / `Semantics(container: true)` |
| Decorative imagery excluded from a11y | `Semantics(excludeSemantics: true)` / `ExcludeSemantics` |
| Screen-reader-friendly heading order | use `textTheme` heading styles; avoid skipping levels |

**StudyU deviations found** (fix when touching the screen):
- Password visibility toggle is `InkWell`+`Icon` with `FocusNode(skipTraversal: true)`
  (`auth_form_fields.dart`) — not reachable by keyboard, unlabeled. Replace with a labeled
  `IconButton`.
- `FormTableLayout` renders forms in a `Table`; use the migration guidance in
  `../studyu/deviations.md` #11 when touching one.

## Focus & keyboard

| Guidance | Flutter |
|---|---|
| Keyboard-reachable controls | default focus traversal; do not `skipTraversal: true` without reason |
| Custom interactive widgets get focus | `Focus` + `FocusNode` attached; indicate focus (`Material`/`InkWell` handles) |
| Enter/next between form fields | `TextInputAction.next` / `.done` on fields, `onSubmitted` to advance |
| Don't create `FocusNode` in `build()` | field instance / `useRef` — churn breaks focus state |

StudyU fields set no `TextInputAction`/`keyboardType` today — add `emailAddress` +
`autofillHints: [AutofillHints.email]` and `TextInputAction.next` when touching auth fields.

## Autofill & input

| Guidance | Flutter |
|---|---|
| Autofill on forms | wrap in `AutofillGroup`; `autofillHints` on each field |
| Correct keyboard | `keyboardType: TextInputType.emailAddress` (email), `.text`/`.number` as appropriate |
| Hints/labels from l10n | StudyU uses `tr.*` strings; never hardcode |

## Gestures & interaction

| Guidance | Flutter |
|---|---|
| Tap target ≥ 48×48dp (M3 minimum) | check `IconButton`/link/checkbox sizes; links may be shorter but add padding |
| Links are real links | `Hyperlink` + `Semantics(link: true)` where it opens a page |
| Loading state announced | `Semantics(liveRegion: true)` on spinner / `CircularProgressIndicator` with label |
| Disabled control explained | tooltip (StudyU `PrimaryButton.tooltipDisabled`) |

## Contrast & text

| Guidance | Flutter |
|---|---|
| ≥ 4.5:1 small text, 3:1 large | check `colorScheme` pairs; muted alphas (e.g. `onSurface @ 65%`) can drop below |
| No text-only color convey | pair color with icon/label |

StudyU uses alpha-muted role colors (`bodyTextMuted` @ 65%, `bodyTextBackground` @ 25%). These
are intentional but may fail contrast — verify on the specific background before trusting them.

## Test

- [ ] Full keyboard traversal of the screen (Tab order matches visual order).
- [ ] Screen reader reads headings, labels, button names.
- [ ] Focus visible on interactive elements.
- [ ] Tap targets ≥ 48dp.
