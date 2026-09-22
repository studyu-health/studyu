import 'package:studyu_core/src/models/expressions/expression.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';

abstract class ValueExpression<V>(String super.type) extends Expression {
  static const String expressionType = 'value';
  String? target;

  bool checkValue(V value);

  @override
  bool? evaluate(QuestionnaireState state) {
    return state.hasAnswer<V>(target!)
        ? checkValue(state.getAnswer<V>(target!))
        : null;
  }
}
