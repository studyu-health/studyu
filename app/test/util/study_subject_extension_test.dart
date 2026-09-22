import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';

void main() {
  setUpAll(() {
    setEnv(
      'http://localhost',
      'anon',
      supabaseClient: SupabaseClient(
        'http://localhost',
        'anon',
        httpClient: _OfflineClient(),
      ),
    );
  });

  test('upsert retains the target recall identity while offline', () async {
    final completedAt = DateTime.utc(2026, 7, 15, 12);
    final target = NutritionRecallPersistenceTarget(
      taskId: 'stored-task',
      periodId: 'stored-period',
      interventionId: 'stored-intervention',
      completedAt: completedAt,
      studyDaySnapshot: 2,
    );
    final subject = StudySubject('subject', 'study', 'user', []);
    subject.progress.add(
      SubjectProgress(
        subjectId: subject.id,
        interventionId: target.interventionId,
        taskId: target.taskId,
        resultType: 'DailyRecall',
        result: Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: target.periodId,
          result: _recall('stored', target.studyDaySnapshot),
        ),
      )..completedAt = target.completedAt,
    );

    await expectLater(
      subject.upsertNutritionResult(
        taskId: 'new-task',
        periodId: 'new-period',
        recall: _recall('updated', 99),
        persistenceTarget: target,
        interventionIdOverride: 'new-intervention',
      ),
      throwsA(isA<SocketException>()),
    );

    final saved = subject.progress.single;
    final savedRecall = saved.result.result as DailyRecall;
    expect(saved.taskId, target.taskId);
    expect(saved.result.periodId, target.periodId);
    expect(saved.interventionId, target.interventionId);
    expect(saved.completedAt, target.completedAt);
    expect(savedRecall.studyDaySnapshot, target.studyDaySnapshot);
  });
}

class _OfflineClient() extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      throw const SocketException('offline');
}

DailyRecall _recall(String id, int studyDaySnapshot) => DailyRecall(
  id: id,
  date: DateTime.utc(2026, 7, 15),
  recallMode: RecallMode.realtimeRecord,
  entryStartedAt: DateTime.utc(2026, 7, 15, 8),
  entryCompletedAt: DateTime.utc(2026, 7, 15, 12),
  meals: [],
  studyDaySnapshot: studyDaySnapshot,
);
