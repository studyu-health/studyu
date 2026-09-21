import 'package:json_annotation/json_annotation.dart';

part 'pain_type.g.dart';

@JsonSerializable()
class const PainType(final String name) {
  factory fromJson(Map<String, dynamic> json) => _$PainTypeFromJson(json);

  Map<String, dynamic> toJson() => _$PainTypeToJson(this);
}
