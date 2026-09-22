import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'body_part.g.dart';

@JsonSerializable()
class const BodyPart({
  required final String id,
  required final String name,
  final BodyPain pain = const BodyPain(),
  final List<BodyPart> children = const [],
}) {
  BodyPart copyWith({
    String? id,
    String? name,
    BodyPain? pain,
    List<BodyPart>? children,
  }) {
    return BodyPart(
      id: id ?? this.id,
      name: name ?? this.name,
      pain: pain ?? this.pain,
      children: children ?? this.children,
    );
  }

  factory fromJson(Map<String, dynamic> json) => _$BodyPartFromJson(json);

  Map<String, dynamic> toJson() => _$BodyPartToJson(this);
}
