import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/fitbit/fitbit_datas/fibit_data.dart';

part 'fitbit_heart_data.g.dart';

@JsonSerializable()
class FitbitHeartData(var double value, DateTime dateTime) extends FitbitData {
  static const String dataType = 'heartrate';
  this : super(dataType, dateTime);

  factory fromJson(Map<String, dynamic> json) =>
      _$FitbitHeartDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FitbitHeartDataToJson(this);
}
