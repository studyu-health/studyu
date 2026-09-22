# Choice Question

## Description

`ChoiceQuestion` asks participants to choose one or more configured answers.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes | - | Fixed value `choice`. |
| `id` | `String` | Yes | - | Stable question identifier used by answers, conditions, and data references. |
| `prompt` | `String?` | No | - | Participant-facing question text rendered as HTML in the app. |
| `rationale` | `String?` | No | - | Extra HTML shown behind the question's information icon. |
| `conditional` | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No | - | Visibility rule evaluated against earlier questionnaire answers. |
| `multiple` | `bool` | No | `false` | Whether participants may select more than one choice. |
| `choices` | [`List<Choice>`](../nested-objects.md) | No | `[]` | Answer options; stored answers contain choice IDs, not labels. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `choice` |
<!-- GENERATED:DISCRIMINATORS END -->
