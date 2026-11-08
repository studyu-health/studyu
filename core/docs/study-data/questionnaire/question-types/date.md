# Date Question

## Description

`DateQuestion` records a date, time, or combined date-time answer.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `type` | `String` | Yes | - | Fixed value `date`. |
| `id` | `String` | Yes | - | Stable question identifier used by answers, conditions, and data references. |
| `prompt` | `String?` | No | - | Participant-facing question text rendered as HTML in the app. |
| `rationale` | `String?` | No | - | Extra HTML shown behind the question's information icon. |
| `conditional` | [`QuestionConditional<V>?`](../../shared/question-conditional.md) | No | - | Visibility rule evaluated against earlier questionnaire answers. |
| `inputType` | [`DateInputType`](../../shared/enums.md#dateinputtype) | Yes | `DateInputType.date` | Input widget style. One of `date`, `time`, `dateTime`. |
| `minDate` | [`DateTime?`](../../shared/scalars.md#datetime) | No | - | Earliest selectable date when `inputType` includes a date. |
| `maxDate` | [`DateTime?`](../../shared/scalars.md#datetime) | No | - | Latest selectable date when `inputType` includes a date. |
| `minTime` | `String?` | No | - | Earliest selectable time when `inputType` includes a time. |
| `maxTime` | `String?` | No | - | Latest selectable time when `inputType` includes a time. |
| `dateFormatPreset` | [`DateFormatPreset`](../../shared/enums.md#dateformatpreset) | Yes | `DateFormatPreset.iso` | Display format for date values. |
| `timeFormatPreset` | [`TimeFormatPreset`](../../shared/enums.md#timeformatpreset) | Yes | `TimeFormatPreset.h24` | Display format for time values. |
| `defaultOption` | [`DefaultDateOption`](../../shared/enums.md#defaultdateoption) | Yes | `DefaultDateOption.none` | Strategy for the pre-filled value. One of `none`, `today`, `now`, `specific`. |
| `defaultSpecificDate` | [`DateTime?`](../../shared/scalars.md#datetime) | No | - | Date used when `defaultOption` is `specific`. |
| `defaultSpecificTime` | `String?` | No | - | Time used when `defaultOption` is `specific`. |
<!-- GENERATED:FIELDS END -->

<!-- GENERATED:DISCRIMINATORS START -->
| Field | Value(s) |
|-------|---------|
| `type` | `date` |
<!-- GENERATED:DISCRIMINATORS END -->
