import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'mock_nutrition_draft_storage.dart';

void main() {
  setUp(() => mockNutritionDraftStorage());

  test(
    'rekeys only the matching pinned correction after preview advance',
    () async {
      final now = DateTime.utc(2026, 7, 17, 12);
      final subject = _subject(daysAgo: 2)
        ..startedAt = now.subtract(const Duration(days: 2));
      final oldTimestamp = now;
      final movedTimestamp = now.subtract(const Duration(days: 1));
      final original = _recall('preview-recall', studyDay: 1)
        ..entryCompletedAt = oldTimestamp;
      final progress = SubjectProgress(
        subjectId: subject.id,
        taskId: 'task',
        interventionId: 'intervention',
        resultType: 'DailyRecall',
        result: Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: 'period',
          result: original,
        ),
      )..completedAt = movedTimestamp;
      subject.progress.add(progress);
      final manager = NutritionRecallAutoSaveManager();
      final correction = DailyRecall.fromJson(original.toJson())
        ..waterIntakeMl = 250;
      await manager.saveRecall(
        recall: correction,
        subjectId: subject.id,
        taskId: 'task',
        periodId: 'period',
        interventionId: 'intervention',
        studyDaySnapshot: 1,
        progressCompletedAt: oldTimestamp,
        nutritionRevision: 2,
      );
      progress.nutritionRevision = 3;
      await manager.rekeyTrackedPreviewDrafts(subject);
      expect(
        (await manager.scanPendingRecalls(subject.id))
            .single
            .progressCompletedAt,
        oldTimestamp,
      );

      progress.nutritionRevision = 2;
      await manager.rekeyTrackedPreviewDrafts(subject);
      final pending = (await manager.scanPendingRecalls(subject.id)).single;
      expect(pending.progressCompletedAt, movedTimestamp);
      expect(pending.nutritionRevision, 2);
      expect(pending.recall.waterIntakeMl, 250);
      expect(pending.recall.entryCompletedAt, oldTimestamp);
    },
  );

  group('a staged create after tracked preview advances', () {
    final now = DateTime.utc(2026, 7, 17, 12);
    final oldDate = DateTime.utc(2026, 7, 17);
    final shiftedDate = DateTime.utc(2026, 7, 16);
    final movedTimestamp = now.subtract(const Duration(days: 1));
    late NutritionRecallAutoSaveManager manager;
    late StudySubject subject;
    late DailyRecall staged;
    late MockClientHandler handleRequest;

    setUpAll(() {
      final supabase = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) => handleRequest(request)),
      );
      setEnv(
        'https://example.supabase.co',
        'test-key',
        supabaseClient: supabase,
      );
      addTearDown(supabase.dispose);
    });

    setUp(() async {
      subject = _subject(daysAgo: 1)
        ..startedAt = now.subtract(const Duration(days: 1));
      manager = NutritionRecallAutoSaveManager();
      staged = _recall('preview-create', studyDay: 1)
        ..date = oldDate
        ..entryStartedAt = now
        ..entryCompletedAt = now
        ..lastAutoSavedAt = now
        ..waterIntakeMl = 250;
      await _save(manager, staged);
      final pending = (await manager.scanPendingRecalls(subject.id)).single;
      expect(await manager.stageRecallUpload(pending, staged), isTrue);
      await _save(
        manager,
        DailyRecall.fromJson(staged.toJson())..waterIntakeMl = 500,
      );
      await subject.setStartDateBackBy(days: 1, persist: false);
    });

    Future<bool> submit() => manager.submitPendingRecalls(
      subject: subject,
      trackProgress: true,
      trackedPreview: true,
      now: now,
    );

    Map<String, dynamic> progressJson(Map<String, dynamic> result) => {
      'subject_id': subject.id,
      'task_id': 'task',
      'intervention_id': 'intervention',
      'completed_at': movedTimestamp.toIso8601String(),
      'result_type': 'DailyRecall',
      'nutrition_revision': 0,
      'result': result,
    };

    void expectIdentityQuery(http.Request request) {
      expect(request.method, 'GET');
      expect(request.url.path, endsWith('/subject_progress'));
      expect(
        request.url.queryParameters,
        containsPair('subject_id', 'eq.subject'),
      );
      expect(request.url.queryParameters, containsPair('task_id', 'eq.task'));
      expect(
        request.url.queryParameters,
        containsPair('result->>periodId', 'eq.period'),
      );
      expect(
        request.url.queryParameters,
        containsPair('result->result->>studyDaySnapshot', 'eq.1'),
      );
    }

    test('restages newer edits after the server confirms absence', () async {
      final methods = <String>[];
      handleRequest = (request) async {
        methods.add(request.method);
        if (request.method == 'GET') {
          expectIdentityQuery(request);
          return _jsonResponse(request, []);
        }
        expect(request.url.path, endsWith('/save_nutrition_recall'));
        final params = jsonDecode(request.body) as Map<String, dynamic>;
        final payload = params['p_result'] as Map<String, dynamic>;
        final sent = DailyRecall.fromJson(
          payload['result'] as Map<String, dynamic>,
        );
        final pending = (await manager.scanPendingRecalls(subject.id)).single;
        expect(sent.date, shiftedDate);
        expect(sent.waterIntakeMl, 500);
        expect(sent.toJson(), pending.stagedUpload!.toJson());
        expect(params['p_expected_revision'], isNull);
        return _jsonResponse(request, progressJson(payload));
      };

      expect(await submit(), isFalse);
      expect(methods, ['GET', 'POST']);
      expect(await manager.scanPendingRecalls(subject.id), isEmpty);
    });

    test(
      'rebases newer edits on an exact save that the server moved',
      () async {
        final methods = <String>[];
        handleRequest = (request) async {
          methods.add(request.method);
          if (request.method == 'GET') {
            expectIdentityQuery(request);
            return _jsonResponse(request, [
              progressJson(
                Result<DailyRecall>.app(
                  type: 'DailyRecall',
                  periodId: 'period',
                  result: staged,
                ).toJson(),
              ),
            ]);
          }
          expect(request.url.path, endsWith('/save_nutrition_recall'));
          final params = jsonDecode(request.body) as Map<String, dynamic>;
          final payload = params['p_result'] as Map<String, dynamic>;
          final sent = DailyRecall.fromJson(
            payload['result'] as Map<String, dynamic>,
          );
          expect(sent.date, oldDate);
          expect(sent.waterIntakeMl, 500);
          expect(params['p_expected_revision'], 0);
          expect(params['p_completed_at'], movedTimestamp.toIso8601String());
          return _jsonResponse(
            request,
            progressJson(payload)..['nutrition_revision'] = 1,
          );
        };

        expect(await submit(), isFalse);
        expect(methods, ['GET', 'POST']);
        final saved = subject.progress.single;
        expect(saved.completedAt, movedTimestamp);
        expect(saved.nutritionRevision, 1);
        expect(await manager.scanPendingRecalls(subject.id), isEmpty);
      },
    );

    test('keeps the snapshot when the server lookup fails', () async {
      handleRequest = (request) async {
        expectIdentityQuery(request);
        throw const SocketException('offline');
      };

      expect(await submit(), isTrue);
      final pending = (await manager.scanPendingRecalls(subject.id)).single;
      expect(pending.stagedUpload?.toJson(), staged.toJson());
      expect(pending.recall.waterIntakeMl, 500);
    });
  });

  test(
    'stale corrections stay local even with a newer device timestamp',
    () async {
      final now = DateTime.utc(2026, 7, 17, 12);
      final completedAt = now.subtract(const Duration(days: 1));
      final subject = _subject(daysAgo: 2)
        ..startedAt = now.subtract(const Duration(days: 2));
      final canonical = _recall('same-recall', studyDay: 1)
        ..entryCompletedAt = completedAt
        ..lastAutoSavedAt = completedAt
        ..waterIntakeMl = 500;
      subject.progress.add(
        SubjectProgress(
            subjectId: subject.id,
            interventionId: 'intervention',
            taskId: 'task',
            resultType: 'DailyRecall',
            result: Result<DailyRecall>.app(
              type: 'DailyRecall',
              periodId: 'period',
              result: canonical,
            ),
          )
          ..completedAt = completedAt
          ..nutritionRevision = 2,
      );
      final submitted = <DailyRecall>[];
      final manager = NutritionRecallAutoSaveManager(
        submitter: (_, result) async => submitted.add(result),
      );
      final correction = _recall(canonical.id, studyDay: 1)
        ..entryCompletedAt = completedAt
        ..lastAutoSavedAt = now
        ..waterIntakeMl = 250;

      Future<void> store(int revision) => manager.saveRecall(
        recall: correction,
        subjectId: subject.id,
        taskId: 'task',
        periodId: 'period',
        interventionId: 'intervention',
        studyDaySnapshot: 1,
        progressCompletedAt: completedAt,
        nutritionRevision: revision,
      );
      await store(1);
      await manager.submitPendingRecalls(
        subject: subject,
        trackProgress: true,
        now: now,
      );
      expect(submitted, isEmpty);
      expect(
        (await manager.scanPendingRecalls(subject.id))
            .single
            .recall
            .waterIntakeMl,
        250,
      );

      await store(2);
      await manager.submitPendingRecalls(
        subject: subject,
        trackProgress: true,
        now: now,
      );
      expect(submitted.single.waterIntakeMl, 250);
    },
  );

  test('add, edit, and delete cache the full recall immediately', () async {
    final manager = NutritionRecallAutoSaveManager();
    final subject = _subject(daysAgo: 0);
    final task = NutritionTask.withId();
    final viewModel = DailyRecallEntryViewModel(
      subject: subject,
      task: task,
      completionPeriod: task.schedule.completionPeriods.single,
      autoSaveManager: manager,
    );
    await Future<void>.delayed(Duration.zero);

    viewModel.addMeal(_meal('first'));
    await viewModel.flushPendingAutoSave();
    expect(
      (await manager.loadRecall(
        subjectId: subject.id,
        taskId: task.id,
        periodId: task.schedule.completionPeriods.single.id,
        studyDay: 0,
      ))!.meals.single.id,
      'first',
    );

    viewModel.updateMeal(0, _meal('updated'));
    await viewModel.flushPendingAutoSave();
    expect(
      (await manager.loadRecall(
        subjectId: subject.id,
        taskId: task.id,
        periodId: task.schedule.completionPeriods.single.id,
        studyDay: 0,
      ))!.meals.single.id,
      'updated',
    );

    viewModel.removeMeal(0);
    await viewModel.flushPendingAutoSave();
    expect(
      (await manager.loadRecall(
        subjectId: subject.id,
        taskId: task.id,
        periodId: task.schedule.completionPeriods.single.id,
        studyDay: 0,
      ))!.meals,
      isEmpty,
    );
    viewModel.dispose();
  });

  test('ordered writes retain the latest prepared snapshot', () async {
    final manager = NutritionRecallAutoSaveManager();

    await Future.wait([
      _save(manager, _recall('old', studyDay: 0)),
      _save(manager, _recall('new', studyDay: 0)),
    ]);

    expect(
      (await manager.loadRecall(
        subjectId: 'subject',
        taskId: 'task',
        periodId: 'period',
        studyDay: 0,
      ))!.id,
      'new',
    );
  });

  test(
    'period-distinct drafts coexist and retain persistence metadata',
    () async {
      final manager = NutritionRecallAutoSaveManager();
      final completedAt = DateTime.utc(2026, 7, 15, 12);

      await manager.saveRecall(
        recall: _recall('morning', studyDay: 3),
        subjectId: 'subject',
        taskId: 'task',
        interventionId: 'intervention-a',
        periodId: 'morning',
        studyDaySnapshot: 3,
        progressCompletedAt: completedAt,
      );
      await manager.saveRecall(
        recall: _recall('evening', studyDay: 3),
        subjectId: 'subject',
        taskId: 'task',
        interventionId: 'intervention-b',
        periodId: 'evening',
        studyDaySnapshot: 3,
      );

      expect(
        (await manager.loadRecall(
          subjectId: 'subject',
          taskId: 'task',
          periodId: 'morning',
          studyDay: 3,
        ))!.id,
        'morning',
      );
      final pending = await manager.scanPendingRecalls('subject');
      expect(pending, hasLength(2));
      expect(
        pending
            .singleWhere((recall) => recall.periodId == 'morning')
            .progressCompletedAt,
        completedAt,
      );
    },
  );

  test(
    'hydrates the current remote recall before restoring stale local data',
    () async {
      final manager = NutritionRecallAutoSaveManager();
      final subject = _subject(daysAgo: 2);
      final task = NutritionTask.withId();
      final period = CompletionPeriod(
        id: 'period',
        unlockTime: StudyUTimeOfDay(),
        lockTime: StudyUTimeOfDay(hour: 23),
      );
      final studyDay = subject.getDayOfStudyFor(DateTime.now());
      await manager.saveRecall(
        recall: _recall('local', studyDay: studyDay),
        subjectId: subject.id,
        taskId: task.id,
        interventionId: 'intervention',
        periodId: period.id,
        studyDaySnapshot: studyDay,
      );
      final completedAt = DateTime.now()
          .add(const Duration(minutes: 1))
          .toUtc();
      subject.progress.add(
        SubjectProgress(
          subjectId: subject.id,
          interventionId: 'intervention',
          taskId: task.id,
          resultType: 'DailyRecall',
          result: Result<DailyRecall>.app(
            type: 'DailyRecall',
            periodId: period.id,
            result: _recall('remote', studyDay: studyDay)
              ..entryCompletedAt = completedAt,
          ),
        )..completedAt = completedAt,
      );

      final viewModel = DailyRecallEntryViewModel(
        subject: subject,
        task: task,
        completionPeriod: period,
        autoSaveManager: manager,
      );
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.recall.id, 'remote');
      expect(viewModel.persistenceTarget?.completedAt, completedAt);
      expect(viewModel.hasDraftConflict, isTrue);
      expect(await viewModel.discardConflictingDraft(), isTrue);
      viewModel.addMeal(_meal('new'));
      await viewModel.flushPendingAutoSave();
      expect(
        (await manager.scanPendingRecalls(subject.id))
            .single
            .progressCompletedAt,
        completedAt,
      );
      viewModel.dispose();
    },
  );

  test('blocks edits until the local draft has loaded', () async {
    final manager = _DelayedRecallLoadManager();
    final subject = _subject(daysAgo: 2);
    final task = NutritionTask.withId();
    final period = CompletionPeriod(
      id: 'period',
      unlockTime: StudyUTimeOfDay(),
      lockTime: StudyUTimeOfDay(hour: 23),
    );
    final studyDay = subject.getDayOfStudyFor(DateTime.now());
    final viewModel = DailyRecallEntryViewModel(
      subject: subject,
      task: task,
      completionPeriod: period,
      autoSaveManager: manager,
    );
    await manager.loadStarted;

    expect(viewModel.canEdit, isFalse);
    viewModel.addMeal(_meal('edited'));
    expect(viewModel.recall.meals, isEmpty);
    manager.complete(
      PendingRecall(
        recall: _recall('cached', studyDay: studyDay),
        subjectId: subject.id,
        taskId: task.id,
        interventionId: 'intervention',
        periodId: period.id,
        studyDaySnapshot: studyDay,
        lastModifiedAt: DateTime.now().toIso8601String(),
        storageKey: 'cached',
      ),
    );
    await viewModel.initialized;

    expect(viewModel.canEdit, isTrue);
    expect(viewModel.recall.meals.single.id, 'cached');
    viewModel.addMeal(_meal('edited'));
    expect(viewModel.recall.meals.last.id, 'edited');
    viewModel.dispose();
  });

  test('flush reports a failed local cache write', () async {
    mockNutritionDraftStorage(
      beforeCall: (call) {
        if (call.method == 'write') throw StateError('Failed to write draft.');
      },
    );
    final manager = NutritionRecallAutoSaveManager();
    final task = NutritionTask.withId();
    final viewModel = DailyRecallEntryViewModel(
      subject: _subject(daysAgo: 0),
      task: task,
      completionPeriod: task.schedule.completionPeriods.single,
      autoSaveManager: manager,
    );
    await Future<void>.delayed(Duration.zero);

    viewModel.addMeal(_meal('unsaved'));

    await expectLater(
      viewModel.flushPendingAutoSave(),
      throwsA(isA<PlatformException>()),
    );
    viewModel.dispose();
  });

  test('completed UTC-current recall uploads despite the local day', () async {
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      submitter: (_, recall) async => submitted = recall,
    );
    final subject = _DivergentStudyDaySubject(localStudyDay: 0)
      ..startedAt = DateTime.utc(2026, 7, 15, 23, 30);
    final now = DateTime.utc(2026, 7, 16, 0, 15);
    await _save(
      manager,
      _recall('utc-current', studyDay: 1)..entryCompletedAt = now,
    );

    await manager.submitPendingRecalls(
      subject: subject,
      trackProgress: true,
      now: now,
    );

    expect(submitted?.id, 'utc-current');
    expect(submitted?.entryCompletedAt, now);
    expect(await manager.scanPendingRecalls(subject.id), isEmpty);
  });

  test('UTC-current draft stays cached despite the local day', () async {
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      submitter: (_, recall) async => submitted = recall,
    );
    final subject = _DivergentStudyDaySubject(localStudyDay: 2)
      ..startedAt = DateTime.utc(2026, 7, 15, 23, 30);
    await _save(manager, _recall('utc-current', studyDay: 1));

    await manager.submitPendingRecalls(
      subject: subject,
      trackProgress: true,
      now: DateTime.utc(2026, 7, 16, 0, 15),
    );

    expect(submitted, isNull);
    final pending = (await manager.scanPendingRecalls(subject.id)).single;
    expect(pending.recall.entryCompletedAt, isNull);
  });

  test('same-day draft uploads only after rollover', () async {
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      submitter: (_, recall) async => submitted = recall,
    );
    final now = DateTime.utc(2026, 7, 17, 12);
    final subject = _subject(daysAgo: 2)..startedAt = DateTime.utc(2026, 7, 15);
    final today = nutritionStudyDayFor(subject, now);
    await _save(manager, _recall('today', studyDay: today));

    await manager.submitPendingRecalls(
      subject: subject,
      trackProgress: true,
      now: now,
    );

    expect(submitted, isNull);
    expect(await manager.scanPendingRecalls(subject.id), hasLength(1));

    await manager.submitPendingRecalls(
      subject: subject,
      trackProgress: true,
      now: now.add(const Duration(days: 1)),
    );

    expect(submitted?.id, 'today');
    expect(submitted?.entryCompletedAt, isNotNull);
    expect(await manager.scanPendingRecalls(subject.id), isEmpty);
  });

  test('previous-day upload finalizes and deletes after success', () async {
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      submitter: (_, recall) async => submitted = recall,
    );
    final subject = _subject(daysAgo: 2);
    final today = subject.getDayOfStudyFor(DateTime.now());
    await _save(manager, _recall('yesterday', studyDay: today - 1));

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(submitted!.entryCompletedAt, isNotNull);
    expect(await manager.scanPendingRecalls(subject.id), isEmpty);
  });

  test(
    'historical correction keeps its existing completion metadata',
    () async {
      DailyRecall? submitted;
      DateTime? submittedTarget;
      final manager = NutritionRecallAutoSaveManager(
        submitter: (pending, recall) async {
          submitted = recall;
          submittedTarget = pending.progressCompletedAt;
        },
      );
      final subject = _subject(daysAgo: 2);
      final today = subject.getDayOfStudyFor(DateTime.now());
      final completedAt = DateTime.utc(2026, 7, 15, 12);
      final entryCompletedAt = DateTime.utc(2026, 7, 15, 11);
      final originalDiaryDate = DateTime.utc(2026, 7, 15);
      final canonical = _recall('canonical', studyDay: today - 1)
        ..entryCompletedAt = entryCompletedAt
        ..date = originalDiaryDate;
      await manager.saveRecall(
        recall: _recall(canonical.id, studyDay: today - 1)
          ..specialOccasion = 'correction'
          ..entryCompletedAt = entryCompletedAt
          ..date = originalDiaryDate,
        subjectId: subject.id,
        taskId: 'task',
        interventionId: 'intervention',
        periodId: 'period',
        studyDaySnapshot: today - 1,
        progressCompletedAt: completedAt,
        nutritionRevision: 0,
      );

      await manager.submitPendingRecalls(subject: subject, trackProgress: true);

      expect(submitted, isNull);
      expect(await manager.scanPendingRecalls(subject.id), hasLength(1));

      subject.progress.add(
        SubjectProgress(
          subjectId: subject.id,
          taskId: 'task',
          interventionId: 'intervention',
          resultType: 'DailyRecall',
          result: Result<DailyRecall>.app(
            type: 'DailyRecall',
            periodId: 'period',
            result: canonical,
          ),
        )..completedAt = completedAt,
      );

      await manager.submitPendingRecalls(subject: subject, trackProgress: true);

      expect(submitted?.specialOccasion, 'correction');
      expect(submitted?.entryCompletedAt, entryCompletedAt);
      expect(submitted?.date, originalDiaryDate);
      expect(submittedTarget, completedAt);
      expect(await manager.scanPendingRecalls(subject.id), isEmpty);
    },
  );

  test('rollover clamps completion to the captured UTC study day', () async {
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      submitter: (_, recall) async => submitted = recall,
    );
    final now = DateTime.utc(2025, 1, 1, 12);
    final subject = _subject(daysAgo: 2)
      ..startedAt = DateTime.utc(2024, 12, 30, 12);
    final recallDate = DateTime.parse('2025-01-01T00:30:00+01:00');
    await _save(
      manager,
      DailyRecall(
        id: 'after-local-midnight',
        date: recallDate,
        recallMode: RecallMode.realtimeRecord,
        entryStartedAt: recallDate,
        lastAutoSavedAt: DateTime.utc(2025, 1, 1, 0, 5),
        meals: [_meal('after-local-midnight')],
        studyDaySnapshot: 1,
      ),
    );

    await manager.submitPendingRecalls(
      subject: subject,
      trackProgress: true,
      now: now,
    );

    expect(submitted!.date, DateTime.utc(2024, 12, 31));
    expect(
      submitted!.entryCompletedAt,
      DateTime.utc(2024, 12, 31, 23, 59, 59, 999, 999),
    );
  });

  test(
    'failed recall deletion keeps the pending recall discoverable',
    () async {
      final savingManager = NutritionRecallAutoSaveManager();
      var failDelete = false;
      mockNutritionDraftStorage(
        beforeCall: (call) {
          if (failDelete && call.method == 'delete') {
            throw StateError('Failed to delete draft.');
          }
        },
      );
      final manager = NutritionRecallAutoSaveManager();
      await _save(savingManager, _recall('retry-delete', studyDay: 1));
      failDelete = true;

      await expectLater(
        manager.deleteRecall(
          subjectId: 'subject',
          taskId: 'task',
          periodId: 'period',
          studyDay: 1,
        ),
        throwsA(isA<PlatformException>()),
      );

      expect(
        (await manager.scanPendingRecalls('subject')).single.recall.id,
        'retry-delete',
      );
    },
  );

  test('newer recall survives previous-day submission', () async {
    final subject = _subject(daysAgo: 2);
    final today = subject.getDayOfStudyFor(DateTime.now());
    final newerManager = NutritionRecallAutoSaveManager();
    final submitterManager = NutritionRecallAutoSaveManager(
      submitter: (_, _) =>
          _save(newerManager, _recall('newer', studyDay: today - 1)),
    );
    await _save(submitterManager, _recall('submitted', studyDay: today - 1));

    await submitterManager.submitPendingRecalls(
      subject: subject,
      trackProgress: true,
    );

    expect(
      (await submitterManager.scanPendingRecalls(subject.id)).single.recall.id,
      'newer',
    );
  });

  test(
    'expired historical add edit delete and resume stay non-mutating',
    () async {
      final manager = NutritionRecallAutoSaveManager();
      final subject = _subject(daysAgo: 3);
      final currentDay = subject.getDayOfStudyFor(DateTime.now());
      final task = NutritionTask.withId();
      final period = CompletionPeriod(
        id: 'period',
        unlockTime: StudyUTimeOfDay(),
        lockTime: StudyUTimeOfDay(hour: 23),
      );
      final viewModel = DailyRecallEntryViewModel(
        subject: subject,
        task: task,
        completionPeriod: period,
        existingRecall: _recall('historical', studyDay: currentDay - 2),
        persistenceTarget: NutritionRecallPersistenceTarget(
          taskId: task.id,
          periodId: period.id,
          interventionId: 'intervention',
          completedAt: DateTime.now().toUtc(),
          studyDaySnapshot: currentDay - 2,
        ),
        historicalMode: true,
        autoSaveManager: manager,
      );

      viewModel.addMeal(_meal('added'));
      viewModel.updateMeal(0, _meal('edited'));
      viewModel.removeMeal(0);
      viewModel.onAppLifecycleStateChanged(AppLifecycleState.resumed);
      await viewModel.flushPendingAutoSave(persistToDatabase: true);

      expect(viewModel.historicalEligibilityExpired, isTrue);
      expect(viewModel.recall.meals.single.id, 'historical');
      expect(await manager.scanPendingRecalls(subject.id), isEmpty);
      viewModel.dispose();
    },
  );

  test(
    'nested definition mutation preserves canonical version through later save',
    () async {
      final manager = NutritionRecallAutoSaveManager();
      final subject = _subject(daysAgo: 2);
      final currentDay = subject.getDayOfStudyFor(DateTime.now());
      final task = NutritionTask.withId();
      final period = CompletionPeriod(
        id: 'period',
        unlockTime: StudyUTimeOfDay(),
        lockTime: StudyUTimeOfDay(hour: 23),
      );
      final target = NutritionRecallPersistenceTarget(
        taskId: task.id,
        periodId: period.id,
        interventionId: 'intervention',
        completedAt: DateTime.now().toUtc(),
        studyDaySnapshot: currentDay - 1,
        nutritionRevision: 0,
      );
      final remoteStarted = Completer<void>();
      final releaseRemote = Completer<void>();
      final events = <String>[];
      final remotelySaved = <DailyRecall>[];
      var remoteCall = 0;
      final viewModel = DailyRecallEntryViewModel(
        subject: subject,
        task: task,
        completionPeriod: period,
        existingRecall: _foodRecall('old', studyDay: currentDay - 1)
          ..entryCompletedAt = target.completedAt,
        persistenceTarget: target,
        historicalMode: true,
        autoSaveManager: manager,
        remoteSaver:
            ({
              required taskId,
              required periodId,
              required recall,
              required persistenceTarget,
              interventionIdOverride,
            }) async {
              expect(taskId, target.taskId);
              expect(periodId, target.periodId);
              expect(persistenceTarget?.taskId, target.taskId);
              expect(persistenceTarget?.periodId, target.periodId);
              expect(persistenceTarget?.interventionId, target.interventionId);
              expect(persistenceTarget?.completedAt, target.completedAt);
              expect(
                persistenceTarget?.studyDaySnapshot,
                target.studyDaySnapshot,
              );
              expect(interventionIdOverride, target.interventionId);
              remoteCall++;
              remotelySaved.add(DailyRecall.fromJson(recall.toJson()));
              events.add('autosave-$remoteCall-started');
              if (remoteCall == 1) {
                remoteStarted.complete();
                await releaseRemote.future;
              }
              events.add('autosave-$remoteCall-completed');
            },
      );
      await Future<void>.delayed(Duration.zero);

      viewModel.updateUsualIntake(true);
      final activeAutoSave = viewModel.flushPendingAutoSave(
        persistToDatabase: true,
      );
      await remoteStarted.future;

      var mutationStarted = false;
      final nestedMutation = () async {
        await viewModel.flushPendingAutoSave(
          persistToDatabase: true,
          requireRemoteSuccess: true,
        );
        mutationStarted = true;
        viewModel.suspendPersistence();
        try {
          events.add('definition-rpc');
          final canonicalRecall = _foodRecall('new', studyDay: currentDay - 1)
            ..entryCompletedAt = target.completedAt;
          canonicalRecall.meals.single.foods.single
            ..id = 'logged-entry'
            ..foodVersionId = 'version-2';
          subject.progress.add(
            SubjectProgress(
              subjectId: subject.id,
              interventionId: target.interventionId,
              taskId: target.taskId,
              resultType: 'DailyRecall',
              result: Result<DailyRecall>.app(
                type: 'DailyRecall',
                periodId: target.periodId,
                result: canonicalRecall,
              ),
            )..completedAt = target.completedAt,
          );
          await manager.rewriteFoodDefinition(
            subjectId: subject.id,
            studyDaySnapshot: currentDay - 1,
            definition: canonicalRecall.meals.single.foods.single,
            entryId: 'logged-entry',
          );

          viewModel.onAppLifecycleStateChanged(AppLifecycleState.paused);
          await viewModel.flushPendingAutoSave();
          expect(
            (await manager.scanPendingRecalls(subject.id))
                .single
                .recall
                .meals
                .single
                .foods
                .single
                .foodVersionId,
            'version-2',
          );
          await viewModel.reloadCanonicalRecall();
        } finally {
          viewModel.resumePersistence();
        }

        viewModel.updateSpecialOccasion('after definition mutation');
        await viewModel.flushPendingAutoSave(
          persistToDatabase: true,
          requireRemoteSuccess: true,
        );
      }();
      await Future<void>.delayed(Duration.zero);

      expect(mutationStarted, isFalse);
      expect(events, ['autosave-1-started']);
      releaseRemote.complete();
      await Future.wait([activeAutoSave, nestedMutation]);

      expect(mutationStarted, isTrue);
      expect(events, [
        'autosave-1-started',
        'autosave-1-completed',
        'autosave-2-started',
        'autosave-2-completed',
        'definition-rpc',
        'autosave-3-started',
        'autosave-3-completed',
      ]);
      expect(
        viewModel.recall.meals.single.foods.single.foodVersionId,
        'version-2',
      );
      expect(
        remotelySaved.last.meals.single.foods.single.foodVersionId,
        'version-2',
      );
      viewModel.dispose();
    },
  );

  test('failed strict historical flush prevents definition mutation', () async {
    final manager = NutritionRecallAutoSaveManager();
    final subject = _subject(daysAgo: 2);
    final currentDay = subject.getDayOfStudyFor(DateTime.now());
    final task = NutritionTask.withId();
    final period = CompletionPeriod(
      id: 'period',
      unlockTime: StudyUTimeOfDay(),
      lockTime: StudyUTimeOfDay(hour: 23),
    );
    final target = NutritionRecallPersistenceTarget(
      taskId: task.id,
      periodId: period.id,
      interventionId: 'intervention',
      completedAt: DateTime.now().toUtc(),
      studyDaySnapshot: currentDay - 1,
    );
    var mutationStarted = false;
    final viewModel = DailyRecallEntryViewModel(
      subject: subject,
      task: task,
      completionPeriod: period,
      existingRecall: _foodRecall('old', studyDay: currentDay - 1)
        ..entryCompletedAt = target.completedAt,
      persistenceTarget: target,
      historicalMode: true,
      autoSaveManager: manager,
      remoteSaver: ({
        required taskId,
        required periodId,
        required recall,
        required persistenceTarget,
        interventionIdOverride,
      }) async => throw StateError('remote flush failed'),
    );
    await Future<void>.delayed(Duration.zero);

    viewModel.updateUsualIntake(true);
    final mutation = () async {
      await viewModel.flushPendingAutoSave(
        persistToDatabase: true,
        requireRemoteSuccess: true,
      );
      mutationStarted = true;
    }();

    await expectLater(
      mutation,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'remote flush failed',
        ),
      ),
    );
    expect(mutationStarted, isFalse);
    viewModel.dispose();
  });

  test(
    'historical definition rewrite updates only the selected entry',
    () async {
      final manager = NutritionRecallAutoSaveManager();
      final selected = _food('old')..id = 'selected-entry';
      final sibling = FoodEntry.fromJson(selected.toJson())
        ..id = 'sibling-entry'
        ..name = 'sibling old';
      final recall = _foodRecall('old', studyDay: 4)
        ..meals.single.foods = [selected, sibling];
      await manager.saveRecall(
        recall: recall,
        subjectId: 'subject',
        taskId: 'historical-task',
        interventionId: 'intervention',
        periodId: 'period',
        studyDaySnapshot: 4,
      );

      await manager.rewriteFoodDefinition(
        subjectId: 'subject',
        studyDaySnapshot: 4,
        definition: _food('new', versionId: 'version-2'),
        entryId: selected.id,
      );

      final foods = (await manager.scanPendingRecalls('subject'))
          .single
          .recall
          .meals
          .single
          .foods;
      expect(foods.singleWhere((food) => food.id == selected.id).name, 'new');
      expect(
        foods.singleWhere((food) => food.id == sibling.id).name,
        'sibling old',
      );
    },
  );

  test(
    'definition rewrite advances the matching draft revision only',
    () async {
      final manager = NutritionRecallAutoSaveManager();
      final completedAt = DateTime.utc(2026, 7, 15, 12);
      final draft = _foodRecall('old', studyDay: 4)
        ..specialOccasion = 'Local note';
      final canonical = DailyRecall.fromJson(draft.toJson())
        ..specialOccasion = null;
      final saved =
          SubjectProgress(
              subjectId: 'subject',
              taskId: 'task',
              interventionId: 'intervention',
              resultType: 'DailyRecall',
              result: Result<DailyRecall>.app(
                type: 'DailyRecall',
                periodId: 'period',
                result: canonical,
              ),
            )
            ..completedAt = completedAt
            ..nutritionRevision = 3;
      Future<void> checkRebase(int revision, int expected) async {
        await manager.saveRecall(
          recall: draft,
          subjectId: saved.subjectId,
          taskId: saved.taskId,
          interventionId: saved.interventionId,
          periodId: 'period',
          studyDaySnapshot: 4,
          progressCompletedAt: completedAt,
          nutritionRevision: revision,
        );
        final before = (await manager.scanPendingRecalls(saved.subjectId))
            .single;
        expect(await manager.stageRecallUpload(before, before.recall), isTrue);
        await manager.rewriteFoodDefinition(
          subjectId: saved.subjectId,
          studyDaySnapshot: 4,
          definition: _food('new', versionId: 'version-2'),
          canonicalProgress: [saved],
        );
        final pending = (await manager.scanPendingRecalls(saved.subjectId))
            .single;
        expect(pending.nutritionRevision, expected);
        expect(pending.recall.specialOccasion, 'Local note');
        if (expected == revision) {
          expect(pending.stagedBaseRevision, revision);
          expect(pending.stagedUpload, isNotNull);
        } else {
          expect(pending.stagedUpload, isNull);
        }
      }

      await checkRebase(2, 3);
      await checkRebase(1, 1);
    },
  );

  test(
    'definition rewrite updates every matching current-day draft only',
    () async {
      final manager = NutritionRecallAutoSaveManager();
      final completedAt = DateTime.utc(2026, 7, 15, 12);
      for (final period in ['morning', 'evening']) {
        await manager.saveRecall(
          recall: _foodRecall('old', studyDay: 4),
          subjectId: 'subject',
          taskId: 'task-$period',
          interventionId: 'intervention-$period',
          periodId: period,
          studyDaySnapshot: 4,
          progressCompletedAt: completedAt,
        );
      }
      await manager.saveRecall(
        recall: _foodRecall('old', studyDay: 3),
        subjectId: 'subject',
        taskId: 'task-old-day',
        interventionId: 'intervention',
        periodId: 'old-day',
        studyDaySnapshot: 3,
      );

      await manager.rewriteFoodDefinition(
        subjectId: 'subject',
        studyDaySnapshot: 4,
        definition: _food('new', versionId: 'version-2'),
      );

      final pending = await manager.scanPendingRecalls('subject');
      final current = pending.where((entry) => entry.studyDaySnapshot == 4);
      expect(current, hasLength(2));
      for (final entry in current) {
        final food = entry.recall.meals.single.foods.single;
        expect(food.id, 'logged-entry');
        expect(food.name, 'new');
        expect(food.foodVersionId, 'version-2');
        expect(entry.progressCompletedAt, completedAt);
      }
      expect(
        pending
            .singleWhere((entry) => entry.studyDaySnapshot == 3)
            .recall
            .meals
            .single
            .foods
            .single
            .name,
        'old',
      );
    },
  );

  test(
    'uploads a pinned correction after the device clock rolls back',
    () async {
      final today = DateTime.utc(2026, 7, 17, 12);
      final completedAt = today.subtract(const Duration(days: 1));
      final subject = _subject(daysAgo: 2)
        ..startedAt = today.subtract(const Duration(days: 2));
      final canonical = _recall('clock-change', studyDay: 1)
        ..entryCompletedAt = completedAt
        ..lastAutoSavedAt = today
        ..waterIntakeMl = 250;
      subject.progress.add(
        SubjectProgress(
            subjectId: subject.id,
            interventionId: 'intervention',
            taskId: 'task',
            resultType: 'DailyRecall',
            result: Result<DailyRecall>.app(
              type: 'DailyRecall',
              periodId: 'period',
              result: canonical,
            ),
          )
          ..completedAt = completedAt
          ..nutritionRevision = 3,
      );
      final uploaded = <DailyRecall>[];
      final manager = NutritionRecallAutoSaveManager(
        submitter: (_, recall) async => uploaded.add(recall),
      );
      await manager.saveRecall(
        recall: DailyRecall.fromJson(canonical.toJson())
          ..lastAutoSavedAt = today.subtract(const Duration(hours: 2))
          ..waterIntakeMl = 500,
        subjectId: subject.id,
        taskId: 'task',
        periodId: 'period',
        interventionId: 'intervention',
        studyDaySnapshot: 1,
        progressCompletedAt: completedAt,
        nutritionRevision: 3,
      );

      await manager.submitPendingRecalls(
        subject: subject,
        trackProgress: true,
        now: today,
      );

      expect(uploaded.single.waterIntakeMl, 500);
      expect(await manager.scanPendingRecalls(subject.id), isEmpty);
    },
  );

  for (final attemptedRevision in [null, 4]) {
    test(
      'rebases newer edits after losing the response at revision $attemptedRevision',
      () async {
        final today = DateTime.utc(2026, 7, 17, 12);
        final day = DateTime.utc(2026, 7, 16);
        final initialCompletion = day.add(const Duration(hours: 16));
        final rowTime = initialCompletion.add(const Duration(microseconds: 1));
        final subject = _subject(daysAgo: 2)
          ..startedAt = today.subtract(const Duration(days: 2));
        final first = _recall('sent-recall', studyDay: 1)
          ..date = day
          ..entryCompletedAt = attemptedRevision == null
              ? null
              : initialCompletion
          ..lastAutoSavedAt = today
          ..waterIntakeMl = 250;
        final sent = DailyRecall.fromJson(first.toJson())
          ..entryCompletedAt = initialCompletion;
        final firstManager = NutritionRecallAutoSaveManager();
        Future<void> store(DailyRecall recall) => firstManager.saveRecall(
          recall: recall,
          subjectId: subject.id,
          taskId: 'task',
          periodId: 'period',
          interventionId: 'intervention',
          studyDaySnapshot: 1,
          progressCompletedAt: attemptedRevision == null ? null : rowTime,
          nutritionRevision: attemptedRevision,
        );
        await store(first);
        final pending = (await firstManager.scanPendingRecalls(subject.id))
            .single;
        expect(await firstManager.stageRecallUpload(pending, sent), isTrue);
        await store(DailyRecall.fromJson(first.toJson())..waterIntakeMl = 500);

        final savedRevision = attemptedRevision == null
            ? 0
            : attemptedRevision + 1;
        subject.progress.add(
          SubjectProgress(
              subjectId: subject.id,
              interventionId: 'intervention',
              taskId: 'task',
              resultType: 'DailyRecall',
              result: Result<DailyRecall>.app(
                type: 'DailyRecall',
                periodId: 'period',
                result: sent,
              ),
            )
            ..completedAt = rowTime
            ..nutritionRevision = savedRevision,
        );
        final attempts = <PendingRecall>[];
        final restarted = NutritionRecallAutoSaveManager(
          submitter: (pending, _) async => attempts.add(pending),
        );

        await restarted.submitPendingRecalls(
          subject: subject,
          trackProgress: true,
          now: today,
        );

        final rebased = attempts.single;
        expect(rebased.recall.waterIntakeMl, 500);
        expect(rebased.recall.entryCompletedAt, initialCompletion);
        expect(rebased.progressCompletedAt, rowTime);
        expect(rebased.nutritionRevision, savedRevision);
        expect(rebased.stagedUpload, isNull);
      },
    );
  }

  test(
    'does not acknowledge a different payload from another device',
    () async {
      final now = DateTime.utc(2026, 7, 17, 12);
      final completion = now.subtract(const Duration(days: 1));
      final subject = _subject(daysAgo: 2)
        ..startedAt = now.subtract(const Duration(days: 2));
      final recall = _recall('shared', studyDay: 1)
        ..entryCompletedAt = completion
        ..waterIntakeMl = 250;
      final manager = NutritionRecallAutoSaveManager(
        submitter: (_, _) async => fail('Must not replace another revision'),
      );
      await manager.saveRecall(
        recall: recall,
        subjectId: subject.id,
        taskId: 'task',
        periodId: 'period',
        interventionId: 'intervention',
        studyDaySnapshot: 1,
        progressCompletedAt: completion,
        nutritionRevision: 0,
      );
      final pending = (await manager.scanPendingRecalls(subject.id)).single;
      expect(await manager.stageRecallUpload(pending, recall), isTrue);
      subject.progress.add(
        SubjectProgress(
            subjectId: subject.id,
            interventionId: 'intervention',
            taskId: 'task',
            resultType: 'DailyRecall',
            result: Result<DailyRecall>.app(
              type: 'DailyRecall',
              periodId: 'period',
              result: DailyRecall.fromJson(recall.toJson())
                ..waterIntakeMl = 999,
            ),
          )
          ..completedAt = completion
          ..nutritionRevision = 1,
      );

      await manager.submitPendingRecalls(
        subject: subject,
        trackProgress: true,
        now: now,
      );

      final retained = (await manager.scanPendingRecalls(subject.id)).single;
      expect(retained.recall.waterIntakeMl, 250);
      expect(retained.nutritionRevision, 0);
      expect(retained.stagedUpload, isNotNull);
    },
  );

  test(
    'clears an acknowledged draft when upload only resolves linkage',
    () async {
      final manager = NutritionRecallAutoSaveManager();
      final day = DateTime.utc(2026, 7, 16);
      final draft = _foodRecall('offline', studyDay: 1)
        ..date = day
        ..lastAutoSavedAt = day;
      await _save(manager, draft);
      final linked = DailyRecall.fromJson(draft.toJson())
        ..entryCompletedAt = day;
      linked.meals.single.foods.single.foodVersionId = 'linked-version';
      final pending = (await manager.scanPendingRecalls('subject')).single;
      expect(await manager.stageRecallUpload(pending, linked), isTrue);
      final saved = SubjectProgress(
        subjectId: 'subject',
        interventionId: 'intervention',
        taskId: 'task',
        resultType: 'DailyRecall',
        result: Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: 'period',
          result: linked,
        ),
      )..completedAt = day;

      await manager.acknowledgeRecallSave(
        saved: saved,
        uploaded: linked,
        previousRevision: null,
      );

      expect(await manager.scanPendingRecalls('subject'), isEmpty);
    },
  );

  test('retries a transient upload failure before the draft expires', () async {
    var attempts = 0;
    final manager = NutritionRecallAutoSaveManager(
      submitter: (_, _) async {
        if (++attempts == 1) throw const SocketException('offline');
      },
    );
    final now = DateTime.utc(2026, 7, 17, 12);
    final subject = _subject(daysAgo: 2)
      ..startedAt = now.subtract(const Duration(days: 2));
    await _save(manager, _recall('retry', studyDay: 1));

    Future<bool> submit(DateTime time) => manager.submitPendingRecalls(
      subject: subject,
      trackProgress: true,
      now: time,
    );
    expect(await submit(now), isTrue);
    expect(await manager.scanPendingRecalls(subject.id), hasLength(1));

    expect(await submit(now.add(const Duration(minutes: 5))), isFalse);
    expect(attempts, 2);
    expect(await manager.scanPendingRecalls(subject.id), isEmpty);
  });

  test('expired drafts stay cached without an upload attempt', () async {
    final submitted = <DailyRecall>[];
    final manager = NutritionRecallAutoSaveManager(
      submitter: (_, recall) async => submitted.add(recall),
    );
    final subject = _subject(daysAgo: 10);
    await _save(manager, _recall('old-retry', studyDay: 0));

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(submitted, isEmpty);
    expect(await manager.scanPendingRecalls(subject.id), hasLength(1));
  });
}

