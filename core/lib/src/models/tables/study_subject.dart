import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/env/env.dart' as env;
import 'package:uuid/uuid.dart';

part 'study_subject.g.dart';

@JsonSerializable()
class StudySubject extends SupabaseObjectFunctions<StudySubject> {
  static const String tableName = 'study_subject';
  final _controller = StreamController<StudySubject>();

  @override
  Map<String, Object> get primaryKeys => {'id': id};

  String id;
  @JsonKey(name: 'study_id')
  String studyId;
  @JsonKey(name: 'user_id')
  String userId;
  @JsonKey(name: 'started_at')
  // Should be converted to UTC before saving
  DateTime? startedAt;
  @JsonKey(name: 'selected_intervention_ids')
  List<String> selectedInterventionIds;
  @JsonKey(name: 'invite_code')
  String? inviteCode;
  @JsonKey(name: 'is_deleted')
  bool isDeleted = false;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late Study study;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late List<SubjectProgress> progress = [];

  new(this.id, this.studyId, this.userId, this.selectedInterventionIds);

  factory fromJson(Map<String, dynamic> json) {
    final subject = _$StudySubjectFromJson(json);

    final Map<String, dynamic>? study = json['study'] as Map<String, dynamic>?;
    if (study != null) {
      subject.study = Study.fromJson(study);
    }

    final List? progress = json['subject_progress'] as List?;
    if (progress != null) {
      subject.progress = progress
          .map((json) => SubjectProgress.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return subject;
  }

  @override
  Map<String, dynamic> toJson() => _$StudySubjectToJson(this);

  new fromStudy(
    this.study,
    this.userId,
    this.selectedInterventionIds,
    this.inviteCode,
  ) : id = const Uuid().v4(),
      studyId = study.id;

  List<String> get interventionOrder =>
      study.schedule.generateInterventionIdsInOrder(selectedInterventionIds);

  List<Intervention> get selectedInterventions {
    final selectedInterventions = selectedInterventionIds
        .map(
          (selectedInterventionId) => study.interventions.singleWhere(
            (intervention) => intervention.id == selectedInterventionId,
          ),
        )
        .toList();
    if (study.schedule.includeBaseline) {
      selectedInterventions.add(
        Intervention(Study.baselineID, 'Baseline')
          ..tasks = []
          ..icon = 'rayStart',
      );
    }
    return selectedInterventions;
  }

  int get daysPerIntervention =>
      study.schedule.numberOfCycles * study.schedule.phaseDuration;

  Map<DateTime, List<SubjectProgress>> getResultsByDate({
    required String interventionId,
  }) {
    final resultsByDate = <DateTime, List<SubjectProgress>>{};
    progress.where((p) => p.interventionId == interventionId).forEach((p) {
      final date = DateTime(
        p.completedAt!.year,
        p.completedAt!.month,
        p.completedAt!.day,
      );
      resultsByDate.putIfAbsent(date, () => []);
      resultsByDate[date]!.add(p);
    });
    return resultsByDate;
  }

  // Day after last intervention
  DateTime endDate(DateTime dt) => dt.add(
    Duration(days: interventionOrder.length * study.schedule.phaseDuration),
  );

  int getDayOfStudyFor(DateTime date) {
    return date.differenceInDays(startedAt!);
  }

  int getInterventionIndexForDate(DateTime date) {
    final test = date.differenceInDays(startedAt!);
    return test ~/ study.schedule.phaseDuration;
  }

  Intervention? getInterventionForDate(DateTime date) {
    final index = getInterventionIndexForDate(date);
    if (date.isBefore(startedAt!) || index >= interventionOrder.length) {
      print('Study is over or has not begun.');
      return null;
    }
    final interventionId = interventionOrder[index];
    return selectedInterventions.firstWhereOrNull(
      (intervention) => intervention.id == interventionId,
    );
  }

  List<Intervention> getInterventionsInOrder() {
    return interventionOrder
        .map(
          (key) => selectedInterventions.firstWhere(
            (intervention) => intervention.id == key,
          ),
        )
        .toList();
  }

  DateTime startOfPhase(int index) =>
      startedAt!.add(Duration(days: study.schedule.phaseDuration * index));

  DateTime dayAfterEndOfPhase(int index) =>
      startOfPhase(index).add(Duration(days: study.schedule.phaseDuration));

  List<SubjectProgress> resultsFor(String taskId) =>
      progress.where((p) => p.taskId == taskId).toList();

  int completedForPhase(int index) {
    final start = startOfPhase(index);
    int completedCount = 0;
    for (int i = 0; i < study.schedule.phaseDuration; i++) {
      if (allTasksCompletedFor(start.add(Duration(days: i)))) {
        completedCount++;
      }
    }
    return completedCount;
  }

  int daysLeftForPhase(int index) {
    final start = startOfPhase(index);
    return study.schedule.phaseDuration -
        DateTime.now().differenceInDays(start);
  }

  double percentCompletedForPhase(int index) {
    return completedForPhase(index) / study.schedule.phaseDuration;
  }

  double percentMissedForPhase(int index, DateTime date) {
    if (startOfPhase(index).isAfter(date)) return 0;

    final missedInPhase =
        min(
          date.differenceInDays(startOfPhase(index)),
          study.schedule.phaseDuration,
        ) -
        completedForPhase(index);
    return missedInPhase / study.schedule.phaseDuration;
  }

  List<SubjectProgress> getTaskProgressForDay(
    String taskId,
    DateTime dateTime,
  ) {
    final List<SubjectProgress> thisTaskProgressToday = [];
    for (final SubjectProgress sp in resultsFor(taskId)) {
      if (sp.subjectId == id && sp.completedAt!.isSameDate(dateTime)) {
        thisTaskProgressToday.add(sp);
      }
    }
    return thisTaskProgressToday;
  }

  /// Check if a task instance is completed
  /// returns true if a given task has been completed for a specific
  /// completionPeriod on a given day
  bool completedTaskInstanceForDay(
    String taskId,
    CompletionPeriod completionPeriod,
    DateTime dateTime,
  ) {
    return getTaskProgressForDay(taskId, dateTime).any((progress) {
      if (progress.result.periodId == null) {
        // fallback to support studies without periodIds
        return progress.completedAt!.isSameDate(dateTime);
      }
      return progress.result.periodId == completionPeriod.id;
    });
  }

  /// Check if a task is fully completed for all task instances
  /// returns true if a given task has been completed for all of its
  /// completionPeriods on a given day
  bool completedTaskForDay(String taskId, DateTime dateTime) {
    return [
          ...selectedInterventions.expand((e) => e.tasks),
          ...study.observations,
        ]
        .where((task) => task.id == taskId)
        .single
        .schedule
        .completionPeriods
        .any((period) => completedTaskInstanceForDay(taskId, period, dateTime));
  }

  int completedTasksFor(Task task) => resultsFor(task.id).length;

  /// Check if all tasks are fully completed on a given day
  /// returns true if all of of the tasks (interventions & observations)
  /// have been completed on a given day
  bool allTasksCompletedFor(DateTime dateTime) => scheduleFor(dateTime).every(
    (taskInstance) => completedTaskForDay(taskInstance.task.id, dateTime),
  );

  // Currently the end of the study, as there is no real minimum, just a set study length
  bool get minimumStudyLengthCompleted {
    final diff = DateTime.now().differenceInDays(startedAt!);
    return diff >= interventionOrder.length * study.schedule.phaseDuration - 1;
  }

  bool get completedStudy {
    return minimumStudyLengthCompleted && allTasksCompletedFor(DateTime.now());
  }

  int totalTaskCountFor(Task task) {
    var daysCount = daysPerIntervention;
    if (task is Observation) {
      if (task.scheduleRule != null) {
        daysCount = task.scheduleRule!
            .resolveScheduledDays(study.schedule)
            .length;
        if (daysCount == 0) daysCount = 1; // Minimum 1 to avoid zero-count
      } else {
        daysCount =
            2 * daysCount +
            (study.schedule.includeBaseline ? study.schedule.phaseDuration : 0);
      }
    }
    return daysCount * task.schedule.completionPeriods.length;
  }

  List<TaskInstance> scheduleFor(DateTime dateTime) {
    final activeIntervention = getInterventionForDate(dateTime);
    final List<TaskInstance> taskSchedule = [];
    if (activeIntervention == null) return taskSchedule;

    for (final task in activeIntervention.tasks) {
      if (task.title == null) continue;
      for (final completionPeriod in task.schedule.completionPeriods) {
        taskSchedule.add(TaskInstance(task, completionPeriod.id));
      }
    }
    final studyDayIndex = getDayOfStudyFor(dateTime);
    final phaseDuration = study.schedule.phaseDuration;
    final firstInterventionStartDay = study.schedule.includeBaseline
        ? phaseDuration
        : 0;

    for (final observation in study.observations) {
      final title = observation.title;
      if (title == null) {
        for (final completionPeriod in observation.schedule.completionPeriods) {
          taskSchedule.add(TaskInstance(observation, completionPeriod.id));
        }
        continue;
      }

      // Scheduled survey: show only on matching days
      if (observation.scheduleRule != null) {
        if (!observation.scheduleRule!.isScheduledForDay(
          studyDayIndex,
          study.schedule,
        )) {
          continue;
        }
        for (final completionPeriod in observation.schedule.completionPeriods) {
          taskSchedule.add(TaskInstance(observation, completionPeriod.id));
        }
        continue;
      }

      // Normal (test) FFQ: one-time on first day of intervention 1
      if (FFQQuestions.isFFQTask(title)) {
        final firstInterventionIndex = study.schedule.includeBaseline ? 1 : 0;
        final interventionIndex = getInterventionIndexForDate(dateTime);
        if (interventionIndex != firstInterventionIndex ||
            studyDayIndex != firstInterventionStartDay) {
          continue;
        }
        if (resultsFor(observation.id).isNotEmpty) continue;
      }

      for (final completionPeriod in observation.schedule.completionPeriods) {
        taskSchedule.add(TaskInstance(observation, completionPeriod.id));
      }
    }
    return taskSchedule;
  }

  Future<void> setStartDateBackBy({required int days}) async {
    await deleteProgress();
    progress = await SupabaseQuery.batchUpsert<SubjectProgress>(
      progress.map((p) => p.setStartDateBackBy(days: days).toJson()).toList(),
    );
    startedAt = startedAt!.subtract(Duration(days: days));
    save(onlyUpdate: true);
  }

  @override
  Future<StudySubject> save({bool onlyUpdate = false}) async {
    try {
      final tableQuery = env.client.from(tableName);
      final query = onlyUpdate
          ? tableQuery.update(toJson()).eq("id", id)
          : tableQuery.upsert(toJson());
      final response = await query.select();
      final json = toFullJson(
        partialJson: List<Map<String, dynamic>>.from(response).single,
      );
      final newSubject = StudySubject.fromJson(json);
      _controller.add(newSubject);
      // print("Saving study subject");
      return newSubject;
    } catch (e, stack) {
      SupabaseQuery.catchSupabaseException(e, stack);
      rethrow;
    }
  }

  Map<String, dynamic> toFullJson({Map<String, dynamic>? partialJson}) {
    final json = partialJson ?? toJson();
    json['study'] = study.toJson();
    json['subject_progress'] = progress.map((p) => p.toJson()).toList();
    return json;
  }

  Stream<StudySubject> get onSave => _controller.stream;

  Future<void> deleteProgress() async {
    try {
      await env.client
          .from(SubjectProgress.tableName)
          .delete()
          .eq('subject_id', id);
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
      rethrow;
    }

    // Filter out all multimodal answers and remove their paths from the blob storage
    final observationPaths = progress
        .where((p) => p.result.result is QuestionnaireState)
        .map((p) => (p.result.result as QuestionnaireState).answers.values)
        .expand((answers) => answers)
        .where(
          (e) =>
              e.question == AudioRecordingQuestion.questionType ||
              e.question == ImageCapturingQuestion.questionType,
        )
        .map((e) => e.response!.toString())
        .toList();

    if (observationPaths.isNotEmpty) {
      BlobStorageHandler().removeObservation(observationPaths);
    }
  }

  @override
  Future<StudySubject> delete() async {
    await deleteProgress();
    try {
      final response = await env.client
          .from(tableName)
          .delete()
          .eq('id', id)
          .select()
          .single();
      response['study'] = study.toJson();
      return StudySubject.fromJson(response);
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  Future<StudySubject> softDelete() {
    isDeleted = true;
    return save(onlyUpdate: true);
  }

  static Future<List<StudySubject>> getStudyHistory(String userId) async {
    return SupabaseQuery.extractSupabaseList<StudySubject>(
      await env.client
          .from(tableName)
          .select('*,study!study_subject_studyId_fkey(*),subject_progress(*)')
          .eq('user_id', userId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySubject &&
          runtimeType == other.runtimeType &&
          jsonEncode(toFullJson()) == jsonEncode(other.toFullJson());

  @override
  int get hashCode => toFullJson().hashCode;

  @override
  String toString() {
    return 'StudySubject{id: $id, studyId: $studyId, userId: $userId, startedAt: $startedAt, selectedInterventionIds: $selectedInterventionIds, inviteCode: $inviteCode, isDeleted: $isDeleted, study: $study, progress: $progress}';
  }
}
