import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/expressions/types/value_expression.dart';

part 'text_expression.g.dart';

enum TextComparator() {
  @JsonValue('=')
  equal,
  @JsonValue('!=')
  notEqual,
  @JsonValue('contains')
  contains,
  @JsonValue('does_not_contain')
  doesNotContain,
  @JsonValue('length_greater_than')
  lengthGreaterThan,
  @JsonValue('length_less_than')
  lengthLessThan,
  @JsonValue('length_greater_than_or_equal')
  lengthGreaterThanOrEqual,
  @JsonValue('length_less_than_or_equal')
  lengthLessThanOrEqual,
  @JsonValue('length_equal')
  lengthEqual,
  @JsonValue('length_not_equal')
  lengthNotEqual,
}

@JsonSerializable()
class TextExpression({
  required var TextComparator comparator,
  required var String value,
}) extends ValueExpression<String> {
  static const String expressionType = 'text';

  // The text to compare against

  this : super(expressionType);

  factory fromJson(Map<String, dynamic> json) => _$TextExpressionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TextExpressionToJson(this);

  @override
  bool checkValue(String targetValue) {
    final lengthValue = int.tryParse(value);

    switch (comparator) {
      case TextComparator.equal:
        return targetValue == value;
      case TextComparator.notEqual:
        return targetValue != value;
      case TextComparator.contains:
        return targetValue.contains(value);
      case TextComparator.doesNotContain:
        return !targetValue.contains(value);
      case TextComparator.lengthGreaterThan:
        return lengthValue != null && targetValue.length > lengthValue;
      case TextComparator.lengthLessThan:
        return lengthValue != null && targetValue.length < lengthValue;
      case TextComparator.lengthGreaterThanOrEqual:
        return lengthValue != null && targetValue.length >= lengthValue;
      case TextComparator.lengthLessThanOrEqual:
        return lengthValue != null && targetValue.length <= lengthValue;
      case TextComparator.lengthEqual:
        return lengthValue != null && targetValue.length == lengthValue;
      case TextComparator.lengthNotEqual:
        return lengthValue != null && targetValue.length != lengthValue;
    }
  }
}
