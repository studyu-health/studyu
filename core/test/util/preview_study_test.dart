import 'dart:convert';

import 'package:studyu_core/src/util/preview_study.dart';
import 'package:test/test.dart';

void main() {
  test('preview study handshake accepts only the exact message shape', () {
    const study = '{"id":"study"}';

    expect(isPreviewStudyRequest(createPreviewStudyRequest()), isTrue);
    expect(
      isPreviewStudyRequest('{"type":"previewStudyRequest","unexpected":true}'),
      isFalse,
    );
    expect(parsePreviewStudy(createPreviewStudyMessage(study)), study);
    expect(
      parsePreviewStudy(
        jsonEncode({'type': previewStudyType, 'study': study, 'extra': true}),
      ),
      isNull,
    );
    expect(parsePreviewStudy('{"type":"previewStudy","study":1}'), isNull);
    expect(parsePreviewStudy('{"type":"previewStudy","study":""}'), isNull);
  });
}
