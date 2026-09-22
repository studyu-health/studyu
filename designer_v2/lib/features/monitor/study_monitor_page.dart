import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/features/monitor/participant/participant_details_view.dart';
import 'package:studyu_designer_v2/features/monitor/study_monitor_table.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const StudyMonitorScreen(super.studyId, {super.key})
    extends StudyPageWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));
    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final studyMonitorData = study.monitorData;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (studyMonitorData.isNotEmpty) ...[
              _monitorSectionHeader(context, studyMonitorData),
              const SizedBox(height: 32.0),
              SelectableText(
                tr.monitoring_participants_title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Container(width: 32.0),
              StudyMonitorTable(
                ref: ref,
                studyMonitorItems: studyMonitorData,
                onSelectItem: (item) =>
                    _onSelectParticipant(context, ref, item, study),
              ),
            ] else
              EmptyBody(
                icon: Icons.person_off_rounded,
                title: tr.monitoring_no_participants_title,
                description: tr.monitoring_no_participants_description,
              ),
          ],
        );
      },
    );
  }

  Widget _monitorSectionHeader(
    BuildContext context,
    List<StudyMonitorItem> monitorData,
  ) {
    final theme = Theme.of(context);
    final int total = monitorData.length;
    const double minPercentage = 0; // Minimum percentage for visibility, change to 0.01 if min visibility is required.

    double activePercentage = monitorData.activeParticipants.length / total;
    double inactivePercentage = monitorData.inactiveParticipants.length / total;
    double dropoutPercentage = monitorData.dropoutParticipants.length / total;
    double completedPercentage =
        monitorData.completedParticipants.length / total;

    // Adjust for minimum percentage visibility
    if (monitorData.activeParticipants.isEmpty) {
      activePercentage = minPercentage;
    }
    if (monitorData.inactiveParticipants.isEmpty) {
      inactivePercentage = minPercentage;
    }
    if (monitorData.dropoutParticipants.isEmpty) {
      dropoutPercentage = minPercentage;
    }
    if (monitorData.completedParticipants.isEmpty) {
      completedPercentage = minPercentage;
    }

    // Normalize the percentages so they add up to 1.0
    final double sumOfPercentages =
        activePercentage +
        inactivePercentage +
        dropoutPercentage +
        completedPercentage;

    activePercentage /= sumOfPercentages;
    inactivePercentage /= sumOfPercentages;
    dropoutPercentage /= sumOfPercentages;
    completedPercentage /= sumOfPercentages;

    final Color activeColor = theme.primaryColor;
    const Color inactiveColor = Color(0xFFD55E00);
    const Color dropoutColor = Color(0xFF0072B2);
    const Color completedColor = Color(0xFF009E73);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        SizedBox(
          width: 450,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${tr.monitoring_total}: $total', textAlign: TextAlign.end),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStat(
                    percentage: activePercentage,
                    color: activeColor,
                    tooltip:
                        '${tr.monitoring_active}: ${monitorData.activeParticipants.map((e) => e.participantId).length}',
                  ),
                  _buildStat(
                    percentage: inactivePercentage,
                    color: inactiveColor,
                    tooltip:
                        '${tr.monitoring_inactive}: ${monitorData.inactiveParticipants.map((e) => e.participantId).length}',
                  ),
                  _buildStat(
                    percentage: dropoutPercentage,
                    color: dropoutColor,
                    tooltip:
                        '${tr.monitoring_dropout}: ${monitorData.dropoutParticipants.map((e) => e.participantId).length}',
                  ),
                  _buildStat(
                    percentage: completedPercentage,
                    color: completedColor,
                    tooltip:
                        '${tr.monitoring_completed}: ${monitorData.completedParticipants.map((e) => e.participantId).length}',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLegend(
                    color: activeColor,
                    text:
                        '${tr.monitoring_active}: ${monitorData.activeParticipants.length}',
                    tooltip: tr.monitoring_active_tooltip,
                  ),
                  const SizedBox(width: 10),
                  _buildLegend(
                    color: inactiveColor,
                    text:
                        '${tr.monitoring_inactive}: ${monitorData.inactiveParticipants.length}',
                    tooltip: tr.monitoring_inactive_tooltip,
                  ),
                  const SizedBox(width: 10),
                  _buildLegend(
                    color: dropoutColor,
                    text:
                        '${tr.monitoring_dropout}: ${monitorData.dropoutParticipants.length}',
                    tooltip: tr.monitoring_dropout_tooltip,
                  ),
                  const SizedBox(width: 10),
                  _buildLegend(
                    color: completedColor,
                    text:
                        '${tr.monitoring_completed}: ${monitorData.completedParticipants.length}',
                    tooltip: tr.monitoring_completed_tooltip,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStat({
    required double percentage,
    required Color color,
    required String tooltip,
  }) {
    return Expanded(
      flex: (percentage * 1000).toInt(),
      child: Tooltip(
        message: tooltip,
        child: Container(height: 20, color: color),
      ),
    );
  }

  Widget _buildLegend({
    required Color color,
    required String text,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Row(
        children: [
          Container(width: 15, height: 15, color: color),
          const SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }

  void _onSelectParticipant(
    BuildContext context,
    WidgetRef ref,
    StudyMonitorItem item,
    Study study,
  ) {
    showModalSideSheet(
      context: context,
      title: tr.participant_details_title,
      width: 550,
      body: ParticipantDetailsView(monitorItem: item, study: study),
      actionButtons: [
        retainSizeInAppBar(
          DismissButton(
            text: tr.dialog_close,
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
      ],
    );
  }
}
