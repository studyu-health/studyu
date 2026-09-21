import 'dart:convert';

const String previewStudyRequestType = 'previewStudyRequest';
const String previewStudyType = 'previewStudy';

String createPreviewStudyRequest() =>
    jsonEncode(const {'type': previewStudyRequestType});

String createPreviewStudyMessage(String study) =>
    jsonEncode({'type': previewStudyType, 'study': study});

bool isPreviewStudyRequest(Object? data) {
  final message = _decodeMessage(data);
  return message != null &&
      message.length == 1 &&
      message['type'] == previewStudyRequestType;
}

String? parsePreviewStudy(Object? data) {
  final message = _decodeMessage(data);
  if (message == null ||
      message.length != 2 ||
      message['type'] != previewStudyType ||
      message['study'] is! String) {
    return null;
  }

  final study = message['study'] as String;
  return study.isEmpty ? null : study;
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