http.Response _jsonResponse(http.Request request, Object body) => http.Response(
  jsonEncode(body),
  200,
  headers: const {'content-type': 'application/json'},
  request: request,
);

Future<void> _save(
  NutritionRecallAutoSaveManager manager,
  DailyRecall recall,
) => manager.saveRecall(
  recall: recall,
  subjectId: 'subject',
  taskId: 'task',
  interventionId: 'intervention',
  periodId: 'period',
  studyDaySnapshot: recall.studyDaySnapshot!,
);

DailyRecall _recall(String id, {required int studyDay}) => DailyRecall(
  id: id,
  date: DateTime.now(),
  recallMode: RecallMode.realtimeRecord,
  entryStartedAt: DateTime.now(),
  meals: [_meal(id)],
  studyDaySnapshot: studyDay,
);

DailyRecall _foodRecall(String name, {required int studyDay}) => DailyRecall(
  id: 'recall-$studyDay',
  date: DateTime.now(),
  recallMode: RecallMode.realtimeRecord,
  entryStartedAt: DateTime.now(),
  meals: [
    MealLog(
      timePrecision: MealOccurrenceTimePrecision.approximate,
      id: 'meal',
      mealType: MealType.breakfast,
      mealContext: MealContext.home,
      timezone: 'UTC',
      isSkipped: false,
      foods: [_food(name)],
    ),
  ],
  studyDaySnapshot: studyDay,
);

