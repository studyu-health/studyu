import 'dart:convert';
import 'dart:io';

import 'package:studyu_mcp/validation_tools.dart';
import 'package:test/test.dart';

void main() {
  test('validates JSON through the validator adapter', () {
    final study =
        jsonDecode(
              File(
                '../studyu_validator/test/fixtures/valid_study.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    study['title'] = '';

    final result = validateStudyJson({
      'json': jsonEncode(study),
      'level': 'publish',
      'section': 'study_info',
    });

    expect(result['valid'], isFalse);
    expect(
      (result['errors'] as List).cast<Map<String, dynamic>>().map(
        (error) => error['code'],
      ),
      contains('study_info.title_required'),
    );
  });

  test('reports malformed JSON', () {
    final result = validateStudyJson({'json': '{'});

    expect(result['valid'], isFalse);
    expect(
      ((result['errors'] as List).single as Map<String, dynamic>)['code'],
      'PARSE_ERROR',
    );
  });
}
