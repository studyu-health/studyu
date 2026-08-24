# AI-Assisted Refactoring Guide — StudyU Material 3 Migration

> How to run the M3 migration with AI coding agents. Human-facing companion to the
> machine specs in `spec/m3/`. Read this before starting, resuming, or reviewing a
> loop iteration.

**Status:** living document. Update when decisions change; record spec-level changes in
`spec/m3/DECISIONS.md` and this file together.

---

## 1. Why AI-assisted, and why this shape

The migration touches ~230 raw-color sites, ~410 hardcoded spacings, and 27 form layouts
across two Flutter apps. It is mechanical-but-judgment-heavy work: most edits are small,
but each needs the same M3/StudyU rules applied consistently. That is exactly the work
AI agents are good at — **if** the rules are written down and each unit of work is small.

The failure mode of "just ask an agent to migrate to M3" is well-documented: context rot
makes long sessions drift, and vague specs compound small misreadings across sessions into
something unrecognizable. The fix used here is the **AI-assisted refactoring workflow**: a fresh agent context
per task, with the filesystem as memory.

Non-negotiable properties of this setup:

| Property | Mechanism |
|---|---|
| No drift between sessions | `spec/m3/DECISIONS.md` locks choices agents may not reopen |
| No lost state | `spec/m3/tasks/*.json` + `ACTIVITY.md` + git history are the only state |
| No vague tasks | every task spec names exact files, acceptance criteria, verification commands |
| No silent regressions | `scripts/pre-commit-check` + tests + visual evidence gate every task |
| No scope creep | one task per invocation; `do_not_touch` lists; commit and stop |

## 2. The moving parts

```
.agents/skills/studyu-material3/     ← design brain (SKILL.md + M3 refs + StudyU patterns/deviations)
spec/m3/
├── PRD.md                           ← why + goals + constraints
├── SUMMARY.md                       ← one-screen overview (agents read this first)
├── DECISIONS.md                     ← locked decisions (D1–D10); human-edited only
├── CATALOG.md                       ← measured drift inventory + screen groupings
├── ACTIVITY.md                      ← append-only loop log (the loop's memory)
├── prompts/ai_refactoring.prompt.md          ← the fixed prompt every iteration starts from
└── tasks/
    ├── tasks.json                   ← flat index: id, status, depends_on
    └── TASK-nnn.json                ← atomic spec per task (32 tasks, phases 0–5)
```

**Rule of thumb:** if it changes during the run, it's a task file, `ACTIVITY.md`, or git.
If it changes the *rules*, it's `DECISIONS.md` — and only a human edits that.

## 3. Task anatomy (what each TASK-nnn.json gives the agent)

| Field | Purpose |
|---|---|
| `files_to_touch` | hard edit boundary |
| `do_not_touch` | explicit anti-scope-creep list |
| `acceptance_criteria` | checkable statements; "done" means all true |
| `verification` | exact commands; `scripts/pre-commit-check` is always first |
| `evidence_required` | analyzer clean / tests pass / smoke note or screenshot |
| `skill_refs` | the *only* skill reference files the agent should read |
| `depends_on`, `priority` | ordering within the DAG |

Phases: **0** bootstrap & guardrails → **1** wording/links (zero risk) → **2** component
migrations with inherited effect → **3** theme/token cleanup → **4** screen-by-screen →
**5** structural (FormTableLayout removal, TextTheme term set).

## 4. Running the loop

### Prerequisites

- FVM + Melos set up (`fvm install`, `fvm exec melos bootstrap` if fresh clone).
- If `rtk` is installed, all commands get the `rtk ` prefix (project output filters).
- Work on a migration branch off `dev`. Never target `main`.

### One iteration

1. **Runner picks a task**: lowest-numbered `pending` task whose `depends_on` are `done`
   (or pass an explicit id).
2. **Start a fresh agent** (new session/subagent/CLI invocation — no chat history) with
   the contents of `spec/m3/prompts/ai_refactoring.prompt.md` plus the task id.
3. The agent executes: read specs → minimal change → verify → update task status +
   `ACTIVITY.md` → commit with trailer `[M3 TASK-nnn]` → stop.
4. **You review** the diff while the codebase is still warm (see §6).

Suggested cadence: run 3–6 tasks, then batch-review and open one PR per phase or per
cohesive group to `dev`.

### Manual equivalent

Each task spec is self-contained enough for a human or a one-off agent prompt:
"Do TASK-021 per spec/m3/tasks/TASK-021.json following spec/m3/prompts/ai_refactoring.prompt.md."

### Resuming after any interruption

Everything needed is on disk: `tasks.json` (what's left), `ACTIVITY.md` (what happened
+ blockers), git log (why). A new session needs zero verbal context. This is the point
of the design.

## 5. Guardrails the agent must enforce

These come from the skill's checklist and are restated in every task prompt:

- **Colors:** `Theme.of(context).colorScheme.*` — never `Colors.*`/`Color(0x…)`
  (sanctioned exception: brand `linkColor` for `Hyperlink` only).
