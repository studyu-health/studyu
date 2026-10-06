import 'package:json_annotation/json_annotation.dart';

part 'nutrition_profile.g.dart';

@JsonSerializable()
class NutritionProfile({
  required var double energyKcal,
  required var double protein,
  required var double carbs,
  required var double fat,
  required var double sugars,
  required var double fiber,
  required var double saturatedFat,
  required var double transFat,
  required var double cholesterol,
  required var double sodium,
  required var double waterContent,
  required var Map<String, double> micros,

  /// Nutrients with no known value. Micronutrient keys use `micros.<name>`.
  var Set<String> unavailableNutrients = const {},

  /// Nutrients with a known subtotal but missing contributing values.
  var Set<String> partialNutrients = const {},

  /// Number of source items represented by this profile with missing data.
  @JsonKey(includeFromJson: false, includeToJson: false)
  var int unavailableItemCount = 0,
}) {
  factory fromJson(Map<String, dynamic> json) =>
      _$NutritionProfileFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$NutritionProfileToJson(this);
    // Empty metadata must not change legacy definition/version comparisons.
    if (unavailableNutrients.isEmpty) json.remove('unavailableNutrients');
    if (partialNutrients.isEmpty) json.remove('partialNutrients');
    return json;
  }

  /// Write-only protocol fields belong outside the scaled nutrition map.
  static const availabilityWriteIntentKey = 'nutritionAvailabilityWriteIntent';
  static const availabilityWriteIntent = 'explicit-v1';

  static const nutrientKeys = {
    'energyKcal',
    'protein',
    'carbs',
    'fat',
    'sugars',
    'fiber',
    'saturatedFat',
    'transFat',
    'cholesterol',
    'sodium',
    'waterContent',
  };

  bool isKnown(String key) =>
      !unavailableNutrients.contains(key) &&
      (!key.startsWith('micros.') || micros.containsKey(key.substring(7)));

  bool isPartial(String key) => isKnown(key) && partialNutrients.contains(key);

  double valueFor(String key) => switch (key) {
    'energyKcal' => energyKcal,
    'protein' => protein,
    'carbs' => carbs,
    'fat' => fat,
    'sugars' => sugars,
    'fiber' => fiber,
    'saturatedFat' => saturatedFat,
    'transFat' => transFat,
    'cholesterol' => cholesterol,
    'sodium' => sodium,
    'waterContent' => waterContent,
    _ when key.startsWith('micros.') => micros[key.substring(7)] ?? 0,
    _ => throw ArgumentError.value(key, 'key', 'Unknown nutrient'),
  };

  @override
  String toString() => toJson().toString();
}
