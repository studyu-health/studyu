# M3 component → Flutter widget mapping (direct)

Handwritten. Maps Material 3 components to the Flutter widget that implements them, and notes the
StudyU convention where one exists (see `../studyu/existing-patterns.md`). This list is only the
1:1-ish cases; composition cases live in `layout-mapping.md`.

## Buttons

| M3 component | Flutter widget | StudyU convention |
|---|---|---|
| Filled button (primary emphasis) | `FilledButton` | `PrimaryButton` (currently wraps `ElevatedButton` — see deviations) |
| Elevated button | `ElevatedButton` | — |
| Filled tonal button | `FilledButton` + `FilledButtonThemeData` tonal style, or `FilledButton.styleFrom` | — |
| Outlined button | `OutlinedButton` | `SecondaryButton` |
| Text button | `TextButton` | `Hyperlink` for text links; `TextButton` for in-bar actions |
| Icon button | `IconButton` | — |
| Filled icon button | `IconButton.filled` | — |
| Outlined icon button | `IconButton.outlined` | — |
| Segmented button | `SegmentedButton` | — |
| Floating action button | `FloatingActionButton` | — |
| Extended FAB | `FloatingActionButton.extended` | — |

## Selection & input

| M3 component | Flutter widget | StudyU convention |
|---|---|---|
| Checkbox | `Checkbox` | `ReactiveCheckbox` (reactive_forms) |
| Radio | `Radio` | `RadioListTile` / `FormControlLabel`+`Radio` |
| Switch | `Switch` | `ReactiveSwitch` |
| Slider | `Slider` | `CustomSlider` (questionnaire) |
| Text field (filled/outlined) | `TextField` / `TextFormField` | `EmailTextField`, `PasswordTextField`, `ReactiveTextField` (reactive_forms) |
| Assist/filter/input/suggestion chip | `Chip`, `FilterChip`, `InputChip`, `ActionChip` | — |
| Search | `SearchAnchor` / `SearchBar` | `common_views/search.dart` |
| Date/time picker | `showDatePicker` / `showTimePicker` | — |

## Navigation

| M3 component | Flutter widget | StudyU convention |
|---|---|---|
| Navigation bar (bottom) | `NavigationBar` | currently `BottomNavigationBar` (legacy — see deviations) |
| Navigation rail | `NavigationRail` | `NavigationRailThemeData()` present but empty |
| Navigation drawer | `Drawer` / `NavigationDrawer` | `app_drawer.dart` |
| Tabs | `TabBar` + `TabBarView` | `navbar_tabbed.dart` |
| Top app bar | `AppBar` | themed in `designer_v2/lib/theme.dart` |
| Bottom app bar | `BottomAppBar` | themed |

## Containment & feedback

| M3 component | Flutter widget | StudyU convention |
|---|---|---|
| Card | `Card` | `CardThemeData` in theme; `common_views` study tile etc. |
| List | `ListTile` | `ListTileThemeData` in theme |
| Bottom sheet | `showModalBottomSheet` / `BottomSheet` | `common_views/sidesheet/` |
| Dialog | `AlertDialog` / `showDialog` | `StandardDialog`, `confirmation_dialog.dart` |
| Divider | `Divider` | **StudyU uses `Divider(height: 1)` — deviation** |
| Snackbar | `SnackBar` | themed (`SnackBarThemeData`) |
| Tooltip | `Tooltip` | themed (`TooltipThemeData`) |
| Menu | `MenuAnchor` / `PopupMenuButton` | `action_menu.dart`, `action_popup_menu.dart` |
| Progress | `CircularProgressIndicator` / `LinearProgressIndicator` | `PrimaryButton` loading state |
| Badge | `Badge` | `badge.dart` |

## Rules of thumb

- **Primary action → `FilledButton`** in M3. StudyU wraps this in `PrimaryButton` — reuse that
  wrapper rather than writing a raw `FilledButton`, unless you need a variant it does not cover.
- **Never reach for a custom widget when an M3 component maps to a Flutter widget** — check this
  table and `studyu/existing-patterns.md` first.
- If a StudyU wrapper exists AND represents the same pattern, prefer the wrapper; only fall back to
  the raw Flutter widget when the wrapper's API cannot express the need (then note it in the
  deviations reference, don't silently fork).
- Do not invent a StudyU wrapper around a Flutter widget just to "own" it. Wrappers earn their
  place by adding behavior (loading, form binding, tooltip-on-disabled) — `PrimaryButton` earns it;
  a bare `Card` wrapper would not.
