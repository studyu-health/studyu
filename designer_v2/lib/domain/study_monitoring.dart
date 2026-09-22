import 'dart:math';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';

class const StudyMonitorItem({
  required final StudySubject studySubject,
  required final String participantId,
  required final String? inviteCode,
  required final DateTime startedAt,
  required final DateTime lastActivityAt,
  required final int currentDayOfStudy,
  required final int studyDurationInDays,
  required final int completedInterventions,
  required final int missedInterventions,
  required final int completedSurveys,
  required final int missedSurveys,
  required final bool droppedOut,
  required final List<Set<String>> missedTasksPerDay,
  required final List<Set<String>> completedTasksPerDay,
  required final int totalInterventionTasks,
  required final int totalSurveyTasks,
}) extends Equatable {
  this
    : assert(missedTasksPerDay.length == currentDayOfStudy),
      assert(completedTasksPerDay.length == currentDayOfStudy);

  @override
  List<Object?> get props => [participantId];
}

extension StudyMonitoringX on Study {
  int _calculateTotalInterventionTasks({
    required List<Intervention> interventions,
    required StudySchedule schedule,
    required StudySubject participant,
  }) {
    // Generate the ordered list of intervention IDs and exclude baseline
    final interventionOrder = schedule
        .generateInterventionIdsInOrder(participant.selectedInterventionIds)
        .where((id) => id != Study.baselineID)
        .toList();

    // Build a map for quick lookup of interventions by ID
    final interventionMap = {for (final i in interventions) i.id: i};

    int total = 0;
    for (final id in interventionOrder) {
      if (!participant.selectedInterventionIds.contains(id)) continue;
      final intervention = interventionMap[id];
      if (intervention != null) {
        total += intervention.tasks.length * schedule.phaseDuration;
      }
    }
    return total;
  }

  List<StudyMonitorItem> get monitorData {
    final schedule = this.schedule;
    final interventions = this.interventions;
    final observations = this.observations;

    final participants = (this.participants ?? []).toList();
    final participantsProgress = (this.participantsProgress ?? []).toList();

    // Group and sort progresses by participant ID
    final progressMap = <String, List<SubjectProgress>>{};
    for (final progress in participantsProgress) {
      progressMap.putIfAbsent(progress.subjectId, () => []).add(progress);
    }
    for (final progresses in progressMap.values) {
      progresses.sort((b, a) => a.completedAt!.compareTo(b.completedAt!));
    }

    final requiredSurveyTaskIds = observations.map((o) => o.id).toSet();
    final totalSurveyTasksPerDay = observations.length;
    final totalDays = schedule.length;

    final interventionMap = {for (final i in interventions) i.id: i};

    // Sort participants by start date (ascending)
    participants.sort((a, b) => a.startedAt!.compareTo(b.startedAt!));

    final items = <StudyMonitorItem>[];
    final nowUtc = DateTime.now().toUtc();

    for (final participant in participants) {
      final progresses = progressMap[participant.id] ?? [];
      final start = participant.startedAt!;
      final lastActivityAt = progresses.isNotEmpty
          ? progresses.first.completedAt!
          : start;

      final daysSinceStart = nowUtc.difference(start).inDays;
      final currentDayOfStudy = min(daysSinceStart, totalDays);
      final daysInBaseline = schedule.includeBaseline
          ? schedule.phaseDuration
          : 0;

      int completedInterventions = 0;
      int completedSurveys = 0;
      final missedTasksPerDay = <Set<String>>[];
      final completedTasksPerDay = <Set<String>>[];

      final interventionOrder = schedule
          .generateInterventionIdsInOrder(participant.selectedInterventionIds)
          .toList();

      for (int day = 0; day < currentDayOfStudy; day++) {
        final dayStart = start.add(Duration(days: day));
        final dayEnd = start.add(Duration(days: day + 1));

        Set<String> requiredInterventionTaskIds = {};
        if (day >= daysInBaseline) {
          final phaseIndex = day ~/ schedule.phaseDuration;
          if (phaseIndex < interventionOrder.length) {
            final interventionId = interventionOrder[phaseIndex];
            final intervention = interventionMap[interventionId];
            if (intervention != null) {
              requiredInterventionTaskIds = {
                for (final t in intervention.tasks) t.id,
              };
            }
          }
        }

        final requiredTaskIds = {
          ...requiredInterventionTaskIds,
          ...requiredSurveyTaskIds,
        };

        final completedForDay = progresses
            .where(
              (p) =>
                  p.completedAt!.isAfter(dayStart) &&
                  p.completedAt!.isBefore(dayEnd),
            )
            .map((p) => p.taskId)
            .toSet();

        final missedForDay = requiredTaskIds.difference(completedForDay);
        missedTasksPerDay.add(missedForDay);

        final completedForDayRequired = requiredTaskIds.intersection(
          completedForDay,
        );
        completedTasksPerDay.add(completedForDayRequired);

        completedSurveys += requiredSurveyTaskIds
            .intersection(completedForDay)
            .length;
        completedInterventions += requiredInterventionTaskIds
            .intersection(completedForDay)
            .length;
      }

      final totalSurveys = currentDayOfStudy * totalSurveyTasksPerDay;
      final totalInterventions = max(0, currentDayOfStudy - daysInBaseline);

      final missedInterventions = totalInterventions - completedInterventions;
      final missedSurveys = totalSurveys - completedSurveys;

      final totalInterventionTasks = _calculateTotalInterventionTasks(
        interventions: interventions,
        schedule: schedule,
        participant: participant,
      );

      final totalSurveyTasks = totalSurveyTasksPerDay * totalDays;

      items.add(
        StudyMonitorItem(
          studySubject: participant,
          participantId: participant.id,
          inviteCode: participant.inviteCode,
          startedAt: start,
          lastActivityAt: lastActivityAt,
          currentDayOfStudy: currentDayOfStudy,
          studyDurationInDays: totalDays,
          completedInterventions: completedInterventions,
          missedInterventions: missedInterventions,
          completedSurveys: completedSurveys,
          missedSurveys: missedSurveys,
          droppedOut: participant.isDeleted,
          missedTasksPerDay: missedTasksPerDay,
          completedTasksPerDay: completedTasksPerDay,
          totalInterventionTasks: totalInterventionTasks,
          totalSurveyTasks: totalSurveyTasks,
        ),
      );
    }

    // Ensure the items list matches the expected categorization order
    final participantCategories =
        items.activeParticipants.toList() +
        items.inactiveParticipants.toList() +
        items.dropoutParticipants.toList() +
        items.completedParticipants.toList();

    assert(
      const DeepCollectionEquality.unordered().equals(
        items,
        participantCategories,
      ),
    );

    return items;
  }
}

