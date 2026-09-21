import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/expressions/expression.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';

part 'composite_expression.g.dart';

enum LogicType() {
  @JsonValue('and')
  and,
  @JsonValue('or')
  or;

  String toJson() => name;
  static LogicType fromJson(String json) => values.byName(json);
}

@JsonSerializable()
class CompositeExpression({
  required var LogicType logicType,
  required var List<Expression> expressions,
}) extends Expression {
  static const String expressionType = 'composite';

  // List of sub-expressions

  this : super(expressionType);

  factory fromJson(Map<String, dynamic> json) =>
      _$CompositeExpressionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CompositeExpressionToJson(this);

  @override
  bool? evaluate(QuestionnaireState state) {
    if (expressions.isEmpty) {
      return true; // No conditions means it's always true
    }

    // Evaluate all sub-expressions
    final evaluatedResults = expressions
        .map((exp) => exp.evaluate(state))
        .toList();

    switch (logicType) {
      case LogicType.and:
        if (evaluatedResults.contains(false)) return false;
        return evaluatedResults.contains(null) ? null : true;
      case LogicType.or:
        if (evaluatedResults.contains(true)) return true;
        return evaluatedResults.contains(null) ? null : false;
    }
  }
}
