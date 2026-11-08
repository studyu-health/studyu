# StudyUQuestionnaire

## Description

`StudyUQuestionnaire` groups questions used for eligibility checks, baseline data, or observation tasks.

Use this page as the questionnaire overview. The type table lists the `type` values that dispatch to concrete question payloads.

The app renders `prompt` as HTML. If `rationale` contains text, the app shows an information icon
next to the prompt and opens the rationale in a dialog. Conditional questions evaluate against
answers from earlier visible questions.

Answers store the question ID in `question` and the typed answer in `response`. Choice answers store
choice IDs. Date answers add `responseType: DateTime` and encode the response as an ISO-8601 string.

## Question types

- [Boolean](question-types/boolean.md): asks for a yes or no answer.
- [Choice](question-types/choice.md): asks participants to select one or more configured answers.
- [Scale](question-types/scale.md): records a numeric value on a bounded scale.
- [Annotated scale](question-types/annotated-scale.md): records a numeric scale answer with labelled values.
- [Visual analogue](question-types/visual-analogue.md): records a slider value with endpoint labels and colors.
- [Image capturing](question-types/image-capturing.md): asks participants to submit an image.
- [Audio recording](question-types/audio-recording.md): asks participants to submit an audio recording.
- [Date](question-types/date.md): records a date, time, or combined date-time answer.
- [Free text](question-types/free-text.md): records typed text with optional format limits.
- [Fitbit](question-types/fitbit.md): requests Fitbit data types used by the study.
- [Pain](question-types/pain.md): records pain information through body pain models.


<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `AudioRecordingQuestion`, `FitbitQuestion`, `ImageCapturingQuestion`, `annotatedScale`, `boolean`, `choice`, `date`, `freeText`, `pain`, `scale`, `visualAnalogue` |
<!-- GENERATED:DISCRIMINATORS END -->
