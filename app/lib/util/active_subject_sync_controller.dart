import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

const _defaultRetryDelay = Duration(seconds: 30);

/// Owns the retry timer that keeps retrying [Cache.synchronize] for the
/// active subject while the connection is degraded or a sync is pending.
///
/// `AppState.activeSubject` is a plain field, not an observable stream —
/// see spec.md Decision 2 — so [onActiveSubjectChanged] and
/// [onAccountCleared] must be called explicitly at the points that field
/// changes, rather than inferred from listening to something.
class ActiveSubjectSyncController._() {
  this {
    _connectionStatusListener = () => _scheduleRetryIfNeeded();
    appConnectionStatusController.addListener(_connectionStatusListener);
  }

  static final ActiveSubjectSyncController instance =
      ActiveSubjectSyncController._();

  late final VoidCallback _connectionStatusListener;

  StudySubject? _activeSubject;
  bool _pending = false;
  bool _stopped = false;
  bool _isSyncing = false;
  bool _externallyPaused = false;
  Timer? _retryTimer;
  int _generation = 0;
  int _pendingRevision = 0;
  int _retryFailures = 0;
  Future<void>? _inFlight;
  void Function(StudySubject subject)? onSynchronized;

  @visibleForTesting
  Future<StudySubject?> Function(String id)? debugFetchSubjectOverride;

  Future<CacheSynchronizationResult> synchronizeNow(
    StudySubject subject,
  ) async {
    try {
      final remote = await (debugFetchSubjectOverride ?? _fetchSubject)(
        subject.id,
      );
      if (remote == null) {
        throw StateError('The active subject no longer exists.');
      }
      final result = await Cache.synchronize(remote);
      final status = result.error == null
          ? null
          : connectionStatusFromError(result.error!);
      if (status != null) {
        appConnectionStatusController.setStatus(status);
      } else {
        appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
      }
      return result;
    } catch (error) {
      final status = connectionStatusFromError(error);
      if (status != null) appConnectionStatusController.setStatus(status);
      return CacheSynchronizationResult(
        subject: subject,
        succeeded: false,
        error: error,
      );
    }
  }

  static Future<StudySubject?> _fetchSubject(String id) =>
      SupabaseQuery.getById<StudySubject>(
        id,
        selectedColumns: [
          '*',
          'study!study_subject_studyId_fkey(*, study_fitbit_credentials:study_fitbit_credentials_studyId_fkey(*))',
          'subject_progress(*)',
        ],
      );

  Future<void> pauseAndWait() async {
    pause();
    await _inFlight;
  }

  @visibleForTesting
  Future<void> debugAttemptSync() {
    _inFlight = _attemptSync();
    return _inFlight!;
  }

  Duration debugRetryDelay = _defaultRetryDelay;

  @visibleForTesting
  Future<CacheSynchronizationResult> Function(StudySubject subject)?
  debugSynchronizeOverride;

  @visibleForTesting
  void debugResetForTesting() {
    _cancelRetry();
    _activeSubject = null;
    _pending = false;
    _stopped = false;
    _isSyncing = false;
    _externallyPaused = false;
    debugRetryDelay = _defaultRetryDelay;
    debugSynchronizeOverride = null;
    debugFetchSubjectOverride = null;
    onSynchronized = null;
    _generation++;
    _pendingRevision = 0;
    _retryFailures = 0;
  }

  @visibleForTesting
  bool get debugIsRetryTimerActive => _retryTimer != null;

  @visibleForTesting
  bool get debugIsPending => _pending;

  /// Call whenever `AppState.activeSubject` is reassigned.
  ///
  /// A non-null [subject] re-enables retries even if a previous account was
  /// cleared — a new active subject means a new participation session.
  void onActiveSubjectChanged(StudySubject? subject) {
    _generation++;
    _retryFailures = 0;
    _cancelRetry();
    _activeSubject = subject;
    _pending = false;
    if (subject == null) {
      _cancelRetry();
      return;
    }
    _stopped = false;
    if (subject.startedAt != null) {
      unawaited(_restorePending(subject, _generation));
    }
    _scheduleRetryIfNeeded();
  }

  Future<void> _restorePending(StudySubject subject, int generation) async {
    try {
      final hasCache = await SecureStorage.containsKey(cacheSubjectKey);
      final queued = await Cache.loadDeferredFitbitRequests();
      if (_stopped || generation != _generation) return;
      if (hasCache ||
          queued.any((request) => request.subjectId == subject.id)) {
        markSynchronizationPending();
      }
    } catch (_) {
      // Retry real requests when a connection failure is reported.
    }
  }

  /// Call from `AppState.clearAccountState()`. Stops all retries; no
  /// further retries happen until [onActiveSubjectChanged] sets a new
  /// subject.
  void onAccountCleared() {
    _generation++;
    _stopped = true;
    _activeSubject = null;
    _pending = false;
    _cancelRetry();
  }

  /// Marks a sync as needed even if the connection is currently healthy
  /// (e.g. a non-connectivity save failure fell back to the local cache).
  void markSynchronizationPending() {
    if (_stopped || _activeSubject == null) return;
    _pendingRevision++;
    _pending = true;
    _scheduleRetryIfNeeded();
  }

  /// Stops the retry loop for a destructive action (e.g. deleting the
  /// subject) that needs to own the cache without a background sync
  /// attempt racing it. Must be paired with [resume].
  void pause() {
    _externallyPaused = true;
    _cancelRetry();
  }

  void resume() {
    _externallyPaused = false;
    _scheduleRetryIfNeeded();
  }

  @visibleForTesting
  bool get debugIsPaused => _externallyPaused;

  bool get _shouldRetry =>
      !_stopped &&
      !_externallyPaused &&
      _activeSubject != null &&
      (appConnectionStatusController.status != AppConnectionStatus.healthy ||
          _pending);

  void _scheduleRetryIfNeeded() {
    if (!_shouldRetry) {
      _cancelRetry();
      return;
    }
    if (_isSyncing) return;
    final delay = debugRetryDelay * (1 << _retryFailures);
    const maximumDelay = Duration(minutes: 5);
    _retryTimer ??= Timer(delay > maximumDelay ? maximumDelay : delay, () {
      _retryTimer = null;
      _inFlight = _attemptSync();
      unawaited(_inFlight);
    });
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  Future<void> _attemptSync() async {
    if (_isSyncing || _stopped || _externallyPaused) return;
    final subject = _activeSubject;
    if (subject == null) {
      _cancelRetry();
      return;
    }
    _isSyncing = true;
    _cancelRetry();
    final generation = _generation;
    final pendingRevision = _pendingRevision;
    try {
      final synchronize = debugSynchronizeOverride ?? synchronizeNow;
      final result = await synchronize(subject);
      if (_stopped || generation != _generation) return;
      if (result.succeeded) {
        _retryFailures = 0;
      } else {
        if (_retryFailures < 4) _retryFailures++;
        _pending = true;
      }
      _activeSubject = result.subject;
      onSynchronized?.call(result.subject);
      if (result.succeeded && pendingRevision == _pendingRevision) {
        _pending = false;
      }
      _scheduleRetryIfNeeded();
    } catch (error) {
      final status = connectionStatusFromError(error);
      if (status != null) appConnectionStatusController.setStatus(status);
      _pending = true;
      if (_retryFailures < 4) _retryFailures++;
    } finally {
      _isSyncing = false;
      _scheduleRetryIfNeeded();
    }
  }
}
