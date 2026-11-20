import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

export 'package:studyu_app/util/study_subject_extension.dart'
    show nutritionStudyDayFor;

class const NutritionRecallRecord({
  required final DailyRecall recall,
  required final String taskId,
  required final String periodId,
  required final String interventionId,
  required final int studyDaySnapshot,
  final SubjectProgress? progress,
  final PendingRecall? pending,
}) {
  bool get isCompleted =>
      pending == null && progress != null && recall.entryCompletedAt != null;

  NutritionRecallPersistenceTarget? get persistenceTarget {
    final completedAt = progress?.completedAt;
    if (completedAt == null) return null;
    return NutritionRecallPersistenceTarget(
      taskId: taskId,
      periodId: periodId,
      interventionId: interventionId,
      completedAt: completedAt,
      studyDaySnapshot: studyDaySnapshot,
      nutritionRevision: progress!.nutritionRevision,
    );
  }
}

/// Loads the launched task's remote recalls and locally pending drafts.
///
/// Statistics use server recalls and unsubmitted entries from the current day.
/// History shows local drafts, including drafts outside the sync window.
Future<List<NutritionRecallRecord>> loadNutritionRecallRecords({
  required StudySubject subject,
  required String taskId,
  NutritionRecallAutoSaveManager? autoSaveManager,
  bool showLocalDraftsSeparately = false,
  DateTime? now,
}) async {
  final todayStudyDay = nutritionStudyDayFor(subject, now ?? DateTime.now());
  final records = <String, NutritionRecallRecord>{};

  for (final progress in subject.progress) {
    if (progress.taskId != taskId || progress.resultType != 'DailyRecall') {
      continue;
    }
    final result = progress.result.result;
    if (result is! DailyRecall ||
        result.entryCompletedAt == null ||
        progress.completedAt == null) {
      continue;
    }
    final studyDay = result.studyDaySnapshot;
    final periodId = progress.result.periodId;
    if (studyDay == null || periodId == null) continue;
    final record = NutritionRecallRecord(
      recall: result,
      taskId: taskId,
      periodId: periodId,
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
    if (remote != null && local.matchesUploadedRecall(remote.recall)) {
      continue;
    }
    final canReplace =
        isWritableNutritionStudyDay(local.studyDaySnapshot, todayStudyDay) &&
        remote != null &&
        local.canReplace(remote.progress!);
    final localRecord = NutritionRecallRecord(
      recall: local.recall,
      taskId: local.taskId,
      periodId: local.periodId,
      interventionId: local.interventionId,
      studyDaySnapshot: local.studyDaySnapshot,
      progress: canReplace ? remote.progress : null,
      pending: local,
    );
    if (showLocalDraftsSeparately) {
      if (canReplace || remote == null) {
        records[identity] = localRecord;
      } else {
        records['draft:$identity'] = localRecord;
      }
    } else if (remote == null && local.studyDaySnapshot == todayStudyDay) {
      records[identity] = localRecord;
    }
  }

  final result = records.values.toList()
    ..sort((left, right) {
      final byDay = right.studyDaySnapshot.compareTo(left.studyDaySnapshot);
      if (byDay != 0) return byDay;
      final leftIsDraft = left.pending != null;
      final rightIsDraft = right.pending != null;
      if (leftIsDraft != rightIsDraft) return leftIsDraft ? 1 : -1;
      return left.periodId.compareTo(right.periodId);
    });
  return result;
}

bool isEditableNutritionRecallDay({
  required int studyDaySnapshot,
  required int currentStudyDay,
  required bool hasUnambiguousPeriod,
}) =>
    hasUnambiguousPeriod &&
    studyDaySnapshot >= 0 &&
    studyDaySnapshot == currentStudyDay - 1;

String _recordIdentity(String taskId, String periodId, int studyDaySnapshot) =>
    '$taskId\u0000$periodId\u0000$studyDaySnapshot';

bool _isNewerRemote(
  NutritionRecallRecord candidate,
  NutritionRecallRecord existing,
) {
  final candidateRevision = candidate.progress!.nutritionRevision;
  final existingRevision = existing.progress!.nutritionRevision;
  if (candidateRevision != existingRevision) {
    return candidateRevision > existingRevision;
  }
  final candidateAt =
      candidate.recall.lastAutoSavedAt ?? candidate.progress?.completedAt;
  final existingAt =
      existing.recall.lastAutoSavedAt ?? existing.progress?.completedAt;
  if (candidateAt == null) return false;
  if (existingAt == null) return true;
  return candidateAt.isAfter(existingAt);
}
