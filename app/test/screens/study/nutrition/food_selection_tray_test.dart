import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_library.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_core/core.dart' as studyu;

import 'fake_nutrition_food_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('search header Create opens meal creation from the basket', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpSearch(tester);
    await _addExternalApple(tester);

    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();
    final create = find.descendant(
      of: find.byType(AppBar),
      matching: find.text('Create'),
    );

    await tester.tap(create);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create meal'));
    await tester.pumpAndSettle();
    expect(find.byType(MealCreatorScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Selected items'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('selection-expanded-list')),
      findsOneWidget,
    );
    expect(create, findsOneWidget);
  });

  testWidgets('manual entry prompt appears only after an empty search', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpSearch(tester, query: null);
    final l10n = lookupAppLocalizations(const Locale('en'));
    final prompt = find.text(l10n.cant_find_it);

    expect(prompt, findsNothing);

    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('External Apple'), findsOneWidget);
    expect(prompt, findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, l10n.my_saved_items));
    await tester.pumpAndSettle();
    expect(find.text(l10n.no_results_for_query('apple')), findsOneWidget);
    expect(prompt.hitTestable(), findsOneWidget);

    await tester.tap(find.text(l10n.create_food_from_search('apple')));
    await tester.pumpAndSettle();
    expect(find.byType(FoodEntryScreen), findsOneWidget);
  });

  testWidgets('search filters show results from the selected sources', (
    tester,
  ) async {
    final subject = studyu.StudySubject('subject', 'study', 'user', []);
    final date = DateTime.utc(2025);
    subject.progress.add(
      studyu.SubjectProgress(
        subjectId: subject.id,
        interventionId: 'intervention',
        taskId: 'task',
        resultType: 'DailyRecall',
        result: studyu.Result<studyu.DailyRecall>.app(
          type: 'DailyRecall',
          periodId: 'period',
          result: studyu.DailyRecall.withId(
            date: date,
            recallMode: studyu.RecallMode.realtimeRecord,
            meals: [
              studyu.MealLog.withId(
                mealType: studyu.MealType.lunch,
                mealContext: studyu.MealContext.home,
                timestamp: date,
                timezone: 'UTC',
                isSkipped: false,
                foods: [
                  _libraryTemplate(name: 'Recent Apple').prototype,
                  _libraryTemplate(name: 'Recent Pear').prototype,
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await _pumpSearch(
      tester,
      subject: subject,
      query: 'APPLE',
      repository: FakeNutritionFoodRepository([
        _libraryTemplate(name: 'Library Apple'),
      ]),
    );

    final list = find.byType(ListView).first;
    Finder result(String name) =>
        find.descendant(of: list, matching: find.text(name));

    final recent = result('Recent Apple');
    final library = result('Library Apple');
    final database = result('External Apple');
    expect(recent, findsOneWidget);
    expect(library, findsOneWidget);
    expect(database, findsOneWidget);
    expect(find.text('Recent Pear'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Recently added'));
    await tester.pumpAndSettle();
    expect(recent, findsOneWidget);
    expect(library, findsNothing);
    expect(database, findsNothing);
    await tester.tap(recent);
    await tester.pumpAndSettle();
    expect(find.text('1 item · 80 kcal'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Library'));
    await tester.pumpAndSettle();
    expect(recent, findsNothing);
    expect(library, findsOneWidget);
    expect(database, findsNothing);
    await tester.tap(library);
    await tester.pumpAndSettle();
    expect(find.text('2 items · 160 kcal'), findsOneWidget);
    expect(find.byType(FoodEntryScreen), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Database'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(recent, findsNothing);
    expect(library, findsNothing);
    expect(database, findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'All'));
    await tester.pumpAndSettle();
    expect(recent, findsOneWidget);
    expect(library, findsOneWidget);
    await tester.scrollUntilVisible(
      database,
      80,
      scrollable: find.descendant(of: list, matching: find.byType(Scrollable)),
    );
    expect(database, findsOneWidget);
  });

  testWidgets('the whole result adds a serving and keeps the query', (
    tester,
  ) async {
    await _pumpSearch(tester);

    final result = find.text('External Apple');
    final card = find.ancestor(of: result, matching: find.byType(Card)).first;
    expect(find.widgetWithText(TextButton, 'Add'), findsNothing);
    await tester.tapAt(tester.getRect(card).centerRight.translate(-6, 0));
    await tester.pumpAndSettle();

    expect(find.byType(FoodEntryScreen), findsNothing);
    expect(find.text('1 item · 78 kcal'), findsOneWidget);
    await tester.tap(find.text('External Apple').first);
    await tester.pumpAndSettle();

    expect(find.text('1 item · 156 kcal'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: card,
        matching: find.byTooltip('Decrease External Apple'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 item · 78 kcal'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: card,
        matching: find.byTooltip('Increase External Apple'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FoodEntryScreen), findsNothing);
    expect(find.text('1 item · 156 kcal'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'apple',
    );
  });

  testWidgets('selector preserves underlying list state through navigation', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpLibrarySelection(tester, 20, selectedCount: 1);

    final library = find.byType(FoodLibrary);
    final libraryList = find.descendant(
      of: library,
      matching: find.byType(ListView),
    );
    final libraryScrollable = find
        .descendant(of: libraryList, matching: find.byType(Scrollable))
        .first;
    final listElement = libraryList.evaluate().single;
    final scrollableState = tester.state<ScrollableState>(libraryScrollable);
    final controller = tester.widget<ListView>(libraryList).controller!;
    final position = controller.position;
    final selectedTemplate = tester
        .widget<FoodLibraryItemCard>(
          find
              .descendant(
                of: library,
                matching: find.byType(FoodLibraryItemCard),
              )
              .first,
        )
        .template;
    expect(selectedTemplate.name, 'Library item 1');

    await tester.drag(libraryList, const Offset(0, -40));
    await tester.pumpAndSettle();
    final scrollOffset = position.pixels;
    expect(scrollOffset, greaterThan(0));

    void expectUnderlyingListPreserved() {
      expect(libraryList.evaluate().single, same(listElement));
      expect(
        tester.state<ScrollableState>(libraryScrollable),
        same(scrollableState),
      );
      expect(tester.widget<ListView>(libraryList).controller, same(controller));
      expect(controller.position, same(position));
      expect(position.pixels, closeTo(scrollOffset, 0.1));
      final libraryWidget = tester.widget<FoodLibrary>(library);
      expect(libraryWidget.isSelected!(selectedTemplate), isTrue);
      expect(libraryWidget.selectedQuantity!(selectedTemplate), 1);
    }

    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();

    final expandedList = find.byKey(const ValueKey('selection-expanded-list'));
    final selectedRow = find.descendant(
      of: expandedList,
      matching: find.text('Library item 1'),
    );
    expect(expandedList, findsOneWidget);
    expect(selectedRow, findsOneWidget);
    expectUnderlyingListPreserved();

    final overlayRect = tester.getRect(
      find.byKey(const ValueKey('selection-tray')),
    );
    final libraryCards = find.descendant(
      of: library,
      matching: find.byType(FoodLibraryItemCard),
    );
    Finder? coveredCard;
    for (final element in libraryCards.evaluate()) {
      final renderObject = element.renderObject;
      if (renderObject is! RenderBox || !renderObject.hasSize) continue;
      final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
      if (overlayRect.contains(rect.center)) {
        coveredCard = find.byElementPredicate(
          (candidate) => identical(candidate, element),
        );
        break;
      }
    }
    expect(coveredCard, isNotNull);
    expect(coveredCard!.hitTestable(), findsNothing);

    await tester.tap(_basketEdit(expandedList));
    await tester.pumpAndSettle();
    expect(find.byType(FoodEntryScreen), findsOneWidget);
    expect(libraryList, findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(expandedList, findsOneWidget);
    expectUnderlyingListPreserved();

    await tester.tap(find.byTooltip('Collapse selected items'));
    await tester.pumpAndSettle();
    expect(expandedList, findsNothing);
    expectUnderlyingListPreserved();
  });

  testWidgets('basket opens the full food editor and can discard changes', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpSearch(tester);
    await _addExternalApple(tester);

    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();
    final expandedList = find.byKey(const ValueKey('selection-expanded-list'));
    final tuneAction = find.descendant(
      of: expandedList,
      matching: find.byTooltip('Edit food'),
    );

    await tester.tap(
      find.descendant(of: expandedList, matching: find.text('External Apple')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FoodEntryScreen), findsNothing);

    await tester.tap(tuneAction);
    await tester.pumpAndSettle();
    expect(find.text('Edit food'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(expandedList, findsNothing);
    await tester.enterText(_amountField(), '3');

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();
    expect(expandedList, findsOneWidget);
    expect(find.text('1 item · 78 kcal'), findsOneWidget);
  });

  testWidgets('saved servings normalize into quantity before increment', (
    tester,
  ) async {
    FoodSearchSelection? selection;
    await _pumpSearch(tester, onResult: (value) => selection = value);

    await _addExternalApple(tester);
    await tester.tap(_basketEdit());
    await tester.pumpAndSettle();
    await tester.enterText(_amountField(), '2');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('selection-tray')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('selection-tray')),
        matching: find.byTooltip('Increase External Apple'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('selection-tray')),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Add 1 item to Lunch'));
    await tester.pumpAndSettle();

    final food = selection!.foods.single;
    expect(food.amount, 3);
    expect(food.servingSizeGrams, 150);
    expect(food.nutrition.energyKcal, 234);
  });

  testWidgets('details stay bounded and confirmable above keyboard', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpSearch(tester);

    await _addExternalApple(tester);
    await tester.tap(_basketEdit());
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.tap(_amountField());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Save').hitTestable(), findsOneWidget);
  });

  testWidgets('full editor changes serving weight at large text sizes', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpSearch(tester, textScaler: const TextScaler.linear(1.5));

    await _addExternalApple(tester);
    await tester.tap(_basketEdit());
    await tester.pumpAndSettle();
    await tester.enterText(_weightField(), '120');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('120 g'), findsWidgets);

    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();

    await tester.tap(_basketEdit());
    await tester.pumpAndSettle();
    await tester.ensureVisible(_weightField());
    await tester.enterText(_weightField(), '150');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('150 g'), findsWidgets);
  });

  testWidgets('header semantics expose expand and collapse actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpSearch(tester);
    await _addExternalApple(tester);

    final header = find.semantics.byLabel(RegExp('Selected items'));
    expect(
      header,
      isSemantics(
        hasTapAction: true,
        hasExpandedState: true,
        isExpanded: false,
      ),
    );
    expect(header.evaluate().single.label, isNot(contains('serving')));

    tester.semantics.tap(header);
    await tester.pumpAndSettle();
    expect(
      header,
      isSemantics(hasTapAction: true, hasExpandedState: true, isExpanded: true),
    );

    tester.semantics.tap(header);
    await tester.pumpAndSettle();
    expect(header, isSemantics(hasExpandedState: true, isExpanded: false));
    semantics.dispose();
  });

  testWidgets('accessibility stays active while search and basket change', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpSearch(tester);
    await _addExternalApple(tester);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(
      location: tester.getCenter(
        find.byTooltip('Increase External Apple').last,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final header = find.semantics.byLabel(RegExp('Selected items'));
    final tray = find.byKey(const ValueKey('selection-tray'));
    final trayElement = tray.evaluate().single;
    tester.semantics.tap(header);
    await tester.pumpAndSettle();
    expect(tray.evaluate().single, same(trayElement));
    await tester.tap(_basketEdit());
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    tester.semantics.tap(header);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Clear text'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(header, findsOneWidget);
    expect(tray.evaluate().single, same(trayElement));
    expect(tester.takeException(), isNull);
    await mouse.removePointer();
    semantics.dispose();
  });

  testWidgets('header semantics describe unavailable calories', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpSearch(
      tester,
      externalFood: _externalFood(caloriesKnown: false),
    );
    await _addExternalApple(tester);

    final label = find.semantics
        .byLabel(RegExp('Selected items'))
        .evaluate()
        .single
        .label;
    expect(label, contains('— kcal · 1 unavailable'));
    expect(label, contains('Calories unavailable for one item'));
    semantics.dispose();
  });

  testWidgets('German header uses Lebensmittel count', (tester) async {
    await _pumpSearch(tester, locale: const Locale('de'));
    await tester.tap(find.text('External Apple'));
    await tester.pumpAndSettle();

    expect(find.text('Ausgewählte Lebensmittel'), findsOneWidget);
    expect(find.text('1 Lebensmittel · 78 kcal'), findsOneWidget);
  });

  testWidgets('short expanded surface sizes to content', (tester) async {
    _setSurfaceSize(tester);
    await _pumpLibrarySelection(tester, 1);

    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();
    final shortHeight = tester
        .getSize(find.byKey(const ValueKey('selection-tray')))
        .height;
    expect(shortHeight, lessThan(640 * 0.75));
    expect(
      find.widgetWithText(FilledButton, 'Add 1 item to Lunch').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('long expanded surface caps, scrolls, and pins confirmation', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpLibrarySelection(tester, 8);
    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();

    final longHeight = tester
        .getSize(find.byKey(const ValueKey('selection-tray')))
        .height;
    final list = tester.widget<ListView>(
      find.byKey(const ValueKey('selection-expanded-list')),
    );
    expect(longHeight, lessThanOrEqualTo(640 * 0.75));
    expect(list.controller!.position.maxScrollExtent, greaterThan(0));
    expect(
      find.widgetWithText(FilledButton, 'Add 8 items to Lunch').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('expanded tray stays usable above keyboard with large text', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpLibrarySelection(
      tester,
      8,
      textScaler: const TextScaler.linear(1.5),
    );
    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.widgetWithText(FilledButton, 'Add 8 items to Lunch').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('saving an edit preserves the expanded basket scroll position', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpLibrarySelection(tester, 8);
    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();

    final listFinder = find.byKey(const ValueKey('selection-expanded-list'));
    await tester.drag(listFinder, const Offset(0, -240));
    await tester.pumpAndSettle();
    final before = tester.widget<ListView>(listFinder).controller!.offset;
    expect(before, greaterThan(0));
    await tester.tap(_basketEdit(listFinder).hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('Edit food'), findsOneWidget);
    await tester.enterText(_amountField(), '2');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final after = tester.widget<ListView>(listFinder).controller!.offset;
    expect(after, closeTo(before, 0.1));
    expect(find.text('8 items · 720 kcal'), findsOneWidget);
  });

  testWidgets('compact basket scrolls through all selected items', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpLibrarySelection(tester, 4);

    final basket = find.byKey(const ValueKey('selection-tray'));
    final list = find.descendant(of: basket, matching: find.byType(Scrollable));
    final lastItem = find.descendant(
      of: basket,
      matching: find.text('Library item 4'),
    );
    await tester.scrollUntilVisible(lastItem, 50, scrollable: list);
    await tester.pumpAndSettle();
    expect(lastItem.hitTestable(), findsOneWidget);
  });

  testWidgets('removing final expanded item requires confirmation', (
    tester,
  ) async {
    await _pumpSearch(tester);
    await _addExternalApple(tester);
    expect(find.widgetWithText(TextButton, 'Add'), findsNothing);

    await tester.tap(find.byTooltip('Increase External Apple').first);
    await tester.pumpAndSettle();
    expect(find.text('1 item · 156 kcal'), findsOneWidget);

    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();
    final decrease = find.descendant(
      of: find.byKey(const ValueKey('selection-expanded-list')),
      matching: find.byTooltip('Decrease External Apple'),
    );
    await tester.tap(decrease);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('1 item · 78 kcal'), findsOneWidget);

    await tester.tap(decrease);
    await tester.pumpAndSettle();
    expect(find.text('Remove External Apple?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('1 item · 78 kcal'), findsOneWidget);

    await tester.tap(decrease);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();

    expect(find.text('Selected items'), findsNothing);
    expect(find.text('External Apple').hitTestable(), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Add 0 items to Lunch'),
      findsNothing,
    );
    expect(find.byType(FoodEntryScreen), findsNothing);
  });

  testWidgets('system back returns details to expanded then compact', (
    tester,
  ) async {
    await _pumpSearch(tester);
    await _addExternalApple(tester);

    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();
    await tester.tap(_basketEdit());
    await tester.pumpAndSettle();
    expect(find.byType(FoodEntryScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(FoodEntryScreen), findsNothing);
    expect(
      find.byKey(const ValueKey('selection-expanded-list')),
      findsOneWidget,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('selection-expanded-list')), findsNothing);
    expect(find.text('Selected items'), findsOneWidget);
  });

  testWidgets('confirmation returns final FoodSearchSelection route result', (
    tester,
  ) async {
    FoodSearchSelection? selection;
    await _pumpSearch(tester, onResult: (value) => selection = value);

    await _addExternalApple(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Add 1 item to Lunch'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodSearchScreen), findsNothing);
    expect(selection?.foods.single.name, 'External Apple');
    expect(selection?.foods.single.amount, 1);
  });

  testWidgets('Library row adds directly to the basket', (tester) async {
    final repository = FakeNutritionFoodRepository([_libraryTemplate()]);
    await _pumpSearch(tester, repository: repository, query: null);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library Pear'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodEntryScreen), findsNothing);
    expect(find.text('Selected items'), findsOneWidget);
    expect(repository.loadCalls, 1);
  });
}

Finder _basketEdit([Finder? basket]) => find.descendant(
  of: basket ?? find.byKey(const ValueKey('selection-tray')),
  matching: find.byTooltip('Edit food'),
);

Finder _amountField() => find.widgetWithText(TextFormField, 'Servings *');

Finder _weightField() =>
    find.widgetWithText(TextFormField, 'Nutrition values are for');

void _setSurfaceSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<void> _addExternalApple(WidgetTester tester) async {
  await tester.tap(find.text('External Apple'));
  await tester.pumpAndSettle();
}

Future<void> _pumpLibrarySelection(
  WidgetTester tester,
  int count, {
  TextScaler? textScaler,
  int? selectedCount,
}) async {
  final repository = FakeNutritionFoodRepository([
    for (var index = 1; index <= count; index++)
      _libraryTemplate(id: 'library-item-$index', name: 'Library item $index'),
  ]);
  await _pumpSearch(
    tester,
    repository: repository,
    query: null,
    textScaler: textScaler,
  );
  final myLibrary = find.text('Library');
  await tester.ensureVisible(myLibrary);
  await tester.tap(myLibrary);
  await tester.pumpAndSettle();
  final library = find.byType(FoodLibrary);
  final libraryList = find.descendant(
    of: library,
    matching: find.byType(ListView),
  );
  final scrollable = find.descendant(
    of: libraryList,
    matching: find.byType(Scrollable),
  );
  for (var index = 0; index < (selectedCount ?? count); index++) {
    final item = find.descendant(
      of: library,
      matching: find.text('Library item ${index + 1}'),
    );
    await tester.scrollUntilVisible(
      item.hitTestable(),
      40,
      scrollable: scrollable,
    );
    await tester.tap(item);
    await tester.pumpAndSettle();
  }
}

Future<void> _pumpSearch(
  WidgetTester tester, {
  String? query = 'apple',
  studyu.StudySubject? subject,
  TextScaler? textScaler,
  FakeNutritionFoodRepository? repository,
  ValueChanged<FoodSearchSelection?>? onResult,
  Locale locale = const Locale('en'),
  UsdaFoodItem? externalFood,
}) async {
  Future<SearchResult> openFoodFactsSearch({
    required String query,
    required int page,
    required int pageSize,
  }) async => const SearchResult(products: []);
  Future<UsdaSearchResponse> usdaFoodSearch({
    required String query,
    required int page,
    required int pageSize,
  }) async => UsdaSearchResponse(
    totalHits: 1,
    currentPage: page,
    totalPages: 1,
    foods: [externalFood ?? _externalFood()],
  );

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AppState()..activeSubject = subject,
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: locale,
        builder: textScaler == null
            ? null
            : (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                child: child!,
              ),
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                final result = await FoodSearchScreen.show(
                  context,
                  mealLabel: 'Lunch',
                  usdaFoodSearch: usdaFoodSearch,
                  openFoodFactsSearch: openFoodFactsSearch,
                  repository: repository ?? FakeNutritionFoodRepository(),
                );
                onResult?.call(result);
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
  if (query case final query?) {
    await tester.enterText(find.byType(TextField), query);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }
}

UsdaFoodItem _externalFood({bool caloriesKnown = true}) => UsdaFoodItem(
  fdcId: 101,
  description: 'External Apple',
  brandOwner: 'Example Foods',
  gtinUpc: '012345678901',
  servingSize: 150,
  servingSizeUnit: 'g',
  householdServingFullText: '1 medium apple',
  foodNutrients: caloriesKnown
      ? [UsdaFoodNutrient(nutrientId: 1008, value: 52)]
      : [],
);

studyu.SavedFoodTemplate _libraryTemplate({
  String id = 'library-pear-template',
  String name = 'Library Pear',
}) => studyu.SavedFoodTemplate(
  id: id,
  userId: 'anonymous',
  name: name,
  isPublic: false,
  createdAt: DateTime.utc(2024),
  prototype: studyu.FoodEntry.withId(
    entryType: studyu.FoodEntryType.singleIngredient,
    name: name,
    amount: 1,
    unit: 'serving',
    servingSizeGrams: 120,
    portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
    portionState: studyu.PortionState.asServed,
    nutrition: studyu.NutritionProfile(
      energyKcal: 80,
      protein: 1,
      carbs: 20,
      fat: 0,
      sugars: 12,
      fiber: 4,
      saturatedFat: 0,
      transFat: 0,
      cholesterol: 0,
      sodium: 0,
      waterContent: 0,
      micros: const {},
    ),
    source: studyu.FoodSource.manual,
    confidenceScore: 1,
    originalValues: const {},
  ),
);
