import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/report/generic_section.dart';
import 'package:studyu_core/core.dart';

class const PerformanceSection(super.subject, {super.key, super.onTap})
    extends GenericSection {
  double get minimumRatio => 0.1;

  double get maximum => 100;

  @override
  Widget buildContent(BuildContext context) {
    final interventions = subject!.selectedInterventions
        .where((intervention) => intervention.id != Study.baselineID)
        .toList();
    final interventionProgress = interventions.map((intervention) {
      final countableInterventions = getCountableObservationAmount(
        intervention,
      );
      return min<double>(
        countableInterventions == 0 ? 0 : countableInterventions / maximum,
        1,
      );
    }).toList();
    return interventions.length != 2 ||
            subject!.study.reportSpecification.primary == null
        ? Center(child: Text(AppLocalizations.of(context)!.performance))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${AppLocalizations.of(context)!.current_power_level}: ${getPowerLevelDescription(context, interventionProgress)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: interventions.length * 2,
                itemBuilder: (context, index) {
                  final i = (index / 2).floor();
                  if (index.isEven) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(interventions[i].name!),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PerformanceBar(
                        progress: interventionProgress[i],
                        minimum: minimumRatio,
                      ),
                    );
                  }
                },
              ),
            ],
          );
  }

  String getPowerLevelDescription(
    BuildContext context,
    List<num> interventionProgress,
  ) {
    if (interventionProgress.any((progress) => progress < minimumRatio)) {
      return AppLocalizations.of(context)!.not_enough_data;
    } else if (interventionProgress.any((progress) => progress < 1)) {
      return AppLocalizations.of(context)!.barely_enough_data;
    } else {
      return AppLocalizations.of(context)!.enough_data;
    }
  }

  int getCountableObservationAmount(Intervention intervention) {
    var interventionsPerDay = 0;
    for (final interventionTask in intervention.tasks) {
      interventionsPerDay += interventionTask.schedule.completionPeriods.length;
    }

    var countable = 0;
    subject!.getResultsByDate(interventionId: intervention.id).values.forEach((
      progress,
    ) {
      if (progress
              .where(
                (result) => intervention.tasks.any(
                  (interventionTask) => interventionTask.id == result.taskId,
                ),
              )
              .length ==
          interventionsPerDay) {
        countable += progress
            .where(
              (result) => subject!.study.observations.any(
                (observation) => observation.id == result.taskId,
              ),
            )
            .length;
      }
    });
    return countable;
    /*final primaryOutcome = subject.reportSpecification.outcomes[0];
    final results = <List<num>>[];
    subject.getResultsByInterventionId(taskId: primaryOutcome.taskId).forEach((key, value) {
      final data = value
          .whereType<Result<QuestionnaireState>>()
          .map((result) => result.result.answers[primaryOutcome.questionId].response)
          .whereType<num>()
          .toList();
      if (data.isNotEmpty && key != Study.baselineID) results.add(data);
    });

    if (results.length != 2 || results[0].isEmpty || results[1].isEmpty) {
      print('The given values are incorrect!');
      return 0;
    }

    final mean0 = Stats.fromData(results[0]).average;
    final mean1 = Stats.fromData(results[1]).average;
    final sD = Stats.fromData([...results[0], ...results[1]]).standardDeviation;

    // TODO might be cdf
    return Normal.cdf(-1.96 + ((mean0 - mean1) / sqrt(pow(sD, 2) / (results[0].length + results[1].length)))) +
        Normal.cdf(-1.96 - ((mean0 - mean1) / sqrt(pow(sD, 2) / (results[0].length + results[1].length))));*/
  }
}

class const PerformanceBar({
  required final double progress,
  final double? minimum,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rainbow = Rainbow(
      spectrum: [Colors.red, Colors.yellow, Colors.green],
      rangeStart: 0,
      rangeEnd: 1,
    );
    final fullSpectrum = List<double>.generate(
      3,
      (index) => index * 0.5,
    ).map<Color>((index) => rainbow[index].withValues(alpha: 0.4)).toList();
    final colorSamples = List<double>.generate(
      11,
      (index) => index * 0.1 * progress,
    ).map<Color>((index) => rainbow[index]).toList();

    //final spacing = (minimum! * 1000).floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: fullSpectrum),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: colorSamples),
                          ),
                        ),
                      ),
                    ),
                    Container(width: 2, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),
        ),

        /// Removing the minimum indicator since it is discussed as confusing in the meeting
        /*if (minimum != null && minimum! >= 0 && minimum! <= 1)
          Column(
            children: [
              Row(
                children: [
                  if (spacing > 0)
                    Spacer(
                      flex: spacing,
                    ),
                  Container(
                    width: 2,
                    height: 15,
                    color: Colors.grey[600],
                  ),
                  if (spacing < 1000)
                    Spacer(
                      flex: 1000 - spacing,
                    ),
                ],
              ),
              Row(
                children: [
                  if (spacing > 0)
                    Spacer(
                      flex: spacing,
                    ),
                  const Text('min'),
                  if (spacing < 1000)
                    Spacer(
                      flex: 1000 - spacing,
                    ),
                ],
              ),
            ],
          ),*/
      ],
    );
  }
}
