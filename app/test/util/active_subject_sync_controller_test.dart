import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/util/active_subject_sync_controller.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

StudySubject _buildSubject() {
  final study = Study('study', 'user')
    ..interventions = [Intervention('intervention-a', 'Intervention A')];
  return StudySubject.fromStudy(study, 'user', ['intervention-a'], null)
    ..startedAt = DateTime.now().subtract(const Duration(days: 1));
}

void main() {
  setUp(() {
    ActiveSubjectSyncController.instance.debugResetForTesting();
    appConnectionStatusController.reset();
  });

  tearDown(() {
    ActiveSubjectSyncController.instance.debugResetForTesting();
    appConnectionStatusController.reset();
  });

  group('idle / retrying state machine', () {
    test('stays idle (no timer) with a healthy connection and nothing '
        'pending', () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance;
        controller.onActiveSubjectChanged(_buildSubject()..startedAt = null);
        async.elapse(const Duration(minutes: 5));
        expect(controller.debugIsRetryTimerActive, isFalse);
      });
    });

    test('a degraded connection arms the retry timer', () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance;
        controller.onActiveSubjectChanged(_buildSubject());

        appConnectionStatusController.setStatus(
          AppConnectionStatus.deviceOffline,
        );
        async.flushMicrotasks();

        expect(controller.debugIsRetryTimerActive, isTrue);
      });
    });

    test('marking synchronization pending arms the retry timer even while '
        'healthy', () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance;
        controller.onActiveSubjectChanged(_buildSubject());

        controller.markSynchronizationPending();

        expect(controller.debugIsRetryTimerActive, isTrue);
      });
    });

    test('the retry timer calls Cache.synchronize with the active subject '
        'on each tick', () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance
          ..debugRetryDelay = const Duration(seconds: 5);
        final subject = _buildSubject();
        final attempts = <StudySubject>[];
        controller.debugSynchronizeOverride = (s) async {
          attempts.add(s);
          return CacheSynchronizationResult(subject: s, succeeded: false);
        };
        controller.onActiveSubjectChanged(subject);
        controller.markSynchronizationPending();

        async.elapse(const Duration(seconds: 16));

        expect(attempts, hasLength(2));
        expect(attempts.every((s) => s.id == subject.id), isTrue);
      });
    });

    test('a successful sync with nothing left pending returns to idle '
        '(timer stops)', () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance
          ..debugRetryDelay = const Duration(seconds: 5);
        final subject = _buildSubject();
        controller.debugSynchronizeOverride = (s) async =>
            CacheSynchronizationResult(subject: s, succeeded: true);
        controller.onActiveSubjectChanged(subject);
        controller.markSynchronizationPending();

        async.elapse(const Duration(seconds: 5));

        expect(controller.debugIsRetryTimerActive, isFalse);
      });
    });

    test('a failed sync keeps retrying', () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance
          ..debugRetryDelay = const Duration(seconds: 5);
        final subject = _buildSubject();
        var callCount = 0;
        controller.debugSynchronizeOverride = (s) async {
          callCount++;
          return CacheSynchronizationResult(subject: s, succeeded: false);
        };
        controller.onActiveSubjectChanged(subject);
        controller.markSynchronizationPending();

        async.elapse(const Duration(seconds: 16));

        expect(callCount, 2);
        expect(controller.debugIsRetryTimerActive, isTrue);
      });
    });
  });

  test(
    'failed retries back off from 30 seconds and cap the delay at five minutes',
    () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance;
        final subject = _buildSubject();
        final times = <Duration>[];
        controller.debugSynchronizeOverride = (s) async {
          times.add(async.elapsed);
          return CacheSynchronizationResult(subject: s, succeeded: false);
        };
        controller.onActiveSubjectChanged(subject);
        controller.markSynchronizationPending();
        async.elapse(const Duration(minutes: 20));
        expect(times.take(5), [
          const Duration(seconds: 30),
          const Duration(seconds: 90),
          const Duration(seconds: 210),
          const Duration(seconds: 450),
          const Duration(seconds: 750),
        ]);
        expect(times[5] - times[4], const Duration(minutes: 5));
      });
    },
  );

  group('onAccountCleared', () {
    test('stops the timer and prevents further retries for the cleared '
        'account', () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance
          ..debugRetryDelay = const Duration(seconds: 5);
        final subject = _buildSubject();
        var callCount = 0;
        controller.debugSynchronizeOverride = (s) async {
          callCount++;
          return CacheSynchronizationResult(subject: s, succeeded: false);
        };
        controller.onActiveSubjectChanged(subject);
        controller.markSynchronizationPending();

        controller.onAccountCleared();
        async.elapse(const Duration(seconds: 30));

        expect(callCount, 0);
        expect(controller.debugIsRetryTimerActive, isFalse);

        // Even a later pending-mark or connection flap must not resurrect
        // retries for the cleared account.
        controller.markSynchronizationPending();
        appConnectionStatusController.setStatus(
          AppConnectionStatus.deviceOffline,
        );
        async.flushMicrotasks();
        expect(controller.debugIsRetryTimerActive, isFalse);
      });
    });

    test('a new active subject after a clear re-enables retries', () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance
          ..debugRetryDelay = const Duration(seconds: 5);
        controller.onActiveSubjectChanged(_buildSubject());
        controller.onAccountCleared();

        final nextSubject = _buildSubject();
        controller.onActiveSubjectChanged(nextSubject);
        controller.markSynchronizationPending();

        expect(controller.debugIsRetryTimerActive, isTrue);
      });
    });
  });

  group('onActiveSubjectChanged(null)', () {
    test('cancels the retry timer when there is no active subject to '
        'sync', () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance
          ..debugRetryDelay = const Duration(seconds: 5);
        controller.onActiveSubjectChanged(_buildSubject());
        controller.markSynchronizationPending();
        expect(controller.debugIsRetryTimerActive, isTrue);

        controller.onActiveSubjectChanged(null);

        expect(controller.debugIsRetryTimerActive, isFalse);
      });
    });
  });

  group('pause / resume', () {
    test('pause() stops the timer and resume() re-arms it if retrying is '
        'still needed', () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance
          ..debugRetryDelay = const Duration(seconds: 5);
        controller.onActiveSubjectChanged(_buildSubject());
        controller.markSynchronizationPending();
        expect(controller.debugIsRetryTimerActive, isTrue);

        controller.pause();
        expect(controller.debugIsPaused, isTrue);
        expect(controller.debugIsRetryTimerActive, isFalse);

        controller.resume();
        expect(controller.debugIsPaused, isFalse);
        expect(controller.debugIsRetryTimerActive, isTrue);
      });
    });

    test('a connection flap while paused does not arm the timer', () {
      fakeAsync((async) {
        final controller = ActiveSubjectSyncController.instance;
        controller.onActiveSubjectChanged(_buildSubject());
        controller.pause();

        appConnectionStatusController.setStatus(
          AppConnectionStatus.deviceOffline,
        );
        async.flushMicrotasks();

        expect(controller.debugIsRetryTimerActive, isFalse);
      });
    });
  });
  test('subject change invalidates an in-flight result', () async {
    final controller = ActiveSubjectSyncController.instance;
    final first = _buildSubject();
    final next = _buildSubject()..id = 'next';
    final response = Completer<CacheSynchronizationResult>();
    var applied = false;
    controller.debugSynchronizeOverride = (_) => response.future;
    controller.onSynchronized = (_) => applied = true;
    controller.onActiveSubjectChanged(first);
    final attempt = controller.debugAttemptSync();
    controller.onActiveSubjectChanged(next);
    response.complete(
      CacheSynchronizationResult(subject: first, succeeded: true),
    );
    await attempt;
    expect(applied, isFalse);
  });
  test('work queued during a retry remains pending', () async {
    final controller = ActiveSubjectSyncController.instance;
    final subject = _buildSubject();
    final response = Completer<CacheSynchronizationResult>();
    controller.debugSynchronizeOverride = (_) => response.future;
    controller.onActiveSubjectChanged(subject);
    final attempt = controller.debugAttemptSync();
    controller.markSynchronizationPending();
    response.complete(
      CacheSynchronizationResult(subject: subject, succeeded: true),
    );
    await attempt;
    expect(controller.debugIsPending, isTrue);
  });
  test('pause waits for the in-flight request before deletion', () async {
    final controller = ActiveSubjectSyncController.instance;
    final subject = _buildSubject();
    final response = Completer<CacheSynchronizationResult>();
    controller.debugSynchronizeOverride = (_) => response.future;
    controller.onActiveSubjectChanged(subject);
    final attempt = controller.debugAttemptSync();
    var drained = false;
    final paused = controller.pauseAndWait().then((_) => drained = true);
    await Future<void>.delayed(Duration.zero);
    expect(drained, isFalse);
    response.complete(
      CacheSynchronizationResult(subject: subject, succeeded: true),
    );
    await attempt;
    await paused;
    expect(drained, isTrue);
  });
}
