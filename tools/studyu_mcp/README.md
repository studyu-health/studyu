# StudyU MCP

StudyU MCP contains automation tools for StudyU development workflows.

Current scope:

- UI automation for the participant app and Designer v2 through Flutter Driver / VM service.
- Reusable UI flow helpers for integration tests.
- MCP tools for LLM-driven app navigation.
- Study JSON validation backed by the standalone validator and typed core checks.

Planned scope:

- Study creation helpers.
- Combined study creation and UI testing workflows.

## Package layout

```text
tools/studyu_mcp/
  bin/
    studyu_mcp.dart              # MCP server entrypoint
  lib/
    validation_tools.dart        # Study JSON validation MCP tool
    ui/
      ui_driver.dart             # General UI contracts
      vm_service_ui_driver.dart  # Flutter Driver / VM service adapter
      app/                       # Participant app-specific UI tools
      designer/                  # Designer v2-specific UI tools
```

## Run the MCP server

From the repository root:

```bash
fvm exec melos run mcp:studyu
```

Or directly:

```bash
cd tools/studyu_mcp
fvm dart run bin/studyu_mcp.dart
```

## Connect to a running Flutter app

Start a driver-enabled app first.

Participant app:

```bash
fvm exec melos run local:app:driver
```

Designer v2:

```bash
fvm exec melos run local:designer_v2:driver
```

Copy the VM service WebSocket URI from Flutter output:

```text
ws://127.0.0.1:<port>/<token>/ws
```

Then provide it to the MCP server through one of these paths:

- Set `STUDYU_UI_VM_SERVICE_URI` before starting the MCP server.
- Pass `vmServiceUri` to the `connect` MCP tool.

Example:

```bash
export STUDYU_UI_VM_SERVICE_URI='ws://127.0.0.1:<port>/<token>/ws'
fvm exec melos run mcp:studyu
```

## Docs

- [UI MCP tools](docs/ui-mcp.md)
