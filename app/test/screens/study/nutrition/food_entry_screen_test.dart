import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

import 'fake_nutrition_food_repository.dart';

Widget foodEntryApp({
  FoodEntry? existingFood,
  bool showSearchAction = true,
  bool historicalMode = false,
  bool isExternalLibraryCopy = false,
  String? mealLabel,
  TemplateViewModel? templateViewModel,
  ValueChanged<FoodEntry?>? onResult,
}) => ChangeNotifierProvider.value(
  value: AppState(),
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<FoodEntry>(
                FoodEntryScreen.route(
                  existingFood: existingFood,
                  showSearchAction: showSearchAction,
                  historicalMode: historicalMode,
                  isExternalLibraryCopy: isExternalLibraryCopy,
                  mealLabel: mealLabel,
                  templateViewModel: templateViewModel,
                ),
              );
              onResult?.call(result);
            },
            child: const Text('Open food'),
          ),
        ),
      ),
    ),
  ),
);

Future<void> openFoodEntry(
  WidgetTester tester, {
  FoodEntry? existingFood,
  bool showSearchAction = true,
  bool historicalMode = false,
  bool isExternalLibraryCopy = false,
  String? mealLabel,
  TemplateViewModel? templateViewModel,
  ValueChanged<FoodEntry?>? onResult,
}) async {
  await tester.pumpWidget(
    foodEntryApp(
      existingFood: existingFood,
      showSearchAction: showSearchAction,
      historicalMode: historicalMode,
      isExternalLibraryCopy: isExternalLibraryCopy,
      mealLabel: mealLabel,
      templateViewModel: templateViewModel,
      onResult: onResult,
    ),
  );
  await tester.tap(find.text('Open food'));
  await tester.pumpAndSettle();
}

FoodEntry existingOffFood(Map<String, dynamic> originalValues) {
  return FoodEntry(
    id: 'off-food',
    foodId: 'off-food-definition',
    foodVersionId: 'off-food-version',
    entryType: FoodEntryType.brandedProduct,
    name: 'Original product',
    brandName: 'Brand',
    description: 'Source description',
    amount: 1,
    unit: 'bar',
    servingSizeGrams: 42,
    portionReference: 'one bar',
    portionEstimationMethod: PortionEstimationMethod.standardUnit,
    portionState: PortionState.asServed,
    yieldFactor: 0.9,
    ediblePortion: 0.8,
    nutrition: NutritionProfile(
      energyKcal: 200,
      protein: 5,
      carbs: 20,
      fat: 10,
      sugars: 8,
      fiber: 3,
      saturatedFat: 4,
      transFat: 0.5,
      cholesterol: 7,
      sodium: 100,
      waterContent: 12,
      micros: {'iron': 2},
    ),
    foodCode: 'off-code',
    externalId: 'off-external-id',
    source: FoodSource.openfoodfacts,
    confidenceScore: 0.73,
    templateId: 'template-id',
    createdAt: DateTime.utc(2025, 1, 2, 3, 4),
    modifiedAt: DateTime.utc(2025, 2, 3),
    originalValues: originalValues,
    parentEntryId: 'parent-recipe-id',
    preparationDetails: PreparationDetails(
      rawWeight: 100,
      cookedWeight: 80,
      yieldFactor: 0.8,
      preparationMethod: 'baked',
      retentionFactors: {'protein': 0.9},
    ),
    componentFoods: [
      FoodComposition(
        id: 'composition-id',
        parentEntryId: 'recipe-id',
        foodId: 'ingredient-id',
        amount: 1,
        unit: 'piece',
      ),
    ],
  );
}

Finder inputWithLabel(String label) => find
    .ancestor(
      of: find.textContaining(label),
      matching: find.byType(TextFormField),
    )
    .first;

Finder decoratorWithLabel(String label) => find.byWidgetPredicate(
  (widget) =>
      widget is InputDecorator &&
      widget.decoration.labelText?.contains(label) == true,
);

class _TrackingTemplateRepository() extends FakeNutritionFoodRepository {
  int saveCalls = 0;

  @override
  Future<SavedFoodTemplate> saveTemplate({
    required String subjectId,
    required String name,
    required FoodEntry food,
    List<String>? tags,
    String? expectedVersionId,
  }) {
    saveCalls++;
    return super.saveTemplate(
      subjectId: subjectId,
      name: name,
      food: food,
      tags: tags,
      expectedVersionId: expectedVersionId,
    );
  }
}

