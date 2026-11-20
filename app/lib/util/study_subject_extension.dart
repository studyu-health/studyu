import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';

int nutritionStudyDayFor(StudySubject subject, DateTime date) =>
    subject.getNutritionStudyDayFor(date);

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
    'nutritionRevision': nutritionRevision,
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
  }) async {
    final studyDay = recall.studyDaySnapshot;
    final completedAt = recall.entryCompletedAt;
    if (studyDay == null || completedAt == null) {
      throw StateError('A completed recall must have a study day.');
    }

    final target = persistenceTarget;
    if (target != null &&
        (target.studyDaySnapshot != studyDay ||
            target.taskId != taskId ||
            target.periodId != periodId)) {
      throw StateError('The nutrition recall identity changed.');
    }
    final completionDate =
        target?.completedAt ?? completionDateOverride ?? completedAt;
    final interventionId =
        target?.interventionId ??
        interventionIdOverride ??
        getNutritionInterventionForStudyDay(studyDay)?.id;
    if (interventionId == null) {
      throw StateError('No intervention found for nutrition recall.');
    }
    final resultObject = Result<DailyRecall>.app(
      type: 'DailyRecall',
      periodId: periodId,
      result: recall,
    );

    final response = await client.rpc<dynamic>(
      'save_nutrition_recall',
      params: {
        'p_subject_id': id,
        'p_completed_at': completionDate.toUtc().toIso8601String(),
        'p_intervention_id': interventionId,
        'p_task_id': taskId,
        'p_result': resultObject.toJson(),
        'p_expected_revision': target?.nutritionRevision,
      },
    );
    final row = response is List ? response.single : response;
    final saved = SupabaseQuery.extractSupabaseSingleRow<SubjectProgress>(
      Map<String, dynamic>.from(row as Map),
    );
    applySavedProgress(saved);
    return saved;
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

    final intervention = getInterventionForDate(DateTime.now());
    if (intervention == null) {
      throw StateError('No intervention found for result');
    }

    var progressToSave = SubjectProgress(
      subjectId: id,
      interventionId: intervention.id,
      taskId: taskId,
      result: resultObject,
      resultType: resultObject.type,
    );
    if (offline) {
      progressToSave.completedAt = DateTime.now().toUtc();
      progress.add(progressToSave);
    } else {
      progressToSave = await progressToSave.save();
      progress.add(progressToSave);
      await save(onlyUpdate: true);
    }
  }
}
