# UI MCP tools

The UI MCP tools drive a running StudyU Flutter app through the Flutter Driver service extension.
They do not use screenshots. They inspect known `ValueKey` widgets and call Flutter Driver commands
through the VM service.

## Start a driver-enabled app

Participant app:

```bash
fvm exec melos run local:app:driver
```

Designer v2:

```bash
fvm exec melos run local:designer_v2:driver
```

Flutter prints a VM service URI:

```text
ws://127.0.0.1:<port>/<token>/ws
```

Set it before starting the MCP server:

```bash
export STUDYU_UI_VM_SERVICE_URI='ws://127.0.0.1:<port>/<token>/ws'
fvm exec melos run mcp:studyu
```

You can also pass the URI to the `connect` tool. Connections are restricted to
`localhost`, `127.0.0.1`, and `::1`.

## Study validation tool

### `validate_study_json`

Validates a JSON string with the standalone StudyU schema and typed core
validators. `level` defaults to `draft`; `section` is optional.

```json
{
  "json": "{...}",
  "level": "publish",
  "section": "observations"
}
```

## General UI tools

### `connect`

Connects the MCP server to a running app or Designer v2 process.

Input:

```json
{
  "vmServiceUri": "ws://127.0.0.1:<port>/<token>/ws"
}
```

`vmServiceUri` is optional when `STUDYU_UI_VM_SERVICE_URI` is set.

### `read_screen`

Returns a compact screen snapshot inferred from visible `ValueKey`s.

Example output:

```json
{
  "screen": "StudySelectionScreen",
  "visibleKeys": [
    "study_selection_invite_code",
    "study_selection_list"
  ]
}
```

### `tap_by_key`

Taps a visible widget by String `ValueKey`.

Input:

```json
{
  "key": "login_button"
}
```

### `enter_text_by_key`

Focuses a text field by String `ValueKey` and enters text.

Input:

```json
{
  "key": "login_email",
  "text": "user1@studyu.health"
}
```

## Participant app tools

### `app_complete_onboarding_to_study_list`

Runs the participant app onboarding and legal flow until the study list appears. Returns the visible
study list.

Input:

```json
{
  "vmServiceUri": "ws://127.0.0.1:<port>/<token>/ws"
}
```

`vmServiceUri` is optional when the MCP server is connected.

Example output:

```json
{
  "screen": "StudySelectionScreen",
  "studies": [
    {
      "id": "...",
      "title": "Public demo study of user1",
      "description": "This is a Demo Study.",
      "status": "running",
      "participation": "open",
      "registryPublished": true,
      "validation": {
        "draft": {"valid": true, "errors": [], "warnings": []},
        "publish": {"valid": true, "errors": [], "warnings": []}
      }
    }
  ]
}
```

### `app_get_visible_studies`

Returns the current study list. Use it only when the app is already on `StudySelectionScreen`.

### `app_recover_state`

Attempts to recover the app to `StudySelectionScreen`, then returns the screen snapshot and visible
studies.

Current recovery behavior:

- `OnboardingScreen`: taps through onboarding.
- `WelcomeScreen`: opens the legal flow.
- `TermsScreen`: accepts terms and privacy.
- `StudySelectionScreen`: returns without navigation.
- `StudyOverviewScreen`: fails with a state error because recovery would require back navigation.

### `app_open_study`

Opens one visible app study by id.

Input:

```json
{
  "studyId": "<study-id>"
}
```

## Designer v2 support

Current Designer v2 support covers general UI primitives:

- `read_screen`
- `tap_by_key`
- `enter_text_by_key`

Known Designer v2 screen inference:

- `DesignerLoginScreen`
- `DesignerStudiesScreen`
- `DesignerStudyEditorScreen`

Designer-specific MCP tools should live under `lib/ui/designer/` when added.

## Integration test reuse

App integration tests can reuse the same app flow without MCP:

```dart
import 'package:studyu_mcp/ui/app/app_ui_flow.dart';

final flow = StudyUAppUiFlow(
  waitForKey: (key, {required timeout}) =>
      tester.waitForValueKey(
        key,
        timeout: timeout,
      ),
  tapKey: tester.tapValueKey,
);

await flow.completeOnboardingToStudyList();
```
