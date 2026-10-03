import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/nutrition/enums.dart';
import 'package:studyu_core/src/models/nutrition/food_entry.dart';
import 'package:uuid/uuid.dart';

part 'meal_log.g.dart';

@JsonSerializable()
class MealLog {
  String id;
  MealType mealType;
  String? customMealLabel;

  /// True when a meal intentionally has no category label.
  /// Missing serialized values remain false for legacy MealType.other records.
  bool isLabelExplicitlyUnset;
  MealContext? mealContext;
  String? locationDescription;
  DateTime? timestamp;
  MealOccurrenceTimePrecision timePrecision;
  String timezone;
  bool isSkipped;
  String? skipReason;
  CompanyContext? companyContext;
  DistractionContext? distractionContext;
  String? templateId;
  List<FoodEntry> foods;

  new({
    required this.id,
    required this.mealType,
    this.customMealLabel,
    this.isLabelExplicitlyUnset = false,
    this.mealContext,
    this.locationDescription,
    this.timestamp,
    this.timePrecision = MealOccurrenceTimePrecision.approximate,
    required this.timezone,
    required this.isSkipped,
    this.skipReason,
    this.companyContext,
    this.distractionContext,
    this.templateId,
    required this.foods,
  });

  new withId({
    required this.mealType,
    this.customMealLabel,
    this.isLabelExplicitlyUnset = false,
    this.mealContext,
    this.locationDescription,
    this.timestamp,
    this.timePrecision = MealOccurrenceTimePrecision.approximate,
    required this.timezone,
    required this.isSkipped,
    this.skipReason,
    this.companyContext,
    this.distractionContext,
    this.templateId,
    required this.foods,
  }) : id = const Uuid().v4();

  /// The editor must distinguish an unanswered time from an unknown answer.
  bool hasValidTimeAnswer({required bool hasSelectedTime}) =>
      hasSelectedTime &&
      (timePrecision == MealOccurrenceTimePrecision.unknown
          ? timestamp == null
          : timestamp != null);

  bool isValidForSave({required bool hasSelectedTime}) => isSkipped
      ? skipReason?.trim().isNotEmpty == true
      : foods.isNotEmpty &&
            hasValidTimeAnswer(hasSelectedTime: hasSelectedTime);

  factory fromJson(Map<String, dynamic> json) => _$MealLogFromJson(json);

  Map<String, dynamic> toJson() => _$MealLogToJson(this);

  @override
  String toString() => toJson().toString();
}
