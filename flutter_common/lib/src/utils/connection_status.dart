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

enum HealthyConnectionRecoveryResult() {
  completed,
  retryNeeded,
}

typedef HealthyConnectionRecovery =
    Future<HealthyConnectionRecoveryResult> Function();

class AppConnectionStatusController._() extends ChangeNotifier {
  static final AppConnectionStatusController instance =
      AppConnectionStatusController._();

  AppConnectionStatus _status = AppConnectionStatus.healthy;
  AuthAutoRefreshSync? _authAutoRefreshSyncOverride;
  HealthyConnectionRecovery? _pendingHealthyConnectionRecovery;
  int _healthyConnectionRecoveryGeneration = 0;
  int? _activeHealthyConnectionRecoveryGeneration;

  AppConnectionStatus get status => _status;

  void setStatus(AppConnectionStatus status) {
    if (_status == status) return;
    _status = status;
    _syncAuthAutoRefresh();
    if (status == AppConnectionStatus.healthy) {
      _startPendingHealthyConnectionRecovery();
    }
    notifyListeners();
  }

  void scheduleHealthyConnectionRecovery(HealthyConnectionRecovery recovery) {
    _pendingHealthyConnectionRecovery = recovery;
    if (_status == AppConnectionStatus.healthy) {
      _startPendingHealthyConnectionRecovery();
    }
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

  void _startPendingHealthyConnectionRecovery() {
    final recovery = _pendingHealthyConnectionRecovery;
    if (recovery == null ||
        _activeHealthyConnectionRecoveryGeneration != null) {
      return;
    }
    _pendingHealthyConnectionRecovery = null;
    final generation = ++_healthyConnectionRecoveryGeneration;
    _activeHealthyConnectionRecoveryGeneration = generation;
    unawaited(_runHealthyConnectionRecovery(recovery, generation));
  }

  Future<void> _runHealthyConnectionRecovery(
    HealthyConnectionRecovery recovery,
    int generation,
  ) async {
    var result = HealthyConnectionRecoveryResult.retryNeeded;
    try {
      result = await recovery();
    } catch (error, stackTrace) {
      debugPrint('Could not recover auth after reconnecting: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    if (_activeHealthyConnectionRecoveryGeneration != generation) return;
    _activeHealthyConnectionRecoveryGeneration = null;
    if (result == HealthyConnectionRecoveryResult.retryNeeded &&
        _pendingHealthyConnectionRecovery == null) {
      _pendingHealthyConnectionRecovery = recovery;
    }
  }

  @visibleForTesting
  void reset() {
    _pendingHealthyConnectionRecovery = null;
    _healthyConnectionRecoveryGeneration++;
    _activeHealthyConnectionRecoveryGeneration = null;
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

AppConnectionStatus? connectionStatusFromError(
  Object error, {
  AppConnectionStatus fallbackStatus = AppConnectionStatus.backendUnavailable,
}) {
  final onlineState = isDeviceOnline();

  if (error is SocketException) {
    final message = error.toString().toLowerCase();
    if (message.contains('connection refused')) {
      return AppConnectionStatus.backendUnavailable;
    }
    return _statusForTransportFailure(onlineState, fallbackStatus);
  }
  if (error is TimeoutException) {
    return _statusForTransportFailure(onlineState, fallbackStatus);
  }

  final message = error.toString().toLowerCase();
  if (message.contains('invalid_credentials') ||
      message.contains('pgrst116') ||
      message.contains('pgrst301')) {
    return null;
  }
  if (message.contains('network is unreachable')) {
    return AppConnectionStatus.deviceOffline;
  }
  if (message.contains('connection refused')) {
    return AppConnectionStatus.backendUnavailable;
  }
  if (message.contains('failed host lookup') ||
      message.contains('no address associated') ||
      message.contains('socketexception')) {
    return _statusForTransportFailure(onlineState, fallbackStatus);
  }
  if (message.contains('connection timeout') ||
      message.contains('failed to fetch') ||
      message.contains('xmlhttprequest error') ||
      message.contains('clientexception') ||
      message.contains('timed out')) {
    return _statusForTransportFailure(onlineState, fallbackStatus);
  }

  return null;
}

AppConnectionStatus _statusForTransportFailure(
  bool? onlineState,
  AppConnectionStatus fallbackStatus,
) {
  if (onlineState == false) {
    return AppConnectionStatus.deviceOffline;
  }
  return fallbackStatus;
}
