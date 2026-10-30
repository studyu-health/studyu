# Intervention

## Description

`Intervention` defines one study arm and the tasks participants perform in that arm.

Participants receive tasks from their active intervention arm. `StudySchedule` decides which
intervention is active on each study day. The app skips intervention tasks with no `title` when it
builds the participant's daily schedule.



<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | `String` | Yes | - | Unique intervention identifier (UUID). |
| `name` | `String?` | No | - | Display name of the intervention arm. |
| `description` | `String?` | No | - | Optional description of what participants do in this arm. |
| `icon` | `String` | No | `''` | Material icon name for this intervention. |
| `tasks` | [`List<InterventionTask>`](checkmark-task.md) | No | `[]` | List of tasks participants perform during each day of this intervention. |
<!-- GENERATED:FIELDS END -->
