import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('rollover preserves the prior draft and rejects new entries', () async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime.utc(2025, 7, 16, 23, 59);
    final subject = StudySubject('rollover-subject', 'study', 'user', [])
      ..study = (Study('study', 'user')..schedule.numberOfCycles = 0)
      ..startedAt = DateTime.utc(2025, 7, 15);
    final task = NutritionTask.withId()..trackWaterIntake = true;
    final period = task.schedule.completionPeriods.single;
    final manager = NutritionRecallAutoSaveManager();
    final model = DailyRecallEntryViewModel(
      subject: subject,
      task: task,
      completionPeriod: period,
      autoSaveManager: manager,
      clock: () => now,
    );
    addTearDown(model.dispose);
    await model.adjustWaterIntake(250);
    await model.flushPendingAutoSave();

    now = now.add(const Duration(minutes: 2));
    await model.adjustWaterIntake(250);
    expect(model.currentDayExpired, isTrue);
    expect(model.recall.waterIntakeMl, 250);
    expect(
      (await manager.scanPendingRecalls(subject.id))
          .single
          .recall
          .waterIntakeMl,
      250,
    );
  });

  test('reloading a newer canonical recall preserves the old draft', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime.utc(2026, 7, 16, 12);
    final task = NutritionTask.withId()..trackWaterIntake = true;
    final period = task.schedule.completionPeriods.single;
    final subject = StudySubject('subject-reload', 'study', 'user', [])
      ..study = (Study('study', 'user')..schedule.numberOfCycles = 0)
      ..startedAt = now;
    final completed = DailyRecall.withId(
      date: now,
      recallMode: RecallMode.realtimeRecord,
      meals: [],
      entryCompletedAt: now,
      studyDaySnapshot: 0,
      lastAutoSavedAt: now,
      waterIntakeMl: 100,
    );
    final progress = SubjectProgress(
      subjectId: subject.id,
      interventionId: 'baseline',
      taskId: task.id,
      resultType: 'DailyRecall',
      result: Result<DailyRecall>.app(
        type: 'DailyRecall',
        periodId: period.id,
        result: completed,
      ),
    )..completedAt = now;
    subject.progress.add(progress);
    final manager = NutritionRecallAutoSaveManager();
    final model = DailyRecallEntryViewModel(
      subject: subject,
      task: task,
      completionPeriod: period,
      autoSaveManager: manager,
      clock: () => now.add(const Duration(minutes: 1)),
    )..shouldSaveToDb = false;
    addTearDown(model.dispose);
    await model.adjustWaterIntake(250);
    await model.flushPendingAutoSave();
    expect(model.recall.waterIntakeMl, 350);

    completed
      ..waterIntakeMl = 125
      ..lastAutoSavedAt = now.add(const Duration(minutes: 2));
    progress.nutritionRevision = 1;
    await model.reloadCanonicalRecall();

    expect(model.hasDraftConflict, isTrue);
    expect(model.recall.waterIntakeMl, 125);
    await model.adjustWaterIntake(250);
    expect(model.recall.waterIntakeMl, 125);
    expect(
      (await manager.scanPendingRecalls(subject.id))
          .single
          .recall
          .waterIntakeMl,
      350,
    );
    expect(await model.discardConflictingDraft(), isTrue);
    expect(model.canEdit, isTrue);
    expect(await manager.scanPendingRecalls(subject.id), isEmpty);
  });

  test(
    'a server revision conflict keeps the local draft and locks edits',
    () async {
      SharedPreferences.setMockInitialValues({});
      final now = DateTime.utc(2026, 7, 16, 12);
      final task = NutritionTask.withId()..trackWaterIntake = true;
      final period = task.schedule.completionPeriods.single;
      final subject = StudySubject('subject-conflict', 'study', 'user', [])
        ..study = (Study('study', 'user')..schedule.numberOfCycles = 0)
        ..startedAt = now;
      final completed = DailyRecall.withId(
        date: now,
        recallMode: RecallMode.realtimeRecord,
        meals: [],
        entryCompletedAt: now,
        studyDaySnapshot: 0,
      );
      final manager = NutritionRecallAutoSaveManager();
      final model = DailyRecallEntryViewModel(
        subject: subject,
        task: task,
        completionPeriod: period,
        existingRecall: completed,
        autoSaveManager: manager,
        clock: () => now.add(const Duration(minutes: 1)),
        remoteSaver:
            ({
              required taskId,
              required periodId,
              required recall,
              required persistenceTarget,
              interventionIdOverride,
            }) => Future<void>.error(
              const PostgrestException(
                message: 'stale nutrition recall revision',
                code: '40001',
              ),
            ),
      );
      addTearDown(model.dispose);

      await model.adjustWaterIntake(250);
      await model.flushPendingAutoSave(persistToDatabase: true);
      expect(model.hasDraftConflict, isTrue);
      expect(model.canDiscardConflictingDraft, isTrue);
      await model.adjustWaterIntake(250);
      expect(model.recall.waterIntakeMl, 250);
      expect(
        (await manager.scanPendingRecalls(subject.id))
            .single
            .recall
            .waterIntakeMl,
        250,
      );
      expect(await model.discardConflictingDraft(), isTrue);
      expect(model.canEdit, isFalse);
      expect(model.requiresReopen, isTrue);
      expect(await manager.scanPendingRecalls(subject.id), isEmpty);
    },
  );

  test('new recall uses the authoritative UTC study day', () {
    SharedPreferences.setMockInitialValues({});
    final subject = _LocalDaySubject()
      ..startedAt = DateTime.now().subtract(const Duration(days: 1))
      ..study = (Study('study', 'owner')
        ..schedule.numberOfCycles = 0
        ..schedule.includeBaseline = true);
    final viewModel = DailyRecallEntryViewModel(subject: subject);
    addTearDown(viewModel.dispose);

    expect(
      viewModel.studyDaySnapshot,
      nutritionStudyDayFor(subject, DateTime.now()),
    );
    expect(
      viewModel.studyDaySnapshot,
      isNot(subject.getDayOfStudyFor(DateTime.now())),
    );
  });

  test('water adjustments preserve and autosave a water-only draft', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime.now();
    final study = Study('study', 'owner')
      ..schedule.numberOfCycles = 0
      ..schedule.includeBaseline = true;
    final subject = StudySubject('subject-water', study.id, 'user', const [])
      ..study = study
      ..startedAt = now.subtract(const Duration(days: 1));
    final task = NutritionTask.withId()..trackWaterIntake = true;
    final period = task.schedule.completionPeriods.single;
    final manager = NutritionRecallAutoSaveManager();
    final studyDay = nutritionStudyDayFor(subject, now);
    final draft = DailyRecall.withId(
      date: now,
      recallMode: RecallMode.realtimeRecord,
      meals: [],
    );
    expect(draft.toJsonForStorage(), isNot(contains('waterIntakeMl')));
    expect(DailyRecall.fromJson(draft.toJson()).waterIntakeMl, isNull);
    await manager.saveRecall(
      recall: draft..waterIntakeMl = 500,
      subjectId: subject.id,
      taskId: task.id,
      interventionId: 'baseline',
      periodId: period.id,
      studyDaySnapshot: studyDay,
    );
    final viewModel = DailyRecallEntryViewModel(
      subject: subject,
      task: task,
      completionPeriod: period,
      autoSaveManager: manager,
    );
    addTearDown(viewModel.dispose);

    await viewModel.adjustWaterIntake(250);
    expect(viewModel.recall.waterIntakeMl, 750);
    await viewModel.flushPendingAutoSave();
    expect(
      (await manager.loadPendingRecall(
        subjectId: subject.id,
        taskId: task.id,
        periodId: period.id,
        studyDay: studyDay,
      ))?.recall.waterIntakeMl,
      750,
    );

    await viewModel.adjustWaterIntake(-1000);
    expect(viewModel.recall.waterIntakeMl, 0);
    expect(viewModel.recall.toJsonForStorage()['waterIntakeMl'], 0);
    expect(viewModel.recall.entryCompletedAt, isNull);
    expect(subject.progress, isEmpty);
    await viewModel.flushPendingAutoSave();

    task.trackWaterIntake = false;
    await viewModel.adjustWaterIntake(250);
    expect(viewModel.recall.waterIntakeMl, 0);
  });

  test(
    'autosave keeps an incomplete recall local without completing progress',
    () async {
      SharedPreferences.setMockInitialValues({});

      final study = Study('study', 'owner')
        ..schedule.numberOfCycles = 0
        ..schedule.includeBaseline = true;
      final subject =
          StudySubject('subject-autosave', study.id, 'user', const [])
            ..study = study
            ..startedAt = DateTime.now().subtract(const Duration(hours: 1));
      final task = NutritionTask.withId();
      final period = task.schedule.completionPeriods.single;
      var remoteSaves = 0;
      final viewModel = DailyRecallEntryViewModel(
        subject: subject,
        task: task,
        completionPeriod: period,
        remoteSaver:
            ({
              required taskId,
              required periodId,
              required recall,
              required persistenceTarget,
              interventionIdOverride,
            }) async {
              remoteSaves++;
            },
      );
      addTearDown(viewModel.dispose);
      await viewModel.initialized;

      viewModel.addMeal(
        MealLog.withId(
          mealType: MealType.lunch,
          mealContext: MealContext.home,
          timestamp: DateTime.now(),
          timezone: 'UTC',
          isSkipped: false,
          foods: [],
        ),
      );

      await Future<void>.delayed(
        NutritionRecallAutoSaveManager.debounceDuration +
            const Duration(milliseconds: 100),
      );

      expect(viewModel.lastSaveTime, isNotNull);
      expect(remoteSaves, 0);
      expect(viewModel.recall.entryCompletedAt, isNull);
      expect(subject.progress, isEmpty);
      expect(
        await NutritionRecallAutoSaveManager().loadRecall(
          subjectId: subject.id,
          taskId: task.id,
          studyDay: 0,
        ),
        isNotNull,
      );
    },
  );

  test(
    'completion flushes a scheduled draft before marking it complete',
    () async {
      SharedPreferences.setMockInitialValues({});

      final study = Study('study', 'owner')
        ..schedule.numberOfCycles = 0
        ..schedule.includeBaseline = true;
      final subject = StudySubject('subject-flush', study.id, 'user', const [])
        ..study = study
        ..startedAt = DateTime.now().subtract(const Duration(hours: 1));
      final task = NutritionTask.withId();
      final period = task.schedule.completionPeriods.single;
      final viewModel = DailyRecallEntryViewModel(
        subject: subject,
        task: task,
        completionPeriod: period,
      );
      addTearDown(viewModel.dispose);
      await viewModel.initialized;

      viewModel.addMeal(
        MealLog.withId(
          mealType: MealType.lunch,
          mealContext: MealContext.home,
          timestamp: DateTime.now(),
          timezone: 'UTC',
          isSkipped: false,
          foods: [],
        ),
      );

      await viewModel.flushPendingAutoSave();

      expect(viewModel.lastSaveTime, isNotNull);
      expect(viewModel.recall.entryCompletedAt, isNull);
      expect(
        await NutritionRecallAutoSaveManager().loadRecall(
          subjectId: subject.id,
          taskId: task.id,
          studyDay: 0,
        ),
        isNotNull,
      );

      final completedRecall = viewModel.markCompleted();
      expect(completedRecall.entryCompletedAt, isNotNull);
      expect(subject.progress, isEmpty);

      await viewModel.clearAutoSave();
      expect(
        await NutritionRecallAutoSaveManager().loadRecall(
          subjectId: subject.id,
          taskId: task.id,
          studyDay: 0,
        ),
        isNull,
      );
    },
  );

  test('completion flush waits for active and scheduled autosaves', () async {
    SharedPreferences.setMockInitialValues({});

    final study = Study('study', 'owner')
      ..schedule.numberOfCycles = 0
      ..schedule.includeBaseline = true;
    final subject =
        StudySubject('subject-queued-flush', study.id, 'user', const [])
          ..study = study
          ..startedAt = DateTime.now().subtract(const Duration(hours: 1));
    final task = NutritionTask.withId();
    final period = task.schedule.completionPeriods.single;
    final autoSaveManager = _BlockingAutoSaveManager();
    final viewModel = DailyRecallEntryViewModel(
      subject: subject,
      task: task,
      completionPeriod: period,
      autoSaveManager: autoSaveManager,
    );
    addTearDown(viewModel.dispose);
    await viewModel.initialized;

    viewModel.addMeal(
      MealLog.withId(
        mealType: MealType.lunch,
        mealContext: MealContext.home,
        timestamp: DateTime.now(),
        timezone: 'UTC',
        isSkipped: false,
        foods: [],
      ),
    );

    final firstFlush = viewModel.flushPendingAutoSave();
    await autoSaveManager.firstSaveStarted.future;

    viewModel.updateSpecialOccasion('Birthday');
    var completionFinished = false;
    final completion = () async {
      await viewModel.flushPendingAutoSave();
      viewModel.markCompleted();
      await viewModel.clearAutoSave();
      completionFinished = true;
    }();

    expect(completionFinished, isFalse);
    expect(autoSaveManager.secondSaveStarted.isCompleted, isFalse);

    autoSaveManager.releaseFirstSave.complete();
    await autoSaveManager.secondSaveStarted.future;
    await firstFlush;
    expect(completionFinished, isFalse);

    autoSaveManager.releaseSecondSave.complete();
    await completion;

    expect(autoSaveManager.savedRecalls, hasLength(2));
    expect(autoSaveManager.savedRecalls.first.specialOccasion, isNull);
    expect(autoSaveManager.savedRecalls.last.specialOccasion, 'Birthday');
    expect(viewModel.recall.entryCompletedAt, isNotNull);
    expect(
      await autoSaveManager.loadRecall(
        subjectId: subject.id,
        taskId: task.id,
        studyDay: 0,
      ),
      isNull,
    );
  });

  test(
    'rejects an incomplete recall instead of creating completed progress',
    () async {
      final study = Study('study', 'owner')
        ..schedule.numberOfCycles = 0
        ..schedule.includeBaseline = true;
      final subject = StudySubject('subject-guard', study.id, 'user', const [])
        ..study = study
        ..startedAt = DateTime.now().subtract(const Duration(hours: 1));
      final recall = DailyRecall.withId(
        date: DateTime.now(),
        recallMode: RecallMode.realtimeRecord,
        meals: [],
        studyDaySnapshot: 0,
      );

      await expectLater(
        subject.upsertNutritionResult(
          taskId: 'nutrition-task',
          periodId: 'period',
          recall: recall,
          completionDateOverride: DateTime.now(),
        ),
        throwsA(isA<StateError>()),
      );
      expect(subject.progress, isEmpty);
    },
  );

  test(
    'rollover retains a conflicting draft when its study day is complete',
    () async {
      SharedPreferences.setMockInitialValues({});

      final study = Study('study', 'owner')
        ..schedule.numberOfCycles = 0
        ..schedule.includeBaseline = true;
      final now = DateTime.utc(2026, 7, 16, 12);
      final yesterday = now.subtract(const Duration(days: 1));
      final subject =
          StudySubject('subject-rollover', study.id, 'user', const [])
            ..study = study
            ..startedAt = yesterday;
      final task = NutritionTask.withId();
      final manager = NutritionRecallAutoSaveManager();
      final draft = DailyRecall.withId(
        date: yesterday,
        recallMode: RecallMode.realtimeRecord,
        meals: [],
        studyDaySnapshot: 0,
        lastAutoSavedAt: yesterday,
      );
      final completed = DailyRecall.withId(
        date: draft.date,
        recallMode: RecallMode.realtimeRecord,
        entryCompletedAt: yesterday,
        meals: [],
        studyDaySnapshot: 0,
      );
      subject.progress.add(
        SubjectProgress(
          subjectId: subject.id,
          interventionId: 'baseline',
          taskId: task.id,
          resultType: 'DailyRecall',
          result: Result<DailyRecall>.app(
            type: 'DailyRecall',
            periodId: 'period',
            result: completed,
          ),
        )..completedAt = completed.entryCompletedAt,
      );
      await manager.saveRecall(
        recall: draft,
        subjectId: subject.id,
        taskId: task.id,
        interventionId: 'baseline',
        periodId: 'period',
        studyDaySnapshot: 0,
      );

      await manager.submitPendingRecalls(
        subject: subject,
        trackProgress: true,
        now: now,
      );

      expect(
        await manager.loadRecall(
          subjectId: subject.id,
          taskId: task.id,
          studyDay: 0,
        ),
        isNotNull,
      );
      expect(subject.progress, hasLength(1));
      expect(
        (subject.progress.single.result as Result<DailyRecall>)
            .result
            .entryCompletedAt,
        isNotNull,
      );
    },
  );
}

