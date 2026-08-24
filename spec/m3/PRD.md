# PRD — StudyU Material 3 Migration (AI-Assisted Refactoring Workflow)

## Why

StudyU ships two Flutter apps on one Melos workspace: the participant `app/` and the
Study Designer `designer_v2/`. `designer_v2` has a real M3 theme (`ColorScheme.fromSeed`,
dynamic color, per-component themes); `app/` has a minimal raw-color theme. Across both
apps there is catalogued drift from Material 3: raw colors, inline `TextStyle`, hardcoded
spacing/radii, unlabeled tappables, legacy navigation theming, table-based forms, and
inconsistent wording.

The `studyu-material3` skill (`.agents/skills/studyu-material3/`) is the design source of
truth. This migration executes the backlog in
`references/studyu/deviations.md` against the real code, in small verified steps.

## Goals

- Both apps read color, type, shape, and spacing from theme tokens — not call-site literals.
- Primary actions use `FilledButton` (via the `PrimaryButton` wrapper); destructive actions
  are never primary.
- Every interactive element has >= 48x48dp touch targets and an accessible label.
- Forms are labeled columns, not `Table` layouts.
- Wording is consistent across equivalent flows (en + de via `tr.*`).
- Drift stays fixed: warning-level lints guard the migrated patterns.

## Non-goals

- Redesigning screens or changing product behavior.
- Replacing intentional StudyU patterns (`PrimaryButton`/`SecondaryButton` API,
  `TwoColumnLayout` 1000px shell, `ThemeConfig` muted roles, brand `linkColor`).
- Migrating `core/`, `flutter_common/`, supabase backend, or any non-UI logic.
- Golden-test infrastructure (manual screenshot evidence is the gate for this migration).

## Constraints

- Flutter/Dart via FVM + Melos. Prefix `dart`/`flutter` with `fvm`, `melos` with
  `fvm exec`; prefix with `rtk ` when `command -v rtk` succeeds.
- Conventional Commits: `feat|fix|chore|docs|refactor|test|style(<scope>):` with scopes
  `app|designer|core|flutter_common|db`; lowercase description, no trailing period.
- Append ` [M3 TASK-nnn]` trailer to each loop commit.
- PRs target `dev`, never `main`.
- Never hardcode UI text; strings go through l10n (`tr.*`, en + de both).
- Decision hierarchy (from the skill): task requirement > intentional StudyU pattern
  (deviations.md "Intentional deviations") > M3 guidance > Flutter conventions > new
  labelled design decision.
- "Accidental drift" in deviations.md is never a precedent — do not extend it.

## Verification stack

Every task runs `scripts/pre-commit-check` and the task's own verification commands.
A UI task is not done without visual evidence (screenshot or smoke note in ACTIVITY.md).

## Spec artifacts

- `spec/m3/PRD.md` — this file
- `spec/m3/SUMMARY.md` — one-screen overview
- `spec/m3/DECISIONS.md` — locked decisions
- `spec/m3/CATALOG.md` — measured drift inventory
- `spec/m3/ACTIVITY.md` — append-only loop log
- `spec/m3/prompts/ai_refactoring.prompt.md` — fixed per-iteration prompt
- `spec/m3/tasks/tasks.json` — task index with status
- `spec/m3/tasks/TASK-nnn.json` — atomic task specs
