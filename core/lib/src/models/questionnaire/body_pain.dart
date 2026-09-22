import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/questionnaire/pain_type.dart';

part 'body_pain.g.dart';

@JsonSerializable()
class const BodyPain({final int painLevel = 0, final PainType? type}) {
  BodyPain copyWith({int? painLevel, PainType? type}) {
    return BodyPain(
      painLevel: painLevel ?? this.painLevel,
      type: type ?? this.type,
    );
  }

  factory fromJson(Map<String, dynamic> json) => _$BodyPainFromJson(json);

  Map<String, dynamic> toJson() => _$BodyPainToJson(this);
}
