import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_core/core.dart';

FoodEntry apple() => FoodEntry(
  id: 'apple-id',
  foodId: 'apple-definition',
  foodVersionId: 'apple-version',
  entryType: FoodEntryType.singleIngredient,
  name: 'Apple',
  amount: 1,
  unit: 'medium',
  servingSizeGrams: 182,
  portionReference: 'Medium apple, 182 g',
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 95,
    protein: 0.5,
    carbs: 25,
    fat: 0.3,
    sugars: 19,
    fiber: 4.4,
    saturatedFat: 0.1,
    transFat: 0,
    cholesterol: 0,
    sodium: 2,
    waterContent: 156,
    micros: {'vitaminC': 8.4},
  ),
  source: FoodSource.usda,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15),
  originalValues: const {'source': 'fixture'},
);

Future<void> pumpSheet(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  FoodEntry? food,
  FoodEntry? baselineFood,
  FoodQuantityAction action = FoodQuantityAction.addToMeal,
  double? initialAmount,
  bool gramsKnown = true,
  bool? baselineGramsKnown,
  ValueChanged<FoodEntry?>? onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: locale,
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () async {
              final result = await FoodQuantitySheet.show(
                context,
                food: food ?? apple(),
                baselineFood: baselineFood,
                mealLabel: 'Snack',
                action: action,
                initialAmount: initialAmount,
                gramsKnown: gramsKnown,
                baselineGramsKnown: baselineGramsKnown,
              );
              onResult?.call(result);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('scales nutrition and returns an independent food', (
    tester,
  ) async {
    FoodEntry? result;
    await pumpSheet(tester, onResult: (value) => result = value);

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('95 kcal'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('190 kcal'), findsOneWidget);
    await tester.tap(find.text('Add to Snack'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.amount, 2);
    expect(result!.servingSizeGrams, 182);
    expect(result!.nutrition.energyKcal, 190);
    expect(result!.nutrition.protein, 1);
    expect(result!.nutrition.micros['vitaminC'], 16.8);
  });

  testWidgets('shows nutrition for the current item amount', (tester) async {
    await pumpSheet(
      tester,
      action: FoodQuantityAction.updateSelection,
      initialAmount: 2,
    );

    expect(find.text('Nutrition for 364 g'), findsOneWidget);
    expect(find.text('190 kcal'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase Apple'));
    await tester.pump();

    expect(find.text('Nutrition for 546 g'), findsOneWidget);
    expect(find.text('285 kcal'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
  });

  testWidgets(
    'updates selected serving weight without changing baseline food',
    (tester) async {
      final baseline = apple()..templateId = 'library-apple';
      FoodEntry? result;
      await pumpSheet(
        tester,
        food: baseline,
        baselineFood: baseline,
        action: FoodQuantityAction.updateSelection,
        initialAmount: 2,
        onResult: (value) => result = value,
      );

      expect(find.text('Library serving: 182 g'), findsNothing);
      expect(find.text('Weight per serving'), findsOneWidget);
      expect(find.textContaining('182 g per serving'), findsNothing);
      expect(find.text('Total weight: 364 g'), findsOneWidget);

      await tester.tap(find.byTooltip('Decrease weight per serving'));
      await tester.pump();
      expect(find.text('Total weight: 362 g'), findsOneWidget);
      await tester.tap(find.byTooltip('Increase weight per serving'));
      await tester.pump();
      expect(find.text('Total weight: 364 g'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, '1');
      await tester.pump();
      expect(
        tester
            .widget<IconButton>(
              find.ancestor(
                of: find.byTooltip('Decrease weight per serving'),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNull,
      );

      await tester.enterText(find.byType(TextField).last, '100');
      await tester.pump();

      expect(find.text('Total weight: 200 g'), findsOneWidget);
      expect(find.text('Use library weight (182 g)'), findsOneWidget);
      expect(find.text('Nutrition for 200 g'), findsOneWidget);
      expect(find.text('104 kcal'), findsOneWidget);
      expect(find.text('52 kcal per serving'), findsNothing);
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(baseline.servingSizeGrams, 182);
      expect(baseline.nutrition.energyKcal, 95);
      expect(result!.amount, 2);
      expect(result!.servingSizeGrams, 100);
      expect(result!.nutrition.energyKcal, closeTo(104.4, 0.1));
    },
  );

  testWidgets('guards invalid weights and accepts decimal grams', (
    tester,
  ) async {
    FoodEntry? result;
    await pumpSheet(
      tester,
      action: FoodQuantityAction.updateSelection,
      initialAmount: 2,
      onResult: (value) => result = value,
    );

    final updateButton = find.widgetWithText(FilledButton, 'Save changes');
    await tester.enterText(find.byType(TextField).last, '0');
    await tester.pump();
    expect(tester.widget<FilledButton>(updateButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField).last, '');
    await tester.pump();
    expect(tester.widget<FilledButton>(updateButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField).last, '100.5');
    await tester.pump();
    expect(find.text('Total weight: 201 g'), findsOneWidget);
    expect(tester.widget<FilledButton>(updateButton).onPressed, isNotNull);

    await tester.tap(updateButton);
    await tester.pumpAndSettle();
    expect(result!.servingSizeGrams, 100.5);
  });

  testWidgets('reset restores baseline nutrition and keeps quantity', (
    tester,
  ) async {
    final baseline = apple();
    final overridden = rescaleFoodAmount(baseline, 100 / 182)
      ..amount = 1
      ..servingSizeGrams = 100;
    FoodEntry? result;
    await pumpSheet(
      tester,
      food: overridden,
      baselineFood: baseline,
      action: FoodQuantityAction.updateSelection,
      initialAmount: 2,
      onResult: (value) => result = value,
    );

    expect(find.text('Default serving: 182 g'), findsNothing);
    expect(find.text('Total weight: 200 g'), findsOneWidget);
    await tester.tap(find.text('Use default weight (182 g)'));
    await tester.pump();

    expect(find.text('Total weight: 364 g'), findsOneWidget);
    expect(find.text('190 kcal'), findsOneWidget);
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(result!.amount, 2);
    expect(result!.servingSizeGrams, 182);
    expect(result!.nutrition.energyKcal, 190);
    expect(overridden.servingSizeGrams, 100);
    expect(baseline.servingSizeGrams, 182);
  });

  testWidgets('unknown baseline keeps quantity editing available', (
    tester,
  ) async {
    final source = apple();
    FoodEntry? result;
    await pumpSheet(
      tester,
      food: source,
      baselineFood: source,
      action: FoodQuantityAction.updateSelection,
      initialAmount: 2,
      gramsKnown: false,
      baselineGramsKnown: false,
      onResult: (value) => result = value,
    );

    final updateButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save changes'),
    );
    expect(updateButton.onPressed, isNotNull);
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(result!.amount, 2);
    expect(result!.nutrition.energyKcal, 190);
    expect(source.amount, 1);
  });

  testWidgets('keeps household units at the amount input end', (tester) async {
    await pumpSheet(tester, food: apple()..unit = 'cup');

    expect(find.text('cup'), findsOneWidget);
  });

  testWidgets('keeps unknown nutrition values descriptive', (tester) async {
    final food = apple()
      ..nutrition.unavailableNutrients = {
        'energyKcal',
        'protein',
        'carbs',
        'fat',
      };
    await pumpSheet(
      tester,
      food: food,
      action: FoodQuantityAction.updateSelection,
      initialAmount: 2,
      gramsKnown: false,
      baselineGramsKnown: false,
    );

    expect(find.text('Nutrition for 2 medium'), findsOneWidget);
    expect(find.text('— kcal'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(3));
    expect(find.text('Nutrition information unavailable'), findsOneWidget);
  });

  testWidgets('invalid direct amounts disable adding', (tester) async {
    await pumpSheet(tester);

    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();

    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Add to Snack'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('invalid source amounts cannot be added', (tester) async {
    await pumpSheet(tester, food: apple()..amount = double.nan);

    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Add to Snack'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('dismissal returns no food and German action is localized', (
    tester,
  ) async {
    FoodEntry? result = apple();
    await pumpSheet(
      tester,
      locale: const Locale('de'),
      onResult: (value) => result = value,
    );

    expect(find.text('Zu Snack hinzufügen'), findsOneWidget);
    await tester.tap(find.byTooltip('Schließen'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
