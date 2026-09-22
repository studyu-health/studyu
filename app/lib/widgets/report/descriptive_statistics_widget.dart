import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:statistics/statistics.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

class DescriptiveStats({
  required final String name,
  required final int total,
  required List<num> values,
}) {
  final int observations = values.length;
  final int missing = total - values.length;
  final double? average = values.isNotEmpty ? values.mean : null;
  final double? minimum = values.isNotEmpty ? values.min as double : null;
  final double? maximum = values.isNotEmpty ? values.max as double : null;

  String formatted(double? value) =>
      value != null ? value.toStringAsFixed(2) : 'No data';
  String get avgString => formatted(average);
  String get minString => formatted(minimum);
  String get maxString => formatted(maximum);
  String get completeness => total > 0
      ? '${((observations / total) * 100).toStringAsFixed(0)}%'
      : 'Null';
}

// ignore: prefer_const_constructors_in_immutables
class DescriptiveStatisticsWidget({
  super.key,
  required List<num> valuesInterventionA,
  required String nameInterventionA,
  required List<num> valuesInterventionB,
  required String nameInterventionB,
  required StudySubject subject,
  final bool initiallyExpanded = false,
}) extends StatelessWidget {
  final DescriptiveStats statsA = DescriptiveStats(
    name: nameInterventionA,
    total:
        subject.study.schedule.phaseDuration *
        subject.study.schedule.numberOfCycles,
    values: valuesInterventionA,
  );
  final DescriptiveStats statsB = DescriptiveStats(
    name: nameInterventionB,
    total:
        subject.study.schedule.phaseDuration *
        subject.study.schedule.numberOfCycles,
    values: valuesInterventionB,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          'Descriptive Statistics',
          style: theme.textTheme.titleLarge,
        ),
        subtitle: Text(
          AppLocalizations.of(context)!
              .compare_results_between(statsA.name, statsB.name),
          style: theme.textTheme.bodyMedium,
        ),
        initiallyExpanded: initiallyExpanded,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummary(context),
                const SizedBox(height: 16),
                _buildStatsTable(context),
                if (statsA.missing > 0 || statsB.missing > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      AppLocalizations.of(context)!.missing_observations_note,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.quick_summary,
            style: headingStyle,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  AppLocalizations.of(context)!.average_score,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Expanded(child: _valueLabel(statsA.avgString, statsA.name)),
              Expanded(child: _valueLabel(statsB.avgString, statsB.name)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  AppLocalizations.of(context)!.data_completeness,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Expanded(child: _valueLabel(statsA.completeness, statsA.name)),
              Expanded(child: _valueLabel(statsB.completeness, statsB.name)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valueLabel(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, softWrap: true, maxLines: 2, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildStatsTable(BuildContext context) {
    // Use a flexible Table to allow wrapping long intervention names
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        _buildTableRow(
          [AppLocalizations.of(context)!.statistic, statsA.name, statsB.name],
          isHeader: true,
          context: context,
        ),
        _buildTableRow([
          AppLocalizations.of(context)!.total_recordings,
          '${statsA.observations}',
          '${statsB.observations}',
        ], context: context),
        _buildTableRow(
          [
            AppLocalizations.of(context)!.missing_recordings,
            '${statsA.missing}',
            '${statsB.missing}',
          ],
          context: context,
          highlight: statsA.missing > 0 || statsB.missing > 0,
        ),
        _buildTableRow([
          AppLocalizations.of(context)!.average,
          statsA.avgString,
          statsB.avgString,
        ], context: context),
        _buildTableRow([
          AppLocalizations.of(context)!.minimum,
          statsA.minString,
          statsB.minString,
        ], context: context),
        _buildTableRow([
          AppLocalizations.of(context)!.maximum,
          statsA.maxString,
          statsB.maxString,
        ], context: context),
      ],
    );
  }

  TableRow _buildTableRow(
    List<String> cells, {
    bool isHeader = false,
    required BuildContext context,
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader
            ? Colors.grey.shade200
            : highlight
            ? Colors.amber.withValues(alpha: 0.1)
            : null,
      ),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            cell,
            softWrap: true,
            textAlign: TextAlign.center,
            style: isHeader
                ? theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : theme.textTheme.bodyMedium,
          ),
        );
      }).toList(),
    );
  }
}
