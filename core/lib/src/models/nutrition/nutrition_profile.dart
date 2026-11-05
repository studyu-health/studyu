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
}) {
  factory fromJson(Map<String, dynamic> json) =>
      _$NutritionProfileFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionProfileToJson(this);

  @override
  String toString() => toJson().toString();
}
