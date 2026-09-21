import 'package:studyu_core/src/models/expressions/types/types.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';
import 'package:studyu_core/src/models/unknown_json_type_error.dart';

typedef ExpressionParser = Expression Function(Map<String, dynamic> data);

abstract class Expression(var String? type) {
  static const String keyType = 'type';
  factory fromJson(Map<String, dynamic> data) => switch (data[keyType]) {
    BooleanExpression.expressionType => BooleanExpression.fromJson(data),
    ChoiceExpression.expressionType => ChoiceExpression.fromJson(data),
    NotExpression.expressionType => NotExpression.fromJson(data),
    NumericExpression.expressionType => NumericExpression.fromJson(data),
    TextExpression.expressionType => TextExpression.fromJson(data),
    _ => throw UnknownJsonTypeError(data[keyType]),
  };

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expression &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() {
    return toJson().toString();
  }

  bool? evaluate(QuestionnaireState state);
}
