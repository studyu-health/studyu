import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';

void main() {
  tearDown(() {
    appConnectionStatusController.debugAuthAutoRefreshSync = null;
    appConnectionStatusController.reset();
  });

  group('AppConnectionStatusController', () {
    test('syncs auth refresh only when status changes', () {
      final calls = <AppConnectionStatus>[];
      appConnectionStatusController.debugAuthAutoRefreshSync = calls.add;

      appConnectionStatusController.setStatus(
        AppConnectionStatus.deviceOffline,
      );
      appConnectionStatusController.setStatus(
        AppConnectionStatus.deviceOffline,
      );
      appConnectionStatusController.setStatus(
        AppConnectionStatus.backendUnavailable,
      );
      appConnectionStatusController.setStatus(AppConnectionStatus.healthy);

      expect(calls, [
        AppConnectionStatus.deviceOffline,
        AppConnectionStatus.backendUnavailable,
        AppConnectionStatus.healthy,
      ]);
    });

    test('syncAuthAutoRefresh reapplies current connection status', () {
      final calls = <AppConnectionStatus>[];
      appConnectionStatusController.debugAuthAutoRefreshSync = calls.add;

      appConnectionStatusController.setStatus(
        AppConnectionStatus.backendUnavailable,
      );
      calls.clear();

      appConnectionStatusController.syncAuthAutoRefresh();

      expect(calls, [AppConnectionStatus.backendUnavailable]);
    });

    test('reset() is a no-op when already healthy', () {
      final calls = <AppConnectionStatus>[];
      appConnectionStatusController.debugAuthAutoRefreshSync = calls.add;

      appConnectionStatusController.reset();

      expect(calls, isEmpty);
      expect(appConnectionStatusController.status, AppConnectionStatus.healthy);
    });
  });

  group('connectionStatusFromError — classified as connectivity', () {
    test('a stringified "network is unreachable" error maps to '
        'deviceOffline unconditionally', () {
      expect(
        connectionStatusFromError(
          Exception('SocketException: Network is unreachable'),
        ),
        AppConnectionStatus.deviceOffline,
      );
    });

    test('a real typed SocketException without a recognized message falls '
        'back to backendUnavailable when online state is unknown', () {
      expect(
        connectionStatusFromError(
          const SocketException('Network is unreachable'),
        ),
        AppConnectionStatus.backendUnavailable,
      );
    });

    test('SocketException: failed host lookup falls back to backendUnavailable '
        'when device online state is unknown (native)', () {
      expect(
        connectionStatusFromError(const SocketException('Failed host lookup')),
        AppConnectionStatus.backendUnavailable,
      );
    });

    test('SocketException: connection refused maps to backendUnavailable '
        'regardless of online-state disambiguation', () {
      expect(
        connectionStatusFromError(const SocketException('Connection refused')),
        AppConnectionStatus.backendUnavailable,
      );
    });

    test('TimeoutException falls back to backendUnavailable when online '
        'state is unknown', () {
      expect(
        connectionStatusFromError(TimeoutException('timed out')),
        AppConnectionStatus.backendUnavailable,
      );
    });

    test('ClientException-shaped "Failed to fetch" message maps to '
        'backendUnavailable', () {
      expect(
        connectionStatusFromError(
          Exception('ClientException: Failed to fetch'),
        ),
        AppConnectionStatus.backendUnavailable,
      );
    });

    test('a custom fallbackStatus is honored for unresolved transport '
        'failures', () {
      expect(
        connectionStatusFromError(
          const SocketException('Failed host lookup'),
          fallbackStatus: AppConnectionStatus.deviceOffline,
        ),
        AppConnectionStatus.deviceOffline,
      );
    });
  });

  group('connectionStatusFromError — explicitly NOT connectivity', () {
    test('invalid_credentials is not classified as connectivity', () {
      expect(
        connectionStatusFromError(Exception('invalid_credentials')),
        isNull,
      );
    });

    test('PGRST116 (deleted subject) is not classified as connectivity', () {
      expect(connectionStatusFromError(Exception('PGRST116')), isNull);
    });

    test('PGRST301 is not classified as connectivity', () {
      expect(connectionStatusFromError(Exception('PGRST301')), isNull);
    });

    test('an unrelated error is not classified as connectivity', () {
      expect(
        connectionStatusFromError(const FormatException('bad input')),
        isNull,
      );
    });
  });
}
