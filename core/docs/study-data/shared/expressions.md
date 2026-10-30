# Expressions

## Description

`Expression` documents condition payloads used by eligibility and question visibility rules.

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `boolean`, `choice`, `not`, `numeric`, `text` |
<!-- GENERATED:DISCRIMINATORS END -->

## Notes

- `CompositeExpression` is not dispatchable through `Expression.fromJson`. Do not use it in study JSON until the dispatcher maps it.
