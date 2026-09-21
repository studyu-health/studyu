---
name: pull-request
description: Standardize pull request creation. Validates branch name and commits against Conventional Commits spec, audits diff size (flag if >500 lines excluding generated files), proposes split if too large, then creates a PR with structured description (problem, changes, testing checklist). Triggers when user says "create PR", "open a pull request", "make a PR", "/pull-request", or asks to submit work for review.
argument-hint: "[target-branch]"
---

# /pull-request - Standardized PR Creation

## Defaults

- Default target branch: `dev`, unless the user specifies a target branch or repository context clearly indicates a different default.
- Jira is required unless the change is a dependency upgrade or meets the ticketless maintenance exception in `CONTRIBUTING.md`.
- Do not force-push, rebase, amend, or rename branches unless the user explicitly asks.
- Never create a PR until branch name, commit compliance, and diff size audit have been presented and the user confirms continuing.

## Step 1: Validate Branch Name

Run:

```bash
git rev-parse --abbrev-ref HEAD
```

A Jira-backed branch must match:

```text
<type>/studyu-<ticket-number>-<short-description>
```

A ticketless maintenance branch must match:

```text
<type>/<short-description>
```

Ticketless branches allow only `chore`, `docs`, `ci`, `build`, or `test`.
They remain provisional until the maintenance scope gate in Step 3 passes.

Examples: `fix/studyu-42-designer-picker`, `feat/studyu-128-date-question`,
`chore/update-agent-skill`.

If neither format matches, stop and propose the applicable valid format. Wait
for the user to rename the branch or explicitly confirm continuing.

## Step 2: Audit Commits

Run:

```bash
git log <target-branch>..HEAD --oneline
```

Each commit subject must match:

```text
<type>[optional scope]: <description>
```

Allowed types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `ci`, `build`, `revert`.

Rules:

- Subject line is 72 characters or fewer.
- Description uses imperative mood, for example `add`, not `added`.
- No trailing period.
- Breaking change uses `!` after type/scope or a `BREAKING CHANGE:` footer.

For every non-compliant commit, present all proposed rewrites at once:

```text
Commit: "some bad message"
Proposed: "fix(auth): handle expired token on login"
Reword with: git rebase -i <target-branch>
```

Wait for the user to fix or explicitly confirm continuing.

## Step 3: Audit Diff Size

Run:

```bash
git diff <target-branch>...HEAD --stat
```

Count changed lines excluding generated and translation files:

- `*.g.dart`
- `*.freezed.dart`
- `*/l10n/*.dart`
- `*/generated/*`
- `*.g.ts`
- `*.lock`
- `pubspec.lock`

A dependency upgrade performed through `.agents/skills/dependency-upgrade` is
ticketless maintenance. Do not require Jira or apply the small-maintenance
scope limits to it.

For any other ticketless branch, confirm all maintenance exception conditions
from `CONTRIBUTING.md`. Stop if the diff exceeds 500 non-generated lines or
changes user-facing behavior, a database, a deployment, or a release. Record
the user's explicit confirmation that no Jira ticket is needed.

If total non-excluded changed lines exceed 500, analyze the diff and propose an independently mergeable split by feature area, layer, or dependency order:

```text
PR is too large: ~<N> lines (excluding generated files).

Proposed split:
  PR 1 - <type>/<scope-1>: <what it does> (~<N> lines)
    Files: <list key files>
  PR 2 - <type>/<scope-2>: <what it does> (~<N> lines)
    Files: <list key files>

Proceed with single PR anyway? Or split?
```

Wait for the user decision.

## Step 4: Collect PR Info

Run in parallel when possible:

```bash
git diff <target-branch>...HEAD --stat
git log <target-branch>..HEAD --format="%s%n%b"
```

Derive:

- Jira ticket: key from the branch and its direct URL. Ask the author for the URL if needed. For an approved ticketless maintenance PR, use `Not applicable — maintenance PR.`
- Problem: what was broken or missing, using commits and diff context.
- Changes: grouped bullet list by area.
- Testing: checklist of verification steps, including commands already run.

## Step 5: Create the PR

When composing the body, use an available PR template and follow its removal
instructions. Include the direct Jira link for Jira-backed work. Use
`Not applicable — maintenance PR.` for an approved ticketless maintenance PR.

If no template exists, write a concise body covering the ticket or maintenance
exception, problem, changes, and verification.

```bash
git push -u origin HEAD
gh pr create \
  --title "<validated-title>" \
  --base <target-branch> \
  --body "<completed-body>"
```

PR title rules:

- Jira-backed format: `[STUDYU-<ticket-number>] <type>[(<scope>)]: <description>`.
- Ticketless maintenance format: `<type>[(<scope>)]: <description>`.
- For Jira-backed work, the ticket must match the branch and Jira link.
- Maximum 72 characters.
- Imperative mood.
- No trailing period.

If `gh` is not authenticated, stop and ask the user to run `gh auth login`.

After creating the PR, remind the author to complete any author-attestation checkboxes before requesting review. Leave them unchecked unless the author confirms completion.
