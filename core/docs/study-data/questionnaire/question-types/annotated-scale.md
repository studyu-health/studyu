# Annotated Scale Question

## Description

`AnnotatedScaleQuestion` records a numeric scale answer with labelled values.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes | - | Fixed value `annotatedScale`. |
| `id` | `String` | Yes | - | Stable question identifier used by answers, conditions, and data references. |
| `prompt` | `String?` | No | - | Participant-facing question text rendered as HTML in the app. |
| `rationale` | `String?` | No | - | Extra HTML shown behind the question's information icon. |
| `conditional` | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No | - | Visibility rule evaluated against earlier questionnaire answers. |
| `minimum` | `double` | No | - | Lowest selectable numeric value. |
| `maximum` | `double` | No | - | Highest selectable numeric value. |
| `step` | `double` | No | - | Distance between selectable values. |
| `annotations` | [`List<Annotation>`](../nested-objects.md) | No | `[]` | Labels attached to specific scale values. |
| `initial` | `double?` | No | - | Numeric value selected when the question first appears. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `annotatedScale` |
<!-- GENERATED:DISCRIMINATORS END -->
