import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_core/core.dart';

typedef AssistedMealSuggestion = ({MealLog meal, int? photoIndex});

final _photoNumber = RegExp(r'(?:\bphotos?|\bfotos?|사진)\s*#?\s*(\d+)\b');
final _clockTime = RegExp(r'\b(\d{1,2}):(\d{2})(?:\s*(am|pm))?\b');
final _grams = RegExp(r'(?:^|[^\d.,-])(\d+(?:[.,]\d+)?)\s*(?:grams?\b|g\b|그램)');

class const _FixtureNutrition({
  required final double energyKcal,
  required final double protein,
  required final double carbs,
  required final double fat,
  required final double sugars,
  required final double fiber,
  required final double saturatedFat,
  required final double sodium,
  final double? cholesterol,
  final double? waterContent,
}) {
  NutritionProfile forPortion(double scale) => NutritionProfile(
    energyKcal: energyKcal * scale,
    protein: protein * scale,
    carbs: carbs * scale,
    fat: fat * scale,
    sugars: sugars * scale,
    fiber: fiber * scale,
    saturatedFat: saturatedFat * scale,
    transFat: 0,
    cholesterol: (cholesterol ?? 0) * scale,
    sodium: sodium * scale,
    waterContent: (waterContent ?? 0) * scale,
    micros: {},
    unavailableNutrients: {
      'transFat',
      if (cholesterol == null) 'cholesterol',
      if (waterContent == null) 'waterContent',
    },
  );
}

enum _SampleFood(final List<String> names) {
  oatmeal(['oatmeal', 'porridge', 'haferbrei', '오트밀']),
  maultaschen(['maultaschen', '마울타셴']),
  potatoSalad(['potato salad', 'kartoffelsalat', '감자 샐러드']);

  bool appearsIn(String text) => names.any(text.contains);

  FoodEntry portion(String languageCode) {
    final (
      name,
      description,
      source,
      externalId,
      servingGrams,
      nutrients,
    ) = switch (this) {
      // One bowl: 200 g cooked oats (FDC 2708381) and 80 g banana
      // (FDC 2709224). The nutrient values are totals for the bowl.
      oatmeal => (
        switch (languageCode) {
          'de' => 'Haferbrei mit Banane',
          'ko' => '바나나 오트밀',
          _ => 'Oatmeal with banana',
        },
        'USDA FoodData Central 2708381 and 2709224',
        FoodSource.manual,
        null,
        280.0,
        const _FixtureNutrition(
          energyKcal: 205.6,
          protein: 5.012,
          carbs: 40.96,
          fat: 2.404,
          sugars: 12.98,
          fiber: 4.76,
          saturatedFat: 0.4616,
          cholesterol: 0,
          sodium: 140,
          waterContent: 230.08,
        ),
      ),
      maultaschen => (
        languageCode == 'ko' ? '마울타셴' : 'Maultaschen',
        'BÜRGER Maultaschen original schwäbisch',
        FoodSource.openfoodfacts,
        '4075600055145',
        1.0,
        const _FixtureNutrition(
          energyKcal: 196,
          protein: 8.6,
          carbs: 25,
          fat: 6.4,
          sugars: 2.1,
          fiber: 2,
          saturatedFat: 2.4,
          sodium: 480,
        ),
      ),
      potatoSalad => (
        switch (languageCode) {
          'de' => 'Kartoffelsalat',
          'ko' => '감자 샐러드',
          _ => 'Potato salad',
        },
        'USDA FoodData Central 2709541',
        FoodSource.usda,
        '2709541',
        1.0,
        const _FixtureNutrition(
          energyKcal: 108,
          protein: 2.92,
          carbs: 17.2,
          fat: 3.22,
          sugars: 1.46,
          fiber: 1.9,
          saturatedFat: 1.2,
          cholesterol: 5,
          sodium: 181,
          waterContent: 74.8,
        ),
      ),
    };
    final (amount, unit) = switch (this) {
      oatmeal => (1.0, 'serving'),
      maultaschen => (150.0, 'g'),
      potatoSalad => (100.0, 'g'),
    };
    final scale = this == oatmeal ? 1.0 : amount / 100;
    return FoodEntry.withId(
      entryType: FoodEntryType.singleIngredient,
      name: name,
      description: description,
      amount: amount,
      unit: unit,
      servingSizeGrams: servingGrams,
      portionReference: this == oatmeal
          ? switch (languageCode) {
              'de' => '1 Schüssel',
              'ko' => '1그릇',
              _ => '1 bowl',
            }
          : null,
      portionEstimationMethod: this == oatmeal
          ? PortionEstimationMethod.householdMeasure
          : PortionEstimationMethod.standardUnit,
      portionState: PortionState.asServed,
      nutrition: nutrients.forPortion(scale),
      externalId: externalId,
      source: source,
      confidenceScore: 0,
      originalValues: {},
    );
  }
}

