# Checkmark Task

## Description

`CheckmarkTask` records whether a participant completed a simple task.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `String` | Yes | Fixed value `checkmark`. |
| `id` | `String` | Yes | Unique task identifier. |
| `title` | `String?` | No | Short display title. |
| `header` | `String?` | No | Optional header text. |
| `footer` | `String?` | No | Optional footer text. |
| `schedule` | [`Schedule`](../schedules/task-schedule.md) | No | When this task is presented. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `checkmark` |
<!-- GENERATED:DISCRIMINATORS END -->
