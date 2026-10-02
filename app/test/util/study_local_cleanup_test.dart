import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/util/active_subject_sync_controller.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/study_local_cleanup.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

StudySubject _buildSubject() {
  final study = Study('study-id', 'user-id')
    ..interventions = [Intervention('intervention-a', 'Intervention A')];
  return StudySubject.fromStudy(study, 'user-id', ['intervention-a'], null)
    ..startedAt = DateTime.now().subtract(const Duration(days: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = <String, String>{};
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory documents;

  setUp(() {
    storage.clear();
    documents = Directory.systemTemp.createTempSync('studyu-cleanup-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (_) async => documents.path);
    ActiveSubjectSyncController.instance.debugResetForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (call) async {
          final arguments = call.arguments as Map<Object?, Object?>;
          final key = arguments['key'] as String?;
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
    ActiveSubjectSyncController.instance.debugResetForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, null);
    if (documents.existsSync()) documents.deleteSync(recursive: true);
  });

  group('clearStudyLocalData', () {
    test('runs the injected local-identity cleanup and clears Fitbit '
        'credentials for the study', () async {
      var identityRefsCleared = false;
      storage.putIfAbsent('fitbit_credentials_study-id', () => 'x');

      await clearStudyLocalData(
        studyId: 'study-id',
        clearLocalIdentityRefs: () async {
          identityRefsCleared = true;
        },
      );

      expect(identityRefsCleared, isTrue);
      expect(storage.containsKey('fitbit_credentials_study-id'), isFalse);
    });
  });

  group('deleteStudySubjectAndClearLocalData', () {
    test('a failed final sync blocks the delete, preserves local data, and '
        'resumes synchronization', () async {
      final subject = _buildSubject();
      var remoteDeleteCalled = false;
      var identityRefsCleared = false;
      var onClearedCalled = false;
      ActiveSubjectSyncController.instance.onActiveSubjectChanged(subject);

      final deleted = await deleteStudySubjectAndClearLocalData(
        subject: subject,
        synchronizeBeforeDelete: (_) async => false,
        deleteRemoteSubject: () async {
          remoteDeleteCalled = true;
        },
        clearLocalIdentityRefs: () async {
          identityRefsCleared = true;
        },
        onLocalDataCleared: () {
          onClearedCalled = true;
        },
      );

      expect(deleted, isFalse);
      expect(remoteDeleteCalled, isFalse);
      expect(identityRefsCleared, isFalse);
      expect(onClearedCalled, isFalse);
      expect(ActiveSubjectSyncController.instance.debugIsPaused, isFalse);
    });

    test('a successful final sync proceeds to delete remote, clear local data, '
        'and notify the caller', () async {
      final subject = _buildSubject();
      var remoteDeleteCalled = false;
      var identityRefsCleared = false;
      var onClearedCalled = false;

      final deleted = await deleteStudySubjectAndClearLocalData(
        subject: subject,
        synchronizeBeforeDelete: (_) async => true,
        deleteRemoteSubject: () async {
          remoteDeleteCalled = true;
        },
        clearLocalIdentityRefs: () async {
          identityRefsCleared = true;
        },
        onLocalDataCleared: () {
          onClearedCalled = true;
        },
      );

      expect(deleted, isTrue);
      expect(remoteDeleteCalled, isTrue);
      expect(identityRefsCleared, isTrue);
      expect(onClearedCalled, isTrue);
    });

    test('the sync controller and Cache are both paused for the duration of '
        'the attempt and resumed afterwards', () async {
      final subject = _buildSubject();
      bool? controllerPausedDuringSync;
      bool? cachePausedDuringCleanup;

      await deleteStudySubjectAndClearLocalData(
        subject: subject,
        synchronizeBeforeDelete: (_) async {
          controllerPausedDuringSync =
              ActiveSubjectSyncController.instance.debugIsPaused;
          return true;
        },
        deleteRemoteSubject: () async {},
        clearLocalIdentityRefs: () async {
          cachePausedDuringCleanup = Cache.debugIsSynchronizationPaused;
        },
        onLocalDataCleared: () {},
      );

      expect(controllerPausedDuringSync, isTrue);
      expect(cachePausedDuringCleanup, isTrue);
      expect(ActiveSubjectSyncController.instance.debugIsPaused, isFalse);
      expect(Cache.debugIsSynchronizationPaused, isFalse);
    });

    test('a partial failure — remote deleted but local cleanup throws — '
        'propagates the error instead of swallowing it', () async {
      final subject = _buildSubject();
      var remoteDeleteCalled = false;

      await expectLater(
        () => deleteStudySubjectAndClearLocalData(
          subject: subject,
          synchronizeBeforeDelete: (_) async => true,
          deleteRemoteSubject: () async {
            remoteDeleteCalled = true;
          },
          clearLocalIdentityRefs: () {
            throw Exception('local cleanup failed');
          },
          onLocalDataCleared: () {},
        ),
        throwsException,
      );

      expect(remoteDeleteCalled, isTrue);
      // The controller must still be resumed even though the operation
      // threw — a partial failure shouldn't also leave sync stuck paused.
      expect(ActiveSubjectSyncController.instance.debugIsPaused, isFalse);
    });
  });
  test('a confirmed missing subject permits local cleanup without another remote delete', () async {
    final subject = _buildSubject();
    await Cache.storeSubject(subject);
    ActiveSubjectSyncController.instance.onActiveSubjectChanged(subject);
    ActiveSubjectSyncController.instance.debugFetchSubjectOverride =
        (_) async => throw const PostgrestException(
          message: 'No rows',
          code: 'PGRST116',
        );
    var cleared = false;
    final deleted = await deleteStudySubjectAndClearLocalData(
      subject: subject,
      synchronizeBeforeDelete: synchronizeBeforeSubjectDeletion,
      deleteRemoteSubject: () async => fail('must not delete again'),
      clearLocalIdentityRefs: () async => cleared = true,
      onLocalDataCleared: () {},
    );
    expect(deleted, isTrue);
    expect(cleared, isTrue);
    expect(storage.containsKey('cache_subject'), isFalse);
    expect(
      ActiveSubjectSyncController.instance.debugIsRetryTimerActive,
      isFalse,
    );
  });
  for (final remoteFails in [false, true]) {
    test(
      'consented discard removes only this participant media after successful remote deletion: failure=$remoteFails',
      () async {
        final subject = _buildSubject();
        final uploads = Directory('${documents.path}/multimodal-upload')
          ..createSync();
        final ownFile = File(
          '${uploads.path}/user-id_user-id_study-id_study-id_123.m4a',
        )..writeAsBytesSync([1]);
        final otherFile = File(
          '${uploads.path}/user-id_other_study-id_study-id_123.m4a',
        )..writeAsBytesSync([2]);
        final deletion = deleteStudySubjectAndClearLocalData(
          subject: subject,
          synchronizeBeforeDelete: (_) async => false,
          confirmDiscardUnsyncedData: () async => true,
          deleteRemoteSubject: () async {
            if (remoteFails) throw StateError('delete failed');
          },
          clearLocalIdentityRefs: () async {},
          onLocalDataCleared: () {},
        );
        if (remoteFails) {
          await expectLater(deletion, throwsStateError);
        } else {
          expect(await deletion, isTrue);
        }
        expect(ownFile.existsSync(), remoteFails);
        expect(otherFile.existsSync(), isTrue);
      },
    );
  }
  for (final confirmed in [false, true]) {
    test(
      'unsynced data is discarded only with explicit confirmation: $confirmed',
      () async {
        final subject = _buildSubject();
        await Cache.storeSubject(subject);
        var remoteDeleted = false;
        final result = await deleteStudySubjectAndClearLocalData(
          subject: subject,
          synchronizeBeforeDelete: (_) async => false,
          confirmDiscardUnsyncedData: () async => confirmed,
          deleteRemoteSubject: () async => remoteDeleted = true,
          clearLocalIdentityRefs: () async {},
          onLocalDataCleared: () {},
        );
        expect(result, confirmed);
        expect(remoteDeleted, confirmed);
        expect(storage.containsKey('cache_subject'), !confirmed);
      },
    );
  }
  test(
    'failed final-sync exception resumes retries and preserves local data',
    () async {
      final subject = _buildSubject();
      await expectLater(
        deleteStudySubjectAndClearLocalData(
          subject: subject,
          synchronizeBeforeDelete: (_) async => throw StateError('sync failed'),
          deleteRemoteSubject: () async => fail('must not delete'),
          clearLocalIdentityRefs: () async => fail('must not clear'),
          onLocalDataCleared: () => fail('must not clear'),
        ),
        throwsStateError,
      );
      expect(ActiveSubjectSyncController.instance.debugIsPaused, isFalse);
    },
  );
}
