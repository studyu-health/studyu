import 'package:flutter/foundation.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const bool Function() _defaultUserLoggedIn = isUserLoggedIn;

class RecoveryResult({
  required final bool success,
  final String? email,
  final String? password,
  final String? subjectId,
  final String? error,
}) {
  factory fromJson(Map<String, dynamic> json) {
    return RecoveryResult(
      success: json['success'] as bool? ?? false,
      email: json['email'] as String?,
      password: json['password'] as String?,
      subjectId: json['subject_id'] as String?,
      error: json['error'] as String?,
    );
  }
}

class RestoreAccountService() {
  static List<String>? _cachedPhrase;
  static String? _cachedRecoveryId;
  static String? _cachedUserId;
  static Future<String?> Function() _recoveryIdGetter = _fetchRecoveryId;
  static Future<String?> Function() _recoveryIdRotator = _rotateRecoveryId;
  static String? Function() _currentUserIdGetter = _currentUserId;
  static Future<StudySubject> Function(String) _subjectGetter = _fetchSubject;
  static Future<RecoveryResult> Function(BigInt) _accountRecoverer =
      recoverAccount;
  static Future<void> Function(String, String) _credentialsStorer =
      storeFakeUserEmailAndPassword;
  static Future<bool> Function() _participantSignIn = signInParticipant;
  static Future<bool> Function() _recoveryConfirmer = _confirmRecovery;
  static bool Function() _userLoggedIn = _defaultUserLoggedIn;
  static Future<void> Function() _activeSubjectStateClearer =
      _clearActiveSubjectState;
  static Future<void> Function(String) _activeSubjectIdStorer =
      storeActiveSubjectId;
  static Future<void> Function() _pendingDeepLinkStorageClearer =
      PendingDeepLinkService.clearStorage;
  static Future<void> Function(AppState) _notificationCanceller =
      cancelNotificationsForAppState;

  static void clearCache() {
    _cachedPhrase = null;
    _cachedRecoveryId = null;
    _cachedUserId = null;
  }

  @visibleForTesting
  static Future<String?> Function() get debugRecoveryIdGetterForTesting =>
      _recoveryIdGetter;

  @visibleForTesting
  static set debugRecoveryIdGetterForTesting(
    Future<String?> Function() getter,
  ) {
    _recoveryIdGetter = getter;
  }

  @visibleForTesting
  static void debugResetRecoveryIdGetterForTesting() {
    _recoveryIdGetter = _fetchRecoveryId;
  }

  @visibleForTesting
  static Future<String?> Function() get debugRecoveryIdRotatorForTesting =>
      _recoveryIdRotator;

  @visibleForTesting
  static set debugRecoveryIdRotatorForTesting(
    Future<String?> Function() rotator,
  ) {
    _recoveryIdRotator = rotator;
  }

  @visibleForTesting
  static void debugResetRecoveryIdRotatorForTesting() {
    _recoveryIdRotator = _rotateRecoveryId;
  }

  @visibleForTesting
  static String? Function() get debugCurrentUserIdGetterForTesting =>
      _currentUserIdGetter;

  @visibleForTesting
  static set debugCurrentUserIdGetterForTesting(String? Function() getter) {
    _currentUserIdGetter = getter;
  }

  @visibleForTesting
  static void debugResetCurrentUserIdGetterForTesting() {
    _currentUserIdGetter = _currentUserId;
  }

  @visibleForTesting
  static Future<StudySubject> Function(String)
  get debugSubjectGetterForTesting => _subjectGetter;

  @visibleForTesting
  static set debugSubjectGetterForTesting(
    Future<StudySubject> Function(String) getter,
  ) {
    _subjectGetter = getter;
  }

  @visibleForTesting
  static void debugResetSubjectGetterForTesting() {
    _subjectGetter = _fetchSubject;
  }

  static bool get isUserLoggedIn => _userLoggedIn();

  @visibleForTesting
  static bool Function() get debugUserLoggedInForTesting => _userLoggedIn;

  @visibleForTesting
  static set debugUserLoggedInForTesting(bool Function() getter) {
    _userLoggedIn = getter;
  }

  @visibleForTesting
  static void debugResetUserLoggedInForTesting() {
    _userLoggedIn = _defaultUserLoggedIn;
  }

  @visibleForTesting
  static void debugConfigureRecoveryForTesting({
    Future<RecoveryResult> Function(BigInt)? recoverAccount,
    Future<void> Function(String, String)? storeCredentials,
    Future<bool> Function()? signInParticipant,
    Future<bool> Function()? confirmRecovery,
    Future<void> Function()? clearActiveSubjectState,
    Future<void> Function(String)? storeActiveSubjectId,
    Future<void> Function()? clearPendingDeepLinkStorage,
    Future<void> Function(AppState)? cancelNotifications,
  }) {
    _accountRecoverer = recoverAccount ?? _accountRecoverer;
    _credentialsStorer = storeCredentials ?? _credentialsStorer;
    _participantSignIn = signInParticipant ?? _participantSignIn;
    _recoveryConfirmer = confirmRecovery ?? _recoveryConfirmer;
    _activeSubjectStateClearer =
        clearActiveSubjectState ?? _activeSubjectStateClearer;
    _activeSubjectIdStorer = storeActiveSubjectId ?? _activeSubjectIdStorer;
    _pendingDeepLinkStorageClearer =
        clearPendingDeepLinkStorage ?? _pendingDeepLinkStorageClearer;
    _notificationCanceller = cancelNotifications ?? _notificationCanceller;
  }

