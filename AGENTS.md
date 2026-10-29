# StudyU Repository Instructions

This is a Flutter/Dart monorepo. Work from the repository root, not a package directory.
These rules are a contract, not a replacement for source code, tests, or linked docs.

## Working Principles

- Ask only when ambiguity affects behavior, compatibility, data, security, or scope. Otherwise
  resolve it from the repo.
- Build the smallest change that fits the request and the existing architecture. No speculative
  features or config.
- Stay in scope. No opportunistic refactors, unrelated formatting, or dependency bumps.
- Keep unrelated working-tree changes and comments. Remove only what your change makes unused.

## Writing Discipline

- Apply `.agents/skills/asd-ste100` to all StudyU prose: issues, PR text, review comments, docs,
  QA checklists.
- Never rewrite code spans, file paths, identifiers, or markers.

## Repository Map

- `core/` — shared Dart models and logic for both frontends.
- `flutter_common/` — shared Flutter code, env loading, Supabase init.
- `app/` — participant-facing app (Android, iOS, web).
- `designer_v2/` — researcher-facing web Designer.
- `supabase/` — current migrations, seeds, local config, database tests.
- `database/migration-legacy/` — historical only, not the current migration path.

## Sources Of Truth

- `pubspec.yaml` `melos.scripts` — commands, package filters, ports, env defines. Don't copy
  script bodies here.
- `CONTRIBUTING.md` — setup, conventions, commits, reviews, PRs.
- `.github/pull_request_template.md` — PR body structure and checklists.
- Hook, CI, and package config files — what's actually enforced.
- `supabase/README.md` — local backend setup, migrations, seeds, database tests.
- `docs/sonarqube.md` — SonarQube gate rules and how to reproduce coverage locally.
- Prose vs. config conflict → trust the config, then fix the prose.

## Root-Only Workflow

- Run every command from the repository root.
- New linked worktree → run `./setup.sh` once before anything else.
- Root Melos scripts: `fvm dart run melos <script>`.
- Direct SDK commands: `fvm dart` / `fvm flutter`. SDK missing → run `./setup.sh`.
- No script for a targeted package check → `fvm dart run melos exec` with a package filter.
  `--scope` takes the package name (`studyu_app`), not the directory (`app`) — a wrong name
  silently runs 0 packages and reports success.
- `fvm dart run melos qualitycheck` is for a full CI-style check or when asked.
- After finishing changes, before commit: run `fvm dart run melos fix` to apply auto-fixable
  lint fixes.

## Verification

- Figure out which packages and boundaries a change touches, then run the narrowest checks that
  cover it.
- Touch a function → add or update a test that covers it.
- `fvm dart run melos test` runs workspace unit and widget tests only — not Designer browser E2E
  or Supabase/pgTAP tests.
- Model or annotation change → run generation, then analyze and test the affected packages.
- `supabase/` change → run the database test workflow in `supabase/README.md` when local
  dependencies are available.
- Full Designer browser flow change → run the dedicated E2E setup and checks.
- Android/iOS/permissions/notifications/camera/audio/Fitbit/deep-link change → validate on the
  relevant platform when available.
- Bug fix → add a regression test when practical. Never weaken a test just to make it pass.
- Before pushing → run `sonar analyze --staged` (or `--base dev`) to catch new SonarQube issues
  locally. It does not compute coverage.
- Before pushing → run `fvm dart run melos test:coverage`, then
  `fvm dart scripts/normalize_lcov.dart coverage/sonar/lcov.info` to reproduce coverage locally.
  The 80%-on-new-code gate itself only evaluates in CI; see `docs/sonarqube.md`.
- Before reporting done: state exactly which checks ran, which passed, and what you couldn't
  verify.

## Environments

- Default `.env` targets production. Unqualified `app`, `designer_v2`, and default build
  scripts use it.
- Use `dev:*` scripts for development, `local:*` scripts for local Supabase.
- Never run an unqualified app or build command for routine development.
- Never commit service-role keys, signing keys, OAuth secrets, store credentials, or other
  privileged credentials to tracked client env files.

## Generated Files And Dependencies

- Never hand-edit generated Dart or localization output. Change the generator input (models,
  annotations, ARB files), then run the root generation script.
