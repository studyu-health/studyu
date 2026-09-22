import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/studyu_driver_state.dart';
import 'package:studyu_core/core.dart';

void main() {
  test('visible study data includes typed core validation results', () async {
    StudyUDriverState.visibleStudies = [Study('study-id', 'user-id')];

    final response = jsonDecode(
      await StudyUDriverState.handleRequest('visibleStudies'),
    ) as Map<String, dynamic>;
    final study = (response['studies'] as List).single as Map<String, dynamic>;
    final validation = study['validation'] as Map<String, dynamic>;

    expect((validation['draft'] as Map<String, dynamic>)['valid'], isFalse);
    expect(
      ((validation['draft'] as Map<String, dynamic>)['errors'] as List)
          .cast<Map<String, dynamic>>()
          .map((error) => error['code']),
      contains('study_info.title_required'),
    );
    expect(validation['publish'], isA<Map<String, dynamic>>());
  });
}
