import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_requests.dart';
import 'package:studyu_app/services/usda_api_service.dart';
import 'package:studyu_core/core.dart' as studyu;

typedef OpenFoodFactsSearch = Future<SearchResult> Function({
  required String query,
  required int page,
  required int pageSize,
});
typedef UsdaFoodSearch = Future<UsdaSearchResponse> Function({
  required String query,
  required int page,
  required int pageSize,
});

final class FoodSearchViewModel({
  final OpenFoodFactsSearch? _openFoodFactsSearch,
  final UsdaFoodSearch? _usdaFoodSearch,
  final bool? _usdaConfigured,
  String languageCode = 'en',
}) extends ChangeNotifier {
  static const _debounceDuration = Duration(milliseconds: 400);
  static const _pageSize = 20;

  String _languageCode = languageCode;
  Timer? _debounceTimer;
  final List<UnifiedFoodResult> _results = [];
  int _offPage = 1;
  int _usdaPage = 1;
  int _searchGeneration = 0;
  bool _offHasMore = true;
  bool _usdaHasMore = true;
  bool _offSearched = false;
  bool _usdaSearched = false;
  bool _offFailed = false;
  bool _usdaFailed = false;
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasSearched = false;
  bool _isDisposed = false;
  String _activeQuery = '';

  List<UnifiedFoodResult> get results =>
      rankFoodSearchResults(_results, _activeQuery);
  bool get offHasMore => _offHasMore;
  bool get usdaHasMore => _usdaHasMore;
  bool get offSearched => _offSearched;
  bool get usdaSearched => _usdaSearched;
  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasSearched => _hasSearched;
  bool get hasError => _results.isEmpty && (_offFailed || _usdaFailed);
  String get activeQuery => _activeQuery;

  bool get _hasUsdaProvider =>
      _usdaFoodSearch != null ||
      (_usdaConfigured ?? UsdaApiService.isConfigured);

  void setLanguageCode(String languageCode) {
    if (_isDisposed || _languageCode == languageCode) return;
    _languageCode = languageCode;
    if (_activeQuery.isNotEmpty) search(_activeQuery);
  }

  void search(String value) {
    if (_isDisposed) return;
    _debounceTimer?.cancel();
    final query = value.trim();
    final generation = ++_searchGeneration;
    _reset();
    if (query.isEmpty) return;

    _debounceTimer = Timer(_debounceDuration, () => _search(query, generation));
  }

  Future<void> retry(String query) async {
    if (_isDisposed) return;
    _debounceTimer?.cancel();
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;
    await _search(trimmedQuery, ++_searchGeneration);
  }

  Future<void> loadMore(String currentQuery) async {
    if (_isDisposed || _isLoadingMore || _isInitialLoading) return;
    if (!_offHasMore && !_usdaHasMore) return;
    if (_activeQuery.isEmpty || _activeQuery != currentQuery.trim()) return;

    final generation = _searchGeneration;
    final offPage = _offPage;
    final usdaPage = _usdaPage;
    _isLoadingMore = true;
    _notifyListeners();

    final futures = <Future<void>>[];
    if (_offHasMore) {
      futures.add(
        _searchOpenFoodFacts(
          _activeQuery,
          page: offPage,
          generation: generation,
        ),
      );
    }
    if (_usdaHasMore) {
      futures.add(
        _searchUsda(_activeQuery, page: usdaPage, generation: generation),
      );
    }

    await Future.wait(futures);
    if (!_isCurrent(generation)) return;
    _isLoadingMore = false;
    _notifyListeners();
  }

  void _reset() {
    _results.clear();
    _offPage = 1;
    _usdaPage = 1;
    _offHasMore = true;
    _usdaHasMore = true;
    _isInitialLoading = false;
    _isLoadingMore = false;
    _hasSearched = false;
    _activeQuery = '';
    _offSearched = false;
    _usdaSearched = false;
    _offFailed = false;
    _usdaFailed = false;
    _notifyListeners();
  }

  Future<void> _search(String query, int generation) async {
    if (!_isCurrent(generation)) return;
    _activeQuery = query;
    _offPage = 1;
    _usdaPage = 1;
    _offHasMore = true;
    _usdaHasMore = true;
    _offSearched = false;
    _usdaSearched = false;
    _offFailed = false;
    _usdaFailed = false;
    _isInitialLoading = true;
    _isLoadingMore = false;
    _hasSearched = true;
    _results.clear();
    _notifyListeners();

    final searches = <Future<void>>[
      _searchOpenFoodFacts(query, page: 1, generation: generation),
    ];
    if (_hasUsdaProvider) {
      searches.add(_searchUsda(query, page: 1, generation: generation));
    } else {
      _usdaSearched = true;
      _usdaHasMore = false;
    }
    await Future.wait(searches);

    if (!_isCurrent(generation)) return;
    _isInitialLoading = false;
    _notifyListeners();
  }

  Future<SearchResult> _fetchOpenFoodFacts({
    required String query,
    required int page,
  }) {
    final search = _openFoodFactsSearch;
    if (search != null) {
      return search(query: query, page: page, pageSize: _pageSize);
    }

    return OpenFoodAPIClient.searchProducts(
      null,
      ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [query]),
          PageNumber(page: page),
          const PageSize(size: _pageSize),
        ],
        languages: openFoodFactsLanguages(_languageCode),
        fields: openFoodFactsSearchFields,
        version: ProductQueryVersion.v3,
      ),
    );
  }

  Future<UsdaSearchResponse> _fetchUsda({
    required String query,
    required int page,
  }) {
    final search = _usdaFoodSearch;
    if (search != null) {
      return search(query: query, page: page, pageSize: _pageSize);
    }

    return UsdaApiService.searchFoods(
      query: query,
      pageSize: _pageSize,
      pageNumber: page,
    );
  }

  Future<void> _searchOpenFoodFacts(
    String query, {
    required int page,
    required int generation,
  }) async {
    try {
      final searchResult = await _fetchOpenFoodFacts(
        query: query,
        page: page,
      ).timeout(foodProviderTimeout);
      if (!_isCurrent(generation)) return;

      final products = searchResult.products ?? const <Product>[];
      _results.addAll(
        products.map((product) {
          product.productName = openFoodFactsProductName(
            product,
            _languageCode,
          );
          return _unifiedOpenFoodFactsResult(product);
        }),
      );
      _offSearched = true;
      _offFailed = false;
      _offPage = page + 1;
      _offHasMore = products.length >= _pageSize;
    } catch (error) {
      if (!_isCurrent(generation)) return;
      debugPrint('OpenFoodFacts error: $error');
      _offSearched = true;
      _offFailed = true;
      _offHasMore = false;
    }
    _notifyListeners();
  }

  Future<void> _searchUsda(
    String query, {
    required int page,
    required int generation,
  }) async {
    try {
      final searchResult = await _fetchUsda(
        query: query,
        page: page,
      ).timeout(foodProviderTimeout);
      if (!_isCurrent(generation)) return;

      _results.addAll(searchResult.foods.map(_unifiedUsdaResult));
      _usdaSearched = true;
      _usdaFailed = false;
      _usdaPage = searchResult.currentPage + 1;
      _usdaHasMore = searchResult.currentPage < searchResult.totalPages;
    } catch (error) {
      if (!_isCurrent(generation)) return;
      debugPrint('USDA error: $error');
      _usdaSearched = true;
      _usdaFailed = true;
      _usdaHasMore = false;
    }
    _notifyListeners();
  }

  bool _isCurrent(int generation) =>
      !_isDisposed && generation == _searchGeneration;

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }
}

