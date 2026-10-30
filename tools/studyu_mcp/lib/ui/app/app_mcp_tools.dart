import 'dart:convert';

import 'package:mcp_server/mcp_server.dart';
import 'package:studyu_mcp/ui/app/app_ui_driver.dart';
import 'package:studyu_mcp/ui/app/app_ui_flow.dart';

void addStudyUAppTools(Server server, StudyUAppUiDriver appDriver) {
  server.addTool(
    name: 'app_complete_onboarding_to_study_list',
    description:
        'Navigate the StudyU App onboarding/legal flow to StudySelectionScreen, then return the dynamic study list.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'vmServiceUri': {
          'type': 'string',
          'description':
              'Optional VM service WebSocket URI. If omitted, uses existing connection, STUDYU_UI_VM_SERVICE_URI, or STUDYU_APP_VM_SERVICE_URI.',
        },
      },
    },
    handler: (arguments) async {
      await appDriver.connect(arguments['vmServiceUri'] as String?);
      final studies = await appDriver.completeOnboardingToStudyList();
      return _jsonResult({
        'screen': StudyUAppScreen.studySelection,
        'studies': studies,
      });
    },
  );

  server.addTool(
    name: 'app_get_visible_studies',
    description:
        'Return studies currently visible on StudySelectionScreen as structured JSON for LLM selection.',
    inputSchema: {'type': 'object', 'properties': {}},
    handler: (_) async {
      final studies = await appDriver.visibleStudies();
      return _jsonResult({
        'screen': StudyUAppScreen.studySelection,
        'studies': studies,
      });
    },
  );

  server.addTool(
    name: 'app_recover_state',
    description:
        'Read current app state and recover to StudySelectionScreen when possible.',
    inputSchema: {'type': 'object', 'properties': {}},
    handler: (_) async {
      final studies = await appDriver.completeOnboardingToStudyList();
      final snapshot = await appDriver.readScreen();
      return _jsonResult({...snapshot.toJson(), 'studies': studies});
    },
  );

  server.addTool(
    name: 'app_open_study',
    description: 'Open one visible StudyU App study by its study id.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'studyId': {'type': 'string'},
      },
      'required': ['studyId'],
    },
    handler: (arguments) async {
      final studyId = arguments['studyId'] as String;
      await appDriver.openStudy(studyId);
      return _jsonResult({
        'screen': StudyUAppScreen.studyOverview,
        'studyId': studyId,
      });
    },
  );
}

CallToolResult _jsonResult(Map<String, Object?> value) => CallToolResult(
  content: [
    TextContent(text: const JsonEncoder.withIndent('  ').convert(value)),
  ],
);
