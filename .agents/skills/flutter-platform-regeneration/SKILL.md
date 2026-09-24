---
name: flutter-platform-regeneration
description: Regenerate StudyU's existing Flutter Android and iOS project files after Flutter migration evidence or an explicit user request, with approval, inventory, reversible worktree, diff, and native handoff gates.
argument-hint: "[commit-or-branch]"
---

# /flutter-platform-regeneration - Assisted Flutter platform regeneration

Use this skill only when Flutter migration output identifies Android or iOS project
regeneration, or when the user explicitly requires regeneration. Do not use it for routine
dependency upgrades, isolated SDK setting changes, package resolution, or release work. Run
every command from the repository root.

## 1. Preflight and scope

Run these checks before mutation:

```bash
source_root="$(git rev-parse --show-toplevel)"
printf '%s\n' "$source_root"
git status --short --untracked-files=all
git branch --show-current
git rev-parse HEAD
git diff -- app/android app/ios
git status --short --ignored -- app/android app/ios
```

Require the StudyU repository root or its resolved Git root. Require a dedicated worktree.
Stop when `app/android` or `app/ios` contains dirty or unexplained changes. Preserve unrelated
changes. Do not stash, reset, clean, or remove files.

Record the trigger evidence or the user's exact request. Record the approved Flutter version,
current commit, branch, target directory `app`, platform set, and files in scope.

Ask for explicit approval that names the command, target, platform set, and replacement risk.
Do not infer this approval from dependency-upgrade approval.

## 2. Baseline inventory

Inventory the existing native tree before `flutter create`. Include tracked and untracked
paths, symlinks, file types, and SHA-256 hashes for binary files. Exclude generated `Pods` and
local `xcuserdata`. Exclude local secrets such as `local.properties` and `key.properties`.

Inspect at least:

- `app/android/**`, including Gradle files, the manifest, Kotlin sources, resources,
  `gradle.properties`, the wrapper, Gemfile, and Fastlane files.
- `app/ios/**`, including `Podfile`, lockfiles, Flutter configuration, Runner sources and
  resources, plists, entitlements, Xcode projects, workspaces, schemes, SwiftPM resolutions,
  tests, and Fastlane files.

Do not print secret contents. Do not record signing keys, certificates, or environment values.
Use `file` to detect binary files by file type, not by filename extension. Hash each file
that `file` classifies as binary. This includes `.a` archives and binaries inside `.framework`
and `.xcframework` bundles, including binaries without extensions.

Use these read-only inventory commands when needed:

```bash
find app/android app/ios -type f \
  -not -path '*/Pods/*' \
  -not -path '*/xcuserdata/*' \
  -not -name 'local.properties' \
  -not -name 'key.properties' \
  -print0 |
while IFS= read -r -d '' path; do
  file_type="$(file -b "$path")"
  encoding="$(file -b --mime-encoding "$path")"
  printf '%s\t%s\n' "$path" "$file_type"
  if [ "$encoding" = 'binary' ]; then
    shasum -a 256 "$path"
  fi
done

find app/android app/ios -type l \
  -not -path '*/Pods/*' \
  -not -path '*/xcuserdata/*' \
  -not -name 'local.properties' \
  -not -name 'key.properties' \
  -print
```

Record these custom contracts:

- Android namespace and application ID `health.studyu.app`.
- Android signing property flow and debug fallback.
- Android SDK and NDK values, Java and Kotlin 17, desugaring, and the `androidx.window`
  workaround.
- Android permissions, deep-link hosts, `studyu-app`, `flutter_web_auth_2`, and notification
  receivers.
- iOS platform `15.0`, Podfile deployment override `13.0`, and `AUDIO_SESSION_MICROPHONE=0`.
- AppDelegate notification and implicit-engine registration.
- SceneDelegate and plist scene or storyboard references.
- Plist permissions, localization, background modes, file sharing, query schemes, and URL
  scheme.
- APNs and both associated domains.
- Xcode targets, schemes, package and Pods phases, bundle ID, team, profile, signing,
  entitlements, plist, bridging header, and deployment target.
- Fastlane and release metadata. Never regenerate these automatically.

## 3. Isolated regeneration

Use the `source_root` value recorded during preflight. Do not recalculate it after entering
the temporary worktree. Choose and record a unique run identifier. Derive and record these
distinct absolute paths before generation:

```bash
temporary_worktree="$source_root/.worktrees/studyu-platform-regeneration-<short-sha>-<run-id>"
artifact_path="$source_root/.worktrees/studyu-platform-regeneration-<short-sha>-<run-id>.patch"
printf '%s\n' "$temporary_worktree"
printf '%s\n' "$artifact_path"
```

Verify that `source_root` is absolute. Verify that `temporary_worktree` differs from
`source_root`. Verify that `artifact_path` is absolute, is inside
`$source_root/.worktrees/`, differs from `temporary_worktree`, and is ignored. Keep the
recorded variables unchanged. Stop if any verification fails.

Create the temporary worktree from the recorded commit:

```bash
git worktree add --detach "$temporary_worktree" <recorded-commit>
```

Create the temporary worktree under `.worktrees/` relative to the recorded source root. Record
the exact absolute path after creation. Verify its path and commit before mutation. From both
worktree roots, verify that the recorded artifact directory is accessible. The source worktree
remains unchanged.

Run all preparation, regeneration, and immediate review commands from the temporary worktree
root, not the source worktree. Run these commands there when required:

```bash
cd <exact-temporary-worktree-path>
fvm install
./setup.sh
```

Run `./setup.sh` only when the selected Flutter SDK or repository state requires setup. Ask for
approval before setup or cache mutation. Do not alter the source worktree. The approved
`fvm flutter create --platforms=android,ios --overwrite app` command and its immediate status
and diff review also run from this exact temporary worktree root.

After preparation, record the full temporary-worktree baseline before regeneration:

```bash
git status --short --untracked-files=all
git status --short --ignored --untracked-files=all
git ls-files --others --ignored --exclude-standard

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Preparation changed tracked files. Stop before regeneration." >&2
  exit 1
fi
```

Stop if preparation changes a tracked file. Do not include preparation changes in the
regeneration artifact.

After the user approves the exact command, run only this regeneration command from the
temporary worktree root:

```bash
fvm flutter create --platforms=android,ios --overwrite app
```

Use `--overwrite` only for this command in the temporary worktree. Do not use it for setup
commands or commands in the source worktree. Never delete or recreate `app/android` or
`app/ios` wholesale. Never run `flutter create .`. Never include desktop or web platforms. Do
not add `--org`, change the bundle ID, or change the package name. Do not regenerate Fastlane,
web, desktop, or unrelated files.

If Flutter cannot limit output to Android and iOS, stop. If the command proposes files outside
`app/android` and `app/ios`, stop before accepting the output.

## 4. Diff and reconciliation

From the same temporary worktree root, inspect the full worktree immediately:

```bash
git status --short --untracked-files=all
git status --short --ignored --untracked-files=all
git ls-files --others --ignored --exclude-standard
git diff --stat
git diff --name-status
git diff
```

Compare the full-worktree results with the recorded temporary-worktree baseline. Classify every
changed tracked path and every untracked or ignored path. Reject every unexpected path. Stop
before platform review if any path remains unexplained or exceeds the approved regeneration
scope.

After the full-worktree gate passes, run the detailed platform review:

```bash
git status --short --untracked-files=all -- app/android app/ios
git status --short --ignored --untracked-files=all -- app/android app/ios
git ls-files --others --ignored --exclude-standard -- app/android app/ios
git diff --stat -- app/android app/ios
git diff --name-status -- app/android app/ios
git diff -- app/android app/ios
```

Compare the platform results with the baseline inventory. Classify every new tracked,
untracked, and ignored path. Exclude secrets and local generated state from transfer. No
unexplained path may remain. Compare binary files by path and SHA-256. Compare text files with
full diffs. Compare Xcode project graph counts and references. Review every deletion, rename,
identity change, signing setting, entitlement, manifest or plist key, Gradle or Podfile hook,
scheme, workspace, lockfile, and asset.

Stop immediately when the diff:

- changes or deletes an unapproved custom file
- changes `health.studyu.app`, the signing team, the profile, entitlements, or capabilities
- removes a deep link, permission, notification receiver, OAuth callback, localization,
  background mode, or plugin workaround
- changes Xcode targets, phases, schemes, workspace references, or SwiftPM state without an
  approved reason
- changes files outside Android or iOS or creates broad template churn without migration
  evidence
- deletes `Podfile.lock`, `Gemfile.lock`, or SwiftPM resolution state without explicit review
- cannot be reconciled mechanically

