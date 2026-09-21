# SonarQube

SonarQube analyzes StudyU pull requests that target `dev`, and every push to `dev`.

Project key: `studyu-health_studyu`

Repository: <https://github.com/studyu-health/studyu/>

Dashboard: <https://sonar.cloud.studyu.health/dashboard?id=studyu-health_studyu>

The project uses a 30-day new-code definition and the built-in **Sonar way** quality gate. The
gate fails when coverage on new code is below 80%.

The gate reports its result on the pull request. `dev` requires only the `ready_to_merge` status
check, and the `Ready to Merge` workflow observes the `SonarQube` workflow run. A failing quality
gate therefore fails `Ready to Merge` and blocks the merge. The `SonarQube` workflows are not
required checks themselves.

## When analysis runs

| Event | Analysis |
| --- | --- |
| Pull request to `dev` from `studyu-health/studyu` | Pull request analysis |
| Push to `dev` | Branch analysis |
| Manual run of the `SonarQube` workflow on `dev` | Branch analysis |

The workflow skips fork and Dependabot pull requests because those runs cannot receive the
SonarQube token. GitHub records a skipped job as successful. This makes those pull requests
explicit exceptions to the required check. It does not mean SonarQube analyzed them.

## Where you see the result

A pull request run adds two checks:

- **`SonarQube Quality Gate`** is the workflow check. It obtains the coverage reports, runs the
  analyzer, and runs the scan. When the quality gate fails, the check shows one error annotation
  for each failing condition, and the run summary shows a table with the value and the threshold
  of each condition.
- **`SonarQube Code Analysis`** is the SonarQube check. It links to the pull request analysis in
  the dashboard and lists the new, fixed, and unresolved issues.

The workflow also writes the condition table to the run summary, and the scan step writes the
full scanner output to the log. The annotations and the table describe the analysis of the same
workflow run: the workflow reads the compute engine task of its own scan and asks SonarQube for
the quality gate of that analysis.

## What the analysis covers

The analysis reads the Dart and Flutter code of four packages:

- Sources: `app/lib`, `core/lib`, `designer_v2/lib`, `flutter_common/lib`.
- Tests: `app/test`, `core/test`, `designer_v2/test`, `flutter_common/test`.

The analysis excludes these files:

- Generated code, for example `*.g.dart`.
- Generated localization files of `app` and `designer_v2`.
- Generated Mockito mocks, for example `*.mocks.dart`.

Coverage comes from the unit and widget tests of the four packages. The workflow merges the
package LCOV reports into one scan report.

The `All Packages` workflow runs the same coverage command and uploads the reports as the
`sonar-coverage` artifact. The `SonarQube` workflow downloads the artifact of the same commit
when it exists, and it skips its own test run. It reuses the artifact only when the reports of
all four packages are present and not empty. When no artifact is available, the `SonarQube`
workflow runs the tests itself.

The workflow also validates these Flutter JSON execution reports before it scans:

- `app/coverage/tests.output`
- `core/coverage/tests.output`
- `designer_v2/coverage/tests.output`
- `flutter_common/coverage/tests.output`

Each report must be non-empty, contain a suite, and end with a successful `done` event. These
reports provide unit-test execution data. They do not calculate coverage.

The analysis does not cover:

- Designer browser end-to-end tests.
- Supabase database tests.
- Native Android and iOS code.
- Generated code and generated localization files.

## New code

The quality gate measures new code, not the complete code base.

- A pull request analysis uses the pull request diff against `dev`.
- A branch analysis uses a window of the last 30 days.

## Quality gate conditions

| Condition | Fails when |
| --- | --- |
| Coverage on new code | below 80.0% |
| Duplicated lines on new code | above 3.0% |
| New issues | one or more |
| Security hotspots reviewed on new code | below 100% |

SonarQube ignores the coverage condition when a change adds fewer than 20 new coverable lines,
and it ignores the duplication condition when a change adds fewer than 20 new lines. A
documentation-only pull request therefore passes the gate.

## When the quality gate fails

1. Open the failing `SonarQube Quality Gate` check. The annotations and summary table show the
   failing condition, its value, and its threshold.
2. Open the dashboard link in the same check. The dashboard shows the affected files and lines.
3. Fix the failing condition:
   - **Coverage on new code** — add tests that execute the new lines.
   - **New issues** — fix the reported issues, or mark a false positive in the dashboard and
     give a reason.
   - **Duplicated lines on new code** — remove the duplication, or extract the shared code into
     one place.
   - **Security hotspots reviewed on new code** — review each hotspot in the dashboard, then
     mark it safe or fixed.
4. Push the fix. The workflow analyzes the pull request again.

A bypass hides the failing condition from the reviewer and from the next analysis. Fix the
condition, or discuss the exception in the pull request.

## Reproduce the coverage result locally

Run these commands from the repository root:

```bash
fvm exec melos test:coverage
fvm dart scripts/normalize_lcov.dart coverage/sonar/lcov.info
fvm dart scripts/normalize_lcov.dart --check
```

`test:coverage` runs `flutter test --coverage` for each package with a test directory. It writes
the package test reports and the package LCOV reports. The normalizer merges the package reports
into `coverage/sonar/lcov.info`. This file is the only coverage input of the scan.

A local run does not contact SonarQube, and it does not evaluate the quality gate. The scan
requires `SONAR_TOKEN` and `SONAR_HOST_URL`, so it runs in GitHub Actions only.

## Known limits

- Coverage includes unit and widget tests only. Integration tests, browser end-to-end tests, and
  database tests do not change the coverage value.
- A skipped workflow run leaves the pull request without a quality gate result. A manual run
  does not replace it, because a manual run analyzes `dev`.
- Flutter LCOV has no record for a source file that no unit or widget test loads. The analysis
  stores no coverage measure for that file, so it adds no lines to cover and counts neither as
  covered nor as uncovered, also on new code.
