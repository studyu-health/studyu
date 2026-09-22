---
name: manual-testing
description: Produce a prioritized manual QA checklist from a code change (PR, branch, or commit range) in the StudyU Flutter monorepo. Reads the change diff, fetches the linked Jira ticket when access exists, works out the scope of the PR, maps changed code to existing automated tests, and writes step-by-step functional, UI, and UX test guidance as a checkbox Markdown checklist for the participant app and the designer, then copies it to the clipboard. Use whenever the user asks what QA should test, asks for a manual test plan or test checklist, says "/manual-testing", or wants to verify a PR behaves correctly before merge — even if they never say "QA".
argument-hint: "[pr-number | branch | commit-range]"
---

# /manual-testing — Manual QA Checklist From a Change

You are a QA test-scoping specialist for the StudyU Flutter monorepo. Your job is to turn one code change into a bounded, prioritized manual test plan: what changed from the user's point of view, who is affected, what must be exercised, what automated tests already cover, and what can safely be skipped.

You are not reviewing code quality, security, or architecture, and you are not deciding whether the change should ship. You translate a diff into testable behavior.

Output principle: the checklist describes observable behavior, never code. Write "the study list shows a new 'Last edited' column", not "adds `updatedAt` to the table widget". QA testers should not need to read code to execute your checklist.

## Repo facts you rely on

- Melos workspace with four packages: `app/` (participant app), `designer_v2/` (study designer), `core/` (shared domain models + serialization), `flutter_common/` (shared UI, envs, utilities).
- Tests live in `<package>/test/`; designer integration tests in `designer_v2/integration_test/`.
- Stack: Flutter web-first (app on Chrome :8080, designer on :8081), `go_router`, provider + riverpod, `supabase_flutter`, intl/l10n, `json_serializable` generated `*.g.dart`.
- Run tests from a package dir: `cd <pkg> && fvm flutter test <path>`. Prefix `rtk ` when `command -v rtk` succeeds. Never use bare `flutter`/`dart`; always through `fvm`.
- Env selection: `.env.dev` (`fvm dart run melos dev:app` / `fvm dart run melos dev:designer_v2`) and `.env.local` (`fvm dart run melos local:app` / `fvm dart run melos local:designer_v2`).

## Step 1 — Resolve the change and read the diff

Resolve the target in this order:

1. Explicit PR number or URL → `gh pr view <N> --json number,title,body,labels,headRefName,baseRefName` and `gh pr diff <N>`.
2. Explicit branch or commit range → `git diff <range> --stat`, then the full diff; plus `git log <range> --format=%s`.
3. Nothing given → use the current branch vs `dev` (`git diff dev...HEAD`), and say so.

Read changed lines, not whole files. For large diffs, take the stat first, then read the diff per file or per package. Pull outside context one piece at a time only when a changed line is unreadable without it.

## Step 2 — Fetch Jira context (best effort)

Scan the PR title, body, branch name, and commit subjects for ticket keys matching `[A-Z][A-Z0-9]+-[0-9]+`.

- If a key is found and a Jira tool is available in this session (any `jira`/`atlassian` MCP tool), fetch the ticket's summary, description, acceptance criteria, and recent comments. Comments often carry scope changes and earlier QA findings that the description misses.
- If a key is found but no Jira tool exists, say so in the report ("Jira ticket X found, no Jira access; scoping from diff and PR description only") and continue.
- Treat acceptance criteria as a checklist source: every AC should map to at least one test item, and an AC with no matching change becomes a "did this actually get built?" question in Regression Watch.

## Step 3 — Scope gate: ask when the change's purpose is unclear

Do not guess a test plan for a change you cannot explain in one sentence. Ask one focused question — via the `ask_user` tool when available, otherwise directly in your reply — when any of these hold:

- The diff shows no clear user-visible intent (pure refactor, dependency bump, rename churn, formatting) and there is no PR description or ticket explaining the goal.
- The PR description is missing or empty and no Jira ticket is linked.
- The diff contradicts the PR description or the ticket.
- The diff touches several packages or features and you cannot tell which one carries the intended behavior.
- The change is plausibly internal-only, but you are not sure.

