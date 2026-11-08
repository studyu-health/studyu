# Scalar Formats

## Description

Scalar fields use plain JSON strings or numbers. Do not copy Dart object syntax into study JSON.

## DateTime

Use ISO-8601 strings.

```json
"2026-07-01T09:00:00.000Z"
```

## Time of day

Use `H:mm` or `HH:mm` strings for `StudyUTimeOfDay` values.

```json
"8:00"
```

```json
"18:30"
```

## Color integers

Color fields store ARGB integers. In strict JSON, use decimal numbers.

```json
4278190335
```

The Dart literal `0xFF0000FF` represents the same value, but JSON files should use decimal numbers.

## IDs

IDs are strings. UUIDs are recommended for generated study content, but stable human-readable IDs
can be useful in hand-authored examples.
