import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/progress_row.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/task_box.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_app/util/date_time_preferences.dart';
import 'package:studyu_app/widgets/intervention_card.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const TaskOverview({
  required final StudySubject? subject,
  required final List<TaskInstance>? scheduleToday,
  super.key,
  final String? interventionIcon,
  final GlobalKey? progressShowcaseKey,
  final GlobalKey? currentInterventionShowcaseKey,
  final GlobalKey? todayTasksShowcaseKey,
}) extends StatefulWidget {
  @override
  State<TaskOverview> createState() => _TaskOverviewState();
}

class _TaskOverviewState() extends State<TaskOverview> {
  void _navigateToReportIfStudyCompleted(BuildContext context) {
    if (widget.subject!.completedStudy) {
      // Workaround to reload dashboard
      context.go('/${RouteNames.dashboard}');
    }
  }

  List<Widget> buildScheduleToday(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = context.watch<DateTimePreferences?>()?.timeFormat;
    final List<Widget> list = [];
    for (final taskInstance in widget.scheduleToday!) {
      list
        ..add(
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              children: [
                Icon(Icons.access_time, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  formatCompletionPeriod(
                    context,
                    taskInstance.completionPeriod,
                    preference: timeFormat,
                  ),
                  style: theme.textTheme.titleSmall!.copyWith(
                    fontSize: 16,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        )
        ..add(
          TaskBox(
            taskInstance: taskInstance,
            onCompleted: () => _navigateToReportIfStudyCompleted(context),
            icon: Icon(
              taskInstance.task is Observation
                  ? MdiIcons.orderBoolAscendingVariant
                  : MdiIconsHelper.fromString(widget.interventionIcon!),
            ),
          ),
        );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 8),
        _buildShowcase(
          key: widget.progressShowcaseKey,
          title: l10n.dashboard_showcase_progress_title,
          description: l10n.dashboard_showcase_progress_description,
          child: ProgressRow(
            // Unlike the dashboard container, this marker exists only when
            // the loaded subject has actual persisted subject_progress.
            key: widget.subject!.progress.isNotEmpty
                ? const ValueKey('dashboard_persisted_progress')
                : null,
            subject: widget.subject,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildShowcase(
                key: widget.currentInterventionShowcaseKey,
                title: l10n.dashboard_showcase_current_intervention_title,
                description:
                    l10n.dashboard_showcase_current_intervention_description,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.intervention_current,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.subject!.daysLeftForPhase(widget.subject!.getInterventionIndexForDate(DateTime.now()))} ${AppLocalizations.of(context)!.days_left}',
                      style: const TextStyle(color: primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              InterventionCardTitle(
                intervention: widget.subject!.getInterventionForDate(
                  DateTime.now(),
                ),
              ),
              const SizedBox(height: 8),
              _buildShowcase(
                key: widget.todayTasksShowcaseKey,
                title: l10n.dashboard_showcase_today_tasks_title,
                description: l10n.dashboard_showcase_today_tasks_description,
                child: Text(
                  AppLocalizations.of(context)!.today_tasks,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
        // Todo: find good way to calculate duration of intervention and display it
        Expanded(child: ListView(children: [...buildScheduleToday(context)])),
      ],
    );
  }

  Widget _buildShowcase({
    required GlobalKey? key,
    required String title,
    required String description,
    required Widget child,
  }) {
    if (key == null) return child;
    final theme = Theme.of(context);
    return Showcase(
      key: key,
      title: title,
      description: description,
      tooltipBackgroundColor: theme.colorScheme.surface,
      textColor: theme.colorScheme.onSurface,
      child: child,
    );
  }
}
