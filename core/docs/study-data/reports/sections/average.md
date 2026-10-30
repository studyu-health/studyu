# Average Section

## Description

`AverageSection` reports an average for a referenced numeric result property.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `average`. |
| `id` | `String` | Yes | Unique section identifier (UUID). |
| `title` | `String?` | No | Report card title shown above the chart. |
| `description` | `String?` | No | Report card body text shown below the title. |
| `aggregate` | [`TemporalAggregation?`](../../shared/enums.md#temporalaggregation) | No | How values are averaged before plotting. One of `day`, `phase`, `intervention`. |
| `resultProperty` | [`DataReference<num>?`](../../shared/data-reference.md) | No | Numeric task result used for the average chart. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `average` |
<!-- GENERATED:DISCRIMINATORS END -->
