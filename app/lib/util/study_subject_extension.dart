import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';

extension StudySubjectExtension on StudySubject {
  /// Updates an existing completed recall or creates a completed result.
  /// Draft recalls stay in local auto-save storage.
  Future<void> upsertNutritionResult({
    required String taskId,
    required String periodId,
    required DailyRecall recall,
    DateTime? completionDateOverride,
  }) async {
    if (recall.entryCompletedAt == null) {
      throw StateError(
        'Nutrition drafts cannot be saved as completed progress',
      );
    }

    final resultObject = Result<DailyRecall>.app(
      type: 'DailyRecall',
      periodId: periodId,
      result: recall,
    );

    String interventionId;
    final completionDate = completionDateOverride ?? recall.entryCompletedAt!;

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
    interventionId = intervention.id;

    // Find existing progress for this task on the same study day
    final existingIndex = progress.indexWhere(
      (p) => p.taskId == taskId && _isSameStudyDay(p, recall),
    );

    // Reuse the same completedAt key for updates to avoid duplicate rows
    final existingCompletedAt = existingIndex >= 0
        ? progress[existingIndex].completedAt
        : null;

    StudyULogger.debug(
      '[upsertNutritionResult] task=$taskId period=$periodId studyDay=${recall.studyDaySnapshot} '
      'completionDate=$completionDate completionDateOverride=$completionDateOverride '
      'existingIndex=$existingIndex existingCompletedAt=$existingCompletedAt '
      'meals=${recall.meals.length} progressLen=${progress.length}',
    );

    final progressToSave = SubjectProgress(
      subjectId: id,
      interventionId: interventionId,
      taskId: taskId,
      result: resultObject,
      resultType: resultObject.type,
    )..completedAt = (existingCompletedAt ?? completionDate).toUtc();

    try {
      final saved = await progressToSave.save();
      if (existingIndex >= 0) {
        progress[existingIndex] = saved;
      } else {
        progress.add(saved);
      }
      await save(onlyUpdate: true);
    } on SocketException {
      // Offline - just update local progress
      if (existingIndex >= 0) {
        progress[existingIndex] = progressToSave;
      } else {
        progress.add(progressToSave);
      }
    }
  }

  bool hasNutritionResultForStudyDay({
    required String taskId,
    required DailyRecall recall,
  }) {
    return progress.any(
      (p) => p.taskId == taskId && _isSameStudyDay(p, recall),
    );
  }

  bool _isSameStudyDay(SubjectProgress p, DailyRecall recall) {
    if (p.resultType != 'DailyRecall') return false;
    try {
      final existingResult = p.result.result;
      if (existingResult is! DailyRecall) return false;
      final existingRecall = existingResult;
      var match = existingRecall.studyDaySnapshot == recall.studyDaySnapshot;

      // Fallback: older rows may not have studyDaySnapshot set; compare by calculated study day.
      if (!match &&
          existingRecall.studyDaySnapshot == null &&
          recall.studyDaySnapshot != null &&
          p.completedAt != null) {
        final existingDay = getDayOfStudyFor(p.completedAt!.toLocal());
        match = existingDay == recall.studyDaySnapshot;
      }

      StudyULogger.debug(
        '[upsertNutritionResult] _isSameStudyDay? $match | existing=${existingRecall.studyDaySnapshot} '
        'incoming=${recall.studyDaySnapshot} completedAt=${p.completedAt}',
      );
      return match;
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

    // Skip multimodal file handling for web
    if (!kIsWeb) {
      // Move multimodal files to upload directory
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

            // Replaces Answer<FutureBlobFile> with Answer<String>
            questionnaireState.answers[answerEntry.key] = Answer<String>(
              answer.question,
              answer.timestamp,
            )..response = futureBlobFile.futureBlobId;
          }
        }
      }
      // Upload multimodal files
      if (!offline) {
        await Cache.uploadBlobFiles();
      }
    }

    String interventionId;
    DateTime completionDate;

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
    interventionId = intervention.id;
    completionDate = result is DailyRecall
        ? result.entryCompletedAt ?? DateTime.now()
        : DateTime.now();

    SubjectProgress p = SubjectProgress(
      subjectId: id,
      interventionId: interventionId,
      taskId: taskId,
      result: resultObject,
      resultType: resultObject.type,
    );
    if (offline) {
      p.completedAt = completionDate.toUtc();
      progress.add(p);
    } else {
      p = await p.save();
      progress.add(p);
      await save(onlyUpdate: true);
    }
  }
}
