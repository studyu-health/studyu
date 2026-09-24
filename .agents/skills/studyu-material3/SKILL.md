---
name: studyu-material3
description: Use when designing, implementing, or reviewing any UI change in StudyU (participant app or Study Designer) — including reviews of pull requests that touch UI in `app/` or `designer_v2/`. Routes Material 3 guidance from generated m3.material.io references, maps it to correct Flutter widgets and theme lookups, and enforces consistency with existing StudyU patterns. Covers layout, spacing, hierarchy, grouping, primary vs secondary actions, positioning, responsive/adaptive behavior, accessibility, interaction, typography, color, shape, motion, Material component selection, Flutter implementation, UI wording, and consistency with neighboring StudyU screens. Triggers on UI tasks, Material 3 guidance questions, screen reviews, auth/form redesigns, theme or token changes.
argument-hint: "[screen/file to review]"
---

# StudyU Material 3 UI skill

StudyU ships two Flutter apps on one Melos workspace: the participant-facing `app` and the Study
Designer `designer_v2`. Both run Material 3 widgets, but only `designer_v2` has a real M3 theme
(`ColorScheme.fromSeed`, dynamic color, per-component themes). This skill makes a UI change
conform to **Material 3 guidance** AND to **StudyU's existing patterns**, whichever applies first.

## Workflow — follow this for every StudyU UI task

### Step 1 — Inspect the affected UI (do NOT code yet)

- Open the complete affected screen, not just the ticket's lines.
- Open neighboring screens and equivalent flows elsewhere in StudyU (same form elsewhere? same
  component used elsewhere?).
- Note the shared layout/components the screen already uses.
- Note current theme/token state: `Theme.of(context)` in `designer_v2` reads the full
  `ThemeProvider` system; the participant `app` has a minimal theme — do not assume parity.

### Step 2 — Identify the UI problem semantically

State in one line each: primary user goal, primary action, secondary actions, navigation actions,
content groups, information hierarchy, form relationships (if a form), responsive requirements.

### Step 3 — Consult relevant Material guidance (route, don't read everything)

| Need | Route to |
|---|---|
| Spacing / grouping / alignment | `references/material/layout.md` + `references/material/foundations.md` + `references/flutter/layout-mapping.md` |
| Forms / login / register / input | `references/material/components/input.md` + `references/material/components/buttons.md` + `references/material/interaction.md` + `references/material/layout.md` |
| Buttons / action emphasis | `references/material/components/buttons.md` + `references/flutter/material-mapping.md` + `references/studyu/existing-patterns.md` (StudyU uses `PrimaryButton`) |
| Navigation | `references/material/components/navigation.md` + `references/flutter/adaptive-mapping.md` |
| Typography | `references/material/typography.md` + `references/material/tokens.md` + `references/flutter/theming.md` |
| Color | `references/material/color.md` + `references/material/tokens.md` + `references/flutter/theming.md` |
| Shape / radii | `references/material/shape.md` + `references/material/tokens.md` |
| Motion | `references/material/motion.md` + `references/material/tokens.md` + `references/material/component-tokens.md` + `references/flutter/motion-mapping.md` |
| Accessibility | `references/material/accessibility.md` + `references/material/interaction.md` + `references/flutter/accessibility-mapping.md` |
| Any exact number | `references/material/tokens.md` and `references/material/component-tokens.md` FIRST — never from memory |
| Does StudyU already do this? | `references/studyu/existing-patterns.md` + `references/studyu/deviations.md` |
| Which UI drift do lints catch? | `references/studyu/lints.md` |
| Flutter widget exists for this? | `references/flutter/material-mapping.md` + `references/flutter/limitations.md` |

### Step 4 — Compare against StudyU precedent

Apply the decision hierarchy below (§ Decision hierarchy). For a value or pattern absent from
StudyU and M3, follow the explicit-label rule in `references/flutter/limitations.md`.

### Step 5 — Implement in Flutter

- Reuse existing StudyU abstractions when they represent the same pattern (`PrimaryButton`,
  `SecondaryButton`, `FormScaffold`, `TwoColumnLayout`, `Hyperlink`, `EmailTextField`).
