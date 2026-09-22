# Study Schedule

## Description

`StudySchedule` defines phase length, baseline use, and intervention order.


<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `numberOfCycles` | `int` | No | `2` | How many A/B cycles the study runs. |
| `phaseDuration` | `int` | No | `7` | Length of each intervention phase in days. |
| `includeBaseline` | `bool` | No | `true` | Whether a baseline phase precedes the first intervention. |
| `sequence` | [`PhaseSequence`](../shared/enums.md#phasesequence) | No | `PhaseSequence.alternating` | Phase ordering strategy. One of `alternating`, `counterBalanced`, `randomized`, `customized`. |
| `sequenceCustom` | `String` | Yes | `'ABAB'` | Custom phase sequence string (e.g. `AABB`). Only used when `sequence` is `customized`. |
<!-- GENERATED:FIELDS END -->
