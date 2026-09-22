import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_core/core.dart';

void main() {
  test(
    'autosave keeps an incomplete recall local without completing progress',
    () async {
      SharedPreferences.setMockInitialValues({});

      final study = Study('study', 'owner')
        ..schedule.numberOfCycles = 0
        ..schedule.includeBaseline = true;
      final subject = StudySubject('subject', study.id, 'user', const [])
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
}
