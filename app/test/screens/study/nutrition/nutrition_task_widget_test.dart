import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/tasks/observation/nutrition_task_widget.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

import 'fake_nutrition_food_repository.dart';

Widget nutritionTaskApp(
  NutritionTask task, {
  DailyRecall? existingRecall,
  Locale locale = const Locale('en'),
  DateTime? historicalDate,
  NutritionRecallPersistenceTarget? persistenceTarget,
  bool readOnly = false,
  AppState? appState,
  FakeNutritionFoodRepository? foodRepository,
}) => ChangeNotifierProvider(
  create: (_) => appState ?? AppState(),
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: locale,
    home: NutritionTaskWidget(
      existingRecall: existingRecall,
      task: task,
      persistenceTarget: persistenceTarget,
      historicalDate: historicalDate,
      readOnly: readOnly,
      foodRepository: foodRepository ?? FakeNutritionFoodRepository(),
      completionPeriod: CompletionPeriod(
        id: 'period',
        unlockTime: StudyUTimeOfDay(),
        lockTime: StudyUTimeOfDay(hour: 23),
      ),
    ),
  ),
);

class const _NutritionLauncher({
  required final NutritionTask task,
  required final ValueChanged<DailyRecall?> onResult,
  final DailyRecall? existingRecall,
}) extends StatefulWidget {
  @override
  State<_NutritionLauncher> createState() => _NutritionLauncherState();
}

class _NutritionLauncherState() extends State<_NutritionLauncher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final result = await Navigator.of(context).push<DailyRecall>(
        NutritionTaskWidget.route(
          existingRecall: widget.existingRecall,
          task: widget.task,
          foodRepository: FakeNutritionFoodRepository(),
          completionPeriod: CompletionPeriod(
            id: 'period',
            unlockTime: StudyUTimeOfDay(),
            lockTime: StudyUTimeOfDay(hour: 23),
          ),
        ),
      );
      widget.onResult(result);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

const nutritionInstructionsShownKey =
    'nutrition_instructions_shown_nutrition-task';

NutritionTask nutritionTask({
  String? instructions,
  int? minimumMeals,
  List<String>? customMealTypes,
  bool requireDailyCompletionConfirmation = true,
}) => NutritionTask.withId()
  ..id = 'nutrition-task'
  ..title = 'Nutrition'
  ..instructions = instructions
  ..minimumMealsRequired = minimumMeals
  ..customMealTypes = customMealTypes
  ..requireDailyCompletionConfirmation = requireDailyCompletionConfirmation;

NutritionProfile nutrition(double energyKcal) => NutritionProfile(
  energyKcal: energyKcal,
  protein: 0,
  carbs: 0,
  fat: 0,
  sugars: 0,
  fiber: 0,
  saturatedFat: 0,
  transFat: 0,
  cholesterol: 0,
  sodium: 0,
  waterContent: 0,
  micros: {},
);

FoodEntry food(String id, String name, double energyKcal) => FoodEntry(
  id: id,
  foodId: '$id-definition',
  foodVersionId: '$id-version',
  entryType: FoodEntryType.singleIngredient,
  name: name,
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: nutrition(energyKcal),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime(2026, 7, 15),
  originalValues: {},
);

MealLog meal(
  String id,
  MealType type, {
  String? label,
  List<FoodEntry> foods = const [],
  bool isSkipped = false,
  MealOccurrenceTimePrecision timePrecision =
      MealOccurrenceTimePrecision.approximate,
}) => MealLog(
  id: id,
  mealType: type,
  customMealLabel: label,
  mealContext: MealContext.home,
  timestamp: DateTime(2026, 7, 15, 12),
  timePrecision: timePrecision,
  timezone: 'UTC',
  isSkipped: isSkipped,
  skipReason: isSkipped ? 'Not hungry' : null,
  foods: foods,
);

DailyRecall recall(List<MealLog> meals) => DailyRecall(
  id: 'recall',
  date: DateTime(2026, 7, 15),
  recallMode: RecallMode.realtimeRecord,
  entryStartedAt: DateTime(2026, 7, 15, 8),
  meals: meals,
);

