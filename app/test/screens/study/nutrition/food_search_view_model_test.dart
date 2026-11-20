import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_core/core.dart' as studyu;

void main() {
  test(
    'USDA mapping preserves measured zero independently for each nutrient',
    () {
      final food = convertUsdaToFoodEntry(
        UsdaFoodItem(
          fdcId: 1,
          servingSize: 50,
          servingSizeUnit: 'g',
          foodNutrients: [
            UsdaFoodNutrient(nutrientId: 1008, value: 0),
            UsdaFoodNutrient(nutrientId: 2000, value: 0),
            UsdaFoodNutrient(nutrientId: 1257, value: 0),
            UsdaFoodNutrient(nutrientId: 1253, value: 0),
            UsdaFoodNutrient(nutrientId: 1051, value: 0),
            UsdaFoodNutrient(nutrientId: 1093, value: 20),
          ],
        ),
      );
      for (final key in [
        'energyKcal',
        'sugars',
        'transFat',
        'cholesterol',
        'waterContent',
        'sodium',
      ]) {
        expect(food.nutrition.isKnown(key), isTrue, reason: key);
      }
      for (final key in ['protein', 'carbs', 'fat', 'fiber', 'saturatedFat']) {
        expect(food.nutrition.isKnown(key), isFalse, reason: key);
      }
      expect(food.nutrition.sodium, 10);
      expect(
        studyu.FoodEntry.fromJson(food.toJson()).nutrition.unavailableNutrients,
        food.nutrition.unavailableNutrients,
      );
    },
  );

  test('USDA mapping uses a 100 g basis for a non-gram serving', () {
    final food = convertUsdaToFoodEntry(
      UsdaFoodItem(
        fdcId: 1,
        servingSize: 240,
        servingSizeUnit: 'ML',
        householdServingFullText: '1 cup (240 mL)',
        foodNutrients: [UsdaFoodNutrient(nutrientId: 1008, value: 125.5)],
      ),
    );
    expect(food.unit, 'serving');
    expect(food.servingSizeGrams, 100);
    expect(food.portionReference, isNull);
    expect(food.originalValues['householdServingFullText'], '1 cup (240 mL)');
    expect(food.nutrition.energyKcal, 125.5);
  });

  test(
    'USDA search and saved food use the energy reported for their data type',
    () {
      for (final (dataType, nutrients, expected) in [
        ('Foundation', {2047: 120.0}, 60.0),
        ('Foundation', {1008: 100.0, 2047: 120.0, 2048: 150.0}, 75.0),
        ('SR Legacy', {1008: 100.0, 2047: 120.0}, 50.0),
      ]) {
        final source = UsdaFoodItem(
          fdcId: 1,
          dataType: dataType,
          servingSize: 50,
          servingSizeUnit: 'g',
          foodNutrients: [
            for (final entry in nutrients.entries)
              UsdaFoodNutrient(nutrientId: entry.key, value: entry.value),
          ],
        );
        expect(usdaFoodSearchResult(source).calories, expected);
        final food = convertUsdaToFoodEntry(source);
        expect(food.nutrition.energyKcal, expected);
        expect(food.nutrition.isKnown('energyKcal'), isTrue);
      }
    },
  );

  test('OFF preview and conversion agree on comma-decimal servings', () async {
    final product = Product.fromJson({
      'code': '123',
      'product_name': 'Food',
      'serving_size': '1 portion (12,5 g)',
      'nutrition': {
        'aggregated_set': {
          'preparation': 'as_sold',
          'per': '100g',
          'nutrients': {
            'energy-kcal': {'unit': 'kcal', 'value': 200},
          },
        },
      },
    });
    final model = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => SearchResult(products: [product]),
      usdaConfigured: false,
    );
    addTearDown(model.dispose);
    await model.retry('Food');
    final result = model.results.single;
    final food = convertFoodResultToFoodEntry(result);

    expect(result.servingSizeGrams, 12.5);
    expect(food.servingSizeGrams, result.servingSizeGrams);
    expect(food.nutrition.energyKcal, result.calories);
  });

  test('OFF mapping preserves null versus zero and sodium units', () {
    final product = Product.fromJson({
      'code': '123',
      'product_name': 'Zero product',
      'serving_size': '50 g',
      'nutrition': {
        'aggregated_set': {
          'preparation': 'as_sold',
          'per': '100g',
          'nutrients': {
            'energy-kcal': {'unit': 'kcal', 'value': 0},
            'proteins': {'unit': 'g', 'value': 0},
            'sugars': {'unit': 'g', 'value': 0},
            'trans-fat': {'unit': 'g', 'value': 0},
            'cholesterol': {'unit': 'g', 'value': 0},
            'sodium': {'unit': 'g', 'value': 0.1},
          },
        },
      },
    });
    final food = convertOpenFoodFactsToFoodEntry(product);
    for (final key in [
      'energyKcal',
      'protein',
      'sugars',
      'transFat',
      'cholesterol',
      'sodium',
    ]) {
      expect(food.nutrition.isKnown(key), isTrue, reason: key);
    }
    for (final key in [
      'carbs',
      'fat',
      'fiber',
      'saturatedFat',
      'waterContent',
    ]) {
      expect(food.nutrition.isKnown(key), isFalse, reason: key);
    }
    expect(food.nutrition.sodium, 50);
    expect(food.nutrition.energyKcal, 0);
    expect(
      studyu.FoodEntry.fromJson(food.toJson()).nutrition.unavailableNutrients,
      food.nutrition.unavailableNutrients,
    );
  });

  test('OFF prefers as-sold mass data over a prepared or volume basis', () {
    final product = Product.fromJson({
      'product_name': 'Food',
      'serving_size': '25 g',
      'nutrition': {
        'aggregated_set': {
          'preparation': 'prepared',
          'per': '100g',
          'nutrients': {
            'energy-kcal': {'unit': 'kcal', 'value': 20},
          },
        },
        'input_sets': [
          {
            'preparation': 'as_sold',
            'per': '100ml',
            'nutrients': {
              'energy-kcal': {'unit': 'kcal', 'value': 14},
            },
          },
          {
            'preparation': 'as_sold',
            'per': 'serving',
            'per_quantity': 25,
            'per_unit': 'g',
            'nutrients': {
              'energy-kj': {'unit': 'kJ', 'value': 418.4},
              'sodium': {'unit': 'mg', 'value_computed': 80},
            },
          },
        ],
      },
    });

    final result = openFoodFactsSearchResult(product);
    final food = convertFoodResultToFoodEntry(result);

    expect(result.calories, closeTo(100, 0.0001));
    expect(food.nutrition.energyKcal, result.calories);
    expect(food.nutrition.sodium, 80);
    expect(food.nutrition.isKnown('sodium'), isTrue);
  });

  test('OFF volume-only data retains the source volume and calories', () {
    final product = Product.fromJson({
      'product_name': 'Drink',
      'serving_size': '200 mL',
      'nutrition': {
        'aggregated_set': {
          'preparation': 'as_sold',
          'per': '100ml',
          'nutrients': {
            'energy-kcal': {'unit': 'kcal', 'value': 50},
          },
        },
      },
    });

    final result = openFoodFactsSearchResult(product);
    final food = convertFoodResultToFoodEntry(result);

    expect(result.calories, 100);
    expect(result.servingVolumeLabel, '200 mL');
    expect(result.calorieBasisGrams, isNull);
    expect(food.servingSizeGrams, 0);
    expect(food.portionReference, '200 mL');
    expect(food.nutrition.energyKcal, 100);
    expect(food.nutrition.isKnown('energyKcal'), isTrue);
    expect(food.originalValues['nutrition'], isNotNull);
  });

  test('OFF source serving basis works without a free-text label', () {
    final product = Product.fromJson({
      'product_name': 'Drink',
      'nutrition': {
        'aggregated_set': {
          'preparation': 'as_sold',
          'per': 'serving',
          'per_unit': 'ml',
          'per_quantity': 330,
          'nutrients': {
            'energy-kcal': {'unit': 'kcal', 'value': 80},
          },
        },
      },
    });

    final food = convertOpenFoodFactsToFoodEntry(product);
    expect(food.portionReference, '330 mL');
    expect(food.servingSizeGrams, 0);
    expect(food.nutrition.energyKcal, 80);
  });

  test('OFF preserves nutrient limits without treating them as exact', () {
    final product = Product.fromJson({
      'product_name': 'Food',
      'nutrition': {
        'aggregated_set': {
          'preparation': 'as_sold',
          'per': '100g',
          'nutrients': {
            'fat': {'unit': 'g', 'value': 0.5, 'modifier': '<'},
            'sugars': {'unit': 'g', 'value': 0},
          },
        },
      },
    });

    final food = convertOpenFoodFactsToFoodEntry(product);
    expect(food.nutrition.isKnown('fat'), isFalse);
    expect(food.nutrition.isKnown('sugars'), isTrue);
    final nutrition = food.originalValues['nutrition'] as Map<String, dynamic>;
    final source = nutrition['aggregated_set'] as Map<String, dynamic>;
    final nutrients = source['nutrients'] as Map<String, dynamic>;
    final fat = nutrients['fat'] as Map<String, dynamic>;
    expect(fat['modifier'], '<');
  });

  for (final slowOff in [true, false]) {
    for (final pagination in [false, true]) {
      testWidgets('${slowOff ? 'OFF' : 'USDA'} timeout preserves results on '
          '${pagination ? 'pagination' : 'first page'}', (tester) async {
        final offResponse = Completer<SearchResult>();
        final usdaResponse = Completer<UsdaSearchResponse>();
        final slowPage = pagination ? 2 : 1;
        final viewModel = FoodSearchViewModel(
          openFoodFactsSearch:
              ({required query, required page, required pageSize}) =>
                  slowOff && page == slowPage
                  ? offResponse.future
                  : Future.value(offPage(page, pageSize)),
          usdaFoodSearch:
              ({required query, required page, required pageSize}) =>
                  !slowOff && page == slowPage
                  ? usdaResponse.future
                  : Future.value(usdaPage(page, pageSize)),
        );
        addTearDown(viewModel.dispose);

        if (pagination) await viewModel.retry('food');
        var completed = false;
        final request = pagination
            ? viewModel.loadMore('food')
            : viewModel.retry('food');
        unawaited(request.then((_) => completed = true));
        await tester.pump();
        final names = viewModel.results.map((result) => result.name).toList();
        expect(names, hasLength(pagination ? 41 : 20));
        expect(viewModel.hasError, isFalse);
        expect(completed, isFalse);

        await tester.pump(const Duration(seconds: 9));
        expect(completed, isFalse);
        await tester.pump(const Duration(seconds: 1));
        expect(completed, isTrue);
        expect(viewModel.isInitialLoading, isFalse);
        expect(viewModel.isLoadingMore, isFalse);
        expect(viewModel.offSearched, isTrue);
        expect(viewModel.usdaSearched, isTrue);
        expect(slowOff ? viewModel.offHasMore : viewModel.usdaHasMore, isFalse);
        expect(viewModel.results.map((result) => result.name), names);
        expect(viewModel.hasError, isFalse);

        offResponse.complete(offPage(slowPage, 20));
        usdaResponse.complete(usdaPage(slowPage, 20));
        await tester.pump();
        expect(viewModel.results.map((result) => result.name), names);
      });
    }
  }

  testWidgets('both provider timeouts keep neutral error and full retry', (
    tester,
  ) async {
    var retry = false;
    final requests = <String>[];
    final viewModel = FoodSearchViewModel(
      openFoodFactsSearch:
          ({required query, required page, required pageSize}) {
            requests.add('OFF:$query:$page');
            return retry
                ? Future.value(offPage(page, 1))
                : Completer<SearchResult>().future;
          },
      usdaFoodSearch: ({required query, required page, required pageSize}) {
        requests.add('USDA:$query:$page');
        return retry
            ? Future.value(usdaPage(page, 1))
            : Completer<UsdaSearchResponse>().future;
      },
    );
    addTearDown(viewModel.dispose);
    unawaited(viewModel.retry('food'));
    await tester.pump(const Duration(seconds: 10));
    expect(viewModel.hasError, isTrue);
    expect(viewModel.isInitialLoading, isFalse);
    retry = true;
    await viewModel.retry('food');
    expect(viewModel.results, hasLength(2));
    expect(viewModel.hasError, isFalse);
    expect(requests, [
      'OFF:food:1',
      'USDA:food:1',
      'OFF:food:1',
      'USDA:food:1',
    ]);
  });

  testWidgets('changing the query cancels a pending server retry', (
    tester,
  ) async {
    final queries = <String>[];
    final viewModel = FoodSearchViewModel(
      usdaConfigured: false,
      openFoodFactsSearch:
          ({required query, required page, required pageSize}) async {
            queries.add(query);
            if (query == 'old') {
              throw const HttpStatusException(statusCode: 503, message: '');
            }
            return offPage(page, 1);
          },
    );
    addTearDown(viewModel.dispose);

    viewModel.search('old');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(queries, ['old']);
    expect(viewModel.isInitialLoading, isTrue);

    viewModel.search('new');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
    expect(queries, ['old', 'new']);
    expect(viewModel.activeQuery, 'new');
    expect(viewModel.results, hasLength(1));
    expect(viewModel.hasError, isFalse);
  });

  testWidgets('stale pagination response and timeout cannot change new query', (
    tester,
  ) async {
    final offResponse = Completer<SearchResult>();
    final viewModel = FoodSearchViewModel(
      openFoodFactsSearch:
          ({required query, required page, required pageSize}) =>
              query == 'old' && page == 2
              ? offResponse.future
              : Future.value(
                  query == 'old' ? offPage(page, pageSize) : offPage(page, 1),
                ),
      usdaFoodSearch: ({required query, required page, required pageSize}) =>
          query == 'old' && page == 2
          ? Completer<UsdaSearchResponse>().future
          : Future.value(usdaPage(page, query == 'old' ? pageSize : 1)),
    );
    addTearDown(viewModel.dispose);
    await viewModel.retry('old');
    unawaited(viewModel.loadMore('old'));
    await viewModel.retry('new');
    final names = viewModel.results.map((result) => result.name).toList();
    offResponse.complete(offPage(2, 1));
    await tester.pump(const Duration(seconds: 10));
    expect(viewModel.activeQuery, 'new');
    expect(viewModel.results.map((result) => result.name), names);
    expect(viewModel.hasError, isFalse);
    expect(viewModel.isLoadingMore, isFalse);
  });

  testWidgets('dispose ignores pending response and timeout state', (
    tester,
  ) async {
    final offResponse = Completer<SearchResult>();
    final viewModel = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) => offResponse.future,
      usdaFoodSearch: ({required query, required page, required pageSize}) =>
          Completer<UsdaSearchResponse>().future,
    );
    var notifications = 0;
    viewModel.addListener(() => notifications++);
    unawaited(viewModel.retry('food'));
    expect(notifications, 1);
    viewModel.dispose();
    offResponse.complete(offPage(1, 1));
    await tester.pump(const Duration(seconds: 10));
    expect(viewModel.results, isEmpty);
    expect(viewModel.offSearched, isFalse);
    expect(viewModel.usdaSearched, isFalse);
    expect(notifications, 1);
    viewModel.search('after dispose');
    await viewModel.retry('after dispose');
    await viewModel.loadMore('food');
    expect(viewModel.activeQuery, 'food');
  });

  test(
    'retry keeps successful provider results when the other fails',
    () async {
      final viewModel = FoodSearchViewModel(
        openFoodFactsSearch: ({
          required query,
          required page,
          required pageSize,
        }) async => throw StateError('offline'),
        usdaFoodSearch:
            ({required query, required page, required pageSize}) async =>
                UsdaSearchResponse(
                  totalHits: 1,
                  currentPage: page,
                  totalPages: 1,
                  foods: [usdaFood(1, 'Apple')],
                ),
      );
      addTearDown(viewModel.dispose);

      await viewModel.retry('apple');

      expect(viewModel.results.map((result) => result.name), ['Apple']);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.offSearched, isTrue);
      expect(viewModel.usdaSearched, isTrue);
    },
  );

  test('stale provider responses do not replace a newer search', () async {
    final firstResponse = Completer<UsdaSearchResponse>();
    final viewModel = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => const SearchResult(products: []),
      usdaFoodSearch: ({required query, required page, required pageSize}) =>
          query == 'first'
          ? firstResponse.future
          : Future.value(
              UsdaSearchResponse(
                totalHits: 1,
                currentPage: page,
                totalPages: 1,
                foods: [usdaFood(2, 'Second')],
              ),
            ),
    );
    addTearDown(viewModel.dispose);

    final firstSearch = viewModel.retry('first');
    await Future<void>.delayed(Duration.zero);
    await viewModel.retry('second');
    firstResponse.complete(
      UsdaSearchResponse(
        totalHits: 1,
        currentPage: 1,
        totalPages: 1,
        foods: [usdaFood(1, 'First')],
      ),
    );
    await firstSearch;

    expect(viewModel.results.map((result) => result.name), ['Second']);
  });

  test(
    'loadMore requests the next page and stops after a short page',
    () async {
      final requestedPages = <int>[];
      final viewModel = FoodSearchViewModel(
        openFoodFactsSearch: ({
          required query,
          required page,
          required pageSize,
        }) async => const SearchResult(products: []),
        usdaFoodSearch:
            ({required query, required page, required pageSize}) async {
              requestedPages.add(page);
              return UsdaSearchResponse(
                totalHits: 21,
                currentPage: page,
                totalPages: 2,
                foods: page == 1
                    ? List.generate(
                        pageSize,
                        (index) => usdaFood(index, 'Food'),
                      )
                    : [usdaFood(20, 'Last food')],
              );
            },
      );
      addTearDown(viewModel.dispose);

      await viewModel.retry('food');
      await viewModel.loadMore('food');
      await viewModel.loadMore('food');

      expect(requestedPages, [1, 2]);
      expect(viewModel.results, hasLength(21));
      expect(viewModel.usdaHasMore, isFalse);
    },
  );

  test('clearing a query ignores pending results from the old query', () async {
    final response = Completer<UsdaSearchResponse>();
    final viewModel = FoodSearchViewModel(
      openFoodFactsSearch: ({
        required query,
        required page,
        required pageSize,
      }) async => const SearchResult(products: []),
      usdaFoodSearch: ({required query, required page, required pageSize}) =>
          response.future,
    );
    addTearDown(viewModel.dispose);

    final search = viewModel.retry('apple');
    await Future<void>.delayed(Duration.zero);
    viewModel.search('');
    response.complete(
      UsdaSearchResponse(
        totalHits: 1,
        currentPage: 1,
        totalPages: 1,
        foods: [usdaFood(3, 'Apple')],
      ),
    );
    await search;

    expect(viewModel.results, isEmpty);
    expect(viewModel.hasSearched, isFalse);
  });

  test('ranking prefers exact and unbranded matches', () {
    final results = [
      result(name: 'Apple pie'),
      result(name: 'Apple', brand: 'Brand'),
      result(name: 'Apple'),
    ];

    expect(
      rankFoodSearchResults(
        results,
        'apple',
      ).map((result) => (result.name, result.brand)),
      [('Apple', null), ('Apple', 'Brand'), ('Apple pie', null)],
    );
  });

  test('conversion creates fresh identities and preserves source metadata', () {
    final food = UsdaFoodItem(
      fdcId: 42,
      description: 'Apple',
      dataType: 'Branded',
      brandOwner: 'Example Foods',
      gtinUpc: '012345678901',
      ingredients: 'Apple',
      servingSize: 150,
      servingSizeUnit: 'g',
      foodNutrients: [UsdaFoodNutrient(nutrientId: 1008, value: 52)],
    );
    final unified = UnifiedFoodResult(
      id: '42',
      name: 'Apple',
      source: studyu.FoodSource.usda,
      originalData: food,
    );

    final first = convertFoodResultToFoodEntry(unified);
    final second = convertFoodResultToFoodEntry(unified);

    expect(first.id, isNot(second.id));
    expect(first.foodId, isNot(second.foodId));
    expect(first.foodVersionId, isNot(second.foodVersionId));
    expect(first.foodCode, food.gtinUpc);
    expect(first.externalId, food.fdcId.toString());
    expect(first.source, studyu.FoodSource.usda);
    expect(first.amount, 1);
    expect(first.unit, 'serving');
    expect(first.servingSizeGrams, 150);
    expect(first.originalValues, food.toJson());
  });
}

SearchResult offPage(int page, int pageSize) => SearchResult(
  products: List.generate(
    page == 1 ? pageSize : 1,
    (index) =>
        Product(barcode: '$page-$index', productName: 'OFF $page-$index'),
  ),
);

UsdaSearchResponse usdaPage(int page, int pageSize) => UsdaSearchResponse(
  totalHits: 21,
  currentPage: page,
  totalPages: 2,
  foods: List.generate(
    page == 1 ? pageSize : 1,
    (index) => usdaFood(page * 100 + index, 'USDA $page-$index'),
  ),
);

UsdaFoodItem usdaFood(int id, String description) => UsdaFoodItem(
  fdcId: id,
  description: description,
  foodNutrients: [UsdaFoodNutrient(nutrientId: 1008, value: 52)],
);

UnifiedFoodResult result({required String name, String? brand}) =>
    UnifiedFoodResult(
      id: '$name:$brand',
      name: name,
      brand: brand,
      calories: 1,
      source: studyu.FoodSource.usda,
      originalData: usdaFood(1, name),
    );
