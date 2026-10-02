import 'dart:convert';

import 'package:studyu_app/models/deferred_fitbit_request.dart';
import 'package:studyu_app/util/active_subject_sync_controller.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

Iterable<FitbitQuestion> _questions(Study study, String taskId) =>
    [
          ...study.observations,
          ...study.interventions.expand((intervention) => intervention.tasks),
        ]
        .whereType<QuestionnaireTask>()
        .where((task) => task.id == taskId)
        .expand((task) => task.questions.questions.whereType<FitbitQuestion>());

bool hasDeferredFitbitAnswers(
  QuestionnaireTask task,
  QuestionnaireState state,
) => task.questions.questions.whereType<FitbitQuestion>().any((question) {
  final response = state.answers[question.id]?.response;
  return response is List && response.isEmpty;
});

bool hasDeferredFitbitProgress(Study study, SubjectProgress progress) {
  if (progress.result.result is! QuestionnaireState) return false;
  final answers = (progress.result.result as QuestionnaireState).answers;
  return _questions(study, progress.taskId).any((question) {
    final response = answers[question.id]?.response;
    return response is List && response.isEmpty;
  });
}

Future<void> persistDeferredFitbitQuestionnaireResult({
  required StudySubject subject,
  required QuestionnaireTask task,
  required String interventionId,
  required String periodId,
  required QuestionnaireState questionnaireState,
  DateTime? completedAt,
}) async {
  final timestamp = disambiguatedCompletedAt(
    subject.progress,
    (completedAt ?? DateTime.now()).toUtc(),
  );
  final requests = <DeferredFitbitRequest>[];
  final queued = await Cache.loadDeferredFitbitRequests();
  for (final question in task.questions.questions.whereType<FitbitQuestion>()) {
    final response = questionnaireState.answers[question.id]?.response;
    if (response is! List || response.isNotEmpty) continue;
    final window = await FitbitHandler.createDeferredRequest(
      subject: subject,
      interventionId: interventionId,
      taskId: task.id,
      periodId: periodId,
      question: question,
      completedAt: timestamp,
    );
    var start = window.windowStart;
    DateTime? queuedEnd;
    for (final pending in queued) {
      if (pending.subjectId == subject.id &&
          pending.taskId == task.id &&
          pending.questionId == question.id &&
          !pending.windowEnd.isAfter(timestamp) &&
          (queuedEnd == null || pending.windowEnd.isAfter(queuedEnd))) {
        queuedEnd = pending.windowEnd;
      }
    }
    if (queuedEnd != null) start = queuedEnd;
    requests.add(
      DeferredFitbitRequest(
        subjectId: subject.id,
        interventionId: interventionId,
        taskId: task.id,
        periodId: periodId,
        questionId: question.id,
        windowStart: start,
        windowEnd: window.windowEnd,
        completedAt: timestamp,
        windowStarts: window.windowStarts,
        questionnaireState: questionnaireState,
      ),
    );
  }
  if (requests.isEmpty) throw StateError('No deferred Fitbit answers found.');
  // Store the full answer payload before marking the task complete.
  await Cache.storeDeferredFitbitRequests(
    requests,
    preparePayload: () => prepareQuestionnaireMedia(questionnaireState),
  );
  final progress = SubjectProgress(
    subjectId: subject.id,
    interventionId: interventionId,
    taskId: task.id,
    resultType: 'QuestionnaireState',
    result: Result<QuestionnaireState>.app(
      type: 'QuestionnaireState',
      periodId: periodId,
      result: questionnaireState,
    ),
  )..completedAt = timestamp;
  subject.progress.add(progress);
  try {
    await Cache.storeSubject(subject);
  } catch (error) {
    // The queue already contains the complete result for restart recovery.
    StudyULogger.warning(
      'Deferred result is queued, but the subject cache write failed: $error',
    );
  }
  ActiveSubjectSyncController.instance.markSynchronizationPending();
}

