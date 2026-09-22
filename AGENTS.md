# StudyU Repository Instructions

This is a Flutter/Dart monorepo. All agent work starts and runs from the repository root.
Treat these instructions as a concise operating contract, not a replacement for the source
code, tests, or linked project documentation.

## Working Principles

- Inspect the relevant implementation, tests, callers, dependents, and documentation before
  changing behavior. Use structural/code-graph tools when available; otherwise locate code with
  filename and symbol search, then trace definitions and impact before editing.
- Check whether the requested approach is correct. Surface a material flaw or a simpler and
  safer alternative before implementing it.
- Resolve ordinary uncertainty from repository evidence. Ask before implementation only when
  unresolved ambiguity materially affects behavior, compatibility, data, security, or scope.
- Prefer the smallest implementation consistent with the request, existing architecture, and
  required failure handling. Do not add speculative features, configuration, or abstractions.
- Keep changes scoped to the requested outcome. Do not include opportunistic refactors,
  unrelated formatting, dependency upgrades, or cleanup.
- Preserve unrelated working-tree changes and comments. Remove only imports, variables, or
  other artifacts made unused by the current change.

## Writing Discipline

- Apply the `.agents/skills/asd-ste100` skill to all StudyU prose you write: issues, PR titles
  and descriptions, review comments, documentation, and generated reports such as manual QA
  checklists.
- Preserve code spans, file paths, identifiers, and markers exactly. Never rewrite them.

## Repository Map

- `core/` contains shared Dart models and logic used by both frontends.
- `flutter_common/` contains shared Flutter functionality, environment loading, and Supabase
  initialization.
- `app/` is the participant-facing Flutter application for Android, iOS, and web.
- `designer_v2/` is the researcher-facing Flutter web Designer.
- `supabase/` contains current migrations, seeds, local configuration, and database tests.
- `database/migration-legacy/` is historical and is not the current migration path.

## Sources Of Truth

- The root `pubspec.yaml` `melos.scripts` section is authoritative for commands, package
  filters, ports, and environment defines. Do not copy its script bodies into this file.
- `CONTRIBUTING.md` is authoritative for setup, coding conventions, commits, reviews, and PRs.
- `.github/pull_request_template.md` is authoritative for PR body structure and checklists.
- Hook, CI, and package configuration files are authoritative for what tools actually enforce.
- `supabase/README.md` is authoritative for local backend setup, migrations, seeds, and database
  tests.
- When prose conflicts with executable configuration, inspect and reconcile the conflict rather
  than guessing.

## Root-Only Workflow

- Run all commands from the repository root. Do not change into a package directory for routine
  work.
- After creating a linked worktree, run `./setup.sh` once from its repository root before any
  other project command.
- Use `fvm dart run melos <script>` for root Melos scripts.
- Use `fvm dart` or `fvm flutter` for direct SDK commands. Run `./setup.sh` if the configured
  SDK is unavailable.
- Prefer the existing root script catalog. For a targeted package check with no catalog entry,
  use a root-level `fvm dart run melos exec` command with the appropriate package filter.
- Use `fvm dart pub get` to install dependencies and `fvm dart run melos bootstrap` to link
  workspace packages. Use the catalog's `app`, `designer_v2`, `dev:*`, `local:*`, `test`,
  `generate`, and `build:web` scripts rather than duplicating their command bodies here.
- Before running any melos, Flutter, Dart, or FVM command, check whether `rtk` is installed
  (`command -v rtk`) and prefix the command with `rtk` when available. This applies the
  project's RTK output filters.
- If `scripts/pre-commit-check` or a qualitycheck command prints
  `[rtk] WARNING: untrusted project filters (.rtk/filters.toml)`, review `.rtk/filters.toml`.
  If it only contains repository-owned output filters, run `rtk trust`, then rerun the same
  command.
- Before staging changes, committing, or opening a pull request, run
  `scripts/pre-commit-check`. The tracked `.githooks/pre-commit` hook runs the same check
  automatically; it formats and analyzes, and only generates files when staged files can affect
  generated output.
