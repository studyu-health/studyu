import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('empty multi-choice answer satisfies the none-selected criterion', () {
    final question = ChoiceQuestion.withId()..id = 'red_flags';
    final state = QuestionnaireState()
      ..answers[question.id] = Answer<List<String>>.forQuestion(
        question,
        <String>[],
      );
    final criterion = EligibilityCriterion.withId()
      ..condition = (ChoiceExpression()
        ..target = question.id
        ..choices = <dynamic>{});

    expect(criterion.condition.evaluate(state), isTrue);
    expect(criterion.isSatisfied(state), isTrue);
    expect(criterion.isViolated(state), isFalse);
  });
}