({NutritionTask task, StudySubject subject}) historicalNavigationSetup(
  String foodName, {
  required bool hasPersistenceTarget,
}) {
  final task = nutritionTask()..id = 'task';
  task.schedule.completionPeriods = [
    CompletionPeriod(
      id: 'period',
      unlockTime: StudyUTimeOfDay(),
      lockTime: StudyUTimeOfDay(hour: 23),
    ),
  ];
  final subject = StudySubject('subject', 'study', 'user', [])
    ..startedAt = DateTime.now().subtract(const Duration(days: 3));
  subject.study = (Study('study', 'user')
    ..schedule = (StudySchedule()..numberOfCycles = 0)
    ..interventions = []);
  final historicalRecall = recall([
    meal('meal', MealType.breakfast, foods: [food('food', foodName, 100)]),
  ])..studyDaySnapshot = subject.getDayOfStudyFor(DateTime.now()) - 1;
  final progress = SubjectProgress(
    subjectId: subject.id,
    interventionId: 'intervention',
    taskId: task.id,
    resultType: 'DailyRecall',
    result: Result<DailyRecall>.app(
      type: 'DailyRecall',
      periodId: 'period',
      result: historicalRecall,
    ),
  );
  if (hasPersistenceTarget) {
    progress.completedAt = DateTime.now()
        .subtract(const Duration(days: 1))
        .toUtc();
  }
  subject.progress.add(progress);
  return (task: task, subject: subject);
}

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({
      nutritionInstructionsShownKey: true,
      'nutrition_instructions_shown_task': true,
    }),
  );

  testWidgets('historical mode shows context and hides workspace navigation', (
    tester,
  ) async {
    final date = DateTime(2026, 7, 15);
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = DateTime.now().subtract(const Duration(days: 2));
    subject.study = (Study('study', 'user')
      ..schedule = (StudySchedule()..numberOfCycles = 0)
      ..interventions = []);
    final target = NutritionRecallPersistenceTarget(
      taskId: 'task',
      periodId: 'period',
      interventionId: 'intervention',
      completedAt: DateTime.utc(2026, 7, 15, 12),
      studyDaySnapshot: subject.getDayOfStudyFor(DateTime.now()) - 1,
    );

    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal('meal', MealType.breakfast, foods: [food('food', 'Apple', 100)]),
        ]),
        historicalDate: date,
        persistenceTarget: target,
        appState: AppState()..activeSubject = subject,
      ),
    );
    await tester.pump();

    expect(find.text('Statistics'), findsNothing);
    expect(find.text('My items'), findsNothing);
    expect(find.byIcon(Icons.history_outlined), findsNothing);
    expect(find.byIcon(Icons.help_outline), findsNothing);
  });

  testWidgets(
    'read-only historical record without a target stays in historical shell',
    (tester) async {
      await tester.pumpWidget(
        nutritionTaskApp(
          nutritionTask(),
          existingRecall: recall([
            meal(
              'meal',
              MealType.breakfast,
              foods: [food('food', 'Apple', 100)],
            ),
          ]),
          historicalDate: DateTime(2026, 7, 15),
          readOnly: true,
        ),
      );
      await tester.pump();

      expect(find.text('Read-only'), findsOneWidget);
      expect(find.text('Daily summary'), findsOneWidget);
      expect(find.text('Statistics'), findsNothing);
      expect(find.text('My items'), findsNothing);
      expect(find.byIcon(Icons.history_outlined), findsNothing);
      expect(find.byIcon(Icons.help_outline), findsNothing);
      expect(find.text('Log meal'), findsNothing);

      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(find.byType(NutritionTaskWidget), findsOneWidget);
      expect(find.byType(MealEntryScreen), findsNothing);
    },
  );

  testWidgets('history opens a targetless record in the read-only shell', (
    tester,
  ) async {
    final setup = historicalNavigationSetup(
      'Historical apple',
      hasPersistenceTarget: false,
    );

    await tester.pumpWidget(
      nutritionTaskApp(
        setup.task,
        appState: AppState()..activeSubject = setup.subject,
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historical apple'));
    await tester.pumpAndSettle();

    expect(find.text('Read-only'), findsOneWidget);
    expect(find.text('Historical apple'), findsOneWidget);
    expect(find.text('Daily summary'), findsOneWidget);
    expect(find.text('Statistics'), findsNothing);
    expect(find.text('My items'), findsNothing);
    expect(find.byTooltip('History'), findsNothing);
    expect(find.byTooltip('Help'), findsNothing);
  });

  testWidgets('history refreshes after an opened record closes', (
    tester,
  ) async {
    final setup = historicalNavigationSetup(
      'Historical apple',
      hasPersistenceTarget: false,
    );

    final appState = AppState()
      ..activeSubject = setup.subject
      ..selectedStudy = setup.subject.study;
    await tester.pumpWidget(nutritionTaskApp(setup.task, appState: appState));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historical apple'));
    await tester.pumpAndSettle();

    final previous = setup.subject.progress.single;
    final correctedRecall =
        recall([
            meal(
              'meal',
              MealType.breakfast,
              foods: [food('food', 'Corrected apple', 100)],
            ),
          ])
          ..studyDaySnapshot =
              (previous.result.result as DailyRecall).studyDaySnapshot;
    setup.subject.progress[0] = SubjectProgress(
      subjectId: setup.subject.id,
      interventionId: previous.interventionId,
      taskId: setup.task.id,
      resultType: 'DailyRecall',
      result: Result<DailyRecall>.app(
        type: 'DailyRecall',
        periodId: 'period',
        result: correctedRecall,
      ),
    )..completedAt = previous.completedAt;

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Corrected apple'), findsOneWidget);
    expect(find.text('Historical apple'), findsNothing);
  });

  testWidgets('returning from history refreshes the mounted food library', (
    tester,
  ) async {
    final setup = historicalNavigationSetup(
      'Historical apple',
      hasPersistenceTarget: false,
    );
    final repository = FakeNutritionFoodRepository();

    await tester.pumpWidget(
      nutritionTaskApp(
        setup.task,
        appState: AppState()..activeSubject = setup.subject,
        foodRepository: repository,
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.loadCalls, 1);

    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historical apple'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(repository.loadCalls, 2);
  });

  testWidgets('disposing during history does not refresh the food library', (
    tester,
  ) async {
    final setup = historicalNavigationSetup(
      'Historical apple',
      hasPersistenceTarget: false,
    );
    final repository = FakeNutritionFoodRepository();

    await tester.pumpWidget(
      nutritionTaskApp(
        setup.task,
        appState: AppState()..activeSubject = setup.subject,
        foodRepository: repository,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historical apple'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(repository.loadCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expired historical edit returns to History on app resume', (
    tester,
  ) async {
    final setup = historicalNavigationSetup(
      'Editable apple',
      hasPersistenceTarget: true,
    );

    await tester.pumpWidget(
      nutritionTaskApp(
        setup.task,
        appState: AppState()..activeSubject = setup.subject,
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editable apple'));
    await tester.pumpAndSettle();
    setup.subject.startedAt = setup.subject.startedAt!.subtract(
      const Duration(days: 1),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('History')),
      findsOneWidget,
    );
    expect(find.text('Editable apple'), findsOneWidget);
    expect(find.text('This study day is no longer editable.'), findsOneWidget);
  });

  testWidgets('never renders manual completion controls', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(requireDailyCompletionConfirmation: false),
        existingRecall: recall([meal('meal', MealType.breakfast)]),
      ),
    );
    await tester.pump();

    expect(find.text('Finish today’s nutrition log'), findsNothing);
    expect(
      find.text('This submits your current nutrition log for today.'),
      findsNothing,
    );
  });

  testWidgets(
    'statistics destination uses statistics help and no history action',
    (tester) async {
      await tester.pumpWidget(
        nutritionTaskApp(
          nutritionTask(),
          existingRecall: recall([meal('meal', MealType.breakfast)]),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Statistics'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Statistics'),
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('History'), findsNothing);

      await tester.tap(find.byTooltip('Help'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Averages include only completed study days'),
        findsOneWidget,
      );
    },
  );

  testWidgets('task-mode exit returns no completion result', (tester) async {
    var didReturn = false;
    DailyRecall? result;
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: _NutritionLauncher(
            task: nutritionTask(),
            existingRecall: recall([meal('meal', MealType.breakfast)]),
            onResult: (value) {
              didReturn = true;
              result = value;
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(didReturn, isTrue);
    expect(result, isNull);
  });

  testWidgets('warns before leaving without the minimum meals', (tester) async {
    var didReturn = false;
    DailyRecall? result;
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: _NutritionLauncher(
            task: nutritionTask(minimumMeals: 1),
            existingRecall: recall([]),
            onResult: (value) {
              didReturn = true;
              result = value;
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Minimum meals not reached'), findsOneWidget);
    await tester.tap(find.text('Leave anyway'));
    await tester.pumpAndSettle();

    expect(didReturn, isTrue);
    expect(result, isNull);
  });

  testWidgets('shows the recall date as non-interactive header text', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(instructions: '   '),
        existingRecall: recall([]),
      ),
    );
    await tester.pump();

    final expectedDate = MaterialLocalizations.of(
      tester.element(find.byType(NutritionTaskWidget)),
    ).formatMediumDate(DateTime(2026, 7, 15));
    final date = find.text(expectedDate);

    expect(find.text('Instructions'), findsNothing);
    expect(date, findsOneWidget);
    expect(
      find.ancestor(of: date, matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(
      find.ancestor(of: date, matching: find.byType(IconButton)),
      findsNothing,
    );
  });

  testWidgets('empty overview uses one log-meal action', (tester) async {
    await tester.pumpWidget(nutritionTaskApp(nutritionTask()));
    await tester.pump();

    expect(find.text('No meals recorded yet'), findsOneWidget);
    expect(find.text('Breakfast'), findsNothing);
    expect(find.text('Log meal'), findsOneWidget);

    await tester.tap(find.text('Log meal'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Log meal')),
      findsOneWidget,
    );
  });

  testWidgets('German nutrition timeline uses participant translations', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(nutritionTask(), locale: const Locale('de')),
    );
    await tester.pump();

    expect(find.text('Mahlzeiten'), findsOneWidget);
    expect(find.text('Mahlzeit erfassen'), findsOneWidget);
    expect(find.text('Meals'), findsNothing);

    await tester.tap(find.text('Mahlzeit erfassen'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Mahlzeit erfassen'),
      ),
      findsOneWidget,
    );
    expect(find.text('Lunch'), findsNothing);
  });

  testWidgets('configured custom labels remain available in the editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(customMealTypes: ['Morning meal', 'Late meal']),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Log meal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meal label'));
    await tester.pumpAndSettle();

    expect(find.text('Morning meal'), findsOneWidget);
    expect(find.text('Late meal'), findsOneWidget);
  });

  testWidgets('custom tasks keep unmatched legacy meals under Other meals', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(customMealTypes: ['Morning meal']),
        existingRecall: recall([
          meal(
            'configured',
            MealType.other,
            label: 'Morning meal',
            foods: [food('apple', 'Apple', 52)],
          ),
          meal(
            'unmatched',
            MealType.other,
            label: 'Late bite',
            foods: [food('toast', 'Toast', 80)],
          ),
          meal(
            'legacy',
            MealType.breakfast,
            foods: [food('eggs', 'Eggs', 140)],
          ),
        ]),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Morning meal'), findsOneWidget);
    expect(find.textContaining('Other'), findsNothing);
    expect(find.textContaining('Late bite'), findsOneWidget);
    expect(find.textContaining('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsNothing);
    expect(find.text('Toast'), findsOneWidget);
    expect(find.text('Eggs'), findsOneWidget);
  });

  testWidgets('keeps multiple and custom meals separate with previews', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal('snack-1', MealType.snack, foods: [food('apple', 'Apple', 52)]),
          meal(
            'snack-2',
            MealType.snack,
            foods: [food('yogurt', 'Yogurt', 90)],
          ),
          meal('brunch', MealType.brunch, foods: [food('eggs', 'Eggs', 140)]),
          meal(
            'custom',
            MealType.other,
            label: 'Late bite',
            foods: [food('toast', 'Toast', 80)],
          ),
          meal('skipped', MealType.breakfast, isSkipped: true),
        ]),
      ),
    );
    await tester.pump();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Yogurt'), findsOneWidget);
    expect(find.textContaining('Brunch'), findsOneWidget);
    expect(find.textContaining('Late bite'), findsOneWidget);
    expect(find.textContaining('Not hungry'), findsOneWidget);
    expect(find.textContaining('52 kcal'), findsOneWidget);
    expect(find.textContaining('90 kcal'), findsOneWidget);
  });

  testWidgets('timeline deletion asks for confirmation', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'breakfast',
            MealType.breakfast,
            foods: [food('apple', 'Apple', 52)],
          ),
        ]),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this meal?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsNothing);
  });

  testWidgets('deleted editor result removes only the selected meal', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'breakfast',
            MealType.breakfast,
            foods: [food('apple', 'Apple', 52)],
          ),
          meal('lunch', MealType.lunch, foods: [food('yogurt', 'Yogurt', 90)]),
        ]),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete meal'));
    await tester.tap(find.text('Delete meal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(NutritionTaskWidget), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Yogurt'), findsOneWidget);
  });

  testWidgets('shows instructions on first open and keeps them in help', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final task = nutritionTask(instructions: 'Record every meal.');

    await tester.pumpWidget(nutritionTaskApp(task));
    await tester.pumpAndSettle();

    expect(find.text('Instructions'), findsOneWidget);
    expect(find.text('Record every meal.'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Help'));
    await tester.pumpAndSettle();

    expect(find.text('Instructions'), findsOneWidget);
    expect(find.text('Record every meal.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(nutritionTaskApp(task));
    await tester.pumpAndSettle();

    expect(find.text('Close'), findsNothing);
  });

  testWidgets('uses the default instructions and minimum meal requirement', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(nutritionTaskApp(nutritionTask(minimumMeals: 2)));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Please record all the foods and beverages you consumed today. '
        'For each meal or snack, provide as much detail as possible including '
        'portion sizes and preparation methods.',
      ),
      findsOneWidget,
    );
    expect(find.text('Please record at least 2 meal(s)'), findsOneWidget);
  });

  testWidgets('groups unknown-time entries at the end', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'unknown',
            MealType.other,
            timePrecision: MealOccurrenceTimePrecision.unknown,
            foods: [food('tea', 'Tea', 5)],
          ),
          meal(
            'early',
            MealType.breakfast,
            foods: [food('cereal', 'Cereal', 200)],
          ),
        ]),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Time not remembered'), findsNWidgets(2));
    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Cereal'), findsOneWidget);
    final cerealY = tester.getTopLeft(find.text('Cereal')).dy;
    final teaY = tester.getTopLeft(find.text('Tea')).dy;
    expect(cerealY, lessThan(teaY));
  });

  testWidgets('timestamp does not make unknown precision chronological', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'unknown',
            MealType.other,
            timePrecision: MealOccurrenceTimePrecision.unknown,
            foods: [food('tea', 'Tea', 5)],
          )..timestamp = DateTime(2026, 7, 15, 6),
          meal('later', MealType.dinner, foods: [food('bread', 'Bread', 100)]),
        ]),
      ),
    );
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('Bread')).dy,
      lessThan(tester.getTopLeft(find.text('Tea')).dy),
    );
  });

  testWidgets('adjacent category entries share one icon header', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'first',
            MealType.breakfast,
            foods: [food('cereal', 'Cereal', 200)],
          )..timestamp = DateTime(2026, 7, 15, 8),
          meal(
            'second',
            MealType.breakfast,
            foods: [food('toast', 'Toast', 150)],
          )..timestamp = DateTime(2026, 7, 15, 9),
        ]),
      ),
    );
    await tester.pump();

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Cereal'), findsOneWidget);
    expect(find.text('Toast'), findsOneWidget);
    expect(find.textContaining('Breakfast •'), findsNothing);
  });

  testWidgets('interleaved categories stay chronological', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'first',
            MealType.breakfast,
            foods: [food('cereal', 'Cereal', 200)],
          )..timestamp = DateTime(2026, 7, 15, 8),
          meal('lunch', MealType.lunch, foods: [food('pasta', 'Pasta', 500)])
            ..timestamp = DateTime(2026, 7, 15, 12),
          meal(
            'second',
            MealType.breakfast,
            foods: [food('toast', 'Toast', 150)],
          )..timestamp = DateTime(2026, 7, 15, 13),
        ]),
      ),
    );
    await tester.pump();

    final breakfastHeaders = find.text('Breakfast');
    expect(breakfastHeaders, findsNWidgets(2));
    expect(
      tester.getTopLeft(breakfastHeaders.at(0)).dy,
      lessThan(tester.getTopLeft(find.text('Lunch')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Lunch')).dy,
      lessThan(tester.getTopLeft(breakfastHeaders.at(1)).dy),
    );
  });

  testWidgets('historical Other and skipped labels remain visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal('other', MealType.other, foods: [food('tea', 'Tea', 5)]),
          meal(
            'skipped',
            MealType.other,
            label: 'Early breakfast',
            isSkipped: true,
          ),
        ]),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Other'), findsOneWidget);
    expect(find.textContaining('Early breakfast'), findsOneWidget);
  });
}
