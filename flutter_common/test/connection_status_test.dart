import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';

void main() {
  tearDown(() {
    appConnectionStatusController.debugAuthAutoRefreshSync = null;
    appConnectionStatusController.reset();
  });

  test('connection status syncs auth refresh only when status changes', () {
    final calls = <AppConnectionStatus>[];
    appConnectionStatusController.debugAuthAutoRefreshSync = calls.add;

    appConnectionStatusController.setStatus(AppConnectionStatus.deviceOffline);
    appConnectionStatusController.setStatus(AppConnectionStatus.deviceOffline);
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

  test(
    'retries recovery while the connection remains healthy without overlap',
    () async {
      var recoveryCalls = 0;
      final firstRecovery = Completer<HealthyConnectionRecoveryResult>();

      appConnectionStatusController.setStatus(
        AppConnectionStatus.backendUnavailable,
      );
      appConnectionStatusController.scheduleHealthyConnectionRecovery(() {
        recoveryCalls++;
        if (recoveryCalls == 1) return firstRecovery.future;
        return Future.value(HealthyConnectionRecoveryResult.completed);
      });

      appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
      expect(recoveryCalls, 1);

      firstRecovery.complete(HealthyConnectionRecoveryResult.retryNeeded);
      await Future<void>.delayed(Duration.zero);
      expect(appConnectionStatusController.status, AppConnectionStatus.healthy);
      expect(recoveryCalls, 2);

      appConnectionStatusController.setStatus(
        AppConnectionStatus.deviceOffline,
      );
      appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
      expect(recoveryCalls, 2);
    },
  );

  test(
    'bounds recovery retries while the connection remains healthy',
    () async {
      var recoveryCalls = 0;

      appConnectionStatusController.scheduleHealthyConnectionRecovery(() async {
        recoveryCalls++;
        return HealthyConnectionRecoveryResult.retryNeeded;
      });

      await Future<void>.delayed(Duration.zero);

      expect(recoveryCalls, 4);

      await Future<void>.delayed(Duration.zero);
      expect(recoveryCalls, 4);
    },
  );

  test(
    'ignores an active recovery result after the connection degrades',
    () async {
      final oldRecovery = Completer<HealthyConnectionRecoveryResult>();
      var oldRecoveryCalls = 0;
      var replacementRecoveryCalls = 0;

      appConnectionStatusController.setStatus(
        AppConnectionStatus.backendUnavailable,
      );
      appConnectionStatusController.scheduleHealthyConnectionRecovery(() {
        oldRecoveryCalls++;
        return oldRecovery.future;
      });
      appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
      expect(oldRecoveryCalls, 1);

      appConnectionStatusController.setStatus(
        AppConnectionStatus.deviceOffline,
      );
      appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
      appConnectionStatusController.scheduleHealthyConnectionRecovery(() async {
        replacementRecoveryCalls++;
        return HealthyConnectionRecoveryResult.retryNeeded;
      });

      oldRecovery.complete(HealthyConnectionRecoveryResult.retryNeeded);
      await Future<void>.delayed(Duration.zero);

      expect(oldRecoveryCalls, 1);
      expect(replacementRecoveryCalls, 4);
    },
  );

  test(
    'starts a queued replacement after the final retry with a fresh budget',
    () async {
      var firstRecoveryCalls = 0;
      var replacementRecoveryCalls = 0;
      final finalRecovery = Completer<HealthyConnectionRecoveryResult>();

      appConnectionStatusController.scheduleHealthyConnectionRecovery(() {
        firstRecoveryCalls++;
        if (firstRecoveryCalls == 4) return finalRecovery.future;
        return Future.value(HealthyConnectionRecoveryResult.retryNeeded);
      });
      await Future<void>.delayed(Duration.zero);
      expect(firstRecoveryCalls, 4);

      appConnectionStatusController.scheduleHealthyConnectionRecovery(() async {
        replacementRecoveryCalls++;
        return HealthyConnectionRecoveryResult.retryNeeded;
      });
      finalRecovery.complete(HealthyConnectionRecoveryResult.retryNeeded);
      await Future<void>.delayed(Duration.zero);

      expect(firstRecoveryCalls, 4);
      expect(replacementRecoveryCalls, 4);
    },
  );

  test(
    'runs a queued recovery after an active recovery requests a retry',
    () async {
      var firstRecoveryCalls = 0;
      var secondRecoveryCalls = 0;
      final firstRecovery = Completer<HealthyConnectionRecoveryResult>();

      appConnectionStatusController.scheduleHealthyConnectionRecovery(() {
        firstRecoveryCalls++;
        return firstRecovery.future;
      });
      expect(firstRecoveryCalls, 1);

      appConnectionStatusController.scheduleHealthyConnectionRecovery(() async {
        secondRecoveryCalls++;
        return HealthyConnectionRecoveryResult.completed;
      });
      expect(secondRecoveryCalls, 0);

      firstRecovery.complete(HealthyConnectionRecoveryResult.retryNeeded);
      await Future<void>.delayed(Duration.zero);

      expect(appConnectionStatusController.status, AppConnectionStatus.healthy);
      expect(firstRecoveryCalls, 1);
      expect(secondRecoveryCalls, 1);
    },
  );

  test(
    'reset invalidates an active recovery without disrupting a new one',
    () async {
      final oldRecovery = Completer<HealthyConnectionRecoveryResult>();
      final newRecovery = Completer<HealthyConnectionRecoveryResult>();
      final oldRecoveryStarted = Completer<void>();
      final newRecoveryStarted = Completer<void>();
      var replacementRecoveryCalls = 0;

      appConnectionStatusController.setStatus(
        AppConnectionStatus.backendUnavailable,
      );
      appConnectionStatusController.scheduleHealthyConnectionRecovery(() {
        oldRecoveryStarted.complete();
        return oldRecovery.future;
      });
      appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
      await oldRecoveryStarted.future;

      appConnectionStatusController.reset();
      appConnectionStatusController.scheduleHealthyConnectionRecovery(() {
        newRecoveryStarted.complete();
        return newRecovery.future;
      });
      await newRecoveryStarted.future;

      oldRecovery.complete(HealthyConnectionRecoveryResult.completed);
      await Future<void>.delayed(Duration.zero);
      appConnectionStatusController.scheduleHealthyConnectionRecovery(() async {
        replacementRecoveryCalls++;
        return HealthyConnectionRecoveryResult.completed;
      });
      expect(replacementRecoveryCalls, 0);

      newRecovery.complete(HealthyConnectionRecoveryResult.completed);
      await Future<void>.delayed(Duration.zero);
      expect(replacementRecoveryCalls, 1);

      appConnectionStatusController.setStatus(
        AppConnectionStatus.deviceOffline,
      );
      appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
      await Future<void>.delayed(Duration.zero);
      expect(replacementRecoveryCalls, 1);
    },
  );

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
}
