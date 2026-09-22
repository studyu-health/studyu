import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/report/report_section_widget.dart';
import 'package:studyu_core/core.dart';

class const LinearRegressionSectionWidget(
  super.subject,
  final LinearRegressionSection section, {
  super.key,
}) extends ReportSectionWidget {
  @override
  Widget build(BuildContext context) {
    return const Text("LinearRegression is currently not supported");
  }
}

/*import 'package:charts_common/common.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

import '../report_section_widget.dart';
import '../util/linear_regression.dart';
import '../util/plot_utilities.dart';

class LinearRegressionSectionWidget extends ReportSectionWidget {
  final LinearRegressionSection section;

  const LinearRegressionSectionWidget(StudySubject subject, this.section, {Key key}) : super(subject, key: key);

  @override
  Widget build(BuildContext context) {
    final interventionOrder = getInterventionPositions(subject.selectedInterventions);
    final values = section.resultProperty.retrieveFromResults(subject);
    final samples = values.entries.map((e) {
      final intervention = subject.getInterventionForDate(e.key).id;
      return MapEntry(
        [
          subject.getDayOfStudyFor(e.key), //time
          if (interventionOrder[intervention] == 1) 1 else 0, //A
          if (interventionOrder[intervention] == 2) 1 else 0, //B
        ],
        e.value,
      );
    });

    final regression = LinearRegression(samples);
    final coefficients = regression.getEstimatedCoefficients();
    final pValues = regression.getPValues();
    final confidenceIntervals = regression.getConfidenceIntervals(section.alpha);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(aspectRatio: 1.5, child: _buildDiagram(context, coefficients, confidenceIntervals)),
        _buildResultDescription(context, coefficients, pValues),
      ],
    );
  }

  charts.NumericExtents getExtents(int numberOfPhases, int phaseDuration) =>
      charts.NumericExtents(subject.study.schedule.includeBaseline ? 0 : 1, 2);

  Widget _buildDiagram(
    BuildContext context,
    LinearRegressionResult<num> coefficients,
    LinearRegressionResult<Range<num>> confidenceIntervals,
  ) {
    final numberOfPhases = subject.interventionOrder.length;
    final phaseDuration = subject.study.schedule.phaseDuration;
    return charts.NumericComboChart(
      _getChartData(coefficients, confidenceIntervals),
      animate: true,
      behaviors: [
        charts.SeriesLegend(desiredMaxColumns: 2),
        charts.RangeAnnotation(
          [createPlotSeparator(coefficients.intercept, axis: charts.RangeAnnotationAxisType.measure)],
        ),
      ],
      domainAxis: charts.NumericAxisSpec(
        viewport: getExtents(numberOfPhases, phaseDuration),
        tickProviderSpec: const charts.StaticNumericTickProviderSpec([]),
      ),
      defaultRenderer: charts.BarRendererConfig<num>(
        groupingType: charts.BarGroupingType.stacked,
        barRendererDecorator: BarErrorDecorator<num>(),
      ),
    );
  }

  List<charts.Series<_ResultDatum, num>> _getChartData(
    LinearRegressionResult<num> coefficients,
    LinearRegressionResult<Range<num>> confidenceIntervals,
  ) {
    final colorPalette = getInterventionPalette(subject.selectedInterventions);
    final interventionNames = getInterventionNames(subject.selectedInterventions);
    final interventionOrder = getInterventionPositions(subject.selectedInterventions);

    final intercept = coefficients.intercept;
    final factorA = coefficients.variables[1];
    final factorB = coefficients.variables[2];
    final interventionA = getInterventionA(subject.selectedInterventions);
    final interventionB = getInterventionB(subject.selectedInterventions);

    final ciIntercept = confidenceIntervals.intercept;
    final ciA = confidenceIntervals.variables[1];
    final ciB = confidenceIntervals.variables[2];

    return {
      if (subject.study.schedule.includeBaseline)
        Study.baselineID: _ResultDatum(interventionOrder[Study.baselineID], intercept, ciIntercept),
      interventionA: _ResultDatum(
        interventionOrder[interventionA],
        intercept + factorA,
        Range(intercept + ciA.min, intercept + ciA.max),
      ),
      interventionB: _ResultDatum(
        interventionOrder[interventionB],
        intercept + factorB,
        Range(intercept + ciB.min, intercept + ciB.max),
      ),
    }
        .entries
        .map(
          (entry) => charts.Series<_ResultDatum, num>(
            id: entry.key,
            displayName: interventionNames[entry.key],
            seriesColor: colorPalette[entry.key],
            domainFn: (datum, _) => datum.pos,
            measureFn: (datum, _) => datum.value,
            measureLowerBoundFn: (datum, _) => datum.confidenceInterval.min,
            measureUpperBoundFn: (datum, _) => datum.confidenceInterval.max,
            data: [entry.value],
          ),
        )
        .toList();
  }

  Widget _buildResultDescription(
    BuildContext context,
    LinearRegressionResult<num> coefficients,
    LinearRegressionResult<num> pValues,
  ) {
    final interventionNames = getInterventionNames(subject.selectedInterventions);

    var factorA = coefficients.variables[1];
    var factorB = coefficients.variables[2];
    if (section.improvement == ImprovementDirection.negative) {
      factorA = -factorA;
      factorB = -factorB;
    }

    final interventionA = getInterventionA(subject.selectedInterventions);
    final interventionB = getInterventionB(subject.selectedInterventions);

    final pIntercept = pValues.intercept;
    final pA = pValues.variables[1];
    final pB = pValues.variables[2];

    String text;
    //TODO: Talk to a statistics guy about this evaluation logic and model design
    if (pA > section.alpha || pB > section.alpha || pIntercept > section.alpha) {
      text = AppLocalizations.of(context).report_outcome_inconclusive;
    } else if (subject.study.schedule.includeBaseline && factorA < 0 && factorB < 0) {
      text = AppLocalizations.of(context).report_outcome_neither;
    } else if (factorA > factorB) {
      //TODO: This if else might be problematic if a baseline is present and A and B are an improvement over it
      text = (AppLocalizations.of(context).report_outcome_one as String)
          .replaceAll('{intervention}', interventionNames[interventionA]);
    } else {
      text = (AppLocalizations.of(context).report_outcome_one as String)
          .replaceAll('{intervention}', interventionNames[interventionB]);
    }

    return Text(text);
  }
}

class _ResultDatum {
  final num pos;
  final num value;
  final Range<num> confidenceInterval;

  _ResultDatum(this.pos, this.value, this.confidenceInterval);
}*/
