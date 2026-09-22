---
name: dependency-upgrade
description: Upgrade Flutter, Dart, or package dependencies in the StudyU monorepo with stable-SDK selection, migration review, validation, release, and pull-request gates.
argument-hint: "[target-branch]"
---

# /dependency-upgrade - StudyU dependency upgrades

Use this skill for Flutter SDK, Dart SDK, or Dart and Flutter package upgrades.
Run every command from the repository root.

## 1. Preflight

Do not mutate the repository until every preflight check passes.

1. Require the repository root. Verify it with `git rev-parse --show-toplevel`.
2. Require a dedicated, clean task worktree. Run:

   ```bash
   git status --short --untracked-files=all
   git branch --show-current
   git rev-parse HEAD
   ```

   If the worktree is not clean, create a fresh worktree without changing the
   existing one. Never stash, reset, or remove unrelated work.
3. Treat dependency upgrades as ticketless maintenance. Do not require a Jira
   ticket.
4. Require a branch that matches `^chore/[a-z0-9][a-z0-9-]*$`. Do not rename a
   branch automatically. Stop and request an approved branch if the name does
   not match.
5. Print the target branch and the current commit. Confirm that the target is
   not the task branch.
6. Confirm the intended scope. Allowed changes are `.fvmrc`, dependency
   manifests, lockfiles, generated output, and compatibility fixes caused by
   the update. Do not edit `.github/workflows/*`. Do not add helper scripts or
   unrelated cleanup.

Never run `git clean`, `melos reset`, `supabase link`, `supabase db push`, or a
Supabase reset against a non-local target. Never deploy or publish during this
workflow. Before the pull request merges, never create or push a tag. After the
merge, tag creation and tag pushes are allowed only through the production
handoff in section 10. They require explicit production release authorization.
Local Melos versioning is allowed only in section 9, after all checks pass.

## 2. Prepare the worktree

Use a fresh worktree based on the selected target branch. Preserve the source
worktree and all unrelated changes. In the fresh worktree, run:

```bash
fvm install
./setup.sh
fvm dart run melos setup
```

`./setup.sh` bootstraps the workspace. If the repository setup script no longer
bootstraps the workspace, run `fvm dart run melos bootstrap` after inspecting
its current definition.

Create the local environment file only when it does not exist:

```bash
if [ ! -e flutter_common/lib/envs/.env.local ] && \
   [ ! -L flutter_common/lib/envs/.env.local ]; then
  cp flutter_common/lib/envs/.env.local.example \
    flutter_common/lib/envs/.env.local
fi
git check-ignore -q flutter_common/lib/envs/.env.local
```

Never overwrite `.env.local`. Never add it to Git. Do not use production
`.env` for routine validation.

## 3. Inventory the workspace

Read the current command catalog and configuration before choosing commands.
The root `pubspec.yaml` is the source of truth for Melos scripts. The current
workflow files are the source of truth for CI and E2E steps. Do not copy script
bodies into this skill or replace them with guessed commands.

Inspect:

- `.fvmrc` and the Flutter and Dart constraints.
- `pubspec.yaml`.
- `core/pubspec.yaml`.
- `flutter_common/pubspec.yaml`.
- `app/pubspec.yaml`.
- `designer_v2/pubspec.yaml`.
- Every workspace `pubspec.lock`.
- Platform lockfiles such as `app/ios/Podfile.lock` and
  `app/android/Gemfile.lock`, when present.

When `app` is in scope, inspect these native inputs:

- Android: `app/android/settings.gradle.kts`, `app/android/app/build.gradle.kts`,
  `app/android/gradle/wrapper/gradle-wrapper.properties`, `app/android/gradle.properties`,
  and the Android Gemfile and lockfile when present.
- iOS: `app/ios/Podfile`, `app/ios/Podfile.lock`,
  `app/ios/Runner.xcworkspace/contents.xcworkspacedata`, relevant Runner project settings,
  and the iOS Gemfile and lockfile when present.

Record native plugin versions, Android Gradle Plugin, Kotlin, Gradle, Java and Kotlin
versions, Flutter-derived Android SDK and NDK values, iOS platform and deployment targets,
CocoaPods version, and lockfile presence. Treat `app/android/Gemfile.lock` as a Fastlane
tooling lock only. Record that `app/ios/Gemfile.lock` is absent when it is absent. Keep the
root `pubspec.yaml` as the command source of truth.

Run and record the full result of:

```bash
fvm exec melos outdated
```

Record current, upgradable, resolvable, and latest versions. Include direct and
dev dependencies, SDK constraints, platform plugins, Git dependencies, and
workspace package versions.

