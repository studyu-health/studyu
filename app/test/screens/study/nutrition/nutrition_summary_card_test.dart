import 'dart:ui' show SemanticsAction;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_core/core.dart';

Widget testApp(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('summary exposes known partial zero and unknown independently', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final nutrition = NutritionProfile(
      energyKcal: 0,
      protein: 999,
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
      unavailableNutrients: {'protein'},
      partialNutrients: {'energyKcal', 'carbs'},
    );
    await tester.pumpWidget(
      testApp(Scaffold(body: NutritionSummaryCard(nutrition: nutrition))),
    );
    expect(find.bySemanticsLabel(RegExp('0 kcal.*partial')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('0 g.*partial')), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(nutrition.protein, 999);
    semantics.dispose();
  });

  testWidgets('nutrition summary distinguishes zero and unavailable values', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();

    final nutrition = NutritionProfile(
      energyKcal: 555,
      protein: 50.4,
      carbs: 30.7,
      fat: 23.9,
      sugars: 0,
      fiber: 3.5,
      saturatedFat: 0,
      transFat: 0,
      cholesterol: 0,
      sodium: 0,
      waterContent: 0,
      micros: const {},
      unavailableNutrients: const {'sugars'},
      unavailableItemCount: 1,
    );

    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: SingleChildScrollView(
            child: NutritionSummaryCard(
              nutrition: nutrition,
              title: 'Today’s nutrition',
              inCard: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('Today’s nutrition'), findsOneWidget);
    expect(find.text('555 kcal'), findsOneWidget);
    expect(find.text('30.7 g'), findsOneWidget);
    expect(find.text('50.4 g'), findsOneWidget);
    expect(find.text('Macronutrients'), findsOneWidget);
    expect(find.text('Energy by macronutrient'), findsNothing);
    expect(find.text('Carbohydrates'), findsOneWidget);
    expect(find.text('23%'), findsOneWidget);
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('37%'), findsOneWidget);
    expect(find.text('Fat'), findsOneWidget);
    expect(find.text('23.9 g'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byType(NutritionMacroDistributionBar))
          .getSemanticsData()
          .label,
      contains('Carbohydrates 23%, Protein 37%, Fat 40%'),
    );
    expect(find.text('Detailed Nutrients'), findsOneWidget);
    expect(find.text('Fibre'), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    final detailsSemantics = tester.getSemantics(
      find.bySemanticsLabel('Detailed Nutrients'),
    );
    expect(
      detailsSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(find.text('Show'), findsNothing);
    expect(find.text('Hide'), findsNothing);
    expect(
      find.textContaining('Some nutrient values are unavailable for 1 item.'),
      findsOneWidget,
    );
    expect(find.text('—'), findsNothing);

    await tester.tap(find.text('Detailed Nutrients'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('0 g'), findsAtLeastNWidgets(1));

    semantics.dispose();
  });

  testWidgets('macro distribution shows amounts and energy percentages', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        const NutritionMacroDistributionBar(
          carbs: 30.7,
          protein: 50.4,
          fat: 23.9,
        ),
      ),
    );

    expect(find.text('Energy by macronutrient'), findsNothing);
    expect(find.text('Carbohydrates'), findsOneWidget);
    expect(find.text('30.7 g'), findsOneWidget);
    expect(find.text('23%'), findsOneWidget);
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('50.4 g'), findsOneWidget);
    expect(find.text('37%'), findsOneWidget);
    expect(find.text('Fat'), findsOneWidget);
    expect(find.text('23.9 g'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Carbs')), findsNothing);
  });

  testWidgets('zero macro energy has no distribution chart', (tester) async {
    await tester.pumpWidget(
      testApp(
        const NutritionMacroDistributionBar(carbs: 0, protein: 0, fat: 0),
      ),
    );

    expect(find.text('Energy by macronutrient'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('kcal'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('measured zero energy stays known despite positive macros', (
    tester,
  ) async {
    final nutrition = NutritionProfile(
      energyKcal: 0,
      protein: 10,
      carbs: 20,
      fat: 5,
      sugars: 0,
      fiber: 0,
      saturatedFat: 0,
      transFat: 0,
      cholesterol: 0,
      sodium: 0,
      waterContent: 0,
      micros: const {},
    );
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: SingleChildScrollView(
            child: NutritionSummaryCard(nutrition: nutrition),
          ),
        ),
      ),
    );

    expect(find.text('—'), findsNothing);
    expect(find.text('0 kcal'), findsOneWidget);
    expect(find.text('Energy by macronutrient'), findsNothing);
  });

  testWidgets('German distribution wraps at narrow width', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: NutritionMacroDistributionBar(
              carbs: 30.7,
              protein: 50.4,
              fat: 23.9,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Energie nach Makronährstoffen'), findsNothing);
    expect(find.text('Kohlenhydrate'), findsOneWidget);
    expect(find.text('23%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recipe builder empty state is passive and fields are unfilled', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(testApp(const MealCreatorScreen()));
    await tester.pump();

    final emptyState = find.text('No foods yet');
    expect(emptyState, findsOneWidget);
    expect(
      find.ancestor(of: emptyState, matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(
      tester
          .getSemantics(emptyState)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );

    for (final label in [
      l10n.template_name_required,
      l10n.nutrition_servings_required,
      l10n.description,
    ]) {
      final field = tester.widget<TextField>(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == label,
        ),
      );
      expect(field.decoration?.filled, isNot(true));
      expect(field.decoration?.fillColor, isNull);
    }

    await tester.tap(find.byTooltip('Add food manually'));
    await tester.pumpAndSettle();

    for (final label in [
      l10n.food_name,
      l10n.nutrition_quantity_short,
      l10n.nutrition_calories_kcal,
    ]) {
      final field = tester.widget<TextField>(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == label,
        ),
      );
      expect(field.decoration?.filled, isNot(true));
      expect(field.decoration?.fillColor, isNull);
    }

    semantics.dispose();
  });

  testWidgets('recipe builder uses the shared collapsed nutrition summary', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(const MealCreatorScreen()));
    await tester.pump();

    await tester.tap(find.byTooltip('Add food manually'));
    await tester.pumpAndSettle();

    final nameField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == l10n.food_name,
    );
    final caloriesField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == l10n.nutrition_calories_kcal,
    );
    await tester.enterText(nameField, 'Test ingredient');
    await tester.enterText(caloriesField, '100');
    final addButton = find.widgetWithText(FilledButton, 'Add');
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.byType(NutritionSummaryCard), findsOneWidget);
    expect(find.text(l10n.nutrition_per_serving), findsOneWidget);
    expect(find.text('1 serving'), findsOneWidget);
    expect(find.text('100 kcal'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(3));
    expect(find.text('0%'), findsNothing);
    expect(find.text('No data yet'), findsNothing);
  });
}
