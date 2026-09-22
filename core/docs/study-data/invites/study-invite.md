# Study Invite

## Description

`StudyInvite` stores invite-only enrolment codes and optional preselected interventions.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `code` | `String` | Yes | Invite code participants enter to enrol. |
| `studyId (study_id)` | `String` | Yes | ID of the study this invite belongs to. |
| `preselectedInterventionIds (preselected_intervention_ids)` | `List<String>?` | No | Optional list of intervention IDs pre-assigned to the invited participant. |
<!-- GENERATED:FIELDS END -->
