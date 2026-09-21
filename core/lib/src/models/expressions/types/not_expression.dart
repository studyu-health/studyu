import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/expressions/expression.dart';
import 'package:studyu_core/src/models/expressions/types/boolean_expression.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';

part 'not_expression.g.dart';

@JsonSerializable()
class NotExpression extends Expression {
  static const String expressionType = 'not';

  late Expression expression;

  new() : super(expressionType);

  new withId() : expression = BooleanExpression(), super(expressionType);

  factory fromJson(Map<String, dynamic> json) => _$NotExpressionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NotExpressionToJson(this);

  @override
  bool? evaluate(QuestionnaireState state) {
    final bool? result = expression.evaluate(state);
    return result != null ? !result : result;
  }
}