UnifiedFoodResult _unifiedOpenFoodFactsResult(Product product) {
  final nutriments = product.nutriments;
  final caloriesPer100g = nutriments?.getValue(
    Nutrient.energyKCal,
    PerSize.oneHundredGrams,
  );
  final servingSizeGrams = _gramsFromMetadata(product.servingSize);
  final calorieBasisGrams = servingSizeGrams ?? 100.0;

  return UnifiedFoodResult(
    id: product.barcode ?? '',
    name: product.productName ?? 'Unknown',
    brand: product.brands,
    imageUrl: product.imageFrontSmallUrl,
    calories: caloriesPer100g == null
        ? null
        : caloriesPer100g * calorieBasisGrams / 100,
    calorieBasisGrams: caloriesPer100g == null ? null : calorieBasisGrams,
    servingSizeGrams: servingSizeGrams,
    source: studyu.FoodSource.openfoodfacts,
    originalData: product,
  );
}

UnifiedFoodResult _unifiedUsdaResult(UsdaFoodItem food) {
  final caloriesPer100g = food.getNutrientValue(1008);
  final servingSize = food.servingSize;
  final hasGramServing =
      _isGramServingUnit(food.servingSizeUnit) &&
      servingSize != null &&
      servingSize.isFinite &&
      servingSize > 0;
  final servingSizeGrams = hasGramServing ? servingSize : null;
  final calorieBasisGrams = hasGramServing ? servingSize : 100.0;

  return UnifiedFoodResult(
    id: food.fdcId.toString(),
    name: food.description ?? 'Unknown',
    brand: food.brandOwner ?? food.brandName,
    calories: caloriesPer100g == null
        ? caloriesPer100g
        : caloriesPer100g * calorieBasisGrams / 100,
    calorieBasisGrams: caloriesPer100g == null ? null : calorieBasisGrams,
    servingSizeGrams: servingSizeGrams,
    source: studyu.FoodSource.usda,
    originalData: food,
  );
}

