import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';

int nutritionStudyDayFor(StudySubject subject, DateTime date) {
  final current = date.toUtc();
  final started = subject.startedAt!.toUtc();
  return DateTime.utc(
    current.year,
    current.month,
    current.day,
  ).difference(DateTime.utc(started.year, started.month, started.day)).inDays;
}

bool isWritableNutritionStudyDay(int? studyDay, int todayStudyDay) =>
    studyDay != null &&
    studyDay >= 0 &&
    (studyDay == todayStudyDay || studyDay == todayStudyDay - 1);

/// The immutable identity of an already persisted nutrition recall.
///
/// Keeping this with the upsert API prevents a correction from being treated
/// as a new completion in a different period or intervention.
class const NutritionRecallPersistenceTarget({
  required final String taskId,
  required final String periodId,
  required final String interventionId,
  required final DateTime completedAt,
  required final int studyDaySnapshot,
  final int? nutritionRevision,
}) {
  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'periodId': periodId,
    'interventionId': interventionId,
    'completedAt': completedAt.toUtc().toIso8601String(),
    'studyDaySnapshot': studyDaySnapshot,
  };
}

extension StudySubjectExtension on StudySubject {
  Future<SubjectProgress?> fetchNutritionRecall({
    required String taskId,
    required String periodId,
    required int studyDaySnapshot,
    NutritionRecallPersistenceTarget? target,
  }) async {
    final query = client
        .from(SubjectProgress.tableName)
        .select()
        .eq('subject_id', id)
        .eq('task_id', taskId)
        .eq('result_type', 'DailyRecall');
    final match = target == null
        ? query
              .eq('result->>periodId', periodId)
              .eq(
                'result->result->>studyDaySnapshot',
                studyDaySnapshot.toString(),
              )
        : query
              .eq('completed_at', target.completedAt.toUtc().toIso8601String())
              .eq('intervention_id', target.interventionId);
    final row = await match.limit(2).maybeSingle();
    if (row == null) return null;
    return SupabaseQuery.extractSupabaseSingleRow<SubjectProgress>(row);
  }

  /// Upserts a DailyRecall result without changing an existing recall's
  /// persistence identity.
  Future<SubjectProgress> upsertNutritionResult({
    required String taskId,
    required String periodId,
    required DailyRecall recall,
    DateTime? completionDateOverride,
    NutritionRecallPersistenceTarget? persistenceTarget,
    String? interventionIdOverride,
    bool createOnly = false,
  }) async {
    if (recall.entryCompletedAt == null) {
      throw StateError(
        'Nutrition drafts cannot be saved as completed progress',
      );
    }

    final target = persistenceTarget;
    final effectiveTaskId = target?.taskId ?? taskId;
    final effectivePeriodId = target?.periodId ?? periodId;
    final effectiveRecall = _recallWithStudyDay(
      recall,
      target?.studyDaySnapshot ?? recall.studyDaySnapshot,
    );
    final resultObject = Result<DailyRecall>.app(
      type: 'DailyRecall',
      periodId: effectivePeriodId,
      result: effectiveRecall,
    );

    final matching = (createOnly ? const <SubjectProgress>[] : progress).where((
      progress,
    ) {
      if (progress.taskId != effectiveTaskId ||
          progress.resultType != 'DailyRecall') {
        return false;
      }
      if (target != null) {
        return progress.completedAt == target.completedAt &&
            progress.interventionId == target.interventionId &&
            (progress.result.periodId == null ||
                progress.result.periodId == effectivePeriodId);
      }
      return _isSameStudyDay(progress, effectiveRecall) &&
          progress.result.periodId == effectivePeriodId;
    }).toList();

    SubjectProgress? existing;
    if (target != null) {
      existing = matching.isEmpty ? null : matching.first;
    } else if (matching.length == 1) {
      existing = matching.single;
    } else if (matching.length > 1) {
      throw StateError(
        'Multiple nutrition recalls match task $effectiveTaskId, period '
        '$effectivePeriodId and study day ${effectiveRecall.studyDaySnapshot}.',
      );
    } else if (!createOnly) {
      final legacyMatches = progress.where((progress) {
        return progress.taskId == effectiveTaskId &&
            progress.resultType == 'DailyRecall' &&
            progress.result.periodId == null &&
            _isSameStudyDay(progress, effectiveRecall);
      }).toList();
      if (legacyMatches.length == 1) existing = legacyMatches.single;
      if (legacyMatches.length > 1) {
        throw StateError(
          'Multiple legacy nutrition recalls match task $effectiveTaskId and '
          'study day ${effectiveRecall.studyDaySnapshot}.',
        );
      }
    }

    final completionDate =
        target?.completedAt ??
        existing?.completedAt ??
        completionDateOverride ??
        effectiveRecall.entryCompletedAt ??
        effectiveRecall.entryStartedAt ??
        effectiveRecall.lastAutoSavedAt ??
        DateTime.now();
    final interventionId =
        target?.interventionId ??
        existing?.interventionId ??
        interventionIdOverride ??
        _interventionIdForRecall(effectiveRecall);

    StudyULogger.debug(
      '[upsertNutritionResult] task=$effectiveTaskId period=$effectivePeriodId '
      'studyDay=${effectiveRecall.studyDaySnapshot} existing=${existing != null} '
      'completionDate=$completionDate meals=${effectiveRecall.meals.length}',
    );

    final response = await client.rpc<dynamic>(
      'save_nutrition_recall',
      params: {
        'p_subject_id': id,
        'p_completed_at': completionDate.toUtc().toIso8601String(),
        'p_intervention_id': interventionId,
        'p_task_id': effectiveTaskId,
        'p_result': resultObject.toJsonForStorage(),
        'p_expected_revision': createOnly
            ? null
            : target?.nutritionRevision ?? existing?.nutritionRevision,
      },
    );
    final row = response is List ? response.single : response;
    final saved = SupabaseQuery.extractSupabaseSingleRow<SubjectProgress>(
      Map<String, dynamic>.from(row as Map),
    );
    applySavedProgress(saved);
    return saved;
  }