FoodEntry _food(String name, {String versionId = 'version-1'}) => FoodEntry(
  id: name == 'old' ? 'logged-entry' : 'definition-snapshot',
  foodId: 'food-definition',
  foodVersionId: versionId,
  entryType: FoodEntryType.singleIngredient,
  name: name,
  amount: 2,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 100,
    protein: 1,
    carbs: 1,
    fat: 1,
    sugars: 0,
    fiber: 0,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: const {},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15),
  originalValues: const {},
);

MealLog _meal(String id) => MealLog(
  timePrecision: MealOccurrenceTimePrecision.approximate,
  id: id,
  mealType: MealType.breakfast,
  mealContext: MealContext.home,
  timezone: 'UTC',
  isSkipped: false,
  foods: [],
);

class _DelayedRecallLoadManager() extends NutritionRecallAutoSaveManager {
  final _loadStarted = Completer<void>();
  final _pending = Completer<PendingRecall?>();

  Future<void> get loadStarted => _loadStarted.future;

  void complete(PendingRecall pending) => _pending.complete(pending);

  @override
  Future<PendingRecall?> loadPendingRecall({
    required String subjectId,
    required String taskId,
    required String periodId,
    required int studyDay,
  }) {
    _loadStarted.complete();
    return _pending.future;
  }
}

class _DivergentStudyDaySubject({required final int localStudyDay})
    extends StudySubject {
  this : super('subject', 'study', 'user', []);

  @override
  int getDayOfStudyFor(DateTime date) => localStudyDay;
}

StudySubject _subject({required int daysAgo}) {
  final subject = StudySubject('subject', 'study', 'user', [
    'intervention',
    'second',
  ])..startedAt = DateTime.now().subtract(Duration(days: daysAgo));
  final study = Study('study', 'user')
    ..schedule = (StudySchedule()
      ..includeBaseline = false
      ..numberOfCycles = 1
      ..phaseDuration = 100)
    ..interventions = [
      Intervention('intervention', 'Intervention'),
      Intervention('second', 'Second'),
    ];
  subject.study = study;
  return subject;
}