- Generated `*.g.dart` files are tracked. Commit them when regeneration changes them.
- Inspect generated diffs for unexpected API, schema, or serialization changes.
- Never hand-edit lockfiles. Change the manifest, run the package workflow, then review the
  resulting lockfile diff.

## Code Reviews

- Trace changed behavior through callers, dependents, persistence, generated sources, tests, and
  integrations.
- Verify each finding against the code before reporting it. Cite the exact file and line.
- Prioritize security, privacy, data integrity, compatibility, user-facing regressions, edge
  cases, missing tests, and real over-engineering. Skip style preferences and restated diffs.
- Format every finding as a [Conventional Comment](https://conventionalcomments.org/):
  `<label> [decorations]: <subject>`, then the discussion.
- Labels: `issue` for a verified problem, `suggestion` for an improvement, `question` when
  context is missing, `todo`/`chore` for small required work, `nitpick` only for trivial
  preference.
- `praise`/`thought`/`note` only when earned. Never manufacture praise.
- Decorations: `(blocking)`, `(non-blocking)`, `(if-minor)` only. `(blocking)` requires a
  correctness, security, data-loss, compatibility, or required-process failure.
- Write plain, active English. One issue per comment. Put evidence, impact, and next step in the
  discussion.

## Safety Boundaries

Never run these without explicit user authorization and immediate verification of target,
environment, and data-loss impact:

- `fvm dart run melos reset`, `git clean`, or anything that discards local changes or files.
- Supabase reset commands or `scripts/reset-test-db.sh` with an unverified or non-local
  `SUPABASE_DB_URL`.
- `supabase link`, remote `db push`, remote migration commands, or anything against a remote
  database or project.
- Production seed operations. Production gets migrations only, never seeds.
- Deployments, release tags, mobile store uploads, Firebase deployments, Pub.dev publication.
- A direct push to `main` or `dev`.

Markdown instructions are not a security boundary. Keep production credentials out of routine
agent sessions; enforce with hooks, permissions, CI, and review gates.

## Area-Specific Rules

### `core/`

- Keep model and serialization contracts compatible with both frontends and active study data,
  unless a breaking change is intended.
- Run `fvm dart run melos generate` after model or annotation changes. Commit the tracked
  output.
- Prefer package-level tests for serialization and public model behavior.

### `flutter_common/`

- Assume the change affects both `app/` and `designer_v2/`.
- Keep app-specific navigation and behavior out of shared code unless both consumers need it.
- Review environment and secure-storage changes for production exposure and data persistence.

### `app/`

- Treat participant data, reminders, permissions, collection flows, and persistence as
  sensitive.
- Preserve the existing Provider, GoRouter, Material theme, responsive layout, and localization
  patterns. Prefer theme values over hardcoded colors.
- Validate the relevant native platform when you touch Android or iOS config or integrations.

### `designer_v2/`

- Preserve the existing Riverpod, reactive-form, routing, repository, and localization patterns.
- Run generation after a Riverpod or other annotation change.
- Use the dedicated browser E2E checks for a full Designer flow.
- Treat study deletion, publishing, exports, and participant-data operations as data-integrity
  sensitive.

### `supabase/`

- New migrations go under `supabase/migrations/` only.
- Review RLS, grants, auth, cascades, and participant-data changes for security and data loss.
  Add or update pgTAP coverage for the invariants they touch.
- Verify the database target is local before a reset or seed operation.
- Read `supabase/README.md` before changing migration, seed, or test workflows.

### `database/`

- `database/migration-legacy/` is historical reference only.
- New database changes go under `supabase/migrations/`.

### `.github/`

- Workflow changes are production-impacting: they can deploy, release, publish, auto-commit, or
  touch privileged secrets.
- Preserve least-privilege permissions, secret references, triggers, and environment boundaries.
- Validate workflow syntax and behavior without triggering a real deployment or release.

## Git And Pull Requests

- Follow `CONTRIBUTING.md`. Never invent a generic commit message or duplicate its conventions.
- Creating a PR → follow `.agents/skills/pull-request/SKILL.md` for branch/commit validation,
  diff audit, testing, and PR creation.
- Build the PR body from `.github/pull_request_template.md`, filled from the actual diff and
  verification. Remind the user about required UI screenshots or video.
- Never revert unrelated changes.
- Worktrees go under `.worktrees/` from the repo root, e.g.
  `git worktree add .worktrees/<branch-name> <branch>`.
