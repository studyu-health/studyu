# Schedule

## Description

`Schedule` defines when a task is available and when reminders fire.

`completionPeriods` creates task instances. A task with two periods appears twice on the same day,
once per period ID. The app uses period IDs to decide whether a task instance has been completed.

Times use local `H:mm` or `HH:mm` strings. The default schedule has one window from `8:00` to
`20:00` and no reminders.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `completionPeriods` | [`List<CompletionPeriod>`](task-schedule.md#completionperiod) | No | `[CompletionPeriod.noId(unlockTime: StudyUTimeOfDay(hour: 8), lockTime: StudyUTimeOfDay(hour: 20))]` | Time windows within a day during which the task can be completed. |
| `reminders` | [`List<StudyUTimeOfDay>`](../shared/scalars.md#time-of-day) | No | `[]` | Optional reminder times for this task. |
<!-- GENERATED:FIELDS END -->

## CompletionPeriod

Each entry in `completionPeriods` is a nested completion-period object.

```json
{
  "id": "morning-window",
  "unlockTime": "8:00",
  "lockTime": "12:00"
}
```

- `id`: unique completion-period identifier.
- `unlockTime`: local time when the task window opens.
- `lockTime`: local time when the task window closes.

<!-- GENERATED:FIELDS:CompletionPeriod START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | Yes | Unique completion-period identifier used to track completion for this daily task window. |
| `unlockTime` | [`StudyUTimeOfDay`](../shared/scalars.md#time-of-day) | Yes | Local time when this completion period opens. |
| `lockTime` | [`StudyUTimeOfDay`](../shared/scalars.md#time-of-day) | Yes | Local time when this completion period closes. |
<!-- GENERATED:FIELDS:CompletionPeriod END -->
