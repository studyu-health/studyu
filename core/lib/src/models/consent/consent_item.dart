import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'consent_item.g.dart';

@JsonSerializable()
class ConsentItem {
  String id;
  String? title;
  String? description;
  String iconName = 'textBoxCheck';

  new(this.id);

  new withId() : id = const Uuid().v4();

  factory fromJson(Map<String, dynamic> json) => _$ConsentItemFromJson(json);
  Map<String, dynamic> toJson() => _$ConsentItemToJson(this);

  @override
  String toString() => toJson().toString();
}