Future<StudySubject> restoreDeferredFitbitProgress(StudySubject subject) async {
  for (final request in await Cache.loadDeferredFitbitRequests()) {
    if (request.subjectId != subject.id ||
        request.questionnaireState == null ||
        subject.progress.any((progress) => _matches(progress, request))) {
      continue;
    }
    subject.progress.add(
      SubjectProgress(
        subjectId: request.subjectId,
        interventionId: request.interventionId,
        taskId: request.taskId,
        resultType: 'QuestionnaireState',
        result: Result<QuestionnaireState>.app(
          type: 'QuestionnaireState',
          periodId: request.periodId,
          result: QuestionnaireState.fromJson(
            request.questionnaireState!.toJson(),
          ),
        ),
      )..completedAt = request.completedAt,
    );
  }
  return subject;
}

bool _matches(SubjectProgress progress, DeferredFitbitRequest request) =>
    progress.subjectId == request.subjectId &&
    progress.interventionId == request.interventionId &&
    progress.taskId == request.taskId &&
    progress.result.periodId == request.periodId &&
    progress.completedAt?.toUtc() == request.completedAt.toUtc();

Future<bool> synchronizeDeferredFitbitRequests(
  StudySubject subject, {
  required Future<SubjectProgress> Function(SubjectProgress) saveProgress,
  required Future<StudySubject> Function(StudySubject) saveSubject,
  void Function(Object error)? onError,
}) async {
  final requests =
      (await Cache.loadDeferredFitbitRequests())
          .where((request) => request.subjectId == subject.id)
          .toList()
        ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
  final groups = <String, List<DeferredFitbitRequest>>{};
  for (final request in requests) {
    final key =
        '${request.subjectId}:${request.completedAt.toUtc().toIso8601String()}';
    groups.putIfAbsent(key, () => []).add(request);
  }
  var succeeded = true;
  for (final group in groups.values) {
    try {
      final request = group.first;
      final matches = subject.progress.where(
        (progress) => _matches(progress, request),
      );
      SubjectProgress progress;
      if (matches.isNotEmpty) {
        progress = SubjectProgress.fromJson(matches.first.toJson());
      } else {
        if (request.questionnaireState == null) {
          throw StateError('Missing deferred answer payload.');
        }
        progress = SubjectProgress(
          subjectId: request.subjectId,
          interventionId: request.interventionId,
          taskId: request.taskId,
          resultType: 'QuestionnaireState',
          result: Result<QuestionnaireState>.app(
            type: 'QuestionnaireState',
            periodId: request.periodId,
            result: QuestionnaireState.fromJson(
              request.questionnaireState!.toJson(),
            ),
          ),
        )..completedAt = request.completedAt;
      }
      var resolved = true;
      final needsSave =
          matches.isEmpty || hasDeferredFitbitProgress(subject.study, progress);
      for (final pending in group) {
        try {
          final state = progress.result.result as QuestionnaireState;
          final response = state.answers[pending.questionId]?.response;
          if (response is List && response.isNotEmpty) continue;
          final question = _questions(
            subject.study,
            pending.taskId,
          ).firstWhere((question) => question.id == pending.questionId);
          final data = await FitbitHandler.resolveDeferredRequest(
            subject,
            pending,
            question,
          );
          state.answers[pending.questionId] =
              Answer<List<String>>(
                  pending.questionId,
                  state.answers[pending.questionId]?.timestamp ??
                      pending.completedAt,
                )
                ..response = data
                    .map((entry) => jsonEncode(entry.toJson()))
                    .toList();
        } catch (error) {
          onError?.call(error);
          resolved = false;
          succeeded = false;
        }
      }
      if (!resolved) continue;
      if (needsSave) {
        await saveProgress(progress);
        final updated = StudySubject.fromJson(subject.toFullJson());
        updated.progress.removeWhere((p) => _matches(p, request));
        updated.progress.add(progress);
        await saveSubject(updated);
      }
      subject.progress.removeWhere((p) => _matches(p, request));
      subject.progress.add(progress);
      for (final pending in group) {
        await Cache.removeDeferredFitbitRequest(pending.id);
      }
    } catch (error) {
      onError?.call(error);
      succeeded = false;
    }
  }
  return succeeded;
}
