import 'dart:convert';

const String previewSessionRequestType = 'previewSessionRequest';
const String previewSessionType = 'previewSession';

String createPreviewSessionRequest() =>
    jsonEncode(const {'type': previewSessionRequestType});

String createPreviewSessionMessage(String session) =>
    jsonEncode({'type': previewSessionType, 'session': session});

bool isPreviewSessionRequest(Object? data) {
  final message = _decodeMessage(data);
  return message != null &&
      message.length == 1 &&
      message['type'] == previewSessionRequestType;
}

String? parsePreviewSession(Object? data) {
  final message = _decodeMessage(data);
  if (message == null ||
      message.length != 2 ||
      message['type'] != previewSessionType ||
      message['session'] is! String) {
    return null;
  }

  final session = message['session'] as String;
  return session.isEmpty ? null : session;
}

Map<String, dynamic>? _decodeMessage(Object? data) {
  if (data is! String) return null;

  try {
    final decoded = jsonDecode(data);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}