class _LocalDaySubject() extends StudySubject {
  this : super('subject', 'study', 'user', []);

  @override
  int getDayOfStudyFor(DateTime date) => 20;
}

class _BlockingAutoSaveManager() extends NutritionRecallAutoSaveManager {
  final firstSaveStarted = Completer<void>();
  final secondSaveStarted = Completer<void>();
  final releaseFirstSave = Completer<void>();
  final releaseSecondSave = Completer<void>();
  final savedRecalls = <DailyRecall>[];

  @override
  Future<void> saveRecall({
    required DailyRecall recall,
    required String subjectId,
    required String taskId,
    required String interventionId,
    required String periodId,
    required int studyDaySnapshot,
    DateTime? progressCompletedAt,
    int? nutritionRevision,
  }) async {
    savedRecalls.add(recall);
    final saveNumber = savedRecalls.length;
    final started = saveNumber == 1 ? firstSaveStarted : secondSaveStarted;
    final release = saveNumber == 1 ? releaseFirstSave : releaseSecondSave;
    started.complete();
    await release.future;
    await super.saveRecall(
      recall: recall,
      subjectId: subjectId,
      taskId: taskId,
      interventionId: interventionId,
      periodId: periodId,
      studyDaySnapshot: studyDaySnapshot,
      progressCompletedAt: progressCompletedAt,
      nutritionRevision: nutritionRevision,
    );
  }
}
