# Intervention Result

## Description

`InterventionResult` defines an exported result grouped by intervention.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `intervention`. |
| `id` | `String` | Yes | Unique result identifier (UUID). |
| `filename` | `String` | No | CSV export filename for this result type. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `intervention` |
<!-- GENERATED:DISCRIMINATORS END -->
