# Pain Question

## Description

`PainQuestion` records pain information through body pain models.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `pain`. |
| `id` | `String` | Yes | Stable question identifier used by answers, conditions, and data references. |
| `prompt` | `String?` | No | Participant-facing question text rendered as HTML in the app. |
| `rationale` | `String?` | No | Extra HTML shown behind the question's information icon. |
| `conditional` | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No | Visibility rule evaluated against earlier questionnaire answers. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `pain` |
<!-- GENERATED:DISCRIMINATORS END -->
