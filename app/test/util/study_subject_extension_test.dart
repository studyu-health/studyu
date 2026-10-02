import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

StudySubject _buildStartedSubject() {
  final study = Study('study', 'user')
    ..interventions = [
      Intervention('intervention-a', 'Intervention A'),
      Intervention('intervention-b', 'Intervention B'),
    ];

  return StudySubject.fromStudy(
    study,
    'user',
    study.interventions.map((intervention) => intervention.id).toList(),
    null,
  )..startedAt = DateTime.now().subtract(const Duration(days: 1));
}

SubjectProgress _progressWithCompletedAt(DateTime completedAt) {
  return SubjectProgress(
    subjectId: 'subject',
    interventionId: 'intervention-a',
    taskId: 'existing-task',
    resultType: 'bool',
    result: Result<bool>.app(type: 'bool', periodId: 'period-0', result: true),
  )..completedAt = completedAt;
}

void main() {
  group('disambiguatedCompletedAt (pure policy)', () {
    test('returns the proposed time unchanged when there is no existing '
        'progress', () {
      final proposed = DateTime.utc(2026, 1, 1, 12);
      expect(disambiguatedCompletedAt([], proposed), proposed);
    });

    test('returns the proposed time unchanged when it is already after '
        'every existing completedAt', () {
      final earlier = DateTime.utc(2026, 1, 1, 11);
      final proposed = DateTime.utc(2026, 1, 1, 12);
      expect(
        disambiguatedCompletedAt([_progressWithCompletedAt(earlier)], proposed),
        proposed,
      );
    });

    test('bumps forward by the minimum increment when the proposed time '
        'exactly collides with an existing completedAt', () {
      final collision = DateTime.utc(2026, 1, 1, 12);
      final result = disambiguatedCompletedAt([
        _progressWithCompletedAt(collision),
      ], collision);
      expect(result.isAfter(collision), isTrue);
      expect(result.difference(collision), const Duration(microseconds: 1));
    });

    test('bumps forward past the latest existing completedAt when the '
        'proposed time precedes it (clock moved backwards)', () {
      final future = DateTime.utc(2026, 1, 1, 12);
      final proposed = DateTime.utc(2026, 1, 1, 11);
      final result = disambiguatedCompletedAt([
        _progressWithCompletedAt(future),
      ], proposed);
      expect(result.isAfter(future), isTrue);
    });

    test('uses the maximum completedAt across multiple existing entries, '
        'not just the last one in the list', () {
      final earliest = DateTime.utc(2026, 1, 1, 10);
      final latest = DateTime.utc(2026, 1, 1, 14);
      final middle = DateTime.utc(2026, 1, 1, 12);
      final result = disambiguatedCompletedAt([
        _progressWithCompletedAt(middle),
        _progressWithCompletedAt(earliest),
        _progressWithCompletedAt(latest),
      ], latest);
      expect(result.isAfter(latest), isTrue);
    });

    test('ignores existing progress entries with a null completedAt', () {
      final proposed = DateTime.utc(2026, 1, 1, 12);
      final nullCompletedAt = SubjectProgress(
        subjectId: 'subject',
        interventionId: 'intervention-a',
        taskId: 'existing-task',
        resultType: 'bool',
        result: Result<bool>.app(
          type: 'bool',
          periodId: 'period-0',
          result: true,
        ),
      );
      expect(disambiguatedCompletedAt([nullCompletedAt], proposed), proposed);
    });
  });

  group('addResult(offline: true) wiring', () {
    test("a new offline completion is disambiguated against the subject's "
        'existing progress', () async {
      final subject = _buildStartedSubject();
      final future = DateTime.now().toUtc().add(const Duration(minutes: 5));
      subject.progress.add(_progressWithCompletedAt(future));

      await subject.addResult<bool>(
        taskId: 'task-1',
        periodId: 'period-1',
        result: true,
        offline: true,
      );

      final newCompletedAt = subject.progress.last.completedAt!;
      expect(newCompletedAt.isAfter(future), isTrue);
    });
  });
}
