# Descriptive Stats Section

## Description

`DescriptiveStatsSection` reports summary statistics for a referenced result property.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `descriptive_stats`. |
| `id` | `String` | Yes | Unique section identifier (UUID). |
| `title` | `String?` | No | Report card title shown above descriptive statistics. |
| `description` | `String?` | No | Report card body text shown below the title. |
| `resultProperty` | [`DataReference<num>?`](../../shared/data-reference.md) | No | Numeric task result used for summary statistics. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `descriptive_stats` |
<!-- GENERATED:DISCRIMINATORS END -->
