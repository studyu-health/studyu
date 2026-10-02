import 'package:json_annotation/json_annotation.dart';

part 'recipe_metadata.g.dart';

@JsonSerializable()
class RecipeMetadata({
  required var double rawWeight,
  required var double cookedWeight,
  required var double yieldFactor,
  required var String preparationMethod,
  required var Map<String, double> retentionFactors,
}) {
  factory fromJson(Map<String, dynamic> json) => _$RecipeMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeMetadataToJson(this);

  @override
  String toString() => toJson().toString();
}
