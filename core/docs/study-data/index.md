# Study Data Reference

## Description

Study data docs describe the JSON-serialisable models used to define, schedule, run, and report a StudyU study.

## Minimal Study JSON

This example defines one invite-only study with one consent item, one intervention arm, one scheduled questionnaire observation, one conditional question, one numeric result, and one report section.

```json
{
  "id": "study-minimal",
  "title": "Minimal mood study",
  "description": "Daily mood tracking with one reminder window.",
  "user_id": "researcher-user-id",
  "participation": "invite",
  "result_sharing": "private",
  "contact": {"email": "researcher@example.org"},
  "status": "draft",
  "consent": [
    {
      "id": "consent-main",
      "title": "Consent",
      "description": "I agree to participate."
    }
  ],
  "interventions": [
    {
      "type": "intervention",
      "id": "arm-a",
      "name": "Daily reflection",
      "description": "Participants complete one short daily check-in.",
      "icon": "editNote",
      "tasks": [
        {
          "type": "checkmark",
          "id": "reflection-checkmark",
          "title": "Complete reflection",
          "schedule": {
            "completionPeriods": [
              {"id": "evening", "unlockTime": "18:00", "lockTime": "22:00"}
            ],
            "reminders": ["19:00"]
          }
        }
      ]
    }
  ],
  "observations": [
    {
      "type": "questionnaire",
      "id": "daily-mood-task",
      "title": "Daily mood",
      "schedule": {
        "completionPeriods": [
          {"id": "evening", "unlockTime": "18:00", "lockTime": "22:00"}
        ],
        "reminders": ["19:00"]
      },
      "questions": [
        {"type": "boolean", "id": "had-good-day", "prompt": "Did you have a good day?"},
        {
          "type": "scale",
          "id": "mood-score",
          "prompt": "How was your mood today?",
          "minimum": 1,
          "maximum": 5,
          "step": 1,
          "conditional": {
            "condition": {
              "type": "composite",
              "logicType": "and",
              "expressions": [{"type": "boolean", "target": "had-good-day"}]
            }
          }
        }
      ]
    }
  ],
  "schedule": {
    "numberOfCycles": 1,
    "phaseDuration": 7,
    "includeBaseline": false,
    "sequence": "alternating",
    "sequenceCustom": "ABAB"
  },
  "results": [
    {
      "type": "numeric",
      "id": "mood-result",
      "filename": "mood.csv",
      "resultProperty": {"task": "daily-mood-task", "property": "mood-score"}
    }
  ],
  "report_specification": {
    "primary": {
      "type": "average",
      "id": "mood-average",
      "title": "Average mood",
      "description": "Average mood by study day.",
      "aggregate": "day",
      "resultProperty": {"task": "daily-mood-task", "property": "mood-score"}
    },
    "secondary": []
  }
}
```

`DataReference.task` points to a task ID. `DataReference.property` points to a question ID inside that task.

## Pages

### interventions
- [Checkmark Task](interventions/checkmark-task.md)
- [Intervention](interventions/intervention.md)

### invites
- [Study Invite](invites/study-invite.md)

### observations
- [Questionnaire Task](observations/questionnaire-task.md)

### participants
- [Study Subject](participants/study-subject.md)
- [Subject Progress](participants/subject-progress.md)

### questionnaire
- [Index](questionnaire/index.md)
- [Nested Objects](questionnaire/nested-objects.md)

### questionnaire/question-types
- [Annotated Scale](questionnaire/question-types/annotated-scale.md)
- [Audio Recording](questionnaire/question-types/audio-recording.md)
- [Body Pain](questionnaire/question-types/body-pain.md)
- [Boolean](questionnaire/question-types/boolean.md)
- [Choice](questionnaire/question-types/choice.md)
- [Date](questionnaire/question-types/date.md)
- [Fitbit](questionnaire/question-types/fitbit.md)
- [Free Text](questionnaire/question-types/free-text.md)
- [Image Capturing](questionnaire/question-types/image-capturing.md)
- [Pain](questionnaire/question-types/pain.md)
- [Scale](questionnaire/question-types/scale.md)
- [Visual Analogue](questionnaire/question-types/visual-analogue.md)

### reports
- [Report Specification](reports/report-specification.md)

### reports/sections
- [Average](reports/sections/average.md)
- [Descriptive Stats](reports/sections/descriptive-stats.md)
- [Gauge Comparison](reports/sections/gauge-comparison.md)
- [Linear Regression](reports/sections/linear-regression.md)
- [Textual Summary](reports/sections/textual-summary.md)

### results
- [Intervention Result](results/intervention-result.md)
- [Numeric Result](results/numeric-result.md)

### schedules
- [Study Schedule](schedules/study-schedule.md)
- [Task Schedule](schedules/task-schedule.md)

### shared
- [Data Reference](shared/data-reference.md)
- [Enums](shared/enums.md)
- [Expressions](shared/expressions.md)
- [Question Conditional](shared/question-conditional.md)
- [Scalars](shared/scalars.md)

### study
- [Consent](study/consent.md)
- [Contact](study/contact.md)
- [Eligibility](study/eligibility.md)
- [Index](study/index.md)