## 4. Select the Flutter SDK

Select the latest stable Flutter release only. Use `fvm releases` and verify the
choice against the official stable release list. Do not select beta, dev, master,
or another prerelease channel. Read the Flutter and Dart migration notes for
every stable release skipped between the pinned version and the selected version.

Show the proposed `.fvmrc` change and ask for approval before changing the
pinned SDK. After approval, use FVM to select and install the exact release, then
verify:

```bash
fvm use <latest-stable-version>
fvm install
fvm flutter --version
fvm dart --version
```

Do not raise a minimum Dart SDK constraint unless the selected stable SDK
requires it. If it does, show the constraint change and its migration reason.
Run this report only after the new SDK is selected:

```bash
fvm dart pub outdated --json
```

Save the JSON output for the upgrade record. Run the workspace report again
with the selected SDK:

```bash
fvm exec melos outdated
```

Use the post-SDK reports for the update table. Do not use the pre-SDK inventory
to make package decisions.

## 5. Review and approve package updates

Consolidate direct and dev dependency entries from all workspace manifests into
one review table. For each proposed update, record the package, owning
manifest, current constraint, selected constraint, resolved version, source,
and risk.

Skip these updates by default:

- Flutter and Dart SDK constraints.
- Git dependencies, including `fitbitter`.
- Transitive-only dependencies.
- Prerelease versions.

Review the pub.dev changelog and migration notes before any of these updates:

- Major updates.
- Minor updates for a `0.x` package.
- Persistent-data, authentication, storage, or routing packages.
- Camera, notification, permission, scanner, recording, or other native
  platform plugins.
- Updates with platform-minimum changes.
- Updates with staged migrations.
- Updates with missing or unclear migration documentation.

Review Git dependency history separately. Pub.dev release notes do not cover
`fitbitter`.

Ask concrete decision questions only when the review finds an actual risk. A
question must name the package, change, affected boundary, and requested
approval. Do not silently apply a breaking migration.

### Required secure-storage gate

Treat `flutter_secure_storage` as a production-data migration. If production
users may have data from v9 and the proposed path reaches v11 through v10, stop
before mutation. Read the v9, v10, and v11 migration notes. Ask for explicit
approval for the staged v9-to-v10-to-v11 release plan.

The approval question must cover:

- How v10 reads and preserves v9 data.
- How v10 data migrates to v11.
- Storage options and key compatibility.
- The minimum app version for each release.
- Rollback and recovery behavior if a read fails.

Do not jump directly from v9 to v11. Do not assume that a new storage format
migrates existing participant data. Inspect the shared implementation in
`flutter_common` and validate both frontends after approval.

## 6. Mutate approved inputs

Obtain approval for the final update table before mutation. Update each approved
direct constraint consistently across every manifest that declares it. Keep
internal workspace constraints aligned. Do not change SDK constraints unless the
SDK gate approved the change.

Edit manifests, not lockfiles. Let the repository command resolve lockfiles:

```bash
fvm exec melos upgrade
```

This uses the root script. Do not use `dart pub upgrade --major-versions` or
`fvm dart pub upgrade --major-versions` as the mutation step. Do not add a
`dependency_overrides` entry without explicit approval.

Review all resulting lockfiles and manifests. Stop if the solver reports a
conflict, a downgrade, an unexpected source change, an unapproved override, or
unrelated dependency churn. Do not repair a lockfile by hand.

## 7. Validate the update

### Native-platform gate

Run this gate when an approved change affects an app SDK, a plugin, native files, platform
minimums, or a required platform build. Complete the dependency resolution step first.

The agent may inspect native inputs and propose commands. After final update-table approval,
obtain explicit user approval before `flutter pub get`, `pod install`, or an
environment-qualified non-signing build. The approval must cover repository, cache, and
build mutation and the required host. Pair with the user for `flutter precache --ios`,
`pod install --repo-update`, `flutter clean`, Bundler installation, and direct native
diagnostics. The user must run signed Xcode builds, device and archive checks, signing,
keychain work, Fastlane, TestFlight, Play upload, and any command that uses production
credentials.

Review the diff immediately after every mutating native step. Do not hand-edit `Podfile.lock`,
generated files, or native lockfiles. Require macOS, Xcode, and CocoaPods for iOS. Require
Android SDK, Java, and Android tooling for Android. `fvm exec melos test` does not provide
native Android or iOS coverage. Record every native command, result, and skipped check with
its reason.

If an approved SDK, manifest, or plugin-resolution change affects the app, or generated
Flutter inputs are missing or stale, run:

```bash
fvm exec melos exec --scope studyu_app -- "flutter pub get"
```