bool _isGramServingUnit(String? unit) {
  return switch (unit?.trim().toLowerCase()) {
    'g' || 'gram' || 'grams' => true,
    _ => false,
  };
}

List<UnifiedFoodResult> rankFoodSearchResults(
  Iterable<UnifiedFoodResult> results,
  String query,
) {
  final normalizedQuery = normalizeFoodSearchText(query);
  final indexed = results.indexed.toList();
  if (normalizedQuery.isEmpty) {
    return indexed.map((entry) => entry.$2).toList(growable: false);
  }

  indexed.sort((left, right) {
    final scoreComparison = _foodSearchScore(
      left.$2,
      normalizedQuery,
    ).compareTo(_foodSearchScore(right.$2, normalizedQuery));
    return scoreComparison != 0 ? scoreComparison : left.$1.compareTo(right.$1);
  });
  return indexed.map((entry) => entry.$2).toList(growable: false);
}

int _foodSearchScore(UnifiedFoodResult result, String normalizedQuery) {
  final name = normalizeFoodSearchText(result.name);
  final queryTokens = normalizedQuery.split(' ');
  final nameTokens = name.split(' ');
  final isExact = name == normalizedQuery;
  final isPrefixOrToken =
      name.startsWith(normalizedQuery) ||
      queryTokens.every(
        (queryToken) =>
            nameTokens.any((nameToken) => nameToken.startsWith(queryToken)),
      );
  final matchTier = isExact
      ? 0
      : isPrefixOrToken
      ? 1
      : 2;
  final isBranded = result.brand?.trim().isNotEmpty ?? false;
  return matchTier * 2 + (isBranded ? 1 : 0);
}

String normalizeFoodSearchText(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

double? _gramsFromMetadata(String? value) {
  if (value == null) return null;
  final match = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*g(?:rams?)?\b',
    caseSensitive: false,
  ).firstMatch(value);
  return match == null
      ? null
      : double.tryParse(match.group(1)!.replaceAll(',', '.'));
}

studyu.FoodEntry convertFoodResultToFoodEntry(UnifiedFoodResult result) {
  return switch (result.originalData) {
    final UsdaFoodItem food => convertUsdaToFoodEntry(food),
    final Product product => convertOpenFoodFactsToFoodEntry(product),
    _ => throw ArgumentError(
      'Unsupported food result source: ${result.source}',
    ),
  };
}

studyu.FoodEntry convertUsdaToFoodEntry(UsdaFoodItem food) {
  final servingSize = food.servingSize;
  final hasGramServing =
      _isGramServingUnit(food.servingSizeUnit) &&
      servingSize != null &&
      servingSize.isFinite &&
      servingSize > 0;
  final servingSizeGrams = hasGramServing ? servingSize : 100.0;
  final scale = servingSizeGrams / 100.0;

  return studyu.FoodEntry.withId(
    entryType: studyu.FoodEntryType.brandedProduct,
    name: food.description ?? 'Unknown Food',
    brandName: food.brandOwner ?? food.brandName,
    description: food.ingredients,
    amount: 1,
    unit: 'serving',
    servingSizeGrams: servingSizeGrams,
    portionReference: food.householdServingFullText,
    portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
    portionState: studyu.PortionState.asServed,
    yieldFactor: 1.0,
    nutrition: studyu.NutritionProfile(
      energyKcal: (food.energyKcal100g * scale).roundToDouble(),
      protein: food.protein100g * scale,
      carbs: food.carbohydrates100g * scale,
      fat: food.fat100g * scale,
      sugars: food.sugars100g * scale,
      fiber: food.fiber100g * scale,
      saturatedFat: food.saturatedFat100g * scale,
      transFat: (food.getNutrientValue(1257) ?? 0) * scale,
      cholesterol: (food.getNutrientValue(1253) ?? 0) * scale,
      sodium: food.sodium100g * scale,
      waterContent: (food.getNutrientValue(1051) ?? 0) * scale,
      micros: {},
      unavailableNutrients: {
        if (food.getNutrientValue(1008) == null) 'energyKcal',
        if (food.getNutrientValue(1003) == null) 'protein',
        if (food.getNutrientValue(1005) == null) 'carbs',
        if (food.getNutrientValue(1004) == null) 'fat',
        if (food.getNutrientValue(2000) == null) 'sugars',
        if (food.getNutrientValue(1079) == null) 'fiber',
        if (food.getNutrientValue(1258) == null) 'saturatedFat',
        if (food.getNutrientValue(1093) == null) 'sodium',
        if (food.getNutrientValue(1257) == null) 'transFat',
        if (food.getNutrientValue(1253) == null) 'cholesterol',
        if (food.getNutrientValue(1051) == null) 'waterContent',
      },
    ),
    foodCode: food.gtinUpc,
    externalId: food.fdcId.toString(),
    source: studyu.FoodSource.usda,
    confidenceScore: 1.0,
    originalValues: food.toJson(),
  );
}

