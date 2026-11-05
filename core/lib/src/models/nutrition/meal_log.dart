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
  MealContext mealContext;
  String? locationDescription;
  DateTime timestamp;
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
    required this.mealContext,
    this.locationDescription,
    required this.timestamp,
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
    required this.mealContext,
    this.locationDescription,
    required this.timestamp,
    required this.timezone,
    required this.isSkipped,
    this.skipReason,
    this.companyContext,
    this.distractionContext,
    this.templateId,
    required this.foods,
  }) : id = const Uuid().v4();

  factory fromJson(Map<String, dynamic> json) => _$MealLogFromJson(json);

  Map<String, dynamic> toJson() => _$MealLogToJson(this);

  @override
  String toString() => toJson().toString();
}
