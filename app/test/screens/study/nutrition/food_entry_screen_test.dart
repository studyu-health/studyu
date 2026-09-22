import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_core/core.dart';

void main() {
  testWidgets('saving an edited food preserves identity and provenance', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final createdAt = DateTime.utc(2026, 9, 20, 10);
    final modifiedAt = DateTime.utc(2026, 9, 21, 11);
    final existing = FoodEntry(
      id: 'food-id',
      entryType: FoodEntryType.recipe,
      name: 'Recipe',
      brandName: 'Brand',
      description: 'Description',
      amount: 3,
      unit: 'serving',
      servingSizeGrams: 250,
      portionReference: 'bowl',
      portionEstimationMethod: PortionEstimationMethod.userWeighted,
      portionState: PortionState.cooked,
      yieldFactor: 0.8,
      ediblePortion: 0.9,
      nutrition: NutritionProfile(
        energyKcal: 300,
        protein: 20,
        carbs: 30,
        fat: 10,
        sugars: 5,
        fiber: 4,
        saturatedFat: 2,
        transFat: 1,
        cholesterol: 7,
        sodium: 8,
        waterContent: 9,
        micros: const {'iron': 10},
      ),
      foodCode: 'food-code',
      externalId: 'external-id',
      source: FoodSource.usda,
      confidenceScore: 0.75,
      templateId: 'template-id',
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      originalValues: {
        'source': 'original',
        'nested': {'value': 'keep'},
      },
      parentRecipeId: 'parent-recipe-id',
      recipeMetadata: RecipeMetadata(
        rawWeight: 1000,
        cookedWeight: 800,
        yieldFactor: 0.8,
        preparationMethod: 'Bake',
        retentionFactors: const {'protein': 0.9},
      ),
      recipeIngredients: [
        RecipeComposition(
          id: 'composition-id',
          recipeId: 'recipe-id',
          ingredientId: 'ingredient-id',
          amount: 2,
          unit: 'cup',
          sortOrder: 1,
        ),
      ],
    );
    FoodEntry? saved;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                saved = await Navigator.of(context)
                    .push(FoodEntryScreen.route(existingFood: existing));
              },
              child: const Text('Edit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Edited Recipe');
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.name, 'Edited Recipe');
    expect(existing.name, 'Recipe');
    expect(saved!.id, existing.id);
    expect(saved!.createdAt, createdAt);
    expect(saved!.modifiedAt, modifiedAt);
    expect(saved!.foodCode, existing.foodCode);
    expect(saved!.externalId, existing.externalId);
    expect(saved!.source, existing.source);
    expect(saved!.confidenceScore, existing.confidenceScore);
    expect(saved!.templateId, existing.templateId);
    expect(saved!.originalValues, existing.originalValues);
    expect(saved!.parentRecipeId, existing.parentRecipeId);
    expect(saved!.recipeMetadata!.toJson(), existing.recipeMetadata!.toJson());
    expect(
      saved!.recipeIngredients!.single.toJson(),
      existing.recipeIngredients!.single.toJson(),
    );
    expect(saved!.nutrition.transFat, existing.nutrition.transFat);
    expect(saved!.nutrition.cholesterol, existing.nutrition.cholesterol);
    expect(saved!.nutrition.waterContent, existing.nutrition.waterContent);
    expect(saved!.nutrition.micros, existing.nutrition.micros);

    (saved!.originalValues['nested'] as Map<String, dynamic>)['value'] =
        'changed';
    saved!.recipeMetadata!.retentionFactors['protein'] = 0.1;
    saved!.recipeIngredients!.single.amount = 4;
    saved!.recipeIngredients!.clear();
    saved!.nutrition.micros['iron'] = 1;

    expect(
      (existing.originalValues['nested'] as Map<String, dynamic>)['value'],
      'keep',
    );
    expect(existing.recipeMetadata!.retentionFactors['protein'], 0.9);
    expect(existing.recipeIngredients, hasLength(1));
    expect(existing.recipeIngredients!.single.amount, 2);
    expect(existing.nutrition.micros['iron'], 10);
  });
}
