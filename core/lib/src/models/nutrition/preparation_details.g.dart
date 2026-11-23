// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preparation_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreparationDetails _$PreparationDetailsFromJson(Map<String, dynamic> json) =>
    PreparationDetails(
      rawWeight: (json['rawWeight'] as num).toDouble(),
      cookedWeight: (json['cookedWeight'] as num).toDouble(),
      yieldFactor: (json['yieldFactor'] as num).toDouble(),
      preparationMethod: json['preparationMethod'] as String,
      retentionFactors: (json['retentionFactors'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$PreparationDetailsToJson(PreparationDetails instance) =>
    <String, dynamic>{
      'rawWeight': instance.rawWeight,
      'cookedWeight': instance.cookedWeight,
      'yieldFactor': instance.yieldFactor,
      'preparationMethod': instance.preparationMethod,
      'retentionFactors': instance.retentionFactors,
    };
