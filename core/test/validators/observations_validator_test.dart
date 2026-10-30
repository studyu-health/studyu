import 'package:studyu_core/src/models/observations/tasks/questionnaire_task.dart';
import 'package:studyu_core/src/models/questionnaire/questions/boolean_question.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/observations_validator.dart';
import 'package:test/test.dart';

Study _studyWithObs(List<dynamic> observations) {
  final s = Study('id', 'user');
  s.observations = observations.cast();
  return s;
}

QuestionnaireTask _obs(String id) {
  final o = QuestionnaireTask.withId();
  o.id = id;
  return o;
}

void main() {
  test('no observations -> passes', () {
    final r = validateObservations(_studyWithObs([]), ValidationLevel.draft);
    expect(r.valid, isTrue);
  });

  test('two observations with unique IDs -> passes', () {
    final r = validateObservations(
      _studyWithObs([_obs('obs-a'), _obs('obs-b')]),
      ValidationLevel.draft,
    );
    expect(r.valid, isTrue);
  });

  test(
    'two observations with same ID -> observations.duplicate_observation_id',
    () {
      final r = validateObservations(
        _studyWithObs([_obs('dup-id'), _obs('dup-id')]),
        ValidationLevel.draft,
      );
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'observations.duplicate_observation_id'),
        isTrue,
      );
    },
  );

  test('validates questionnaire content inside observations', () {
    final observation = _obs('obs')
      ..questions.questions = [BooleanQuestion.withId()..prompt = ''];

    final result = validateObservations(
      _studyWithObs([observation]),
      ValidationLevel.publish,
    );

    expect(
      result.errors.any((error) => error.code == 'question.prompt_required'),
      isTrue,
    );
  });

  test('detects duplicate question IDs across observation questionnaires', () {
    final first = _obs('first')
      ..questions.questions = [BooleanQuestion.withId()..id = 'shared'];
    final second = _obs('second')
      ..questions.questions = [BooleanQuestion.withId()..id = 'shared'];

    final result = validateObservations(
      _studyWithObs([first, second]),
      ValidationLevel.draft,
    );

    expect(
      result.errors.any(
        (error) =>
            error.code == 'questionnaire.duplicate_question_id_cross_context',
      ),
      isTrue,
    );
  });

  test(
    'three observations: first and third share ID -> one error at index 2',
    () {
      final r = validateObservations(
        _studyWithObs([_obs('id-a'), _obs('id-b'), _obs('id-a')]),
        ValidationLevel.draft,
      );
      expect(r.valid, isFalse);
      expect(r.errors.length, 1);
      expect(r.errors.first.code, 'observations.duplicate_observation_id');
      expect(r.errors.first.path, contains('[2]'));
    },
  );
}