Acknowledge that `fvm exec melos upgrade` already performs approved workspace
resolution and bootstrap. This command is not a second general dependency upgrade.

If iOS plugin resolution or Flutter pod integration changed, or Pods are absent or out of
sync, then run:

```bash
fvm exec melos exec --scope studyu_app -- "cd ios && pod install"
```

The iOS `app/ios/Podfile:13-26` requires generated Flutter settings before manual pod work.
Use `pod install --repo-update` only when plain `pod install` reports that a required
specification is unavailable or stale. Use `fvm flutter precache --ios` before pod work only
after the selected SDK lacks `Flutter.xcframework` or Flutter reports that exact missing-
artifact condition.

Do not run `pod update` for routine upgrades. Do not automatically run `bundle install`,
`bundle update`, Gradle refreshes, Gradle wrapper generation, AGP or Kotlin changes, or
`flutter create`. Treat these as separate, approved native or tooling changes.

### Native project regeneration handoff

This workflow must not run native project regeneration. Stop when Flutter migration evidence or
a concrete missing or outdated template file requires regeneration. Follow
`.agents/skills/flutter-platform-regeneration/SKILL.md` under a separate explicit approval.

Resume dependency validation only after that skill returns its approved patch and report. Keep
the native diff, approvals, command results, skipped checks, and residual risks in the upgrade
record. Prefer a narrow native compatibility edit when it fixes the issue without regeneration.

Run the narrowest checks for the affected packages and platforms. Use the
existing root Melos scripts and inspect their current definitions before use.
Record every command, result, and skipped check.

Run code generation when generator versions or generated inputs changed:

```bash
fvm exec melos generate
```

Inspect generated diffs. Keep tracked generated files only when the update
caused them.

Run analysis and fixes only for failures caused by this update. Use the root
scripts. Run `fvm exec melos fix` only after identifying such a failure. Then
rerun the affected analysis.

Run unit tests for workspace packages with tests:

```bash
fvm exec melos test
```

Run `fvm exec melos qualitycheck` when the pre-commit hook has not already run
an equivalent check, or when a full workspace check is required. This script
formats, generates, and analyzes. Review any formatting changes and keep only
changes caused by the upgrade.

Build every affected platform. Use a current environment-specific build
script from the root `pubspec.yaml`. Every app or Designer build must provide
`--dart-define=STUDYU_ENV=.env.dev` or `--dart-define=STUDYU_ENV=.env.local`.
Do not invoke an unqualified `build:android`, `build:ios`, or `build:web` script.
If the catalog has no safe environment-specific build script, run these root-level
commands for the participant app:

```bash
fvm exec melos exec --scope studyu_app -- \
  "flutter build apk --dart-define=STUDYU_ENV=.env.dev"

fvm exec melos exec --scope studyu_app -- \
  "flutter build ipa --no-codesign --dart-define=STUDYU_ENV=.env.dev"
```

Use `.env.local` when local services are required. These are validation builds, not release
builds. Flutter uses the CocoaPods workspace for the iOS build. A signed, device, or archive
check does not follow this unattended path. Ask the user to run it. Stop when the required
host or toolchain is unavailable. Do not fall back to an unqualified production command.

### Local E2E gate

Run local E2E checks when the affected boundary requires them. Before any
reset, read `supabase/README.md` and `.github/workflows/e2e_tests.yml`.
Follow the current workflow at run time. Do not copy its script body here.

Start the local Supabase services from the current workflow:

```bash
supabase start -x studio,imgproxy
```

Validate the same effective database URL that `scripts/reset-test-db.sh` uses.
The script uses `SUPABASE_DB_URL` when it is non-empty. Otherwise, it uses
`postgresql://postgres:postgres@127.0.0.1:54322/postgres`.

Immediately before the reset, read the running local database endpoint from
Supabase status and compare the effective URL with that endpoint and the local
configuration. Do not authorize a reset from a loopback hostname alone:

```bash
effective_db_url="${SUPABASE_DB_URL:-postgresql://postgres:postgres@127.0.0.1:54322/postgres}"
status_db_url="$({
  supabase status -o env |
    python3 -c '
import sys

db_url = None
for line in sys.stdin:
    if line.startswith("DB_URL=") and db_url is None:
        db_url = line.rstrip("\n").split("=", 1)[1]

if db_url is None:
    raise SystemExit(1)
print(db_url)
'
} )" || {
  echo "Cannot read the local database endpoint from supabase status." >&2
  exit 1
}

EFFECTIVE_DB_URL="$effective_db_url" STATUS_DB_URL="$status_db_url" python3 - <<'PY'
import os
import tomllib
from urllib.parse import urlparse


def endpoint(raw_url):
    parsed = urlparse(raw_url)
    database = parsed.path.removeprefix("/")
    if (
        parsed.scheme not in {"postgres", "postgresql"}
        or parsed.hostname not in {"localhost", "127.0.0.1", "::1"}
        or parsed.port is None
        or not database
        or parsed.query
        or parsed.fragment
    ):
        raise ValueError
    return parsed.scheme, parsed.hostname, parsed.port, database

try:
    effective = endpoint(os.environ["EFFECTIVE_DB_URL"])
    running = endpoint(os.environ["STATUS_DB_URL"])
    with open("supabase/config.toml", "rb") as config_file:
        configured_port = tomllib.load(config_file)["db"]["port"]
except (KeyError, OSError, TypeError, ValueError):
    raise SystemExit("Cannot validate the local Supabase database endpoint.")

if effective != running:
    raise SystemExit(
        "The effective SUPABASE_DB_URL does not match the running local endpoint."
    )
if running[2] != configured_port:
    raise SystemExit(
        "The running Supabase database port does not match supabase/config.toml."
    )

print(f"Verified local Supabase endpoint: {running[1]}:{running[2]}/{running[3]}")
PY
```

Stop if the URL is empty, malformed, remote, or differs in scheme, host, port,
database, query, or fragment from the running local endpoint. Stop if the
running database port differs from `supabase/config.toml`. Treat a failed
`supabase status` or endpoint comparison as evidence that the local services
are not ready.

Show the verified local endpoint without printing credentials. State that the
reset deletes local database data and that the reset script applies test
fixtures to the verified endpoint. Ask the user for explicit authorization to
run the reset with the validated URL. Do not infer authorization from an
earlier approval.

For the default validated local endpoint, remove `SUPABASE_DB_URL` from the
reset process. This preserves the script's Docker fallback. For another
validated local endpoint, pass the effective URL. The script then requires
`psql` and does not use the Docker fallback:

```bash
default_db_url="postgresql://postgres:postgres@127.0.0.1:54322/postgres"
if [ "$effective_db_url" = "$default_db_url" ]; then
  (
    unset SUPABASE_DB_URL
    ./scripts/reset-test-db.sh --yes
  )
else
  SUPABASE_DB_URL="$effective_db_url" ./scripts/reset-test-db.sh --yes
fi
```

Ensure the ignored `.env.local` exists without overwriting it. Populate local
values by following the workflow. Run the current Designer and app browser E2E
commands from `.github/workflows/e2e_tests.yml`. Never substitute production
credentials or a remote Supabase project.

Do not silently skip a required check. Stop when a required tool, platform,
local database, browser, or validation environment is unavailable. Mark an
optional check as skipped only with a reason in the upgrade record.

## 8. Stop conditions

Stop and request a decision or remediation when any of these conditions occurs:

- The repository root, clean worktree, or valid maintenance branch is missing.
- The SDK proposal is not the latest stable release, or migration notes are
  unavailable.
- The solver conflicts, downgrades, changes a source, or requires an override.
- A changelog or migration note is missing for a flagged update.
- A package raises a platform minimum without explicit approval.
- A breaking persistent-data, auth, storage, routing, camera, notification,
  permission, or other native migration lacks an approved plan.
- A required validation command fails or is unavailable.
- A required native host, toolchain, or platform validation is unavailable.
- A native dependency or platform-minimum change lacks explicit approval.
- `pod install` or native synchronization fails, `Podfile.lock` has unexpected churn, or a required podspec is unavailable.
- Regeneration lacks explicit approval, leaves an unexplained dirty native tree, removes custom native behavior, or changes identity, signing, or capabilities.
- Routine native validation uses an unqualified or production environment.
- The diff contains unrelated changes, workflow edits, or a tracked `.env.local`.
- A generated, lockfile, platform, or compatibility change has no update cause.

Keep the failure output and the exact command. Do not hide or work around the
failure with an override, downgrade, skipped check, or unrelated refactor.

## 9. Version and release handoff

Version only after all required checks pass and the final diff is reviewed.
Commit the validated dependency changes first. Stage only approved files and
use a compliant Conventional Commit subject:

```bash
git add <approved-files>
git commit -m "fix(deps): update approved dependencies"
```

Melos versions from committed Conventional Commits. First preview the
proposals without creating a commit or tags:

```bash
printf 'n\n' | fvm exec melos version --all --no-git-tag-version
```

Review package versions, internal constraints, and changelogs. Then let Melos
create its standard version commit without pre-merge tags:

