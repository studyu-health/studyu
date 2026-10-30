# Visual Analogue Question

## Description

`VisualAnalogueQuestion` records a slider value with endpoint labels and colors.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes | - | Fixed value `visualAnalogue`. |
| `id` | `String` | Yes | - | Stable question identifier used by answers, conditions, and data references. |
| `prompt` | `String?` | No | - | Participant-facing question text rendered as HTML in the app. |
| `rationale` | `String?` | No | - | Extra HTML shown behind the question's information icon. |
| `conditional` | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No | - | Visibility rule evaluated against earlier questionnaire answers. |
| `minimum` | `double` | No | - | Lowest slider value. |
| `maximum` | `double` | No | - | Highest slider value. |
| `step` | `double` | No | - | Distance between selectable slider values. |
| `minimumColor` | `int` | No | `0xFF0000FF` | ARGB color integer for the left/minimum end. |
| `maximumColor` | `int` | No | `0xFFFF0000` | ARGB color integer for the right/maximum end. |
| `minimumAnnotation` | `String` | No | `''` | Label shown at the minimum end. |
| `maximumAnnotation` | `String` | No | `''` | Label shown at the maximum end. |
| `initial` | `double?` | No | - | Numeric value selected when the question first appears. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `visualAnalogue` |
<!-- GENERATED:DISCRIMINATORS END -->
