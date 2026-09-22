import 'dart:async';
import 'dart:convert';

import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import "package:universal_html/html.dart" as html;

typedef PreviewNavigationHandler = Future<void> Function(String? route);
typedef PreviewStudyHandler = void Function(Study study);

/// Firebase hosting site that serves the Designer preview channels for PR
/// previews (.firebaserc and .github/workflows/firebase-hosting-pull-request.yml).
const _previewFirebaseDesignerSite = 'studyu-dev-designer';

/// Derives the Designer origin used as the postMessage target and for
/// validating incoming messages. The embedding parent's referrer origin wins
/// only when its host is trusted: the compiled designer host or a
/// [_previewFirebaseDesignerSite] Firebase hosting domain, because Firebase PR
/// previews host the Designer on a preview-channel origin that differs from
/// the compiled [fallbackUrl]. Untrusted referrers fall back to the compiled
/// designer URL. Exposed for testing.
String? deriveDesignerOrigin(String? referrer, String? fallbackUrl) {
  final fallback = _tryParseUrl(fallbackUrl);
  final parent = _tryParseUrl(referrer);
  if (parent != null && _isTrustedDesignerHost(parent, fallback)) {
    return parent.origin;
  }
  return fallback?.origin;
}

Uri? _tryParseUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasScheme && uri.host.isNotEmpty ? uri : null;
}

bool _isTrustedDesignerHost(Uri referrer, Uri? fallback) {
  final host = referrer.host;
  if (fallback != null && referrer.origin == fallback.origin) return true;
  if (referrer.scheme != 'https' ||
      (referrer.hasPort && referrer.port != 443)) {
    return false;
  }

  return RegExp(
    '^$_previewFirebaseDesignerSite(?:--[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)?'
    r'\.(?:web\.app|firebaseapp\.com)$',
  ).hasMatch(host);
}

class IFrameHelper() {
  // The listener must outlive LoadingScreen so loaded preview routes keep
  // receiving live study updates from the Designer.
  static StreamSubscription<html.MessageEvent>? _messageSubscription;
  Completer<Study?>? _previewStudyCompleter;

  String? _designerOrigin() {
    final referrerObject = html.document.referrer as Object?;
    final referrer = referrerObject is String ? referrerObject : null;
    return deriveDesignerOrigin(referrer, env.designerUrl);
  }

  html.WindowBase? _messageTarget() {
    try {
      final parent = html.window.parent;
      if (parent != null && parent != html.window) return parent;
      return html.window.opener;
    } catch (_) {
      return null;
    }
  }

  // Validate by origin only: dart:html wraps `event.source` via
  // `_convertNativeToDart_EventTarget`, so it is never identical to
  // `window.parent`/`window.opener`, even for the genuine sender. The origin
  // check is the postMessage security boundary; `deriveDesignerOrigin`
  // already restricts it to trusted hosts.
  bool _isExpectedMessage(html.MessageEvent event, String designerOrigin) =>
      event.origin == designerOrigin;

  Future<String?> requestPreviewSession() async {
    final parent = _messageTarget();
    final designerOrigin = _designerOrigin();
    if (parent == null || designerOrigin == null) return null;

    final completer = Completer<String?>();
    late final StreamSubscription<html.MessageEvent> subscription;
    subscription = html.window.onMessage.listen((event) {
      if (!_isExpectedMessage(event, designerOrigin)) return;
      final session = parsePreviewSession(event.data);
      if (session != null && !completer.isCompleted) {
        completer.complete(session);
      }
    });

    parent.postMessage(createPreviewSessionRequest(), designerOrigin);
    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      return null;
    } finally {
      await subscription.cancel();
    }
  }

  Future<Study?> requestPreviewStudy() async {
    final parent = _messageTarget();
    final designerOrigin = _designerOrigin();
    if (parent == null || designerOrigin == null) return null;

    final completer = Completer<Study?>();
    _previewStudyCompleter = completer;
    parent.postMessage(createPreviewStudyRequest(), designerOrigin);
    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      return null;
    } finally {
      if (identical(_previewStudyCompleter, completer)) {
        _previewStudyCompleter = null;
      }
    }
  }

  void postPreviewStatus({required String status, String? message}) {
    _postMessage(
      jsonEncode({
        'type': 'previewStatus',
        'status': status,
        'message': ?message,
      }),
    );
  }

  void postRouteFinished() {
    // Go back to the selected origin route
    _postMessage('routeFinished');
  }

  void _postMessage(Object message) {
    final parent = _messageTarget();
    if (parent == null) return;

    final designerOrigin = _designerOrigin();
    if (designerOrigin == null) return;

    parent.postMessage(message, designerOrigin);
  }

  void listen(
    AppState state, {
    PreviewNavigationHandler? onNavigate,
    PreviewStudyHandler? onStudy,
  }) {
    final parent = _messageTarget();
    final designerOrigin = _designerOrigin();
    if (parent == null || designerOrigin == null) return;

    _messageSubscription?.cancel();
    _messageSubscription = html.window.onMessage.listen((event) async {
      if (!_isExpectedMessage(event, designerOrigin)) return;
      final data = event.data;

      final serializedStudy = parsePreviewStudy(data);
      if (serializedStudy != null) {
        try {
          final decodedStudy = jsonDecode(serializedStudy);
          if (decodedStudy is! Map<String, dynamic>) return;
          final study = Study.fromJson(decodedStudy);
          state.updateStudy(study);
          onStudy?.call(study);
          final completer = _previewStudyCompleter;
          if (completer != null && !completer.isCompleted) {
            completer.complete(study);
          }
        } catch (_) {
          return;
        }
        return;
      }

      if (data is! String) return;

      final Object? decodedMessage;
      try {
        decodedMessage = jsonDecode(data);
      } catch (_) {
        return;
      }
      if (decodedMessage is! Map<String, dynamic>) return;

      if (decodedMessage['type'] == 'previewNavigate') {
        if (!decodedMessage.keys.every(
              (key) => const {'type', 'route', 'extra', 'data'}.contains(key),
            ) ||
            (decodedMessage['route'] != null &&
                decodedMessage['route'] is! String) ||
            (decodedMessage['extra'] != null &&
                decodedMessage['extra'] is! String) ||
            (decodedMessage['data'] != null &&
                decodedMessage['data'] is! String)) {
          return;
        }
        await onNavigate?.call(decodedMessage['route'] as String?);
      }
    });
  }
}
