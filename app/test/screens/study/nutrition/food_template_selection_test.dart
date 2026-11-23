import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_library.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart' as studyu;

import 'fake_nutrition_food_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final kind in ['draft', 'draft with template ID', 'saved', 'synced']) {
    testWidgets('$kind selection uses its food identity', (tester) async {
      final isSynced = kind == 'synced';
      final food = _food()
        ..templateId = kind == 'saved' || kind == 'draft with template ID'
            ? 'saved-template'
            : null;
      final recall = studyu.DailyRecall.withId(
        date: DateTime(2026),
        recallMode: studyu.RecallMode.realtimeRecord,
        meals: [
          studyu.MealLog.withId(
            mealType: studyu.MealType.lunch,
            timestamp: DateTime(2026),
            timezone: 'UTC',
            isSkipped: false,
            foods: [food],
          ),
        ],
      );
      final model = TemplateViewModel(
        userId: 'test',
        repository: FakeNutritionFoodRepository([
          if (kind == 'saved' || isSynced)
            studyu.SavedFoodTemplate(
              id: isSynced ? food.foodId : 'saved-template',
              userId: 'test',
              name: food.name,
              isPublic: false,
              createdAt: food.createdAt,
              prototype: food,
            ),
        ]),
        loadDraftRecalls: () async => [
          if (kind.startsWith('draft'))
            (recall: recall, taskId: 'task', periodId: 'period'),
        ],
      );
      final appState = AppState();
      if (isSynced) {
        final subject = studyu.StudySubject('test', 'study', 'user', []);
        subject.progress.add(
          studyu.SubjectProgress(
            subjectId: subject.id,
            interventionId: 'intervention',
            taskId: 'task',
            resultType: 'DailyRecall',
            result: studyu.Result<studyu.DailyRecall>.app(
              type: 'DailyRecall',
              periodId: 'period',
              result: recall,
            ),
          ),
        );
        appState.activeSubject = subject;
      }
      addTearDown(model.dispose);
      addTearDown(appState.dispose);
      await model.loadAllTemplates();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FoodSearchScreen(
              mealLabel: 'Lunch',
              initialFoods: [food],
              templateViewModel: model,
              openFoodFactsSearch: ({
                required query,
                required page,
                required pageSize,
              }) async => const SearchResult(products: []),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = lookupAppLocalizations(const Locale('en'));
      await tester.tap(find.text(l10n.my_saved_items));
      await tester.pumpAndSettle();
      FoodLibraryItemCard card() =>
          tester.widget(find.byType(FoodLibraryItemCard));
      expect(card().isSelected, isTrue);
      expect(card().selectedQuantity, 1);
      await tester.tap(
        find.descendant(
          of: find.byType(FoodLibraryItemCard),
          matching: find.byTooltip(l10n.food_selection_increment('Nutella')),
        ),
      );
      await tester.pumpAndSettle();
      expect(card().selectedQuantity, 2);
      await tester.tap(
        find.descendant(
          of: find.byType(FoodLibraryItemCard),
          matching: find.byTooltip(l10n.food_selection_decrement('Nutella')),
        ),
      );
      await tester.pumpAndSettle();
      expect(card().selectedQuantity, 1);
      if (isSynced) {
        await tester.tap(
          find.descendant(
            of: find.byType(FoodLibraryItemCard),
            matching: find.byTooltip(l10n.food_selection_decrement('Nutella')),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.food_selection_remove));
        await tester.pumpAndSettle();
        expect(card().isSelected, isFalse);
        await tester.tap(
          find.descendant(
            of: find.byType(FoodLibraryItemCard),
            matching: find.text('Nutella'),
          ),
        );
        await tester.pumpAndSettle();
        expect(card().selectedQuantity, 1);
        await tester.tap(find.text(l10n.recent_foods));
        await tester.pumpAndSettle();
        final increment = find.descendant(
          of: find.byType(ListView).first,
          matching: find.byTooltip(l10n.food_selection_increment('Nutella')),
        );
        await tester.tap(increment);
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.my_saved_items));
        await tester.pumpAndSettle();
        expect(card().selectedQuantity, 2);
      }
      await tester.enterText(find.byType(TextField).first, 'Nutella');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(card().isSelected, isTrue);
      expect(card().selectedQuantity, isSynced ? 2 : 1);
    });
  }
}

studyu.FoodEntry _food() => studyu.FoodEntry(
  id: 'entry',
  foodId: 'food',
  foodVersionId: 'version',
  entryType: studyu.FoodEntryType.singleIngredient,
  name: 'Nutella',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: studyu.PortionEstimationMethod.unknown,
  portionState: studyu.PortionState.asServed,
  nutrition: studyu.NutritionProfile(
    energyKcal: 100,
    protein: 5,
    carbs: 10,
    fat: 2,
    sugars: 3,
    fiber: 4,
    saturatedFat: 1,
    transFat: 0,
    cholesterol: 0,
    sodium: 10,
    waterContent: 70,
    micros: {},
  ),
  source: studyu.FoodSource.openfoodfacts,
  externalId: '3017620422003',
  confidenceScore: 1,
  createdAt: DateTime.utc(2025),
  originalValues: {},
);
