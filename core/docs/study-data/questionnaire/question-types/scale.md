# Scale Question

## Description

`ScaleQuestion` records a numeric value on a bounded scale.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes | - | Fixed value `scale`. |
| `id` | `String` | Yes | - | Stable question identifier used by answers, conditions, and data references. |
| `prompt` | `String?` | No | - | Participant-facing question text rendered as HTML in the app. |
| `rationale` | `String?` | No | - | Extra HTML shown behind the question's information icon. |
| `conditional` | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No | - | Visibility rule evaluated against earlier questionnaire answers. |
| `minimum` | `double` | No | - | Lowest selectable numeric value on the scale. |
| `maximum` | `double` | No | - | Highest selectable numeric value on the scale. |
| `step` | `double` | No | - | Distance between selectable values. `0` means the app chooses intermediate values. |
| `annotations` | [`List<Annotation>`](../nested-objects.md) | No | `[]` | Labels attached to specific scale values. |
| `minColor (min_color)` | `int?` | No | - | ARGB color integer for the minimum end of the scale. |
| `maxColor (max_color)` | `int?` | No | - | ARGB color integer for the maximum end of the scale. |
| `initial` | `double?` | No | - | Numeric value selected when the question first appears. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `scale` |
<!-- GENERATED:DISCRIMINATORS END -->
