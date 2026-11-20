import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_core/core.dart';

import '../../../util/mock_nutrition_draft_storage.dart';

void main() {
  setUp(() => mockNutritionDraftStorage());
  test('keeps the latest revision for one period and day', () async {
    final yesterday = DateTime.utc(2026, 7, 16);
    final subject = _subject(yesterday);
    final active = _recall('latest', yesterday, 0)
      ..entryCompletedAt = yesterday;
    final old = _recall('old', yesterday, 0)..entryCompletedAt = yesterday;
    subject.progress.addAll([
      _progress(recall: active, completedAt: yesterday)..nutritionRevision = 2,
      _progress(
        recall: old,
        completedAt: yesterday.add(const Duration(minutes: 1)),
      )..nutritionRevision = 1,
    ]);
    final records = await loadNutritionRecallRecords(
      subject: subject,
      taskId: 'task',
      now: yesterday.add(const Duration(days: 1)),
    );

    expect(records.single.recall.id, 'latest');
    expect(records.single.isCompleted, isTrue);
  });

  test(
    'statistics excludes an expired draft but history preserves it',
    () async {
      final date = DateTime.utc(2026, 7, 16);
      final now = date.add(const Duration(days: 2));
      final subject = _subject(date);
      final draft = _recall('local', date, 0);
      final manager = NutritionRecallAutoSaveManager();
      await manager.saveRecall(
        recall: draft,
        subjectId: subject.id,
        taskId: 'task',
        periodId: 'period',
        interventionId: 'intervention',
        studyDaySnapshot: 0,
      );

      final statistics = await loadNutritionRecallRecords(
        subject: subject,
        taskId: 'task',
        now: now,
      );
      final history = await loadNutritionRecallRecords(
        subject: subject,
        taskId: 'task',
        now: now,
        showLocalDraftsSeparately: true,
      );

      expect(statistics, isEmpty);
      expect(history.single.pending?.recall.id, 'local');
      expect(history.single.isCompleted, isFalse);
    },
  );

  test('nutrition study day uses the UTC calendar across offset midnights', () {
    final subject = _subject(DateTime.parse('2026-07-15T23:30:00-10:00'));

    expect(
      nutritionStudyDayFor(
        subject,
        DateTime.parse('2026-07-17T00:15:00+14:00'),
      ),
      0,
    );
  });

  test(
    'only the immediately previous study day with a known period is editable',
    () {
      expect(
        isEditableNutritionRecallDay(
          studyDaySnapshot: 9,
          currentStudyDay: 10,
          hasUnambiguousPeriod: true,
        ),
        isTrue,
      );
      expect(
        isEditableNutritionRecallDay(
          studyDaySnapshot: 8,
          currentStudyDay: 10,
          hasUnambiguousPeriod: true,
        ),
        isFalse,
      );
      expect(
        isEditableNutritionRecallDay(
          studyDaySnapshot: 9,
          currentStudyDay: 10,
          hasUnambiguousPeriod: false,
        ),
        isFalse,
      );
    },
  );

  test('keeps a stale local draft behind a remote completion', () async {
    final now = DateTime(2026, 7, 17, 12);
    final subject = _subject(now.subtract(const Duration(days: 3)));
    final currentStudyDay = subject.getDayOfStudyFor(now);
    final recallStudyDay = currentStudyDay - 1;
    final remoteCompletedAt = now.subtract(const Duration(minutes: 30));
    subject.progress.add(
      _progress(
        recall: _recall(
          'remote',
          now.subtract(const Duration(days: 1)),
          recallStudyDay,
        ),
        completedAt: remoteCompletedAt,
      ),
    );

    final manager = NutritionRecallAutoSaveManager();
    await manager.saveRecall(
      recall: _recall(
        'local',
        now.subtract(const Duration(days: 1)),
        recallStudyDay,
      ),
      subjectId: subject.id,
      taskId: 'task',
      periodId: 'period',
      interventionId: 'intervention',
      studyDaySnapshot: recallStudyDay,
    );
    final records = await loadNutritionRecallRecords(
      subject: subject,
      taskId: 'task',
      autoSaveManager: manager,
      now: now,
    );

    expect(records.single.recall.id, 'remote');
  });
}

StudySubject _subject(DateTime startedAt) {
  final subject = StudySubject('subject', 'study', 'user', [])
    ..startedAt = startedAt;
  subject.study = (Study('study', 'user')
    ..schedule = (StudySchedule()..numberOfCycles = 0)
    ..interventions = []);
  return subject;
}

SubjectProgress _progress({
  required DailyRecall recall,
  required DateTime completedAt,
}) => SubjectProgress(
  subjectId: 'subject',
  interventionId: 'intervention',
  taskId: 'task',
  resultType: 'DailyRecall',
  result: Result<DailyRecall>.app(
    type: 'DailyRecall',
    periodId: 'period',
    result: recall..entryCompletedAt = completedAt,
  ),
)..completedAt = completedAt;

DailyRecall _recall(String id, DateTime date, int studyDay) => DailyRecall(
  id: id,
  date: date,
  recallMode: RecallMode.realtimeRecord,
  entryStartedAt: date,
  meals: [],
  studyDaySnapshot: studyDay,
);
