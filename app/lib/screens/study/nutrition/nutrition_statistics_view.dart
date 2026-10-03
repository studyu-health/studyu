import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_core/core.dart';

class const NutritionStatisticsView({
  final StudySubject? subject,
  final String? taskId,
  final DailyRecall? activeRecall,
  final int? activeStudyDay,
  final String? activePeriodId,
  final Future<void> Function(NutritionRecallRecord record)? onOpenRecall,
  super.key,
}) extends StatefulWidget {
  @override
  State<NutritionStatisticsView> createState() =>
      _NutritionStatisticsViewState();
}

enum _StatisticsPeriod(final int days) {
  recent7(7),
  recent30(30),
}

enum _Nutrient() {
  carbs,
  protein,
  fat,
  fiber,
}

class _NutritionStatisticsViewState() extends State<NutritionStatisticsView> {
  late Future<List<NutritionRecallRecord>> _records;
  _StatisticsPeriod _selectedPeriod = _StatisticsPeriod.recent7;
  _Nutrient _selectedNutrient = _Nutrient.carbs;
  int? _focusedEnergyDay;

  @override
  void initState() {
    super.initState();
    _records = _loadRecords();
  }

  @override
  void didUpdateWidget(covariant NutritionStatisticsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subject != widget.subject ||
        oldWidget.taskId != widget.taskId) {
      _records = _loadRecords();
    }
  }

  Future<List<NutritionRecallRecord>> _loadRecords() {
    final subject = widget.subject;
    final taskId = widget.taskId;
    if (subject == null || taskId == null) return Future.value([]);
    return loadNutritionRecallRecords(subject: subject, taskId: taskId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<NutritionRecallRecord>>(
      future: _records,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final now = DateTime.now();
        final statisticsDays = nutritionStatisticsDays(
          snapshot.data!,
          activeRecall: widget.activeRecall,
          activeStudyDay: widget.activeStudyDay,
          activePeriodId: widget.activePeriodId,
          today: now,
        );
        final current = nutritionStatisticsPeriod(
          statisticsDays,
          endDate: now,
          dayCount: _selectedPeriod.days,
          today: now,
        );
        final previous = nutritionStatisticsPeriod(
          statisticsDays,
          endDate: addCalendarDays(
            DateUtils.dateOnly(now),
            -_selectedPeriod.days,
          ),
          dayCount: _selectedPeriod.days,
          today: now,
        );
        final hasData = current.days.any((day) => day.hasChartData);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<_StatisticsPeriod>(
              segments: [
                ButtonSegment(
                  value: _StatisticsPeriod.recent7,
                  label: Text(l10n.nutrition_recent_7_days),
                ),
                ButtonSegment(
                  value: _StatisticsPeriod.recent30,
                  label: Text(l10n.nutrition_recent_30_days),
                ),
              ],
              selected: {_selectedPeriod},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _selectedPeriod = selection.single),
            ),
            const SizedBox(height: 12),
            Text(
              '${_periodLabel(context, current.startDate, current.endDate)} · '
              '${l10n.nutrition_completed_days(current.recordedCount)}'
              '${current.hasTodaySoFar ? ' · ${l10n.nutrition_today_so_far}' : ''}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (!hasData)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text(l10n.nutrition_statistics_empty)),
              )
            else ...[
              _overviewCard(context, current),
              const SizedBox(height: 12),
              _energyCard(context, current),
              const SizedBox(height: 12),
              _nutrientCard(context, current),
              const SizedBox(height: 12),
              _comparisonCard(context, current, previous),
            ],
          ],
        );
      },
    );
  }

  Widget _overviewCard(
    BuildContext context,
    NutritionStatisticsPeriod current,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final unavailable = current.unavailableNutrients;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.nutrition_daily_average,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            NutritionSummaryView(
              energyKcal: current.average((nutrition) => nutrition.energyKcal),
              energyUnavailable: current.hasUnavailableEnergy,
              carbs: unavailable.contains('carbs')
                  ? null
                  : current.average((nutrition) => nutrition.carbs),
              protein: unavailable.contains('protein')
                  ? null
                  : current.average((nutrition) => nutrition.protein),
              fat: unavailable.contains('fat')
                  ? null
                  : current.average((nutrition) => nutrition.fat),
              unavailableNutrients: unavailable,
              formatEnergy: (value) => _calories(context, value),
              formatGrams: (value) => _grams(context, value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _energyCard(BuildContext context, NutritionStatisticsPeriod current) {
    final l10n = AppLocalizations.of(context)!;
    final average = current.hasUnavailableEnergy
        ? null
        : current.average((nutrition) => nutrition.energyKcal);
    final values = [
      for (final day in current.days)
        if (day.hasChartData && !_energyUnavailable(day.data!.nutrition))
          day.data!.nutrition.energyKcal,
    ];
    final maxY = _chartMax(values);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.nutrition_energy_by_study_day,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Tooltip(
                  message: l10n.nutrition_statistics_help_message,
                  triggerMode: TooltipTriggerMode.tap,
                  child: const Icon(Icons.info_outline, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.nutrition_average_value(_calories(context, average))),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: _energyChart(context, current, average, maxY),
            ),
            const SizedBox(height: 8),
            Text(l10n.nutrition_tap_bar_hint, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _energyChart(
    BuildContext context,
    NutritionStatisticsPeriod current,
    double? average,
    double maxY,
  ) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                ),
                titlesData: _titlesData(
                  context,
                  current,
                  maxY: maxY,
                  unit: 'kcal',
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: average == null
                      ? []
                      : [
                          HorizontalLine(
                            y: average,
                            color: theme.colorScheme.outline,
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ],
                ),
                barGroups: [
                  for (var index = 0; index < current.days.length; index++)
                    BarChartGroupData(
                      x: index,
                      barRods:
                          current.days[index].hasChartData &&
                              !_energyUnavailable(
                                current.days[index].data!.nutrition,
                              )
                          ? [
                              BarChartRodData(
                                toY: current
                                    .days[index]
                                    .data!
                                    .nutrition
                                    .energyKcal,
                                width: current.days.length == 7 ? 18 : 6,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                                color: current.days[index].isToday
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.65,
                                      )
                                    : theme.colorScheme.primary,
                              ),
                            ]
                          : [],
                    ),
                ],
                barTouchData: BarTouchData(
                  touchExtraThreshold: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent || response?.spot == null) {
                      return;
                    }
                    final day =
                        current.days[response!.spot!.touchedBarGroupIndex];
                    if (!day.isToday && day.data?.record != null) {
                      unawaited(_openDay(day));
                    }
                  },
                  touchTooltipData: BarTouchTooltipData(
                    fitInsideHorizontally: true,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = current.days[group.x];
                      final nutrition = day.data?.nutrition;
                      if (nutrition == null || _energyUnavailable(nutrition)) {
                        return null;
                      }
                      return BarTooltipItem(
                        '${_tooltipDate(context, day)} · '
                        '${_calories(context, nutrition.energyKcal)}',
                        TextStyle(color: theme.colorScheme.onInverseSurface),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          bottom: 28,
          child: Row(
            children: [
              for (var index = 0; index < current.days.length; index++)
                Expanded(
                  child: _accessibleEnergyDay(
                    context,
                    current.days[index],
                    index,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accessibleEnergyDay(
    BuildContext context,
    NutritionStatisticsPeriodDay day,
    int index,
  ) {
    final canOpen =
        !day.isToday && day.data?.record != null && widget.onOpenRecall != null;
    return Focus(
      key: ValueKey(day.date),
      canRequestFocus: canOpen,
      onFocusChange: (focused) =>
          setState(() => _focusedEnergyDay = focused ? index : null),
      onKeyEvent: (node, event) {
        if (canOpen &&
            event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space)) {
          unawaited(_openDay(day));
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        container: true,
        label: _accessibleDayLabel(
          context,
          day,
          day.hasChartData
              ? _calories(
                  context,
                  _energyUnavailable(day.data!.nutrition)
                      ? null
                      : day.data!.nutrition.energyKcal,
                )
              : null,
        ),
        hint: canOpen
            ? AppLocalizations.of(context)!.nutrition_view_day_hint
            : null,
        button: canOpen,
        onTap: canOpen ? () => unawaited(_openDay(day)) : null,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: _focusedEnergyDay == index
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  Future<void> _openDay(NutritionStatisticsPeriodDay day) async {
    final record = day.data?.record;
    final openRecall = widget.onOpenRecall;
    if (record == null || openRecall == null) return;
    await openRecall(record);
    if (!mounted) return;
    setState(() {
      _records = _loadRecords();
    });
  }

  Widget _nutrientCard(
    BuildContext context,
    NutritionStatisticsPeriod current,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final average = current.average(
      (nutrition) => _nutrientValue(_selectedNutrient, nutrition),
    );
    final values = [
      for (final day in current.days)
        if (day.hasChartData)
          _nutrientValue(_selectedNutrient, day.data!.nutrition),
    ];
    final maxY = _chartMax(values);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.nutrition_nutrient_trend,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<_Nutrient>(
                segments: [
                  ButtonSegment(
                    value: _Nutrient.carbs,
                    label: Text(l10n.nutrition_carbs),
                  ),
                  ButtonSegment(
                    value: _Nutrient.protein,
                    label: Text(l10n.protein),
                  ),
                  ButtonSegment(value: _Nutrient.fat, label: Text(l10n.fat)),
                  ButtonSegment(
                    value: _Nutrient.fiber,
                    label: Text(l10n.fibre),
                  ),
                ],
                selected: {_selectedNutrient},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    setState(() => _selectedNutrient = selection.single),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: _nutrientChart(context, current, maxY),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.nutrition_average_per_recorded_day(_grams(context, average)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutrientChart(
    BuildContext context,
    NutritionStatisticsPeriod current,
    double maxY,
  ) {
    final theme = Theme.of(context);
    return Semantics(
      label: _lineChartSemantics(context, current),
      child: ExcludeSemantics(
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (current.days.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
            ),
            titlesData: _titlesData(context, current, maxY: maxY, unit: 'g'),
            lineBarsData: _lineSegments(
              current,
              _selectedNutrient,
              theme.colorScheme.primary,
            ),
            lineTouchData: LineTouchData(
              touchSpotThreshold: 24,
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                getTooltipItems: (spots) => [
                  for (final spot in spots)
                    LineTooltipItem(
                      '${_tooltipDate(context, current.days[spot.x.round()])} · '
                      '${_grams(context, spot.y)}',
                      TextStyle(color: theme.colorScheme.onInverseSurface),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _comparisonCard(
    BuildContext context,
    NutritionStatisticsPeriod current,
    NutritionStatisticsPeriod previous,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final enoughData =
        current.recordedCount >= 2 && previous.recordedCount >= 2;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: enoughData
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.nutrition_compared_previous_days(_selectedPeriod.days),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _changeRow(
                    context,
                    l10n.nutrition_energy,
                    current.average((value) => value.energyKcal)! -
                        previous.average((value) => value.energyKcal)!,
                    calories: true,
                  ),
                  _changeRow(
                    context,
                    l10n.protein,
                    current.average((value) => value.protein)! -
                        previous.average((value) => value.protein)!,
                  ),
                  _changeRow(
                    context,
                    l10n.fibre,
                    current.average((value) => value.fiber)! -
                        previous.average((value) => value.fiber)!,
                  ),
                ],
              )
            : Text(l10n.nutrition_record_more_comparisons),
      ),
    );
  }

  Widget _changeRow(
    BuildContext context,
    String label,
    double change, {
    bool calories = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final rounded = change.abs() < 0.05 ? 0.0 : change;
    final sign = rounded > 0 ? '+' : (rounded < 0 ? '−' : '');
    final magnitude = calories
        ? _numberFormat(context, maximumFractionDigits: 0).format(rounded.abs())
        : _numberFormat(
            context,
            maximumFractionDigits: 1,
          ).format(rounded.abs());
    final value = calories
        ? l10n.nutrition_kcal_per_day('$sign$magnitude')
        : l10n.nutrition_grams_per_day('$sign$magnitude');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Icon(
            rounded > 0
                ? Icons.arrow_upward
                : (rounded < 0 ? Icons.arrow_downward : Icons.remove),
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(value),
        ],
      ),
    );
  }

  FlTitlesData _titlesData(
    BuildContext context,
    NutritionStatisticsPeriod period, {
    required double maxY,
    required String unit,
  }) => FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      axisNameWidget: Text(unit, style: Theme.of(context).textTheme.bodySmall),
      axisNameSize: 20,
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 36,
        interval: maxY / 4,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          meta: meta,
          space: 4,
          child: Text(
            _axisLabel(context, value, interval: maxY / 4),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final index = value.round();
          if ((value - index).abs() > 0.001 ||
              index < 0 ||
              index >= period.days.length) {
            return const SizedBox.shrink();
          }
          if (period.days.length > 7 &&
              index % 5 != 0 &&
              index != period.days.length - 1) {
            return const SizedBox.shrink();
          }
          final day = period.days[index];
          final locale = Localizations.localeOf(context).toString();
          final label = day.isToday
              ? AppLocalizations.of(context)!.today
              : (period.days.length == 7
                    ? DateFormat.E(locale).format(day.date)
                    : DateFormat('d MMM', locale).format(day.date));
          return SideTitleWidget(
            meta: meta,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontWeight: day.isToday ? FontWeight.bold : null),
            ),
          );
        },
      ),
    ),
  );

  List<LineChartBarData> _lineSegments(
    NutritionStatisticsPeriod period,
    _Nutrient nutrient,
    Color color,
  ) {
    final result = <LineChartBarData>[];
    var segment = <FlSpot>[];

    void addSegment() {
      if (segment.isEmpty) return;
      result.add(LineChartBarData(spots: segment, color: color, barWidth: 3));
      segment = [];
    }

    for (var index = 0; index < period.days.length; index++) {
      final day = period.days[index];
      if (!day.hasChartData) {
        addSegment();
        continue;
      }
      segment.add(
        FlSpot(index.toDouble(), _nutrientValue(nutrient, day.data!.nutrition)),
      );
    }
    addSegment();
    return result;
  }

  double _nutrientValue(_Nutrient nutrient, NutritionProfile nutrition) =>
      switch (nutrient) {
        _Nutrient.carbs => nutrition.carbs,
        _Nutrient.protein => nutrition.protein,
        _Nutrient.fat => nutrition.fat,
        _Nutrient.fiber => nutrition.fiber,
      };

  String _lineChartSemantics(
    BuildContext context,
    NutritionStatisticsPeriod period,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final nutrient = switch (_selectedNutrient) {
      _Nutrient.carbs => l10n.nutrition_carbs,
      _Nutrient.protein => l10n.protein,
      _Nutrient.fat => l10n.fat,
      _Nutrient.fiber => l10n.fibre,
    };
    return '$nutrient. ${[for (final day in period.days) _accessibleDayLabel(context, day, day.hasChartData ? _grams(context, _nutrientValue(_selectedNutrient, day.data!.nutrition)) : null)].join('; ')}';
  }

  String _accessibleDayLabel(
    BuildContext context,
    NutritionStatisticsPeriodDay day,
    String? value,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final date = day.isToday
        ? l10n.nutrition_today_so_far
        : DateFormat.yMMMd(Localizations.localeOf(context).toString())
              .format(day.date);
    return value == null
        ? l10n.nutrition_chart_day_missing(date)
        : l10n.nutrition_chart_day_value(date, value);
  }

  String _tooltipDate(BuildContext context, NutritionStatisticsPeriodDay day) {
    if (day.isToday) {
      return AppLocalizations.of(context)!.nutrition_today_so_far;
    }
    return DateFormat(
      'EEE, d MMM',
      Localizations.localeOf(context).toString(),
    ).format(day.date);
  }

  String _periodLabel(BuildContext context, DateTime start, DateTime end) {
    final locale = Localizations.localeOf(context).toString();
    if (start.year == end.year && start.month == end.month) {
      return '${start.day}–${end.day} ${DateFormat.MMMM(locale).format(end)}';
    }
    if (start.year == end.year) {
      return '${DateFormat('d MMM', locale).format(start)}–'
          '${DateFormat('d MMM', locale).format(end)}';
    }
    return '${DateFormat.yMMMd(locale).format(start)}–'
        '${DateFormat.yMMMd(locale).format(end)}';
  }

  String _calories(BuildContext context, double? value) => value == null
      ? '—'
      : '${_numberFormat(context, maximumFractionDigits: 0).format(value)} kcal';

  String _grams(BuildContext context, double? value) => value == null
      ? '—'
      : '${_numberFormat(context, maximumFractionDigits: 1).format(value)} g';

  NumberFormat _numberFormat(
    BuildContext context, {
    required int maximumFractionDigits,
  }) =>
      NumberFormat.decimalPattern(Localizations.localeOf(context).toString())
        ..maximumFractionDigits = maximumFractionDigits;

  String _axisLabel(
    BuildContext context,
    double value, {
    required double interval,
  }) {
    final locale = Localizations.localeOf(context).toString();
    if (value.abs() >= 1000) {
      return NumberFormat.compact(locale: locale).format(value);
    }
    var scaledInterval = interval.abs();
    var fractionDigits = 0;
    while (fractionDigits < 4 &&
        (scaledInterval - scaledInterval.round()).abs() > 0.000001) {
      scaledInterval *= 10;
      fractionDigits++;
    }
    return _numberFormat(
      context,
      maximumFractionDigits: fractionDigits,
    ).format(value);
  }

  double _chartMax(Iterable<double> values) {
    var maximum = 0.0;
    for (final value in values) {
      maximum = math.max(maximum, value);
    }
    if (maximum <= 0) return 4;

    final rawStep = maximum / 4;
    final magnitude = math
        .pow(10, (math.log(rawStep) / math.ln10).floor())
        .toDouble();
    final normalized = rawStep / magnitude;
    final niceStep = switch (normalized) {
      <= 1 => 1,
      <= 2 => 2,
      <= 2.5 => 2.5,
      <= 5 => 5,
      <= 7.5 => 7.5,
      _ => 10,
    };
    return niceStep * magnitude * 4;
  }
}

bool _energyUnavailable(NutritionProfile nutrition) {
  final macroEnergy =
      nutrition.carbs * 4 + nutrition.protein * 4 + nutrition.fat * 9;
  return nutrition.unavailableNutrients.contains('energyKcal') ||
      (nutrition.energyKcal <= 0 && macroEnergy > 0);
}

class const NutritionStatisticsDay({
  required final int studyDaySnapshot,
  required final DateTime date,
  required final NutritionProfile nutrition,
  required final bool isRecorded,
  required final bool hasData,
  required final NutritionRecallRecord? record,
});

class const NutritionStatisticsPeriodDay({
  required final DateTime date,
  required final NutritionStatisticsDay? data,
  required final bool isToday,
}) {
  bool get isRecorded => data?.isRecorded ?? false;
  bool get hasChartData => isRecorded || (isToday && (data?.hasData ?? false));
}

class const NutritionStatisticsPeriod(
  final List<NutritionStatisticsPeriodDay> days,
) {
  DateTime get startDate => days.first.date;
  DateTime get endDate => days.last.date;
  int get recordedCount => days.where((day) => day.isRecorded).length;
  Set<String> get unavailableNutrients => {
    for (final day in days)
      if (day.isRecorded) ...day.data!.nutrition.unavailableNutrients,
  };
  bool get hasUnavailableEnergy => days.any(
    (day) => day.isRecorded && _energyUnavailable(day.data!.nutrition),
  );
  bool get hasTodaySoFar =>
      days.any((day) => day.isToday && !day.isRecorded && day.hasChartData);

  double? average(double Function(NutritionProfile nutrition) value) {
    final recordedDays = days.where((day) => day.isRecorded).toList();
    if (recordedDays.isEmpty) return null;
    return recordedDays.fold<double>(
          0,
          (sum, day) => sum + value(day.data!.nutrition),
        ) /
        recordedDays.length;
  }
}

List<NutritionStatisticsDay> nutritionStatisticsDays(
  List<NutritionRecallRecord> records, {
  DailyRecall? activeRecall,
  int? activeStudyDay,
  String? activePeriodId,
  DateTime? today,
}) {
  final mergedRecords = [...records];
  final activeDay = activeStudyDay ?? activeRecall?.studyDaySnapshot;
  if (activeRecall != null && activeDay != null) {
    bool matchesActiveRecord(NutritionRecallRecord record) =>
        record.studyDaySnapshot == activeDay &&
        (activePeriodId != null
            ? record.periodId == activePeriodId
            : record.recall.id == activeRecall.id);

    NutritionRecallRecord? replaced;
    for (final record in mergedRecords) {
      if (matchesActiveRecord(record)) {
        replaced = record;
        break;
      }
    }
    mergedRecords.removeWhere(matchesActiveRecord);
    mergedRecords.add(
      NutritionRecallRecord(
        recall: activeRecall,
        taskId: replaced?.taskId ?? '',
        periodId: activePeriodId,
        interventionId: replaced?.interventionId ?? '',
        studyDaySnapshot: activeDay,
        progress: replaced?.progress,
      ),
    );
  }

  final byDay = <int, List<NutritionRecallRecord>>{};
  for (final record in mergedRecords) {
    byDay.putIfAbsent(record.studyDaySnapshot, () => []).add(record);
  }
  final days = byDay.entries.map((entry) {
    final recordsForDay = entry.value;
    final date = DateUtils.dateOnly(recordsForDay.first.recall.date.toLocal());
    final foods = [
      for (final record in recordsForDay)
        for (final meal in record.recall.meals)
          if (!meal.isSkipped) ...meal.foods,
    ];
    final completed = recordsForDay.where(
      (record) => record.recall.entryCompletedAt != null,
    );
    return NutritionStatisticsDay(
      studyDaySnapshot: entry.key,
      date: date,
      nutrition: sumNutritionFoods(foods),
      isRecorded: completed.isNotEmpty,
      hasData: foods.isNotEmpty,
      record: completed.isNotEmpty ? completed.first : recordsForDay.first,
    );
  }).toList()..sort((left, right) => left.date.compareTo(right.date));
  return days;
}

NutritionStatisticsPeriod nutritionStatisticsPeriod(
  List<NutritionStatisticsDay> statisticsDays, {
  required DateTime endDate,
  required int dayCount,
  DateTime? today,
}) {
  final end = DateUtils.dateOnly(endDate);
  final start = addCalendarDays(end, -(dayCount - 1));
  final currentDate = DateUtils.dateOnly(today ?? DateTime.now());
  final byDate = {
    for (final day in statisticsDays)
      _dateKey(DateUtils.dateOnly(day.date)): day,
  };
  return NutritionStatisticsPeriod([
    for (var offset = 0; offset < dayCount; offset++)
      NutritionStatisticsPeriodDay(
        date: addCalendarDays(start, offset),
        data: byDate[_dateKey(addCalendarDays(start, offset))],
        isToday: DateUtils.isSameDay(
          addCalendarDays(start, offset),
          currentDate,
        ),
      ),
  ]);
}

DateTime addCalendarDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';
