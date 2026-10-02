import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

const _studyId = 'study-id';
const _userId = 'user-id';
const _interventionAId = 'intervention-a';
const _interventionBId = 'intervention-b';
const _checkmarkPeriodId = 'period-checkmark';
const _observationPeriodId = 'period-observation';

StudySubject _buildSubject() {
  final checkmarkTask = CheckmarkTask.withId()
    ..title = 'Rate your day'
    ..schedule.completionPeriods = [
      CompletionPeriod(
        id: _checkmarkPeriodId,
        unlockTime: StudyUTimeOfDay(hour: 8),
        lockTime: StudyUTimeOfDay(hour: 20),
      ),
    ];

  final observationTask = QuestionnaireTask.withId()
    ..title = 'Mood survey'
    ..schedule.completionPeriods = [
      CompletionPeriod(
        id: _observationPeriodId,
        unlockTime: StudyUTimeOfDay(hour: 9),
        lockTime: StudyUTimeOfDay(hour: 21),
      ),
    ];

  final study = Study(_studyId, _userId)
    ..title = 'Cached study'
    ..status = StudyStatus.running
    ..schedule = StudySchedule(sequenceCustom: 'AB')
    ..interventions = [
      Intervention(_interventionAId, 'Intervention A')..tasks = [checkmarkTask],
      Intervention(_interventionBId, 'Intervention B'),
    ]
    ..observations = [observationTask];

  study.schedule
    ..includeBaseline = true
    ..numberOfCycles = 1
    ..phaseDuration = 2;

  final subject = StudySubject.fromStudy(
    study,
    _userId,
    study.interventions.map((intervention) => intervention.id).toList(),
    null,
  )..startedAt = DateTime.utc(2026, 8);

  subject.progress = [
    SubjectProgress(
      subjectId: subject.id,
      interventionId: _interventionAId,
      taskId: checkmarkTask.id,
      resultType: 'bool',
      result: Result<bool>.app(
        type: 'bool',
        periodId: _checkmarkPeriodId,
        result: true,
      ),
    )..completedAt = DateTime.utc(2026, 8, 3, 10),
  ];

  return subject;
}

void main() {
  group('StudySubject cache roundtrip', () {
    test(
      'preserves cached configuration, schedule, task state, and progress',
      () {
        final subject = _buildSubject();
        final activeDate = subject.startedAt!.add(
          Duration(days: subject.study.schedule.phaseDuration),
        );
        final restored = StudySubject.fromJson(subject.toFullJson());

        expect(restored.study.title, subject.study.title);
        expect(restored.study.status, StudyStatus.running);
        expect(restored.study.schedule.includeBaseline, isTrue);
        expect(
          restored.study.schedule.phaseDuration,
          subject.study.schedule.phaseDuration,
        );
        expect(
          restored.study.schedule.numberOfCycles,
          subject.study.schedule.numberOfCycles,
        );
        expect(
          restored.selectedInterventionIds,
          subject.selectedInterventionIds,
        );
        expect(
          restored.getInterventionForDate(activeDate)?.id,
          _interventionAId,
        );

        final scheduledTaskIds = restored
            .scheduleFor(activeDate)
            .map((taskInstance) => taskInstance.task.id)
            .toList();
        expect(
          scheduledTaskIds,
          unorderedEquals([
            restored.study.interventions.first.tasks.single.id,
            restored.study.observations.single.id,
          ]),
        );

        expect(restored.progress, hasLength(1));
        expect(
          restored.progress.single.completedAt,
          DateTime.utc(2026, 8, 3, 10),
        );
        expect(
          restored.completedTaskForDay(
            restored.study.interventions.first.tasks.single.id,
            activeDate,
          ),
          isTrue,
        );
        expect(
          restored.completedTaskForDay(
            restored.study.observations.single.id,
            activeDate,
          ),
          isFalse,
        );
        expect(restored.allTasksCompletedFor(activeDate), isFalse);
      },
    );

    test('preserves study.fitbitCredentials through the cache round trip', () {
      // study.fitbitCredentials is @JsonKey(includeToJson: false) on Study
      // itself — it's populated from a joined-query column
      // (`study_fitbit_credentials`), not a plain field of the `study`
      // table, so it must never be written back out by a normal
      // `study.save()`/upsert. That means StudySubject.toFullJson() (the
      // cache serialization boundary) is responsible for round-tripping
      // it, not Study's own toJson()/fromJson().
      final subject = _buildSubject();
      subject.study.fitbitCredentials = StudyFitbitCredentials(
        _studyId,
        FitbitAuthCredentials(
          clientId: 'client-id',
          clientSecret: 'client-secret',
        ),
      );

      final restored = StudySubject.fromJson(subject.toFullJson());

      expect(restored.study.fitbitCredentials, isNotNull);
      expect(
        restored.study.fitbitCredentials!.fitbitCredentials.clientId,
        'client-id',
      );
    });
  });
}
