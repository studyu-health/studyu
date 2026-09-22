import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/features/monitor/participant/participant_info.dart';
import 'package:studyu_designer_v2/features/monitor/participant/participant_legend.dart';
import 'package:studyu_designer_v2/features/monitor/participant/participant_squares.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const ParticipantDetailsView({
  required final StudyMonitorItem monitorItem,
  required final Study study,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParticipantInfo(monitorItem: monitorItem),
        const SizedBox(height: 8.0),
        const Divider(),
        const SizedBox(height: 8.0),
        if (monitorItem.missedTasksPerDay.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextParagraph(
                text: tr.participant_details_study_days_description,
              ),
              const SizedBox(height: 16.0),
              ParticipantSquares(monitorItem: monitorItem, study: study),
              const SizedBox(height: 16.0),
              const ParticipantLegend(),
            ],
          )
        else
          EmptyBody(
            icon: Icons.hourglass_empty,
            title: tr.participant_details_progress_empty_title,
            description: tr.participant_details_progress_empty_description,
          ),
      ],
    );
  }
}
