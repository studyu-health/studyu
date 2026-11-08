# Data Reference

## Description

`DataReference` points a report or result to a task result property.

Use `DataReference` in report sections and numeric result definitions.

## How to choose values

- `task` is the ID of an observation task or intervention task.
- For questionnaire tasks, `property` is the question ID inside that task's `questions` array.
- Report sections that expect numbers should reference a question that records numeric answers.

## Example

```json
{
  "task": "daily-mood-task",
  "property": "mood-score"
}
```

<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `task` | `String` | Yes | ID of the task this reference points to. |
| `property` | `String` | Yes | Name of the specific property within the task result to reference. |
<!-- GENERATED:FIELDS END -->
