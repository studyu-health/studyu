import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/expressions/expression.dart';
import 'package:studyu_core/src/models/expressions/types/boolean_expression.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';
import 'package:uuid/uuid.dart';

part 'eligibility_criterion.g.dart';

@JsonSerializable()
class EligibilityCriterion {
  String id;
  String? reason;
  late Expression condition;

  new(this.id);

  new withId() : id = const Uuid().v4(), condition = BooleanExpression();

  factory fromJson(Map<String, dynamic> data) =>
      _$EligibilityCriterionFromJson(data);
  Map<String, dynamic> toJson() => _$EligibilityCriterionToJson(this);

  bool isSatisfied(QuestionnaireState qs) => condition.evaluate(qs) == true;
  bool isViolated(QuestionnaireState qs) => condition.evaluate(qs) == false;

  // does not compare id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EligibilityCriterion &&
          runtimeType == other.runtimeType &&
          reason == other.reason &&
          condition == other.condition;

  @override
  int get hashCode => reason.hashCode ^ condition.hashCode;

  @override
  String toString() {
    return 'EligibilityCriterion{id: $id, reason: $reason, condition: $condition}';
  }
}
