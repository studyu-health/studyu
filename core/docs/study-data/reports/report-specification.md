# Report Specification

## Description

`ReportSpecification` defines the report sections shown after study participation.

Reports render after participation is complete. In debug builds they can render earlier. The app
shows `primary` first with a primary-result label, then each `secondary` section below it.

Each report section reads numeric answers through a `DataReference`. The referenced task must exist
in `observations` or in the participant's selected intervention tasks. For questionnaire tasks, the
referenced property is a question ID.



<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `primary` | [`ReportSection?`](report-specification.md) | No | - | The main highlighted report section shown at the top. |
| `secondary` | [`List<ReportSection>`](report-specification.md) | No | `[]` | Additional report sections shown below the primary section. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:LINKS START -->
- [Average](sections/average.md)
- [Linear Regression](sections/linear-regression.md)
- [Textual Summary](sections/textual-summary.md)
- [Gauge Comparison](sections/gauge-comparison.md)
- [Descriptive Stats](sections/descriptive-stats.md)
<!-- GENERATED:LINKS END -->
