import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/expressions/types/value_expression.dart';

part 'choice_expression.g.dart';

@JsonSerializable()
class ChoiceExpression extends ValueExpression<dynamic> {
  static const String expressionType = 'choice';

  Set<dynamic> choices = {};

  new() : super(expressionType);

  new withId() : super(expressionType);

  factory fromJson(Map<String, dynamic> json) =>
      _$ChoiceExpressionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChoiceExpressionToJson(this);

  @override
  bool checkValue(dynamic value) {
    if (value is List) {
      // Legacy eligibility criteria use an empty set to mean no selection.
      if (choices.isEmpty) return value.isEmpty;
      return value.any((element) => choices.contains(element));
    }
    return choices.contains(value);
  }
}
