import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

  test('submits a draft after its index write failed', () async {
    final now = DateTime.utc(2026, 7, 17, 12);
    final subject = _subject(daysAgo: 2)
      ..startedAt = now.subtract(const Duration(days: 2));
    final writer = NutritionRecallAutoSaveManager(
      stringWriter: (prefs, key, value) => key.contains('_index_')
          ? Future.value(false)
          : prefs.setString(key, value),
    );

    await expectLater(
      _save(writer, _recall('orphaned', studyDay: 1)),
      throwsStateError,
    );

    final submitted = <DailyRecall>[];
    final reader = NutritionRecallAutoSaveManager(
      submitter: (_, recall) async => submitted.add(recall),
    );
    await reader.submitPendingRecalls(
      subject: subject,
      trackProgress: true,
      now: now,
    );

    expect(submitted.single.id, 'orphaned');
    expect(await reader.scanPendingRecalls(subject.id), isEmpty);
  });

  test('deleting a subject removes indexed and orphaned drafts', () async {
    const prefix = 'studyu_nutrition_autosave';
    const orphan = '${prefix}_subject_old_task_2';
    const other = '${prefix}_another_subject_task_period_3';
    SharedPreferences.setMockInitialValues({orphan: 'invalid', other: 'keep'});
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(preferences: prefs);
    await _save(manager, _recall('draft', studyDay: 3));
    await manager.updateLastKnownStudyDay('subject', 3);

    await manager.deleteSubjectDrafts('subject');

    expect(await manager.scanPendingRecalls('subject'), isEmpty);
    expect(await manager.getLastKnownStudyDay('subject'), isNull);
    expect(prefs.getKeys(), {other});
  });

  test('add, edit, and delete cache the full recall immediately', () async {
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(preferences: prefs);
    final subject = _subject(daysAgo: 0);
    final viewModel = DailyRecallEntryViewModel(
      subject: subject,
      autoSaveManager: manager,
    );
    await Future<void>.delayed(Duration.zero);

    viewModel.addMeal(_meal('first'));
    await viewModel.flushPendingAutoSave();
    expect(
      (await manager.loadRecall(
        subjectId: subject.id,
        taskId: NutritionRecallAutoSaveManager.standaloneTaskId,
        studyDay: 0,
      ))!.meals.single.id,
      'first',
    );

    viewModel.updateMeal(0, _meal('updated'));
    await viewModel.flushPendingAutoSave();
    expect(
      (await manager.loadRecall(
        subjectId: subject.id,
        taskId: NutritionRecallAutoSaveManager.standaloneTaskId,
        studyDay: 0,
      ))!.meals.single.id,
      'updated',
    );

    viewModel.removeMeal(0);
    await viewModel.flushPendingAutoSave();
    expect(
      (await manager.loadRecall(
        subjectId: subject.id,
        taskId: NutritionRecallAutoSaveManager.standaloneTaskId,
        studyDay: 0,
      ))!.meals,
      isEmpty,
    );
    viewModel.dispose();
  });

  test('ordered writes retain the latest prepared snapshot', () async {
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(preferences: prefs);

    await Future.wait([
      _save(manager, _recall('old', studyDay: 0)),
      _save(manager, _recall('new', studyDay: 0)),
    ]);

    expect(
      (await manager.loadRecall(
        subjectId: 'subject',
        taskId: 'task',
        studyDay: 0,
      ))!.id,
      'new',
    );
  });

  test('legacy food draft survives scan and submission', () async {
    final prefs = await SharedPreferences.getInstance();
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, recall) async => submitted = recall,
    );
    final subject = _subject(daysAgo: 1);
    final studyDay = nutritionStudyDayFor(subject, DateTime.now()) - 1;
    await _save(manager, _foodRecall('legacy', studyDay: studyDay));

    final storageKey =
        'studyu_nutrition_autosave_subject_task_period_$studyDay';
    final stored = Map<String, dynamic>.from(
      jsonDecode(prefs.getString(storageKey)!) as Map,
    );
    final recallJson = Map<String, dynamic>.from(stored['recall'] as Map);
    final meals = List<dynamic>.from(recallJson['meals'] as List);
    final meal = Map<String, dynamic>.from(meals.single as Map);
    final foods = List<dynamic>.from(meal['foods'] as List);
    final legacyFood = Map<String, dynamic>.from(foods.single as Map)
      ..remove('foodId')
      ..remove('foodVersionId');
    meal['foods'] = [legacyFood];
    recallJson['meals'] = [meal];
    stored['recall'] = recallJson;
    await prefs.setString(storageKey, jsonEncode(stored));

    final firstScan = await manager.scanPendingRecalls(subject.id);
    final secondScan = await manager.scanPendingRecalls(subject.id);
    final firstFood = firstScan.single.recall.meals.single.foods.single;
    final repeatedFood = secondScan.single.recall.meals.single.foods.single;
    expect(firstFood.foodId, repeatedFood.foodId);
    expect(firstFood.foodVersionId, repeatedFood.foodVersionId);
    expect(firstFood.foodId, isNot(firstFood.foodVersionId));
    expect(firstFood.toJson(), contains('foodId'));
    expect(firstFood.toJson(), contains('foodVersionId'));

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(submitted?.meals.single.foods.single.foodId, firstFood.foodId);
    expect(
      submitted?.meals.single.foods.single.foodVersionId,
      firstFood.foodVersionId,
    );
  });

  test(
    'period-distinct drafts coexist and retain persistence metadata',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final manager = NutritionRecallAutoSaveManager(preferences: prefs);
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
      final prefs = await SharedPreferences.getInstance();
      final manager = NutritionRecallAutoSaveManager(preferences: prefs);
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
            result: _recall('remote', studyDay: studyDay),
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
    final prefs = await SharedPreferences.getInstance();
    final manager = _DelayedRecallLoadManager(preferences: prefs);
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
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      stringWriter: (_, _, _) async => false,
    );
    final viewModel = DailyRecallEntryViewModel(
      subject: _subject(daysAgo: 0),
      autoSaveManager: manager,
    );
    await Future<void>.delayed(Duration.zero);

    viewModel.addMeal(_meal('unsaved'));

    await expectLater(
      viewModel.flushPendingAutoSave(),
      throwsA(isA<StateError>()),
    );
    viewModel.dispose();
  });

  test('completed UTC-current recall uploads despite the local day', () async {
    final prefs = await SharedPreferences.getInstance();
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
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
    expect(await manager.getLastKnownStudyDay(subject.id), 1);
  });

  test('UTC-current draft stays cached despite the local day', () async {
    final prefs = await SharedPreferences.getInstance();
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
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
    final prefs = await SharedPreferences.getInstance();
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
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
    final prefs = await SharedPreferences.getInstance();
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, recall) async => submitted = recall,
    );
    final subject = _subject(daysAgo: 2);
    final today = subject.getDayOfStudyFor(DateTime.now());
    await _save(manager, _recall('yesterday', studyDay: today - 1));

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(submitted!.entryCompletedAt, isNotNull);
    expect(await manager.scanPendingRecalls(subject.id), isEmpty);
  });

  test('legacy completed recall preserves a conflicting prior draft', () async {
    final prefs = await SharedPreferences.getInstance();
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, recall) async => submitted = recall,
    );
    final subject = _subject(daysAgo: 2);
    final studyDay = subject.getDayOfStudyFor(DateTime.now()) - 1;
    subject.progress.add(
      SubjectProgress(
        subjectId: subject.id,
        interventionId: 'intervention',
        taskId: 'task',
        resultType: 'DailyRecall',
        result: Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: null,
          result: _recall('completed', studyDay: studyDay)
            ..entryCompletedAt = DateTime.now(),
        ),
      )..completedAt = DateTime.now().toUtc(),
    );
    await _save(manager, _recall('draft', studyDay: studyDay));

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(submitted, isNull);
    expect(
      (await manager.scanPendingRecalls(subject.id)).single.recall.id,
      'draft',
    );
  });

  test('incomplete legacy progress uploads a previous-day draft', () async {
    final prefs = await SharedPreferences.getInstance();
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, recall) async => submitted = recall,
    );
    final subject = _subject(daysAgo: 2);
    final studyDay = subject.getDayOfStudyFor(DateTime.now()) - 1;
    subject.progress.add(
      SubjectProgress(
        subjectId: subject.id,
        interventionId: 'intervention',
        taskId: 'task',
        resultType: 'DailyRecall',
        result: Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: null,
          result: _recall('incomplete', studyDay: studyDay),
        ),
      )..completedAt = DateTime.now().toUtc(),
    );
    await _save(manager, _recall('draft', studyDay: studyDay));

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(submitted?.id, 'draft');
    expect(submitted?.entryCompletedAt, isNotNull);
    expect(await manager.scanPendingRecalls(subject.id), isEmpty);
  });

  test('rollover completes a draft pinned to legacy progress', () async {
    final now = DateTime.utc(2026, 7, 17, 12);
    final completedAt = now.subtract(const Duration(days: 1, hours: 1));
    final subject = _subject(daysAgo: 2)
      ..startedAt = now.subtract(const Duration(days: 2));
    final canonical = _recall('legacy', studyDay: 1);
    subject.progress.add(
      SubjectProgress(
        subjectId: subject.id,
        taskId: 'task',
        interventionId: 'intervention',
        resultType: 'DailyRecall',
        result: Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: null,
          result: canonical,
        ),
      )..completedAt = completedAt,
    );

    final submitted = <PendingRecall>[];
    final manager = NutritionRecallAutoSaveManager(
      submitter: (pending, _) async => submitted.add(pending),
    );
    await manager.saveRecall(
      recall: _recall(canonical.id, studyDay: 1)
        ..lastAutoSavedAt = completedAt.add(const Duration(hours: 1)),
      subjectId: subject.id,
      taskId: 'task',
      periodId: 'period',
      interventionId: 'intervention',
      studyDaySnapshot: 1,
      progressCompletedAt: completedAt,
      nutritionRevision: 0,
    );

    await manager.submitPendingRecalls(
      subject: subject,
      trackProgress: true,
      now: now,
    );
    expect(submitted.single.progressCompletedAt, completedAt);
    expect(submitted.single.periodId, 'period');
    expect(await manager.scanPendingRecalls(subject.id), isEmpty);
  });

  test(
    'historical correction keeps its existing completion metadata',
    () async {
      final prefs = await SharedPreferences.getInstance();
      DailyRecall? submitted;
      DateTime? submittedTarget;
      final manager = NutritionRecallAutoSaveManager(
        preferences: prefs,
        submitter: (pending, recall) async {
          submitted = recall;
          submittedTarget = pending.progressCompletedAt;
        },
      );
      final subject = _subject(daysAgo: 2);
      final today = subject.getDayOfStudyFor(DateTime.now());
      final completedAt = DateTime.utc(2026, 7, 15, 12);
      final entryCompletedAt = DateTime.utc(2026, 7, 15, 11);
      final canonical = _recall('canonical', studyDay: today - 1)
        ..entryCompletedAt = entryCompletedAt;
      await manager.saveRecall(
        recall: _recall(canonical.id, studyDay: today - 1)
          ..specialOccasion = 'correction',
        subjectId: subject.id,
        taskId: 'task',
        interventionId: 'intervention',
        periodId: 'period',
        studyDaySnapshot: today - 1,
        progressCompletedAt: completedAt,
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
      expect(submittedTarget, completedAt);
      expect(await manager.scanPendingRecalls(subject.id), isEmpty);
    },
  );

  test('previous-day completion stays on the recall calendar date', () async {
    final prefs = await SharedPreferences.getInstance();
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, recall) async => submitted = recall,
    );
    final subject = _subject(daysAgo: 2);
    final recallDate = DateTime(2024, 12, 31);
    final today = subject.getDayOfStudyFor(DateTime.now());
    await _save(
      manager,
      DailyRecall(
        id: 'after-midnight',
        date: recallDate,
        recallMode: RecallMode.realtimeRecord,
        entryStartedAt: recallDate.add(const Duration(hours: 20)),
        lastAutoSavedAt: DateTime(2025, 1, 1, 0, 5),
        meals: [_meal('after-midnight')],
        studyDaySnapshot: today - 1,
      ),
    );

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(
      submitted!.entryCompletedAt,
      DateTime(2024, 12, 31, 23, 59, 59, 999, 999),
    );
  });

  test('saving a period-qualified draft migrates its legacy cache', () async {
    const legacyKey = 'studyu_nutrition_autosave_subject_task_3';
    const indexKey = 'studyu_nutrition_autosave_index_subject';
    final legacyRecall = _recall('legacy', studyDay: 3);
    SharedPreferences.setMockInitialValues({
      legacyKey: jsonEncode({
        'recall': legacyRecall.toJson(),
        'metadata': {
          'subjectId': 'subject',
          'taskId': 'task',
          'interventionId': 'intervention',
          'periodId': 'period',
          'studyDaySnapshot': 3,
          'createdAt': DateTime.utc(2026).toIso8601String(),
          'lastModifiedAt': DateTime.utc(2026).toIso8601String(),
        },
      }),
      indexKey: jsonEncode(['task_3']),
    });
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(preferences: prefs);

    await _save(manager, _recall('migrated', studyDay: 3));

    expect(prefs.getString(legacyKey), isNull);
    expect(
      (await manager.loadRecall(
        subjectId: 'subject',
        taskId: 'task',
        periodId: 'period',
        studyDay: 3,
      ))!.id,
      'migrated',
    );
    expect(
      (await manager.scanPendingRecalls('subject')).single.recall.id,
      'migrated',
    );
  });

  test(
    'failed recall deletion keeps the pending recall discoverable',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final savingManager = NutritionRecallAutoSaveManager(preferences: prefs);
      final manager = NutritionRecallAutoSaveManager(
        preferences: prefs,
        keyRemover: (_, _) async => false,
      );
      await _save(savingManager, _recall('retry-delete', studyDay: 1));

      await expectLater(
        manager.deleteRecall(subjectId: 'subject', taskId: 'task', studyDay: 1),
        throwsA(isA<StateError>()),
      );

      expect(
        (await manager.scanPendingRecalls('subject')).single.recall.id,
        'retry-delete',
      );
    },
  );

  test('newer recall survives previous-day submission', () async {
    final prefs = await SharedPreferences.getInstance();
    final subject = _subject(daysAgo: 2);
    final today = subject.getDayOfStudyFor(DateTime.now());
    final newerManager = NutritionRecallAutoSaveManager(preferences: prefs);
    final submitterManager = NutritionRecallAutoSaveManager(
      preferences: prefs,
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
      final prefs = await SharedPreferences.getInstance();
      final manager = NutritionRecallAutoSaveManager(preferences: prefs);
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
      final prefs = await SharedPreferences.getInstance();
      final manager = NutritionRecallAutoSaveManager(preferences: prefs);
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
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(preferences: prefs);
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
      final prefs = await SharedPreferences.getInstance();
      final manager = NutritionRecallAutoSaveManager(preferences: prefs);
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
      }

      await checkRebase(2, 3);
      await checkRebase(1, 1);
    },
  );

  test(
    'definition rewrite updates every matching current-day draft only',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final manager = NutritionRecallAutoSaveManager(preferences: prefs);
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
    final prefs = await SharedPreferences.getInstance();
    final submitted = <DailyRecall>[];
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, recall) async => submitted.add(recall),
    );
    final subject = _subject(daysAgo: 10);
    await _save(manager, _recall('old-retry', studyDay: 0));

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(submitted, isEmpty);
    expect(await manager.scanPendingRecalls(subject.id), hasLength(1));
  });
}

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
  id: id,
  mealType: MealType.breakfast,
  mealContext: MealContext.home,
  timezone: 'UTC',
  isSkipped: false,
  foods: [],
);

class _DelayedRecallLoadManager({required SharedPreferences preferences})
    extends NutritionRecallAutoSaveManager {
  final _loadStarted = Completer<void>();
  final _pending = Completer<PendingRecall?>();

  this : super(preferences: preferences);

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
  final subject = StudySubject('subject', 'study', 'user', [])
    ..startedAt = DateTime.now().subtract(Duration(days: daysAgo));
  final study = Study('study', 'user')
    ..schedule = (StudySchedule()..numberOfCycles = 0)
    ..interventions = [];
  subject.study = study;
  return subject;
}
