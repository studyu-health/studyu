import 'dart:convert';

import 'package:mcp_server/mcp_server.dart';
import 'package:studyu_validator/studyu_validator.dart' as validator;

void addStudyValidationTools(Server server) {
  server.addTool(
    name: 'validate_study_json',
    description:
        'Validate StudyU study JSON against the standalone schema and typed core validators.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'json': {'type': 'string'},
        'level': {
          'type': 'string',
          'enum': ['draft', 'publish'],
          'default': 'draft',
        },
        'section': {
          'type': 'string',
          'enum': const [
            'study_info',
            'interventions',
            'questionnaire',
            'schedule',
            'consent',
            'observations',
            'report',
            'eligibility',
          ],
        },
      },
      'required': ['json'],
    },
    handler: (arguments) async => CallToolResult(
      content: [
        TextContent(
          text: const JsonEncoder.withIndent(
            ' ',
          ).convert(validateStudyJson(arguments)),
        ),
      ],
    ),
  );
}

Map<String, dynamic> validateStudyJson(Map<String, dynamic> arguments) =>
    validator.validateJson(
      arguments['json'] as String,
      level: arguments['level'] as String? ?? 'draft',
      section: arguments['section'] as String?,
    );
