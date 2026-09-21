import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class const StudyMonitorTable({
  required final WidgetRef ref,
  required final List<StudyMonitorItem> studyMonitorItems,
  required final OnSelectHandler<StudyMonitorItem> onSelectItem,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StandardTable<StudyMonitorItem>(
      items: studyMonitorItems,
      sortColumnPredicates: [
        (a, b) => a.participantId.compareTo(b.participantId),
        (a, b) =>
            a.inviteCode != null ? a.inviteCode!.compareTo(b.inviteCode!) : 0,
        (a, b) => b.startedAt.compareTo(a.startedAt),
        (a, b) => b.lastActivityAt.compareTo(a.lastActivityAt),
        (a, b) => a.currentDayOfStudy.compareTo(b.currentDayOfStudy),
        (a, b) => a.completedInterventions.compareTo(b.completedInterventions),
        (a, b) => a.completedSurveys.compareTo(b.completedSurveys),
      ],
      columns: [
        StandardTableColumn(
          sortable: true,
          label: tr.monitoring_table_column_participant_id,
          columnWidth: const MaxColumnWidth(
            FixedColumnWidth(150),
            FlexColumnWidth(1.6),
          ),
        ),
        StandardTableColumn(
          sortable: true,
          label: tr.monitoring_table_column_invite_code,
          columnWidth: const MaxColumnWidth(
            FixedColumnWidth(200),
            FlexColumnWidth(1.6),
          ),
        ),
        StandardTableColumn(
          sortable: true,
          label: tr.monitoring_table_column_enrolled,
          columnWidth: const MaxColumnWidth(
            FixedColumnWidth(150),
            FlexColumnWidth(1.6),
          ),
        ),
        StandardTableColumn(
          sortable: true,
          label: tr.monitoring_table_column_last_activity,
          columnWidth: const MaxColumnWidth(
            FixedColumnWidth(150),
            FlexColumnWidth(1.6),
          ),
        ),
        StandardTableColumn(
          sortable: true,
          label: tr.monitoring_table_column_day_in_study,
          tooltip: tr.monitoring_table_days_in_study_header_tooltip,
          columnWidth: const MaxColumnWidth(
            FixedColumnWidth(125),
            FlexColumnWidth(1.6),
          ),
        ),
        StandardTableColumn(
          sortable: true,
          label: tr.monitoring_table_column_completed_intervention_tasks,
          tooltip: tr.monitoring_table_completed_interventions_header_tooltip,
          columnWidth: const MaxColumnWidth(
            FixedColumnWidth(125),
            FlexColumnWidth(1.6),
          ),
        ),
        StandardTableColumn(
          sortable: true,
          label: tr.monitoring_table_column_completed_surveys,
          tooltip: tr.monitoring_table_completed_surveys_header_tooltip,
          columnWidth: const MaxColumnWidth(
            FixedColumnWidth(125),
            FlexColumnWidth(1.7),
          ),
        ),
      ],
      buildCellsAt: _buildRow,
      rowSpacing: 5.0,
      minRowHeight: 30.0,
      headerMaxLines: 3,
      softWrapHeader: true,
      onSelectItem: onSelectItem,
    );
  }

  List<Widget> _buildRow(
    BuildContext context,
    StudyMonitorItem item,
    int rowIdx,
    Set<WidgetState> states,
  ) {
    final locale = ref.watch(localeProvider).toLanguageTag();
    final preferences = ref.watch(userStateProvider).value?.preferences;
    final theme = Theme.of(context);
    return [
      Tooltip(
        message: item.participantId,
        child: Text(item.participantId.split("-").first),
      ),
      if (item.inviteCode != null)
        Text(item.inviteCode!)
      else
        TextParagraph(
          text: item.inviteCode ?? 'N/A',
          style: ThemeConfig.bodyTextMuted(theme),
        ),
      Tooltip(
        message: item.startedAt.toLocalizedString(
          locale: locale,
          showTime: false,
          datePreference: preferences?.dateFormat,
        ),
        child: Text(item.startedAt.toTimeAgoString()),
      ),
      Tooltip(
        message: item.lastActivityAt.toLocalizedString(
          locale: locale,
          datePreference: preferences?.dateFormat,
          timePreference: preferences?.timeFormat,
        ),
        child: Row(
          children: [
            Flexible(child: Text(item.lastActivityAt.toTimeAgoString())),
            if (item.droppedOut)
              Row(
                children: [
                  const SizedBox(width: 5.0),
                  Tooltip(
                    message: tr.monitoring_table_row_tooltip_dropout,
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 16.0,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      _buildProgressCell(
        context,
        item.currentDayOfStudy,
        item.studyDurationInDays,
      ),
      _buildProgressCell(
        context,
        item.completedInterventions,
        item.totalInterventionTasks,
      ),
      _buildProgressCell(context, item.completedSurveys, item.totalSurveyTasks),
    ];
  }

  Widget _buildProgressCell(BuildContext context, int progress, int total) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        SizedBox.expand(
          child: LinearProgressIndicator(
            value: total <= 0 ? 0 : progress / total,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.7),
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
        Align(
          child: Text(
            "$progress/$total",
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