- Otherwise use official Flutter Material components (FilledButton, NavigationBar, TextField, …).
- Read color/type/spacing from the current theme — never hardcode. In `designer_v2`:
  `Theme.of(context).colorScheme.*`, `.textTheme.*`. In the participant `app`, the theme is
  minimal — either extend the theme or use the app's existing conventions; do not silently assume
  `designer_v2` tokens exist there.
- Check `references/studyu/deviations.md` for known traps before you reproduce them.

### Step 6 — Review the ENTIRE screen (not just touched lines)

Run the review checklist (§ Review checklist). The review must cover the whole affected screen and
its consistency with neighboring StudyU screens.

## Decision hierarchy (source of truth order)

```
task/design requirement
  > intentional existing StudyU pattern (must be listed in references/studyu/deviations.md § Intentional deviations)
    > Material 3 guidance (generated refs)
      > Flutter conventions
        > new design decision (labelled as such)
```

Document which level you chose, and name the level's source (file/token/doc) in the change or review.

**Drift-precedent rule**: the "intentional existing StudyU pattern" level only covers entries explicitly listed under *Intentional deviations* in `references/studyu/deviations.md`. Anything in *Accidental drift* is a known violation, not a pattern — never cite it as precedent. If code you're touching reproduces accidental drift (raw colors, inline radii, unlabeled `InkWell`, 4px gaps, `Table`-based layout…), fix it or flag it as a violation per the migration target — do NOT extend it to new code, even to "stay consistent" with the file you're in.

## StudyU context you should already know

- Auth lives ONLY in `designer_v2/lib/features/auth/` (Login, Signup, PasswordForgot,
  PasswordRecovery). The participant `app` has onboarding, not auth.
- Primary action = `PrimaryButton` (wraps `ElevatedButton` today — see deviations; M3 would use
  `FilledButton`). Secondary = `SecondaryButton` (OutlinedButton). This pair is the StudyU
  convention — do not replace it casually.
- Forms use `FormScaffold`/`StandardDialog` + `FormTableLayout`. See deviations for the
  `FormTableLayout` a11y caveat.
- All UI strings go through l10n (`tr.*`, en + de). Never hardcode UI text.
- Responsive: `designer_v2` uses `TwoColumnLayout` + `LayoutBuilder` breakpoints (e.g.
  `AuthScaffold` 1000px); participant `app` uses bare Scaffolds.

## Review checklist (final screen review)

For the whole affected screen:

- [ ] **Hierarchy**: primary action is visually strongest; one clear primary CTA per task.
- [ ] **Grouping**: related content grouped; spacing between groups > spacing within groups.
- [ ] **Wording**: consistent with equivalent StudyU flows; verbs match across entry points
      ("Sign in" CTA vs "Sign in" link collision — see deviations); strings via `tr.*`.
- [ ] **Alignment**: consistent within screen and with neighboring screens; not mixed.
- [ ] **Spacing rhythm**: on the 8dp grid; no arbitrary `SizedBox` values; spacing tokens if any.
- [ ] **Action prominence**: primary > secondary > tertiary; destructive actions not primary.
- [ ] **Component selection**: correct M3 component → Flutter widget (see material-mapping).
- [ ] **Adaptive**: layout handles compact/medium/expanded without breakage.

### M3 conformance sub-checklist (runs against every changed line AND the surrounding screen)

These items are the M3 non-negotiables; a violation here is never acceptable as "consistent with
the codebase" — StudyU's own drift (see deviations.md § Accidental) is the thing being fixed, not
the reference against which to conform:

- [ ] **Touch target**: every tappable/pressable control ≥ 48×48dp (`MinSize`/`IconButton` visual density), not just the drawn hit rect.
- [ ] **Semantics**: every interactive element has a button/link/… role and an accessible label; `Tooltip.message` alone is not a label; unlabeled `InkWell`/`GestureDetector` for actions is a violation.
- [ ] **Typography**: from `textTheme`, not raw `TextStyle(fontSize:)`.
- [ ] **Colors**: from `colorScheme`, not raw `Colors.*`/`Color(0x…)` (StudyU-sanctioned exception: brand `linkColor` for `Hyperlink` only).
- [ ] **Shape**: from theme shape / shape tokens, not raw `BorderRadius.circular(...)` at call sites.
- [ ] **Spacing**: on the 4/8 grid; introduce named spacing constants for repeated values; never add per-instance magic literals.
- [ ] **Motion**: durations/easings from the M3 easing-duration token table (short/medium/long × emphasis/standard); if Flutter lacks the token, use a named constant grounded in that table — not a raw `220`/`0.92` at the call site.
- [ ] **Input components**: helper text and error text are separate slots (`references/material/components/input.md`); an invalid field surfaces `errorText` in `colorScheme.error`, never repurposes `helperText` or another flow's string.
- [ ] **Buttons**: primary emphasis = `FilledButton` (StudyU wrapper = `PrimaryButton`); destructive ≠ primary.

