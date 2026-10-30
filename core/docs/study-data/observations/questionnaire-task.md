# Questionnaire Task

## Description

`QuestionnaireTask` schedules a questionnaire as an observation during the study.

The participant app creates one task instance for each `completionPeriods` entry on every scheduled
day. Questionnaire answers are stored by question ID. Report sections and numeric results reference
those answers through `DataReference.task` and `DataReference.property`.

Use stable IDs for questionnaire tasks and questions. Changing them breaks result references and
conditional expressions.



<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes | - | Fixed value `questionnaire`. |
| `id` | `String` | Yes | - | Unique task identifier. |
| `title` | `String?` | No | - | Short display title. |
| `header` | `String?` | No | - | Optional header text shown above the task. |
| `footer` | `String?` | No | - | Optional footer text shown below the task. |
| `schedule` | [`Schedule`](../schedules/task-schedule.md) | No | - | When this task is presented to the participant. |
| `questions` | [`StudyUQuestionnaire`](../questionnaire/index.md) | No | `StudyUQuestionnaire()` | The ordered list of questions in this task. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `questionnaire` |
<!-- GENERATED:DISCRIMINATORS END -->
