import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/food_library.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('local and external matches appear together', (tester) async {
    final local = _food('local', 'Local Apple');
    final repository = _ExternalLibraryRepository([_template(local)]);
    final search = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => const SearchResult(products: []),
      usdaFoodSearch:
          ({required query, required page, required pageSize}) async =>
              UsdaSearchResponse(
                totalHits: 1,
                currentPage: page,
                totalPages: 1,
                foods: [_externalFood()],
              ),
    );
    final viewModel = TemplateViewModel(
      userId: 'subject',
      repository: repository,
    );
    addTearDown(viewModel.dispose);
    addTearDown(search.dispose);

    await _pumpExternalLibrary(tester, viewModel: viewModel, search: search);
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump();

    expect(find.text('Local Apple'), findsOneWidget);
    expect(find.text('External Apple'), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Local Apple'), findsOneWidget);
    expect(find.text('External Apple'), findsOneWidget);
  });

  testWidgets('external results stay visible when local results are empty', (
    tester,
  ) async {
    final repository = _ExternalLibraryRepository(const []);
    final search = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => const SearchResult(products: []),
      usdaFoodSearch:
          ({required query, required page, required pageSize}) async =>
              UsdaSearchResponse(
                totalHits: 1,
                currentPage: page,
                totalPages: 1,
                foods: [_externalFood()],
              ),
    );
    final viewModel = TemplateViewModel(
      userId: 'subject',
      repository: repository,
    );
    addTearDown(viewModel.dispose);
    addTearDown(search.dispose);

    await _pumpExternalLibrary(tester, viewModel: viewModel, search: search);
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('External library'), findsOneWidget);
    expect(find.text('External Apple'), findsOneWidget);
  });

  testWidgets('external failure leaves local matches usable', (tester) async {
    final local = _food('local', 'Local Apple');
    final repository = _ExternalLibraryRepository([_template(local)]);
    final search = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => throw StateError('offline'),
      usdaFoodSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => throw StateError('offline'),
    );
    final viewModel = TemplateViewModel(
      userId: 'subject',
      repository: repository,
    );
    addTearDown(viewModel.dispose);
    addTearDown(search.dispose);

    await _pumpExternalLibrary(tester, viewModel: viewModel, search: search);
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Local Apple'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('external cards expose Copy without local management actions', (
    tester,
  ) async {
    final repository = _ExternalLibraryRepository(const []);
    final search = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => const SearchResult(products: []),
      usdaFoodSearch:
          ({required query, required page, required pageSize}) async =>
              UsdaSearchResponse(
                totalHits: 1,
                currentPage: page,
                totalPages: 1,
                foods: [_externalFood()],
              ),
    );
    final viewModel = TemplateViewModel(
      userId: 'subject',
      repository: repository,
    );
    addTearDown(viewModel.dispose);
    addTearDown(search.dispose);

    await _pumpExternalLibrary(tester, viewModel: viewModel, search: search);
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Import'), findsOneWidget);
    expect(find.byType(PopupMenuButton), findsNothing);
  });

  testWidgets('Meals filter invalidates pending external results', (
    tester,
  ) async {
    final response = Completer<UsdaSearchResponse>();
    var requests = 0;
    final meal = _food('meal', 'Fruit bowl')..entryType = FoodEntryType.meal;
    final repository = _ExternalLibraryRepository([_template(meal)]);
    final search = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => const SearchResult(products: []),
      usdaFoodSearch: ({required query, required page, required pageSize}) {
        requests++;
        return response.future;
      },
    );
    final viewModel = TemplateViewModel(
      userId: 'subject',
      repository: repository,
    );
    addTearDown(viewModel.dispose);
    addTearDown(search.dispose);

    await _pumpExternalLibrary(tester, viewModel: viewModel, search: search);
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(const Duration(milliseconds: 500));
    expect(requests, 1);

    await tester.tap(
      find.widgetWithText(FilterChip, l10n.nutrition_saved_meals_filter),
    );
    await tester.pump();
    response.complete(
      UsdaSearchResponse(
        totalHits: 1,
        currentPage: 1,
        totalPages: 1,
        foods: [_externalFood()],
      ),
    );
    await tester.pumpAndSettle();

    expect(search.results, isEmpty);
    expect(find.text('External Apple'), findsNothing);
  });

  testWidgets('canceling external copy does not save a template', (
    tester,
  ) async {
    final repository = _ExternalLibraryRepository(const []);
    final search = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => const SearchResult(products: []),
      usdaFoodSearch:
          ({required query, required page, required pageSize}) async =>
              UsdaSearchResponse(
                totalHits: 1,
                currentPage: page,
                totalPages: 1,
                foods: [_externalFood()],
              ),
    );
    final viewModel = TemplateViewModel(
      userId: 'subject',
      repository: repository,
    );
    final appState = AppState();
    addTearDown(viewModel.dispose);
    addTearDown(search.dispose);

    await _pumpExternalLibrary(
      tester,
      viewModel: viewModel,
      search: search,
      appState: appState,
    );
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    expect(find.text('Review food'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(repository.saveCount, 0);
  });

  testWidgets('saving external copy persists once with provenance', (
    tester,
  ) async {
    final repository = _ExternalLibraryRepository(const []);
    final search = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => const SearchResult(products: []),
      usdaFoodSearch:
          ({required query, required page, required pageSize}) async =>
              UsdaSearchResponse(
                totalHits: 1,
                currentPage: page,
                totalPages: 1,
                foods: [_externalFood()],
              ),
    );
    final viewModel = TemplateViewModel(
      userId: 'subject',
      repository: repository,
    );
    final appState = AppState();
    addTearDown(viewModel.dispose);
    addTearDown(search.dispose);

    await _pumpExternalLibrary(
      tester,
      viewModel: viewModel,
      search: search,
      appState: appState,
    );
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save to My library'));
    await tester.pumpAndSettle();

    expect(repository.saveCount, 1);
    expect(repository.saved, isNotNull);
    expect(repository.saved!.foodCode, '012345678901');
    expect(repository.saved!.externalId, '101');
    expect(repository.saved!.source, FoodSource.usda);
    expect(repository.saved!.originalValues, isNotEmpty);
  });

  testWidgets('save failure can retry the same edited draft', (tester) async {
    final repository = _ExternalLibraryRepository(const [])
      ..failuresRemaining = 1;
    final search = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => const SearchResult(products: []),
      usdaFoodSearch:
          ({required query, required page, required pageSize}) async =>
              UsdaSearchResponse(
                totalHits: 1,
                currentPage: page,
                totalPages: 1,
                foods: [_externalFood()],
              ),
    );
    final viewModel = TemplateViewModel(
      userId: 'subject',
      repository: repository,
    );
    final appState = AppState();
    addTearDown(viewModel.dispose);
    addTearDown(search.dispose);

    await _pumpExternalLibrary(
      tester,
      viewModel: viewModel,
      search: search,
      appState: appState,
    );
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save to My library'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
    await tester.pumpAndSettle();

    expect(repository.saveAttempts, 2);
    expect(repository.saveCount, 1);
    expect(repository.saved, isNotNull);
  });

  testWidgets('saved meal add exposes quantity controls', (tester) async {
    final meal = _food('meal', 'Fruit bowl')..entryType = FoodEntryType.meal;
    final template = _template(meal);
    var selected = false;
    var quantity = 1;
    Offset? addSource;

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => FoodLibraryItemCard(
              template: template,
              onAdd: (_, source) => setState(() {
                addSource = source;
                selected = true;
              }),
              isSelected: selected,
              selectedQuantity: quantity,
              onIncrement: (_) => setState(() => quantity++),
              onDecrement: () => setState(() => selected = false),
              showManagementActions: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Add'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.byTooltip('Increase Fruit bowl'), findsOneWidget);
    expect(find.byTooltip('Decrease Fruit bowl'), findsOneWidget);
    expect(addSource, isNotNull);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase Fruit bowl'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Decrease Fruit bowl'));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('details tap stays separate from selected quantity controls', (
    tester,
  ) async {
    final template = _template(_food('apple', 'Apple'));
    var detailsTaps = 0;
    var quantity = 1;

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: Scaffold(
          body: FoodLibraryItemCard(
            template: template,
            isSelected: true,
            selectedQuantity: quantity,
            onTap: (_) => detailsTaps++,
            onIncrement: (_) => quantity++,
            onDecrement: () {},
            showManagementActions: false,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Apple'));
    await tester.pump();
    expect(detailsTaps, 1);

    await tester.tap(find.byTooltip('Increase Apple'));
    await tester.pump();
    expect(detailsTaps, 1);
    expect(quantity, 2);
    await tester.pump(const Duration(milliseconds: 150));
  });

  testWidgets('saved meal edit updates name and ordered composition', (
    tester,
  ) async {
    final component = _food('component', 'Apple');
    final meal = _food('meal', 'Fruit bowl')
      ..entryType = FoodEntryType.meal
      ..componentFoods = [
        FoodComposition(
          id: 'composition',
          parentEntryId: 'meal-entry',
          foodId: component.foodId,
          amount: 1,
          unit: 'serving',
          sortOrder: 0,
        ),
      ]
      ..componentSnapshots = [component];
    final template = SavedFoodTemplate(
      id: meal.foodId,
      userId: 'subject',
      name: meal.name,
      isPublic: false,
      createdAt: DateTime.utc(2026, 7, 15),
      prototype: meal,
    );
    final repository = _LibraryRepository(template);
    final viewModel = TemplateViewModel(
      userId: 'subject',
      repository: repository,
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: viewModel,
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: Scaffold(body: FoodLibraryItemCard(template: template)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fruit bowl'));
    await tester.pumpAndSettle();

    expect(find.byType(MealCreatorScreen), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.template_name_required),
      'Updated bowl',
    );
    await tester.tap(find.byTooltip('Edit amount'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Amount'), '2');
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(repository.saved, isNotNull);
    expect(repository.saved!.foodId, 'meal-definition');
    expect(repository.saved!.name, 'Updated bowl');
    expect(repository.saved!.componentFoods!.single.amount, 2);
    expect(repository.saved!.componentFoods!.single.sortOrder, 0);
    expect(
      repository.saved!.componentSnapshots!.single.foodId,
      'component-definition',
    );
    expect(repository.saved!.componentSnapshots!.single.amount, 2);
    expect(repository.expectedVersionId, 'meal-version');
  });
}

Future<void> _pumpExternalLibrary(
  WidgetTester tester, {
  required TemplateViewModel viewModel,
  required FoodSearchViewModel search,
  AppState? appState,
}) async {
  final providers = <SingleChildWidget>[
    ChangeNotifierProvider.value(value: viewModel),
    if (appState != null) ChangeNotifierProvider.value(value: appState),
  ];
  await tester.pumpWidget(
    MultiProvider(
      providers: providers,
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: Scaffold(
          body: FoodLibrary(
            includeExternalLibrary: true,
            externalSearchViewModel: search,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SavedFoodTemplate _template(FoodEntry food) => SavedFoodTemplate(
  id: food.foodId,
  userId: 'subject',
  name: food.name,
  isPublic: false,
  createdAt: DateTime.utc(2026, 7, 15),
  prototype: food,
);

UsdaFoodItem _externalFood() => UsdaFoodItem(
  fdcId: 101,
  description: 'External Apple',
  brandOwner: 'Example Foods',
  gtinUpc: '012345678901',
  servingSize: 150,
  servingSizeUnit: 'g',
  foodNutrients: [UsdaFoodNutrient(nutrientId: 1008, value: 52)],
);

class _ExternalLibraryRepository(final List<SavedFoodTemplate> templates)
    extends NutritionFoodRepository {
  FoodEntry? saved;
  int saveCount = 0;
  int saveAttempts = 0;
  int failuresRemaining = 0;

  @override
  Future<List<SavedFoodTemplate>> loadTemplates(String subjectId) async =>
      templates;

  @override
  Future<SavedFoodTemplate> saveTemplate({
    required String subjectId,
    required String name,
    required FoodEntry food,
    List<String>? tags,
    String? expectedVersionId,
  }) async {
    saveAttempts++;
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw StateError('save failed');
    }
    saveCount++;
    saved = FoodEntry.fromJson(food.toJson());
    return SavedFoodTemplate(
      id: food.foodId,
      userId: subjectId,
      name: name,
      isPublic: false,
      createdAt: DateTime.utc(2026, 7, 15),
      prototype: saved!,
    );
  }
}

class _LibraryRepository(final SavedFoodTemplate template)
    extends NutritionFoodRepository {
  FoodEntry? saved;
  String? expectedVersionId;

  @override
  Future<List<SavedFoodTemplate>> loadTemplates(String subjectId) async => [
    template,
  ];

  @override
  Future<SavedFoodTemplate> saveTemplate({
    required String subjectId,
    required String name,
    required FoodEntry food,
    List<String>? tags,
    String? expectedVersionId,
  }) async {
    saved = FoodEntry.fromJson(food.toJson());
    this.expectedVersionId = expectedVersionId;
    return SavedFoodTemplate(
      id: food.foodId,
      userId: subjectId,
      name: name,
      isPublic: false,
      createdAt: template.createdAt,
      prototype: saved!,
    );
  }
}

FoodEntry _food(String id, String name) => FoodEntry(
  id: '$id-entry',
  foodId: '$id-definition',
  foodVersionId: '$id-version',
  entryType: FoodEntryType.singleIngredient,
  name: name,
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 100,
    protein: 1,
    carbs: 1,
    fat: 1,
    sugars: 0,
    fiber: 0,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: const {},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15),
  originalValues: const {},
);
