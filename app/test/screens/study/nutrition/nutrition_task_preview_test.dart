import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/screens/study/tasks/observation/nutrition_task_widget.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_core/core.dart';

import '../../../util/mock_nutrition_draft_storage.dart';
import 'meal_entry_screen_test.dart' show testFood;

void main() {
  setUp(() => mockNutritionDraftStorage());

  testWidgets('published preview can save to its own food library', (
    tester,
  ) async {
    final task = NutritionTask.withId();
    SharedPreferences.setMockInitialValues({
      'nutrition_instructions_shown_${task.id}': true,
    });
    final intervention = Intervention('intervention', 'Arm')..tasks = [];
    final study = Study('study', 'user')
      ..status = StudyStatus.running
      ..schedule = (StudySchedule()..numberOfCycles = 0)
      ..observations = [task]
      ..interventions = [intervention];
    final subject = StudySubject('preview', study.id, 'user', [intervention.id])
      ..study = study
      ..startedAt = DateTime.now();
    final appState = AppState()
      ..isPreview = true
      ..activeSubject = subject
      ..selectedStudy = study;
    expect(appState.trackParticipantProgress, isFalse);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NutritionTaskWidget(task: task),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final viewModel = tester
        .element(find.byType(Scaffold).first)
        .read<TemplateViewModel>();
    await viewModel.saveMealAsTemplate(
      name: 'Preview meal',
      meal: MealLog.withId(
        mealType: MealType.lunch,
        timezone: 'UTC',
        isSkipped: false,
        foods: [testFood()],
      ),
    );
    expect(viewModel.mealTemplates.single.name, 'Preview meal');
  });

  testWidgets('open nutrition preview reflects a changed water setting', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'nutrition_instructions_shown_nutrition': true,
    });
    final task = NutritionTask.withId()
      ..id = 'nutrition'
      ..title = 'Nutrition';
    final updated = NutritionTask.fromJson(task.toJson())
      ..trackWaterIntake = true;
    final intervention = Intervention('intervention', 'Arm')..tasks = [];
    final study = Study('study', 'user')
      ..schedule = (StudySchedule()..numberOfCycles = 0)
      ..observations = [task]
      ..interventions = [intervention];
    final updatedStudy = Study('study', 'user')
      ..schedule = (StudySchedule()..numberOfCycles = 0)
      ..observations = [updated]
      ..interventions = [intervention];
    final subject =
        StudySubject('test-subject', 'study', 'user', [intervention.id])
          ..study = study
          ..startedAt = DateTime.now();
    final appState = AppState()
      ..isPreview = true
      ..activeSubject = subject
      ..selectedStudy = study;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TaskScreen(
            taskInstance: TaskInstance(
              task,
              task.schedule.completionPeriods.first.id,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final taskFinder = find.byType(NutritionTaskWidget);
    expect(
      tester.widget<NutritionTaskWidget>(taskFinder).task!.trackWaterIntake,
      isFalse,
    );
    final model = tester
        .element(find.byType(Consumer<DailyRecallEntryViewModel>))
        .read<DailyRecallEntryViewModel>();
    final recallId = model.recall.id;
    appState.updateStudy(updatedStudy);
    await tester.pumpAndSettle();
    expect(
      tester.widget<NutritionTaskWidget>(taskFinder).task!.trackWaterIntake,
      isTrue,
    );
    expect(model.task!.trackWaterIntake, isTrue);
    expect(model.recall.id, recallId);
  });
}
