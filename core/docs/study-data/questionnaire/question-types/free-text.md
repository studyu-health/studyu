# Free Text Question

## Description

`FreeTextQuestion` records typed text with optional format limits.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `freeText`. |
| `id` | `String` | Yes | Stable question identifier used by answers, conditions, and data references. |
| `prompt` | `String?` | No | Participant-facing question text rendered as HTML in the app. |
| `rationale` | `String?` | No | Extra HTML shown behind the question's information icon. |
| `conditional` | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No | Visibility rule evaluated against earlier questionnaire answers. |
| `lengthRange` | `List<int>` | Yes | Allowed answer length as `[min, max]` characters. |
| `textType` | [`FreeTextQuestionType`](../../shared/enums.md#freetextquestiontype) | Yes | Text validator. One of `any`, `alphanumeric`, `numeric`, `custom`. |
| `customTypeExpression` | `String?` | No | Regex used when `textType` is `custom`. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `freeText` |
<!-- GENERATED:DISCRIMINATORS END -->