// extension StudyMonitoringX on Study {
//   int _calculateTotalInterventionTasks({
//     required List<Intervention> interventions,
//     required StudySchedule schedule,
//     required StudySubject participant,
//   }) {
//     final interventionIdsInOrder = schedule.generateInterventionIdsInOrder(
//       participant.selectedInterventionIds,
//     );
//
//     // Remove the baseline if it exists
//     final effectiveInterventionIds =
//         interventionIdsInOrder.where((id) => id != Study.baselineID);
//
//     final Map<String, int> interventionCounts = {};
//
//     for (final id in effectiveInterventionIds) {
//       if (!participant.selectedInterventionIds.contains(id)) continue;
//       interventionCounts[id] = (interventionCounts[id] ?? 0) + 1;
//     }
//
//     int total = 0;
//     for (final entry in interventionCounts.entries) {
//       final intervention = interventions.firstWhere((i) => i.id == entry.key);
//       total += intervention.tasks.length * entry.value * schedule.phaseDuration;
//     }
//
//     return total;
//   }
//
//   List<StudyMonitorItem> get monitorData {
//     final List<StudyMonitorItem> items = [];
//
//     final participants = this.participants ?? [];
//     final participantsProgress = this.participantsProgress ?? [];
//
//     participants
//         .sort((a, b) => a.startedAt!.compareTo(b.startedAt!)); // ascending
//
//     for (final participant in participants) {
//       final progresses = participantsProgress
//           .where((progress) => progress.subjectId == participant.id)
//           .toList();
//
//       progresses.sort(
//         (b, a) => a.completedAt!.compareTo(b.completedAt!),
//       ); // descending
//
//       final interventionOrder = schedule
//           .generateInterventionIdsInOrder(participant.selectedInterventionIds);
//
//       final lastActivityAt = progresses.isNotEmpty
//           ? progresses.first.completedAt!
//           : participant.startedAt!;
//
//       final studyDurationInDays = schedule.length;
//
//       final currentDayOfStudy = min(
//         studyDurationInDays,
//         DateTime.now().toUtc().difference(participant.startedAt!).inDays,
//       );
//
//       final daysInBaseline =
//           schedule.includeBaseline ? schedule.phaseDuration : 0;
//
//       final Set<String> requiredSurveyTaskIds =
//           observations.map((o) => o.id).toSet();
//
//       int completedInterventions = 0;
//       int completedSurveys = 0;
//       final List<Set<String>> missedTasksPerDay = [];
//       final List<Set<String>> completedTasksPerDay = [];
//
//       for (int day = 0; day < currentDayOfStudy; day++) {
//         final Set<String> requiredInterventionTaskIds = {};
//
//         if (day >= daysInBaseline) {
//           final interventionIdForThisPhase =
//               interventionOrder[day ~/ schedule.phaseDuration];
//
//           final interventionForThisPhase = interventions
//               .firstWhere((i) => i.id == interventionIdForThisPhase);
//
//           requiredInterventionTaskIds
//               .addAll(interventionForThisPhase.tasks.map((t) => t.id));
//         }
//
//         final requiredTaskIds =
//             requiredInterventionTaskIds.union(requiredSurveyTaskIds);
//
//         final completedTaskIds = progresses
//             .where(
//               (p) =>
//                   p.completedAt!.isAfter(
//                     participant.startedAt!.add(Duration(days: day)),
//                   ) &&
//                   p.completedAt!.isBefore(
//                     participant.startedAt!.add(Duration(days: day + 1)),
//                   ),
//             )
//             .map((p) => p.taskId)
//             .toSet();
//
//         final missedTaskIds = requiredTaskIds.difference(completedTaskIds);
//         missedTasksPerDay.add(missedTaskIds);
//
//         final completedTaskIdsPerDay =
//             requiredTaskIds.intersection(completedTaskIds);
//         completedTasksPerDay.add(completedTaskIdsPerDay);
//
//         final completedSurveysSet =
//             requiredSurveyTaskIds.intersection(completedTaskIds);
//
//         // final completedIntervention = requiredInterventionTaskIds.isNotEmpty &&
//         //     requiredInterventionTaskIds.intersection(completedTaskIds).length ==
//         //         requiredInterventionTaskIds.length;
//
//         completedSurveys += completedSurveysSet.length;
//
//         completedInterventions +=
//             requiredInterventionTaskIds.intersection(completedTaskIds).length;
//       }
//
//       final totalSurveys = currentDayOfStudy * observations.length;
//       final totalInterventions = max(0, currentDayOfStudy - daysInBaseline);
//
//       final missedInterventions = totalInterventions - completedInterventions;
//       final missedSurveys = totalSurveys - completedSurveys;
//
//       // final totalInterventionTasks = interventions
//       //         .where((i) => participant.selectedInterventionIds.contains(i.id))
//       //         .map((i) => i.tasks.length)
//       //         .fold(0, (prev, element) => prev + element) *
//       //     schedule.phaseDuration *
//       //     schedule.numberOfCycles;
//
//       // Calculate total number of tasks for all interventions for this participant
//       final totalInterventionTasks = _calculateTotalInterventionTasks(
//         interventions: interventions,
//         schedule: schedule,
//         participant: participant,
//       );
//
//       //calculate the total number of surveys for this participant
//       final totalSurveyTasks = observations
//               .where((o) => requiredSurveyTaskIds.contains(o.id))
//               .length *
//           schedule.length;
//
//       items.add(
//         StudyMonitorItem(
//           studySubject: participant,
//           participantId: participant.id,
//           inviteCode: participant.inviteCode,
//           startedAt: participant.startedAt!,
//           lastActivityAt: lastActivityAt,
//           currentDayOfStudy: currentDayOfStudy,
//           studyDurationInDays: studyDurationInDays,
//           completedInterventions: completedInterventions,
//           missedInterventions: missedInterventions,
//           completedSurveys: completedSurveys,
//           missedSurveys: missedSurveys,
//           droppedOut: participant.isDeleted,
//           missedTasksPerDay: missedTasksPerDay,
//           completedTasksPerDay: completedTasksPerDay,
//           totalInterventionTasks: totalInterventionTasks,
//           totalSurveyTasks: totalSurveyTasks,
//         ),
//       );
//     }
//
//     final participantCategories = items.activeParticipants.toList() +
//         items.inactiveParticipants.toList() +
//         items.dropoutParticipants.toList() +
//         items.completedParticipants.toList();
//     final deepEq = const DeepCollectionEquality.unordered().equals;
//     assert(deepEq(items, participantCategories));
//
//     return items;
//   }
// }

