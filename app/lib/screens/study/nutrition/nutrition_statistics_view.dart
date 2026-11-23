import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/widgets/empty_state.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_core/core.dart';

class const NutritionStatisticsView({
  final StudySubject? subject,
  final String? taskId,
  final NutritionTask? task,
  final NutritionRecallAutoSaveManager? autoSaveManager,
  final DailyRecall? activeRecall,
  final int? activeStudyDay,
  final String? activePeriodId,
  final Future<void> Function(NutritionRecallRecord record)? onOpenRecall,
  final bool isVisible = true,
  super.key,
}) extends StatefulWidget {
  @override
  State<NutritionStatisticsView> createState() =>
      _NutritionStatisticsViewState();
}

enum _StatisticsPeriod(final int days) {
  day(1),
  week(7),
  month(30),
}

enum _Nutrient() {
  carbs,
  protein,
  fat,
  fiber,
}

class _NutritionStatisticsViewState() extends State<NutritionStatisticsView> {
  Future<List<NutritionRecallRecord>>? _records;
  _StatisticsPeriod _selectedPeriod = _StatisticsPeriod.day;
  int _periodsBack = 0;
  _Nutrient _selectedNutrient = _Nutrient.carbs;
  int? _focusedEnergyDay;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) _records = _loadRecords();
  }

  @override
  void didUpdateWidget(covariant NutritionStatisticsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final sourceChanged =
        oldWidget.subject?.id != widget.subject?.id ||
        oldWidget.taskId != widget.taskId;
    if (sourceChanged) {
      _selectedPeriod = _StatisticsPeriod.day;
      _periodsBack = 0;
      _focusedEnergyDay = null;
      _records = null;
    }
    if (widget.isVisible &&
        (sourceChanged ||
            !oldWidget.isVisible ||
            !identical(oldWidget.subject, widget.subject))) {
      _records = _loadRecords();
    }
  }

  Future<List<NutritionRecallRecord>> _loadRecords() {
    final subject = widget.subject;
    final taskId = widget.taskId;
    if (subject == null || taskId == null) return Future.value([]);
    return loadNutritionRecallRecords(
      subject: subject,
      taskId: taskId,
      autoSaveManager: widget.autoSaveManager,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_records == null) return const SizedBox.shrink();
    return FutureBuilder<List<NutritionRecallRecord>>(
      key: ValueKey((widget.subject?.id, widget.taskId)),
      future: _records,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text(l10n.error));
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final now = DateTime.now();
        final subject = widget.subject;
        final today = DateUtils.dateOnly(
          subject?.startedAt == null ? now : now.toUtc(),
        );
        final statisticsDays = nutritionStatisticsDays(
          snapshot.data!,
          subject: subject,
          task: widget.task,
          activeRecall: widget.activeRecall,
          activeStudyDay: widget.activeStudyDay,
          activePeriodId: widget.activePeriodId,
        );
        final periodDays = _selectedPeriod.days;
        final earliest = statisticsDays.firstOrNull?.date ?? today;
        final daysSinceEarliest =
            DateTime.utc(today.year, today.month, today.day)
                .difference(
                  DateTime.utc(earliest.year, earliest.month, earliest.day),
                )
                .inDays;
        final maxPeriodsBack = math.max(0, daysSinceEarliest ~/ periodDays);
        final periodsBack = math.min(_periodsBack, maxPeriodsBack);
        final endDate = addCalendarDays(today, -periodsBack * periodDays);
        final current = nutritionStatisticsPeriod(
          statisticsDays,
          endDate: endDate,
          dayCount: periodDays,
          today: today,
        );
        final isDaily = _selectedPeriod == _StatisticsPeriod.day;
        final previous = nutritionStatisticsPeriod(
          statisticsDays,
          endDate: addCalendarDays(endDate, -periodDays),
          dayCount: periodDays,
          today: today,
        );
        final hasData = current.days.any((day) => day.hasChartData);
        final canCompare =
            current.recordedCount >= 2 && previous.recordedCount >= 2;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<_StatisticsPeriod>(
              segments: [
                ButtonSegment(
                  value: _StatisticsPeriod.day,
                  label: Text(l10n.day),
                ),
                ButtonSegment(
                  value: _StatisticsPeriod.week,
                  label: Text(l10n.nutrition_statistics_week),
                ),
                ButtonSegment(
                  value: _StatisticsPeriod.month,
                  label: Text(l10n.nutrition_statistics_month),
                ),
              ],
              selected: {_selectedPeriod},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => setState(() {
                _selectedPeriod = selection.single;
                _periodsBack = 0;
                _focusedEnergyDay = null;
              }),
            ),
            const SizedBox(height: 12),
            _dateNavigation(
              context,
              current,
              periodsBack: periodsBack,
              canGoBack: periodsBack < maxPeriodsBack,
            ),
            if (isDaily) ...[
              const SizedBox(height: 16),
              _dailySummary(context, current.days.single, previous.days.single),
            ] else ...[
              Text(
                '${l10n.nutrition_completed_days(current.recordedCount)}'
                '${current.hasTodaySoFar ? ' · ${l10n.nutrition_today_so_far}' : ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (!hasData)
                EmptyState(
                  icon: Icons.bar_chart_outlined,
                  message: l10n.nutrition_statistics_empty,
                )
              else ...[
                _aggregateOverview(
                  context,
                  current,
                  previous,
                  canCompare: canCompare,
                ),
                const SizedBox(height: 12),
                _energyCard(context, current),
                const SizedBox(height: 12),
                _nutrientCard(context, current),
                const SizedBox(height: 12),
                _comparisonCard(
                  context,
                  current,
                  previous,
                  canCompare: canCompare,
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _dateNavigation(
    BuildContext context,
    NutritionStatisticsPeriod period, {
    required int periodsBack,
    required bool canGoBack,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isLatest = periodsBack == 0;
    final label = _selectedPeriod == _StatisticsPeriod.day
        ? (isLatest
              ? l10n.today
              : DateFormat.yMMMd(Localizations.localeOf(context).toString())
                    .format(period.endDate))
        : _periodLabel(context, period.startDate, period.endDate);
    return Row(
      children: [
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Wrap(
          spacing: 4,
          children: [
            IconButton.filledTonal(
              icon: const Icon(Icons.chevron_left),
              tooltip: l10n.nutrition_statistics_previous_period,
              onPressed: canGoBack ? () => _selectDate(periodsBack + 1) : null,
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.chevron_right),
              tooltip: l10n.nutrition_statistics_next_period,
              onPressed: isLatest ? null : () => _selectDate(periodsBack - 1),
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.settings_backup_restore),
              tooltip: l10n.nutrition_statistics_go_to_today,
              onPressed: isLatest ? null : () => _selectDate(0),
            ),
          ],
        ),
      ],
    );
  }

  void _selectDate(int periodsBack) => setState(() {
    _periodsBack = periodsBack;
    _focusedEnergyDay = null;
  });

  Widget _dailySummary(
    BuildContext context,
    NutritionStatisticsPeriodDay day,
    NutritionStatisticsPeriodDay previous,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final data = day.data;
    if (data == null || (!data.hasData && !data.isRecorded)) {
      return EmptyState(
        icon: Icons.bar_chart_outlined,
        message: l10n.nutrition_statistics_empty,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _energyHeadline(
          context,
          label: day.isToday && !data.isRecorded
              ? l10n.nutrition_today_so_far
              : l10n.total_energy,
          nutrition: data.nutrition,
          change: _dailyNutritionEnergyChange(day, previous),
        ),
        const SizedBox(height: 16),
        NutritionSummaryCard(
          key: ValueKey(day.date),
          nutrition: data.nutrition,
          title: l10n.daily_summary,
          inCard: true,
          showEnergy: false,
        ),
      ],
    );
  }

  Widget _energyHeadline(
    BuildContext context, {
    required String label,
    required NutritionProfile nutrition,
    required int? change,
  }) {
    final theme = Theme.of(context);
    final energy = _energyUnavailable(nutrition) ? null : nutrition.energyKcal;
    final value = _calories(context, energy);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          value,
          semanticsLabel:
              '${AppLocalizations.of(context)!.nutrition_energy}, $value',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (change != null) ...[
          const SizedBox(height: 8),
          _energyChange(context, change),
        ],
      ],
    );
  }

  Widget _energyChange(BuildContext context, int change) {
    final l10n = AppLocalizations.of(context)!;
    final sign = change > 0 ? '+' : (change < 0 ? '−' : '');
    final value =
        '$sign${_numberFormat(context, maximumFractionDigits: 0).format(change.abs())}';
    final isDaily = _selectedPeriod == _StatisticsPeriod.day;
    final changeLabel = isDaily
        ? l10n.nutrition_energy_change_from_previous_day('$value kcal')
        : l10n.nutrition_kcal_per_day(value);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    _changeIcon(change),
                    size: 16,
                    color: colors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    changeLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isDaily)
          Text(l10n.nutrition_compared_previous_days(_selectedPeriod.days)),
      ],
    );
  }

  Widget _aggregateOverview(
    BuildContext context,
    NutritionStatisticsPeriod current,
    NutritionStatisticsPeriod previous, {
    required bool canCompare,
  }) {
    final nutrition = current.averageNutrition;
    final change = canCompare
        ? _averageChange(current, previous, 'energyKcal')?.round()
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _energyHeadline(
          context,
          label: AppLocalizations.of(context)!.nutrition_daily_average,
          nutrition: nutrition,
          change: change,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: NutritionSummaryView(
              energyKcal: null,
              showEnergy: false,
              carbs: nutrition.carbs,
              protein: nutrition.protein,
              fat: nutrition.fat,
              unavailableNutrients: nutrition.unavailableNutrients,
              partialNutrients: nutrition.partialNutrients,
              formatGrams: (value) => _grams(context, value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _energyCard(BuildContext context, NutritionStatisticsPeriod current) {
    final l10n = AppLocalizations.of(context)!;
    final average = current.hasUnavailableEnergy
        ? null
        : current.averageFor('energyKcal');
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
    final average = current.averageFor(_selectedNutrient.name);
    final values = [
      for (final day in current.days)
        if (day.hasChartData &&
            day.data!.nutrition.isKnown(_selectedNutrient.name))
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
    NutritionStatisticsPeriod previous, {
    required bool canCompare,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: canCompare
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
                    l10n.protein,
                    _averageChange(current, previous, 'protein'),
                  ),
                  _changeRow(
                    context,
                    l10n.fibre,
                    _averageChange(current, previous, 'fiber'),
                  ),
                ],
              )
            : Text(l10n.nutrition_record_more_comparisons),
      ),
    );
  }

  Widget _changeRow(BuildContext context, String label, double? change) {
    final l10n = AppLocalizations.of(context)!;
    if (change == null) {
      return Row(
        children: [
          Expanded(child: Text(label)),
          const Text('—'),
        ],
      );
    }
    final rounded = change.abs() < 0.05 ? 0.0 : change;
    final sign = rounded > 0 ? '+' : (rounded < 0 ? '−' : '');
    final magnitude = _numberFormat(
      context,
      maximumFractionDigits: 1,
    ).format(rounded.abs());
    final value = l10n.nutrition_grams_per_day('$sign$magnitude');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Icon(
            _changeIcon(rounded),
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
      if (!day.hasChartData || !day.data!.nutrition.isKnown(nutrient.name)) {
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
    final days = [
      for (final day in period.days)
        _accessibleDayLabel(
          context,
          day,
          day.hasChartData &&
                  day.data!.nutrition.isKnown(_selectedNutrient.name)
              ? _grams(
                  context,
                  _nutrientValue(_selectedNutrient, day.data!.nutrition),
                )
              : null,
        ),
    ];
    return '$nutrient. ${days.join('; ')}';
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
    final dateFormat = start.year == end.year && end.year == DateTime.now().year
        ? DateFormat.MMMd(locale)
        : DateFormat.yMMMd(locale);
    return '${dateFormat.format(start)} – ${dateFormat.format(end)}';
  }

  double? _averageChange(
    NutritionStatisticsPeriod current,
    NutritionStatisticsPeriod previous,
    String key,
  ) {
    if (current.partialNutrients.contains(key) ||
        previous.partialNutrients.contains(key)) {
      return null;
    }
    final currentValue = current.averageFor(key);
    final previousValue = previous.averageFor(key);
    return currentValue == null || previousValue == null
        ? null
        : currentValue - previousValue;
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

bool _energyUnavailable(NutritionProfile nutrition) =>
    !nutrition.isKnown('energyKcal');

IconData _changeIcon(num change) => change > 0
    ? Icons.arrow_upward
    : (change < 0 ? Icons.arrow_downward : Icons.remove);

int? _dailyNutritionEnergyChange(
  NutritionStatisticsPeriodDay day,
  NutritionStatisticsPeriodDay previous,
) {
  final currentData = day.data;
  final previousData = previous.data;
  if (currentData == null ||
      previousData == null ||
      (!day.isToday && !currentData.isRecorded) ||
      !previousData.isRecorded) {
    return null;
  }
  final current = currentData.nutrition;
  final baseline = previousData.nutrition;
  if (_energyUnavailable(current) ||
      _energyUnavailable(baseline) ||
      current.isPartial('energyKcal') ||
      baseline.isPartial('energyKcal')) {
    return null;
  }
  return (current.energyKcal - baseline.energyKcal).round();
}

class const NutritionStatisticsDay({
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
  NutritionProfile get averageNutrition => scaleNutritionProfile(
    sumNutritionProfiles([
      for (final day in days)
        if (day.isRecorded) day.data!.nutrition,
    ]),
    recordedCount == 0 ? 1 : 1 / recordedCount,
  );
  Set<String> get unavailableNutrients => averageNutrition.unavailableNutrients;
  Set<String> get partialNutrients => averageNutrition.partialNutrients;
  bool get hasUnavailableEnergy => !averageNutrition.isKnown('energyKcal');

  double? averageFor(String key) {
    final nutrition = averageNutrition;
    return nutrition.isKnown(key) ? nutrition.valueFor(key) : null;
  }

  bool get hasTodaySoFar =>
      days.any((day) => day.isToday && !day.isRecorded && day.hasChartData);
}

List<NutritionStatisticsDay> nutritionStatisticsDays(
  List<NutritionRecallRecord> records, {
  StudySubject? subject,
  NutritionTask? task,
  DailyRecall? activeRecall,
  int? activeStudyDay,
  String? activePeriodId,
}) {
  DateTime dateFor(DateTime recallDate, int? studyDay) => DateUtils.dateOnly(
    subject?.startedAt != null && studyDay != null
        ? subject!.nutritionDateForStudyDay(studyDay)
        : recallDate.toLocal(),
  );

  final activeDay = activeStudyDay ?? activeRecall?.studyDaySnapshot;
  bool matchesActiveRecord(NutritionRecallRecord record) =>
      activeRecall != null &&
      (activeDay != null && activePeriodId != null
          ? record.studyDaySnapshot == activeDay &&
                record.periodId == activePeriodId
          : record.recall.id == activeRecall.id);

  final byDate = <DateTime, List<NutritionRecallRecord>>{};
  final activeDate = activeRecall == null
      ? null
      : dateFor(activeRecall.date, activeDay);
  NutritionRecallRecord? replaced;
  for (final record in records) {
    if (matchesActiveRecord(record)) {
      replaced ??= record;
      continue;
    }
    final date = dateFor(record.recall.date, record.studyDaySnapshot);
    byDate.putIfAbsent(date, () => []).add(record);
  }
  if (activeDate != null) byDate.putIfAbsent(activeDate, () => []);
  final days = byDate.entries.map((entry) {
    final date = entry.key;
    final recordsForDate = entry.value;
    final active = date == activeDate ? activeRecall : null;
    final recalls = [
      for (final record in recordsForDate) record.recall,
      ?active,
    ];
    final foods = [
      for (final recall in recalls)
        for (final meal in recall.meals)
          if (!meal.isSkipped) ...meal.foods,
    ];
    final completedRecord = recordsForDate
        .where((record) => record.isCompleted)
        .firstOrNull;
    final allRecordsCompleted =
        recordsForDate.every((record) => record.isCompleted) &&
        (active == null ||
            (active.entryCompletedAt != null && replaced?.isCompleted == true));
    final completedPeriods = {
      for (final record in recordsForDate)
        if (record.isCompleted) record.periodId,
      if (active?.entryCompletedAt != null && replaced?.isCompleted == true)
        replaced!.periodId,
    };
    final scheduledPeriods = task?.schedule.completionPeriods;
    final day = active != null
        ? activeDay
        : recordsForDate.firstOrNull?.studyDaySnapshot;
    final scheduleRule = task?.scheduleRule;
    final isScheduled =
        scheduleRule == null ||
        (subject != null &&
            day != null &&
            scheduleRule.isScheduledForDay(day, subject.study.schedule));
    return NutritionStatisticsDay(
      date: date,
      nutrition: sumNutritionFoods(foods),
      isRecorded:
          allRecordsCompleted &&
          isScheduled &&
          (scheduledPeriods == null ||
              scheduledPeriods.isNotEmpty &&
                  scheduledPeriods.every(
                    (period) => completedPeriods.contains(period.id),
                  )),
      hasData: foods.isNotEmpty,
      record: completedRecord ?? replaced ?? recordsForDate.firstOrNull,
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
    for (final day in statisticsDays) DateUtils.dateOnly(day.date): day,
  };
  return NutritionStatisticsPeriod([
    for (var offset = 0; offset < dayCount; offset++)
      NutritionStatisticsPeriodDay(
        date: addCalendarDays(start, offset),
        data: byDate[addCalendarDays(start, offset)],
        isToday: DateUtils.isSameDay(
          addCalendarDays(start, offset),
          currentDate,
        ),
      ),
  ]);
}

DateTime addCalendarDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);