Do not hand-edit lockfiles. Do not accept generated output by default. Show the complete diff.
Ask the user to approve the exact changed-file set before reapplying custom configuration.

Before creating the artifact, obtain an explicit approved changed-file list. Stage only the
approved paths that regeneration created or changed after the post-preparation baseline. Do
not stage a path that preparation created. Verify that `git diff --cached --name-status`
exactly matches the approved list. Generate a binary-capable patch from only those staged
paths at the recorded absolute path:

```bash
git diff --cached --binary --no-ext-diff > "$artifact_path"
```

Use the recorded absolute path to display the artifact hash and approved file list:

```bash
shasum -a 256 "$artifact_path"
git apply --stat "$artifact_path"
```

Require explicit user approval of the artifact and record its SHA-256 hash. Before every later
step, verify that the SHA-256 hash of the recorded absolute path is unchanged. From the source
worktree, run this check against the same recorded path:

```bash
git apply --check "$artifact_path"
```

After the check and before the approved apply step, verify the hash again. Apply only the
approved artifact from the same recorded absolute path:

```bash
git apply "$artifact_path"
```

Do not silently copy trees or merge unrelated work. Do not remove the artifact without
explicit cleanup approval. Stop if any path is unexplained or the artifact hash changes.

## 5. Controlled reapplication

Reapply only user-approved, mechanically verifiable StudyU settings. Preserve custom source,
resources, Fastlane, and release files unless the user approves a specific migration. Do not
alter signing, capabilities, profiles, certificates, or credentials.

The user must review every changed `project.pbxproj`, scheme, workspace, Podfile, Gradle file,
manifest, plist, entitlements file, and binary asset. The user must decide ambiguous Xcode
project graph changes. The agent must not resolve those conflicts.

## 6. Validation and user handoff

After diff approval, run only the narrowest approved validation from the source worktree.
Use this root-safe Android command when approved Android files changed:

```bash
fvm exec melos exec --scope studyu_app -- \
  "flutter build apk --dart-define=STUDYU_ENV=.env.dev"
```

Use this root-level iOS form when approved iOS files changed:

```bash
fvm exec melos exec --scope studyu_app --fail-fast -- \
  "flutter build ipa --no-codesign --dart-define=STUDYU_ENV=.env.dev"
```

Use `.env.local` instead when local services are required. Do not run an unqualified production
build. Inspect the root `pubspec.yaml` before selecting other commands. Do not run signing,
archives, deployment, Fastlane, `xcodebuild` archive, or device commands autonomously. Keep
user-supervised emulator and device behavior checks separate from compile validation.

No-codesign validation proves only that the project can compile without signing. It does not
prove provisioning, capabilities, entitlements, App Store submission, or device behavior.

The user must open `app/ios/Runner.xcworkspace` in Xcode, not the `.xcodeproj`. The user must
inspect target membership, Pods, Swift packages, schemes, build configurations,
`Runner/Runner.entitlements`, `Runner/Info.plist`, bundle ID, team, and provisioning profiles.
The user must resolve signing and capability changes in Xcode. The user must supervise launch,
deep-link, notification, camera, and affected-plugin checks. Do not report release readiness
until Xcode and device or archive checks pass.

For Android, the user must choose an authorized emulator or device. The user must review deep
links, notifications, OAuth callback, and launch behavior when those surfaces changed.

## 7. Responsibility and stop conditions

The agent captures trigger evidence, inventories paths and hashes, creates and verifies the
temporary worktree, runs the approved platform-limited command, produces complete diffs, stops
on loss or ambiguity, reapplies approved settings, and reports commands and residual risks.

The user approves regeneration, the exact command, each changed-file set, custom-setting
reapplication, ambiguous project graph changes, Xcode workspace review, team, certificates,
profiles, capabilities, devices, signing, and release decisions. The user must not provide
credentials to the agent or run a release lane through this skill.

Stop when the worktree is dirty, the scope is broad, the command lacks explicit approval, the
output changes identity or signing, custom behavior disappears, lockfiles churn unexpectedly,
the Xcode graph is ambiguous, the required host or toolchain is unavailable, or validation
fails. Stop when regeneration proposes files outside `app/android` and `app/ios`.

Record every command, result, skipped check, reason, approved decision, changed file, and
remaining risk.
