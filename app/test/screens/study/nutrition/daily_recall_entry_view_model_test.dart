import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

void main() {
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
      final viewModel = DailyRecallEntryViewModel(
        subject: subject,
        task: task,
        completionPeriod: period,
      );
      addTearDown(viewModel.dispose);

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
    'rollover discards a draft when its study day is already complete',
    () async {
      SharedPreferences.setMockInitialValues({});

      final study = Study('study', 'owner')
        ..schedule.numberOfCycles = 0
        ..schedule.includeBaseline = true;
      final subject =
          StudySubject('subject-rollover', study.id, 'user', const [])
            ..study = study
            ..startedAt = DateTime.now().subtract(const Duration(days: 2));
      final task = NutritionTask.withId();
      final manager = NutritionRecallAutoSaveManager();
      final draft = DailyRecall.withId(
        date: DateTime.now().subtract(const Duration(days: 2)),
        recallMode: RecallMode.realtimeRecord,
        meals: [],
        studyDaySnapshot: 0,
        lastAutoSavedAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      final completed = DailyRecall.withId(
        date: draft.date,
        recallMode: RecallMode.realtimeRecord,
        entryCompletedAt: DateTime.now().subtract(const Duration(days: 2)),
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

      await manager.submitPendingRecalls(subject: subject, trackProgress: true);

      expect(
        await manager.loadRecall(
          subjectId: subject.id,
          taskId: task.id,
          studyDay: 0,
        ),
        isNull,
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
