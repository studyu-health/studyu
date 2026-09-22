import 'package:json_annotation/json_annotation.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact() {
  String organization = '';
  String? institutionalReviewBoard = '';
  String? institutionalReviewBoardNumber = '';
  String? researchers = '';
  String email = '';
  String website = '';
  String phone = '';
  String? additionalInfo;

  factory fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);

  Map<String, dynamic> toJson() => _$ContactToJson(this);

  @override
  String toString() => toJson().toString();
}