- Do not use the root qualitycheck script as the default pre-commit or pre-PR check. Use it for a
  full CI-style workspace check or when explicitly requested.

## Environments

- The default `.env` targets production. Unqualified `app`, `designer_v2`, and default build
  scripts can therefore use production configuration.
- Use `dev:*` scripts for the development environment and `local:*` scripts for local Supabase.
- Do not run an unqualified application or build command for routine development.
- Treat environment, storage, authentication, and Supabase initialization changes as affecting
  both frontends when they touch `flutter_common/`.
- Never add service-role keys, signing keys, OAuth secrets, store credentials, private keys, or
  other privileged credentials to tracked client environment files. Do not commit secrets.
- Environment templates live in `flutter_common/lib/envs/`; select them with
  `--dart-define=STUDYU_ENV=.env.dev` or `.env.local` when the selected root script does not
  already choose the environment.

## Coding Style

- Follow Effective Dart and the shared `analysis_options.yaml`, which includes
  `package:lint/strict.yaml`.
- Use the configured formatter before committing. Keep Dart files `snake_case.dart`, classes and
  widgets `UpperCamelCase`, and members `lowerCamelCase`.

## Generated Files And Dependencies

- Do not hand-edit generated Dart or localization output. Change models, annotations, ARB files,
  or other generator inputs, then run the configured root generation script.
- Generated `*.g.dart` files are tracked and must be included when regeneration changes them.
- Inspect generated diffs for unexpected API, schema, or serialization changes.
- Do not hand-edit lockfiles. For dependency work, change the manifest and use the configured
  package workflow, then review all resulting lockfile changes.
- Changes to `core/` models can affect both frontends and persisted study data. Inspect consumers
  before changing public model or serialization contracts.

## Verification

- Determine which packages and boundaries are affected, then run the narrowest relevant checks.
- Use `fvm dart run melos test` for workspace Flutter unit and widget tests. This does not cover
  Designer browser E2E tests or Supabase/pgTAP tests.
- Place unit and widget tests under each package's `test/` directory and Designer integration
  tests under `designer_v2/integration_test/`. Prefer names ending in `_test.dart`, matching the
  feature or model.
- Prefer tests for logic, behavior, state, navigation, and accessibility contracts. Do not add
  or update widget assertions that merely mirror presentation details such as exact icons, colors,
  typography, spacing, widget classes, or incidental copy. Do not add visual/golden coverage for
  a purely visual change unless explicitly requested; only update existing goldens when their
  established coverage requires it.
- Run generation after model or annotation changes, and analyze/test affected packages after
  generated output is updated.
- Changes under `supabase/` require the database test workflow described in `supabase/README.md`
  when the relevant local dependencies are available.
- Changes to full Designer browser flows require the dedicated E2E setup and checks.
- Changes to Android, iOS, permissions, notifications, camera/audio, Fitbit, or deep links
  require the relevant platform validation when available.
- For bugs, add or identify a regression test when practical. Do not weaken tests or expected
  behavior merely to obtain a passing result.
- Before reporting completion, inspect the final diff and state exactly which checks ran, which
  passed, and what could not be verified.

## Code Reviews

- Review the complete diff in repository context. Trace changed behavior through callers,
  dependents, persistence boundaries, generated sources, tests, and relevant integrations.
- Verify each finding against the implementation before reporting it. Include the exact file and
  line. Use a question when a concern depends on missing context.
- Prioritize security, privacy, data integrity, compatibility, user-facing regressions, edge
  cases, missing tests, and concrete over-engineering risks. Do not report style preferences,
  restated diffs, or speculative improvements.
