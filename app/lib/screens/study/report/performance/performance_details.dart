import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/intervention_card.dart';
import 'package:studyu_core/core.dart';

class const PerformanceDetailsScreen(
  final StudySubject? reportSubject, {
  super.key,
}) extends StatelessWidget {
  static MaterialPageRoute routeFor({required StudySubject? subject}) =>
      MaterialPageRoute(
        builder: (_) => PerformanceDetailsScreen(subject),
        settings: const RouteSettings(name: 'performanceDetails'),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interventions = reportSubject!.selectedInterventions
        .where((intervention) => !intervention.isBaseline())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.performance),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    AppLocalizations.of(context)!.performance_overview,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!
                          .performance_overview_interventions,
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: interventions.length,
                  itemBuilder: (context, index) => InterventionPerformanceBar(
                    subject: reportSubject,
                    intervention: interventions[index],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!
                          .performance_overview_observations,
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: reportSubject!.study.observations.length,
                  itemBuilder: (context, index) => ObservationPerformanceBar(
                    subject: reportSubject,
                    observation: reportSubject!.study.observations[index],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class const InterventionPerformanceBar({
  required final Intervention intervention,
  required final StudySubject? subject,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InterventionCard(
              intervention,
              showTasks: false,
              showDescription: false,
            ),
            const SizedBox(height: 8),
            ...intervention.tasks.map(
              (task) => PerformanceBar(
                task: task,
                completed: subject!.completedTasksFor(task),
                total: subject!.totalTaskCountFor(task),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class const ObservationPerformanceBar({
  required final Observation observation,
  required final StudySubject? subject,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PerformanceBar(
          task: observation,
          completed: subject!.completedTasksFor(observation),
          total: subject!.totalTaskCountFor(observation),
        ),
      ),
    );
  }
}

class const PerformanceBar({
  required final Task task,
  required final int completed,
  required final int total,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(task.title ?? '')),
            Text('$completed/$total'),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            LinearProgressIndicator(minHeight: 20, value: completed / total),
            Center(
              child: Text(
                '${(completed / total * 100).toStringAsFixed(2).replaceAll('.00', '')} %',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
