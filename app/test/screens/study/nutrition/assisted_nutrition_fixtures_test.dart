import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/study/nutrition/assisted/assisted_nutrition_fixtures.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_core/core.dart';

void main() {
  final day = DateTime.utc(2026, 11, 21);

  test('uses the edited description, photo numbers and diary day', () {
    final suggestions = assistedNutritionSuggestions(
      description:
          'Photo 2 shows oatmeal at exactly 8:15 am. '
          'Photo 1 shows 80 g of potato salad at lunch.',
      photoCount: 2,
      diaryDay: day,
      languageCode: 'en',
    );
    expect(suggestions.map((item) => item.photoIndex), [1, 0]);
    final breakfast = suggestions.first.meal;
    expect(breakfast.timePrecision, MealOccurrenceTimePrecision.exact);
    expect(breakfast.timestamp!.hour, 8);
    expect(breakfast.timestamp!.toUtc().isBefore(day), isFalse);
    expect(
      breakfast.timestamp!.toUtc().isBefore(day.add(const Duration(days: 1))),
      isTrue,
    );
    final lunch = suggestions.last.meal;
    expect(lunch.timePrecision, MealOccurrenceTimePrecision.unknown);
    expect(lunch.timestamp, isNull);
    expect(lunch.foods.single.amount, 80);
  });

  test('sorts mixed units and preserves order at equal or unknown weights', () {
    final suggestions = assistedNutritionSuggestions(
      description: '',
      photoCount: 2,
      diaryDay: day,
      languageCode: 'en',
    );
    final bowl = suggestions.first.meal.foods.single;
    final dumplings = suggestions.last.meal.foods.first;
    final salad = suggestions.last.meal.foods.last;
    final sameWeight = rescaleFoodAmount(salad, 150);
    final unknownFirst = duplicateFoodEntry(salad)..servingSizeGrams = 0;
    final unknownSecond = duplicateFoodEntry(dumplings)..servingSizeGrams = 0;
    expect(
      orderAssistedFoodsByWeight([
        unknownFirst,
        sameWeight,
        dumplings,
        unknownSecond,
        bowl,
      ]),
      [bowl, sameWeight, dumplings, unknownFirst, unknownSecond],
    );
  });

  test('updates the portion without restoring the initial review order', () {
    final suggestions = assistedNutritionSuggestions(
      description: 'I had Maultaschen and potato salad.',
      photoCount: 0,
      diaryDay: day,
      languageCode: 'en',
    );
    final meal = suggestions.single.meal;
    meal.foods = meal.foods.reversed.toList();
    final ids = meal.foods.map((food) => food.id).toList();
    expect(
      applyAssistedNutritionCorrection([meal], 'I had 75 g of potato salad.'),
      isTrue,
    );
    expect(meal.foods.map((food) => food.id), ids);
    expect(meal.foods.first.amount, 75);
    expect(meal.foods.last.amount, 150);
  });
}
