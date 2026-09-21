import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/report/report_section_widget.dart';
import 'package:studyu_app/screens/study/report/util/plot_utilities.dart';
import 'package:studyu_app/util/data_processing.dart';
import 'package:studyu_core/core.dart';

class const AverageSectionWidget(
  super.subject,
  final AverageSection section, {
  super.key,
}) extends ReportSectionWidget {
  @override
  Widget build(BuildContext context) {
    return _AverageSectionStatefulWidget(subject, section);
  }
}

class const _AverageSectionStatefulWidget(
  final StudySubject subject,
  final AverageSection section,
) extends StatefulWidget {
  @override
  _AverageSectionWidgetState createState() => _AverageSectionWidgetState();
}

class _AverageSectionWidgetState()
    extends State<_AverageSectionStatefulWidget> {
  bool showColorlessGauges = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<TemporalAggregation>(
          value: widget.section.aggregate,
          items: [
            DropdownMenuItem(
              value: TemporalAggregation.intervention,
              child: Text(AppLocalizations.of(context)!.intervention),
            ),
            DropdownMenuItem(
              value: TemporalAggregation.phase,
              child: Text(AppLocalizations.of(context)!.phase),
            ),
            DropdownMenuItem(
              value: TemporalAggregation.day,
              child: Text(AppLocalizations.of(context)!.day),
            ),
          ],
          onChanged: (value) {
            setState(() {
              widget.section.aggregate = value;
            });
          },
        ),
        const SizedBox(height: 8),
        getLegend(context, aggregateDataBy(widget.section.aggregate).toList()),
        AspectRatio(
          aspectRatio: 1.5,
          child: getDiagram(
            context,
            aggregateDataBy(widget.section.aggregate).toList(),
          ),
        ),
        // ExpansionTile(
        //   title: const Text(
        //     'Descriptive Statistics',
        //     style: TextStyle(
        //       fontSize: 14,
        //       color: Colors.black,
        //       decoration: TextDecoration.underline,
        //     ),
        //   ),
        //   children: [
        //     DescriptiveStatisticsWidget(
        //       valuesInterventionA,
        //       valuesInterventionB,
        //       nameInterventionA,
        //       nameInterventionB,
        //       widget.subject,
        //       widget.section,
        //     ),
        //   ],
        // ),
      ],
    );
  }

  List<int> get titlePos {
    final numberOfPhases = widget.subject.interventionOrder.length;
    final phaseDuration = widget.subject.study.schedule.phaseDuration;
    return Iterable<int>.generate(numberOfPhases)
        .map(
          (i) => (((i + 1) * phaseDuration - ((phaseDuration / 2) - 1)) - 1)
              .floor(),
        )
        .toList();
  }

  List<int> get phasePos {
    final numberOfPhases = widget.subject.interventionOrder.length;
    final phaseDuration = widget.subject.study.schedule.phaseDuration;
    return Iterable<int>.generate(numberOfPhases)
        .map((i) => (i + 1) * phaseDuration)
        .toList();
  }

  Widget getLegend(BuildContext context, List<DiagramDatum> data) {
    final interventionNames = getInterventionNames(context);
    final legends = {
      for (final entry in data)
        interventionNames[entry.intervention]!: Legend(
          interventionNames[entry.intervention]!,
          getColor(entry),
        ),
    };
    return LegendsListWidget(legends: legends.values.toList());
  }

  Widget getDiagram(BuildContext context, List<DiagramDatum> data) {
    if (data.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.no_data_available_yet),
      );
    }
    if (widget.section.aggregate == TemporalAggregation.day) {
      return LineChart(getLineChartData(context, data));
    }
    return BarChart(getChartData(context, data));
  }

  BarChartData getChartData(BuildContext context, List<DiagramDatum> data) {
    final barGroups = getBarGroups(context, data);
    final maxY =
        ((data.sortedBy((entry) => entry.value).toList().lastOrNull?.value ??
                    0) *
                1.1)
            .ceilToDouble();

    return BarChartData(
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          axisNameWidget:
              (widget.section.aggregate != TemporalAggregation.intervention)
              ? Text(AppLocalizations.of(context)!.phase)
              : const Text(""),
          sideTitles: SideTitles(showTitles: true, getTitlesWidget: getTitles),
        ),
        topTitles: const AxisTitles(),
      ),
      gridData: getGridData(barGroups),
      alignment: BarChartAlignment.spaceAround,
      barGroups: barGroups,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              rod.toY.toString(),
              const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
      backgroundColor: getBackgroundColor(data),
      maxY: maxY,
    );
  }

  LineChartData getLineChartData(
    BuildContext context,
    List<DiagramDatum> data,
  ) {
    // Sort data by x value to ensure proper line plotting
    data.sort((a, b) => a.x.compareTo(b.x));

    final lineBarsData = <LineChartBarData>[];

    // Create segments of spots with background colors
    for (var i = 0; i < data.length - 1; i++) {
      final datum = data[i];
      final nextDatum = data[i + 1];

      final spots = [
        FlSpot(datum.x.toDouble(), datum.value.toDouble()),
        FlSpot(nextDatum.x.toDouble(), nextDatum.value.toDouble()),
      ];

      // Determine the background color based on the intervention
      Color backgroundColor;
      if (getColor(datum) == Colors.blue) {
        backgroundColor = Colors.blue.withValues(alpha: 0.6);
      } else if (getColor(datum) == Colors.orange) {
        backgroundColor = Colors.orange.withValues(alpha: 0.6);
      } else if (getColor(datum) == Colors.grey) {
        backgroundColor = Colors.grey.withValues(alpha: 0.6);
      } else {
        backgroundColor = Colors.transparent;
      }

      lineBarsData.add(
        LineChartBarData(
          spots: spots,
          belowBarData: BarAreaData(show: true, color: backgroundColor),
          aboveBarData: BarAreaData(
            show: true,
            color: backgroundColor, // Adjust as needed
          ),
          dotData: FlDotData(
            show: false,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.black,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          color: Colors.black, // Line color
        ),
      );
    }

    final minX = data
        .map((datum) => datum.x.toDouble())
        .reduce((a, b) => a < b ? a : b);
    final maxX = data
        .map((datum) => datum.x.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final maxY =
        (data
                    .map((datum) => datum.value.toDouble())
                    .reduce((a, b) => a > b ? a : b) *
                1.1)
            .ceilToDouble();

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          axisNameWidget: widget.section.aggregate == TemporalAggregation.day
              ? Text(AppLocalizations.of(context)!.day)
              : const SizedBox.shrink(),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text(AppLocalizations.of(context)!.value),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(axisNameWidget: SizedBox.shrink()),
        rightTitles: const AxisTitles(axisNameWidget: SizedBox.shrink()),
      ),
      borderData: FlBorderData(show: true, border: Border.all()),
      lineBarsData: lineBarsData,
      minX: minX,
      maxX: maxX,
      minY: 0,
      maxY: maxY,
    );
  }

  List<Color> getBackgroundColors(List<DiagramDatum> data) {
    final List<Color> colors = [];
    for (final datum in data) {
      if (getColor(datum) == Colors.blue) {
        colors.add(Colors.blue.withValues(alpha: 0.2));
      } else if (getColor(datum) == Colors.orange) {
        colors.add(Colors.orange.withValues(alpha: 0.2));
      }
    }
    return colors;
  }

  Color getBackgroundColor(List<DiagramDatum> data) {
    if (data.any((datum) => datum.intervention == 'intervention_a')) {
      return Colors.lightBlue.withValues(alpha: 0.3);
    } else if (data.any((datum) => datum.intervention == 'intervention_b')) {
      return Colors.orange.withValues(alpha: 0.3);
    }
    return Colors.transparent;
  }

  Widget getTitles(double value, TitleMeta meta) {
    return SideTitleWidget(meta: meta, child: getValues(value));
  }

  Widget getValues(double value) {
    switch (widget.section.aggregate) {
      case TemporalAggregation.day:
        final index = titlePos.indexOf(value.round());
        if (index != -1) {
          return Text("${index + 1}");
        } else {
          return const SizedBox.shrink();
        }
      case TemporalAggregation.phase:
        return Text("${value.toInt() + 1}");
      case TemporalAggregation.intervention:
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  List<BarChartGroupData> getBarGroups(
    BuildContext context,
    List<DiagramDatum> data,
  ) {
    if (data.isEmpty) return [BarChartGroupData(x: 0)];

    int barCount = 0;
    switch (widget.section.aggregate) {
      case TemporalAggregation.day:
        barCount = widget.subject.study.schedule.length;
      case TemporalAggregation.phase:
        barCount = widget.subject.interventionOrder.length;
      case TemporalAggregation.intervention:
        barCount =
            widget.subject.selectedInterventionIds.length +
            (widget.subject.study.schedule.includeBaseline ? 1 : 0);
      default:
    }

    // there is no good way of dynamically setting the width of bars so they
    // fill the chart :( the author of fl_charts themselves recommended using
    // media queries: https://github.com/imaNNeo/fl_chart/issues/370
    // so we take a wild guess and say the bars should fill about half of the
    // space the chart gets which seems to be fine
    final barWidth = MediaQuery.of(context).size.width / 2 / barCount;
    BarChartGroupData barGenerator(int index, {double y = 0, Color? color}) {
      final rod = BarChartRodData(
        toY: y,
        color: color,
        width: barWidth,
        borderRadius: const BorderRadius.all(Radius.circular(1)),
      );
      return BarChartGroupData(x: index, barsSpace: 0, barRods: [rod]);
    }

    final starter = List<BarChartGroupData>.generate(barCount, barGenerator);
    for (final entry in data) {
      starter[entry.x.round()] = barGenerator(
        entry.x.round(),
        y: entry.value.toDouble(),
        color: getColor(entry),
      );
    }
    return starter;
  }

  FlGridData getGridData(List<BarChartGroupData> barGroups) {
    if (widget.section.aggregate != TemporalAggregation.day) {
      return const FlGridData(
        drawHorizontalLine: false,
        drawVerticalLine: false,
      );
    }
    // the grid lines are always at positions in [0, 1] so this is a bit tricky
    // also note that this math is only correct with
    // BarChartAlignment.spaceAround, otherwise it would get even uglier

    // resolution
    final lineCount = barGroups.length * 2;
    bool drawLine(double val) {
      // draw when we are at the border between two phases
      return (val *
                  lineCount %
                  (2 * widget.subject.study.schedule.phaseDuration))
              .toInt() ==
          0;
    }

    return FlGridData(
      drawHorizontalLine: false,
      checkToShowVerticalLine: drawLine,
      verticalInterval: 1 / lineCount,
    );
  }

  MaterialColor getColor(DiagramDatum diagram) {
    const baselineColor = Colors.grey;
    final colors = [Colors.blue, Colors.orange];
    MaterialColor? c = Colors.teal;

    switch (widget.section.aggregate) {
      case TemporalAggregation.day:
        //c = colors[subject.interventionOrder.indexOf(diagram.intervention)];
        if (widget.subject.study.schedule.includeBaseline &&
            diagram.x < widget.subject.study.schedule.phaseDuration) {
          // if id == "_baseline"
          c = baselineColor;
        } else {
          c =
              colors[widget.subject.selectedInterventions
                  .map((e) => e.id)
                  .toList()
                  .indexOf(diagram.intervention)];
        }
      case TemporalAggregation.phase:
        if (widget.subject.study.schedule.includeBaseline && diagram.x == 0) {
          c = baselineColor;
        } else {
          c =
              colors[widget.subject.selectedInterventions
                  .map((e) => e.id)
                  .toList()
                  .indexOf(diagram.intervention)];
        }
      case TemporalAggregation.intervention:
        if (widget.subject.study.schedule.includeBaseline && diagram.x == 2) {
          c = baselineColor;
        } else if (diagram.x == 0) {
          c = Colors.blue;
        } else if (diagram.x == 1) {
          c = Colors.orange;
        }
      default:
    }
    return c;
  }

  /// Returns the day index adjusted for baseline inclusion.
  int getDayIndex(DateTime key) {
    final dayOfStudy = widget.subject.getDayOfStudyFor(key);
    if (widget.subject.study.schedule.includeBaseline) {
      return dayOfStudy;
    }
    final schedule = widget.subject.scheduleFor(widget.subject.startedAt!);
    // The offset is the index of the first task that is not the baseline.
    final offset = schedule.indexWhere((task) => task.id != Study.baselineID);
    return dayOfStudy - offset;
  }

  /// Groups data by intervention (excluding baseline data)
  /// and returns a mapping from intervention IDs to a list of values.
  Map<String, List<num>> getInterventionGroups(List<DiagramDatum> data) {
    final filteredData = data.where(
      (datum) => datum.intervention != '__baseline',
    );
    // Group data by intervention
    final interventionGroups = filteredData.fold<Map<String, List<num>>>({}, (
      map,
      datum,
    ) {
      map.putIfAbsent(datum.intervention, () => []).add(datum.value);
      return map;
    });

    return interventionGroups;
  }

  Iterable<DiagramDatum> aggregateDataBy(TemporalAggregation? aggregate) {
    final values = widget.section.resultProperty!.retrieveFromResults(
      widget.subject,
    );
    final data = values.entries.map(
      (e) => DiagramDatum(
        getDayIndex(e.key),
        e.value,
        e.key,
        widget.subject.getInterventionForDate(e.key)!.id,
      ),
    );
    if (aggregate == null) {
      return data;
    } else if (aggregate == TemporalAggregation.day) {
      return data
          .groupBy((e) => e.x)
          .aggregateWithKey(
            (data, day) => DiagramDatum(
              day,
              foldAggregateMean()(data.map((e) => e.value)),
              null,
              data.first.intervention,
            ),
          )
          .map((e) => e.value);
    } else if (aggregate == TemporalAggregation.phase) {
      return data
          .groupBy(
            (e) => widget.subject.getInterventionIndexForDate(e.timestamp!),
          )
          .aggregateWithKey(
            (data, phase) => DiagramDatum(
              phase,
              foldAggregateMean()(data.map((e) => e.value)),
              null,
              data.first.intervention,
            ),
          )
          .map((e) => e.value);
    } else {
      final order = getInterventionPositions(
        widget.subject.selectedInterventions,
      );
      return data
          .groupBy((e) => e.intervention)
          .aggregateWithKey(
            (data, intervention) => DiagramDatum(
              order[intervention]! as num,
              foldAggregateMean()(data.map((e) => e.value)),
              null,
              intervention,
            ),
          )
          .map((e) => e.value);
    }
  }

  Map<String, String?> getInterventionNames(BuildContext context) {
    final names = {
      for (final intervention in widget.subject.study.interventions)
        intervention.id: intervention.name,
    };
    final localizations = AppLocalizations.of(context);
    names[Study.baselineID] = localizations?.baseline ?? "baseline";
    return names;
  }

  String? getInterventionNameFromInterventionId(
    BuildContext context,
    String interventionId,
  ) {
    for (final intervention in widget.subject.study.interventions) {
      if (intervention.id == interventionId) {
        return intervention.name;
      }
    }
    return null;
  }
}

class DiagramDatum(
  final num x,
  final num value,
  final DateTime? timestamp,
  final String intervention,
);
