# Dependency Maintenance

Renovate manages out-of-range dependency updates. The `pub` manager keeps its
seven-day `minimumReleaseAge` policy.

Renovate lockfile maintenance stays disabled. It runs `dart pub upgrade`, which
can select compatible transitive releases younger than seven days.

## Monthly lockfile refresh

1. Start from an up-to-date `dev` branch in a clean working tree.
2. Verify that `fvm dart --version` meets the SDK constraint in the root
   `pubspec.yaml`.
3. Run `fvm dart pub upgrade` from the repository root.
4. Review every changed package version in the root `pubspec.lock`. Confirm
   that each publication date is at least seven days old.
5. Confirm that the `fitbitter` resolved Git commit did not change.
6. Confirm that workspace packages remain workspace dependencies.
7. Run `fvm dart run melos run test` and open a lockfile-only pull request.

Reject the refresh when an age check, Git revision check, workspace check, or
validation check fails. Require human review before merging.
