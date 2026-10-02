import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/deferred_fitbit_request.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_core/core.dart';

FitbitQuestion _fitbitQuestion(List<FitbitQuestionType> types) {
  return FitbitQuestion.withId(
    questionType: FitbitQuestion.questionType,
    types: types,
  );
}

StudySubject _buildSubject({required List<FitbitQuestionType> types}) {
  final question = _fitbitQuestion(types);
  final task = QuestionnaireTask.withId()..questions.questions = [question];
  final study = Study('study-id', 'user-id')
    ..interventions = [Intervention('intervention-a', 'Intervention A')]
    ..observations = [task];

  return StudySubject.fromStudy(study, 'user-id', ['intervention-a'], null)
    ..startedAt = DateTime.now().subtract(const Duration(days: 1));
}

void main() {
  tearDown(() {
    FitbitHandler.debugAuthorizeForOfflineParticipationOverride = null;
    FitbitHandler.debugFindLatestDataEntryOverride = null;
    FitbitHandler.debugResolveDeferredRequestOverride = null;
  });

  group('requiredTypesForStudy', () {
    test('returns an empty list for a study with no Fitbit questions', () {
      final study = Study('study-id', 'user-id')
        ..observations = [QuestionnaireTask.withId()];
      expect(FitbitHandler.requiredTypesForStudy(study), isEmpty);
    });

    test('collects the types of every FitbitQuestion across all tasks', () {
      final taskA = QuestionnaireTask.withId()
        ..questions.questions = [
          _fitbitQuestion([FitbitQuestionType.steps]),
        ];
      final taskB = QuestionnaireTask.withId()
        ..questions.questions = [
          _fitbitQuestion([FitbitQuestionType.sleep, FitbitQuestionType.steps]),
        ];
      final study = Study('study-id', 'user-id')..observations = [taskA, taskB];

      expect(FitbitHandler.requiredTypesForStudy(study).toSet(), {
        FitbitQuestionType.steps,
        FitbitQuestionType.sleep,
      });
    });
  });

  group('authorizeForOfflineParticipation', () {
    test('returns true without attempting authorization when the study '
        'requires no Fitbit types', () async {
      final study = Study('study-id', 'user-id')
        ..observations = [QuestionnaireTask.withId()];
      FitbitHandler.debugAuthorizeForOfflineParticipationOverride = (_, _) {
        fail('should not attempt authorization when nothing is required');
      };

      expect(
        await FitbitHandler.authorizeForOfflineParticipation(study),
        isTrue,
      );
    });

    test('delegates to the authorization override when Fitbit types are '
        'required', () async {
      final subject = _buildSubject(types: [FitbitQuestionType.steps]);
      List<FitbitQuestionType>? requestedTypes;
      FitbitHandler.debugAuthorizeForOfflineParticipationOverride =
          (study, types) async {
            requestedTypes = types;
            return true;
          };

      final result = await FitbitHandler.authorizeForOfflineParticipation(
        subject.study,
      );

      expect(result, isTrue);
      expect(requestedTypes, [FitbitQuestionType.steps]);
    });

    test('surfaces an authorization failure', () async {
      final subject = _buildSubject(types: [FitbitQuestionType.steps]);
      FitbitHandler.debugAuthorizeForOfflineParticipationOverride = (
        _,
        _,
      ) async => false;

      expect(
        await FitbitHandler.authorizeForOfflineParticipation(subject.study),
        isFalse,
      );
    });
  });

  group('createDeferredRequest', () {
    test('falls back to the start of the answer day when no prior data '
        'entry is known', () async {
      final subject = _buildSubject(types: [FitbitQuestionType.steps]);
      final question = subject.study.observations.first as QuestionnaireTask;
      final fitbitQuestion =
          question.questions.questions.first as FitbitQuestion;
      FitbitHandler.debugFindLatestDataEntryOverride = (_, _, _, _) async =>
          null;
      final completedAt = DateTime.utc(2026, 3, 5, 14, 30);

      final request = await FitbitHandler.createDeferredRequest(
        subject: subject,
        interventionId: 'intervention-a',
        taskId: question.id,
        periodId: 'period-1',
        question: fitbitQuestion,
        completedAt: completedAt,
      );

      expect(request.windowStart, DateTime(2026, 3, 5).toUtc());
      expect(request.windowEnd, completedAt);
      expect(request.questionId, fitbitQuestion.id);
      expect(request.subjectId, subject.id);
      expect(request.taskId, question.id);
    });

    test('uses the known latest data entry as the window start when one '
        'exists', () async {
      final subject = _buildSubject(types: [FitbitQuestionType.steps]);
      final question = subject.study.observations.first as QuestionnaireTask;
      final fitbitQuestion =
          question.questions.questions.first as FitbitQuestion;
      final knownLatest = DateTime.utc(2026, 3, 4, 9);
      FitbitHandler.debugFindLatestDataEntryOverride = (_, _, _, _) async =>
          knownLatest;

      final request = await FitbitHandler.createDeferredRequest(
        subject: subject,
        interventionId: 'intervention-a',
        taskId: question.id,
        periodId: 'period-1',
        question: fitbitQuestion,
        completedAt: DateTime.utc(2026, 3, 5, 14, 30),
      );

      expect(request.windowStart, knownLatest);
    });

    test(
      'uses the earliest known entry across multiple required types',
      () async {
        final subject = _buildSubject(
          types: [FitbitQuestionType.steps, FitbitQuestionType.sleep],
        );
        final question = subject.study.observations.first as QuestionnaireTask;
        final fitbitQuestion =
            question.questions.questions.first as FitbitQuestion;
        final stepsLatest = DateTime.utc(2026, 3, 4, 9);
        final sleepLatest = DateTime.utc(2026, 3, 2, 22);
        FitbitHandler.debugFindLatestDataEntryOverride = (
          _,
          _,
          _,
          type,
        ) async => type == FitbitQuestionType.steps ? stepsLatest : sleepLatest;

        final request = await FitbitHandler.createDeferredRequest(
          subject: subject,
          interventionId: 'intervention-a',
          taskId: question.id,
          periodId: 'period-1',
          question: fitbitQuestion,
          completedAt: DateTime.utc(2026, 3, 5, 14, 30),
        );

        expect(request.windowStart, sleepLatest);
      },
    );
  });

  test('captures each type boundary and reads live as well as cached Fitbit answers', () async {
    final subject = _buildSubject(
      types: [
        FitbitQuestionType.steps,
        FitbitQuestionType.heartrate,
        FitbitQuestionType.sleep,
      ],
    );
    final task = subject.study.observations.first as QuestionnaireTask;
    final question = task.questions.questions.first as FitbitQuestion;
    final stepsTime = DateTime.utc(2026, 3, 2, 10);
    final heartTime = DateTime.utc(2026, 3, 4, 10);
    subject.progress.add(
      SubjectProgress(
        subjectId: subject.id,
        interventionId: 'intervention-a',
        taskId: task.id,
        resultType: 'QuestionnaireState',
        result: Result<QuestionnaireState>.app(
          type: 'QuestionnaireState',
          periodId: 'period',
          result: QuestionnaireState()
            ..answers[question.id] =
                (Answer<List<FitbitData>>(question.id, heartTime)
                  ..response = [
                    FitbitStepData(2, stepsTime),
                    FitbitHeartData(70, heartTime),
                  ]),
        ),
      )..completedAt = heartTime,
    );
    final completedAt = DateTime(2026, 3, 5, 1);
    final request = await FitbitHandler.createDeferredRequest(
      subject: subject,
      interventionId: 'intervention-a',
      taskId: task.id,
      periodId: 'period',
      question: question,
      completedAt: completedAt,
    );
    expect(request.windowStarts[FitbitQuestionType.steps], stepsTime);
    expect(request.windowStarts[FitbitQuestionType.heartrate], heartTime);
    expect(
      request.windowStarts[FitbitQuestionType.sleep],
      DateTime(2026, 3, 5).toUtc(),
    );
    final restored = DeferredFitbitRequest.fromJson(request.toJson());
    expect(restored.windowStarts, request.windowStarts);
    final cachedSubject = StudySubject.fromJson(
      jsonDecode(jsonEncode(subject.toFullJson())) as Map<String, dynamic>,
    );
    final cached = await FitbitHandler.createDeferredRequest(
      subject: cachedSubject,
      interventionId: 'intervention-a',
      taskId: task.id,
      periodId: 'period',
      question: question,
      completedAt: completedAt,
    );
    expect(cached.windowStarts, request.windowStarts);
  });
  test(
    'deferred answer-day fallback and fetched dates use the local calendar',
    () async {
      final subject = _buildSubject(types: [FitbitQuestionType.steps]);
      final task = subject.study.observations.first as QuestionnaireTask;
      final question = task.questions.questions.first as FitbitQuestion;
      final completedAt = DateTime(2026, 3, 5, 1);
      final request = await FitbitHandler.createDeferredRequest(
        subject: subject,
        interventionId: 'intervention-a',
        taskId: task.id,
        periodId: 'period',
        question: question,
        completedAt: completedAt.toUtc(),
      );
      expect(request.windowStart, DateTime(2026, 3, 5).toUtc());
      expect(FitbitHandler.fetchDays(request.windowStart, request.windowEnd), [
        DateTime(2026, 3, 5),
      ]);
    },
  );
  group('deferred window clock skew', () {
    for (final scenario in ['future end', 'future start', 'past window']) {
      test('clamps $scenario before fetching', () async {
        final subject = _buildSubject(types: [FitbitQuestionType.steps]);
        final task = subject.study.observations.first as QuestionnaireTask;
        final question = task.questions.questions.first as FitbitQuestion;
        final now = DateTime.utc(2026, 3, 5, 12);
        final start = scenario == 'future start'
            ? now.add(const Duration(hours: 2))
            : now.subtract(const Duration(days: 1));
        final end = scenario == 'past window'
            ? now.subtract(const Duration(hours: 1))
            : now.add(const Duration(hours: 3));
        final request = DeferredFitbitRequest(
          subjectId: subject.id,
          interventionId: 'intervention-a',
          taskId: task.id,
          periodId: 'period-1',
          questionId: question.id,
          windowStart: start,
          windowEnd: end,
          completedAt: end,
        );
        DeferredFitbitRequest? received;
        FitbitHandler.debugResolveDeferredRequestOverride =
            (_, value, _) async {
              received = value;
              return [];
            };
        await FitbitHandler.resolveDeferredRequest(
          subject,
          request,
          question,
          resolveTime: now,
        );
        final expectedEnd = end.isAfter(now) ? now : end;
        expect(received!.windowEnd, expectedEnd);
        expect(
          received!.windowStart,
          start.isAfter(expectedEnd) ? expectedEnd : start,
        );
        expect(received!.id, request.id);
        expect(request.windowEnd, end);
      });
    }
  });

  group('resolveDeferredRequest', () {
    test('delegates to the override and returns its data', () async {
      final subject = _buildSubject(types: [FitbitQuestionType.steps]);
      final question = subject.study.observations.first as QuestionnaireTask;
      final fitbitQuestion =
          question.questions.questions.first as FitbitQuestion;
      final request = DeferredFitbitRequest(
        subjectId: subject.id,
        interventionId: 'intervention-a',
        taskId: question.id,
        periodId: 'period-1',
        questionId: fitbitQuestion.id,
        windowStart: DateTime.utc(2026, 3, 4),
        windowEnd: DateTime.utc(2026, 3, 5),
        completedAt: DateTime.utc(2026, 3, 5),
      );
      final expectedData = [FitbitStepData(1234, DateTime.utc(2026, 3, 4, 10))];
      DeferredFitbitRequest? receivedRequest;
      FitbitHandler.debugResolveDeferredRequestOverride = (_, req, _) async {
        receivedRequest = req;
        return expectedData;
      };

      final data = await FitbitHandler.resolveDeferredRequest(
        subject,
        request,
        fitbitQuestion,
      );

      expect(data, expectedData);
      expect(receivedRequest, same(request));
    });
  });
  test(
    'deferred intraday fetch includes every calendar day and the end day',
    () {
      expect(
        FitbitHandler.fetchDays(
          DateTime(2026, 1, 1, 23).toUtc(),
          DateTime(2026, 1, 3, 1).toUtc(),
        ),
        [DateTime(2026), DateTime(2026, 1, 2), DateTime(2026, 1, 3)],
      );
      expect(
        FitbitHandler.fetchDays(
          DateTime(2026).toUtc(),
          DateTime(2026, 1, 1, 1).toUtc(),
        ),
        [DateTime(2026)],
      );
    },
  );
}
