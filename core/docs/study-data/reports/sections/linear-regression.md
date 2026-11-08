# Linear Regression Section

## Description

`LinearRegressionSection` reports a trend for a referenced numeric result property.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes | - | Fixed value `linearRegression`. |
| `id` | `String` | Yes | - | Unique section identifier (UUID). |
| `title` | `String?` | No | - | Report card title shown above the regression result. |
| `description` | `String?` | No | - | Report card body text shown below the title. |
| `resultProperty` | [`DataReference<num>?`](../../shared/data-reference.md) | No | - | Numeric task result used as the regression outcome. |
| `alpha` | `double` | No | `0.05` | Significance threshold for the regression test. |
| `improvement` | [`ImprovementDirection?`](../../shared/enums.md#improvementdirection) | No | - | Direction that counts as improvement. One of `positive`, `negative`. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `linearRegression` |
<!-- GENERATED:DISCRIMINATORS END -->
