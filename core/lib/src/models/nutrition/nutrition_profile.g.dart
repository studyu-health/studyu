// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionProfile _$NutritionProfileFromJson(Map<String, dynamic> json) =>
    NutritionProfile(
      energyKcal: (json['energyKcal'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      sugars: (json['sugars'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      saturatedFat: (json['saturatedFat'] as num).toDouble(),
      transFat: (json['transFat'] as num).toDouble(),
      cholesterol: (json['cholesterol'] as num).toDouble(),
      sodium: (json['sodium'] as num).toDouble(),
      waterContent: (json['waterContent'] as num).toDouble(),
      micros: (json['micros'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$NutritionProfileToJson(NutritionProfile instance) =>
    <String, dynamic>{
      'energyKcal': instance.energyKcal,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'sugars': instance.sugars,
      'fiber': instance.fiber,
      'saturatedFat': instance.saturatedFat,
      'transFat': instance.transFat,
      'cholesterol': instance.cholesterol,
      'sodium': instance.sodium,
      'waterContent': instance.waterContent,
      'micros': instance.micros,
    };
