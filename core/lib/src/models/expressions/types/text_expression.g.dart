// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextExpression _$TextExpressionFromJson(Map<String, dynamic> json) =>
    TextExpression(
        comparator: $enumDecode(_$TextComparatorEnumMap, json['comparator']),
        value: json['value'] as String,
      )
      ..type = json['type'] as String?
      ..target = json['target'] as String?;

Map<String, dynamic> _$TextExpressionToJson(TextExpression instance) =>
    <String, dynamic>{
      'type': ?instance.type,
      'target': ?instance.target,
      'comparator': _$TextComparatorEnumMap[instance.comparator]!,
      'value': instance.value,
    };

const _$TextComparatorEnumMap = {
  TextComparator.equal: '=',
  TextComparator.notEqual: '!=',
  TextComparator.contains: 'contains',
  TextComparator.doesNotContain: 'does_not_contain',
  TextComparator.lengthGreaterThan: 'length_greater_than',
  TextComparator.lengthLessThan: 'length_less_than',
  TextComparator.lengthGreaterThanOrEqual: 'length_greater_than_or_equal',
  TextComparator.lengthLessThanOrEqual: 'length_less_than_or_equal',
  TextComparator.lengthEqual: 'length_equal',
  TextComparator.lengthNotEqual: 'length_not_equal',
};
