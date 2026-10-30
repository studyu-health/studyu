# Body Pain Models

## Description

Body pain models describe pain locations and intensity values used by pain questions.

### BodyPain

<!-- GENERATED:FIELDS START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `painLevel` | `int` | Yes | `0` | Numeric pain intensity value for a body part. |
| `type` | [`PainType?`](body-pain.md) | No | - | Pain type identifier string. |
<!-- GENERATED:FIELDS END -->

### BodyPart

<!-- GENERATED:FIELDS:BodyPart START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | `String` | Yes | - | Unique identifier. |
| `name` | `String` | Yes | - | Display name of the body part or pain type. |
| `pain` | [`BodyPain`](body-pain.md) | Yes | - | Pain record associated with a body region. |
| `children` | [`List<BodyPart>`](body-pain.md) | Yes | `const []` | Child body parts nested within this body region. |
<!-- GENERATED:FIELDS:BodyPart END -->

### Body

<!-- GENERATED:FIELDS:Body START -->
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `parts` | [`List<BodyPart>`](body-pain.md) | Yes | `const []` | List of body parts making up this body model. |
<!-- GENERATED:FIELDS:Body END -->

### PainType

<!-- GENERATED:FIELDS:PainType START -->
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `String` | Yes | Display name of the body part or pain type. |
<!-- GENERATED:FIELDS:PainType END -->
