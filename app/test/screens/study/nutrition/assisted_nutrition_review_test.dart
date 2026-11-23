import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/assisted/assisted_nutrition_review.dart';
import 'package:studyu_core/core.dart';

final _l10n = lookupAppLocalizations(const Locale('en'));

void main() {
  testWidgets('moves foods with the menu and keeps their order on retry', (
    tester,
  ) async {
    final meals = [
      _meal(MealType.breakfast, ['Oats', 'Banana'])
        ..mealContext = MealContext.other
        ..locationDescription = 'Garden'
        ..companyContext = CompanyContext.friends
        ..distractionContext = DistractionContext.phone,
      _meal(MealType.lunch, ['Potato']),
    ];
    final attempts = <List<MealLog>>[];
    await _openReview(tester, meals, (entries) async {
      attempts.add(entries);
      return attempts.length == 2;
    });

    final mealDetails = find.text(
      'Garden • ${_l10n.company_friends} • ${_l10n.distraction_phone}',
    );
    expect(mealDetails, findsOneWidget);
    await _moveFromMenu(tester, 'Oats', _l10n.assisted_move_food_down);
    await _moveFromMenu(
      tester,
      'Potato',
      _l10n.assisted_move_food_to_meal(_l10n.meal_type_breakfast),
    );

    expect(find.text(_l10n.meal_type_lunch), findsOneWidget);
    expect(find.text(_l10n.assisted_empty_meal), findsOneWidget);
    final saveTwo = find.widgetWithText(
      FilledButton,
      _l10n.assisted_save_diary_entries(2),
    );
    expect(tester.widget<FilledButton>(saveTwo).onPressed, isNull);
    expect(attempts, isEmpty);

    await tester.tap(find.text(_l10n.assisted_remove_empty_meal));
    await tester.pumpAndSettle();
    final saveOne = find.text(_l10n.assisted_save_diary_entries(1));
    await tester.tap(saveOne);
    await tester.pumpAndSettle();

    expect(find.text(_l10n.assisted_save_failed), findsOneWidget);
    expect(find.byType(AssistedNutritionReview), findsOneWidget);
    await tester.tap(saveOne);
    await tester.pumpAndSettle();

    expect(attempts, hasLength(2));
    for (final entries in attempts) {
      expect(entries.single.id, meals.first.id);
      expect(entries.single.foods.map((food) => food.name), [
        'Banana',
        'Oats',
        'Potato',
      ]);
    }
    expect(find.text('Saved'), findsOneWidget);
    expect(meals.first.foods.map((food) => food.name), ['Oats', 'Banana']);
    expect(meals.last.foods.single.name, 'Potato');
  });

  testWidgets('dropping into gaps sets the exact order across meals', (
    tester,
  ) async {
    final meals = [
      _meal(MealType.breakfast, ['Oats', 'Banana']),
      _meal(MealType.lunch, ['Potato']),
    ];
    List<MealLog>? saved;
    await _openReview(tester, meals, (entries) async {
      saved = entries;
      return true;
    });

    final banana = find.text('Banana');
    await _dragToGap(tester, 'Oats', meals.first, 2);
    expect(
      tester.getCenter(find.text('Oats')).dy,
      greaterThan(tester.getCenter(banana).dy),
    );

    await _dragToGap(tester, 'Oats', meals.last, 0);
    expect(
      tester.getCenter(find.text('Oats')).dy,
      lessThan(tester.getCenter(find.text('Potato')).dy),
    );
    await _dragToGap(tester, 'Banana', meals.last, 2);
    expect(find.text(_l10n.assisted_empty_meal), findsOneWidget);
    await _dragToGap(tester, 'Potato', meals.first, 0);
    await tester.tap(find.text(_l10n.assisted_save_diary_entries(2)));
    await tester.pumpAndSettle();

    expect(saved?.first.foods.single.name, 'Potato');
    expect(saved?.last.foods.map((food) => food.name), ['Oats', 'Banana']);
  });
}

Future<void> _openReview(
  WidgetTester tester,
  List<MealLog> meals,
  Future<bool> Function(List<MealLog>) save,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () async {
              final saved = await Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (_) => AssistedNutritionReview(
                    meals: meals,
                    diaryDay: DateTime.utc(2026, 11, 21),
                    task: null,
                    onSave: save,
                  ),
                ),
              );
              if (saved == true && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Saved')));
              }
            },
            child: const Text('Review'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Review'));
  await tester.pumpAndSettle();
}

Future<void> _moveFromMenu(
  WidgetTester tester,
  String food,
  String action,
) async {
  await tester.tap(find.byTooltip(_l10n.assisted_food_order_actions(food)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(action));
  await tester.pumpAndSettle();
}

Future<void> _dragToGap(
  WidgetTester tester,
  String food,
  MealLog meal,
  int index,
) async {
  final source = find.byTooltip(_l10n.assisted_food_order_actions(food));
  final drag = await tester.startGesture(tester.getCenter(source));
  await drag.moveBy(const Offset(-32, 0));
  await tester.pump();

  final gaps = find.descendant(
    of: find.byKey(ValueKey(meal.id)),
    matching: find.byType(DragTarget<FoodEntry>),
  );
  await drag.moveTo(tester.getCenter(gaps.at(index)));
  await tester.pump();
  await drag.up();
  await tester.pumpAndSettle();
}

MealLog _meal(MealType type, List<String> foods) => MealLog.withId(
  mealType: type,
  timePrecision: MealOccurrenceTimePrecision.unknown,
  timezone: 'UTC',
  isSkipped: false,
  foods: foods.map(_food).toList(),
);

FoodEntry _food(String name) => FoodEntry.withId(
  entryType: FoodEntryType.singleIngredient,
  name: name,
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.householdMeasure,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 100,
    protein: 3,
    carbs: 20,
    fat: 1,
    sugars: 4,
    fiber: 1,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: {},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  originalValues: {},
);
