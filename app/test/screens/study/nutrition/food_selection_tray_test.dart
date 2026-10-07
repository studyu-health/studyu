import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/food_library.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_core/core.dart' as studyu;

import 'fake_nutrition_food_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('new result opens details, then add reveals compact tray', (
    tester,
  ) async {
    await _pumpSearch(tester);

    await tester.tap(find.text('External Apple'));
    await tester.pumpAndSettle();

    expect(find.text('Edit amount'), findsOneWidget);
    expect(find.byKey(const ValueKey('food-quantity-back')), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Add item'), findsOneWidget);
    expect(
      tester
          .widget<FoodQuantitySheet>(find.byType(FoodQuantitySheet))
          .food
          .portionReference,
      '1 medium apple',
    );
    expect(find.textContaining('1 medium apple'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodQuantitySheet), findsNothing);
    expect(find.text('Selected items'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Add 1 item to Lunch'),
      findsOneWidget,
    );
  });

  testWidgets('back from empty details hides tray but keeps it ready', (
    tester,
  ) async {
    await _pumpSearch(tester);

    await tester.tap(find.text('External Apple'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Add item'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('food-quantity-back')));
    await tester.pumpAndSettle();

    expect(find.byType(FoodQuantitySheet), findsNothing);
    expect(find.text('Selected items'), findsNothing);

    await tester.tap(find.text('External Apple'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Add item'), findsOneWidget);
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
    final libraryAddActions = find.descendant(
      of: library,
      matching: find.widgetWithText(TextButton, 'Add'),
    );
    Finder? coveredAddAction;
    for (final element in libraryAddActions.evaluate()) {
      final renderObject = element.renderObject;
      if (renderObject is! RenderBox || !renderObject.hasSize) continue;
      final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
      if (overlayRect.contains(rect.center)) {
        coveredAddAction = find.byElementPredicate(
          (candidate) => identical(candidate, element),
        );
        break;
      }
    }
    expect(coveredAddAction, isNotNull);
    expect(coveredAddAction!.hitTestable(), findsNothing);

    await tester.tap(selectedRow);
    await tester.pumpAndSettle();
    expect(find.byType(FoodQuantitySheet), findsOneWidget);
    expectUnderlyingListPreserved();

    await tester.tap(find.byKey(const ValueKey('food-quantity-back')));
    await tester.pumpAndSettle();
    expect(expandedList, findsOneWidget);
    expectUnderlyingListPreserved();

    await tester.tap(find.byTooltip('Collapse selected items'));
    await tester.pumpAndSettle();
    expect(expandedList, findsNothing);
    expectUnderlyingListPreserved();
  });

  testWidgets('selected item details navigate inside one surface', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpSearch(tester);
    await _addExternalApple(tester);

    final searchRouteCount = find.byType(FoodSearchScreen).evaluate().length;
    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete External Apple'), findsOneWidget);
    expect(find.byKey(const ValueKey('selection-drag-handle')), findsOneWidget);
    expect(find.byType(FoodSearchScreen), findsNWidgets(searchRouteCount));

    await tester.tap(find.text('External Apple').last);
    await tester.pumpAndSettle();
    expect(find.text('Edit amount'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save changes'), findsOneWidget);
    expect(find.byKey(const ValueKey('selection-drag-handle')), findsNothing);
    expect(
      find.descendant(
        of: find.byType(FoodQuantitySheet),
        matching: find.byIcon(Icons.close),
      ),
      findsNothing,
    );
    expect(find.textContaining('1 medium apple'), findsOneWidget);
    expect(find.textContaining('150 g per serving'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('food-quantity-back')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete External Apple'), findsOneWidget);
    expect(find.byType(FoodSearchScreen), findsNWidgets(searchRouteCount));

    await tester.tap(find.byTooltip('Collapse selected items'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete External Apple'), findsNothing);
  });

  testWidgets('detail servings normalize into quantity before increment', (
    tester,
  ) async {
    FoodSearchSelection? selection;
    await _pumpSearch(tester, onResult: (value) => selection = value);

    await tester.tap(find.text('External Apple'));
    await tester.pumpAndSettle();
    await tester.enterText(_amountField(), '2');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
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

    await tester.tap(find.text('External Apple'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.tap(_amountField());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.widgetWithText(FilledButton, 'Add item').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('custom weight fits narrow rows and resets to source baseline', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpSearch(tester, textScaler: const TextScaler.linear(1.5));

    await _addExternalApple(tester);
    await tester.tap(find.text('External Apple').last);
    await tester.pumpAndSettle();
    await tester.enterText(_weightField(), '120');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(find.textContaining('120 g'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete External Apple'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('External Apple').last);
    await tester.pumpAndSettle();
    final reset = find.text('Use default weight (150 g)');
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(find.textContaining('150 g'), findsWidgets);
    expect(tester.takeException(), isNull);
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
    await tester.tap(
      find.widgetWithText(FilledButton, 'Lebensmittel hinzufügen'),
    );
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

  testWidgets('expanded list keeps scroll position across details', (
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
    final visibleItem = find
        .descendant(
          of: listFinder,
          matching: find.textContaining('Library item'),
        )
        .hitTestable()
        .first;

    await tester.tap(visibleItem);
    await tester.pumpAndSettle();
    expect(find.text('Edit amount'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('food-quantity-back')));
    await tester.pumpAndSettle();

    final after = tester.widget<ListView>(listFinder).controller!.offset;
    expect(after, closeTo(before, 0.1));
    expect(find.byIcon(Icons.delete_outline), findsWidgets);
  });

  testWidgets('compact tray offers View all with total count', (tester) async {
    _setSurfaceSize(tester);
    await _pumpLibrarySelection(tester, 4);

    expect(find.text('View all 4 items'), findsOneWidget);
    await tester.tap(find.text('View all 4 items'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete Library item 4'), findsOneWidget);
  });

  testWidgets('deleting final expanded item hides selection surface', (
    tester,
  ) async {
    await _pumpSearch(tester);
    await _addExternalApple(tester);

    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete External Apple'));
    await tester.pumpAndSettle();

    expect(find.text('Selected items'), findsNothing);
    expect(find.byTooltip('Delete External Apple'), findsNothing);
    expect(
      find.widgetWithText(FilledButton, 'Add 0 items to Lunch'),
      findsNothing,
    );
    expect(find.byType(FoodQuantitySheet), findsNothing);
  });

  testWidgets('system back returns details to expanded then compact', (
    tester,
  ) async {
    await _pumpSearch(tester);
    await _addExternalApple(tester);

    await tester.tap(find.text('Selected items'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('External Apple').last);
    await tester.pumpAndSettle();
    expect(find.byType(FoodQuantitySheet), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(FoodQuantitySheet), findsNothing);
    expect(find.byTooltip('Delete External Apple'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete External Apple'), findsNothing);
    expect(find.text('Selected items'), findsOneWidget);
  });

  testWidgets('confirmation returns final FoodSearchSelection route result', (
    tester,
  ) async {
    FoodSearchSelection? selection;
    await _pumpSearch(tester, onResult: (value) => selection = value);

    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add 1 item to Lunch'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodSearchScreen), findsNothing);
    expect(selection?.foods.single.name, 'External Apple');
    expect(selection?.foods.single.amount, 1);
  });

  testWidgets('My library item uses unified details and selection surface', (
    tester,
  ) async {
    final repository = FakeNutritionFoodRepository([_libraryTemplate()]);
    await _pumpSearch(tester, repository: repository, query: null);

    await tester.tap(find.text('My library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library Pear'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Add item'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodQuantitySheet), findsNothing);
    expect(find.text('Selected items'), findsOneWidget);
    expect(repository.loadCalls, 1);
  });
}

Finder _amountField() => find
    .descendant(
      of: find.byType(FoodQuantitySheet),
      matching: find.byType(TextField),
    )
    .first;

Finder _weightField() =>
    find.byKey(const ValueKey('food-quantity-weight-field'));

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
  await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
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
  final myLibrary = find.text('My library');
  await tester.ensureVisible(myLibrary);
  await tester.tap(myLibrary);
  await tester.pumpAndSettle();
  for (var index = 0; index < (selectedCount ?? count); index++) {
    final add = find.text('Add').first;
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();
  }
}

Future<void> _pumpSearch(
  WidgetTester tester, {
  String? query = 'apple',
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
      create: (_) => AppState(),
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