  @visibleForTesting
  static void debugResetRecoveryForTesting() {
    _accountRecoverer = RestoreAccountService.recoverAccount;
    _credentialsStorer = storeFakeUserEmailAndPassword;
    _participantSignIn = signInParticipant;
    _recoveryConfirmer = _confirmRecovery;
    _activeSubjectStateClearer = _clearActiveSubjectState;
    _activeSubjectIdStorer = storeActiveSubjectId;
    _pendingDeepLinkStorageClearer = PendingDeepLinkService.clearStorage;
    _notificationCanceller = cancelNotificationsForAppState;
  }

  static Future<void> _clearActiveSubjectState([AppState? appState]) async {
    appState?.clearAccountState();
    await deleteActiveStudyReference();
    await Cache.delete();
  }

  static Future<bool> _confirmRecovery() async {
    try {
      return await Supabase.instance.client.rpc('confirm_recovered_account') ==
          true;
    } catch (e) {
      StudyULogger.warning('Error confirming recovered account: $e');
      return false;
    }
  }

  static Future<List<String>?> getRecoveryPhrase() async {
    final currentUserId = _currentUserIdGetter();
    if (_cachedPhrase != null &&
        currentUserId != null &&
        _cachedUserId == currentUserId) {
      return _cachedPhrase;
    }

    final recoveryId = await getOrCreateRecoveryId();
    if (recoveryId == null) return null;

    final sanitizedId = _sanitizeUuid(recoveryId);
    if (sanitizedId == null) {
      StudyULogger.warning('Invalid recovery ID format');
      return null;
    }

    try {
      final id = BigInt.parse(sanitizedId, radix: 16);
      _cachedUserId = currentUserId;
      return _cachedPhrase = encode(id);
    } on FormatException catch (e) {
      StudyULogger.warning('Failed to parse recovery ID: $e');
      return null;
    }
  }

  /// Sanitizes a UUID string by removing hyphens and validating format
  /// Returns null if the UUID format is invalid
  static String? _sanitizeUuid(String uuid) {
    // Remove all hyphens and convert to lowercase
    final sanitized = uuid.replaceAll('-', '').toLowerCase().trim();

    // UUID without hyphens should be exactly 32 hex characters
    if (sanitized.length != 32) {
      return null;
    }

    // Validate hex characters only
    final validHex = RegExp(r'^[0-9a-f]+$');
    if (!validHex.hasMatch(sanitized)) {
      return null;
    }

    return sanitized;
  }

  static Future<String?> getOrCreateRecoveryId() async {
    final currentUserId = _currentUserIdGetter();
    if (_cachedRecoveryId != null &&
        currentUserId != null &&
        _cachedUserId == currentUserId) {
      return _cachedRecoveryId;
    }

    final recoveryId = await _recoveryIdGetter();
    if (recoveryId != null) {
      _cachedRecoveryId = recoveryId;
      _cachedUserId = currentUserId;
    }
    return recoveryId;
  }

  static Future<String?> _fetchRecoveryId() async {
    try {
      final response = await Supabase.instance.client.rpc(
        'get_or_create_recovery',
      );

      if (response is Map<String, dynamic> && response['success'] == true) {
        return _cachedRecoveryId = response['recovery_id'] as String?;
      } else {
        final error = response is Map ? response['error'] : 'Unknown error';
        StudyULogger.warning('Failed to get recovery_id: $error');
        return null;
      }
    } catch (e) {
      StudyULogger.warning('Error getting recovery_id: $e');
      return null;
    }
  }

  static Future<List<String>?> rotateRecoveryPhrase() async {
    clearCache();
    final currentUserId = _currentUserIdGetter();
    final recoveryId = await _recoveryIdRotator();
    final sanitizedId = recoveryId == null ? null : _sanitizeUuid(recoveryId);
    if (sanitizedId == null) return null;

    try {
      final phrase = encode(BigInt.parse(sanitizedId, radix: 16));
      if (_currentUserIdGetter() != currentUserId) return null;
      _cachedRecoveryId = recoveryId;
      _cachedPhrase = phrase;
      _cachedUserId = currentUserId;
      return phrase;
    } on FormatException catch (e) {
      StudyULogger.warning('Failed to parse rotated recovery ID: $e');
      return null;
    }
  }

