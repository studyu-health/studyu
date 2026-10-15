import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'recipe_composition.g.dart';

@JsonSerializable()
class RecipeComposition {
  String id;
  String recipeId;
  String ingredientId;
  double amount;
  String unit;
  int? sortOrder;

  new({
    required this.id,
    required this.recipeId,
    required this.ingredientId,
    required this.amount,
    required this.unit,
    this.sortOrder,
  });

  new withId({
    required this.recipeId,
    required this.ingredientId,
    required this.amount,
    required this.unit,
    this.sortOrder,
  }) : id = const Uuid().v4();

  factory fromJson(Map<String, dynamic> json) =>
      _$RecipeCompositionFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeCompositionToJson(this);

  @override
  String toString() => toJson().toString();
}
