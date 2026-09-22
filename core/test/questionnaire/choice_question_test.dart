import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('selection is optional when the stored setting is absent', () {
    final question = ChoiceQuestion.fromJson({
      'type': ChoiceQuestion.questionType,
      'id': 'question-id',
      'multiple': true,
      'choices': <Map<String, dynamic>>[],
    });

    expect(question.selectionRequired, isFalse);
  });
}
