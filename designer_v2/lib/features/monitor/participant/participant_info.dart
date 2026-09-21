import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class const ParticipantInfo({
  required final StudyMonitorItem monitorItem,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(localeProvider).languageCode;
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            tr.monitoring_table_column_participant_id,
            monitorItem.participantId,
          ),
          _buildInfoRow(
            tr.monitoring_table_column_invite_code,
            monitorItem.inviteCode ?? 'N/A',
          ),
          _buildInfoRow(
            tr.monitoring_table_column_enrolled,
            monitorItem.startedAt.toLocalizedString(
              locale: languageCode,
              showTime: false,
            ),
          ),
          _buildInfoRow(
            tr.monitoring_table_column_last_activity,
            monitorItem.lastActivityAt.toLocalizedString(locale: languageCode),
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            tr.monitoring_table_column_day_in_study,
            '${monitorItem.currentDayOfStudy}/${monitorItem.studyDurationInDays}',
          ),
          _buildInfoRow(
            tr.monitoring_table_column_completed_intervention_tasks,
            '${monitorItem.completedInterventions}/${monitorItem.totalInterventionTasks}',
          ),
          _buildInfoRow(
            tr.monitoring_table_column_completed_surveys,
            '${monitorItem.completedSurveys}/${monitorItem.totalSurveyTasks}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
