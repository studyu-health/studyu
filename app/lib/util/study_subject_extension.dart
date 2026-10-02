import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';

/// Returns [proposed], or the minimum timestamp strictly after the latest
/// `completedAt` in [existingProgress] when [proposed] would collide with
/// (or precede) it.
///
/// `participant_progress`'s primary key is `(completed_at, subject_id)`
/// (see `supabase/migrations/00000000000001_studyu-schema.sql`), so two
/// offline completions sharing a timestamp would collide on upload.
DateTime disambiguatedCompletedAt(
  Iterable<SubjectProgress> existingProgress,
  DateTime proposed,
) {
  DateTime? latest;
  for (final entry in existingProgress) {
    final completedAt = entry.completedAt;
    if (completedAt == null) continue;
    if (latest == null || completedAt.isAfter(latest)) {
      latest = completedAt;
    }
  }
  if (latest != null && !proposed.isAfter(latest)) {
    return latest.add(const Duration(microseconds: 1));
  }
  return proposed;
}

Future<void> prepareQuestionnaireMedia(QuestionnaireState state) async {
  if (kIsWeb) return;
  for (final entry in state.answers.entries.toList()) {
    final response = entry.value.response;
    if (response is FutureBlobFile) {
      await TemporaryStorageHandler.moveStagingFileToUploadDirectory(
        response.localFilePath,
        response.futureBlobId,
      );
      state.answers[entry.key] = Answer<String>(
        entry.value.question,
        entry.value.timestamp,
      )..response = response.futureBlobId;
    }
  }
}

extension StudySubjectExtension on StudySubject {
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

    // Skip multimodal file handling for web
    if (!kIsWeb) {
      // Move multimodal files to upload directory
      if (resultObject.result is QuestionnaireState) {
        await prepareQuestionnaireMedia(
          resultObject.result as QuestionnaireState,
        );
      }
      // Upload multimodal files
      if (!offline) {
        await Cache.uploadBlobFiles();
      }
    }

    SubjectProgress p = SubjectProgress(
      subjectId: id,
      interventionId: getInterventionForDate(DateTime.now())!.id,
      taskId: taskId,
      result: resultObject,
      resultType: resultObject.type,
    );
    if (offline) {
      p.completedAt = disambiguatedCompletedAt(
        progress,
        DateTime.now().toUtc(),
      );
      progress.add(p);
    } else {
      p = await p.save();
      progress.add(p);
      await save(onlyUpdate: true);
    }
  }
}
