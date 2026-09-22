import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'question_conditional.g.dart';

@JsonSerializable()
class QuestionConditional<V> {
  static const String keyDefaultValue = 'defaultValue';
  @JsonKey(includeToJson: false, includeFromJson: false)
  V? defaultValue;

  late CompositeExpression condition;

  new();

  new withCondition(this.condition, {this.defaultValue});

  factory fromJson(Map<String, dynamic> json) => _fromJson(json);

  static QuestionConditional<V> _fromJson<K, V>(Map<String, dynamic> json) {
    final instance = _$QuestionConditionalFromJson<V>(json)
      ..defaultValue = json[keyDefaultValue] as V?;

    // --- DOWNWARD COMPATIBILITY HACK ---
    // If 'condition' in the JSON is not a map with 'type: composite',
    // it means it's an old single Expression. Wrap it in a CompositeExpression.
    if (json['condition'] is Map<String, dynamic> &&
        (json['condition'] as Map<String, dynamic>)['type'] !=
            CompositeExpression.expressionType) {
      final oldConditionMap = json['condition'] as Map<String, dynamic>;
      final oldExpression = Expression.fromJson(oldConditionMap);
      instance.condition = CompositeExpression(
        logicType: LogicType.and, // Default to AND for single old conditions
        expressions: [oldExpression],
      );
    } else if (json['condition'] == null) {
      // Handle cases where 'condition' might be missing (e.g., old data without any condition)
      instance.condition = CompositeExpression(
        logicType: LogicType.and,
        expressions: [],
      );
    }
    // --- END DOWNWARD COMPATIBILITY HACK ---

    return instance;
  }

  Map<String, dynamic> toJson() =>
      _$QuestionConditionalToJson<V>(this)..[keyDefaultValue] = defaultValue;

  @override
  String toString() {
    return toJson().toString();
  }
}

extension QuestionConditionalCopy on QuestionConditional {
  QuestionConditional deepCopy() {
    return QuestionConditional.fromJson(toJson());
  }
}
