# M3 token → Flutter theme mapping

Handwritten. Maps Material 3 color/type/shape/elevation roles to Flutter theme lookups. StudyU
specifics are for `designer_v2/lib/theme.dart` (the full theme) and `app/lib/theme.dart` (minimal).

## Color roles

| M3 role | Flutter lookup | StudyU notes |
|---|---|---|
| primary | `Theme.of(context).colorScheme.primary` | `ThemeProvider` seeds from `ThemeSettings.sourceColor`; dynamic color can override `primary` |
| on-primary | `.onPrimary` | — |
| primary-container / on-primary-container | `.primaryContainer` / `.onPrimaryContainer` | used for scaffold tint (`scaffoldBackgroundColor: primaryContainer @ 15%`) |
| secondary / on-secondary | `.secondary` / `.onSecondary` | `modalBarrierColor` = secondary @ 40% |
| secondary-container | `.secondaryContainer` | `containerColor` = secondaryContainer @ 30% |
| tertiary | `.tertiary` | — |
| surface / on-surface | `.surface` / `.onSurface` | `AuthScaffold` left panel uses `surface`; participant app does NOT seed |
| surface-variant / on-surface-variant | `.surfaceVariant` / `.onSurfaceVariant` | muted text, tab unselected label |
| surface-container-* | `.surfaceContainerLowest/Low/High/Highest` | bottom nav background = `surfaceContainerHighest` |
| error / on-error | `.error` / `.onError` | input error border |
| outline / outline-variant | `.outline` / `.outlineVariant` | — |

StudyU has a `CustomColor`/`linkColor` mechanism (`theme.dart` `linkColor = Color(0xFF00B0FF)`,
`blend` harmonization). Links are the exception where a brand color is intentional — but `Hyperlink`
still defaults to raw `0xFF0000EE` (see deviations).

## Text roles (type scale)

M3 type scale has 15 styles: display-large/medium/small, headline-*, title-*, body-*, label-*.

| M3 style | Flutter lookup |
|---|---|
| display-large / medium / small | `textTheme.displayLarge/Medium/Small` |
| headline-large / medium / small | `textTheme.headlineLarge/Medium/Small` |
| title-large / medium / small | `textTheme.titleLarge/Medium/Small` |
| body-large / medium / small | `textTheme.bodyLarge/Medium/Small` |
| label-large / medium / small | `textTheme.labelLarge/Medium/Small` |

StudyU **deviation**: `designer_v2/lib/theme.dart` `textTheme()` hand-sets sizes that collide with
M3 — `bodyLarge` 14 (M3 16), `titleMedium` 14 (M3 16), `displaySmall` 26 (M3 36). Do not treat the
StudyU sizes as M3 sizes; when M3 guidance cites a style, use the M3 name and accept that StudyU's
pixel values differ until the theme migrates. The open `TODO: migrate to 2021 term set`
(`theme.dart:337`) tracks this.

## Shape / elevation

| M3 | Flutter |
|---|---|
| Corner scale (0/4/8/12/16/28/…) | theme shape; StudyU `shapeMedium` = radius 8 |
| Elevation | `elevation` params / `ThemeData` elevation shadows |

## Where NOT to read theme

- Participant `app` theme is minimal (`app/lib/theme.dart`): only `primary`/`secondary` seeded to
  `Colors.blue`/`Colors.orange`, one `elevatedButtonTheme`. `textTheme` and most component themes
  are defaults. Do not assume `designer_v2` tokens exist in `app` code.
- Never read `primaryColor`/`accentColor` from a hardcoded constant if `colorScheme` is available.
- Never construct `TextStyle(fontSize: ...)` inline when a `textTheme` style expresses the intent.

## Theme access pattern (StudyU)

```dart
final theme = Theme.of(context);
final colors = theme.colorScheme;
final text = theme.textTheme;
```

In `designer_v2`, prefer `Theme.of(context)` inside widgets; `ThemeConfig` static helpers
(`bodyTextMuted`, `bodyTextBackground`) are fine when they encode a shared intent, but they are
StudyU-owned text styles — treat them as tokens, not as a substitute for `colorScheme`.
