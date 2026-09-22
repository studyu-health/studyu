import 'package:flutter/foundation.dart';
import 'package:stack_deferred_link/stack_deferred_link.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const DeferredLink._({final String? inviteCode, final String? studyId}) {
  this : assert(inviteCode != null || studyId != null);

  factory invite(String inviteCode) => DeferredLink._(inviteCode: inviteCode);

  factory study(String studyId) => DeferredLink._(studyId: studyId);
}

@visibleForTesting
DeferredLink? parseAndroidDeferredLink({
  required String? inviteCode,
  required String? studyId,
  required String? referrer,
}) {
  var parsedInviteCode = _sanitizeDeferredValue(inviteCode);
  var parsedStudyId = _sanitizeDeferredValue(studyId);

  if ((parsedInviteCode == null || parsedStudyId == null) && referrer != null) {
    final uri = Uri.tryParse('?$referrer');
    final params = uri?.queryParameters;
    parsedInviteCode ??= _sanitizeDeferredValue(params?['invite']);
    parsedStudyId ??= _sanitizeDeferredValue(params?['study']);
  }

  if (parsedInviteCode == null && referrer != null) {
    parsedInviteCode = _extractReferrerValue(referrer, 'invite');
  }
  if (parsedStudyId == null && referrer != null) {
    parsedStudyId = _extractReferrerValue(referrer, 'study');
  }

  if (parsedInviteCode != null) return DeferredLink.invite(parsedInviteCode);
  if (parsedStudyId != null) return DeferredLink.study(parsedStudyId);
  return null;
}

@visibleForTesting
DeferredLink? parseIosDeferredLinkPath(String? referralPath) {
  if (referralPath == null) return null;
  final uri = Uri.tryParse(referralPath);
  final segments = uri?.pathSegments;
  if (segments == null) return null;

  final inviteIndex = segments.indexOf('invite');
  if (inviteIndex >= 0 && inviteIndex + 1 < segments.length) {
    final inviteCode = _sanitizeDeferredValue(segments[inviteIndex + 1]);
    if (inviteCode != null) return DeferredLink.invite(inviteCode);
  }

  final studyIndex = segments.indexOf('study');
  if (studyIndex >= 0 && studyIndex + 1 < segments.length) {
    final studyId = _sanitizeDeferredValue(segments[studyIndex + 1]);
    if (studyId != null) return DeferredLink.study(studyId);
  }

  return null;
}

DeferredLink? pendingDeferredLinkFromStorageValues({
  required String? inviteCode,
  required String? studyId,
}) {
  final parsedInviteCode = _sanitizeDeferredValue(inviteCode);
  if (parsedInviteCode != null) return DeferredLink.invite(parsedInviteCode);

  final parsedStudyId = _sanitizeDeferredValue(studyId);
  if (parsedStudyId != null) return DeferredLink.study(parsedStudyId);

  return null;
}

String? _extractReferrerValue(String referrer, String key) {
  try {
    final regexp = RegExp('(?:^|&)$key=([^&]+)');
    final match = regexp.firstMatch(referrer);
    return _sanitizeDeferredValue(match?.group(1));
  } catch (_) {
    return null;
  }
}

class DeferredLinkService() {
  static Future<DeferredLink?> checkForDeferredLink() async {
    try {
      final hasProcessed =
          await SecureStorage.readBool('has_processed_deferred_link') ?? false;
      if (hasProcessed) {
        await SecureStorage.write(
          'debug_install_referrer',
          'Check skipped: has_processed_deferred_link is true',
        );
        return null;
      }

      DeferredLink? deferredLink;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await StackDeferredLink.getInstallReferrerAndroid();
        final referrer = info.installReferrer; // capture to local for promotion
        await SecureStorage.write(
          'debug_install_referrer',
          'Raw: $referrer\nParams: ${info.asQueryParameters}',
        );
        deferredLink = parseAndroidDeferredLink(
          inviteCode: info.getParam('invite'),
          studyId: info.getParam('study'),
          referrer: referrer,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await SecureStorage.write(
          'debug_install_referrer',
          'iOS deferred deep linking disabled: clipboard handoff removed.',
        );
        return null;
      }

      if (deferredLink != null) {
        if (deferredLink.inviteCode != null) {
          await SecureStorage.write(
            'pending_deferred_link_invite',
            deferredLink.inviteCode!,
          );
        }
        if (deferredLink.studyId != null) {
          await SecureStorage.write(
            'pending_deferred_link_study',
            deferredLink.studyId!,
          );
        }
        return deferredLink;
      }
      // Add else block for debugging empty code
      else {
        await SecureStorage.write(
          'debug_install_referrer',
          'Deferred link parsed but empty or null.',
        );
      }
    } catch (e) {
      debugPrint("Deferred link check failed: $e");
      // debug error
      await SecureStorage.write('debug_install_referrer', 'Error: $e');
    }
    return null;
  }
}

String? _sanitizeDeferredValue(String? value) {
  if (value == null) return null;
  var sanitized = value.trim();
  if (sanitized.isEmpty) return null;

  try {
    sanitized = Uri.decodeComponent(sanitized);
  } catch (_) {
    // ignore
  }
  return sanitized.trim();
}
