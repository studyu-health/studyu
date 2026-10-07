import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_core/core.dart';

import 'fake_nutrition_food_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'meal creator retains known partial zero across save and reload',
    (tester) async {
      final known = _food()..nutrition.energyKcal = 0;
      final missing = _food()
        ..nutrition.energyKcal = 999
        ..nutrition.unavailableNutrients = {'energyKcal', 'protein'};
      final repository = FakeNutritionFoodRepository();
      final viewModel = TemplateViewModel(
        userId: 'subject',
        repository: repository,
      );
      addTearDown(viewModel.dispose);
      FoodEntry? result;
      await _pump(
        tester,
        () => MealCreatorScreen.route(
          initialName: 'Meal',
          initialFoods: [known, missing],
          templateViewModel: viewModel,
        ),
        (food) => result = food,
        viewModel,
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(result!.nutrition.energyKcal, 0);
      expect(result!.nutrition.isKnown('energyKcal'), isTrue);
      expect(result!.nutrition.isPartial('energyKcal'), isTrue);
      final stored = (await repository.loadTemplates('subject'))
          .single
          .prototype;
      expect(stored.nutrition.isPartial('energyKcal'), isTrue);
      expect(
        stored.componentSnapshots!.last.nutrition.isKnown('energyKcal'),
        isFalse,
      );
      expect(missing.nutrition.energyKcal, 999);
    },
  );

  testWidgets(
    'repeated meal edits preserve serving nutrition and composition',
    (tester) async {
      final ingredient = _food();
      var meal = _food()
        ..entryType = FoodEntryType.meal
        ..name = 'Soup'
        ..foodId = 'meal-definition'
        ..amount = 2
        ..nutrition.energyKcal = 200
        ..componentFoods = [
          FoodComposition.withId(
            parentEntryId: 'meal',
            foodId: ingredient.foodId,
            amount: 1,
            unit: 'serving',
            sortOrder: 0,
          ),
        ]
        ..componentSnapshots = [ingredient];
      final repository = FakeNutritionFoodRepository();
      final viewModel = TemplateViewModel(
        userId: 'subject',
        repository: repository,
      );
      addTearDown(viewModel.dispose);
      await _pump(
        tester,
        () => MealCreatorScreen.route(existingMeal: meal),
        (result) => meal = result,
        viewModel,
      );

      for (var edit = 0; edit < 2; edit++) {
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(meal.amount, 2);
        expect(meal.nutrition.energyKcal, 200);
        expect(meal.componentFoods!.single.amount, 1);
        expect(flattenNutritionFoodEntries([meal]).single.amount, 2);
      }
    },
  );

  testWidgets(
    'new multi-serving meal stores one-serving definition and total occurrence',
    (tester) async {
      final repository = FakeNutritionFoodRepository();
      final viewModel = TemplateViewModel(
        userId: 'subject',
        repository: repository,
      );
      addTearDown(viewModel.dispose);
      FoodEntry? result;
      await _pump(
        tester,
        () => MealCreatorScreen.route(
          initialName: 'Soup',
          initialFoods: [_food()],
          templateViewModel: viewModel,
        ),
        (food) => result = food,
        viewModel,
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final l10n = lookupAppLocalizations(const Locale('en'));
      await tester.enterText(
        find.widgetWithText(TextFormField, l10n.nutrition_servings_required),
        '2',
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(result!.amount, 2);
      expect(result!.nutrition.energyKcal, 100);
      expect(result!.componentFoods!.single.amount, 0.5);
      final template = (await repository.loadTemplates('subject'))
          .single
          .prototype;
      expect(template.amount, 1);
      expect(template.nutrition.energyKcal, 50);
      expect(template.componentFoods!.single.amount, 0.5);
    },
  );
}

Future<void> _pump(
  WidgetTester tester,
  MaterialPageRoute<FoodEntry> Function() route,
  void Function(FoodEntry) onResult,
  TemplateViewModel viewModel,
) => tester.pumpWidget(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider.value(value: viewModel),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(route());
              if (result != null) onResult(result);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  ),
);

FoodEntry _food() => FoodEntry.withId(
  entryType: FoodEntryType.singleIngredient,
  name: 'Ingredient',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  source: FoodSource.manual,
  confidenceScore: 1,
  originalValues: {},
  nutrition: NutritionProfile(
    energyKcal: 100,
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
  ),
);
