import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/expressions/types/value_expression.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';

part 'numeric_expression.g.dart';

enum NumericComparator() {
  @JsonValue('=')
  equal,
  @JsonValue('!=')
  notEqual,
  @JsonValue('>')
  greaterThan,
  @JsonValue('<')
  lessThan,
  @JsonValue('>=')
  greaterThanOrEqual,
  @JsonValue('<=')
  lessThanOrEqual,
}

@JsonSerializable()
class NumericExpression({
  required var NumericComparator comparator,
  required var num value,
}) extends ValueExpression<num> {
  // Use 'num' for int/double
  static const String expressionType = 'numeric';

  // The value to compare against

  this : super(expressionType);

  factory fromJson(Map<String, dynamic> json) =>
      _$NumericExpressionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NumericExpressionToJson(this);

  @override
  bool checkValue(num targetValue) {
    switch (comparator) {
      case NumericComparator.equal:
        return targetValue == value;
      case NumericComparator.notEqual:
        return targetValue != value;
      case NumericComparator.greaterThan:
        return targetValue > value;
      case NumericComparator.lessThan:
        return targetValue < value;
      case NumericComparator.greaterThanOrEqual:
        return targetValue >= value;
      case NumericComparator.lessThanOrEqual:
        return targetValue <= value;
    }
  }

  // Override evaluate to ensure we're comparing numbers, even if the answer is stored as a string or different numeric type
  @override
  bool? evaluate(QuestionnaireState state) {
    if (!state.hasAnswer<dynamic>(target!)) {
      // Check for dynamic first, then try to parse to num
      return null;
    }
    final dynamic answer = state.getAnswer<dynamic>(target!);
    if (answer is num) {
      return checkValue(answer);
    } else if (answer is String) {
      // Try to parse string answer to num if it's a number
      final parsedAnswer = num.tryParse(answer);
      if (parsedAnswer != null) {
        return checkValue(parsedAnswer);
      }
    }
    return null; // Cannot evaluate if answer is not a number or parsable string
  }
}
