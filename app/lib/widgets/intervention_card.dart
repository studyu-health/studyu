import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/util/date_time_preferences.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const InterventionCard(
  final Intervention intervention, {
  final Function()? onTap,
  final bool selected = false,
  final bool showCheckbox = false,
  final bool showTasks = true,
  final bool showDescription = true,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InterventionCardTitle(
          intervention: intervention,
          showCheckbox: showCheckbox,
          showDescriptionButton: !showDescription,
          onTap: onTap,
          selected: selected,
        ),
        if (showDescription)
          InterventionCardDescription(intervention: intervention),
        if (showTasks && intervention.tasks.isNotEmpty)
          _TaskList(tasks: intervention.tasks),
      ],
    );
  }
}

class const InterventionCardTitle({
  required final Intervention? intervention,
  final bool selected = false,
  final bool showCheckbox = false,
  final bool showDescriptionButton = true,
  final Function()? onTap,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(
        MdiIconsHelper.fromString(intervention!.icon),
        color: theme.colorScheme.secondary,
      ),
      trailing: showCheckbox
          ? Checkbox(
              value: selected,
              onChanged: (_) =>
                  onTap!(), // Needed so Checkbox can be clicked and has color
            )
          : null,
      dense: true,
      title: Row(
        children: [
          Expanded(
            child: Text(intervention!.name!, style: theme.textTheme.titleLarge),
          ),
          if (showDescriptionButton)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  final description = intervention!.isBaseline()
                      ? AppLocalizations.of(context)!.baseline_description
                      : intervention!.description;
                  return AlertDialog(
                    title: ListTile(
                      leading: Icon(
                        MdiIconsHelper.fromString(intervention!.icon),
                        color: theme.colorScheme.secondary,
                      ),
                      dense: true,
                      title: Text(
                        intervention!.name!,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    content: HtmlText(description),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class const InterventionCardDescription({
  required final Intervention intervention,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final description = intervention.isBaseline()
        ? AppLocalizations.of(context)!.baseline_description
        : intervention.description;
    if (description == null) return Container();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(
        description,
        style: theme.textTheme.bodyMedium!.copyWith(
          color: theme.textTheme.bodySmall!.color,
        ),
      ),
    );
  }
}

class const _TaskList({required final List<InterventionTask> tasks})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = context.watch<DateTimePreferences?>()?.timeFormat;
    String scheduleString(List<CompletionPeriod> schedules) => schedules
        .map(
          (period) =>
              formatCompletionPeriod(context, period, preference: timeFormat),
        )
        .join(',');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.tasks_daily,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const Divider(height: 4),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: tasks
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: theme.textTheme.bodySmall!.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            scheduleString(task.schedule.completionPeriods),
                            style: theme.textTheme.bodyMedium!.copyWith(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall!.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
