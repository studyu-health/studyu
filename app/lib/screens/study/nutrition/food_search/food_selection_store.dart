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
  double get amount => baseFood.amount * quantity;
  bool get canDecrement => amount > baselineFood.amount + 0.000001;
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

  Iterable<FoodSelectionItem> get items => _items.values;
  int get itemCount => _items.length;
  int get servingCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  int get unknownCaloriesCount =>
      _items.values.where((item) => item.hasMissingCalories).length;
  bool get hasKnownCalories =>
      _items.values.any((item) => item.hasKnownCalories);
  bool get isEmpty => _items.isEmpty;

  FoodSelectionItem? itemFor(String key) => _items[key];

  String keyForFoodDefinition(String foodId, String preferredKey) {
    if (_items[preferredKey]?.baseFood.foodId == foodId) return preferredKey;
    for (final item in _items.values) {
      if (item.baseFood.foodId == foodId) return item.key;
    }
    return preferredKey;
  }

  void seed(Iterable<studyu.FoodEntry> foods) {
    for (final food in foods) {
      final canonicalKey = canonicalFoodSelectionKey(food);
      // Preserve distinct occurrences already stored under the same identity.
      final key = _items.containsKey(canonicalKey)
          ? '$canonicalKey:occurrence:${food.id}'
          : canonicalKey;
      addOrIncrement(
        key,
        food,
        sourceFood: rescaleFoodAmount(food, 1),
        gramsKnown: food.servingSizeGrams.isFinite && food.servingSizeGrams > 0,
      );
    }
  }

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
        final roundedServings = servings.isFinite ? servings.round() : 0;
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
      _setAmount(existing, existing.amount + existing.baselineFood.amount);
    }
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
    notifyListeners();
  }

  void increment(String key) {
    final item = _items[key];
    if (item == null) return;
    _setAmount(item, item.amount + item.baselineFood.amount);
    notifyListeners();
  }

  void decrement(String key) {
    final item = _items[key];
    if (item == null) return;
    if (!item.canDecrement) {
      _items.remove(key);
    } else {
      _setAmount(item, item.amount - item.baselineFood.amount);
    }
    notifyListeners();
  }

  void delete(String key) {
    if (_items.remove(key) == null) return;
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
    _setFood(item, food, food.amount);
    item.caloriesKnown = caloriesKnown;
    if (gramsKnown != null) item.gramsKnown = gramsKnown;
    notifyListeners();
  }

  void _setAmount(FoodSelectionItem item, double amount) =>
      _setFood(item, item.baseFood, amount);

  void _setFood(FoodSelectionItem item, studyu.FoodEntry food, double amount) {
    final servings = amount / item.baselineFood.amount;
    final roundedServings = servings.isFinite ? servings.round() : 0;
    if (servings.isFinite &&
        roundedServings > 0 &&
        (servings - roundedServings).abs() < 0.000001) {
      item
        ..baseFood = rescaleFoodAmount(food, amount / roundedServings)
        ..quantity = roundedServings;
    } else {
      item
        ..baseFood = rescaleFoodAmount(food, amount)
        ..quantity = 1;
    }
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
      final amount = item.amount;
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
  if (food.source == studyu.FoodSource.manual) return 'manual:${food.foodId}';
  return [
    source,
    normalizeFoodSearchText(food.name),
    normalizeFoodSearchText(food.brandName ?? ''),
    normalizeFoodSearchText(food.unit),
    food.servingSizeGrams.toString(),
  ].join('|');
}
