import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';

import 'fake_nutrition_food_repository.dart';

Widget testApp(Widget home) => ChangeNotifierProvider(
  create: (_) => AppState(),
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: home,
  ),
);

Finder field(String label) => find
    .ancestor(of: find.text(label), matching: find.byType(TextFormField))
    .first;

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('food draft asks before leaving', (tester) async {
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => Navigator.push(
                context,
                FoodEntryScreen.route(showSearchAction: false),
              ),
              child: const Text('Open food'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open food'));
    await tester.pumpAndSettle();
    await tester.enterText(field(l10n.food_name), 'Apple');

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Discard unsaved changes?'), findsOneWidget);
    await tester.tap(find.text('Continue editing'));
    await tester.pumpAndSettle();
    expect(find.byType(FoodEntryScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();
    expect(find.byType(FoodEntryScreen), findsNothing);
  });

  testWidgets('meal creator draft asks before leaving', (tester) async {
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () =>
                  Navigator.push(context, MealCreatorScreen.route()),
              child: const Text('Open meal creator'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open meal creator'));
    await tester.pumpAndSettle();
    await tester.enterText(field(l10n.template_name_required), 'Lunch bowl');

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Discard unsaved changes?'), findsOneWidget);
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();
    expect(find.byType(MealCreatorScreen), findsNothing);
  });

  testWidgets('selected search foods ask before being discarded', (
    tester,
  ) async {
    var returned = false;
    FoodSearchSelection? result;
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await FoodSearchScreen.show(
                  context,
                  mealLabel: 'Lunch',
                  repository: FakeNutritionFoodRepository(),
                );
                returned = true;
              },
              child: const Text('Open search'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create food'));
    await tester.pumpAndSettle();

    await tester.enterText(field(l10n.food_name), 'Apple');
    await tester.tap(find.text('Save and add to Lunch'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(find.text('Discard unsaved changes?'), findsOneWidget);
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();

    expect(returned, isTrue);
    expect(result, isNull);
  });
}