- Format every finding according to [Conventional Comments](https://conventionalcomments.org/):
  `<label> [decorations]: <subject>` followed by the discussion.
- Use `issue` for a verified problem, `suggestion` for an improvement, and `question` when the
  concern depends on missing context. Use `todo` or `chore` for small required work, and use
  `nitpick` only for trivial preferences.
- Use `praise`, `thought`, or `note` only when warranted. Do not manufacture praise.
- Use only `(blocking)`, `(non-blocking)`, or `(if-minor)` decorations. A blocking finding must
  identify a correctness, security, data-loss, compatibility, or required-process failure.
- Write findings in concise, plain, active English. Preserve uncertainty and scope qualifiers.
  Keep one issue per comment. Put evidence, impact, and the proposed next step in the discussion.

## Safety Boundaries

Do not run any of the following without explicit user authorization and immediate verification
of the target, environment, and data-loss impact:

- `fvm dart run melos reset`, `git clean`, or other commands that discard local changes or files.
- Supabase reset commands or `scripts/reset-test-db.sh` with an unverified or non-local
  `SUPABASE_DB_URL`.
- `supabase link`, remote `db push`, remote migration commands, or any command against a remote
  database or project.
- Production seed operations. Production receives migrations only, never seeds.
- Deployments, release tags, mobile store uploads, Firebase deployments, or Pub.dev publication.
- Commands that push directly to `main` or `dev`.

Markdown instructions are not a security boundary. Keep production credentials unavailable to
routine agent sessions and use hooks, CI, and package permissions for hard enforcement.

## Area-Specific Rules

### When changing `core/`

- Keep shared model and serialization contracts compatible with both frontends and active study
  data unless a breaking change is explicitly intended.
- Run `fvm dart run melos generate` after model or annotation changes and commit tracked output.
- Prefer package-level tests for serialization and public model behavior.

### When changing `flutter_common/`

- Assume the change affects both `app/` and `designer_v2/`.
- Keep application-specific navigation and behavior out of shared code unless both consumers need
  it.
- Review environment and secure-storage changes for production exposure and data persistence.

### When changing `app/`

- Treat participant data, reminders, permissions, collection flows, and persistence as sensitive.
- Preserve established Provider, GoRouter, Material theme, responsive layout, and localization
  patterns. Prefer theme values over hardcoded colors.
- Validate relevant native platforms when changing Android or iOS configuration or integrations.

### When changing `designer_v2/`

- Preserve established Riverpod, reactive-form, routing, repository, and localization patterns.
- Run generation after Riverpod or other annotation changes.
- Use the dedicated browser E2E checks for full Designer flows when applicable.
- Treat study deletion, publishing, exports, and participant-data operations as data-integrity
  sensitive.

### When changing `supabase/`

- Add current migrations only under `supabase/migrations/`.
- Review RLS, grants, authentication, cascades, and participant-data changes for security and
  data loss, and add or update pgTAP coverage for relevant invariants.
- Verify database targets are local before reset or seed operations.
- Read `supabase/README.md` before changing migration, seed, or test workflows.

### When changing `database/`

- Treat `database/migration-legacy/` as historical reference only.
- Put new database changes under `supabase/migrations/`.

### When changing `.github/`

- Treat workflow changes as production-impacting because workflows can deploy, release,
  publish, auto-commit, or access privileged secrets.
- Preserve least-privilege permissions, secret references, triggers, and environment boundaries.
- Validate workflow syntax and behavior without triggering a deployment or release.

## Git And Pull Requests

- Follow `CONTRIBUTING.md`; do not invent generic commit messages or duplicate its conventions.
- Use Conventional Commits for all commits: `<type>(<scope>): <description>`. Allowed types are
  `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, and `style`; allowed scopes are `app`,
  `designer`, `core`, `flutter_common`, and `db`. Keep descriptions lowercase and do not end
  them with a period.
- When creating a pull request, use `.agents/skills/pull-request/SKILL.md` for the procedural
  workflow. It covers branch and commit validation, diff auditing, testing, and PR creation.
- The pull-request skill must use `.github/pull_request_template.md` as the live PR body schema,
  complete it from the actual diff and verification, and remind the user about required UI
  screenshots or video.
- When using the GitHub CLI (`gh`) to open a pull request, complete the `Description` and
  `Testing Steps` sections from the actual diff, keep the checklist interactive, and check off
  formatting and analyzer items only when those checks passed.
- Do not revert unrelated changes. All worktrees must be created under `.worktrees/` relative to
  the repository root, for example `git worktree add .worktrees/<branch-name> <branch>`.
