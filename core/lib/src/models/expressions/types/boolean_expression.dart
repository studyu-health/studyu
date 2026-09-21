import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/expressions/types/value_expression.dart';

part 'boolean_expression.g.dart';

@JsonSerializable()
class BooleanExpression() extends ValueExpression<bool> {
  static const String expressionType = 'boolean';

  this : super(expressionType);

  factory fromJson(Map<String, dynamic> json) =>
      _$BooleanExpressionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BooleanExpressionToJson(this);

  @override
  bool checkValue(bool value) => value;
}
