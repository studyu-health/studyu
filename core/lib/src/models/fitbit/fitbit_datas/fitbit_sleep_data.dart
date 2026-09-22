import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/fitbit/fitbit_datas/fibit_data.dart';

part 'fitbit_sleep_data.g.dart';

@JsonSerializable()
class FitbitSleepData(
  var String level,
  var DateTime entryDateTime,
  DateTime dateTime,
) extends FitbitData {
  static const String dataType = 'sleep';
  this : super(dataType, dateTime);

  factory fromJson(Map<String, dynamic> json) =>
      _$FitbitSleepDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FitbitSleepDataToJson(this);
}
