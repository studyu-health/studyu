part of '../food_search_screen.dart';

final class FoodSearchSelection {
  final List<studyu.FoodEntry> foods;

  new(Iterable<studyu.FoodEntry> foods) : foods = List.unmodifiable(foods);

  new single(studyu.FoodEntry food) : foods = List.unmodifiable([food]);
}

final class FoodSelectionItem({
  required final String key,
  required final studyu.FoodEntry baselineFood,
  required var studyu.FoodEntry baseFood,
  var int quantity = 1,
  var bool caloriesKnown = true,
  var bool gramsKnown = true,
  final bool baselineGramsKnown = true,
}) {
  String get name => baseFood.name;
  bool get hasKnownCalories =>
      caloriesKnown && baseFood.nutrition.isKnown('energyKcal');
  bool get hasMissingCalories =>
      !hasKnownCalories || baseFood.nutrition.isPartial('energyKcal');

  bool get servingWeightOverridden =>
      gramsKnown &&
      (!baselineGramsKnown ||
          (baseFood.servingSizeGrams - baselineFood.servingSizeGrams).abs() >
              0.000001);
}

/// Temporary, route-scoped state for the multi-select Add items flow.
final class FoodSelectionStore() extends ChangeNotifier {
  final LinkedHashMap<String, FoodSelectionItem> _items = LinkedHashMap();
  final List<String> _recentKeys = [];

  Iterable<FoodSelectionItem> get items => _items.values;
  Iterable<FoodSelectionItem> get recentItems => _recentKeys.reversed
      .map((key) => _items[key])
      .whereType<FoodSelectionItem>();
  int get itemCount => _items.length;
  int get servingCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  int get unknownCaloriesCount =>
      _items.values.where((item) => item.hasMissingCalories).length;
  bool get hasKnownCalories =>
      _items.values.any((item) => item.hasKnownCalories);
  bool get isEmpty => _items.isEmpty;

  FoodSelectionItem? itemFor(String key) => _items[key];

  void addOrIncrement(
    String key,
    studyu.FoodEntry food, {
    studyu.FoodEntry? sourceFood,
    bool caloriesKnown = true,
    bool gramsKnown = true,
    bool? baselineGramsKnown,
  }) {
    final existing = _items[key];
    if (existing == null) {
      var quantity = 1;
      var baseFood = food;
      final sourceAmount = sourceFood?.amount;
      if (sourceAmount != null && sourceAmount.isFinite && sourceAmount > 0) {
        final servings = food.amount / sourceAmount;
        final roundedServings = servings.round();
        if (servings.isFinite &&
            roundedServings > 0 &&
            (servings - roundedServings).abs() < 0.000001) {
          quantity = roundedServings;
          baseFood = rescaleFoodAmount(food, food.amount / roundedServings);
        }
      }
      _items[key] = FoodSelectionItem(
        key: key,
        baselineFood: cloneFoodEntry(sourceFood ?? baseFood),
        baseFood: cloneFoodEntry(baseFood),
        quantity: quantity,
        caloriesKnown: caloriesKnown,
        gramsKnown: gramsKnown,
        baselineGramsKnown: baselineGramsKnown ?? gramsKnown,
      );
    } else {
      existing.quantity++;
    }
    _recentKeys
      ..remove(key)
      ..add(key);
    notifyListeners();
  }

  void restore(FoodSelectionItem item) {
    if (_items.containsKey(item.key)) return;
    _items[item.key] = FoodSelectionItem(
      key: item.key,
      baselineFood: cloneFoodEntry(item.baselineFood),
      baseFood: cloneFoodEntry(item.baseFood),
      quantity: item.quantity,
      caloriesKnown: item.caloriesKnown,
      gramsKnown: item.gramsKnown,
      baselineGramsKnown: item.baselineGramsKnown,
    );
    _recentKeys
      ..remove(item.key)
      ..add(item.key);
    notifyListeners();
  }

  void increment(String key) {
    final item = _items[key];
    if (item == null) return;
    item.quantity++;
    notifyListeners();
  }

  void decrement(String key) {
    final item = _items[key];
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(key);
      _recentKeys.remove(key);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }

  void delete(String key) {
    if (_items.remove(key) == null) return;
    _recentKeys.remove(key);
    notifyListeners();
  }

  void replaceBase(
    String key,
    studyu.FoodEntry food, {
    required bool caloriesKnown,
    bool? gramsKnown,
  }) {
    final item = _items[key];
    if (item == null) return;
    final servings = food.amount / item.baseFood.amount;
    final roundedServings = servings.round();
    if (servings.isFinite &&
        roundedServings > 0 &&
        (servings - roundedServings).abs() < 0.000001) {
      item
        ..baseFood = rescaleFoodAmount(food, food.amount / roundedServings)
        ..quantity = roundedServings;
    } else {
      item
        ..baseFood = cloneFoodEntry(food)
        ..quantity = 1;
    }
    item.caloriesKnown = caloriesKnown;
    if (gramsKnown != null) item.gramsKnown = gramsKnown;
    notifyListeners();
  }

  double knownCalories() => _items.values
      .where((item) => item.hasKnownCalories)
      .fold(
        0,
        (sum, item) => sum + item.baseFood.nutrition.energyKcal * item.quantity,
      );

  List<studyu.FoodEntry> materialize() {
    final result = <studyu.FoodEntry>[];
    for (final item in _items.values) {
      final amount = item.baseFood.amount * item.quantity;
      if (!amount.isFinite || amount <= 0) {
        throw ArgumentError.value(amount, 'amount', 'Must be positive');
      }
      result.add(rescaleFoodAmount(item.baseFood, amount));
    }
    return result;
  }
}

String canonicalFoodSelectionKey(studyu.FoodEntry food) {
  if (food.templateId case final templateId? when templateId.isNotEmpty) {
    return 'template:$templateId';
  }
  final source = food.source.name;
  final externalId = food.externalId?.trim();
  if (externalId != null && externalId.isNotEmpty) {
    return '$source:id:$externalId';
  }
  final barcode = food.foodCode?.trim();
  if (barcode != null && barcode.isNotEmpty) {
    return '$source:barcode:$barcode';
  }
  if (food.source == studyu.FoodSource.manual) return 'manual:${food.id}';
  return [
    source,
    normalizeFoodSearchText(food.name),
    normalizeFoodSearchText(food.brandName ?? ''),
    normalizeFoodSearchText(food.unit),
    food.amount.toString(),
    food.servingSizeGrams.toString(),
  ].join('|');
}
