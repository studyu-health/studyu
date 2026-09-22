# Questionnaire Nested Objects

## Description

Questionnaire nested objects are small JSON objects used inside question payloads. They are not
standalone tasks or questions.

## Choice

Use `Choice` objects in `ChoiceQuestion.choices`.

```json
{
  "id": "choice-yes",
  "text": "Yes"
}
```

- `id`: stable value stored in answers and conditions.
- `text`: label shown to participants.

## Annotation

Use `Annotation` objects in scale questions that need labelled values.

```json
{
  "value": 1,
  "annotation": "low"
}
```

- `value`: numeric scale value receiving the label.
- `annotation`: label shown for that value.

<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | `String` | Yes | - | Unique choice identifier used in choice answers. |
| `text` | `String` | No | `''` | Participant-facing choice label. |
| `value` | `int` | No | `0` | Numeric scale value that receives an annotation. |
| `annotation` | `String` | No | `''` | Label shown for the annotated scale value. |
<!-- GENERATED:FIELDS END -->
