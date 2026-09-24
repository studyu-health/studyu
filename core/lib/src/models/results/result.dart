import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/nutrition/daily_recall.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';
import 'package:studyu_core/src/models/unknown_json_type_error.dart';

part 'result.g.dart';

@JsonSerializable()
class Result<T> {
  static const keyType = 'type';
  String type;
  // Todo make non-nullable (breaks backwards compatibility)
  String? periodId;

  static const String keyResult = 'result';

  @JsonKey(includeToJson: false, includeFromJson: false)
  late T result;

  new(this.type);

  new app({required this.type, required this.periodId, required this.result});

  factory parseJson(Map<String, dynamic> json) => _$ResultFromJson(json);

  factory fromJson(Map<String, dynamic> json) => switch (json[keyType]) {
    'QuestionnaireState' =>
      Result<QuestionnaireState>.parseJson(json)
        ..result = QuestionnaireState.fromJson(
          List<Map<String, dynamic>>.from(json[keyResult] as List),
        ),
    'DailyRecall' => Result<DailyRecall>.parseJson(
      json,
    )..result = DailyRecall.fromJson(json[keyResult] as Map<String, dynamic>),
    'bool' => Result<bool>.parseJson(json)..result = json[keyResult] as bool,
    _ => throw UnknownJsonTypeError(json[keyType]),
  } as Result<T>;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> resultMap = switch (type) {
      'QuestionnaireState' => {
        keyResult: (result as QuestionnaireState).toJson(),
      },
      'DailyRecall' => {keyResult: (result as DailyRecall).toJson()},
      'bool' => {keyResult: result},
      _ => throw ArgumentError('Unknown result type $type'),
    };
    return mergeMaps<String, dynamic>(_$ResultToJson(this), resultMap);
  }
}