void main() {
  testWidgets('shows database search outside the search flow', (tester) async {
    await openFoodEntry(tester);

    expect(find.byTooltip('Search Food Database'), findsOneWidget);
  });

  testWidgets('does not open nested search from the search flow', (
    tester,
  ) async {
    await openFoodEntry(tester, showSearchAction: false);

    expect(find.byTooltip('Search Food Database'), findsNothing);
  });

  testWidgets(
    'historical search saves reusable food by default and returns selection',
    (tester) async {
      final repository = _TrackingTemplateRepository();
      FoodSearchSelection? result;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: AppState(),
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) => Scaffold(
                body: FilledButton(
                  onPressed: () async {
                    result = await FoodSearchScreen.show(
                      context,
                      mealLabel: 'Dinner',
                      historicalMode: true,
                      repository: repository,
                    );
                  },
                  child: const Text('Open search'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open search'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Create food'), findsOneWidget);
      expect(find.text('Create meal'), findsNothing);

      await tester.tap(find.byTooltip('Create food'));
      await tester.pumpAndSettle();
      final saveToMyItems = find.widgetWithText(
        CheckboxListTile,
        'Save to My items for future use',
      );
      expect(tester.widget<CheckboxListTile>(saveToMyItems).value, isTrue);
      expect(find.byTooltip('Search Food Database'), findsNothing);

      await tester.enterText(inputWithLabel('Food Name'), 'Historical soup');
      await tester.tap(
        find.widgetWithText(FilledButton, 'Save and add to Dinner'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add 1 item to Dinner'));
      await tester.pumpAndSettle();

      expect(repository.saveCalls, 1);
      expect(result?.foods.single.name, 'Historical soup');
      expect(result?.foods.single.templateId, isNotNull);
    },
  );

  testWidgets(
    'historical manual food opt-out returns occurrence without reusable save',
    (tester) async {
      final repository = _TrackingTemplateRepository();
      final templateViewModel = TemplateViewModel(
        userId: 'subject',
        repository: repository,
      );
      FoodEntry? result;

      await openFoodEntry(
        tester,
        historicalMode: true,
        mealLabel: 'Dinner',
        templateViewModel: templateViewModel,
        onResult: (value) => result = value,
      );

      await tester.tap(find.text('Save to My items for future use'));
      await tester.pump();
      expect(
        tester
            .widget<CheckboxListTile>(
              find.widgetWithText(
                CheckboxListTile,
                'Save to My items for future use',
              ),
            )
            .value,
        isFalse,
      );

      await tester.enterText(inputWithLabel('Food Name'), 'One-off soup');
      await tester.tap(
        find.widgetWithText(FilledButton, 'Save and add to Dinner'),
      );
      await tester.pumpAndSettle();

      expect(repository.saveCalls, 0);
      expect(result?.name, 'One-off soup');
      expect(result?.templateId, isNull);
    },
  );

  testWidgets('external copy mode exposes review and save semantics', (
    tester,
  ) async {
    final existingFood = existingOffFood(const {
      'image_front_small_url': 'https://images.openfoodfacts.org/product.jpg',
    });
    FoodEntry? result;

    await openFoodEntry(
      tester,
      existingFood: existingFood,
      showSearchAction: false,
      isExternalLibraryCopy: true,
      onResult: (value) => result = value,
    );

    expect(find.text('Review food'), findsOneWidget);
    expect(find.text('Save to My library'), findsOneWidget);
    expect(
      find.textContaining('Changes won’t affect the external library.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).first, 'Copied product');
    await tester.tap(find.widgetWithText(FilledButton, 'Save to My library'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.name, 'Copied product');
    expect(result!.id, existingFood.id);
    expect(result!.foodId, existingFood.foodId);
    expect(result!.foodVersionId, existingFood.foodVersionId);
    expect(result!.foodCode, existingFood.foodCode);
    expect(result!.externalId, existingFood.externalId);
    expect(result!.source, existingFood.source);
    expect(result!.originalValues, equals(existingFood.originalValues));
  });

  testWidgets('normal editing of imported food does not show copy mode', (
    tester,
  ) async {
    await openFoodEntry(
      tester,
      existingFood: existingOffFood(const {}),
      showSearchAction: false,
    );

    expect(find.text('Review food'), findsNothing);
    expect(find.text('Save to My library'), findsNothing);
    expect(find.text('Edit food'), findsOneWidget);
  });

  testWidgets('discarding external copy returns no result', (tester) async {
    FoodEntry? result;
    await openFoodEntry(
      tester,
      existingFood: existingOffFood(const {}),
      showSearchAction: false,
      isExternalLibraryCopy: true,
      onResult: (value) => result = value,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('editing preserves food identity and source provenance', (
    tester,
  ) async {
    const imageUrl = 'https://images.openfoodfacts.org/product.jpg';
    final originalValues = <String, dynamic>{
      'image_front_small_url': imageUrl,
      'source_name': 'Open Food Facts',
      'nested': {'value': 'keep'},
    };
    final existingFood = existingOffFood(originalValues);
    FoodEntry? result;

    await openFoodEntry(
      tester,
      existingFood: existingFood,
      onResult: (value) => result = value,
    );

    await tester.enterText(inputWithLabel('Food Name'), 'Edited product');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.name, 'Edited product');
    expect(result!.id, existingFood.id);
    expect(result!.createdAt, existingFood.createdAt);
    expect(result!.modifiedAt, isNotNull);
    expect(result!.modifiedAt, isNot(existingFood.modifiedAt));
    expect(result!.foodCode, existingFood.foodCode);
    expect(result!.externalId, existingFood.externalId);
    expect(result!.source, existingFood.source);
    expect(result!.confidenceScore, existingFood.confidenceScore);
    expect(result!.templateId, existingFood.templateId);
    expect(result!.originalValues, equals(originalValues));
    expect(result!.parentEntryId, existingFood.parentEntryId);
    expect(
      result!.preparationDetails?.toJson(),
      equals(existingFood.preparationDetails?.toJson()),
    );
    expect(
      result!.componentFoods?.map((food) => food.toJson()).toList(),
      equals(
        existingFood.componentFoods?.map((food) => food.toJson()).toList(),
      ),
    );
    expect(result!.nutrition.transFat, existingFood.nutrition.transFat);
    expect(result!.nutrition.cholesterol, existingFood.nutrition.cholesterol);
    expect(result!.nutrition.waterContent, existingFood.nutrition.waterContent);
    expect(result!.nutrition.micros, equals(existingFood.nutrition.micros));

    (result!.originalValues['nested'] as Map<String, dynamic>)['value'] =
        'changed';
    result!.preparationDetails!.retentionFactors['protein'] = 0.1;
    result!.componentFoods!.single.amount = 2;
    result!.nutrition.micros['iron'] = 1;

    expect(
      (existingFood.originalValues['nested'] as Map<String, dynamic>)['value'],
      'keep',
    );
    expect(existingFood.preparationDetails!.retentionFactors['protein'], 0.9);
    expect(existingFood.componentFoods!.single.amount, 1);
    expect(existingFood.nutrition.micros['iron'], 2);
  });

  testWidgets('missing or malformed image values render no product image', (
    tester,
  ) async {
    await openFoodEntry(tester, existingFood: existingOffFood(const {}));
    expect(find.byType(Image), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await openFoodEntry(
      tester,
      existingFood: existingOffFood(const {'image_front_small_url': 42}),
    );
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('failed product image leaves no empty space', (tester) async {
    await openFoodEntry(
      tester,
      existingFood: existingOffFood(const {
        'image_front_small_url': 'https://example.invalid/image.jpg',
      }),
    );
    final failedImageCardTop = tester.getTopLeft(find.byType(Card).first).dy;

    await tester.pageBack();
    await tester.pumpAndSettle();
    await openFoodEntry(tester, existingFood: existingOffFood(const {}));
    final absentImageCardTop = tester.getTopLeft(find.byType(Card).first).dy;

    expect(failedImageCardTop, absentImageCardTop);
  });

  testWidgets('uses themed cards and unfilled field decorations', (
    tester,
  ) async {
    await openFoodEntry(tester, existingFood: existingOffFood(const {}));

    expect(
      tester
          .widget<InputDecorator>(decoratorWithLabel('Food Name'))
          .decoration
          .filled,
      isNot(true),
    );

    await tester.tap(find.text('Detailed Nutrition'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<InputDecorator>(decoratorWithLabel('Fiber'))
          .decoration
          .filled,
      isNot(true),
    );
  });
}
