import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_core/core.dart' as studyu;

void main() {
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
