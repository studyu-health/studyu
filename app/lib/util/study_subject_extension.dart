import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';

/// The immutable identity of an already persisted nutrition recall.
///
/// Keeping this with the upsert API prevents a correction from being treated
/// as a new completion in a different period or intervention.
int nutritionStudyDayFor(StudySubject subject, DateTime date) {
  final current = date.toUtc();
  final started = subject.startedAt!.toUtc();
  return DateTime.utc(
    current.year,
    current.month,
    current.day,
  ).difference(DateTime.utc(started.year, started.month, started.day)).inDays;
}

class const NutritionRecallPersistenceTarget({
  required final String taskId,
  required final String periodId,
  required final String interventionId,
  required final DateTime completedAt,
  required final int studyDaySnapshot,
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
  /// Upserts a DailyRecall result without changing an existing recall's
  /// persistence identity.
  Future<void> upsertNutritionResult({
    required String taskId,
    required String periodId,
    required DailyRecall recall,
    DateTime? completionDateOverride,
    NutritionRecallPersistenceTarget? persistenceTarget,
    String? interventionIdOverride,
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

    final matching = progress.where((progress) {
      if (progress.taskId != effectiveTaskId ||
          progress.resultType != 'DailyRecall') {
        return false;
      }
      if (target != null) {
        return progress.completedAt == target.completedAt;
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
    } else {
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

    final progressToSave = SubjectProgress(
      subjectId: id,
      interventionId: interventionId,
      taskId: effectiveTaskId,
      result: resultObject,
      resultType: resultObject.type,
    )..completedAt = target?.completedAt ?? completionDate.toUtc();

    var updatedLocalProgress = false;
    try {
      final saved = await progressToSave.save();
      if (existing != null) {
        final index = progress.indexOf(existing);
        if (index >= 0) progress[index] = saved;
      } else {
        progress.add(saved);
      }
      updatedLocalProgress = true;
      await save(onlyUpdate: true);
    } on SocketException {
      if (!updatedLocalProgress) {
        if (existing != null) {
          final index = progress.indexOf(existing);
          if (index >= 0) progress[index] = progressToSave;
        } else {
          progress.add(progressToSave);
        }
      }
      rethrow;
    }
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
      studyDaySnapshot: studyDaySnapshot,
      lastAutoSavedAt: recall.lastAutoSavedAt,
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
