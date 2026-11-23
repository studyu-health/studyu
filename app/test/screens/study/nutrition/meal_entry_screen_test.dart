import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

import '../../../util/mock_nutrition_draft_storage.dart';
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
  timePrecision: MealOccurrenceTimePrecision.exact,
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
  timePrecision: MealOccurrenceTimePrecision.exact,
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
  timePrecision: MealOccurrenceTimePrecision.exact,
  timezone: 'UTC',
  isSkipped: false,
  foods: [testFood()],
);

Future<void> openMealEntry(
  WidgetTester tester,
  MealLog? meal, {
  NutritionTask? task,
  MealType? initialMealType,
  List<FoodEntry> initialFoods = const [],
  DateTime? occurrenceDate,
  NutritionRecallPersistenceTarget? historicalTarget,
  NutritionFoodRepository? foodRepository,
  AppState? appState,
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
                            initialFoods: initialFoods,
                            occurrenceDate: occurrenceDate,
                            historicalTarget: historicalTarget,
                            foodRepository:
                                foodRepository ?? FakeNutritionFoodRepository(),
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
  FoodEntry? currentDefinition;
  final expectedVersions = <String>[];
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
  Future<FoodEntry?> loadCurrentFoodDefinition({
    required String subjectId,
    required String foodId,
  }) async => currentDefinition;

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
    expectedVersions.add(expectedVersionId);
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
    onResult: onResult,
  );

  await openFoodSearchFromMeal(tester);
  await tester.tap(find.text('Create food'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).first, 'Historical toast');
  await tester.tap(
    find.widgetWithText(FilledButton, 'Save and add to Breakfast'),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add 1 item to Breakfast'));
  await tester.pumpAndSettle();
  expect(
    tester
        .widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Save diary entry'),
        )
        .onPressed,
    isNull,
  );
  await tester.tap(find.text('Select a time'));
  await tester.pumpAndSettle();
  await tester.tap(find.text("I don't remember"));
  await tester.pumpAndSettle();
  await tester.ensureVisible(
    find.widgetWithText(CheckboxListTile, 'Save to My items for future use'),
  );
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
          timePrecision: MealOccurrenceTimePrecision.unknown,
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

Future<void> selectMealType(WidgetTester tester, String label) async {
  final mealDetails = find.text('Meal details');
  await tester.ensureVisible(mealDetails);
  await tester.tap(mealDetails);
  await tester.pumpAndSettle();
  await tester.tap(findMealDetailsText(label));
  await tester.pumpAndSettle();
  await tester.tap(findMealDetailsText('Apply'));
  await tester.pumpAndSettle();
}

Future<void> openFoodSearchFromMeal(WidgetTester tester) async {
  final addFood = find.ancestor(
    of: find.textContaining(RegExp(r'^Add item$')),
    matching: find.byType(TextButton),
  );
  await tester.ensureVisible(addFood);
  await tester.tap(addFood);
  await tester.pumpAndSettle();
}

Future<void> chooseMealTime(
  WidgetTester tester,
  String precision, {
  required String hour,
  required String minute,
  DayPeriod? period,
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
  if (period != null) {
    final label = period == DayPeriod.am ? 'AM' : 'PM';
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Finder findMealDetailsText(String label) =>
    find.descendant(of: find.byType(BottomSheet), matching: find.text(label));

void main() {
  setUp(() => mockNutritionDraftStorage());
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

  test('meal clone preserves absent context and independent children', () {
    final original = editableMeal()..mealContext = null;
    final clone = cloneMealLog(original);
    expect(clone.mealContext, isNull);
    expect(clone.toJson().containsKey('mealContext'), isFalse);
    expect(clone.foods.single.id, original.foods.single.id);
    expect(identical(clone.foods.single, original.foods.single), isFalse);
  });

  testWidgets('Now sets the exact time without opening the selector', (
    tester,
  ) async {
    MealLog? result;
    final today = DateTime.now().toUtc();
    await openMealEntry(
      tester,
      null,
      initialFoods: [testFood()],
      occurrenceDate: DateTime.utc(today.year, today.month, today.day),
      onResult: (value) => result = value,
    );
    expect(find.text('Select a time'), findsOneWidget);
    expect(find.text('Select a time to save'), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);

    final beforeTap = DateTime.now();
    await tester.tap(find.text('Now'));
    final afterTap = DateTime.now();
    await tester.pumpAndSettle();
    expect(find.text('Select a time'), findsNothing);
    expect(find.text('Select a time to save'), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(TimePickerDialog), findsNothing);

    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result!.timePrecision, MealOccurrenceTimePrecision.exact);
    expect(result!.timezone, beforeTap.timeZoneName);
    final timestamp = result!.timestamp!;
    expect(timestamp.isUtc, isTrue);
    expect(timestamp.isBefore(beforeTap), isFalse);
    expect(timestamp.isAfter(afterTap), isFalse);
  });

  testWidgets('canceling the time picker leaves a new answer unanswered', (
    tester,
  ) async {
    await openMealEntry(tester, null);
    await tester.tap(find.text('Select a time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exact time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Save diary entry'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Select a time'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<RadioGroup<MealOccurrenceTimePrecision>>(
            find.byType(RadioGroup<MealOccurrenceTimePrecision>),
          )
          .groupValue,
      isNull,
    );
  });

  testWidgets('new occasion saves untouched context as absent', (tester) async {
    MealLog? result;
    await _openValidNewHistoricalMeal(
      tester,
      onResult: (value) => result = value,
    );
    await tester.ensureVisible(find.text('Meal details'));
    expect(find.text('Breakfast'), findsOneWidget);
    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result!.mealContext, isNull);
    expect(result!.toJson().containsKey('mealContext'), isFalse);
    expect(result!.foods, isNotEmpty);
    expect(MealLog.fromJson(result!.toJson()).mealContext, isNull);
  });

  testWidgets(
    'clearing context removes the old location without changing the source',
    (tester) async {
      final original = editableMeal()
        ..mealContext = MealContext.other
        ..locationDescription = 'Park';
      MealLog? result;
      await openMealEntry(
        tester,
        original,
        onResult: (value) => result = value,
      );
      await tester.ensureVisible(find.text('Meal details'));
      await tester.tap(find.text('Meal details'));
      await tester.pumpAndSettle();
      await tester.tap(findMealDetailsText('Not added'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Supper'), findsOneWidget);
      await tester.tap(find.text('Save diary entry'));
      await tester.pumpAndSettle();
      expect(result!.mealContext, isNull);
      expect(result!.locationDescription, isNull);
      expect(result!.customMealLabel, 'Supper');
      expect(original.mealContext, MealContext.other);
      expect(original.locationDescription, 'Park');
    },
  );

  for (final precision in [
    MealOccurrenceTimePrecision.exact,
    MealOccurrenceTimePrecision.approximate,
  ]) {
    testWidgets('$precision without a timestamp disables Save until answered', (
      tester,
    ) async {
      final original = editableMeal()
        ..timestamp = null
        ..timePrecision = precision;
      MealLog? result;
      await openMealEntry(
        tester,
        original,
        onResult: (value) => result = value,
      );
      final save = find.widgetWithText(FilledButton, 'Save diary entry');
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.tap(find.text('Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("I don't remember"));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(result!.timestamp, isNull);
      expect(result!.timePrecision, MealOccurrenceTimePrecision.unknown);
      expect(original.timePrecision, precision);
    });
  }

  testWidgets(
    'unknown answer clears a selected timestamp and labels remain optional',
    (tester) async {
      MealLog? result;
      final original = editableMeal(customMealLabel: null)..mealContext = null;
      await openMealEntry(
        tester,
        original,
        onResult: (value) => result = value,
      );
      await tester.tap(find.text('Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("I don't remember"));
      await tester.pumpAndSettle();
      final save = find.widgetWithText(FilledButton, 'Save diary entry');
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(result!.timestamp, isNull);
      expect(result!.timePrecision, MealOccurrenceTimePrecision.unknown);
      expect(result!.customMealLabel, isNull);
      expect(result!.mealContext, isNull);
      expect(original.timestamp, isNotNull);
    },
  );

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

    expect(find.text('Meal details'), findsOneWidget);
    expect(find.text('Dinner'), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Add entry'),
      ),
      findsOneWidget,
    );
    expect(find.text('Save diary entry'), findsOneWidget);
    expect(find.text('Delete entry'), findsNothing);
    expect(find.text('Select a time'), findsOneWidget);

    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Save diary entry'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Select a time'));
    await tester.pumpAndSettle();
    final timeGroup = tester.widget<RadioGroup<MealOccurrenceTimePrecision>>(
      find.byType(RadioGroup<MealOccurrenceTimePrecision>),
    );
    expect(timeGroup.groupValue, isNull);
    await tester.tap(find.text("I don't remember"));
    await tester.pumpAndSettle();

    expect(find.text('Time not remembered'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Save diary entry'),
          )
          .onPressed,
      isNull,
    );
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

    await tester.tap(find.text('Save diary entry'));
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

      await tester.tap(find.text('Save diary entry'));
      await tester.pumpAndSettle();

      expect(repository.savedTemplateTypes, [FoodEntryType.meal]);
      expect(result, isNull);
      expect(find.byType(MealEntryScreen), findsOneWidget);
      expect(find.text('Could not save results'), findsOneWidget);

      await tester.tap(find.text('Save to My items for future use'));
      await tester.tap(find.text('Save diary entry'));
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
    await tester.tap(find.text('Save diary entry'));
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

    expect(find.text('Now'), findsNothing);
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
    await tester.tap(find.text('Save diary entry'));
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

    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.timestamp, isNotNull);
    expect(result!.timestamp!.minute, 30);
    expect(result!.timestamp, isNot(DateTime(2026, 7, 15, 20)));
    expect(result!.timePrecision, MealOccurrenceTimePrecision.exact);
  });

  testWidgets('meal time uses the selected UTC day at its local boundary', (
    tester,
  ) async {
    final utcDay = DateTime.utc(2024, 2, 3);
    final latestMinute = DateTime.utc(2024, 2, 3, 23, 59);
    final local = latestMinute.toLocal();
    final meal = editableMeal()
      ..timestamp = null
      ..timePrecision = MealOccurrenceTimePrecision.unknown;
    MealLog? result;
    await openMealEntry(
      tester,
      meal,
      occurrenceDate: utcDay,
      onResult: (value) => result = value,
    );
    await chooseMealTime(
      tester,
      'Exact time',
      hour: (local.hour % 12 == 0 ? 12 : local.hour % 12).toString(),
      minute: local.minute.toString(),
      period: local.hour < 12 ? DayPeriod.am : DayPeriod.pm,
    );
    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();
    expect(result!.timestamp, latestMinute);
    expect(result!.timestamp!.isUtc, isTrue);
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

    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.timestamp, isNotNull);
    expect(result!.timestamp!.minute, 30);
    expect(result!.timestamp, isNot(DateTime(2026, 7, 15, 20)));
    expect(result!.timePrecision, MealOccurrenceTimePrecision.approximate);
  });

  testWidgets('meal type picker offers no free-text label editor', (
    tester,
  ) async {
    await openMealEntry(tester, null);

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();

    final sheet = find.byType(BottomSheet);
    expect(
      find.descendant(of: sheet, matching: find.text('Breakfast')),
      findsOneWidget,
    );
    expect(find.text('Custom Meal Label'), findsNothing);
    expect(
      find.descendant(of: sheet, matching: find.byType(EditableText)),
      findsNothing,
    );
  });

  testWidgets('standalone label picker works with context disabled', (
    tester,
  ) async {
    final task = NutritionTask.withId()..collectMealContext = false;
    await openMealEntry(tester, editableMeal(), task: task);
    expect(find.text('Meal details'), findsNothing);
    await tester.tap(find.text('Meal label'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
    expect(
      tester.getTopLeft(findMealDetailsText('No label')).dy,
      lessThan(tester.getTopLeft(findMealDetailsText('Breakfast')).dy),
    );

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Supper'), findsOneWidget);

    await tester.tap(find.text('Meal label'));
    await tester.pumpAndSettle();
    await tester.tap(findMealDetailsText('Dinner'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Dinner'), findsOneWidget);
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
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Meal details'), findsOneWidget);
    expect(find.text('Supper • Home'), findsOneWidget);
    expect(find.text('Dinner'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Edit diary entry'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('built-in meal type clears an existing custom label', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 540));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    MealEntryResult? result;
    await openMealEntry(
      tester,
      editableMeal(),
      onEntryResult: (value) => result = value,
    );

    await selectMealType(tester, 'Dinner');

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Edit diary entry'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Supper meal'),
      ),
      findsNothing,
    );

    await tester.tap(find.text('Save diary entry'));
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

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();

    expect(find.text('Morning meal'), findsOneWidget);
    expect(find.text('Evening snack'), findsOneWidget);
    expect(find.text('No label'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);

    await tester.tap(findMealDetailsText('Evening snack'));
    await tester.pumpAndSettle();
    await tester.tap(findMealDetailsText('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Evening snack • Home'), findsOneWidget);

    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();

    final meal = (result! as SavedMealEntryResult).meal;
    expect(meal.mealType, MealType.other);
    expect(meal.customMealLabel, 'Evening snack');
  });

  testWidgets('picker marks an existing generic meal as No label', (
    tester,
  ) async {
    final task = NutritionTask.withId()
      ..customMealTypes = ['Morning meal', 'Evening snack'];
    await openMealEntry(
      tester,
      editableMeal(customMealLabel: null),
      task: task,
    );

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();

    final semantics = tester
        .getSemantics(findMealDetailsText('No label'))
        .getSemanticsData();
    expect(semantics.label, 'No label');
    expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
    expect(semantics.hasAction(SemanticsAction.tap), isTrue);
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

    await selectMealType(tester, 'No label');
    expect(find.text('Edit diary entry'), findsOneWidget);

    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();

    final meal = (result! as SavedMealEntryResult).meal;
    expect(meal.mealType, MealType.other);
    expect(meal.customMealLabel, isNull);
  });

  testWidgets('meal detail choices apply together from one sheet', (
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

    final mealLabels = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.textContaining(RegExp(r'^(No label|Supper|Breakfast)$')),
    );
    expect(findMealDetailsText('Supper'), findsOneWidget);
    expect(tester.widget<Text>(mealLabels.first).data, 'No label');

    await tester.tap(findMealDetailsText('Lunch'));
    await tester.pumpAndSettle();
    await tester.tap(findMealDetailsText('Family'));
    await tester.pumpAndSettle();
    final dismissHandle = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.bySemanticsLabel('Dismiss'),
    );
    await tester.drag(dismissHandle, const Offset(0, 600));
    await tester.pumpAndSettle();

    expect(find.text('Family'), findsNothing);
    expect(find.text('Supper • Home'), findsOneWidget);

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(findMealDetailsText('Lunch'));
    await tester.pumpAndSettle();
    await tester.tap(findMealDetailsText('Family'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Family'), findsNothing);
    expect(find.text('Supper • Home'), findsOneWidget);

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(findMealDetailsText('Dinner'));
    await tester.pumpAndSettle();
    await tester.tap(findMealDetailsText('Restaurant'));
    await tester.pumpAndSettle();
    await tester.tap(findMealDetailsText('Family'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(findMealDetailsText('None'));
    await tester.tap(findMealDetailsText('None'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Dinner • Restaurant • Family • None'), findsOneWidget);
    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();
    final meal = (result! as SavedMealEntryResult).meal;
    expect(meal.mealType, MealType.dinner);
    expect(meal.customMealLabel, isNull);
    expect(meal.mealContext, MealContext.restaurant);
    expect(meal.companyContext, CompanyContext.family);
    expect(meal.distractionContext, DistractionContext.none);
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
        timePrecision: MealOccurrenceTimePrecision.exact,
        timezone: 'UTC',
        isSkipped: false,
        foods: [testFood()],
      ),
      onEntryResult: (value) => result = value,
    );

    await tester.ensureVisible(find.text('Meal details'));
    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(findMealDetailsText('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();
    await tester.tap(findMealDetailsText('Other').first);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save diary entry'));
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
      find.widgetWithText(FilledButton, 'Save diary entry'),
    );
    expect(saveButton.onPressed, isNotNull);

    await tester.tap(find.text('Save diary entry'));
    await tester.pump();

    reasonField = tester.widget<TextField>(find.byType(TextField));
    expect(reasonField.decoration?.errorText, 'Enter a reason before saving.');

    await tester.enterText(find.byType(TextField), 'Not hungry');
    await tester.pump();

    reasonField = tester.widget<TextField>(find.byType(TextField));
    expect(reasonField.decoration?.errorText, isNull);
  });

  testWidgets(
    'empty meal disables Save until food is added and does not auto-save',
    (tester) async {
      MealLog? result;
      await openMealEntry(
        tester,
        emptyMeal(),
        onResult: (value) => result = value,
      );

      expect(find.text('No foods added'), findsOneWidget);
      expect(find.text('Add item').hitTestable(), findsOneWidget);
      expect(find.text('Items'), findsOneWidget);
      expect(find.text('Meal Nutrition'), findsNothing);
      expect(
        find.text('Add at least one food item before saving.'),
        findsOneWidget,
      );
      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save diary entry'),
      );
      expect(saveButton.onPressed, isNull);

      await tester.tap(find.text('Save diary entry'));
      await tester.pump();

      expect(result, isNull);
      expect(find.byType(MealEntryScreen), findsOneWidget);
      expect(
        find.text('Add at least one food item before saving.'),
        findsOneWidget,
      );

      expect(find.text('Skipped this meal'), findsNothing);
      expect(result, isNull);
      expect(find.byType(MealEntryScreen), findsOneWidget);
    },
  );

  testWidgets(
    'logged meal shows food and details without a nutrition summary',
    (tester) async {
      await openMealEntry(tester, editableMeal());

      expect(
        tester.getTopLeft(find.text('Items')).dy,
        lessThan(tester.getTopLeft(find.text('Meal details')).dy),
      );
      expect(find.text('Meal label'), findsNothing);
      expect(find.text('Meal Nutrition'), findsNothing);
    },
  );

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

    for (final label in ['Meal details', 'Time', 'Apple']) {
      final card = tester.widget<Card>(
        find.ancestor(of: find.text(label), matching: find.byType(Card)).first,
      );
      expect(card.color, isNull);
    }
  });

  testWidgets('Adding food opens search with the foods already logged', (
    tester,
  ) async {
    await openMealEntry(tester, editableMeal());

    await openFoodSearchFromMeal(tester);

    final search = tester.widget<FoodSearchScreen>(
      find.byType(FoodSearchScreen),
    );
    expect(search.initialFoods.map((food) => food.name), ['Apple']);
    expect(search.allowMeals, isTrue);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);
  });

  testWidgets('Save to My items opens the meal builder directly', (
    tester,
  ) async {
    await openMealEntry(tester, _mealWithCompositeDefinition());

    final saveToMyItems = find.text('Save to My items');
    await tester.ensureVisible(saveToMyItems);
    await tester.tap(saveToMyItems);
    await tester.pumpAndSettle();

    final builder = tester.widget<MealCreatorScreen>(
      find.byType(MealCreatorScreen),
    );
    expect(builder.initialFoods.map((food) => food.name), [
      'Apple',
      'Individual apple',
    ]);
    expect(builder.initialName, 'Supper');
  });

  testWidgets('back offers discard and continue actions', (tester) async {
    await openMealEntry(tester, skippedMeal());
    await tester.enterText(find.byType(TextField), 'Not hungry');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Leave this entry?'), findsOneWidget);
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

    await tester.ensureVisible(find.text('Delete entry'));
    await tester.tap(find.text('Delete entry'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this entry?'), findsOneWidget);
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
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.mutationCalls, 0);
    expect(find.text('Local apple'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.text('Save diary entry'));
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
      await tester.tap(find.text('Save'));
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
      await tester.tap(find.text('Save'));
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
      await tester.tap(find.text('Save'));
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

  for (final version in ['food-version', 'newer-version']) {
    testWidgets(
      'historical reusable edit loads canonical values for $version',
      (tester) async {
        final setup = _historicalEditingSetup();
        final repository = _TrackingNutritionFoodRepository(todayUpdateCount: 0)
          ..currentDefinition = (testFood()
            ..name = 'Current apple'
            ..foodVersionId = version
            ..nutrition.energyKcal = 73
            ..amount = 1);
        MealLog? result;
        await openMealEntry(
          tester,
          _mealWithMatchingDefinitions(),
          historicalTarget: setup.target,
          foodRepository: repository,
          appState: setup.appState,
          onResult: (meal) => result = meal,
        );

        await tester.tap(find.byTooltip('More options').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit reusable food'));
        await tester.pumpAndSettle();

        expect(find.text('Current apple'), findsOneWidget);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(repository.expectedVersions, [version]);
        expect(repository.submittedSnapshot!.id, 'food');
        expect(repository.submittedSnapshot!.nutrition.energyKcal, 73);

        await tester.tap(find.text('Save diary entry'));
        await tester.pumpAndSettle();
        expect(result!.foods.first.amount, 2);
        expect(result!.foods.first.nutrition.energyKcal, 146);
        expect(result!.foods.first.foodVersionId, 'updated-food-version');
      },
    );
  }

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
      final l10n = AppLocalizations.of(
        tester.element(find.byType(FoodEntryScreen)),
      )!;
      final energyField = foodEditorInput(l10n.energy_kcal);
      expect(tester.widget<TextField>(energyField).controller!.text, '52.0');
      await tester.enterText(energyField, '120');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repository.mutationCalls, 1);
      expect(repository.propagatedStudyDays, [null]);
      expect(repository.submittedSnapshot!.id, 'food');
      expect(repository.submittedSnapshot!.foodId, 'food-definition');
      expect(repository.submittedSnapshot!.amount, 1);
      expect(repository.submittedSnapshot!.nutrition.energyKcal, 120);
      expect(repository.submittedSnapshot!.servingSizeGrams, 80);
      expect(
        find.text(
          'Reusable item updated. Matching entries in the current study day were not updated.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Save diary entry'));
      await tester.pumpAndSettle();

      expect(result, isA<SavedMealEntryResult>());
      final meal = (result! as SavedMealEntryResult).meal;
      expect(meal.foods[0].id, 'food');
      expect(meal.foods[0].foodId, 'food-definition');
      expect(meal.foods[0].foodVersionId, 'updated-food-version');
      expect(meal.foods[0].name, 'Reusable apple');
      expect(meal.foods[0].amount, 2);
      expect(meal.foods[0].nutrition.energyKcal, 240);
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
      final editAmount = find.byTooltip('Edit amount');
      await Scrollable.ensureVisible(
        tester.element(editAmount),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(editAmount);
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

      await tester.tap(find.text('Save diary entry'));
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
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
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
    await tester.tap(find.text('Save'));
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
    await tester.tap(find.text('Save'));
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

    await selectMealType(tester, 'Dinner');

    await tester.ensureVisible(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit food'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodEntryScreen), findsOneWidget);
    expect(find.byTooltip('Search Food Database'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsOneWidget);
    expect(find.text('Dinner • Home'), findsOneWidget);
  });

  testWidgets('recipe builder return preserves and saves the meal draft', (
    tester,
  ) async {
    final original = editableMeal();
    MealLog? result;
    await openMealEntry(tester, original, onResult: (value) => result = value);

    await selectMealType(tester, 'Dinner');

    final recipeResult = Navigator.of(
      tester.element(find.byType(MealEntryScreen)),
    ).push<FoodEntry>(MealCreatorScreen.route());
    await tester.pumpAndSettle();

    expect(find.text('Create meal'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(await recipeResult, isNull);

    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.mealType, MealType.dinner);
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

    await selectMealType(tester, 'Dinner');
    await openFoodSearchFromMeal(tester);
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved Pear Template'));
    await tester.pumpAndSettle();

    expect(repository.loadCalls, 1);
    await tester.tap(find.byTooltip('Edit food').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Only this selection'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Servings *'),
      '2',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('selection-tray')),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.mealType, MealType.dinner);
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
    await selectMealType(tester, 'Dinner');
    await openFoodSearchFromMeal(tester);
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Afternoon Snack'));
    await tester.pumpAndSettle();

    expect(repository.loadCalls, 1);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('selection-tray')),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.mealType, MealType.dinner);
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

  testWidgets('food menu and row open the editor with logged servings', (
    tester,
  ) async {
    final original = editableMeal();
    MealLog? result;
    await openMealEntry(tester, original, onResult: (value) => result = value);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    expect(find.text('Edit amount'), findsNothing);
    await tester.tap(find.text('Edit food'));
    await tester.pumpAndSettle();

    final servings = find.widgetWithText(TextFormField, 'Servings *');
    expect(servings, findsOneWidget);
    await tester.enterText(servings, '3');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextFormField>(servings).controller!.text, '1.0');
    await tester.enterText(servings, '2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(original.foods.single.amount, 1);
    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();
    expect(result!.foods.single.amount, 2);
    expect(result!.foods.single.nutrition.energyKcal, 104);
  });

  testWidgets('food menu removes food from the meal draft immediately', (
    tester,
  ) async {
    await openMealEntry(tester, editableMeal());
    expect(find.text('Apple'), findsOneWidget);

    final options = find.byTooltip('More options');
    final remove = find.text('Remove from entry');
    await tester.tap(options);
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Edit food')).dy,
      closeTo(tester.getBottomLeft(options).dy, kMinInteractiveDimension),
    );
    await tester.tapAt(tester.getCenter(find.byType(AppBar)));
    await tester.pumpAndSettle();
    expect(remove, findsNothing);
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(options);
    await tester.pumpAndSettle();
    await tester.tap(remove);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Save to My items'), findsNothing);
  });

  testWidgets('reopened basket updates the same meal item', (tester) async {
    final prototype = testFood()..name = 'Pear';
    final repository = FakeNutritionFoodRepository([
      SavedFoodTemplate(
        id: 'saved-pear',
        userId: 'anonymous',
        name: 'Pick a pear',
        isPublic: false,
        createdAt: DateTime(2026, 7, 15),
        prototype: prototype,
      ),
    ]);
    MealLog? result;
    await openMealEntry(
      tester,
      editableMeal()..foods.clear(),
      foodRepository: repository,
      onResult: (value) => result = value,
    );
    final basket = find.byKey(const ValueKey('selection-tray'));
    final update = find.widgetWithText(FilledButton, 'Update selection');

    for (final existing in [false, true]) {
      await openFoodSearchFromMeal(tester);
      if (existing) {
        expect(
          find.descendant(of: basket, matching: find.text('Pear')),
          findsOneWidget,
        );
        expect(update, findsOneWidget);
      }
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pick a pear'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: basket, matching: find.byType(FilledButton)),
      );
      await tester.pumpAndSettle();
    }

    expect(find.text('Pear'), findsOneWidget);
    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();
    expect(result!.foods.single.amount, 2);
    expect(result!.foods.single.nutrition.energyKcal, 104);
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
    await selectMealType(tester, 'Dinner');
    await openFoodSearchFromMeal(tester);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    await openFoodSearchFromMeal(tester);
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved Pear Template'));
    await tester.pumpAndSettle();
    expect(repository.loadCalls, 2);
    await tester.tap(find.byTooltip('Edit food').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Only this selection'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.mealType, MealType.dinner);
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
    await tester.tap(find.text('Save diary entry'));
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

    await tester.tap(find.text('Save diary entry'));
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
