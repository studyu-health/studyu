import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/nutrition/enums.dart';
import 'package:studyu_core/src/models/nutrition/food_composition.dart';
import 'package:studyu_core/src/models/nutrition/nutrition_profile.dart';
import 'package:studyu_core/src/models/nutrition/preparation_details.dart';
import 'package:uuid/uuid.dart';

part 'food_entry.g.dart';

@JsonSerializable()
class FoodEntry {
  /// UUID for this occurrence in a recall. It is never a definition ID.
  String id;

  /// Stable, subject-scoped definition identity.
  String foodId;

  /// Immutable definition revision used for this logged snapshot.
  String foodVersionId;

  /// Local serializer provenance. Absence in cached JSON is not verification.
  @JsonKey(defaultValue: false)
  bool availabilityVerified;

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
  String? parentEntryId;

  // Meal-specific fields
  PreparationDetails? preparationDetails;
  List<FoodComposition>? componentFoods;

  /// Ordered, immutable component snapshots for a saved meal definition.
  List<FoodEntry>? componentSnapshots;

  new({
    required this.id,
    required this.foodId,
    required this.foodVersionId,
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
    this.parentEntryId,
    this.preparationDetails,
    this.componentFoods,
    this.componentSnapshots,
    this.availabilityVerified = true,
  });

  new withId({
    String? foodId,
    String? foodVersionId,
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
    this.parentEntryId,
    this.preparationDetails,
    this.componentFoods,
    this.componentSnapshots,
    this.availabilityVerified = true,
  }) : id = const Uuid().v4(),
       foodId = foodId ?? const Uuid().v4(),
       foodVersionId = foodVersionId ?? const Uuid().v4(),
       createdAt = DateTime.now();

  factory fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final isLegacyRecipe = json['entryType'] == 'recipe';
    final food = _$FoodEntryFromJson({
      ...json,
      if (!json.containsKey('foodId')) 'foodId': _legacyIdentity('food', id),
      if (!json.containsKey('foodVersionId'))
        'foodVersionId': _legacyIdentity('version', id),
      if (!json.containsKey('parentEntryId'))
        'parentEntryId': json['parentRecipeId'],
      if (!json.containsKey('preparationDetails'))
        'preparationDetails': json['recipeMetadata'],
      if (isLegacyRecipe) ...{
        // Legacy recipes contain totals but no ingredient snapshots.
        'entryType': 'manualCustom',
        'originalValues': {
          ...?json['originalValues'] as Map<String, dynamic>?,
          '_legacyRecipeIngredients': json['recipeIngredients'],
        },
      },
    });
    if (!food.availabilityVerified) food.setAvailabilityVerified(false);
    return food;
  }

  static String _legacyIdentity(String kind, String entryId) => const Uuid().v5(
    Namespace.url.value,
    'studyu:nutrition:legacy:$kind:$entryId',
  );

  bool get canWriteAvailability =>
      availabilityVerified &&
      (componentSnapshots?.every((food) => food.canWriteAvailability) ?? true);

  /// Use true only for newly constructed data or canonical server responses.
  void setAvailabilityVerified(bool verified) {
    availabilityVerified = verified;
    for (final food in componentSnapshots ?? <FoodEntry>[]) {
      food.setAvailabilityVerified(verified);
    }
  }

  Map<String, dynamic> toJson() {
    final json = _$FoodEntryToJson(this);
    if (!availabilityVerified) json.remove('availabilityVerified');
    return json;
  }

  /// Local provenance must not change persisted definition identity.
  Map<String, dynamic> toJsonForStorage() => toJson()
    ..remove('availabilityVerified')
    ..addAll({
      if (componentSnapshots != null)
        'componentSnapshots': [
          for (final food in componentSnapshots!) food.toJsonForStorage(),
        ],
    });

  @override
  String toString() => toJson().toString();
}
