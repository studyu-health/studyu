# Gauge Comparison Section

## Description

`GaugeComparisonSection` reports a gauge for a referenced numeric result property.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `gauge_comparison`. |
| `id` | `String` | Yes | Unique section identifier (UUID). |
| `title` | `String?` | No | Report card title shown above the gauges. |
| `description` | `String?` | No | Report card body text shown below the title. |
| `resultProperty` | [`DataReference<num>?`](../../shared/data-reference.md) | No | Numeric task result compared between interventions. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `gauge_comparison` |
<!-- GENERATED:DISCRIMINATORS END -->
