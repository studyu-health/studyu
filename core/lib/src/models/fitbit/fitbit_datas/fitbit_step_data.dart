import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/fitbit/fitbit_datas/fibit_data.dart';

part 'fitbit_step_data.g.dart';

@JsonSerializable()
class FitbitStepData(var double value, DateTime dateTime) extends FitbitData {
  static const String dataType = 'steps';
  this : super(dataType, dateTime);

  factory fromJson(Map<String, dynamic> json) => _$FitbitStepDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FitbitStepDataToJson(this);
}
