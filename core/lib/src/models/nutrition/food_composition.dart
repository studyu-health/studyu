import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'food_composition.g.dart';

@JsonSerializable()
class FoodComposition {
  String id;
  String parentEntryId;
  String foodId;
  double amount;
  String unit;
  int? sortOrder;

  new({
    required this.id,
    required this.parentEntryId,
    required this.foodId,
    required this.amount,
    required this.unit,
    this.sortOrder,
  });

  new withId({
    required this.parentEntryId,
    required this.foodId,
    required this.amount,
    required this.unit,
    this.sortOrder,
  }) : id = const Uuid().v4();

  factory fromJson(Map<String, dynamic> json) =>
      _$FoodCompositionFromJson(json);

  Map<String, dynamic> toJson() => _$FoodCompositionToJson(this);

  @override
  String toString() => toJson().toString();
}