studyu.FoodEntry convertOpenFoodFactsToFoodEntry(Product product) {
  final nutriments = product.nutriments;
  final energyKcal =
      nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ?? 0;
  final protein =
      nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0;
  final carbs =
      nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
      0;
  final fat = nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0;
  final sugars =
      nutriments?.getValue(Nutrient.sugars, PerSize.oneHundredGrams) ?? 0;
  final fiber =
      nutriments?.getValue(Nutrient.fiber, PerSize.oneHundredGrams) ?? 0;
  final saturatedFat =
      nutriments?.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams) ?? 0;
  final sodium =
      (nutriments?.getValue(Nutrient.sodium, PerSize.oneHundredGrams) ?? 0) *
      1000;
  bool isUnavailable(Nutrient nutrient) =>
      nutriments?.getValue(nutrient, PerSize.oneHundredGrams) == null;
  final unavailableNutrients = {
    if (isUnavailable(Nutrient.energyKCal)) 'energyKcal',
    if (isUnavailable(Nutrient.proteins)) 'protein',
    if (isUnavailable(Nutrient.carbohydrates)) 'carbs',
    if (isUnavailable(Nutrient.fat)) 'fat',
    if (isUnavailable(Nutrient.sugars)) 'sugars',
    if (isUnavailable(Nutrient.fiber)) 'fiber',
    if (isUnavailable(Nutrient.saturatedFat)) 'saturatedFat',
    if (isUnavailable(Nutrient.sodium)) 'sodium',
    if (isUnavailable(Nutrient.transFat)) 'transFat',
    if (isUnavailable(Nutrient.cholesterol)) 'cholesterol',
    'waterContent',
  };
  double servingSizeGrams = 100.0;
  if (product.servingSize != null) {
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*g')
        .firstMatch(product.servingSize!);
    if (match != null) {
      servingSizeGrams = double.tryParse(match.group(1)!) ?? 100.0;
    }
  }

  return studyu.FoodEntry.withId(
    entryType: studyu.FoodEntryType.brandedProduct,
    name: product.productName ?? 'Unknown Product',
    brandName: product.brands,
    description: product.genericName,
    amount: 1,
    unit: 'serving',
    servingSizeGrams: servingSizeGrams,
    portionReference: product.servingSize,
    portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
    portionState: studyu.PortionState.asServed,
    yieldFactor: 1.0,
    nutrition: studyu.NutritionProfile(
      energyKcal: energyKcal * servingSizeGrams / 100,
      protein: protein * servingSizeGrams / 100,
      carbs: carbs * servingSizeGrams / 100,
      fat: fat * servingSizeGrams / 100,
      sugars: sugars * servingSizeGrams / 100,
      fiber: fiber * servingSizeGrams / 100,
      saturatedFat: saturatedFat * servingSizeGrams / 100,
      transFat:
          (nutriments?.getValue(Nutrient.transFat, PerSize.oneHundredGrams) ??
              0) *
          servingSizeGrams /
          100,
      cholesterol:
          (nutriments?.getValue(
                Nutrient.cholesterol,
                PerSize.oneHundredGrams,
              ) ??
              0) *
          1000 *
          servingSizeGrams /
          100,
      sodium: sodium * servingSizeGrams / 100,
      waterContent: 0,
      micros: {},
      unavailableNutrients: unavailableNutrients,
    ),
    foodCode: product.barcode,
    externalId: product.barcode,
    source: studyu.FoodSource.openfoodfacts,
    confidenceScore: 1.0,
    originalValues: product.toJson(),
  );
}
