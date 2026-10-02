import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_flutter_common/src/utils/connection_status_platform.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppConnectionStatus() {
  healthy,
  deviceOffline,
  backendUnavailable,
}

typedef AuthAutoRefreshSync = void Function(AppConnectionStatus status);

class AppConnectionStatusController._() extends ChangeNotifier {
  static final AppConnectionStatusController instance =
      AppConnectionStatusController._();

  AppConnectionStatus _status = AppConnectionStatus.healthy;
  AuthAutoRefreshSync? _authAutoRefreshSyncOverride;

  AppConnectionStatus get status => _status;

  void setStatus(AppConnectionStatus status) {
    if (_status == status) return;
    _status = status;
    _syncAuthAutoRefresh();
    notifyListeners();
  }

  void syncAuthAutoRefresh() {
    _syncAuthAutoRefresh();
  }

  void _syncAuthAutoRefresh() {
    final sync = _authAutoRefreshSyncOverride ?? _defaultAuthAutoRefreshSync;
    sync(_status);
  }

  void _defaultAuthAutoRefreshSync(AppConnectionStatus status) {
    try {
      final auth = Supabase.instance.client.auth;
      if (status == AppConnectionStatus.healthy) {
        auth.startAutoRefresh();
      } else {
        auth.stopAutoRefresh();
      }
    } catch (_) {
      // Supabase may not be initialized yet during early startup.
    }
  }

  @visibleForTesting
  void reset() {
    if (_status == AppConnectionStatus.healthy) return;
    _status = AppConnectionStatus.healthy;
    _syncAuthAutoRefresh();
    notifyListeners();
  }

  @visibleForTesting
  AuthAutoRefreshSync? get debugAuthAutoRefreshSync =>
      _authAutoRefreshSyncOverride;

  @visibleForTesting
  set debugAuthAutoRefreshSync(AuthAutoRefreshSync? sync) {
    _authAutoRefreshSyncOverride = sync;
  }
}

AppConnectionStatusController get appConnectionStatusController =>
    AppConnectionStatusController.instance;

/// Error substrings that are never connectivity problems — they fall
/// through to existing auth/deleted-subject handling untouched. Only
/// checked for errors that aren't already a typed transport exception.
const _nonConnectivityMarkers = ['invalid_credentials', 'pgrst116', 'pgrst301'];

/// Substrings that mean "some transport failure happened", whose precise
/// status still depends on [isDeviceOnline] — see [_statusForTransportFailure].
/// Only checked for errors that aren't already a typed transport exception,
/// since those are always a transport failure regardless of their message.
const _transportFailureMarkers = [
  'failed host lookup',
  'no address associated',
  'socketexception',
  'connection timeout',
  'failed to fetch',
  'xmlhttprequest error',
  'clientexception',
  'timed out',
];

AppConnectionStatus? connectionStatusFromError(
  Object error, {
  AppConnectionStatus fallbackStatus = AppConnectionStatus.backendUnavailable,
}) {
  final message = error.toString().toLowerCase();

  // Checked first and unconditionally for every error shape: a backend
  // actively refusing the connection is never ambiguous, so it skips
  // isDeviceOnline()'s disambiguation entirely.
  if (message.contains('connection refused')) {
    return AppConnectionStatus.backendUnavailable;
  }

  // A real typed SocketException/TimeoutException is always a transport
  // failure, even when its message doesn't match any marker below (e.g. a
  // platform-specific wording this classifier doesn't otherwise recognize).
  if (error is SocketException || error is TimeoutException) {
    return _statusForTransportFailure(isDeviceOnline(), fallbackStatus);
  }

  if (_nonConnectivityMarkers.any(message.contains)) {
    return null;
  }
  // Unlike the typed-exception branch above, a stringified/wrapped error
  // reporting "network is unreachable" is trusted unconditionally — there's
  // no platform-specific ambiguity to disambiguate here, it's already explicit.
  if (message.contains('network is unreachable')) {
    return AppConnectionStatus.deviceOffline;
  }
  if (_transportFailureMarkers.any(message.contains)) {
    return _statusForTransportFailure(isDeviceOnline(), fallbackStatus);
  }

  return null;
}

AppConnectionStatus _statusForTransportFailure(
  bool? onlineState,
  AppConnectionStatus fallbackStatus,
) {
  return onlineState == false
      ? AppConnectionStatus.deviceOffline
      : fallbackStatus;
}
