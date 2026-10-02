import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/active_subject_sync_controller.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

const _studyId = 'study-id';
const _userId = 'user-id';
const _interventionAId = 'intervention-a';
const _interventionBId = 'intervention-b';
const _taskAId = 'task-a';
const _taskBId = 'task-b';
const _periodAId = 'period-a';
const _periodBId = 'period-b';

const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

StudySubject _buildSubject() {
  final study = Study(_studyId, _userId)
    ..interventions = [
      Intervention(_interventionAId, 'Intervention A'),
      Intervention(_interventionBId, 'Intervention B'),
    ];

  return StudySubject.fromStudy(
    study,
    _userId,
    study.interventions.map((intervention) => intervention.id).toList(),
    null,
  )..startedAt = DateTime.utc(2026, 8, 10);
}

SubjectProgress _progress({
  required String subjectId,
  required String interventionId,
  required String taskId,
  required String periodId,
  required DateTime completedAt,
}) {
  return SubjectProgress(
    subjectId: subjectId,
    interventionId: interventionId,
    taskId: taskId,
    resultType: 'bool',
    result: Result<bool>.app(type: 'bool', periodId: periodId, result: true),
  )..completedAt = completedAt;
}

class _SavingSubject(StudySubject original) extends StudySubject {
  this
    : super(
        original.id,
        original.studyId,
        original.userId,
        original.selectedInterventionIds,
      ) {
    study = original.study;
    startedAt = original.startedAt;
  }
  final saves = StreamController<StudySubject>();
  @override
  Stream<StudySubject> get onSave => saves.stream;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = <String, String>{};
  Completer<void>? blockNextWrite;
  Completer<void>? writeStarted;

