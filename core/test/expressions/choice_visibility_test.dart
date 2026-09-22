import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

QuestionnaireState _stateWithChoices(List<String> choices) {
  final question = ChoiceQuestion.withId()..id = 'choice';
  return QuestionnaireState()
    ..answers[question.id] = question.constructAnswer(
      choices.map((id) => Choice.withText(id: id, text: id)).toList(),
    );
}

ChoiceExpression _choiceExpression(String target, String choice) =>
    ChoiceExpression()
      ..target = target
      ..choices = {choice};

void main() {
  test('empty choice answers match no choices', () {
    final state = _stateWithChoices([]);
    final isChoice = _choiceExpression('choice', 'a');

    expect(isChoice.evaluate(state), isFalse);
    expect((NotExpression()..expression = isChoice).evaluate(state), isTrue);
  });

  test('selected choices support matching, negation, AND, and OR', () {
    final state = _stateWithChoices(['a', 'b']);
    final isA = _choiceExpression('choice', 'a');
    final isB = _choiceExpression('choice', 'b');
    final isC = _choiceExpression('choice', 'c');

    expect(isA.evaluate(state), isTrue);
    expect((NotExpression()..expression = isC).evaluate(state), isTrue);
    expect(
      CompositeExpression(
        logicType: LogicType.and,
        expressions: [isA, isB],
      ).evaluate(state),
      isTrue,
    );
    expect(
      CompositeExpression(
        logicType: LogicType.or,
        expressions: [isC, isB],
      ).evaluate(state),
      isTrue,
    );
  });

  test('empty expression choices match only empty answers', () {
    final noChoices = ChoiceExpression()
      ..target = 'choice'
      ..choices = {};

    expect(noChoices.evaluate(_stateWithChoices([])), isTrue);
    expect(noChoices.evaluate(_stateWithChoices(['a'])), isFalse);
  });

  test('composite expressions preserve decisive results with unknowns', () {
    final state = _stateWithChoices(['a']);
    final isA = _choiceExpression('choice', 'a');
    final isB = _choiceExpression('choice', 'b');
    final unanswered = _choiceExpression('unanswered', 'a');

    expect(
      CompositeExpression(
        logicType: LogicType.or,
        expressions: [isA, unanswered],
      ).evaluate(state),
      isTrue,
    );
    expect(
      CompositeExpression(
        logicType: LogicType.and,
        expressions: [isB, unanswered],
      ).evaluate(state),
      isFalse,
    );
    expect(
      CompositeExpression(
        logicType: LogicType.or,
        expressions: [isB, unanswered],
      ).evaluate(state),
      isNull,
    );
    expect(
      CompositeExpression(
        logicType: LogicType.and,
        expressions: [isA, unanswered],
      ).evaluate(state),
      isNull,
    );
  });
}
