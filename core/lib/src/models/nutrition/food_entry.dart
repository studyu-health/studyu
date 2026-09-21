import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/nutrition/enums.dart';
import 'package:studyu_core/src/models/nutrition/nutrition_profile.dart';
import 'package:studyu_core/src/models/nutrition/recipe_composition.dart';
import 'package:studyu_core/src/models/nutrition/recipe_metadata.dart';
import 'package:uuid/uuid.dart';

part 'food_entry.g.dart';

@JsonSerializable()
class FoodEntry {
  String id;
  FoodEntryType entryType;
  String name;
  String? brandName;
  String? description;
  double amount;
  String unit;
  double servingSizeGrams;
  String? portionReference;
  PortionEstimationMethod portionEstimationMethod;
  PortionState portionState;
  double? yieldFactor;
  double? ediblePortion;
  NutritionProfile nutrition;
  String? foodCode;
  String? externalId;
  FoodSource source;
  double confidenceScore;
  String? templateId;
  DateTime createdAt;
  DateTime? modifiedAt;
  Map<String, dynamic> originalValues;
  String? parentRecipeId;

  // Recipe-specific fields
  RecipeMetadata? recipeMetadata;
  List<RecipeComposition>? recipeIngredients;

  new({
    required this.id,
    required this.entryType,
    required this.name,
    this.brandName,
    this.description,
    required this.amount,
    required this.unit,
    required this.servingSizeGrams,
    this.portionReference,
    required this.portionEstimationMethod,
    required this.portionState,
    this.yieldFactor,
    this.ediblePortion,
    required this.nutrition,
    this.foodCode,
    this.externalId,
    required this.source,
    required this.confidenceScore,
    this.templateId,
    required this.createdAt,
    this.modifiedAt,
    required this.originalValues,
    this.parentRecipeId,
    this.recipeMetadata,
    this.recipeIngredients,
  });

  new withId({
    required this.entryType,
    required this.name,
    this.brandName,
    this.description,
    required this.amount,
    required this.unit,
    required this.servingSizeGrams,
    this.portionReference,
    required this.portionEstimationMethod,
    required this.portionState,
    this.yieldFactor,
    this.ediblePortion,
    required this.nutrition,
    this.foodCode,
    this.externalId,
    required this.source,
    required this.confidenceScore,
    this.templateId,
    this.modifiedAt,
    required this.originalValues,
    this.parentRecipeId,
    this.recipeMetadata,
    this.recipeIngredients,
  }) : id = const Uuid().v4(),
       createdAt = DateTime.now();

  factory fromJson(Map<String, dynamic> json) => _$FoodEntryFromJson(json);

  Map<String, dynamic> toJson() => _$FoodEntryToJson(this);

  @override
  String toString() => toJson().toString();
}