  setUp(() {
    storage.clear();
    blockNextWrite = null;
    writeStarted = null;
    Cache.debugResetSynchronizationStateForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (call) async {
          final arguments = call.arguments as Map<Object?, Object?>;
          final key = arguments['key'] as String?;
          if (call.method == 'write' && blockNextWrite != null) {
            final block = blockNextWrite!;
            blockNextWrite = null;
            writeStarted!.complete();
            await block.future;
          }
          return switch (call.method) {
            'write' => storage[key!] = arguments['value']! as String,
            'read' => storage[key],
            'delete' => storage.remove(key),
            'containsKey' => storage.containsKey(key),
            _ => throw UnimplementedError(call.method),
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
    Cache.debugResetSynchronizationStateForTesting();
    ActiveSubjectSyncController.instance.debugResetForTesting();
    appConnectionStatusController.reset();
  });

  test(
    'retry upload failure preserves local progress and degraded status',
    () async {
      final remote = _buildSubject();
      final cached = StudySubject.fromJson(remote.toFullJson())
        ..progress = [
          _progress(
            subjectId: remote.id,
            interventionId: _interventionAId,
            taskId: _taskAId,
            periodId: _periodAId,
            completedAt: DateTime.utc(2026, 8, 10),
          ),
        ];
      await Cache.storeSubject(cached);
      Cache.debugUploadBlobFilesOverride = () async =>
          throw const SocketException('offline');
      final controller = ActiveSubjectSyncController.instance;
      controller.debugFetchSubjectOverride = (_) async => remote;
      final result = await controller.synchronizeNow(cached);
      expect(result.succeeded, isFalse);
      expect(result.subject.progress, cached.progress);
      expect(
        appConnectionStatusController.status,
        isNot(AppConnectionStatus.healthy),
      );
    },
  );

  test('replacement subjects remain subscribed to cache saves', () async {
    final initial = _SavingSubject(_buildSubject());
    final updated = _SavingSubject(initial);
    final state = AppState()..activeSubject = initial;
    state.initCache();
    ActiveSubjectSyncController.instance.onSynchronized!(updated);
    updated.progress.add(
      _progress(
        subjectId: updated.id,
        interventionId: _interventionAId,
        taskId: _taskAId,
        periodId: _periodAId,
        completedAt: DateTime.utc(2026, 8, 10),
      ),
    );
    updated.saves.add(updated);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect((await Cache.loadSubject()).progress, updated.progress);
    state.dispose();
    await initial.saves.close();
    await updated.saves.close();
  });

  test(
    'local writes queued during the final sync write cannot be overwritten',
    () async {
      final remote = _buildSubject();
      await Cache.storeSubject(
        StudySubject.fromJson(remote.toFullJson())
          ..startedAt = DateTime.utc(2026, 8, 9),
      );
      final local = StudySubject.fromJson(remote.toFullJson())
        ..progress = [
          _progress(
            subjectId: remote.id,
            interventionId: _interventionAId,
            taskId: _taskAId,
            periodId: _periodAId,
            completedAt: DateTime.utc(2026, 8, 10),
          ),
        ];
      final release = Completer<void>();
      blockNextWrite = release;
      writeStarted = Completer<void>();
      final sync = Cache.synchronize(remote);
      await writeStarted!.future;
      final localWrite = Cache.storeSubject(local);
      await Future<void>.delayed(Duration.zero);
      release.complete();
      final result = await sync;
      await localWrite;
      expect((await Cache.loadSubject()).progress, local.progress);
      expect(result.succeeded, isFalse);
      expect(result.subject.progress, local.progress);
    },
  );
  test(
    'an upload failure returns completions written after its snapshot',
    () async {
      final remote = _buildSubject();
      final first = _progress(
        subjectId: remote.id,
        interventionId: _interventionAId,
        taskId: _taskAId,
        periodId: _periodAId,
        completedAt: DateTime.utc(2026, 8, 10),
      );
      final second = _progress(
        subjectId: remote.id,
        interventionId: _interventionAId,
        taskId: _taskBId,
        periodId: _periodAId,
        completedAt: DateTime.utc(2026, 8, 11),
      );
      await Cache.storeSubject(
        StudySubject.fromJson(remote.toFullJson())..progress = [first],
      );
      Cache.debugAfterSubjectSnapshotLoaded = () => Cache.storeSubject(
        StudySubject.fromJson(remote.toFullJson())..progress = [first, second],
      );
      Cache.debugUploadBlobFilesOverride = () async =>
          throw const SocketException('offline');
      final result = await Cache.synchronize(remote);
      expect(result.succeeded, isFalse);
      expect(result.subject.progress.map((p) => p.taskId), [
        _taskAId,
        _taskBId,
      ]);
    },
  );
  test('destructive pause drains direct cache callers and rejects their final writes', () async {
    final remote = _buildSubject();
    await Cache.storeSubject(remote);
    final snapshot = Completer<void>();
    final release = Completer<void>();
    Cache.debugAfterSubjectSnapshotLoaded = () async {
      snapshot.complete();
      await release.future;
    };
    final sync = Cache.synchronize(remote);
    await snapshot.future;
    var drained = false;
    final paused = Cache.pauseAndWaitSynchronization().then(
      (_) => drained = true,
    );
    await Future<void>.delayed(Duration.zero);
    expect(drained, isFalse);
    release.complete();
    expect((await sync).succeeded, isFalse);
    await paused;
    expect(drained, isTrue);
    Cache.resumeSynchronization();
  });
  test(
    'invalid cache JSON uses the supplied backup without exposing payload',
    () async {
      final remote = _buildSubject();
      storage[cacheSubjectKey] = '{broken';
      expect(await Cache.loadSubject(backupSubject: remote), same(remote));
    },
  );

  test(
    'model parse fallback preserves the subject_progress relation',
    () async {
      final remote = _buildSubject();
      final progress = _progress(
        subjectId: remote.id,
        interventionId: _interventionAId,
        taskId: _taskAId,
        periodId: _periodAId,
        completedAt: DateTime.utc(2026, 8, 10),
      );
      final json = remote.toFullJson()..['study'] = {'id': 'broken'};
      json['subject_progress'] = [progress.toJson()];
      storage[cacheSubjectKey] = jsonEncode(json);
      expect((await Cache.loadSubject(backupSubject: remote)).progress, [
        progress,
      ]);
    },
  );

  test(
    'a stale subject save cannot replace already cached completions',
    () async {
      final stale = _buildSubject();
      await Cache.storeSubject(stale);
      final completed = StudySubject.fromJson(stale.toFullJson())
        ..progress = [
          _progress(
            subjectId: stale.id,
            interventionId: _interventionAId,
            taskId: _taskAId,
            periodId: _periodAId,
            completedAt: DateTime.utc(2026, 8, 10),
          ),
        ];
      await Cache.storeSubject(completed);
      await Cache.storeSubject(stale);
      expect((await Cache.loadSubject()).progress, completed.progress);
    },
  );
  test('an explicit server-side progress re-key replaces cached timestamps without resubmitting old entries', () async {
    final original = _buildSubject()
      ..progress = [
        _progress(
          subjectId: 'id',
          interventionId: _interventionAId,
          taskId: _taskAId,
          periodId: _periodAId,
          completedAt: DateTime.utc(2026, 8, 11),
        ),
      ];
    await Cache.storeSubject(original);
    final shifted = StudySubject.fromJson(original.toFullJson());
    shifted.progress.single.completedAt = DateTime.utc(2026, 8, 10);
    await Cache.storeSubject(shifted, replaceProgress: true);
    expect((await Cache.loadSubject()).progress, shifted.progress);
    Cache.debugSaveProgressOverride = (_) async =>
        fail('must not resubmit the old timestamp');
    expect((await Cache.synchronize(shifted)).succeeded, isTrue);
  });
  group('Cache.isCompatibleCachedSubject', () {
    test('true for the same subject identity', () {
      final remote = _buildSubject();
      final local = StudySubject.fromJson(remote.toFullJson());
      expect(
        Cache.isCompatibleCachedSubject(
          localSubject: local,
          remoteSubject: remote,
        ),
        isTrue,
      );
    });

    test('false when the cached subject id does not match', () {
      final remote = _buildSubject();
      final local = StudySubject.fromJson(remote.toFullJson())
        ..id = 'different-subject-id';
      expect(
        Cache.isCompatibleCachedSubject(
          localSubject: local,
          remoteSubject: remote,
        ),
        isFalse,
      );
    });
  });

  group('Cache.buildProgressSyncPlan', () {
    test('merges local-only progress even when lengths already match', () {
      final remote = _buildSubject()
        ..progress = [
          _progress(
            subjectId: 'id',
            interventionId: _interventionAId,
            taskId: _taskAId,
            periodId: _periodAId,
            completedAt: DateTime.utc(2026, 8, 10, 8),
          ),
        ];
      final local = StudySubject.fromJson(remote.toFullJson())
        ..progress = [
          _progress(
            subjectId: 'id',
            interventionId: _interventionBId,
            taskId: _taskBId,
            periodId: _periodBId,
            completedAt: DateTime.utc(2026, 8, 11, 8),
          ),
        ];

      final plan = Cache.buildProgressSyncPlan(
        localSubject: local,
        remoteSubject: remote,
      );

      expect(plan.hasChanges, isTrue);
      expect(plan.newProgress, hasLength(1));
      expect(plan.newProgress.single.taskId, _taskBId);
      expect(plan.mergedProgress, hasLength(2));
      expect(
        plan.mergedProgress.map((p) => p.taskId),
        containsAll([_taskAId, _taskBId]),
      );
    });

    test('does not collapse separate tasks that share a timestamp', () {
      final sharedTimestamp = DateTime.utc(2026, 8, 10, 8);
      final remote = _buildSubject()
        ..progress = [
          _progress(
            subjectId: 'id',
            interventionId: _interventionAId,
            taskId: _taskAId,
            periodId: _periodAId,
            completedAt: sharedTimestamp,
          ),
        ];
      final local = StudySubject.fromJson(remote.toFullJson())
        ..progress = [
          _progress(
            subjectId: 'other-id',
            interventionId: _interventionBId,
            taskId: _taskBId,
            periodId: _periodBId,
            completedAt: sharedTimestamp,
          ),
        ];

      final plan = Cache.buildProgressSyncPlan(
        localSubject: local,
        remoteSubject: remote,
      );

      expect(plan.mergedProgress, hasLength(2));
    });

    test('does not resubmit progress that already matches remote', () {
      final shared = _progress(
        subjectId: 'id',
        interventionId: _interventionAId,
        taskId: _taskAId,
        periodId: _periodAId,
        completedAt: DateTime.utc(2026, 8, 10, 8),
      );
      final remote = _buildSubject()..progress = [shared];
      final local = StudySubject.fromJson(remote.toFullJson())
        ..progress = [SubjectProgress.fromJson(shared.toJson())];

      final plan = Cache.buildProgressSyncPlan(
        localSubject: local,
        remoteSubject: remote,
      );

      expect(plan.hasChanges, isFalse);
      expect(plan.newProgress, isEmpty);
      expect(plan.mergedProgress, hasLength(1));
    });

    test('a retry plan after a partial failure contains only what is still '
        'unsynced', () {
      final remote = _buildSubject();
      final first = _progress(
        subjectId: 'id',
        interventionId: _interventionAId,
        taskId: _taskAId,
        periodId: _periodAId,
        completedAt: DateTime.utc(2026, 8, 10, 8),
      );
      final second = _progress(
        subjectId: 'id',
        interventionId: _interventionBId,
        taskId: _taskBId,
        periodId: _periodBId,
        completedAt: DateTime.utc(2026, 8, 11, 8),
      );
      final local = StudySubject.fromJson(remote.toFullJson())
        ..progress = [first, second];

      // Simulate that `first` made it to the remote before the retry.
      remote.progress = [first];

      final retryPlan = Cache.buildProgressSyncPlan(
        localSubject: local,
        remoteSubject: remote,
      );

      expect(retryPlan.newProgress, hasLength(1));
      expect(retryPlan.newProgress.single.taskId, _taskBId);
    });
  });

  group('Cache.applyProgressSyncPlan', () {
    test('a save failure partway through still records every attempted '
        'save and propagates the error', () async {
      final remote = _buildSubject();
      final saved = <SubjectProgress>[];
      final plan = SubjectProgressSyncPlan(
        newProgress: [
          _progress(
            subjectId: 'id',
            interventionId: _interventionAId,
            taskId: _taskAId,
            periodId: _periodAId,
            completedAt: DateTime.utc(2026, 8, 10, 8),
          ),
          _progress(
            subjectId: 'id',
            interventionId: _interventionBId,
            taskId: _taskBId,
            periodId: _periodBId,
            completedAt: DateTime.utc(2026, 8, 11, 8),
          ),
        ],
        mergedProgress: const [],
        saveProgress: (progress) async {
          saved.add(progress);
          if (saved.length == 2) {
            throw Exception('simulated upload failure');
          }
          return progress;
        },
        saveSubject: (subject) async => subject,
      );

      await expectLater(
        () =>
            Cache.applyProgressSyncPlan(remoteSubject: remote, syncPlan: plan),
        throwsException,
      );
      expect(saved, hasLength(2));
    });
  });

  group('Cache.synchronize', () {
    test(
      'returns the remote subject unchanged when there is no cache',
      () async {
        final remote = _buildSubject();
        final result = await Cache.synchronize(remote);
        expect(result.succeeded, isTrue);
        expect(result.subject, same(remote));
      },
    );

    test('is a no-op when the cached subject already equals the remote '
        'subject', () async {
      final remote = _buildSubject();
      await Cache.storeSubject(StudySubject.fromJson(remote.toFullJson()));

      final result = await Cache.synchronize(remote);

      expect(result.succeeded, isTrue);
      expect(result.subject.progress, isEmpty);
    });

    test('ignores cached data that belongs to a different subject', () async {
      final remote = _buildSubject()
        ..progress = [
          _progress(
            subjectId: 'id',
            interventionId: _interventionAId,
            taskId: _taskAId,
            periodId: _periodAId,
            completedAt: DateTime.utc(2026, 8, 10, 8),
          ),
        ];
      final foreignCached = StudySubject.fromJson(remote.toFullJson())
        ..id = 'different-subject-id'
        ..progress = [
          _progress(
            subjectId: 'different-subject-id',
            interventionId: _interventionBId,
            taskId: _taskBId,
            periodId: _periodBId,
            completedAt: DateTime.utc(2026, 8, 11, 8),
          ),
        ];
      await Cache.storeSubject(foreignCached);

      final result = await Cache.synchronize(remote);

      expect(result.succeeded, isTrue);
      expect(result.subject.progress, hasLength(1));
      expect(result.subject.progress.single.taskId, _taskAId);
    });

    test('merges unsynced local progress even when remote.startedAt is after '
        "local.startedAt (the fixed silent-drop bug)", () async {
      final remote = _buildSubject()
        ..startedAt = DateTime.utc(2026, 8, 15); // later than local below
      final cached = StudySubject.fromJson(remote.toFullJson())
        ..startedAt = DateTime.utc(2026, 8, 10)
        ..progress = [
          _progress(
            subjectId: remote.id,
            interventionId: _interventionAId,
            taskId: _taskAId,
            periodId: _periodAId,
            completedAt: DateTime.utc(2026, 8, 11, 8),
          ),
        ];
      await Cache.storeSubject(cached);
      Cache.debugUploadBlobFilesOverride = () async {};
      Cache.debugSaveProgressOverride = (p) async => p;
      Cache.debugSaveSubjectOverride = (s) async => s;

      final result = await Cache.synchronize(remote);

      expect(result.succeeded, isTrue);
      expect(result.subject.progress, hasLength(1));
      expect(result.subject.progress.single.taskId, _taskAId);
    });

    test('a concurrent synchronize() call is rejected, not silently '
        'dropped', () async {
      final remote = _buildSubject();
      await Cache.storeSubject(StudySubject.fromJson(remote.toFullJson()));
      final snapshotLoaded = Completer<void>();
      final unblock = Completer<void>();
      Cache.debugAfterSubjectSnapshotLoaded = () async {
        snapshotLoaded.complete();
        await unblock.future;
      };

      final first = Cache.synchronize(remote);
      await snapshotLoaded.future;
      final second = await Cache.synchronize(remote);

      expect(second.succeeded, isFalse);

      unblock.complete();
      await first;
    });

    test('synchronization paused by pauseSynchronization() is rejected '
        'until resumeSynchronization() is called', () async {
      final remote = _buildSubject();
      Cache.pauseSynchronization();

      final blocked = await Cache.synchronize(remote);
      expect(blocked.succeeded, isFalse);

      Cache.resumeSynchronization();
      final resumed = await Cache.synchronize(remote);
      expect(resumed.succeeded, isTrue);
    });

    test('a cache write that lands while synchronize() is mid-flight is not '
        'clobbered by a stale merge', () async {
      final remote = _buildSubject();
      final originalCached = StudySubject.fromJson(remote.toFullJson());
      await Cache.storeSubject(originalCached);

      final queuedSubject = StudySubject.fromJson(remote.toFullJson())
        ..progress = [
          _progress(
            subjectId: remote.id,
            interventionId: _interventionBId,
            taskId: _taskBId,
            periodId: _periodBId,
            completedAt: DateTime.utc(2026, 8, 11, 8),
          ),
        ];
      final snapshotLoaded = Completer<void>();
      final releaseSynchronization = Completer<void>();
      Cache.debugAfterSubjectSnapshotLoaded = () async {
        snapshotLoaded.complete();
        await releaseSynchronization.future;
      };
      Cache.debugUploadBlobFilesOverride = () async {};
      Cache.debugSaveProgressOverride = (p) async => p;
      Cache.debugSaveSubjectOverride = (s) async => s;

      final synchronizationFuture = Cache.synchronize(remote);
      await snapshotLoaded.future;
      await Cache.storeSubject(queuedSubject);
      releaseSynchronization.complete();
      final result = await synchronizationFuture;

      expect(result.succeeded, isFalse);
      expect(result.error, isNull);
      final restored = await Cache.loadSubject();
      expect(restored.progress, hasLength(1));
      expect(restored.progress.single.taskId, _taskBId);
    });

    test('a successful merge is persisted back to the cache', () async {
      final remote = _buildSubject()
        ..progress = [
          _progress(
            subjectId: 'id',
            interventionId: _interventionAId,
            taskId: _taskAId,
            periodId: _periodAId,
            completedAt: DateTime.utc(2026, 8, 10, 8),
          ),
        ];
      final cached = StudySubject.fromJson(remote.toFullJson())
        ..progress = [
          _progress(
            subjectId: 'id',
            interventionId: _interventionBId,
            taskId: _taskBId,
            periodId: _periodBId,
            completedAt: DateTime.utc(2026, 8, 11, 8),
          ),
        ];
      await Cache.storeSubject(cached);
      Cache.debugUploadBlobFilesOverride = () async {};
      Cache.debugSaveProgressOverride = (p) async => p;
      Cache.debugSaveSubjectOverride = (s) async => s;

      final result = await Cache.synchronize(remote);
      final restored = await Cache.loadSubject();

      expect(result.succeeded, isTrue);
      expect(restored.progress, hasLength(2));
      expect(
        restored.progress.map((p) => p.taskId),
        containsAll([_taskAId, _taskBId]),
      );
    });

    test('a failed synchronization leaves the cache untouched and reports the '
        'error', () async {
      final remote = _buildSubject();
      final cached = StudySubject.fromJson(remote.toFullJson())
        ..progress = [
          _progress(
            subjectId: 'id',
            interventionId: _interventionAId,
            taskId: _taskAId,
            periodId: _periodAId,
            completedAt: DateTime.utc(2026, 8, 10, 8),
          ),
        ];
      await Cache.storeSubject(cached);
      Cache.debugUploadBlobFilesOverride = () =>
          Future<void>.error(Exception('failed to fetch'));

      final result = await Cache.synchronize(remote);

      expect(result.succeeded, isFalse);
      expect(result.error, isNotNull);
      final restored = await Cache.loadSubject();
      expect(restored.progress, hasLength(1));
    });
  });
}