/// Uses the Figma sample meals and recognizes their names in the description.
List<AssistedMealSuggestion> assistedNutritionSuggestions({
  required String description,
  required int photoCount,
  required DateTime diaryDay,
  required String languageCode,
}) {
  final clauses = description.toLowerCase().split(RegExp(r'[.!?\n]+(?=\s|$)'));
  final matchingClauses = clauses
      .where(
        (clause) => _SampleFood.values.any((food) => food.appearsIn(clause)),
      )
      .toList();

  if (matchingClauses.isEmpty) {
    return [
      _suggestMeal(
        MealType.breakfast,
        [_SampleFood.oatmeal],
        '',
        diaryDay,
        languageCode,
        photoIndex: photoCount > 0 ? 0 : null,
      ),
      if (photoCount != 1)
        _suggestMeal(
          MealType.lunch,
          [_SampleFood.maultaschen, _SampleFood.potatoSalad],
          '',
          diaryDay,
          languageCode,
          photoIndex: photoCount > 1 ? 1 : null,
        ),
    ];
  }

  return [
    for (final clause in matchingClauses)
      for (final (type, foods) in [
        (MealType.breakfast, [_SampleFood.oatmeal]),
        (MealType.lunch, [_SampleFood.maultaschen, _SampleFood.potatoSalad]),
      ])
        if (foods.any((food) => food.appearsIn(clause)))
          _suggestMeal(
            type,
            foods.where((food) => food.appearsIn(clause)),
            clause,
            diaryDay,
            languageCode,
            photoIndex: _referencedPhoto(clause, photoCount),
          ),
  ];
}

int? _referencedPhoto(String clause, int photoCount) {
  final match = _photoNumber.firstMatch(clause);
  final number = int.tryParse(match?.group(1) ?? '');
  return number != null && number > 0 && number <= photoCount
      ? number - 1
      : null;
}

AssistedMealSuggestion _suggestMeal(
  MealType type,
  Iterable<_SampleFood> examples,
  String clause,
  DateTime diaryDay,
  String languageCode, {
  required int? photoIndex,
}) {
  final timestamp = _describedTime(clause, diaryDay);
  final exact = RegExp(r'\b(exactly|genau|pünktlich)\b|정확히').hasMatch(clause);
  final foods = examples
      .map((example) => example.portion(languageCode))
      .toList();
  if (_describedGrams(clause) case final grams? when foods.length == 1) {
    final resized = _foodWithGrams(foods.single, grams);
    if (resized != null) foods[0] = resized;
  }
  return (
    meal: MealLog.withId(
      mealType: type,
      timestamp: timestamp,
      timePrecision: timestamp == null
          ? MealOccurrenceTimePrecision.unknown
          : exact
          ? MealOccurrenceTimePrecision.exact
          : MealOccurrenceTimePrecision.approximate,
      timezone: (timestamp ?? diaryDay).toLocal().timeZoneName,
      isSkipped: false,
      foods: orderAssistedFoodsByWeight(foods),
    ),
    photoIndex: photoIndex,
  );
}

DateTime? _describedTime(String text, DateTime day) {
  final times = _clockTime.allMatches(text).toList();
  if (times.length != 1) return null;
  final match = times.single;
  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final period = match.group(3);
  if (period != null) {
    if (hour < 1 || hour > 12) return null;
    hour = hour % 12 + (period == 'pm' ? 12 : 0);
  }
  if (hour > 23 || minute > 59) return null;
  if (day.isUtc) {
    final localTimes = localMealTimesOnUtcDay(day, hour: hour, minute: minute);
    return localTimes.length == 1 ? localTimes.single : null;
  }
  final time = DateTime(day.year, day.month, day.day, hour, minute);
  return time.hour == hour && time.minute == minute ? time : null;
}

List<FoodEntry> orderAssistedFoodsByWeight(List<FoodEntry> foods) {
  final indexed = foods.indexed.toList();
  indexed.sort((left, right) {
    final leftGrams = foodTotalGrams(left.$2, 1);
    final rightGrams = foodTotalGrams(right.$2, 1);
    final byWeight = switch ((leftGrams, rightGrams)) {
      (null, null) => 0,
      (null, _) => 1,
      (_, null) => -1,
      (final double left, final double right) => right.compareTo(left),
    };
    return byWeight == 0 ? left.$1.compareTo(right.$1) : byWeight;
  });
  return indexed.map((entry) => entry.$2).toList();
}

/// Applies a single portion correction to the current draft.
bool applyAssistedNutritionCorrection(List<MealLog> meals, String text) {
  final description = text.toLowerCase();
  final grams = _describedGrams(description);
  final matches = [
    for (final meal in meals)
      for (final (index, food) in meal.foods.indexed)
        if (description.contains(food.name.toLowerCase()) ||
            _SampleFood.values.any(
              (sample) =>
                  sample.appearsIn(food.name.toLowerCase()) &&
                  sample.appearsIn(description),
            ))
          (meal: meal, index: index, food: food),
  ];
  if (grams == null || matches.length != 1) return false;
  final match = matches.single;
  final edited = _foodWithGrams(match.food, grams);
  if (edited == null) return false;
  match.meal.foods[match.index] = edited;
  return true;
}

double? _describedGrams(String text) {
  final matches = _grams.allMatches(text).toList();
  if (matches.length != 1) return null;
  final grams = parseNutritionAmount(matches.single.group(1)!);
  return grams != null && grams > 0 ? grams : null;
}

FoodEntry? _foodWithGrams(FoodEntry food, double grams) {
  if (foodTotalGrams(food, 1) == null) return null;
  final amount = grams / food.servingSizeGrams;
  return amount.isFinite && amount > 0 ? rescaleFoodAmount(food, amount) : null;
}
