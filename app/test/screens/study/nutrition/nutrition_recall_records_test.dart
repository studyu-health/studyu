import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_core/core.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

    SharedPreferences.setMockInitialValues({
      'studyu_nutrition_autosave_index_subject': jsonEncode([
        {
          'taskId': 'task',
          'periodId': 'period',
          'studyDaySnapshot': recallStudyDay,
        },
      ]),
      'studyu_nutrition_autosave_subject_task_period_$recallStudyDay':
          jsonEncode({
            'recall': _recall(
              'local',
              now.subtract(const Duration(days: 1)),
              recallStudyDay,
            ).toJson(),
            'metadata': {
              'subjectId': subject.id,
              'taskId': 'task',
              'interventionId': 'intervention',
              'periodId': 'period',
              'studyDaySnapshot': recallStudyDay,
              'createdAt': now
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
              'lastModifiedAt': now
                  .subtract(const Duration(hours: 1))
                  .toIso8601String(),
            },
          }),
    });
    final manager = NutritionRecallAutoSaveManager(
      preferences: await SharedPreferences.getInstance(),
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
    result: recall,
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
