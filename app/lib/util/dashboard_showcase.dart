import 'package:flutter/foundation.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const DashboardShowcaseStorage._() {
  static const _completedKey = 'dashboard_showcase_completed';

  static Future<bool> isCompleted() async {
    return await SecureStorage.readBool(_completedKey) ?? false;
  }

  static Future<void> markCompleted() async {
    await SecureStorage.write(_completedKey, 'true');
  }

  static Future<void> reset() async {
    await SecureStorage.delete(_completedKey);
  }
}

class const RecoveryPhraseStorage._() {
  static const _pendingKeyPrefix = 'recovery_phrase_pending';
  static Future<bool?> Function(String) _pendingReader = _readPending;
  static Future<void> Function(String) _pendingMarker = _markPending;
  static Future<void> Function(String) _pendingClearer = _clearPending;

  static String _key(String subjectId) => '${_pendingKeyPrefix}_$subjectId';

  static Future<bool> isPending(String subjectId) async {
    return await _pendingReader(subjectId) ?? false;
  }

  static Future<void> markPending(String subjectId) =>
      _pendingMarker(subjectId);

  static Future<void> clearPending(String subjectId) =>
      _pendingClearer(subjectId);

  static Future<bool?> _readPending(String subjectId) =>
      SecureStorage.readBool(_key(subjectId));

  static Future<void> _markPending(String subjectId) =>
      SecureStorage.write(_key(subjectId), 'true');

  static Future<void> _clearPending(String subjectId) =>
      SecureStorage.delete(_key(subjectId));

  @visibleForTesting
  static void debugConfigureForTesting({
    Future<bool?> Function(String)? readPending,
    Future<void> Function(String)? markPending,
    Future<void> Function(String)? clearPending,
  }) {
    _pendingReader = readPending ?? _pendingReader;
    _pendingMarker = markPending ?? _pendingMarker;
    _pendingClearer = clearPending ?? _pendingClearer;
  }

  @visibleForTesting
  static void debugResetForTesting() {
    _pendingReader = _readPending;
    _pendingMarker = _markPending;
    _pendingClearer = _clearPending;
  }
}
