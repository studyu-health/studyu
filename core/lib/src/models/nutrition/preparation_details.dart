import 'package:json_annotation/json_annotation.dart';

part 'preparation_details.g.dart';

@JsonSerializable()
class PreparationDetails({
  required var double rawWeight,
  required var double cookedWeight,
  required var double yieldFactor,
  required var String preparationMethod,
  required var Map<String, double> retentionFactors,
}) {
  factory fromJson(Map<String, dynamic> json) =>
      _$PreparationDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PreparationDetailsToJson(this);

  @override
  String toString() => toJson().toString();
}