## Output format for reviews

When asked to evaluate code or a PR, format every finding as a Conventional Comments entry
(repo rule): `<label> [decorations]: <subject>\n\n[discussion]` with labels from
`praise: | nitpick: | suggestion: | issue: | todo: | question: | thought: | chore: | note:` and
decorations `(blocking) | (non-blocking) | (if-minor)`. Cite: the file:line in the change, the
M3 source the finding maps to (skill reference + anchor), and, when the drift is already catalogued,
the deviations.md entry number.

## Common StudyU mistakes to avoid

| Mistake | Correct |
|---|---|
| Raw `Colors.blue`/`Colors.white` in widgets | `Theme.of(context).colorScheme.*` |
| `TextStyle(fontSize: 14, ...)` at call sites | reuse `theme.textTheme.*` |
| `BorderRadius.circular(5)` inline | theme shape / shape tokens |
| `ElevatedButton` for the primary action | M3 primary = `FilledButton`; StudyU = `PrimaryButton` |
| `BottomNavigationBar` | M3 = `NavigationBar` |
| `Divider(height: 1)` | M3 divider default vertical padding |
| `Table` for non-tabular forms (`FormTableLayout`) | column of labeled fields |
| Unlabeled `InkWell` for password visibility toggle | labeled `IconButton` (semantics + focus + tooltip) |
| Wording diverging between equivalent flows | match the existing flow's phrasing (see deviations) |
| Inline `TextStyle` on hyperlinks | use `Hyperlink` / theme link style |

## Refresh (maintenance)

Regenerate Material references when M3 ships an update — from the skill root:

```bash
node scripts/refresh-m3.js routes                          # sanity: confirm route count is as expected
node scripts/refresh-m3.js pages .build/m3-pages           # scrape (vendored)
node scripts/refresh-material-refs.js                      # consolidate into references/material/
node scripts/refresh-component-tokens.js                   # regenerate token geometry
git diff                                                   # review before committing
```

Last full scrape: `carbonVersion=2026-08-19_06-10-14` — 91 routes, 76 guidance pages consolidated
into the 14 reference files (the remaining ~15 are platform/dev/blog/index pages, intentionally
excluded). Expected coverage invariants after a refresh:

- `references/material/` has exactly the 14 category files (foundations, layout, interaction,
  accessibility, color, typography, shape, motion, components/{buttons,input,navigation,
  containment,feedback,bars}, tokens, component-tokens).
- `refresh-component-tokens.js` reports `0 unassigned, 0 fetch failures`.
- Each generated file's first line names the source slug(s) and updated timestamp — a refresh that
  drops a page silently is refused by `refresh-material-refs.js` ("refusing to overwrite generated
  references: … required scraped page(s) missing"), which is the strictness signal to look for.

Generated pages carry a source attribution header (`<!-- Source: … -->`); `tokens.md` and
`component-tokens.md` carry their own provenance note (m3.material.io + AOSP Compose tokens). The M3 site
is an Angular SPA — do not fetch guideline URLs directly; use the scripts. Flutter mappings
(`references/flutter/`) are handwritten and must be re-validated against current Flutter APIs
(`scripts/refresh-flutter.js`) when the SDK bumps.

### Refresh boundaries and follow-up

- `refresh-material-refs.js` now refuses to replace generated references unless every routed source
  page is present; `refresh-component-tokens.js` also refuses output when any token fetch fails.
  Review `git diff` after every successful refresh because these checks cannot judge the meaning of
  source changes.
- The Material route list and the Flutter validator are maintenance boundaries, not proof of full
  coverage: new M3 pages/components and Flutter API behavior, deprecations, or parameter changes
  still need a human review. Update the category list and handwritten Flutter mappings when that
  review identifies a relevant change.