  String _interventionIdForRecall(DailyRecall recall) {
    final baseDate = startedAt;
    final snapshotDate = baseDate != null && recall.studyDaySnapshot != null
        ? baseDate.add(Duration(days: recall.studyDaySnapshot!))
        : null;
    final intervention =
        (snapshotDate == null ? null : getInterventionForDate(snapshotDate)) ??
        getInterventionForDate(DateTime.now());
    if (intervention == null) {
      throw StateError('No intervention found for nutrition recall');
    }
    return intervention.id;
  }

  DailyRecall _recallWithStudyDay(DailyRecall recall, int? studyDaySnapshot) {
    if (studyDaySnapshot == null ||
        recall.studyDaySnapshot == studyDaySnapshot) {
      return recall;
    }
    return DailyRecall(
      id: recall.id,
      date: recall.date,
      isUsualIntakeDay: recall.isUsualIntakeDay,
      specialOccasion: recall.specialOccasion,
      recallMode: recall.recallMode,
      entryStartedAt: recall.entryStartedAt,
      entryCompletedAt: recall.entryCompletedAt,
      meals: recall.meals,
      waterIntakeMl: recall.waterIntakeMl,
      studyDaySnapshot: studyDaySnapshot,
      lastAutoSavedAt: recall.lastAutoSavedAt,
      availabilityVerified: recall.availabilityVerified,
    );
  }

  bool _isSameStudyDay(SubjectProgress progress, DailyRecall recall) {
    try {
      final existingRecall = progress.result.result;
      if (existingRecall is! DailyRecall) return false;
      if (existingRecall.studyDaySnapshot == recall.studyDaySnapshot) {
        return true;
      }
      return existingRecall.studyDaySnapshot == null &&
          recall.studyDaySnapshot != null &&
          progress.completedAt != null &&
          nutritionStudyDayFor(this, progress.completedAt!) ==
              recall.studyDaySnapshot;
    } catch (_) {
      return false;
    }
  }

  Future<void> addResult<T>({
    required String taskId,
    required String periodId,
    required T result,
    bool offline = false,
  }) async {
    final Result<T> resultObject = switch (result) {
      QuestionnaireState() => Result<T>.app(
        type: 'QuestionnaireState',
        periodId: periodId,
        result: result,
      ),
      DailyRecall() => Result<T>.app(
        type: 'DailyRecall',
        periodId: periodId,
        result: result,
      ),
      bool() => Result<T>.app(type: 'bool', periodId: periodId, result: result),
      _ => Result<T>.app(type: 'unknown', periodId: periodId, result: result),
    };

    if (resultObject.type == 'unknown') {
      print('Unsupported question type: $T');
    }

    if (!kIsWeb) {
      if (resultObject.result is QuestionnaireState) {
        final questionnaireState = resultObject.result as QuestionnaireState;
        for (final answerEntry in questionnaireState.answers.entries.toList()) {
          final answer = answerEntry.value;
          if (answer.response is FutureBlobFile) {
            final futureBlobFile = answer.response as FutureBlobFile;
            await TemporaryStorageHandler.moveStagingFileToUploadDirectory(
              futureBlobFile.localFilePath,
              futureBlobFile.futureBlobId,
            );
            questionnaireState.answers[answerEntry.key] = Answer<String>(
              answer.question,
              answer.timestamp,
            )..response = futureBlobFile.futureBlobId;
          }
        }
      }
      if (!offline) await Cache.uploadBlobFiles();
    }

    final snapshotDate =
        startedAt != null &&
            result is DailyRecall &&
            result.studyDaySnapshot != null
        ? startedAt!.add(Duration(days: result.studyDaySnapshot!))
        : null;
    final intervention =
        (snapshotDate == null ? null : getInterventionForDate(snapshotDate)) ??
        getInterventionForDate(DateTime.now());
    if (intervention == null) {
      throw StateError('No intervention found for result');
    }
    final completionDate = result is DailyRecall
        ? result.entryCompletedAt ?? DateTime.now()
        : DateTime.now();

    var progressToSave = SubjectProgress(
      subjectId: id,
      interventionId: intervention.id,
      taskId: taskId,
      result: resultObject,
      resultType: resultObject.type,
    );
    if (offline) {
      progressToSave.completedAt = completionDate.toUtc();
      progress.add(progressToSave);
    } else {
      progressToSave = await progressToSave.save();
      progress.add(progressToSave);
      await save(onlyUpdate: true);
    }
  }
}
