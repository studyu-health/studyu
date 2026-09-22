# Textual Summary Section

## Description

`TextualSummarySection` reports a text summary for a referenced result property.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `textual_summary`. |
| `id` | `String` | Yes | Unique section identifier (UUID). |
| `title` | `String?` | No | Report card title shown above the textual summary. |
| `description` | `String?` | No | Report card body text shown below the title. |
| `resultProperty` | [`DataReference<num>?`](../../shared/data-reference.md) | No | Numeric task result summarized by intervention. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `textual_summary` |
<!-- GENERATED:DISCRIMINATORS END -->
