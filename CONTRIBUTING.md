# Contributing

## Getting Started

1. Install [FVM](https://fvm.app/documentation/getting-started/installation).
2. Clone this repository and open its root directory.
3. Run `./setup.sh` to install the pinned Flutter SDK, resolve Melos from the lockfile,
   dependencies, workspace links, and tracked Git hooks.

The root [`pubspec.yaml`](pubspec.yaml) is the command catalog. Run its Melos
scripts as `fvm dart run melos <script>`.

## Flutter SDK Setup

FVM manages the Flutter SDK for this repository. Refer to the [official FVM
installation guide](https://fvm.app/documentation/getting-started/installation) for
installation requirements and the [FVM workflow documentation](https://fvm.app/documentation/guides/workflows)
for general FVM usage.

The committed [`.fvmrc`](.fvmrc) pins this repository to the configured version. The
project version takes precedence over a global Flutter version. All commands below
must be run from the repository root.

### Set up the repository

After installing FVM, run:

```bash
./setup.sh
fvm flutter --version
fvm dart --version
```

`./setup.sh` reads `.fvmrc`, installs the pinned Flutter SDK, and creates the ignored
`.fvm/flutter_sdk` link to the cached project SDK. It also installs Melos, bootstraps the
workspace, fetches root dependencies, creates `.env.local` from `.env.local.example` when
needed, and configures the tracked Git hooks. The root `pubspec.yaml` points Melos to the same
SDK through `melos.sdkPath`; no manual `MELOS_SDK_PATH` export is required.

Use the project SDK for development commands:

```bash
fvm flutter test
fvm dart analyze
fvm dart run melos test
fvm dart run melos dev:app
fvm dart run melos local:designer_v2
```

### IDE configuration

Open the repository root, not an individual package. Configure the IDE to use the
project SDK link at `.fvm/flutter_sdk`.

For VS Code or VSCodium, set `dart.flutterSdkPath` to `.fvm/flutter_sdk`. Refer to
the [FVM VS Code documentation](https://fvm.app/documentation/guides/vscode) for
FVM-specific editor integration.

For Android Studio or IntelliJ:

1. Open **Settings/Preferences > Languages & Frameworks > Flutter**.
2. Set **Flutter SDK path** to `<repository-root>/.fvm/flutter_sdk`.
3. If required, set the Dart SDK path to
   `<repository-root>/.fvm/flutter_sdk/bin/cache/dart-sdk`.
4. Re-select the project SDK path after changing versions with `fvm use` if the IDE
   has resolved the previous symlink target.

For project-specific diagnostics, run `fvm doctor` from the repository root.

## Repository Overview

The StudyU platform is a Flutter/Dart monorepo with the following packages:

- [StudyU App](./app): Participate in N-of-1 trials.
- [StudyU Designer v2](./designer_v2): Design and conduct your own N-of-1 trial.

Dependency packages:

- [Core](./core): shared models and logic used by both frontends.
- [Flutter Common](./flutter_common): shared Flutter functionality, environment loading, and Supabase initialization.

Backend and tooling at the repo root (outside the Flutter workspace):

- [supabase/](./supabase): migrations, seeds, local CLI config, and database tests.
- [database/migration-legacy/](./database/migration-legacy): historical migrations; no longer the current migration path.

Run `fvm dart run melos <script>` from the repository root to operate on the
workspace. See `pubspec.yaml` for the full script catalog.

## Environments

Environment files live under `flutter_common/lib/envs/`:

- `.env` — Production database using main branch (default; do **not** use for routine development).
- `.env.dev` — Development database using dev branch.
- `.env.local` — Local Supabase CLI instance. `./setup.sh` creates this file from
  `.env.local.example` when it does not exist.

Use the `dev:*` Melos scripts for the development environment and `local:*`
for a local Supabase instance. Only `.env.dev` or `.env.local` should be used
for routine development.

### Override the environment at runtime

The loader reads `STUDYU_ENV` at runtime
(`flutter_common/lib/src/utils/env_loader.dart`) and picks the matching file
under `flutter_common/lib/envs/`. To override without renaming files, pass
`STUDYU_ENV` to a Flutter subcommand, or add
`--dart-define=STUDYU_ENV=.env.local` to the run configuration in Android
Studio or VS Code:

```bash
flutter [build, run, test] [android, ios, web] --dart-define=STUDYU_ENV=.env.local
```

### `.env` template

Each env file is a key=value list. Required keys
(see `flutter_common/lib/envs/.env` for the canonical version):

```shell
STUDYU_SUPABASE_URLS=https://db-redirect-prod.studyu.health,https://studyu-01.dhc-lab.hpi.de
STUDYU_SUPABASE_PUBLIC_ANON_KEY=your-public-anon-key
STUDYU_APP_URL=https://app.studyu.health
STUDYU_DESIGNER_URL=https://designer.studyu.health
```

Optional keys the loader recognizes (set when relevant):

```shell
STUDYU_PROJECT_GENERATOR_URL=
STUDYU_ANDROID_PACKAGE_ID=health.studyu.app
STUDYU_IOS_APP_STORE_ID=1571991198
STUDYU_DEVELOPER_EMAIL=
STUDYU_APP_DEEP_LINK_SCHEME=
```

See [`supabase/README.md`](supabase/README.md) for the `.env.local` workflow
and local backend setup.

## Codegen

The `core` and `designer_v2` packages use code generation. `core` produces
JSON IO for shared models via [build_runner](https://pub.dev/packages/build_runner)
and [json_serializable](https://pub.dev/packages/json_serializable). `designer_v2`
adds Riverpod, routing, and json_serializable output on top of that.

After changing annotated models, controllers, or routes, run:

```bash
fvm dart run melos generate
```

Contrary to most recommendations, the generated files (`*.g.dart`) are committed
to Git. This is required because `core` is imported as a dependency by both
frontends, and consumers need the generated output present at dependency
resolution.

## Code Style

The shared Dart and Flutter lint rules are defined in [`analysis_options.yaml`](analysis_options.yaml).
The tracked pre-commit hook runs [`scripts/pre-commit-check`](scripts/pre-commit-check), which
formats, generates affected output, and analyzes the workspace. The Git hooks are configured by
`./setup.sh`. If you develop manually without the automated pre-commit check running your
changes, run `fvm dart run melos qualitycheck` instead; it checks formatting and
analyzes the workspace without writing files. Run `fvm dart run melos generate` separately when
code generation is required. Use `fvm dart run melos qualitycheck` for a full CI-style workspace
check or when explicitly requested.

## Frontend

Both frontends follow the [Material Design 3 guidelines](https://m3.material.io/get-started).
Custom themes live in [`app/lib/theme.dart`](app/lib/theme.dart) (participant app) and
[`designer_v2/lib/theme.dart`](designer_v2/lib/theme.dart) (researcher designer).

## Commits

We use [Conventional Commits](https://www.conventionalcommits.org). The format is:

```
<type>[(<scope>)]: <description>
```

Common types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`,
`perf`, `ci`, `build`, `revert`. Use a `scope` that names the touched package
(`app`, `designer`, `core`, `flutter_common`, `db`).

Examples from this repo:

- `fix: remove redundant fitbit label`
- `feat(designer): move fitbit credentials to study-level`
- `chore: update deps + ios deps`

## Pull Requests

For any new feature or bug fix, create a branch and open a pull request. Follow the
pull request template and these conventions:

- Jira-backed branch: `<type>/studyu-<ticket-number>-<short-description>`
- Jira-backed PR title: `[STUDYU-<ticket-number>] <type>[(<scope>)]: <description>`
- Dependency-upgrade PRs created through `.agents/skills/dependency-upgrade`
  are maintenance and do not require Jira. Use a `chore/<short-description>`
  branch and a `chore(deps): <description>` PR title.
- A small maintenance PR can omit Jira only when all these conditions apply:
  - Its type is `chore`, `docs`, `ci`, `build`, or `test`.
  - It changes no user-facing behavior, database, deployment, or release.
  - It changes at most 500 non-generated lines.
  - The author explicitly confirms that no Jira ticket is needed.
- A ticketless maintenance branch uses `<type>/<short-description>`.
- A ticketless maintenance PR title uses `<type>[(<scope>)]: <description>`.
- PR description must include:
  - A direct Jira link, or `Not applicable — maintenance PR.` for an approved
    ticketless maintenance PR.
  - A **description** of the change and its motivation, with any related
    issues or context.
  - **Testing steps** that let a reviewer reproduce and verify the change
    locally.
- **Screenshot or video** of any visual change. Use a screen recording for
  interactive changes and a static screenshot for non-interactive ones.
  Non-visual PRs may drop the `## Visuals` section of the template.

## Writing Style

Write issues, PR titles and descriptions, review comments, and documentation in
[ASD-STE100](https://en.wikipedia.org/wiki/Simplified_Technical_English) Simplified
Technical English: short active-voice sentences, one action per sentence, plain words,
one term per concept. The `.agents/skills/asd-ste100` skill holds the full rules.

## Code Reviews — Conventional Comments

We use [Conventional Comments](https://conventionalcomments.org/) for all review
feedback. This standard makes the intent behind each comment clear and
actionable.

### Format

```
<label> [decorations]: <subject>

[discussion]
```

### Labels

| Label | Purpose |
| --- | --- |
| **praise:** | Highlight something sincerely positive when warranted. |
| **nitpick:** | Trivial preference-based request. Non-blocking by nature. |
| **suggestion:** | Propose an improvement. Be explicit about *what* and *why*. |
| **issue:** | Highlight a specific problem. Pair with a suggestion when possible. |
| **todo:** | Small, necessary change that must be done before merging. |
| **question:** | Ask for clarification when you're unsure if something is a problem. |
| **thought:** | Share an idea that came up during review. Non-blocking. |
| **chore:** | A process-related task needed before acceptance (e.g., run CI job). |
| **note:** | Non-blocking observation the reader should be aware of. |

### Decorations

Add decorations in parentheses for extra context:

- **(non-blocking)** — should not prevent merging
- **(blocking)** — must be resolved before merging
- **(if-minor)** — resolve only if the fix is trivial

### Examples

```
suggestion (non-blocking): Consider extracting this into a helper method.

It appears in three places and the logic is identical.
```

```
issue (blocking): This query fetches all rows without pagination.

On tables with 10k+ rows this will timeout. Can we add a LIMIT clause?
```

```
praise: Great use of the builder pattern here — very readable.
```

## Database and Backend

See [`supabase/README.md`](supabase/README.md) for local setup, migrations,
seeds, and database tests. `database/migration-legacy/` is historical only.
