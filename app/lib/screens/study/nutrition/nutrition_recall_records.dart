import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

export 'package:studyu_app/util/study_subject_extension.dart'
    show nutritionStudyDayFor;

class const NutritionRecallRecord({
  required final DailyRecall recall,
  required final String taskId,
  required final String? periodId,
  required final String interventionId,
  required final int studyDaySnapshot,
  final SubjectProgress? progress,
}) {
  NutritionRecallPersistenceTarget? get persistenceTarget {
    final completedAt = progress?.completedAt;
    if (periodId == null || completedAt == null) return null;
    return NutritionRecallPersistenceTarget(
      taskId: taskId,
      periodId: periodId!,
      interventionId: interventionId,
      completedAt: completedAt,
      studyDaySnapshot: studyDaySnapshot,
    );
  }

  bool get hasUnambiguousPeriod => periodId != null;

  NutritionRecallRecord withLocalRecall(PendingRecall pending) =>
      NutritionRecallRecord(
        recall: pending.recall,
        taskId: taskId,
        periodId: periodId,
        interventionId: interventionId,
        studyDaySnapshot: studyDaySnapshot,
        progress: progress,
      );
}

/// Loads the launched task's remote recalls and locally pending drafts.
///
/// A local draft may supersede its matching remote record only while it is a
/// current/previous study-day correction and is newer than the remote payload.
Future<List<NutritionRecallRecord>> loadNutritionRecallRecords({
  required StudySubject subject,
  required String taskId,
  NutritionRecallAutoSaveManager? autoSaveManager,
  DateTime? now,
}) async {
  final todayStudyDay = nutritionStudyDayFor(subject, now ?? DateTime.now());
  final records = <String, NutritionRecallRecord>{};

  for (final progress in subject.progress) {
    if (progress.taskId != taskId || progress.resultType != 'DailyRecall') {
      continue;
    }
    final result = progress.result.result;
    if (result is! DailyRecall) continue;
    final studyDay =
        result.studyDaySnapshot ??
        (progress.completedAt == null
            ? null
            : nutritionStudyDayFor(subject, progress.completedAt!));
    if (studyDay == null) continue;
    final record = NutritionRecallRecord(
      recall: result,
      taskId: taskId,
      periodId: progress.result.periodId,
      interventionId: progress.interventionId,
      studyDaySnapshot: studyDay,
      progress: progress,
    );
    final identity = _recordIdentity(taskId, record.periodId, studyDay);
    final existing = records[identity];
    if (existing == null || _isNewerRemote(record, existing)) {
      records[identity] = record;
    }
  }

  final pending = await (autoSaveManager ?? NutritionRecallAutoSaveManager())
      .scanPendingRecalls(subject.id);
  for (final local in pending.where((pending) => pending.taskId == taskId)) {
    final identity = _recordIdentity(
      local.taskId,
      local.periodId,
      local.studyDaySnapshot,
    );
    final remote = records[identity];
    if (remote == null) {
      records[identity] = NutritionRecallRecord(
        recall: local.recall,
        taskId: local.taskId,
        periodId: local.periodId,
        interventionId: local.interventionId,
        studyDaySnapshot: local.studyDaySnapshot,
      );
      continue;
    }
    final remoteSavedAt =
        remote.recall.lastAutoSavedAt ??
        remote.progress?.completedAt ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final canReplace =
        local.studyDaySnapshot == todayStudyDay ||
        local.studyDaySnapshot == todayStudyDay - 1;
    if (canReplace && local.lastModifiedAtDate.isAfter(remoteSavedAt)) {
      records[identity] = remote.withLocalRecall(local);
    }
  }

  final result = records.values.toList()
    ..sort(
      (left, right) => right.studyDaySnapshot.compareTo(left.studyDaySnapshot),
    );
  return result;
}

bool isEditableNutritionRecallDay({
  required int studyDaySnapshot,
  required int currentStudyDay,
  required bool hasUnambiguousPeriod,
}) => hasUnambiguousPeriod && studyDaySnapshot == currentStudyDay - 1;

String _recordIdentity(String taskId, String? periodId, int studyDaySnapshot) =>
    '$taskId\u0000${periodId ?? '<missing>'}\u0000$studyDaySnapshot';

bool _isNewerRemote(
  NutritionRecallRecord candidate,
  NutritionRecallRecord existing,
) {
  final candidateAt =
      candidate.recall.lastAutoSavedAt ?? candidate.progress?.completedAt;
  final existingAt =
      existing.recall.lastAutoSavedAt ?? existing.progress?.completedAt;
  if (candidateAt == null) return false;
  if (existingAt == null) return true;
  return candidateAt.isAfter(existingAt);
}