extension ListX on List<StudyMonitorItem> {
  static final inactiveDate = DateTime.now().subtract(
    const Duration(days: Config.participantInactiveDuration),
  );
  static final dropoutDate = DateTime.now().subtract(
    const Duration(days: Config.participantDropoutDuration),
  );

  static bool Function(StudyMonitorItem p) get studyStillRunning =>
      (StudyMonitorItem p) => p.currentDayOfStudy < p.studyDurationInDays;

  static bool Function(StudyMonitorItem p) get inactive =>
      (p) =>
          p.lastActivityAt.isBefore(inactiveDate) &&
          p.lastActivityAt.isAfter(dropoutDate);

  static bool Function(StudyMonitorItem p) get dropout =>
      (p) => p.droppedOut || dropoutByDuration(p) && studyStillRunning(p);

  static bool Function(StudyMonitorItem p) get dropoutByDuration =>
      (p) => p.lastActivityAt.isBefore(dropoutDate);

  /// Number of participants who are currently active in the study
  /// Active means that the the study has not ended yet and the participant
  /// did not drop out
  Iterable<StudyMonitorItem> get activeParticipants =>
      where((p) => !dropout(p) && !inactive(p) && studyStillRunning(p));

  /// Number of participants who are currently inactive in the study for more
  /// than [participantDropoutDuration] days in a row
  Iterable<StudyMonitorItem> get inactiveParticipants =>
      where((p) => !dropout(p) && inactive(p) && studyStillRunning(p));

  /// Number of participants who dropped out of the study before the study ended
  /// Hint: The is_deleted flag in the study_subject database table marks a
  /// participant as dropped out
  /// Note: If the participant's last activity exceeds
  /// [participantDropoutDuration] days, they will also be counted as a dropout
  Iterable<StudyMonitorItem> get dropoutParticipants =>
      where((p) => dropout(p));

  /// Number of participants who completed the study
  /// Completed means that the participant has reached the end of the study
  Iterable<StudyMonitorItem> get completedParticipants =>
      where((p) => !dropout(p) && !studyStillRunning(p));
}