```bash
fvm exec melos version --all --no-git-tag-version --yes
```

Do not create a manual version commit. Do not create package tags before the
pull request merges. Capture the exact Melos version commit:

```bash
git log --oneline --decorate -n 5
```

Use that actual Melos version commit to derive the released package list. Check
only package pubspec files whose versions changed in that commit:

```bash
git diff-tree --no-commit-id --name-only --diff-filter=M -r \
  <melos-version-commit> -- \
  core/pubspec.yaml flutter_common/pubspec.yaml app/pubspec.yaml \
  designer_v2/pubspec.yaml
```

For each listed manifest, compare its parent `version:` with its new
`version:` from `<melos-version-commit>`. Record a package only when that
version changed. Read and record its `name:` and new `version:` from the actual
commit. Ignore manifests that changed for constraints only. Exclude any package
whose manifest did not change in the actual Melos version commit. Stop if the
list is empty or a package name or version is unclear. Do not use the workspace
package list as a substitute. Melos `--all` includes private packages, but it
does not require every package to receive a version change.

Never push tags before the pull request merges. Never run `git push --tags` or
`git push origin --tags`.

## 10. Pull request and post-merge handoff

After the version step, follow `.agents/skills/pull-request/SKILL.md`. Complete
its ticketless maintenance branch, Conventional Commit, diff, template,
testing, confirmation, and author-attestation gates. Use
`chore(deps): <description>` for the PR title and
`Not applicable — maintenance PR.` for the Jira section.

Push the branch only. Do not include tags:

```bash
git push -u origin HEAD
```

Create the pull request only after the pull-request skill receives the required
confirmation. Do not deploy or publish. Before the pull request merges, do not
create or push tags. Allow merge, squash, and rebase outcomes. The production
handoff resolves the actual resulting commit on `main`.

After the dependency-upgrade pull request merges, handle tags only through an
explicitly approved production release plan. An ordinary merge to `dev` must
never create or push package tags. Use the dependency-upgrade pull request when
it merged directly to `main`. Otherwise, use the production pull request that
carried the change from `dev` to `main`.

Resolve the resulting commit from GitHub pull request metadata first:

```bash
gh pr view <main-pr-number> --repo studyu-health/studyu \
  --json state,mergedAt,baseRefName,headRefOid,mergeCommit,url
git fetch origin main --tags
```

Require a merged pull request whose base is `main`. Use `mergeCommit.oid` when
GitHub returns it and the commit is an ancestor of `origin/main`:

```bash
git merge-base --is-ancestor <merge-commit-oid> origin/main
```

For a rebase outcome or unavailable merge commit metadata, inspect the
applicable first-parent history:

```bash
git log --first-parent --format='%H %cI %s' origin/main
```

Use the pull request merge time and verified manifest contents to select the
commit that resulted from the pull request. Stop if more than one commit is
plausible. Do not select a commit from a path-filtered log alone. Record the
resolved commit as `<main-release-commit>`.

Use only the manifest paths and package names recorded from the actual Melos
version commit in section 9. This recorded list is the allowed package subset.
Do not add packages from the workspace or production pull request. If the
recorded list does not include an app version change, do not create a
`studyu_app-v*` tag.

For each recorded manifest, read the file at the exact resolved commit:

```bash
git show '<main-release-commit>:<manifest-path>'
```

Verify that `name:` matches the recorded package. Verify that `version:` matches
the version approved in the dependency-upgrade pull request. Stop if a manifest
is missing or either value differs. Construct each exact tag from these verified
values. Every tag must point to `<main-release-commit>`.

Before creating any tag, verify that its exact name is absent locally and on
`origin`:

```bash
git tag --list '<exact-tag>'
git ls-remote --exit-code --refs origin 'refs/tags/<exact-tag>'
```

Stop if either command finds the tag. Also stop if the remote check fails for a
reason other than an absent reference. Never move or overwrite an existing tag.
Show the exact conditional commands, but do not run them until explicit
production release authorization is given:

```bash
# Repeat only for each verified package entry.
git tag --annotate --message="Release <released-package> v<version>" \
  <released-package>-v<version> <main-release-commit>
git push origin <exact-tag-1> <exact-tag-2> ...
```

Pushing `studyu_app-v*` tags triggers `.github/workflows/release_app.yml`.
Tag creation and tag pushes require explicit production release authorization.
Never create or push tags for an ordinary `dev` merge. Record the main commit,
verified package subset, exact tags, authorization, and commands.

Record the changed files, approvals, commands, results, skipped checks with
reasons, release commit, exact tags, branch push, and residual risks.