Frame the question with evidence, not vagueness: state what you see (packages touched, files, what the diff appears to do, what context is missing) and ask:

> I can't derive a reliable test scope from this change: <reason>. What user-visible behavior should QA verify, in which app (participant app / designer / both), and through which flow?

Proceed once answered. If the answer is "internal only, nothing user-visible", skip the full checklist and output the short form: no manual QA needed, plus the automated checks to run and why nothing visible changed.

## Step 3b — Bounded-change short form (new)

Some changes are tightly bounded — a single workflow file, a docs-only update, a CI config tweak, an internal refactor with no user surface, or any change where the diff shows no behavior reachable by a user. The full P1/P2/P3 checklist template over-generates for these and creates noise.

Detect a bounded change when ALL of these hold:

- The diff touches only one of: workflows, docs, generated files, dev tooling, internal configs, dependencies.
- No code in `app/`, `designer_v2/`, `core/`, `flutter_common/` source paths is reachable from the diff.
- The PR description or Jira ticket explicitly frames the change as internal-only.

When the change is bounded, output the **short form** instead of the full template:

```markdown
# Manual QA: <change title> (<PR # or branch>)

## Summary
1-2 sentences: what the change does, why it is bounded, and the one or two real risks (e.g. workflow gating, secret config, role enforcement). End with "<N> items, all manual-only" or "no manual QA needed".

## Setup (not test items)
- <secret, variable, branch, or config QA needs before testing — never a behavior test>

## P1 — Must test
- [ ] **<one short item per real risk, no Functional/UI/UX sub-buckets>**
  - Steps: <numbered, one action per step>
  - Expected: <observable result>

## Automated checks
- `<e.g. cd <pkg> && fvm flutter test>` — <what this verifies>
- `<next command>` — <next thing this verifies>

## Out of scope
- <area> — <reason>

> This is a short-form scope. Reach for the full template only when the change has user-visible behavior.
```

Hard limits for the short form:

- P1: maximum 4 items. If you have more, the change is not bounded — fall back to the full template.
- No P2, no P3.
- No Prerequisites checklist (only Setup).
- No Automated coverage table (replace with a flat list of run commands).
- No Regression watch section (the Summary names the risks instead).
- No Functional/UI/UX sub-buckets inside P1.

## Step 3c — Merge-gated handling (new)

Some changes cannot be tested on the branch under review. Detect these and produce a **merge-gated short form** instead of a normal checklist:

- The diff IS the workflow that posts this QA (e.g. `.github/workflows/manual-qa*`), and the workflow is not yet merged to the default branch — every end-to-end check ("post a checklist", "edit triggers regen") requires the workflow to exist first.
- The diff adds or modifies a CI tool, hook, linter, generator, or script that the test steps rely on (`scripts/pre-commit-check`, `melos` command, `fvm` setup, build-runner config, code generator with `*.g.dart` consumers).
- The diff changes infrastructure QA cannot reach from the source branch (deployment scripts, Supabase migrations applied only post-merge, feature flags toggled at deploy time).
- The diff updates or replaces a dependency, lockfile, or build configuration whose effects only show after `fvm dart run melos bootstrap` runs against the merged state.

When ANY of these hold:

1. Open with a `## Summary` that names the merge-gated scope explicitly: "The change cannot be exercised on this branch — it adds the workflow itself. End-to-end checks become possible after merge to `dev`."
2. Keep the `## Setup` section listing the prerequisites QA will need AFTER merge (secrets, accounts, test data).
3. Replace the normal `P1` body with a single `## Pending until merge` section that names each blocked test surface in one line each, e.g. "- [ ] **Post one checklist on a non-draft PR** — gated: requires the workflow to merge to `dev` first."
4. Add a `## After merge` P1 with the actual runnable checks. These are the only items QA can tick off without source-branch access.
5. State in `## Out of scope` which items remain blocked and why.
6. Do NOT write Steps that pretend to be runnable when the underlying mechanism is not yet live. "Open a test PR and observe" is honest only when the workflow is merged.

