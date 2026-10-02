import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/deferred_fitbit_request.dart';
import 'package:studyu_app/util/active_subject_sync_controller.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/deferred_fitbit_sync.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/study_local_cleanup.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};
  late StudySubject subject;
  late QuestionnaireTask task;
  late FitbitQuestion question;
  final uploaded = <SubjectProgress>[];
  String? failWriteKey;
  setUp(() {
    ActiveSubjectSyncController.instance.debugResetForTesting();
    failWriteKey = null;
    storage.clear();
    uploaded.clear();
    Cache.debugResetSynchronizationStateForTesting();
    question = FitbitQuestion.withId(
      questionType: FitbitQuestion.questionType,
      types: [FitbitQuestionType.steps],
    );
    task = QuestionnaireTask.withId()..questions.questions = [question];
    final study = Study('study', 'user')
      ..interventions = [Intervention('intervention', 'Intervention')]
      ..observations = [task];
    subject = StudySubject.fromStudy(study, 'user', ['intervention'], null)
      ..startedAt = DateTime.utc(2020);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          final args = call.arguments as Map<Object?, Object?>;
          final key = args['key']! as String;
          if (call.method == 'write' && key == failWriteKey) {
            throw PlatformException(code: 'storage_full');
          }
          return switch (call.method) {
            'read' => storage[key],
            'write' => storage[key] = args['value']! as String,
            'containsKey' => storage.containsKey(key),
            'delete' => storage.remove(key),
            _ => throw UnimplementedError(call.method),
          };
        });
    Cache.debugUploadBlobFilesOverride = () async {};
    Cache.debugSaveProgressOverride = (p) async {
      uploaded.add(p);
      return p;
    };
    Cache.debugSaveSubjectOverride = (s) async => s;
    FitbitHandler.debugResolveDeferredRequestOverride = (_, r, _) async => [
      FitbitStepData(5, r.windowEnd),
    ];
  });
  tearDown(() {
    ActiveSubjectSyncController.instance.debugResetForTesting();
    Cache.debugResetSynchronizationStateForTesting();
    FitbitHandler.debugResolveDeferredRequestOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  Future<void> defer(DateTime time) => persistDeferredFitbitQuestionnaireResult(
    subject: subject,
    task: task,
    interventionId: 'intervention',
    periodId: 'period',
    questionnaireState: QuestionnaireState()
      ..answers[question.id] = (Answer<List<String>>(question.id, time)
        ..response = []),
    completedAt: time,
  );
  StudySubject remote() =>
      StudySubject.fromJson(subject.toFullJson())..progress = [];

  test('mixed media and deferred Fitbit answers stage files before durable queue storage', () async {
    final directory = await Directory.systemTemp.createTemp(
      'studyu-deferred-media-',
    );
    const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (_) async => directory.path);
    addTearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathChannel, null);
      await directory.delete(recursive: true);
    });
    final file = File('${directory.path}/staging.jpg');
    await file.writeAsBytes([1, 2, 3]);
    final state = QuestionnaireState()
      ..answers[question.id] = (Answer<List<String>>(
        question.id,
        DateTime.utc(2020, 1, 2),
      )..response = [])
      ..answers['photo'] = (Answer<FutureBlobFile>(
        'photo',
        DateTime.utc(2020, 1, 2),
      )..response = FutureBlobFile(file.path, 'photo-id'));
    await persistDeferredFitbitQuestionnaireResult(
      subject: subject,
      task: task,
      interventionId: 'intervention',
      periodId: 'period',
      questionnaireState: state,
      completedAt: DateTime.utc(2020, 1, 2),
    );
    expect(state.answers['photo']!.response, 'photo-id');
    expect(
      await File('${directory.path}/multimodal-upload/photo-id').exists(),
      isTrue,
    );
    final restored = await Cache.loadSubject();
    expect(
      (restored.progress.single.result.result as QuestionnaireState)
          .answers['photo']!
          .response,
      'photo-id',
    );
  });

  test(
    'queue overflow leaves media staged and does not prepare rejected answers',
    () async {
      await Cache.storeDeferredFitbitRequests(
        List.generate(
          Cache.maxDeferredFitbitRequests,
          (i) => DeferredFitbitRequest(
            subjectId: subject.id,
            interventionId: 'intervention',
            taskId: task.id,
            periodId: 'period',
            questionId: question.id,
            windowStart: DateTime.utc(2020),
            windowEnd: DateTime.utc(2020, 1, 2),
            completedAt: DateTime.utc(
              2020,
              1,
              2,
            ).add(Duration(microseconds: i)),
          ),
        ),
      );
      final state = QuestionnaireState()
        ..answers[question.id] = (Answer<List<String>>(
          question.id,
          DateTime.utc(2020, 1, 3),
        )..response = [])
        ..answers['photo'] = (Answer<FutureBlobFile>(
          'photo',
          DateTime.utc(2020, 1, 3),
        )..response = FutureBlobFile('/not-accessed/staging.jpg', 'photo-id'));
      await expectLater(
        persistDeferredFitbitQuestionnaireResult(
          subject: subject,
          task: task,
          interventionId: 'intervention',
          periodId: 'period',
          questionnaireState: state,
          completedAt: DateTime.utc(2020, 1, 3),
        ),
        throwsA(isA<DeferredFitbitQueueFullException>()),
      );
      expect(state.answers['photo']!.response, isA<FutureBlobFile>());
      expect(
        await Cache.loadDeferredFitbitRequests(),
        hasLength(Cache.maxDeferredFitbitRequests),
      );
    },
  );
  test('deferred-only synchronization uploads staged media before questionnaire progress', () async {
    await defer(DateTime.utc(2020, 1, 2));
    final calls = <String>[];
    Cache.debugUploadBlobFilesOverride = () async => calls.add('media');
    Cache.debugSaveProgressOverride = (p) async {
      calls.add('progress');
      return p;
    };
    expect((await Cache.synchronize(remote())).succeeded, isTrue);
    expect(calls, ['media', 'progress']);
  });
  test(
    'a successful empty Fitbit window syncs other answers and permits deletion',
    () async {
      final time = DateTime.utc(2020, 1, 2);
      final state = QuestionnaireState()
        ..answers[question.id] = (Answer<List<String>>(question.id, time)
          ..response = [])
        ..answers['ordinary'] = (Answer<bool>('ordinary', time)
          ..response = true);
      await persistDeferredFitbitQuestionnaireResult(
        subject: subject,
        task: task,
        interventionId: 'intervention',
        periodId: 'period',
        questionnaireState: state,
        completedAt: time,
      );
      FitbitHandler.debugResolveDeferredRequestOverride = (_, _, _) async => [];
      final server = remote();
      final result = await Cache.synchronize(server);
      expect(result.succeeded, isTrue);
      expect(uploaded, hasLength(1));
      expect(
        (uploaded.single.result.result as QuestionnaireState)
            .answers['ordinary']!
            .response,
        isTrue,
      );
      expect(await Cache.loadDeferredFitbitRequests(), isEmpty);
      ActiveSubjectSyncController.instance.debugFetchSubjectOverride = (
        _,
      ) async => result.subject;
      expect(await synchronizeBeforeSubjectDeletion(result.subject), isTrue);
    },
  );
  test('replaces placeholder, persists result, and removes request', () async {
    await defer(DateTime.utc(2020, 1, 2));
    final result = await Cache.synchronize(remote());
    expect(result.succeeded, isTrue);
    expect(uploaded, hasLength(1));
    expect(
      (uploaded.single.result.result as QuestionnaireState)
          .answers[question.id]!
          .response,
      isNotEmpty,
    );
    expect(await Cache.loadDeferredFitbitRequests(), isEmpty);
    expect((await Cache.loadSubject()).progress, result.subject.progress);
  });
  for (final networkFailure in [false, true]) {
    test(
      'deferred failures keep retry state separate from connection health: $networkFailure',
      () async {
        await defer(DateTime.utc(2020, 1, 2));
        final error = networkFailure
            ? const SocketException('offline')
            : StateError('revoked authorization');
        FitbitHandler.debugResolveDeferredRequestOverride = (_, _, _) async =>
            throw error;
        appConnectionStatusController.setStatus(
          AppConnectionStatus.deviceOffline,
        );
        ActiveSubjectSyncController.instance.debugFetchSubjectOverride = (
          _,
        ) async => remote();
        final result = await ActiveSubjectSyncController.instance
            .synchronizeNow(subject);
        expect(result.succeeded, isFalse);
        expect(result.error, same(error));
        expect(
          appConnectionStatusController.status == AppConnectionStatus.healthy,
          !networkFailure,
        );
        expect(await Cache.loadDeferredFitbitRequests(), hasLength(1));
      },
    );
  }
  test(
    'failed request does not starve a later completion in the same period',
    () async {
      await defer(DateTime.utc(2020, 1, 2));
      await defer(DateTime.utc(2020, 1, 3));
      FitbitHandler.debugResolveDeferredRequestOverride = (_, r, _) async {
        if (r.completedAt.day == 2) throw StateError('expired token');
        return [FitbitStepData(5, r.windowEnd)];
      };
      final result = await Cache.synchronize(remote());
      expect(result.succeeded, isFalse);
      expect(uploaded, hasLength(1));
      expect(uploaded.single.completedAt!.day, 3);
      expect(
        (await Cache.loadDeferredFitbitRequests()).single.completedAt.day,
        2,
      );
      expect((await Cache.loadSubject()).progress, hasLength(2));
    },
  );
  test(
    'ambiguous retry reconciles remote result without fetching again',
    () async {
      await defer(DateTime.utc(2020, 1, 2));
      final server = remote()
        ..progress = [
          SubjectProgress.fromJson(subject.progress.single.toJson()),
        ];
      (server.progress.single.result.result as QuestionnaireState)
          .answers[question.id]!
          .response = [
        'resolved',
      ];
      FitbitHandler.debugResolveDeferredRequestOverride = (_, _, _) async =>
          throw StateError('must not fetch');
      final result = await Cache.synchronize(server);
      expect(result.succeeded, isTrue);
      expect(uploaded, isEmpty);
      expect(await Cache.loadDeferredFitbitRequests(), isEmpty);
      expect((await Cache.loadSubject()).progress, server.progress);
    },
  );
  test('multiple questions upload one complete questionnaire', () async {
    final second = FitbitQuestion.withId(
      questionType: FitbitQuestion.questionType,
      types: [FitbitQuestionType.steps],
    );
    task.questions.questions.add(second);
    final time = DateTime.utc(2020, 1, 2);
    final answers = QuestionnaireState()
      ..answers[question.id] = (Answer<List<String>>(question.id, time)
        ..response = [])
      ..answers[second.id] = (Answer<List<String>>(second.id, time)
        ..response = []);
    await persistDeferredFitbitQuestionnaireResult(
      subject: subject,
      task: task,
      interventionId: 'intervention',
      periodId: 'period',
      questionnaireState: answers,
      completedAt: time,
    );
    expect(await Cache.loadDeferredFitbitRequests(), hasLength(2));
    expect((await Cache.synchronize(remote())).succeeded, isTrue);
    expect(uploaded, hasLength(1));
    expect(
      (uploaded.single.result.result as QuestionnaireState).answers.values
          .every((a) => (a.response as List).isNotEmpty),
      isTrue,
    );
  });
  test('subject switch leaves other requests untouched', () async {
    await defer(DateTime.utc(2020, 1, 2));
    final other = remote()..id = 'other';
    await Cache.synchronize(other);
    expect(await Cache.loadDeferredFitbitRequests(), hasLength(1));
    expect(uploaded, isEmpty);
  });
  test(
    'queue payload survives a missing subject cache after interruption',
    () async {
      await defer(DateTime.utc(2020, 1, 2));
      final server = remote();
      await Cache.delete();
      final result = await Cache.synchronize(server);
      expect(result.succeeded, isTrue);
      expect(uploaded, hasLength(1));
      expect(await Cache.loadDeferredFitbitRequests(), isEmpty);
    },
  );
  test(
    'two same-time completions receive distinct persisted timestamps',
    () async {
      await defer(DateTime.utc(2020, 1, 2));
      await defer(DateTime.utc(2020, 1, 2));
      final requests = await Cache.loadDeferredFitbitRequests();
      expect(requests, hasLength(2));
      expect(
        requests.last.completedAt.isAfter(requests.first.completedAt),
        isTrue,
      );
    },
  );
  test(
    'one retry pass uploads plain progress and resolves a queued Fitbit task',
    () async {
      await defer(DateTime.utc(2020, 1, 2));
      subject.progress.add(
        SubjectProgress(
          subjectId: subject.id,
          interventionId: 'intervention',
          taskId: 'plain',
          resultType: 'bool',
          result: Result<bool>.app(
            type: 'bool',
            periodId: 'period',
            result: true,
          ),
        )..completedAt = DateTime.utc(2020, 1, 3),
      );
      await Cache.storeSubject(subject);
      final controller = ActiveSubjectSyncController.instance;
      controller.debugFetchSubjectOverride = (_) async => remote();
      controller.onActiveSubjectChanged(subject);
      final result = await controller.synchronizeNow(subject);
      expect(result.succeeded, isTrue);
      expect(uploaded, hasLength(2));
      expect(uploaded.where((p) => p.resultType == 'bool'), hasLength(1));
      expect(await Cache.loadDeferredFitbitRequests(), isEmpty);
      expect((await Cache.loadSubject()).progress, hasLength(2));
    },
  );
  test(
    'queued windows chain instead of fetching the previous window twice',
    () async {
      await defer(DateTime.utc(2020, 1, 2));
      await defer(DateTime.utc(2020, 1, 3));
      final requests = await Cache.loadDeferredFitbitRequests();
      expect(requests.last.windowStart, requests.first.windowEnd);
    },
  );
  test('queue write failure cannot mark a task complete', () async {
    failWriteKey = 'deferred_fitbit_requests';
    await expectLater(
      defer(DateTime.utc(2020, 1, 2)),
      throwsA(isA<PlatformException>()),
    );
    expect(subject.progress, isEmpty);
    expect(await Cache.loadDeferredFitbitRequests(), isEmpty);
  });
  test(
    'durable queue restores completion when the subject-cache write fails',
    () async {
      await Cache.storeSubject(subject);
      failWriteKey = cacheSubjectKey;
      await defer(DateTime.utc(2020, 1, 2));
      final restored = await Cache.loadSubject();
      expect(restored.progress, hasLength(1));
      expect(await Cache.loadDeferredFitbitRequests(), hasLength(1));
    },
  );
  test('subject save failure retains requests for ambiguous retry', () async {
    await defer(DateTime.utc(2020, 1, 2));
    Cache.debugSaveSubjectOverride = (_) async =>
        throw StateError('lost response');
    expect((await Cache.synchronize(remote())).succeeded, isFalse);
    expect(await Cache.loadDeferredFitbitRequests(), hasLength(1));
    expect((await Cache.loadSubject()).progress, hasLength(1));
  });
  test('one failed question cannot upload a partial questionnaire', () async {
    final second = FitbitQuestion.withId(
      questionType: FitbitQuestion.questionType,
      types: [FitbitQuestionType.steps],
    );
    task.questions.questions.add(second);
    final time = DateTime.utc(2020, 1, 2);
    final answers = QuestionnaireState()
      ..answers[question.id] = (Answer<List<String>>(question.id, time)
        ..response = [])
      ..answers[second.id] = (Answer<List<String>>(second.id, time)
        ..response = []);
    await persistDeferredFitbitQuestionnaireResult(
      subject: subject,
      task: task,
      interventionId: 'intervention',
      periodId: 'period',
      questionnaireState: answers,
      completedAt: time,
    );
    FitbitHandler.debugResolveDeferredRequestOverride = (_, request, _) async {
      if (request.questionId == second.id) throw StateError('expired');
      return [FitbitStepData(5, request.windowEnd)];
    };
    expect((await Cache.synchronize(remote())).succeeded, isFalse);
    expect(uploaded, isEmpty);
    expect(await Cache.loadDeferredFitbitRequests(), hasLength(2));
  });
  test('cached Fitbit configuration survives actual secure storage', () async {
    subject.study.fitbitCredentials = StudyFitbitCredentials(
      subject.study.id,
      FitbitAuthCredentials(clientId: 'client', clientSecret: 'secret'),
    );
    await Cache.storeSubject(subject);
    final restored = await Cache.loadSubject();
    expect(
      restored.study.fitbitCredentials!.fitbitCredentials.clientId,
      'client',
    );
    expect(FitbitHandler.requiredTypesForStudy(restored.study), [
      FitbitQuestionType.steps,
    ]);
  });
}
