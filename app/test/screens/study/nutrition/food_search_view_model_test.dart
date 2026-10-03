import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_core/core.dart' as studyu;

void main() {
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
