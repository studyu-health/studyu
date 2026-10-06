import 'dart:convert';

import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

NutritionProfile profile({
  double value = 0,
  Set<String> unavailable = const {},
  Set<String> partial = const {},
  Map<String, double> micros = const {},
}) => NutritionProfile(
  energyKcal: value,
  protein: value,
  carbs: value,
  fat: value,
  sugars: value,
  fiber: value,
  saturatedFat: value,
  transFat: value,
  cholesterol: value,
  sodium: value,
  waterContent: value,
  micros: Map.of(micros),
  unavailableNutrients: unavailable,
  partialNutrients: partial,
);

NutritionProfile roundTrip(NutritionProfile source) =>
    NutritionProfile.fromJson(
      jsonDecode(jsonEncode(source.toJson())) as Map<String, dynamic>,
    );

void main() {
  test('legacy numeric JSON stays stable and zero stays known', () {
    for (final value in [0.0, 12.5]) {
      final legacy = profile(value: value, micros: {'iron': 0}).toJson();
      expect(legacy, isNot(contains('unavailableNutrients')));
      expect(legacy, isNot(contains('partialNutrients')));
      final hydrated = NutritionProfile.fromJson(legacy);
      expect(hydrated.toJson(), legacy);
      for (final key in NutritionProfile.nutrientKeys) {
        expect(hydrated.isKnown(key), isTrue, reason: key);
        expect(hydrated.valueFor(key), value, reason: key);
      }
      expect(hydrated.isKnown('micros.iron'), isTrue);
      expect(hydrated.micros['iron'], 0);
    }
  });

  test(
    'unknown and partial metadata survive JSON without numeric metadata',
    () {
      final original = profile(
        value: 99,
        unavailable: {'protein', 'micros.iron'},
        partial: {'fiber', 'micros.zinc'},
        micros: {'iron': 99, 'zinc': 0},
      )..unavailableItemCount = 3;
      final copy = roundTrip(original);
      expect(copy.toJson(), original.toJson());
      expect(copy.isKnown('protein'), isFalse);
      expect(copy.isKnown('micros.iron'), isFalse);
      expect(copy.isPartial('fiber'), isTrue);
      expect(copy.isPartial('micros.zinc'), isTrue);
      expect(copy.toJson(), isNot(contains('unavailableItemCount')));
      copy.unavailableNutrients.add('fat');
      expect(original.unavailableNutrients, {'protein', 'micros.iron'});
    },
  );

  test('scaling copies availability and does not mutate source', () {
    final original = profile(
      value: 7,
      unavailable: {'protein'},
      partial: {'fiber'},
      micros: {'iron': 2},
    )..unavailableItemCount = 2;
    final before = jsonEncode(original.toJson());
    final scaled = scaleNutritionProfile(original, 3);
    expect(scaled.energyKcal, 21);
    expect(scaled.micros['iron'], 6);
    expect(scaled.unavailableNutrients, {'protein'});
    expect(scaled.partialNutrients, {'fiber'});
    expect(scaled.unavailableItemCount, 2);
    scaled.unavailableNutrients.add('fat');
    scaled.partialNutrients.clear();
    scaled.micros['iron'] = 0;
    expect(jsonEncode(original.toJson()), before);
  });

  for (final key in NutritionProfile.nutrientKeys) {
    test('$key distinguishes complete, partial, unknown and measured zero', () {
      final known = profile(value: 10);
      final unknown = profile(value: 999, unavailable: {key});
      final before = jsonEncode(unknown.toJson());
      final complete = sumNutritionProfiles([known, known]);
      expect(complete.valueFor(key), 20);
      expect(complete.isKnown(key), isTrue);
      expect(complete.isPartial(key), isFalse);
      final mixed = sumNutritionProfiles([known, unknown]);
      expect(mixed.valueFor(key), 10);
      expect(mixed.isKnown(key), isTrue);
      expect(mixed.isPartial(key), isTrue);
      final missing = sumNutritionProfiles([unknown, unknown]);
      expect(missing.valueFor(key), 0);
      expect(missing.isKnown(key), isFalse);
      expect(missing.isPartial(key), isFalse);
      final zero = sumNutritionProfiles([profile(), unknown]);
      expect(zero.valueFor(key), 0);
      expect(zero.isKnown(key), isTrue);
      expect(zero.isPartial(key), isTrue);
      final nested = sumNutritionProfiles([roundTrip(mixed), known]);
      expect(nested.valueFor(key), 20);
      expect(nested.isPartial(key), isTrue);
      expect(jsonEncode(unknown.toJson()), before);
    });
  }

  test('micronutrient sums exclude unknown placeholders and absent values', () {
    final mixed = sumNutritionProfiles([
      profile(micros: {'iron': 0, 'zinc': 3}),
      profile(micros: {'iron': 99}, unavailable: {'micros.iron'}),
    ]);
    expect(mixed.micros, {'iron': 0, 'zinc': 3});
    expect(mixed.isKnown('micros.iron'), isTrue);
    expect(mixed.isPartial('micros.iron'), isTrue);
    expect(mixed.isPartial('micros.zinc'), isTrue);
    final unknown = sumNutritionProfiles([
      profile(micros: {'iron': 99}, unavailable: {'micros.iron'}),
      profile(),
    ]);
    expect(unknown.isKnown('micros.iron'), isFalse);
    expect(unknown.micros['iron'], 0);
    expect(
      sumNutritionProfiles([roundTrip(mixed)]).partialNutrients,
      containsAll(['micros.iron', 'micros.zinc']),
    );
  });

  test('empty aggregate has no known values', () {
    final empty = sumNutritionProfiles([]);
    expect(empty.unavailableNutrients, NutritionProfile.nutrientKeys);
    expect(empty.partialNutrients, isEmpty);
  });
}
