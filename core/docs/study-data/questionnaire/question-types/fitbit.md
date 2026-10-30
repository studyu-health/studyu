# Fitbit Question

## Description

`FitbitQuestion` requests Fitbit data types used by the study.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `FitbitQuestion`. |
| `id` | `String` | Yes | Stable question identifier used by answers, conditions, and data references. |
| `prompt` | `String?` | No | Participant-facing question text rendered as HTML in the app. |
| `rationale` | `String?` | No | Extra HTML shown behind the question's information icon. |
| `conditional` | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No | Visibility rule evaluated against earlier questionnaire answers. |
| `types` | [`List<FitbitQuestionType>`](../../shared/enums.md#fitbitquestiontype) | Yes | Fitbit data streams requested for this question. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `FitbitQuestion` |
<!-- GENERATED:DISCRIMINATORS END -->
