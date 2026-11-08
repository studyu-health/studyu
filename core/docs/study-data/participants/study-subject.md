# Study Subject

## Description

`StudySubject` stores the runtime enrolment row for one participant in one study.

<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | `String` | Yes | - | Unique participant identifier (UUID). |
| `studyId (study_id)` | `String` | Yes | - | ID of the study this subject is enrolled in. |
| `userId (user_id)` | `String` | Yes | - | ID of the authenticated user account. |
| `startedAt (started_at)` | [`DateTime?`](../shared/scalars.md#datetime) | No | - | UTC timestamp when the participant started the study. |
| `selectedInterventionIds (selected_intervention_ids)` | `List<String>` | Yes | - | Ordered list of intervention IDs assigned to this participant. |
| `inviteCode (invite_code)` | `String?` | No | - | Invite code used to enrol, if any. |
| `isDeleted (is_deleted)` | `bool` | No | `false` | Whether this subject has been soft-deleted. |
<!-- GENERATED:FIELDS END -->

## Notes

- `StudySubject` documents enrolment rows stored by Supabase. These rows are runtime state, not portable study-definition JSON exported from the designer.
