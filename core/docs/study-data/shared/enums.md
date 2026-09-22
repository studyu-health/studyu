# Enum Values

## Description

Enum fields must use the exact JSON values listed here. Case matters.

## DateInputType

| Value      | Meaning        |
|------------|----------------|
| `date`     | Date only.     |
| `time`     | Time only.     |
| `dateTime` | Date and time. |

## DateFormatPreset

| Value      | Meaning                |
|------------|------------------------|
| `iso`      | ISO date display.      |
| `european` | European date display. |
| `us`       | US date display.       |
| `german`   | German date display.   |

## TimeFormatPreset

| Value | Meaning                  |
|-------|--------------------------|
| `h24` | 24-hour time.            |
| `h12` | 12-hour time with AM/PM. |

## DefaultDateOption

| Value      | Meaning                                             |
|------------|-----------------------------------------------------|
| `none`     | No default.                                         |
| `today`    | Current date.                                       |
| `now`      | Current date-time or time.                          |
| `specific` | Use `defaultSpecificDate` or `defaultSpecificTime`. |

## FreeTextQuestionType

| Value          | Meaning                               |
|----------------|---------------------------------------|
| `any`          | Any text.                             |
| `alphanumeric` | Letters and digits only.              |
| `numeric`      | Numeric text only.                    |
| `custom`       | Validate with `customTypeExpression`. |

## FitbitQuestionType

| Value       | Meaning          |
|-------------|------------------|
| `heartrate` | Heart rate data. |
| `sleep`     | Sleep data.      |
| `steps`     | Step count data. |

## PhaseSequence

| Value             | Meaning                                    |
|-------------------|--------------------------------------------|
| `alternating`     | Alternating A/B phases.                    |
| `counterBalanced` | Alternates AB and BA order across cycles.  |
| `randomized`      | Randomizes after the first cycle.          |
| `customized`      | Uses `sequenceCustom`, for example `ABAB`. |

## TemporalAggregation

| Value          | Meaning                          |
|----------------|----------------------------------|
| `day`          | Aggregate by day.                |
| `phase`        | Aggregate by intervention phase. |
| `intervention` | Aggregate by intervention.       |

## ImprovementDirection

| Value      | Meaning                             |
|------------|-------------------------------------|
| `positive` | Higher values count as improvement. |
| `negative` | Lower values count as improvement.  |