- **Type:** `theme.textTheme.*` — never `TextStyle(fontSize: …)` at call sites.
- **Spacing/shape:** named constants / theme shape — never magic literals or inline
  `BorderRadius.circular(…)`.
- **A11y:** every interactive element ≥ 48×48dp with role + accessible label;
  `Tooltip.message` alone is not a label; unlabeled `InkWell`/`GestureDetector` = violation.
- **Buttons:** primary = `FilledButton` (StudyU: `PrimaryButton`); destructive ≠ primary.
- **Strings:** `tr.*`, en + de both — never hardcoded UI text.
- **Precedent:** only *intentional* deviations (listed in
  `references/studyu/deviations.md`) may be cited as patterns. Accidental drift is
  fixed, never extended.
- **App ≠ Designer:** `designer_v2` has the full `ThemeProvider` token system; `app/`
  has its own minimal seed-based theme (after TASK-032). Never import one app's tokens
  into the other.

## 6. Human review protocol — where humans stay in the loop

Automation gets the edits made; humans keep the taste. Review every task diff against:

1. **Scope:** only `files_to_touch` changed? Any drive-by?
2. **Checklist:** run the skill's M3 conformance sub-checklist (touch targets, semantics,
   textTheme, colorScheme, shape, spacing grid, input error/helper slots, button emphasis)
   over the *whole screen*, not just the diff.
3. **Decision hierarchy:** if the agent deviated from M3, did it cite a level
   (task > intentional pattern > M3 > Flutter convention > labelled new decision)?
   Undocumented deviations are rejections.
4. **Evidence:** `ACTIVITY.md` entry has verification results + smoke note/screenshot?

Phase gates (human sign-off before the next phase starts): after Phase 2 (broad inherited
changes), after Phase 3 (theme changes affect everything), and before Phase 5 (structural).
`TASK-050` and the `FormTableLayout` slices (060–062) always get a careful visual pass.

## 7. When the loop gets it wrong — fix the spec, not the code

If a task comes back wrong, resist hand-fixing. Instead:

1. Revert the commit.
2. Diagnose: was the task too big? criteria ambiguous? a decision missing?
3. Edit the spec: split the task, sharpen `acceptance_criteria`, add a `DECISIONS.md`
   entry, or add a line to the task's `notes`.
4. Set the task back to `pending` and rerun.

The spec is the asset; the code is regenerable. Two failures on the same task means the
spec is wrong — escalate to a human before a third attempt, and record the outcome in
`ACTIVITY.md`.

## 8. Common failure modes and mitigations

| Failure | Sign | Mitigation |
|---|---|---|
| Context rot | agent re-edits finished files, contradicts itself | one task per fresh session — never batch |
| Spec drift | each screen migrates slightly differently | `DECISIONS.md` + task-level `skill_refs` pinning |
| Theme-parity bug | designer tokens assumed in `app/` | explicit rule in prompt + Phase 3 ordering (app theme before app screens) |
| Analyzer-green visual regression | checks pass, UI looks wrong | `evidence_required` smoke notes/screenshots per task; human phase gates |
| Over-migration | intentional StudyU wrappers replaced | SKILL.md decision hierarchy; wrappers listed as patterns to preserve |
| Scope creep | diff touches files outside spec | `do_not_touch` + review step 1 — reject wholesale |
| Lint whack-a-mole | new drift reintroduced after migration | `studyu_lints` warnings (TASK-070), promote to errors per-pattern after each migration lands |

## 9. Rollout and PR strategy

- **Branching:** one migration branch per phase (or per cohesive task group) off `dev`;
  rebase frequently to limit merge pain on the theme files.
- **PR size:** small — component-level changes (e.g. TASK-020) are single-task PRs;
  screen groups are per-group PRs. TextTheme (TASK-063) and FormTableLayout (TASK-060–062)
  are deliberately separate PRs per `DECISIONS.md`.
- **PR body:** use `.github/pull_request_template.md`; check off format/analyze items only
  if actually run; attach screenshots for every UI-visible change (reminder: this is
  manual — agents can't do it for you).
- **Target:** `dev`. Always `dev`.
- **Keep local:** the `spec/m3/` scaffolding itself stays local (like `.agents/skills/`
  spec work) unless the team explicitly asks to commit it.

## 10. Quick reference

```bash
# baseline checks (TASK-001)
command -v rtk
fvm dart --version
fvm exec melos --version
scripts/pre-commit-check

# stock counts (refresh CATALOG.md when materially changed)
rg -c 'SizedBox\((width|height):' designer_v2/lib app/lib
rg -c 'Colors\.' designer_v2/lib app/lib
rg -l FormTableLayout designer_v2/lib app/lib

# package-scoped verification
fvm dart analyze designer_v2
cd designer_v2 && fvm flutter test
fvm dart analyze app
cd app && fvm flutter test

# pre-commit gate (always)
scripts/pre-commit-check
```

Commit format: `<type>(<scope>): <lowercase description>` + trailer `[M3 TASK-nnn]`.
Scopes: `app`, `designer`, `core`, `flutter_common`, `db`.
