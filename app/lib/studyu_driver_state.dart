import 'dart:convert';

import 'package:studyu_core/core.dart';

class StudyUDriverState {
  StudyUDriverState._();

  static List<Study> visibleStudies = [];

  static Future<String> handleRequest(String? message) async {
    switch (message) {
      case 'visibleStudies':
        return jsonEncode({
          'studies': visibleStudies.map(_studyToJson).toList(),
        });
      default:
        return jsonEncode({
          'error': 'Unsupported StudyU driver request',
          'message': message,
          'supportedMessages': ['visibleStudies'],
        });
    }
  }

  static Map<String, Object?> _studyToJson(Study study) => {
    'id': study.id,
    'title': study.title,
    'description': study.description,
    'status': study.status.name,
    'participation': study.participation.name,
    'registryPublished': study.registryPublished,
    'validation': {
      'draft': validateStudy(study, ValidationLevel.draft).toJson(),
      'publish': validateStudy(study, ValidationLevel.publish).toJson(),
    },
  };
}
