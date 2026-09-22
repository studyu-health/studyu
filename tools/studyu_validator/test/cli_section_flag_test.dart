import 'dart:convert';

import 'package:studyu_core/core.dart';
import 'package:studyu_core/testing.dart';
import 'package:studyu_validator/studyu_validator.dart';
import 'package:test/test.dart';

void main() {
  group('section validation', () {
    test('runs only the requested section', () {
      final study = StudyFixtures.minimal();

      final result = validateJson(
        jsonEncode(study.toJson()),
        section: 'study_info',
      );

      expect(result['valid'], isTrue);
    });

    test('observations section validates questionnaire content', () {
      final study = StudyFixtures.minimal();
      final observation = QuestionnaireTask.withId()
        ..questions.questions = [BooleanQuestion.withId()..prompt = ''];
      study.observations = [observation];

      final result = validateJson(
        jsonEncode(study.toJson()),
        level: 'publish',
        section: 'observations',
      );

      expect(result['valid'], isFalse);
      expect(
        (result['errors'] as List).cast<Map<String, dynamic>>().map(
          (error) => error['code'],
        ),
        contains('question.prompt_required'),
      );
    });

    test('rejects unknown sections at the adapter boundary', () {
      expect(
        () => validateJson(
          jsonEncode(StudyFixtures.minimal().toJson()),
          section: 'unknown',
        ),
        throwsArgumentError,
      );
    });
  });

  test('schema accepts subject progress started_at consumed by core', () {
    final startedAt = DateTime.utc(2025, 1, 2, 3, 4, 5);
    final progressJson = _progressJson(
      Result<bool>.app(type: 'bool', periodId: 'period-id', result: true),
    )..['started_at'] = startedAt.toIso8601String();
    final studyJson = StudyFixtures.minimal().toJson()
      ..['subject_progress'] = [progressJson];

    final result = validateJson(jsonEncode(studyJson), schemaOnly: true);

    expect(
      result['valid'],
      isTrue,
      reason: const JsonEncoder.withIndent(' ').convert(result['errors']),
    );
    expect(SubjectProgress.fromJson(progressJson).startedAt, startedAt);
  });

  test('schema accepts payloads from supported Result serializers', () {
    final questionnaireState = QuestionnaireState();
    final answer = Answer<bool>('question-id', DateTime.utc(2025))
      ..response = true;
    questionnaireState.answers[answer.question] = answer;

    final serializedResults = [
      Result<bool>.app(type: 'bool', periodId: 'period-id', result: true),
      Result<QuestionnaireState>.app(
        type: 'QuestionnaireState',
        periodId: 'period-id',
        result: questionnaireState,
      ),
    ].map(_progressJson);

    for (final progressJson in serializedResults) {
      final studyJson = StudyFixtures.minimal().toJson()
        ..['subject_progress'] = [progressJson];
      final result = validateJson(jsonEncode(studyJson), schemaOnly: true);

      expect(
        result['valid'],
        isTrue,
        reason: const JsonEncoder.withIndent(' ').convert(result['errors']),
      );
      expect(SubjectProgress.fromJson(progressJson), isA<SubjectProgress>());
    }
  });

  test('schema accepts representative serialized subtypes', () {
    final study = StudyFixtures.fullValid();
    study.questionnaire.questions = [
      BooleanQuestion.withId()..prompt = 'Boolean?',
      ChoiceQuestion.withId()
        ..prompt = 'Choose'
        ..choices = [Choice.withText(text: 'One')],
      ScaleQuestion.withId()
        ..prompt = 'Scale'
        ..minimum = 0
        ..maximum = 10,
    ];
    study.observations = [
      QuestionnaireTask.withId()
        ..title = 'Observation'
        ..questions.questions = [BooleanQuestion.withId()..prompt = 'Daily?'],
    ];
    study.reportSpecification.primary = AverageSection.withId();

    final serialized = jsonEncode(study.toJson());
    final result = validateJson(serialized, schemaOnly: true);

    expect(
      result['valid'],
      isTrue,
      reason: const JsonEncoder.withIndent(' ').convert(result['errors']),
    );
    expect(
      Study.fromJson(jsonDecode(serialized) as Map<String, dynamic>),
      isA<Study>(),
    );
  });

  test(
    'schema rejects composite expressions outside question conditionals',
    () {
      final studyJson = StudyFixtures.minimal().toJson();
      studyJson['eligibility_criteria'] = [
        {
          'id': 'criterion-id',
          'condition': {
            'type': 'composite',
            'logicType': 'and',
            'expressions': <Object?>[],
          },
        },
      ];

      final result = validateJson(jsonEncode(studyJson), schemaOnly: true);

      expect(result['valid'], isFalse);
      expect(
        (result['errors'] as List).cast<Map<String, dynamic>>().map(
          (error) => error['code'],
        ),
        contains('SCHEMA_ERROR'),
      );
    },
  );
}

Map<String, dynamic> _progressJson(Result<dynamic> result) => SubjectProgress(
  subjectId: 'subject-id',
  interventionId: 'intervention-id',
  taskId: 'task-id',
  resultType: result.type,
  result: result,
).toJson();
