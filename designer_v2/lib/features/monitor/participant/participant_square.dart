import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/striped_gradient.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/features/monitor/participant/colors.dart';

class const ParticipantSquare({
  super.key,
  required final int index,
  required final Set<String> missed,
  required final Set<String> completed,
  required final int numberOfTheDay,
  required final StudyMonitorItem monitorItem,
  required final Study study,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _getTooltipText(),
      child: Container(
        height: 50,
        width: 50,
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 8),
        decoration: BoxDecoration(
          color: missed.isEmpty
              ? completeColor
              : (completed.isEmpty
                    ? incompleteColor
                    : null), // Set color to null when using gradient
          gradient: completed.isEmpty || missed.isEmpty
              ? null
              : StripedGradient(
                  colors: [
                    partiallyCompleteColor,
                    partiallyCompleteColor,
                    incompleteColor,
                    incompleteColor,
                  ],
                ).gradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            numberOfTheDay.toString(),
            style: TextStyle(
              color: missed.isEmpty ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  String _getTooltipText() {
    final sb = StringBuffer();
    for (final intervention in study.interventions) {
      for (final task in intervention.tasks) {
        if (missed.contains(task.id)) {
          sb.writeln('\u{274C} ${task.title}');
        } else if (completed.contains(task.id)) {
          sb.writeln('\u{2705} ${task.title}');
        }
      }
    }
    for (final observation in study.observations) {
      if (missed.contains(observation.id)) {
        sb.writeln('\u{274C} ${observation.title}');
      } else if (completed.contains(observation.id)) {
        sb.writeln('\u{2705} ${observation.title}');
      }
    }
    String str = sb.toString();
    if (str.isNotEmpty) {
      str = str.substring(0, str.length - 1);
    }
    return str;
  }
}
