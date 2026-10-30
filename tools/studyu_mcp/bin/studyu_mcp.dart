import 'dart:convert';

import 'package:mcp_server/mcp_server.dart';
import 'package:studyu_mcp/ui/app/app_mcp_tools.dart';
import 'package:studyu_mcp/ui/app/app_ui_driver.dart';
import 'package:studyu_mcp/ui/app/app_ui_flow.dart';
import 'package:studyu_mcp/ui/designer/designer_ui_screen.dart';
import 'package:studyu_mcp/ui/vm_service_ui_driver.dart';
import 'package:studyu_mcp/validation_tools.dart';

Future<void> main() async {
  final server = Server(
    name: 'studyu',
    version: '0.1.0',
    capabilities: ServerCapabilities.simple(tools: true),
  );
  final driver = StudyUUiDriver(
    screenKeys: {...StudyUAppKey.all, ...StudyUDesignerKey.all},
    inferScreen: _inferScreen,
  );
  final appDriver = StudyUAppUiDriver(driver);

  server.addTool(
    name: 'connect',
    description:
        'Connect to a running StudyU App or Designer Flutter process started with lib/driver_main.dart.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'vmServiceUri': {
          'type': 'string',
          'description':
              'VM service WebSocket URI, for example ws://127.0.0.1:12345/abc=/ws. Defaults to STUDYU_UI_VM_SERVICE_URI or STUDYU_APP_VM_SERVICE_URI.',
        },
      },
    },
    handler: (arguments) async {
      await driver.connect(arguments['vmServiceUri'] as String?);
      return _jsonResult({'connected': true});
    },
  );

  addStudyUAppTools(server, appDriver);
  addStudyValidationTools(server);
  _addGeneralUiTools(server, driver);

  final transportResult = McpServer.createStdioTransport();
  final transport = transportResult.get();
  server.connect(transport);
  await transport.onClose;
}

void _addGeneralUiTools(Server server, StudyUUiDriver driver) {
  server.addTool(
    name: 'read_screen',
    description:
        'Return a compact non-visual screen snapshot inferred from visible ValueKeys.',
    inputSchema: {'type': 'object', 'properties': {}},
    handler: (_) async {
      final snapshot = await driver.readScreen();
      return _jsonResult(snapshot.toJson());
    },
  );

  server.addTool(
    name: 'tap_by_key',
    description:
        'Tap a visible widget by String ValueKey. Works for App and Designer.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'key': {'type': 'string'},
      },
      'required': ['key'],
    },
    handler: (arguments) async {
      final key = arguments['key'] as String;
      await driver.tapByValueKey(key);
      return _jsonResult({'tapped': key});
    },
  );

  server.addTool(
    name: 'enter_text_by_key',
    description:
        'Focus a text field by String ValueKey and enter text. Works for App and Designer.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'key': {'type': 'string'},
        'text': {'type': 'string'},
      },
      'required': ['key', 'text'],
    },
    handler: (arguments) async {
      final key = arguments['key'] as String;
      final text = arguments['text'] as String;
      await driver.enterTextByValueKey(key, text);
      return _jsonResult({'enteredTextInto': key});
    },
  );
}

CallToolResult _jsonResult(Map<String, Object?> value) => CallToolResult(
  content: [
    TextContent(text: const JsonEncoder.withIndent('  ').convert(value)),
  ],
);

String _inferScreen(Set<String> keys) {
  final appScreen = inferStudyUAppScreen(keys);
  if (appScreen != StudyUAppScreen.unknown) return appScreen;
  return inferStudyUDesignerScreen(keys) ?? StudyUAppScreen.unknown;
}
