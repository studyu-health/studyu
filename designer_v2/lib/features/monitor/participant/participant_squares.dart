import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/features/monitor/participant/participant_square.dart';

class const ParticipantSquares({
  required final StudyMonitorItem monitorItem,
  required final Study study,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phases = _buildPhases();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: phases.mapIndexed((phaseIndex, phase) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!phase.intervention.isBaseline())
                  interventionPrefix(
                    study.interventions.indexOf(phase.intervention),
                    theme,
                  ),
                Text(
                  phase.intervention.name!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              children: phase.missedTasksPerDay
                  .mapIndexed(
                    (index, missed) => ParticipantSquare(
                      index: index,
                      missed: missed,
                      completed: phase.completedTasksPerDay[index],
                      numberOfTheDay:
                          (phaseIndex * study.schedule.phaseDuration) +
                          index +
                          1,
                      monitorItem: monitorItem,
                      study: study,
                    ),
                  )
                  .toList(),
            ),
            if (phaseIndex < phases.length - 1) const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  List<StudyPhase> _buildPhases() {
    final totalCompletedDays = monitorItem.missedTasksPerDay.length;
    final phases = <StudyPhase>[];

    if (study.schedule.includeBaseline) {
      const startInx = 0;
      final endInx = totalCompletedDays > study.schedule.baselineLength
          ? study.schedule.baselineLength
          : totalCompletedDays;
      phases.add(
        StudyPhase(
          intervention: Intervention.withId()..name = 'Baseline',
          missedTasksPerDay: monitorItem.missedTasksPerDay.sublist(
            startInx,
            endInx,
          ),
          completedTasksPerDay: monitorItem.completedTasksPerDay.sublist(
            startInx,
            endInx,
          ),
        ),
      );
    }

    final numberOfInterventionPhases =
        study.schedule.numberOfCycles *
        (study.schedule.sequence == PhaseSequence.customized
            ? study.schedule.sequenceCustom.length
            : StudySchedule.numberOfInterventions);
    for (int i = 0; i < numberOfInterventionPhases; i++) {
      final int phaseDuration = study.schedule.phaseDuration;
      final bool includeBaseline = study.schedule.includeBaseline;
      final int baselineAdjustmentStart = includeBaseline
          ? (i + 1) * phaseDuration
          : i * phaseDuration;
      final int baselineAdjustmentEnd = includeBaseline
          ? (i + 2) * phaseDuration
          : (i + 1) * phaseDuration;

      if (baselineAdjustmentStart >= totalCompletedDays) break;

      final int start = totalCompletedDays > baselineAdjustmentStart
          ? baselineAdjustmentStart
          : totalCompletedDays;

      final int end = totalCompletedDays > baselineAdjustmentEnd
          ? baselineAdjustmentEnd
          : totalCompletedDays;

      monitorItem.studySubject.study = study;
      final intervention = monitorItem.studySubject
          .getInterventionsInOrder()[i + (includeBaseline ? 1 : 0)];

      phases.add(
        StudyPhase(
          intervention: intervention,
          missedTasksPerDay: monitorItem.missedTasksPerDay.sublist(start, end),
          completedTasksPerDay: monitorItem.completedTasksPerDay.sublist(
            start,
            end,
          ),
        ),
      );
    }
    assert(
      monitorItem.missedTasksPerDay.length ==
          monitorItem.completedTasksPerDay.length,
    );
    return phases;
  }
}

class StudyPhase({
  required final Intervention intervention,
  required final List<Set<String>> missedTasksPerDay,
  required final List<Set<String>> completedTasksPerDay,
});
