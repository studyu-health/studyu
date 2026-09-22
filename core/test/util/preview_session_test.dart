import 'dart:convert';

import 'package:studyu_core/src/util/preview_session.dart';
import 'package:test/test.dart';

void main() {
  test('preview session handshake accepts only the exact message shape', () {
    const session = '{"access_token":"secret"}';

    expect(isPreviewSessionRequest(createPreviewSessionRequest()), isTrue);
    expect(
      isPreviewSessionRequest(
        '{"type":"previewSessionRequest","unexpected":true}',
      ),
      isFalse,
    );
    expect(parsePreviewSession(createPreviewSessionMessage(session)), session);
    expect(
      parsePreviewSession(
        jsonEncode({
          'type': previewSessionType,
          'session': session,
          'extra': true,
        }),
      ),
      isNull,
    );
    expect(
      parsePreviewSession('{"type":"previewSession","session":1}'),
      isNull,
    );
    expect(
      parsePreviewSession('{"type":"previewSession","session":""}'),
      isNull,
    );
  });
}
