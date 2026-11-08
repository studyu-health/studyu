# Study

## Description

`Study` is the root study definition. It links participant-facing content, eligibility, interventions, schedules, and reports.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | `String` | Yes | - | Unique study identifier (UUID). |
| `title` | `String?` | No | - | Display title shown to participants. |
| `description` | `String?` | No | `''` | Long-form description of the study. |
| `userId (user_id)` | `String` | Yes | - | ID of the researcher who owns this study. |
| `participation` | `Participation` | No | `Participation.invite` | Whether the study is open or invite-only. One of `open`, `invite`. |
| `resultSharing (result_sharing)` | `ResultSharing` | No | `ResultSharing.private` | Who can see results. One of `public`, `private`, `organization`. |
| `contact` | [`Contact`](contact.md) | No | `Contact()` | Contact information for the lead researcher. |
| `iconName (icon_name)` | `String` | No | `'accountHeart'` | Material icon name shown in the participant app. |
| `status` | `StudyStatus` | No | `StudyStatus.draft` | Lifecycle state of the study. One of `draft`, `running`, `closed`. |
| `questionnaire` | [`StudyUQuestionnaire`](../questionnaire/index.md) | No | `StudyUQuestionnaire()` | Eligibility and baseline questionnaire configuration. |
| `eligibilityCriteria (eligibility_criteria)` | [`List<EligibilityCriterion>`](eligibility.md) | No | `[]` | List of eligibility rules participants must satisfy. |
| `consent` | [`List<ConsentItem>`](consent.md) | No | `[]` | Consent items participants must acknowledge before enrolling. |
| `interventions` | [`List<Intervention>`](../interventions/intervention.md) | No | `[]` | List of intervention arms in the study. |
| `observations` | [`List<Observation>`](../observations/questionnaire-task.md) | No | `[]` | List of observation tasks (e.g. questionnaires) assigned during the study. |
| `schedule` | [`StudySchedule`](../schedules/study-schedule.md) | No | `StudySchedule()` | Phase and cycle schedule configuration. |
| `reportSpecification (report_specification)` | [`ReportSpecification`](../reports/report-specification.md) | No | `ReportSpecification()` | Report sections shown to participants after the study. |
| `results` | [`List<StudyResult>`](../results/numeric-result.md) | No | `[]` | Study-level result definitions. |
| `collaboratorEmails (collaborator_emails)` | `List<String>` | No | `[]` | Email addresses of co-researchers who can edit the study. |
| `registryPublished (registry_published)` | `bool` | No | `false` | Whether the study is listed in the public registry. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:LINKS START -->
- [Contact](contact.md)
- [Eligibility](eligibility.md)
- [Consent](consent.md)
- [Index](../questionnaire/index.md)
- [Intervention](../interventions/intervention.md)
- [Study Schedule](../schedules/study-schedule.md)
- [Report Specification](../reports/report-specification.md)
<!-- GENERATED:LINKS END -->
