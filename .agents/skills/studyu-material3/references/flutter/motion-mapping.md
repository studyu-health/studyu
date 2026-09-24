# M3 motion → Flutter mapping

Handwritten. Maps Material 3 motion guidance (`references/material/motion.md`) and the Expressive
motion tokens (`references/material/tokens.md`, component-tokens for per-component specs) to Flutter.

## Expressive vs standard easing

| M3 token | Cubic | Flutter |
|---|---|---|
| `MotionEasingEmphasizedAccelerate` | (0.3, 0, 0.8, 0.15) | `Cubic(0.3, 0, 0.8, 0.15)` — no named `Curves` constant (verified 2026-08-24) |
| `MotionEasingEmphasizedDecelerate` | (0.05, 0.7, 0.1, 1) | `Cubic(0.05, 0.7, 0.1, 1)` — no named constant |
| `MotionEasingEmphasized` / `MotionEasingStandard` | (0.2, 0, 0, 1) | `Curves.easeInOutCubicEmphasized` |
| Standard accelerate / decelerate style | — | `Curves.easeInCubic` / `Curves.easeOutCubic` (close approximations) |

Use the emphasized cubic for screen-level transitions and shared containers; standard-style
easing for small in-place changes.

## Durations

M3 Expressive tokens (spring-style names) map to Flutter `Duration` values:

| Token | ms | Use |
|---|---|---|
| `MotionDurationShort1..4` | 50 / 100 / 150 / 200 | small in-place: checkbox, icon, fade |
| `MotionDurationMedium1..4` | 250 / 300 / 350 / 400 | layout changes, expanding surfaces |
| `MotionDurationLong1..4` | 450 / 500 / 550 / 600 | screen transitions, large containers |
| `MotionDurationExtraLong1..4` | 650 / 700 / 800 / 1000 | hero-scale, expressive springs |

Flutter built-in Material widgets already use these defaults — do not override duration/curve
unless you are writing the animation yourself.

## Widget mapping

| M3 pattern | Flutter |
|---|---|
| Fade through (UI swap) | `AnimatedSwitcher` with `FadeTransition` (default M3 page transitions in `ThemeData.pageTransitionsTheme`) |
| Shared axis (forward/back, lateral) | `animations` package `SharedAxisTransition` + a `PageTransitionsBuilder`, or the page route transition theme |
| Container transform (element expands to surface) | `animations` package `OpenContainer` |
| Shared element (hero) | `Hero` |
| Collapse/expand | `AnimatedSize`, `ExpansionTile` |
| Simple state change | `AnimatedContainer`, `AnimatedOpacity`, implicit animated widgets |

Note: the `animations` package is **not currently a dependency** of `app` or `designer_v2`
(verified 2026-08-24). Adding it for a transition is a deliberate dependency change — say so.

## Reduced motion / accessibility

M3 requires honoring reduced-motion preferences. In Flutter:

- `MediaQuery.disableAnimationsOf(context)` — true when the OS asks to reduce motion (verified
  in the Flutter API index 2026-08-24). Long custom animations MUST check this and substitute a
  short fade.
- Built-in Material widgets handle this themselves; the rule applies to hand-rolled
  `AnimationController` work.

## StudyU convention

StudyU currently performs no custom choreographed animation — dialogs, snackbars, and navigation
use widget defaults. Keep it that way: prefer default Material transitions over bespoke curves;
any hand-rolled animation is a new design decision (decision hierarchy level 5).