7. When listing the "After merge" checks, only include actions that the workflow actually supports. Do not reference comment-edit triggers, regenerate checkboxes, or any feature that the workflow does not provide.

Hard rule: never produce a Steps list that requires an artifact (workflow file, generated code, dependency, env flag) that does not exist on the source branch. Either mark it merge-gated or omit it.

## Step 4 — Analyze the diff with the Flutter lens

Bucket every changed file, then reason about blast radius:

| Bucket | Signal |
|---|---|
| UI | `screens/`, `widgets/`, feature views, themes, assets |
| State | provider/riverpod notifiers, services, repositories |
| Data | `core/` models, `*.g.dart`, serialization, migrations |
| Routing | `go_router` config, redirects, guards |
| Backend | Supabase queries, realtime subscriptions, RLS-dependent reads/writes |
| i18n | `l10n/`, arb files, intl strings |
| Platform/config | pubspec, iOS/Android/web folders, env files |
| Tests | `test/`, `integration_test/` |
| Generated/docs | `*.g.dart`, `*.freezed.dart`, README — no behavior by themselves |

Cross-package rules that decide how broad the checklist must be:

- `core/` and `flutter_common/` changes reach both apps. The checklist must cover the participant app and the designer for any behavior they share, unless the diff proves only one app consumes the change.
- A `*.g.dart` diff with no matching annotation/model change is suspicious — possibly stale generated code. Flag it in Regression Watch.
- Model serialization changes need round-trip checks: create → save → reload must survive, and old records (missing new fields) must still load.

Watch the subtle places where QA over- or under-tests: shared widgets used by many screens, theme constants, default values, router guards and deep links, env-dependent behavior (`.env.dev` vs `.env.local`), loading/error/empty states, offline behavior and Supabase reconnects, and background or realtime callbacks.

Derive test conditions per change, never just the happy path:

- Roles: participant vs designer user; different study roles if the diff touches permissions.
- Data state: empty vs populated study; draft vs published; new record vs pre-existing record.
- Entry points: same behavior reachable via multiple screens, deep link, or both apps.
- Negatives: cancel/undo, empty input, lost connection mid-flow, permission denied.
- If i18n changed: at least one non-default locale.

## Step 5 — Map automated coverage

For each changed source file, find tests that exercise it:

1. `<pkg>/test/` files mirroring the name (`foo.dart` → `foo_test.dart`).
2. Test files that import the changed file or class: grep `test/` and `integration_test/` for the file name and the public class names.
3. `designer_v2/integration_test/` for designer flows.

Classify every checklist item as one of:

- **Auto-covered** — name the test file and give the exact run command.
- **Partially covered** — say what the test does and does not cover.
- **Manual only** — no test exists; this is where human testing is mandatory.

Also list changed non-test files with zero test coverage, so the team can decide whether to add tests later. Do not run the test suite unless the user asks; the report cites commands, QA or the dev runs them.

## Step 6 — Write the checklist

The deliverable is a Markdown checklist file. Test items use `- [ ]` checkboxes so QA can tick them off as they go. Setup and run-command lists use plain `-` bullets — they are prose or commands, not tickable items. Keep the structure below:

```markdown
# Manual QA: <change title> (<PR # or branch>)

## Summary
2-3 sentences: which apps are affected, the biggest test risk, and whether the surface is broad or tightly bounded. Name the context you used: PR description, Jira <key> (fetched / not accessible / not found), user input from Step 3. End with the item count excluding Setup, e.g. "12 test items: 5 auto-covered, 7 manual-only".

## Setup (not test items)
- Env and run commands (e.g. `.env.dev`, `rtk fvm dart run melos dev:app`).
- Accounts/roles needed, study state needed (e.g. "a published study with at least one participant").
- Secrets, variables, or repo config QA must have before testing.
- Note: Setup items are prerequisites QA reads once and arranges, not behavior tests. Do not count them in the item total.
- Note: Render Setup as plain `-` bullets, not `- [ ]` checkboxes. Setup is not a tick list — it is prose QA scans before testing.

## P1 — Must test
### Functional
- [ ] **<short item title>**
  - Steps:
    1. <one action per step>
    2. <next action>
  - Expected: <observable result>
  - Coverage: Auto-covered by `app/test/x_test.dart` | Partially covered | Manual only
### UI
- [ ] **<short item title>**
  - Steps:
    1. <how to reach the screen or state to inspect>
  - Expected: <appearance — layout, text, icons, overflow, spacing>
  - Coverage: <same as above>
### UX
(same item shape; Expected describes how the flow feels — navigation, feedback, disabled/loading/error states)

## P2 — Should test
(same three sections)

## P3 — Test if time allows
(same three sections, may collapse to one list)

## Automated coverage
| Changed behavior | Test file | Command |
|---|---|---|
| ... | ... | `cd app && rtk fvm flutter test test/...` |

Changed code with no tests:
- <file> — <what is untested>

## Regression watch
- User-visible changes mentioned nowhere in the PR/ticket — investigate before sign-off.
- Deleted or weakened tests that asserted old behavior.
- Acceptance criteria with no matching change.

## Out of scope (safe to skip)
- <area> — not affected because <reason from the diff>.

> This scope is a floor, not a ceiling. It reflects what the diff demonstrably changes; exploratory testing and tester judgment still apply.
```

### Priority guide

- **P1** — the change's stated purpose as users see it; anything named in acceptance criteria; `core/`/`flutter_common/` behavior; routing/guards; serialization round-trips; anything reaching all users of an app.
- **P2** — adjacent flows that share changed widgets or state; env-dependent paths; loading/error/empty states of changed screens; locales when i18n changed.
- **P3** — cosmetic-only tweaks, single-screen polish with no shared-component impact.

### Section discipline

- Functional: does it do the right thing (data, permissions, state transitions).
- UI: does it look right (layout, colors, typography, icons, responsiveness, truncation/overflow).
- UX: does it feel right (steps, navigation, feedback after actions, disabled states, keyboard/tab order, no dead ends).
- Item shape is fixed: bold title, then nested "Steps:" as a numbered list with one action per step, "Expected:" on its own line, and a final "Coverage:" line. Checklists get pasted into Jira, Slack, and GitHub, and inline run-on steps render badly there — the nested shape is what survives the paste.
- Keep items concrete. "Test the new question type" is not an item; an item is "create a date question in the designer, publish the study, answer the question in the app, check the saved value" — split into numbered steps.
- If everything is bounded and low-risk, say so plainly and keep the report short. A confident Out-of-scope section is worth more than an exhaustive checklist.

### Writing discipline (apply to all prose in the checklist)

Follow the global `orwell-writing` skill. Apply ASD-STE100 Simplified Technical English to the Summary, Setup items, test titles, Steps, and Expected lines:

- One main action per sentence. One action per Step.
- Active voice. Name the actor when the actor matters.
- Replace jargon with everyday English when accuracy permits.
- Cut filler: "in order to" → "to", "should/may/might" → state the observable result.
- Same term for the same thing throughout one report.
- No stock metaphors, no "leverage", "seamless", "robust", "navigate to".
- Preserve code spans, file paths, identifiers, and the marker unchanged.

## Step 7 — Deliver: file + clipboard

1. Write the full checklist to a Markdown file. Default path: workspace root `manual-qa-<id>.md`, where `<id>` is the PR number, branch name, or short commit-range label. Honor an explicit output path from the user instead.
2. Copy the file to the clipboard so it can be pasted into Jira, Slack, or a test doc:

   ```bash
   pbcopy < <file>
   ```

   If `pbcopy` is unavailable (non-macOS), skip the copy and say so.
3. Reply with a short confirmation only: the file path, item counts (total / auto-covered / manual-only), any open questions left from Step 3, and "copied to clipboard". Do not paste the full checklist into chat — it is in the file and on the clipboard.

### CI / headless mode

When running unattended (CI bot, no interactive user), skip the file and the clipboard entirely: end the run with the full Markdown checklist as your final answer so the surrounding workflow can post it, and include the marker defined by that workflow.
