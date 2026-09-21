import 'package:studyu_core/env.dart';

/// Extracts an invite code from scanner output or returns a raw code.
String? inviteCodeFromScan(String value) {
  final input = value.trim();
  if (input.isEmpty) return null;

  final uri = Uri.tryParse(input);
  if (uri == null) return input;

  final rawPathSegments = uri.path.split('/');
  final webHosts = {'app.studyu.health'};
  try {
    final configuredHost = Uri.parse(appUrl ?? '').host;
    if (configuredHost.isNotEmpty) webHosts.add(configuredHost);
  } catch (_) {
    // The environment is not initialized in pure parser tests.
  }
  final isWebInvite =
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      webHosts.contains(uri.host) &&
      rawPathSegments.length == 3 &&
      rawPathSegments[1] == 'invite';
  final isAppInvite =
      uri.scheme == 'studyu-app' &&
      ((uri.host == 'invite' && rawPathSegments.length == 2) ||
          (uri.host.isEmpty &&
              rawPathSegments.length == 3 &&
              rawPathSegments[1] == 'invite'));

  if (isWebInvite || isAppInvite) {
    final encodedCode = isAppInvite && uri.host == 'invite'
        ? rawPathSegments[1]
        : rawPathSegments[2];
    if (encodedCode.isEmpty) return null;
    try {
      return Uri.decodeComponent(encodedCode);
    } catch (_) {
      return input;
    }
  }

  return input;
}
