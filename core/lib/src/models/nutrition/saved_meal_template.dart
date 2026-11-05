import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/nutrition/enums.dart';
import 'package:studyu_core/src/models/nutrition/food_entry.dart';
import 'package:uuid/uuid.dart';

part 'saved_meal_template.g.dart';

@JsonSerializable()
class SavedMealTemplate {
  String id;
  String userId;
  String name;
  MealType mealType;
  List<String>? tags;
  bool isPublic;
  DateTime createdAt;
  DateTime? updatedAt;
  List<FoodEntry> prototypes;

  new({
    required this.id,
    required this.userId,
    required this.name,
    required this.mealType,
    this.tags,
    required this.isPublic,
    required this.createdAt,
    this.updatedAt,
    required this.prototypes,
  });

  new withId({
    required this.userId,
    required this.name,
    required this.mealType,
    this.tags,
    required this.isPublic,
    this.updatedAt,
    required this.prototypes,
  }) : id = const Uuid().v4(),
       createdAt = DateTime.now();

  factory fromJson(Map<String, dynamic> json) =>
      _$SavedMealTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$SavedMealTemplateToJson(this);

  @override
  String toString() => toJson().toString();
}