  static Future<String?> _rotateRecoveryId() async {
    try {
      final response = await Supabase.instance.client.rpc('rotate_recovery_id');
      if (response is String) return response;
      StudyULogger.warning('Unexpected rotate_recovery_id response');
      return null;
    } catch (e) {
      StudyULogger.warning('Error rotating recovery_id: $e');
      return null;
    }
  }

  static String? _currentUserId() =>
      Supabase.instance.client.auth.currentUser?.id;

  static BigInt decodeRecoveryPhrase(List<String> words) {
    // Validate word count first
    if (words.length != RecoveryConstants.totalWordCount) {
      throw ArgumentError(
        'Expected ${RecoveryConstants.totalWordCount} words, got ${words.length}',
      );
    }

    // Try English wordlist first
    try {
      final enWords = words.map((w) => w.toLowerCase().trim()).toList();
      return decode(enWords, wordlist: wordlistEn);
    } catch (e) {
      if (e is! ArgumentError) rethrow;

      // Check if error is due to word not found in English list
      final errorStr = e.toString();
      if (errorStr.contains('Invalid word') ||
          errorStr.contains('Checksum mismatch')) {
        // Try German wordlist
        try {
          final deWords = words.map((w) => w.toLowerCase().trim()).toList();
          return decode(deWords, wordlist: wordlistDe);
        } catch (deError) {
          if (deError is! ArgumentError) rethrow;

          // German also failed, throw original English error
          throw e;
        }
      }
      rethrow;
    }
  }

  static String? convertBigIntToUuid(BigInt id) {
    // Validate the ID fits within 128 bits
    if (id < BigInt.zero || id > _max128BitValue) {
      StudyULogger.warning('Recovery ID out of valid range');
      return null;
    }

    final hexString = id.toRadixString(16).padLeft(32, '0');
    return '${hexString.substring(0, 8)}-'
        '${hexString.substring(8, 12)}-'
        '${hexString.substring(12, 16)}-'
        '${hexString.substring(16, 20)}-'
        '${hexString.substring(20, 32)}';
  }

  static final BigInt _max128BitValue = (BigInt.one << 128) - BigInt.one;

  static Future<RecoveryResult> recoverAccount(BigInt recoveryId) async {
    try {
      final uuidString = convertBigIntToUuid(recoveryId);
      if (uuidString == null) {
        return RecoveryResult(success: false, error: 'invalid_recovery_id');
      }
      final response = await Supabase.instance.client.rpc(
        'recover_account',
        params: {'p_recovery_id': uuidString},
      );

      if (response is Map<String, dynamic>) {
        return RecoveryResult.fromJson(response);
      } else {
        StudyULogger.warning('Unexpected response format: $response');
        return RecoveryResult(success: false, error: 'recovery_failed');
      }
    } catch (e) {
      StudyULogger.warning('RPC call failed: $e');
      return RecoveryResult(success: false, error: 'recovery_network_error');
    }
  }

  static Future<StudySubject> _fetchSubject(String subjectId) =>
      SupabaseQuery.getById<StudySubject>(subjectId, selectedColumns: ['*']);

  static Future<bool> validateSubject(String subjectId) async {
    try {
      final subject = await _subjectGetter(subjectId);
      return !subject.isDeleted;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return false;
      rethrow;
    }
  }

  static Future<RecoveryResult> performRecovery(
    BigInt recoveryId, {
    AppState? appState,
  }) async {
    // Invalidate any cached recovery secret from a prior session before
    // establishing the recovered identity, so it cannot leak to the new
    // account via the static cache on a shared device.
    clearCache();
    try {
      final result = await _accountRecoverer(recoveryId);

      if (!result.success) {
        return result;
      }

      await _credentialsStorer(result.email!, result.password!);

      // Signing in broadcasts an auth event that can start loading before this
      // method returns. Remove the former account's subject state first. Then
      // store the recovered subject ID before sign-in, when one exists.
      if (appState != null) {
        await _pendingDeepLinkStorageClearer();
        await _notificationCanceller(appState);
        appState.clearAccountState();
      }
      await _activeSubjectStateClearer();
      if (result.subjectId != null) {
        await _activeSubjectIdStorer(result.subjectId!);
      }

      final signInResult = await _participantSignIn();
      if (!signInResult) {
        await _activeSubjectStateClearer();
        StudyULogger.warning('Sign in failed after recovery');
        return RecoveryResult(success: false, error: 'recovery_failed');
      }

      final subjectIsValid =
          result.subjectId == null || await validateSubject(result.subjectId!);
      if (!subjectIsValid) await _activeSubjectStateClearer();

      if (!await _recoveryConfirmer()) {
        StudyULogger.warning('Recovery confirmation failed');
        return RecoveryResult(success: false, error: 'recovery_failed');
      }

      return subjectIsValid
          ? result
          : RecoveryResult(
              success: true,
              email: result.email,
              password: result.password,
            );
    } catch (e, stackTrace) {
      StudyULogger.warning('Error in performRecovery: $e\n$stackTrace');
      return RecoveryResult(success: false, error: 'recovery_network_error');
    }
  }
}
