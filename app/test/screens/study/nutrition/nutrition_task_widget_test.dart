import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/tasks/observation/nutrition_task_widget.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/widgets/photo_recall_section.dart';
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
const _photoManagerChannel = MethodChannel('com.fluttercandies/photo_manager');

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

FakeNutritionFoodRepository _savedSoupRepository() =>
    FakeNutritionFoodRepository([
      SavedFoodTemplate(
        id: 'saved-soup',
        userId: 'anonymous',
        name: 'Saved soup',
        isPublic: false,
        createdAt: DateTime(2026, 7, 15),
        prototype: food('soup', 'Soup', 100),
      ),
    ]);

Future<void> _selectSavedSoup(WidgetTester tester) async {
  await tester.tap(find.text('Library'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Saved soup'));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('selection-tray')),
      matching: find.byType(FilledButton),
    ),
  );
  await tester.pumpAndSettle();
}

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
  setUp(() {
    SharedPreferences.setMockInitialValues({
      nutritionInstructionsShownKey: true,
      'nutrition_instructions_shown_task': true,
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _photoManagerChannel,
          (_) async => PermissionState.denied.index,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_photoManagerChannel, null);
  });

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
    expect(find.byType(PhotoRecallSection), findsNothing);
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

  testWidgets('library add opens the food and meal editors', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.pumpWidget(nutritionTaskApp(nutritionTask()));
    await tester.pumpAndSettle();

    final navigation = find.byType(NavigationBar);
    final add = find.byTooltip(l10n.add);
    expect(add, findsNothing);
    await tester.tap(
      find.descendant(of: navigation, matching: find.text(l10n.food_library)),
    );
    await tester.pumpAndSettle();

    await tester.tap(add);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.add_food_action));
    await tester.pumpAndSettle();
    expect(find.byType(FoodEntryScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.add_meal_action));
    await tester.pumpAndSettle();
    expect(find.byType(MealCreatorScreen), findsOneWidget);
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
    'moves the daily summary to statistics and retains the period selection',
    (tester) async {
      await tester.pumpWidget(
        nutritionTaskApp(
          nutritionTask(),
          existingRecall: recall([
            meal(
              'meal',
              MealType.breakfast,
              foods: [food('apple', 'Apple', 100)],
            ),
          ])..date = DateTime.now(),
        ),
      );
      await tester.pump();
      expect(find.text('Daily summary'), findsNothing);

      final navigation = find.byType(NavigationBar);
      final statistics = find.descendant(
        of: navigation,
        matching: find.text('Statistics'),
      );
      await tester.tap(statistics);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Statistics'),
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('History'), findsNothing);
      expect(find.text('Daily summary'), findsOneWidget);
      expect(find.text('100 kcal'), findsOneWidget);

      await tester.tap(find.byTooltip('Help'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Averages include only completed study days'),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      expect(find.text('Energy by study day'), findsOneWidget);
      await tester.tap(
        find.descendant(of: navigation, matching: find.text('Today')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Daily summary'), findsNothing);

      await tester.tap(statistics);
      await tester.pumpAndSettle();
      expect(find.text('Energy by study day'), findsOneWidget);
    },
  );

  for (final tab in ['Today', 'Statistics', 'Library']) {
    testWidgets('Exit closes $tab without returning a completion result', (
      tester,
    ) async {
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
      await tester.pumpAndSettle();

      final navigation = find.byType(NavigationBar);
      await tester.tap(
        find.descendant(of: navigation, matching: find.text(tab)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsNothing);
      await tester.tap(
        find.descendant(of: navigation, matching: find.text('Exit')),
      );
      await tester.pumpAndSettle();

      expect(didReturn, isTrue);
      expect(result, isNull);
      expect(find.byType(NutritionTaskWidget), findsNothing);
    });
  }

  testWidgets('Exit asks before leaving below the advisory meal target', (
    tester,
  ) async {
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
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();

    expect(didReturn, isFalse);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(didReturn, isFalse);
    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();
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

  testWidgets('Log meal opens search before the new meal editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(nutritionTask(), foodRepository: _savedSoupRepository()),
    );
    await tester.pump();

    expect(find.text('No meals recorded yet'), findsOneWidget);
    expect(find.text('Breakfast'), findsNothing);
    expect(find.text('Log meal'), findsOneWidget);

    await tester.tap(find.text('Log meal'));
    await tester.pumpAndSettle();
    expect(find.byType(FoodSearchScreen), findsOneWidget);
    expect(find.byType(MealEntryScreen, skipOffstage: false), findsNothing);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('No meals recorded yet'), findsOneWidget);

    await tester.tap(find.text('Log meal'));
    await tester.pumpAndSettle();
    await _selectSavedSoup(tester);

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Log meal')),
      findsOneWidget,
    );
    expect(find.text('Soup'), findsOneWidget);
    expect(find.byType(FoodSearchScreen), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();
    expect(find.text('No meals recorded yet'), findsOneWidget);
  });

  testWidgets('expands Photo Recall and logs a new meal from a photo', (
    tester,
  ) async {
    const photoId = 'lunch-photo';
    final photoTime = DateTime(2026, 7, 15, 12, 30);
    var galleryQueries = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_photoManagerChannel, (call) async {
          if (call.method == 'getAssetPathList') galleryQueries++;
          return switch (call.method) {
            'getPermissionState' => PermissionState.authorized.index,
            'getAssetPathList' => {
              'data': [
                {'id': 'all', 'name': 'All photos', 'isAll': true},
              ],
            },
            'getAssetCountFromPath' => 1,
            'getAssetListPaged' => {
              'data': [
                {
                  'id': photoId,
                  'type': 1,
                  'width': 300,
                  'height': 300,
                  'createDt': photoTime.millisecondsSinceEpoch ~/ 1000,
                },
              ],
            },
            _ => null,
          };
        });

    final today = recall([
      meal(
        'breakfast',
        MealType.breakfast,
        foods: [food('toast', 'Toast', 80)],
      ),
    ]);
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: today,
        foodRepository: _savedSoupRepository(),
      ),
    );
    await tester.pumpAndSettle();

    final photoRecall = find.text('Photo Recall');
    final gallery = find.byType(PhotoRecallSection);
    expect(gallery, findsNothing);
    expect(galleryQueries, 0);
    expect(
      tester.getTopLeft(photoRecall).dy,
      greaterThan(
        tester.getBottomLeft(find.byKey(const ValueKey('meal-breakfast'))).dy,
      ),
    );
    await tester.ensureVisible(photoRecall);
    await tester.tap(photoRecall);
    await tester.pumpAndSettle();
    expect(tester.widget<PhotoRecallSection>(gallery).date, today.date);

    await tester.tap(photoRecall);
    await tester.pumpAndSettle();
    expect(gallery, findsNothing);

    await tester.tap(photoRecall);
    await tester.pumpAndSettle();
    final thumbnail = find.byKey(const ValueKey(photoId));
    await tester.ensureVisible(thumbnail);
    await tester.tap(thumbnail);
    await tester.pumpAndSettle();

    final editor = find.byType(MealEntryScreen);
    expect(tester.widget<MealEntryScreen>(editor).existingMeal, isNull);
    expect(tester.widget<MealEntryScreen>(editor).occurrenceDate, today.date);
    final preview = find.descendant(
      of: editor,
      matching: find.byType(PhotoRecallThumbnail),
    );
    expect(tester.widget<PhotoRecallThumbnail>(preview).photo.id, photoId);
    expect(find.text('Select a time'), findsOneWidget);

    await tester.tap(find.text('Select a time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("I don't remember"));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add food or saved meal'));
    await tester.pumpAndSettle();
    expect(find.byType(FoodSearchScreen), findsOneWidget);
    await _selectSavedSoup(tester);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsNothing);
    expect(find.text('Toast'), findsOneWidget);
    expect(find.text('Soup'), findsOneWidget);
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

    final search = tester.widget<FoodSearchScreen>(
      find.byType(FoodSearchScreen),
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(FoodSearchScreen)),
    )!;
    expect(search.mealLabel, l10n.meal_neutral_label);
    expect(find.text('Lunch'), findsNothing);
  });

  testWidgets('configured custom labels remain available in the editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(customMealTypes: ['Morning meal', 'Late meal']),
        foodRepository: _savedSoupRepository(),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Log meal'));
    await tester.pumpAndSettle();
    await _selectSavedSoup(tester);
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
    final actions = find.byType(BottomSheet);
    final deleteAction = find.descendant(
      of: actions,
      matching: find.text('Delete'),
    );
    expect(
      find.descendant(of: actions, matching: find.text('Breakfast')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: actions, matching: find.text('Edit')),
      findsOneWidget,
    );
    await tester.tap(deleteAction);
    await tester.pumpAndSettle();

    expect(find.text('Delete this meal?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(deleteAction);
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

  testWidgets('uses the default instructions and configured meal target', (
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
    final l10n = AppLocalizations.of(
      tester.element(find.byType(NutritionTaskWidget)),
    )!;
    expect(find.text(l10n.min_meals_required(2)), findsOneWidget);
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
