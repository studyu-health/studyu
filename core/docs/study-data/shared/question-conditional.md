# Question Conditional

## Description

`QuestionConditional` controls whether a question is shown and can provide a default answer value.

Use it in a question's `conditional` field. The `condition` object is a composite expression.

## JSON shape

```json
{
  "condition": {
    "type": "composite",
    "logicType": "and",
    "expressions": [
      {
        "type": "boolean",
        "target": "consent-confirmed"
      }
    ]
  },
  "defaultValue": true
}
```

- `condition`: required composite expression.
- `defaultValue`: optional value used as the initial answer when the question appears.

## Notes

- `target` values inside expressions are question IDs.
- A missing answer evaluates to `null`; question visibility only hides the question when the
  condition evaluates to `false`.
- Single legacy expression objects can be read, but new JSON should use a composite expression.

<!-- GENERATED:DISCRIMINATORS START -->

| Field  | Value(s)                                                   |
|--------|------------------------------------------------------------|
| `type` | `boolean`, `choice`, `composite`, `not`, `numeric`, `text` |

<!-- GENERATED:DISCRIMINATORS END -->
