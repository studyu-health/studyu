import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/nutrition/food_entry.dart';
import 'package:uuid/uuid.dart';

part 'saved_food_template.g.dart';

@JsonSerializable()
class SavedFoodTemplate {
  String id;
  String userId;
  String name;
  List<String>? tags;
  bool isPublic;
  DateTime createdAt;
  DateTime? updatedAt;
  FoodEntry prototype;

  new({
    required this.id,
    required this.userId,
    required this.name,
    this.tags,
    required this.isPublic,
    required this.createdAt,
    this.updatedAt,
    required this.prototype,
  });

  new withId({
    required this.userId,
    required this.name,
    this.tags,
    required this.isPublic,
    this.updatedAt,
    required this.prototype,
  }) : id = const Uuid().v4(),
       createdAt = DateTime.now();

  factory fromJson(Map<String, dynamic> json) =>
      _$SavedFoodTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$SavedFoodTemplateToJson(this);

  @override
  String toString() => toJson().toString();
}
