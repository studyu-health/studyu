import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/widgets/photo_recall_section.dart';
import 'package:studyu_core/core.dart';

import 'fake_nutrition_food_repository.dart';

FoodEntry testFood() => FoodEntry(
  id: 'food',
  foodId: 'food-definition',
  foodVersionId: 'food-version',
  entryType: FoodEntryType.singleIngredient,
  name: 'Apple',
  amount: 1,
  unit: 'piece',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.householdMeasure,
  portionState: PortionState.raw,
  nutrition: NutritionProfile(
    energyKcal: 52,
    protein: 0.3,
    carbs: 14,
    fat: 0.2,
    sugars: 10,
    fiber: 2.4,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 1,
    waterContent: 86,
    micros: {},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime(2026, 7, 15),
  originalValues: {
    'nested': {'value': 1},
  },
);

MealLog skippedMeal({String? reason}) => MealLog(
  id: 'meal',
  mealType: MealType.breakfast,
  customMealLabel: 'Early breakfast',
  mealContext: MealContext.home,
  locationDescription: 'Kitchen',
  timestamp: DateTime(2026, 7, 15, 8),
  timezone: 'UTC',
  isSkipped: true,
  skipReason: reason,
  companyContext: CompanyContext.family,
  distractionContext: DistractionContext.phone,
  templateId: 'template',
  foods: [testFood()],
);

MealLog emptyMeal() => MealLog(
  id: 'empty-meal',
  mealType: MealType.other,
  customMealLabel: 'Supper',
  mealContext: MealContext.home,
  timestamp: DateTime(2026, 7, 15, 20),
  timezone: 'UTC',
  isSkipped: false,
  foods: [],
);

MealLog editableMeal({String? customMealLabel = 'Supper'}) => MealLog(
  id: 'editable-meal',
  mealType: MealType.other,
  customMealLabel: customMealLabel,
  mealContext: MealContext.home,
  timestamp: DateTime(2026, 7, 15, 20),
  timezone: 'UTC',
  isSkipped: false,
  foods: [testFood()],
);

Future<void> openMealEntry(
  WidgetTester tester,
  MealLog? meal, {
  NutritionTask? task,
  MealType? initialMealType,
  DateTime? occurrenceDate,
  NutritionRecallPersistenceTarget? historicalTarget,
  NutritionFoodRepository? foodRepository,
  AppState? appState,
  bool openFoodSearch = false,
  ValueChanged<MealLog?>? onResult,
  ValueChanged<MealEntryResult?>? onEntryResult,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => appState ?? AppState(),
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  final result = await Navigator.of(context)
                      .push<MealEntryResult>(
                        MaterialPageRoute(
                          builder: (_) => MealEntryScreen(
                            existingMeal: meal,
                            task: task,
                            initialMealType: initialMealType,
                            occurrenceDate: occurrenceDate,
                            historicalTarget: historicalTarget,
                            foodRepository:
                                foodRepository ?? FakeNutritionFoodRepository(),
                            openFoodSearch: openFoodSearch,
                          ),
                        ),
                      );
                  onEntryResult?.call(result);
                  onResult?.call(
                    result is SavedMealEntryResult ? result.meal : null,
                  );
                },
                child: const Text('Open meal'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open meal'));
  await tester.pumpAndSettle();
}

class _TrackingNutritionFoodRepository({
  required final int todayUpdateCount,
  final int failuresBeforeSuccess = 0,
  final bool failTemplateSave = false,
}) extends FakeNutritionFoodRepository {
  int mutationCalls = 0;
  final List<String?> mutationIds = [];
  final List<int?> propagatedStudyDays = [];
  List<Map<String, dynamic>> Function(FoodEntry definition)? progressBuilder;
  FoodEntry? submittedSnapshot;
  final List<FoodEntryType> savedTemplateTypes = [];

  @override
  Future<SavedFoodTemplate> saveTemplate({
    required String subjectId,
    required String name,
    required FoodEntry food,
    List<String>? tags,
    String? expectedVersionId,
  }) {
    savedTemplateTypes.add(food.entryType);
    if (failTemplateSave) {
      throw StateError('template save failure');
    }
    return super.saveTemplate(
      subjectId: subjectId,
      name: name,
      food: food,
      tags: tags,
      expectedVersionId: expectedVersionId,
    );
  }

  @override
  Future<NutritionFoodMutationResult> mutateHistoricalDefinition({
    required String subjectId,
    required FoodEntry snapshot,
    required String expectedVersionId,
    required String entryId,
    required Map<String, dynamic> target,
    int? currentStudyDay,
    String? mutationId,
  }) async {
    mutationCalls++;
    mutationIds.add(mutationId);
    propagatedStudyDays.add(currentStudyDay);
    submittedSnapshot = FoodEntry.fromJson(snapshot.toJson());
    if (mutationCalls <= failuresBeforeSuccess) {
      throw StateError('transient mutation failure');
    }
    final definition = FoodEntry.fromJson(snapshot.toJson())
      ..foodVersionId = 'updated-food-version';
    final now = DateTime.now();
    return NutritionFoodMutationResult(
      definition: NutritionFoodDefinition(
        id: definition.foodId,
        subjectId: subjectId,
        kind: definition.entryType == FoodEntryType.meal ? 'meal' : 'food',
        currentVersionId: definition.foodVersionId,
        deletedAt: null,
        snapshot: definition,
        createdAt: now,
        updatedAt: now,
      ),
      progress: progressBuilder?.call(definition) ?? const [],
      selectedHistoricalUpdateCount: 1,
      todayUpdateCount: todayUpdateCount,
    );
  }
}

({AppState appState, NutritionRecallPersistenceTarget target})
_historicalEditingSetup() {
  final subject = StudySubject('subject', 'study', 'user', [])
    ..startedAt = DateTime.now().subtract(const Duration(days: 5));
  subject.study = (Study('study', 'user')
    ..schedule = (StudySchedule()..numberOfCycles = 0)
    ..interventions = []);
  final currentStudyDay = subject.getDayOfStudyFor(DateTime.now());
  final target = NutritionRecallPersistenceTarget(
    taskId: 'task',
    periodId: 'period',
    interventionId: 'intervention',
    completedAt: DateTime.now().subtract(const Duration(days: 1)),
    studyDaySnapshot: currentStudyDay - 1,
  );
  return (appState: AppState()..activeSubject = subject, target: target);
}

Future<_TrackingNutritionFoodRepository> _openValidNewHistoricalMeal(
  WidgetTester tester, {
  ValueChanged<MealLog?>? onResult,
  bool failTemplateSave = false,
}) async {
  final setup = _historicalEditingSetup();
  final repository = _TrackingNutritionFoodRepository(
    todayUpdateCount: 0,
    failTemplateSave: failTemplateSave,
  );
  await openMealEntry(
    tester,
    null,
    initialMealType: MealType.breakfast,
    historicalTarget: setup.target,
    foodRepository: repository,
    appState: setup.appState,
    openFoodSearch: true,
    onResult: onResult,
  );

  await tester.tap(find.byTooltip('Create food'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save to My items for future use'));
  await tester.enterText(find.byType(TextFormField).first, 'Historical toast');
  await tester.tap(
    find.widgetWithText(FilledButton, 'Save and add to Breakfast'),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add 1 item to Breakfast'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Select a time'));
  await tester.pumpAndSettle();
  await tester.tap(find.text("I don't remember"));
  await tester.pumpAndSettle();
  return repository;
}

DailyRecall _recallWithFoods(List<FoodEntry> foods, {required int? studyDay}) =>
    DailyRecall(
      id: 'recall-${foods.first.id}-${studyDay ?? 'legacy'}',
      date: DateTime.now(),
      recallMode: RecallMode.realtimeRecord,
      entryStartedAt: DateTime.now(),
      meals: [
        MealLog(
          id: 'meal-${foods.first.id}',
          mealType: MealType.breakfast,
          mealContext: MealContext.home,
          timezone: 'UTC',
          isSkipped: false,
          foods: foods,
        ),
      ],
      studyDaySnapshot: studyDay,
    );

SubjectProgress _progressWithRecall(
  DailyRecall recall, {
  required String taskId,
  required String periodId,
  required DateTime completedAt,
}) => SubjectProgress(
  subjectId: 'subject',
  interventionId: 'intervention-$taskId',
  taskId: taskId,
  resultType: 'DailyRecall',
  result: Result<DailyRecall>.app(
    type: 'DailyRecall',
    periodId: periodId,
    result: recall,
  ),
)..completedAt = completedAt;

FoodEntry _nestedFoodMatch() {
  final component = FoodEntry.fromJson(testFood().toJson())
    ..id = 'nested-component';
  return FoodEntry.fromJson(testFood().toJson())
    ..id = 'unrelated-composite-entry'
    ..foodId = 'unrelated-composite-definition'
    ..entryType = FoodEntryType.meal
    ..componentFoods = [
      FoodComposition(
        id: 'nested-composition',
        parentEntryId: 'unrelated-composite-entry',
        foodId: component.foodId,
        amount: component.amount,
        unit: component.unit,
        sortOrder: 0,
      ),
    ]
    ..componentSnapshots = [component];
}

MealLog _mealWithCompositeDefinition() {
  final component = FoodEntry.fromJson(testFood().toJson())
    ..id = 'component-snapshot'
    ..foodId = 'component-definition'
    ..foodVersionId = 'component-version';
  component.nutrition.micros = {'iron': 4};
  final composite = FoodEntry.fromJson(testFood().toJson())
    ..id = 'composite-entry'
    ..foodId = 'composite-definition'
    ..foodVersionId = 'composite-version'
    ..entryType = FoodEntryType.meal
    ..name = 'Fruit bowl'
    ..amount = 2
    ..nutrition.energyKcal = 104
    ..componentFoods = [
      FoodComposition(
        id: 'composition',
        parentEntryId: 'composite-entry',
        foodId: component.foodId,
        amount: 1,
        unit: component.unit,
        sortOrder: 0,
      ),
    ]
    ..componentSnapshots = [component];
  composite.nutrition.micros = {'iron': 8};
  final individualComponent = FoodEntry.fromJson(component.toJson())
    ..id = 'individual-component-entry'
    ..name = 'Individual apple';
  return editableMeal()..foods = [composite, individualComponent];
}

MealLog _mealWithMatchingDefinitions() {
  final selected = FoodEntry.fromJson(testFood().toJson())
    ..amount = 2
    ..nutrition.energyKcal = 104;
  final sibling = FoodEntry.fromJson(testFood().toJson())
    ..id = 'sibling-entry'
    ..amount = 3
    ..nutrition.energyKcal = 156;
  return editableMeal()..foods = [selected, sibling];
}

Finder foodEditorInput(String label) => find.byWidgetPredicate(
  (widget) =>
      widget is TextField &&
      (widget.decoration?.labelText ?? '').toLowerCase().contains(
        label.toLowerCase(),
      ),
);

Future<void> selectMealType(
  WidgetTester tester,
  String label, {
  String? customLabel,
}) async {
  final mealLabelTrigger = find.text('Meal label');
  await tester.tap(
    mealLabelTrigger.evaluate().isNotEmpty
        ? mealLabelTrigger.last
        : find.byIcon(Icons.label_outline),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
  if (customLabel != null) {
    await tester.enterText(find.byType(TextField).last, customLabel);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
  }
}

Future<void> openFoodSearchFromMeal(WidgetTester tester) async {
  final addFood = find.byTooltip('Add food or saved meal');
  await tester.ensureVisible(
    addFood.evaluate().isNotEmpty
        ? addFood
        : find.text('Add food or saved meal').first,
  );
  await tester.tap(
    addFood.evaluate().isNotEmpty
        ? addFood
        : find.text('Add food or saved meal').first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('add-food-search-option')));
  await tester.pumpAndSettle();
}

Future<void> chooseMealTime(
  WidgetTester tester,
  String precision, {
  required String hour,
  required String minute,
}) async {
  await tester.tap(find.text('Time'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(precision));
  await tester.pumpAndSettle();
  expect(find.byType(TimePickerDialog), findsOneWidget);
  await tester.tap(find.byIcon(Icons.keyboard_outlined));
  await tester.pumpAndSettle();
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), hour);
  await tester.enterText(fields.at(1), minute);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('meal clone does not share nested food metadata', () {
    final original = skippedMeal();
    final clone = cloneMealLog(original);

    (clone.foods.single.originalValues['nested']
            as Map<String, dynamic>)['value'] =
        2;

    expect(
      (original.foods.single.originalValues['nested']
          as Map<String, dynamic>)['value'],
      1,
    );
  });

  testWidgets('new meal uses the requested initial meal type', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: Locale('en'),
          home: MealEntryScreen(initialMealType: MealType.dinner),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Meal label'), findsOneWidget);
    expect(find.text('Dinner'), findsWidgets);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Log meal')),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Done'), findsOneWidget);
    expect(find.text('Delete meal'), findsNothing);
    expect(find.text('Select a time'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    await tester.tap(find.text('Select a time'));
    await tester.pumpAndSettle();
    final timeGroup = tester.widget<RadioGroup<MealOccurrenceTimePrecision>>(
      find.byType(RadioGroup<MealOccurrenceTimePrecision>),
    );
    expect(timeGroup.groupValue, isNull);
    await tester.tap(find.text("I don't remember"));
    await tester.pumpAndSettle();

    expect(find.text('Time not remembered'), findsOneWidget);
    expect(find.text('Required'), findsNothing);
  });

  testWidgets('historical new meal saves reusable template by default', (
    tester,
  ) async {
    MealLog? result;
    final repository = await _openValidNewHistoricalMeal(
      tester,
      onResult: (value) => result = value,
    );

    final saveToMyItems = find.widgetWithText(
      CheckboxListTile,
      'Save to My items for future use',
    );
    expect(tester.widget<CheckboxListTile>(saveToMyItems).value, isTrue);

    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();

    expect(repository.savedTemplateTypes, [FoodEntryType.meal]);
    expect(result?.foods.single.name, 'Historical toast');
  });

  testWidgets(
    'historical new meal reusable save failure keeps editor open until opt-out',
    (tester) async {
      MealLog? result;
      final repository = await _openValidNewHistoricalMeal(
        tester,
        failTemplateSave: true,
        onResult: (value) => result = value,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Done'));
      await tester.pumpAndSettle();

      expect(repository.savedTemplateTypes, [FoodEntryType.meal]);
      expect(result, isNull);
      expect(find.byType(MealEntryScreen), findsOneWidget);
      expect(find.text('Could not save results'), findsOneWidget);

      await tester.tap(find.text('Save to My items for future use'));
      await tester.tap(find.widgetWithText(FilledButton, 'Done'));
      await tester.pumpAndSettle();

      expect(repository.savedTemplateTypes, [FoodEntryType.meal]);
      expect(result?.foods.single.name, 'Historical toast');
    },
  );

  testWidgets('historical new meal opt-out skips reusable template', (
    tester,
  ) async {
    MealLog? result;
    final repository = await _openValidNewHistoricalMeal(
      tester,
      onResult: (value) => result = value,
    );

    await tester.tap(find.text('Save to My items for future use'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();

    expect(repository.savedTemplateTypes, isEmpty);
    expect(result?.foods.single.name, 'Historical toast');
  });

  testWidgets('unknown historical meal uses recall date when time is added', (
    tester,
  ) async {
    MealLog? result;
    final historical = editableMeal()
      ..timestamp = null
      ..timePrecision = MealOccurrenceTimePrecision.unknown;
    await openMealEntry(
      tester,
      historical,
      occurrenceDate: DateTime(2024, 2, 3),
      onResult: (value) => result = value,
    );

    await tester.tap(find.text('Time'));
    await tester.pumpAndSettle();
    expect(
      find.byType(RadioListTile<MealOccurrenceTimePrecision>),
      findsNWidgets(3),
    );
    await tester.tap(find.text('Exact time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.timestamp!.year, 2024);
    expect(result!.timestamp!.month, 2);
    expect(result!.timestamp!.day, 3);
  });

  testWidgets('exact meal time can be reopened and changed', (tester) async {
    MealLog? result;
    final meal = editableMeal()
      ..timePrecision = MealOccurrenceTimePrecision.exact;
    await openMealEntry(tester, meal, onResult: (value) => result = value);

    await chooseMealTime(tester, 'Exact time', hour: '9', minute: '15');
    await chooseMealTime(tester, 'Exact time', hour: '10', minute: '30');

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.timestamp, isNotNull);
    expect(result!.timestamp!.minute, 30);
    expect(result!.timestamp, isNot(DateTime(2026, 7, 15, 20)));
    expect(result!.timePrecision, MealOccurrenceTimePrecision.exact);
  });

  testWidgets('approximate meal time can be reopened and changed', (
    tester,
  ) async {
    MealLog? result;
    await openMealEntry(
      tester,
      editableMeal(),
      onResult: (value) => result = value,
    );

    await chooseMealTime(tester, 'Approximate time', hour: '9', minute: '15');
    await chooseMealTime(tester, 'Approximate time', hour: '10', minute: '30');

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.timestamp, isNotNull);
    expect(result!.timestamp!.minute, 30);
    expect(result!.timestamp, isNot(DateTime(2026, 7, 15, 20)));
    expect(result!.timePrecision, MealOccurrenceTimePrecision.approximate);
  });

  testWidgets('new meal uses the requested custom meal label', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: Locale('en'),
          home: MealEntryScreen(
            initialMealType: MealType.other,
            initialCustomMealLabel: 'Late bite',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Meal label'), findsOneWidget);
    expect(find.text('Late bite'), findsWidgets);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Log meal')),
      findsOneWidget,
    );
  });

  testWidgets('existing meal wins over requested initial values', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: MealEntryScreen(
            existingMeal: editableMeal(),
            initialMealType: MealType.dinner,
            initialCustomMealLabel: 'Ignored',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Meal label'), findsOneWidget);
    expect(find.text('Supper'), findsWidgets);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Log meal')),
      findsOneWidget,
    );
    expect(find.text('Ignored'), findsNothing);
  });

  testWidgets('built-in meal type clears an existing custom label', (
    tester,
  ) async {
    MealEntryResult? result;
    await openMealEntry(
      tester,
      editableMeal(),
      onEntryResult: (value) => result = value,
    );

    await selectMealType(tester, 'Dinner');

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Log meal')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Supper meal'),
      ),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isA<SavedMealEntryResult>());
    final savedMeal = (result! as SavedMealEntryResult).meal;
    expect(savedMeal.mealType, MealType.dinner);
    expect(savedMeal.customMealLabel, isNull);
  });

  testWidgets('meal type sheet uses task-specific choices', (tester) async {
    MealEntryResult? result;
    final task = NutritionTask.withId()
      ..customMealTypes = ['Morning meal', 'Evening snack', 'Other'];
    await openMealEntry(
      tester,
      editableMeal(),
      task: task,
      onEntryResult: (value) => result = value,
    );

    await tester.tap(find.text('Meal label'));
    await tester.pumpAndSettle();

    expect(find.text('Morning meal'), findsOneWidget);
    expect(find.text('Evening snack'), findsOneWidget);
    expect(find.text('No label'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);

    await tester.tap(find.text('Evening snack'));
    await tester.pumpAndSettle();
    expect(find.text('Evening snack'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final meal = (result! as SavedMealEntryResult).meal;
    expect(meal.mealType, MealType.other);
    expect(meal.customMealLabel, 'Evening snack');
  });

  testWidgets('custom meal choices represent an existing generic Other', (
    tester,
  ) async {
    final task = NutritionTask.withId()
      ..customMealTypes = ['Morning meal', 'Evening snack'];
    await openMealEntry(
      tester,
      editableMeal(customMealLabel: null),
      task: task,
    );

    await tester.tap(find.text('Meal label'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(RadioListTile<String>, 'No label'),
      findsOneWidget,
    );
    expect(find.text('Breakfast'), findsOneWidget);
  });

  testWidgets('custom meal choices can save generic Other', (tester) async {
    MealEntryResult? result;
    final task = NutritionTask.withId()
      ..customMealTypes = ['Morning meal', 'Evening snack'];
    await openMealEntry(
      tester,
      editableMeal(customMealLabel: 'Morning meal'),
      task: task,
      onEntryResult: (value) => result = value,
    );

    await tester.tap(find.text('Meal label'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'No label').last);
    await tester.pumpAndSettle();
    expect(find.text('Log meal'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final meal = (result! as SavedMealEntryResult).meal;
    expect(meal.mealType, MealType.other);
    expect(meal.customMealLabel, isNull);
    expect(meal.isLabelExplicitlyUnset, isTrue);
  });

  testWidgets('meal details apply atomically and dismissal discards edits', (
    tester,
  ) async {
    MealEntryResult? result;
    await openMealEntry(
      tester,
      editableMeal(),
      onEntryResult: (value) => result = value,
    );

    await tester.ensureVisible(find.text('Meal details'));
    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            widget.decoration.labelText == 'Who were you with?',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Family').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(BottomSheet), const Offset(0, 600));
    await tester.pumpAndSettle();

    expect(find.text('Family'), findsNothing);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            widget.decoration.labelText == 'Who were you with?',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Family').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Family'), findsNothing);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            widget.decoration.labelText == 'Who were you with?',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Family').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Home • Family'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(
      (result! as SavedMealEntryResult).meal.companyContext,
      CompanyContext.family,
    );
  });

  testWidgets('meal details clear a hidden location description', (
    tester,
  ) async {
    MealEntryResult? result;
    await openMealEntry(
      tester,
      MealLog(
        id: 'location-meal',
        mealType: MealType.dinner,
        mealContext: MealContext.other,
        locationDescription: 'Park',
        timestamp: DateTime(2026, 7, 15, 20),
        timezone: 'UTC',
        isSkipped: false,
        foods: [testFood()],
      ),
      onEntryResult: (value) => result = value,
    );

    await tester.ensureVisible(find.text('Meal details'));
    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            widget.decoration.labelText == 'Where did you eat?',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            widget.decoration.labelText == 'Where did you eat?',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other').last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final meal = (result! as SavedMealEntryResult).meal;
    expect(meal.mealContext, MealContext.home);
    expect(meal.locationDescription, isNull);
  });

  testWidgets('skipped meal only asks for a reason and keeps save visible', (
    tester,
  ) async {
    await openMealEntry(tester, skippedMeal());

    expect(find.text('Reason for skipping'), findsOneWidget);
    expect(find.text('Meal label'), findsNothing);
    expect(find.text('Meal context'), findsNothing);
    var reasonField = tester.widget<TextField>(find.byType(TextField));
    expect(reasonField.decoration?.errorText, isNull);

    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(saveButton.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    reasonField = tester.widget<TextField>(find.byType(TextField));
    expect(reasonField.decoration?.errorText, 'Enter a reason before saving.');

    await tester.enterText(find.byType(TextField), 'Not hungry');
    await tester.pump();

    reasonField = tester.widget<TextField>(find.byType(TextField));
    expect(reasonField.decoration?.errorText, isNull);
  });

  testWidgets(
    'empty meal keeps validation beside food and does not auto-save',
    (tester) async {
      MealLog? result;
      await openMealEntry(
        tester,
        emptyMeal(),
        onResult: (value) => result = value,
      );

      final emptyFoodState = find.ancestor(
        of: find.text('Add food or saved meal'),
        matching: find.byType(InkWell),
      );
      expect(emptyFoodState, findsOneWidget);
      expect(tester.widget<InkWell>(emptyFoodState).onTap, isNotNull);
      expect(find.text('Foods and saved meals'), findsOneWidget);
      expect(find.text('Meal Nutrition'), findsNothing);
      expect(
        find.ancestor(
          of: find.text('Add food or saved meal'),
          matching: find.byType(Card),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: emptyFoodState,
          matching: find.text('Add at least one food item before saving.'),
        ),
        findsNothing,
      );
      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pump();

      expect(result, isNull);
      expect(find.byType(MealEntryScreen), findsOneWidget);
      expect(
        find.descendant(
          of: emptyFoodState,
          matching: find.text('Add at least one food item before saving.'),
        ),
        findsOneWidget,
      );

      expect(find.text('Skipped this meal'), findsNothing);
      expect(result, isNull);
      expect(find.byType(MealEntryScreen), findsOneWidget);
    },
  );

  testWidgets('meal nutrition appears below meal details in a card', (
    tester,
  ) async {
    await openMealEntry(tester, editableMeal());

    expect(
      tester.getTopLeft(find.text('Foods and saved meals')).dy,
      lessThan(tester.getTopLeft(find.text('Meal label')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Meal details')).dy,
      lessThan(tester.getTopLeft(find.text('Meal Nutrition')).dy),
    );
    expect(
      find.ancestor(
        of: find.text('Meal Nutrition'),
        matching: find.byType(Card),
      ),
      findsOneWidget,
    );
  });

  testWidgets('meal fields cards and chips use native theme defaults', (
    tester,
  ) async {
    await openMealEntry(tester, editableMeal());

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.filled == true ||
                widget.decoration?.fillColor != null),
      ),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField &&
            (widget.decoration.filled == true ||
                widget.decoration.fillColor != null),
      ),
      findsNothing,
    );

    for (final chip in tester.widgetList<FilterChip>(find.byType(FilterChip))) {
      expect(chip.backgroundColor, isNull);
      expect(chip.selectedColor, isNull);
      expect(chip.checkmarkColor, isNull);
    }

    for (final label in ['Meal label', 'Time', 'Apple']) {
      final card = tester.widget<Card>(
        find.ancestor(of: find.text(label), matching: find.byType(Card)).first,
      );
      expect(card.color, isNull);
    }
  });

  testWidgets('routes Photo Recall from Add Food using the occurrence date', (
    tester,
  ) async {
    const channel = MethodChannel('com.fluttercandies/photo_manager');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'getPermissionState':
              return PermissionState.authorized.index;
            case 'getAssetPathList':
              return {'data': <dynamic>[]};
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    final meal = editableMeal()
      ..timestamp = null
      ..timePrecision = MealOccurrenceTimePrecision.unknown;
    await openMealEntry(tester, meal, occurrenceDate: DateTime(2024, 2, 3));

    expect(find.text('Photo Recall'), findsNothing);
    await tester.tap(find.byTooltip('Add food or saved meal'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('add-food-search-option')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('add-food-photo-recall-option')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('add-food-photo-recall-option')),
    );
    await tester.pumpAndSettle();

    final section = tester.widget<PhotoRecallSection>(
      find.byType(PhotoRecallSection),
    );
    expect(section.date, DateTime(2024, 2, 3));
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('No photos found'), findsOneWidget);
  });

  testWidgets('back offers discard and continue actions', (tester) async {
    await openMealEntry(tester, skippedMeal());
    await tester.enterText(find.byType(TextField), 'Not hungry');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Leave this meal?'), findsOneWidget);
    expect(
      find.text('Discard your changes or continue editing.'),
      findsOneWidget,
    );
    expect(find.text('Save and leave'), findsNothing);
    expect(
      find.widgetWithText(FilledButton, 'Discard changes'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Continue editing'), findsOneWidget);

    await tester.tap(find.text('Continue editing'));
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsNothing);
    expect(find.text('Open meal'), findsOneWidget);
  });

  testWidgets('existing meal can return a typed deleted result', (
    tester,
  ) async {
    MealEntryResult? result;
    await openMealEntry(
      tester,
      editableMeal(),
      onEntryResult: (value) => result = value,
    );

    await tester.ensureVisible(find.text('Delete meal'));
    await tester.tap(find.text('Delete meal'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this meal?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(result, isA<DeletedMealEntryResult>());
    expect(find.byType(MealEntryScreen), findsNothing);
  });

  testWidgets('historical entry edit stays local to the selected occurrence', (
    tester,
  ) async {
    final setup = _historicalEditingSetup();
    final repository = _TrackingNutritionFoodRepository(todayUpdateCount: 2);
    MealLog? result;
    await openMealEntry(
      tester,
      _mealWithMatchingDefinitions(),
      historicalTarget: setup.target,
      foodRepository: repository,
      appState: setup.appState,
      onResult: (value) => result = value,
    );

    await tester.tap(find.byTooltip('More options').first);
    await tester.pumpAndSettle();
    expect(find.text('Edit reusable food'), findsOneWidget);
    await tester.tap(find.text('Edit this entry'));
    await tester.pumpAndSettle();

    await tester.enterText(foodEditorInput('Food Name'), 'Local apple');
    await tester.enterText(foodEditorInput('Nutrition values are for'), '75');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repository.mutationCalls, 0);
    expect(find.text('Local apple'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.foods[0].id, 'food');
    expect(result!.foods[0].foodId, 'food-definition');
    expect(result!.foods[0].name, 'Local apple');
    expect(result!.foods[0].amount, 2);
    expect(result!.foods[0].servingSizeGrams, 75);
    expect(result!.foods[1].id, 'sibling-entry');
    expect(result!.foods[1].name, 'Apple');
    expect(result!.foods[1].amount, 3);
    expect(result!.foods[1].servingSizeGrams, 100);
  });

  testWidgets(
    'reusable food propagation defaults off and leaves current records and drafts unchanged',
    (tester) async {
      final setup = _historicalEditingSetup();
      final subject = setup.appState.activeSubject!;
      final currentStudyDay = nutritionStudyDayFor(subject, DateTime.now());
      final direct = FoodEntry.fromJson(testFood().toJson())
        ..id = 'current-direct-entry';
      final currentRecall = _recallWithFoods([
        direct,
        _nestedFoodMatch(),
      ], studyDay: currentStudyDay);
      subject.progress.add(
        _progressWithRecall(
          currentRecall,
          taskId: 'other-task',
          periodId: 'other-period',
          completedAt: DateTime.now().toUtc(),
        ),
      );
      final autoSaveManager = NutritionRecallAutoSaveManager();
      await autoSaveManager.saveRecall(
        recall: currentRecall,
        subjectId: subject.id,
        taskId: 'draft-task',
        interventionId: 'draft-intervention',
        periodId: 'draft-period',
        studyDaySnapshot: currentStudyDay,
      );
      final repository = _TrackingNutritionFoodRepository(todayUpdateCount: 0);

      await openMealEntry(
        tester,
        editableMeal(),
        historicalTarget: setup.target,
        foodRepository: repository,
        appState: setup.appState,
      );
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit reusable food'));
      await tester.pumpAndSettle();

      expect(
        find.text('Also update matching entries in current study day'),
        findsOneWidget,
      );
      expect(
        find.textContaining('You can also update matching entries'),
        findsOneWidget,
      );
      await tester.enterText(foodEditorInput('Food Name'), 'Updated apple');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(repository.propagatedStudyDays, [null]);
      final remoteRecall = subject.progress.single.result.result as DailyRecall;
      expect(remoteRecall.meals.single.foods.first.name, 'Apple');
      expect(
        remoteRecall.meals.single.foods.last.componentSnapshots!.single.name,
        'Apple',
      );
      final draftRecall = (await autoSaveManager.scanPendingRecalls(subject.id))
          .single
          .recall;
      expect(draftRecall.meals.single.foods.first.name, 'Apple');
      expect(
        draftRecall.meals.single.foods.last.componentSnapshots!.single.name,
        'Apple',
      );
      expect(
        find.textContaining(
          'Matching entries in the current study day were not updated',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('No matching entries'), findsNothing);
    },
  );

  testWidgets(
    'reusable food propagation opt-in updates direct current records and drafts',
    (tester) async {
      final setup = _historicalEditingSetup();
      final subject = setup.appState.activeSubject!;
      final currentStudyDay = nutritionStudyDayFor(subject, DateTime.now());
      final completedAt = DateTime.now().toUtc();
      final direct = FoodEntry.fromJson(testFood().toJson())
        ..id = 'current-direct-entry';
      final currentRecall = _recallWithFoods([
        direct,
        _nestedFoodMatch(),
      ], studyDay: currentStudyDay);
      subject.progress.add(
        _progressWithRecall(
          currentRecall,
          taskId: 'other-task',
          periodId: 'other-period',
          completedAt: completedAt,
        ),
      );
      final autoSaveManager = NutritionRecallAutoSaveManager();
      await autoSaveManager.saveRecall(
        recall: currentRecall,
        subjectId: subject.id,
        taskId: 'draft-task',
        interventionId: 'draft-intervention',
        periodId: 'draft-period',
        studyDaySnapshot: currentStudyDay,
      );
      final repository = _TrackingNutritionFoodRepository(todayUpdateCount: 2)
        ..progressBuilder = (definition) => [
          _progressWithRecall(
            replaceNutritionFoodSnapshots(currentRecall, definition),
            taskId: 'other-task',
            periodId: 'other-period',
            completedAt: completedAt,
          ).toJson(),
        ];

      await openMealEntry(
        tester,
        editableMeal(),
        historicalTarget: setup.target,
        foodRepository: repository,
        appState: setup.appState,
      );
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit reusable food'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Also update matching entries in current study day'),
      );
      await tester.enterText(foodEditorInput('Food Name'), 'Updated apple');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(repository.propagatedStudyDays, [currentStudyDay]);
      final remoteRecall = subject.progress.single.result.result as DailyRecall;
      expect(remoteRecall.meals.single.foods.first.name, 'Updated apple');
      expect(
        remoteRecall.meals.single.foods.last.componentSnapshots!.single.name,
        'Apple',
      );
      final draftRecall = (await autoSaveManager.scanPendingRecalls(subject.id))
          .single
          .recall;
      expect(draftRecall.meals.single.foods.first.name, 'Updated apple');
      expect(
        draftRecall.meals.single.foods.last.componentSnapshots!.single.name,
        'Apple',
      );
    },
  );

  testWidgets(
    'draft-only reusable food opt-in reports current-day propagation',
    (tester) async {
      final setup = _historicalEditingSetup();
      final subject = setup.appState.activeSubject!;
      final currentStudyDay = nutritionStudyDayFor(subject, DateTime.now());
      await NutritionRecallAutoSaveManager().saveRecall(
        recall: _recallWithFoods([testFood()], studyDay: currentStudyDay),
        subjectId: subject.id,
        taskId: 'other-task',
        interventionId: 'other-intervention',
        periodId: 'other-period',
        studyDaySnapshot: currentStudyDay,
      );
      final repository = _TrackingNutritionFoodRepository(todayUpdateCount: 0);

      await openMealEntry(
        tester,
        editableMeal(),
        historicalTarget: setup.target,
        foodRepository: repository,
        appState: setup.appState,
      );
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit reusable food'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Also update matching entries in current study day'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(repository.propagatedStudyDays, [currentStudyDay]);
      expect(
        find.text(
          'Reusable item updated. Matching entries in the current study day were also updated.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'nested and legacy current-day records do not show propagation option',
    (tester) async {
      final setup = _historicalEditingSetup();
      final subject = setup.appState.activeSubject!;
      final currentStudyDay = nutritionStudyDayFor(subject, DateTime.now());
      subject.progress.addAll([
        _progressWithRecall(
          _recallWithFoods([_nestedFoodMatch()], studyDay: currentStudyDay),
          taskId: 'nested-task',
          periodId: 'nested-period',
          completedAt: DateTime.now().toUtc(),
        ),
        _progressWithRecall(
          _recallWithFoods([testFood()], studyDay: null),
          taskId: 'legacy-task',
          periodId: 'legacy-period',
          completedAt: DateTime.now().toUtc(),
        ),
      ]);

      await openMealEntry(
        tester,
        editableMeal(),
        historicalTarget: setup.target,
        appState: setup.appState,
      );
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit reusable food'));
      await tester.pumpAndSettle();

      expect(
        find.text('Also update matching entries in current study day'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'historical reusable edit normalizes definition and reports opt-out',
    (tester) async {
      final setup = _historicalEditingSetup();
      final repository = _TrackingNutritionFoodRepository(todayUpdateCount: 3);
      MealEntryResult? result;
      await openMealEntry(
        tester,
        _mealWithMatchingDefinitions(),
        historicalTarget: setup.target,
        foodRepository: repository,
        appState: setup.appState,
        onEntryResult: (value) => result = value,
      );

      await tester.tap(find.byTooltip('More options').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit reusable food'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('You can also update matching entries'),
        findsOneWidget,
      );
      await tester.enterText(foodEditorInput('Food Name'), 'Reusable apple');
      await tester.enterText(foodEditorInput('Nutrition values are for'), '80');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(repository.mutationCalls, 1);
      expect(repository.propagatedStudyDays, [null]);
      expect(repository.submittedSnapshot!.id, 'food');
      expect(repository.submittedSnapshot!.foodId, 'food-definition');
      expect(repository.submittedSnapshot!.amount, 1);
      expect(repository.submittedSnapshot!.nutrition.energyKcal, 52);
      expect(repository.submittedSnapshot!.servingSizeGrams, 80);
      expect(
        find.text(
          'Reusable item updated. Matching entries in the current study day were not updated.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(result, isA<SavedMealEntryResult>());
      final meal = (result! as SavedMealEntryResult).meal;
      expect(meal.foods[0].id, 'food');
      expect(meal.foods[0].foodId, 'food-definition');
      expect(meal.foods[0].foodVersionId, 'updated-food-version');
      expect(meal.foods[0].name, 'Reusable apple');
      expect(meal.foods[0].amount, 2);
      expect(meal.foods[0].nutrition.energyKcal, 104);
      expect(meal.foods[0].servingSizeGrams, 80);
      expect(meal.foods[1].id, 'sibling-entry');
      expect(meal.foods[1].foodVersionId, 'food-version');
      expect(meal.foods[1].name, 'Apple');
      expect(meal.foods[1].amount, 3);
    },
  );

  testWidgets(
    'historical composite definition edit propagates composition only by meal identity',
    (tester) async {
      final setup = _historicalEditingSetup();
      final repository = _TrackingNutritionFoodRepository(todayUpdateCount: 2);
      MealEntryResult? result;
      await openMealEntry(
        tester,
        _mealWithCompositeDefinition(),
        historicalTarget: setup.target,
        foodRepository: repository,
        appState: setup.appState,
        onEntryResult: (value) => result = value,
      );

      await tester.tap(find.byTooltip('More options').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit reusable food'));
      await tester.pumpAndSettle();

      expect(find.byType(MealCreatorScreen), findsOneWidget);
      expect(
        find.textContaining('You can also update matching entries'),
        findsOneWidget,
      );
      await tester.enterText(
        foodEditorInput('Meal name'),
        'Updated fruit bowl',
      );
      await tester.enterText(foodEditorInput('Servings'), '2');
      await tester.ensureVisible(find.byTooltip('Edit amount'));
      await tester.drag(find.byType(ListView).last, const Offset(0, -80));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit amount'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '1.5');
      await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(repository.mutationCalls, 1);
      expect(repository.propagatedStudyDays, [null]);
      expect(repository.submittedSnapshot!.foodId, 'composite-definition');
      expect(repository.submittedSnapshot!.amount, 1);
      expect(repository.submittedSnapshot!.nutrition.energyKcal, 39);
      expect(repository.submittedSnapshot!.nutrition.micros, {'iron': 3});
      expect(repository.submittedSnapshot!.componentFoods!.single.amount, 0.75);
      expect(
        repository.submittedSnapshot!.componentSnapshots!.single.foodId,
        'component-definition',
      );
      expect(
        repository.submittedSnapshot!.componentSnapshots!.single.amount,
        0.75,
      );
      expect(
        repository
            .submittedSnapshot!
            .componentSnapshots!
            .single
            .nutrition
            .micros,
        {'iron': 3},
      );
      expect(find.text('Updated fruit bowl'), findsOneWidget);
      expect(find.text('Individual apple'), findsOneWidget);
      expect(
        find.text(
          'Reusable item updated. Matching entries in the current study day were not updated.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      final savedMeal = (result! as SavedMealEntryResult).meal;
      expect(savedMeal.mealType, MealType.other);
      expect(savedMeal.timestamp, DateTime(2026, 7, 15, 20));
      expect(savedMeal.foods.first.id, 'composite-entry');
      expect(savedMeal.foods.first.amount, 2);
      expect(savedMeal.foods.first.nutrition.energyKcal, 78);
      expect(savedMeal.foods.first.nutrition.micros, {'iron': 6});
      expect(savedMeal.foods.first.foodVersionId, 'updated-food-version');
      expect(savedMeal.foods.first.componentFoods!.single.amount, 0.75);
      expect(savedMeal.foods.last.id, 'individual-component-entry');
      expect(savedMeal.foods.last.name, 'Individual apple');
      expect(savedMeal.foods.last.foodVersionId, 'component-version');
    },
  );

  testWidgets('draft-only composite opt-in reports current-day propagation', (
    tester,
  ) async {
    final setup = _historicalEditingSetup();
    final subject = setup.appState.activeSubject!;
    final currentStudyDay = nutritionStudyDayFor(subject, DateTime.now());
    final currentComposite = FoodEntry.fromJson(
      _mealWithCompositeDefinition().foods.first.toJson(),
    )..id = 'current-composite-entry';
    await NutritionRecallAutoSaveManager().saveRecall(
      recall: _recallWithFoods([currentComposite], studyDay: currentStudyDay),
      subjectId: subject.id,
      taskId: 'other-task',
      interventionId: 'other-intervention',
      periodId: 'other-period',
      studyDaySnapshot: currentStudyDay,
    );
    final repository = _TrackingNutritionFoodRepository(todayUpdateCount: 0);

    await openMealEntry(
      tester,
      _mealWithCompositeDefinition(),
      historicalTarget: setup.target,
      foodRepository: repository,
      appState: setup.appState,
    );
    await tester.tap(find.byTooltip('More options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit reusable food'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('Also update matching entries in current study day'),
    );
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(repository.propagatedStudyDays, [currentStudyDay]);
    expect(
      find.text(
        'Reusable item updated. Matching entries in the current study day were also updated.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('historical food retry uses a new mutation id', (tester) async {
    final setup = _historicalEditingSetup();
    final repository = _TrackingNutritionFoodRepository(
      todayUpdateCount: 0,
      failuresBeforeSuccess: 1,
    );
    await openMealEntry(
      tester,
      editableMeal(),
      historicalTarget: setup.target,
      foodRepository: repository,
      appState: setup.appState,
    );

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit reusable food'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repository.mutationCalls, 2);
    expect(repository.mutationIds, hasLength(2));
    expect(repository.mutationIds, everyElement(isNotNull));
    expect(repository.mutationIds.last, isNot(repository.mutationIds.first));
  });

  testWidgets('historical composite retry uses a new mutation id', (
    tester,
  ) async {
    final setup = _historicalEditingSetup();
    final repository = _TrackingNutritionFoodRepository(
      todayUpdateCount: 0,
      failuresBeforeSuccess: 1,
    );
    await openMealEntry(
      tester,
      _mealWithCompositeDefinition(),
      historicalTarget: setup.target,
      foodRepository: repository,
      appState: setup.appState,
    );

    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.tap(find.byTooltip('More options').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit reusable food'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
    }

    expect(repository.mutationCalls, 2);
    expect(repository.mutationIds, hasLength(2));
    expect(repository.mutationIds, everyElement(isNotNull));
    expect(repository.mutationIds.last, isNot(repository.mutationIds.first));
  });

  testWidgets('historical definition save rechecks device-local eligibility', (
    tester,
  ) async {
    final setup = _historicalEditingSetup();
    final repository = _TrackingNutritionFoodRepository(todayUpdateCount: 0);
    await openMealEntry(
      tester,
      editableMeal(),
      historicalTarget: setup.target,
      foodRepository: repository,
      appState: setup.appState,
    );

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit reusable food'));
    await tester.pumpAndSettle();
    final subject = setup.appState.activeSubject!;
    subject.startedAt = subject.startedAt!.subtract(const Duration(days: 1));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repository.mutationCalls, 0);
    expect(find.text('This study day is no longer editable.'), findsOneWidget);
  });

  testWidgets('opted-in reusable edit ignores incomplete server count', (
    tester,
  ) async {
    final setup = _historicalEditingSetup();
    final subject = setup.appState.activeSubject!;
    final currentStudyDay = nutritionStudyDayFor(subject, DateTime.now());
    subject.progress.add(
      _progressWithRecall(
        _recallWithFoods([testFood()], studyDay: currentStudyDay),
        taskId: 'other-task',
        periodId: 'other-period',
        completedAt: DateTime.now().toUtc(),
      ),
    );
    final repository = _TrackingNutritionFoodRepository(todayUpdateCount: 0);
    await openMealEntry(
      tester,
      editableMeal(),
      historicalTarget: setup.target,
      foodRepository: repository,
      appState: setup.appState,
    );

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit reusable food'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('Also update matching entries in current study day'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repository.mutationCalls, 1);
    expect(repository.propagatedStudyDays, [currentStudyDay]);
    expect(
      find.text(
        'Reusable item updated. Matching entries in the current study day were also updated.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('food editor hides search and preserves the meal draft', (
    tester,
  ) async {
    await openMealEntry(tester, editableMeal());

    await selectMealType(
      tester,
      'Custom Meal Label',
      customLabel: 'Edited supper',
    );

    await tester.ensureVisible(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit this entry'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodEntryScreen), findsOneWidget);
    expect(find.byTooltip('Search Food Database'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsOneWidget);
    expect(find.text('Edited supper'), findsWidgets);
  });

  testWidgets('recipe builder return preserves and saves the meal draft', (
    tester,
  ) async {
    final original = editableMeal();
    MealLog? result;
    await openMealEntry(tester, original, onResult: (value) => result = value);

    await selectMealType(
      tester,
      'Custom Meal Label',
      customLabel: 'Edited supper',
    );

    final recipeResult = Navigator.of(
      tester.element(find.byType(MealEntryScreen)),
    ).push<FoodEntry>(MealCreatorScreen.route());
    await tester.pumpAndSettle();

    expect(find.text('Create saved meal'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(await recipeResult, isNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.customMealLabel, 'Edited supper');
    expect(result!.foods, hasLength(1));
    expect(result!.foods.single.id, 'food');
    expect(result!.foods.single.name, 'Apple');
    expect(original.customMealLabel, 'Supper');
    expect(original.foods, hasLength(1));
  });

  testWidgets('template quantity return preserves and saves the meal draft', (
    tester,
  ) async {
    final prototype = FoodEntry.fromJson(testFood().toJson())
      ..id = 'saved-food-prototype'
      ..name = 'Saved Pear'
      ..originalValues = {
        'nested': {'value': 1},
      };
    prototype.nutrition.micros = {'vitaminC': 5};
    final repository = FakeNutritionFoodRepository([
      SavedFoodTemplate(
        id: 'saved-food-template',
        userId: 'anonymous',
        name: 'Saved Pear Template',
        isPublic: false,
        createdAt: DateTime(2026, 7, 15),
        prototype: prototype,
      ),
    ]);
    final original = editableMeal();
    MealLog? result;
    await openMealEntry(
      tester,
      original,
      foodRepository: repository,
      onResult: (value) => result = value,
    );

    await selectMealType(
      tester,
      'Custom Meal Label',
      customLabel: 'Edited supper',
    );
    await openFoodSearchFromMeal(tester);
    await tester.tap(find.text('My library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved Pear Template'));
    await tester.pumpAndSettle();

    expect(repository.loadCalls, 1);
    await tester.enterText(
      find.descendant(
        of: find.byType(FoodQuantitySheet),
        matching: find.byType(TextField),
      ),
      '2',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('selection-tray')),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.customMealLabel, 'Edited supper');
    expect(result!.foods, hasLength(2));
    expect(result!.foods.first.id, 'food');
    expect(result!.foods.first.name, 'Apple');
    expect(result!.foods.last.id, isNot(prototype.id));
    expect(result!.foods.last.name, 'Saved Pear');
    expect(result!.foods.last.amount, 2);
    expect(result!.foods.last.nutrition.energyKcal, 104);
    expect(result!.foods.last.nutrition.micros['vitaminC'], 10);
    expect(result!.foods.last.source, prototype.source);
    expect(result!.foods.last.templateId, 'saved-food-template');
    expect(result!.foods.last.originalValues, prototype.originalValues);
    expect(original.customMealLabel, 'Supper');
    expect(original.foods, hasLength(1));
  });

  testWidgets('saved meal adds cloned foods without replacing meal details', (
    tester,
  ) async {
    final pear = FoodEntry.fromJson(testFood().toJson())
      ..id = 'pear-prototype'
      ..foodId = 'pear-definition'
      ..foodVersionId = 'pear-version'
      ..name = 'Pear';
    final yogurt = FoodEntry.fromJson(testFood().toJson())
      ..id = 'yogurt-prototype'
      ..foodId = 'yogurt-definition'
      ..foodVersionId = 'yogurt-version'
      ..name = 'Yogurt';
    final mealPrototype = FoodEntry.fromJson(testFood().toJson())
      ..id = 'meal-prototype'
      ..foodId = 'meal-definition'
      ..foodVersionId = 'meal-version'
      ..entryType = FoodEntryType.meal
      ..name = 'Afternoon Snack'
      ..componentFoods = [
        FoodComposition.withId(
          parentEntryId: 'meal-prototype',
          foodId: pear.foodId,
          amount: pear.amount,
          unit: pear.unit,
        ),
        FoodComposition.withId(
          parentEntryId: 'meal-prototype',
          foodId: yogurt.foodId,
          amount: yogurt.amount,
          unit: yogurt.unit,
        ),
      ]
      ..componentSnapshots = [pear, yogurt];
    final repository = FakeNutritionFoodRepository([
      SavedFoodTemplate(
        id: 'saved-meal-template',
        userId: 'anonymous',
        name: 'Afternoon Snack',
        isPublic: false,
        createdAt: DateTime(2026, 7, 15),
        prototype: mealPrototype,
      ),
    ]);
    final original = editableMeal();
    MealLog? result;
    await openMealEntry(
      tester,
      original,
      foodRepository: repository,
      onResult: (value) => result = value,
    );
    await selectMealType(
      tester,
      'Custom Meal Label',
      customLabel: 'Edited supper',
    );
    await openFoodSearchFromMeal(tester);
    await tester.tap(find.text('My library'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Afternoon Snack'));
    await tester.pumpAndSettle();

    expect(repository.loadCalls, 1);
    await tester.tap(
      find.descendant(
        of: find.byType(FoodQuantitySheet),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('selection-tray')),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.mealType, MealType.other);
    expect(result!.customMealLabel, 'Edited supper');
    expect(result!.mealContext, original.mealContext);
    expect(result!.timestamp, original.timestamp);
    expect(result!.foods, hasLength(2));
    expect(result!.foods[1].id, isNot(mealPrototype.id));
    expect(result!.foods[1].entryType, FoodEntryType.meal);
    expect(result!.foods[1].templateId, 'saved-meal-template');
    expect(result!.foods[1].componentFoods, hasLength(2));
    expect(
      result!.foods[1].componentFoods!.map((component) => component.foodId),
      [pear.foodId, yogurt.foodId],
    );
    expect(
      result!.foods[1].componentFoods!.map(
        (component) => component.parentEntryId,
      ),
      everyElement(result!.foods[1].id),
    );
    expect(
      result!.foods[1].componentSnapshots!.map((component) => component.foodId),
      [pear.foodId, yogurt.foodId],
    );
    expect(original.foods, hasLength(1));
  });

  testWidgets(
    'food actions show contextual sheet and close before quantity edit',
    (tester) async {
      await openMealEntry(tester, editableMeal());

      expect(find.byType(PopupMenuButton<String>), findsNothing);
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();

      expect(find.text('Details'), findsOneWidget);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      expect(find.byType(FoodQuantitySheet), findsOneWidget);
      expect(find.text('Remove from meal'), findsNothing);
    },
  );

  testWidgets('saved food omits the save action', (tester) async {
    final meal = editableMeal();
    meal.foods.single.templateId = 'saved-food-template';
    await openMealEntry(tester, meal);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();

    expect(find.text('Save to My items'), findsNothing);
    expect(find.text('Remove from meal'), findsOneWidget);
  });

  testWidgets('canceling template or quantity selection adds no food', (
    tester,
  ) async {
    final prototype = FoodEntry.fromJson(testFood().toJson())
      ..id = 'saved-food-prototype'
      ..name = 'Saved Pear';
    final repository = FakeNutritionFoodRepository([
      SavedFoodTemplate(
        id: 'saved-food-template',
        userId: 'anonymous',
        name: 'Saved Pear Template',
        isPublic: false,
        createdAt: DateTime(2026, 7, 15),
        prototype: prototype,
      ),
    ]);
    final original = editableMeal();
    MealLog? result;
    await openMealEntry(
      tester,
      original,
      foodRepository: repository,
      onResult: (value) => result = value,
    );
    await selectMealType(
      tester,
      'Custom Meal Label',
      customLabel: 'Edited supper',
    );
    await openFoodSearchFromMeal(tester);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    await openFoodSearchFromMeal(tester);
    await tester.tap(find.text('My library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved Pear Template'));
    await tester.pumpAndSettle();
    expect(repository.loadCalls, 2);
    await tester.tap(find.byKey(const ValueKey('food-quantity-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.customMealLabel, 'Edited supper');
    expect(result!.foods, hasLength(1));
    expect(result!.foods.single.id, 'food');
    expect(original.customMealLabel, 'Supper');
    expect(original.foods, hasLength(1));
  });

  testWidgets('switching a skipped meal back clears the skip reason', (
    tester,
  ) async {
    MealLog? result;
    await openMealEntry(
      tester,
      skippedMeal(reason: 'Not hungry'),
      onResult: (value) => result = value,
    );

    await tester.tap(find.text('Skipped this meal'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.isSkipped, isFalse);
    expect(result!.skipReason, isNull);
    expect(result!.foods, hasLength(1));
  });

  testWidgets('saving a skipped meal removes contradictory details', (
    tester,
  ) async {
    MealLog? result;
    final original = skippedMeal(reason: 'Not hungry');
    await openMealEntry(tester, original, onResult: (value) => result = value);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.isSkipped, isTrue);
    expect(result!.customMealLabel, 'Early breakfast');
    expect(result!.locationDescription, isNull);
    expect(result!.companyContext, isNull);
    expect(result!.distractionContext, isNull);
    expect(result!.templateId, isNull);
    expect(result!.foods, isEmpty);
    expect(original.foods, hasLength(1));
    expect(original.locationDescription, 'Kitchen');
  });
}
