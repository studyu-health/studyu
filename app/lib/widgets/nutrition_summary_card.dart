import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

class const NutritionMacroDistributionBar({
  required final double carbs,
  required final double protein,
  required final double fat,
  final Set<String> unavailableNutrients = const {},
  final String Function(double)? formatGrams,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = carbs * 4 + protein * 4 + fat * 9;
    final distributionUnavailable = unavailableNutrients.any(
      (key) => {'carbs', 'protein', 'fat'}.contains(key),
    );
    if (total <= 0 || distributionUnavailable) return const SizedBox.shrink();

    final macros = _macros(context, total);
    final contextLabel =
        '${l10n.energy_by_macronutrient}: '
        '${macros.map((macro) => '${macro.label} ${macro.percent.round()}%').join(', ')}';
    return Semantics(
      label: contextLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _legend(context, macros),
          const SizedBox(height: 8),
          _bar(context, macros),
        ],
      ),
    );
  }

  List<_NutritionMacroData> _macros(BuildContext context, double total) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return [
      _NutritionMacroData(
        label: l10n.carbohydrates,
        grams: carbs,
        percent: carbs * 4 / total * 100,
        color: colors.primary,
      ),
      _NutritionMacroData(
        label: l10n.protein,
        grams: protein,
        percent: protein * 4 / total * 100,
        color: colors.secondary,
      ),
      _NutritionMacroData(
        label: l10n.fat,
        grams: fat,
        percent: fat * 9 / total * 100,
        color: colors.tertiary,
      ),
    ];
  }

  Widget _bar(BuildContext context, List<_NutritionMacroData> macros) {
    final colors = Theme.of(context).colorScheme;
    final stackItems = <BarChartRodStackItem>[];
    var fromY = 0.0;
    for (final macro in macros) {
      if (macro.percent <= 0) continue;

      final toY = fromY + macro.percent;
      stackItems.add(BarChartRodStackItem(fromY, toY, macro.color));
      fromY = toY;
    }
    return SizedBox(
      height: 24,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: 100,
          rotationQuarterTurns: 1,
          alignment: BarChartAlignment.center,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 100,
                  width: 14,
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                  rodStackItems: stackItems,
                ),
              ],
            ),
          ],
          barTouchData: const BarTouchData(enabled: false),
        ),
        duration: Duration.zero,
      ),
    );
  }

  Widget _legend(BuildContext context, List<_NutritionMacroData> macros) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final macro in macros)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: macro.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(macro.label)),
                SizedBox(
                  width: 64,
                  child: Text(
                    formatGrams?.call(macro.grams) ?? _formatGrams(macro.grams),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${macro.percent.round()}%',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatGrams(double value) {
    final formatted = value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
    return '$formatted g';
  }
}

class const _NutritionMacroData({
  required final String label,
  required final double grams,
  required final double percent,
  required final Color color,
});

class const NutritionSummaryView({
  required final double? energyKcal,
  required final double? carbs,
  required final double? protein,
  required final double? fat,
  final Set<String> unavailableNutrients = const {},
  final bool energyUnavailable = false,
  final String Function(double)? formatEnergy,
  final String Function(double)? formatGrams,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final total = (carbs ?? 0) * 4 + (protein ?? 0) * 4 + (fat ?? 0) * 9;
    final energyContradictory =
        energyKcal != null && energyKcal! <= 0 && total > 0;
    final hideEnergy =
        energyUnavailable ||
        _isUnavailable('energyKcal', energyKcal) ||
        energyContradictory;
    final distributionUnavailable =
        energyContradictory ||
        _isUnavailable('carbs', carbs) ||
        _isUnavailable('protein', protein) ||
        _isUnavailable('fat', fat);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _nutritionIconBadge(
              icon: Icons.local_fire_department_outlined,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hideEnergy
                        ? '—'
                        : formatEnergy?.call(energyKcal!) ??
                              '${energyKcal!.round()} kcal',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(l10n.total_energy),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.macronutrients,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (total <= 0 || distributionUnavailable) ...[
          _macronutrientRow(
            context,
            label: l10n.carbohydrates,
            value: carbs,
            keyName: 'carbs',
          ),
          _macronutrientRow(
            context,
            label: l10n.protein,
            value: protein,
            keyName: 'protein',
          ),
          _macronutrientRow(
            context,
            label: l10n.fat,
            value: fat,
            keyName: 'fat',
          ),
        ] else ...[
          const SizedBox(height: 4),
          NutritionMacroDistributionBar(
            carbs: carbs!,
            protein: protein!,
            fat: fat!,
            unavailableNutrients: unavailableNutrients,
            formatGrams: formatGrams,
          ),
        ],
      ],
    );
  }

  bool _isUnavailable(String key, double? value) =>
      value == null || unavailableNutrients.contains(key);

  Widget _macronutrientRow(
    BuildContext context, {
    required String label,
    required double? value,
    required String keyName,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            _formatGrams(value, keyName),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatGrams(double? value, String key) {
    if (_isUnavailable(key, value)) return '—';
    if (formatGrams != null) return formatGrams!(value!);
    if (value == 0) return '0 g';
    return '${value!.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '')} g';
  }
}

class const NutritionSummaryCard({
  required final NutritionProfile nutrition,
  final String? title,
  final String? subtitle,
  final bool inCard = false,
  final bool showTitle = true,
  super.key,
}) extends StatefulWidget {
  @override
  State<NutritionSummaryCard> createState() => _NutritionSummaryCardState();
}

class _NutritionSummaryCardState() extends State<NutritionSummaryCard> {
  bool _detailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final content = _content(context, includeHeader: true);
    if (!widget.inCard) return content;

    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: content,
      ),
    );
  }

  Widget _content(BuildContext context, {required bool includeHeader}) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: includeHeader ? 16 : 0, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (includeHeader && widget.showTitle) ...[
                Text(
                  widget.title ?? l10n.nutrition_summary,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(widget.subtitle!, style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: 12),
              ],
              NutritionSummaryView(
                energyKcal: widget.nutrition.energyKcal,
                carbs: widget.nutrition.carbs,
                protein: widget.nutrition.protein,
                fat: widget.nutrition.fat,
                unavailableNutrients: widget.nutrition.unavailableNutrients,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _details(context),
        ),
      ],
    );
  }

  Widget _details(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          toggled: _detailsExpanded,
          label: l10n.detailed_nutrients,
          hint: _detailsExpanded ? l10n.hide : l10n.show,
          onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
          child: InkWell(
            onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  _nutritionIconBadge(
                    icon: Icons.eco_outlined,
                    color: Colors.green.shade700,
                    size: 32,
                    iconSize: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.detailed_nutrients,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _detailsExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.nutrition.unavailableItemCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.some_values_unavailable(
                widget.nutrition.unavailableItemCount,
              ),
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (_detailsExpanded) ...[
          _group(context, l10n.carbohydrates, [
            _row(l10n.fibre, widget.nutrition.fiber, 'g', 'fiber'),
            _row(l10n.sugars_g, widget.nutrition.sugars, 'g', 'sugars'),
          ]),
          _group(context, l10n.fat, [
            _row(
              l10n.saturated_fat_g,
              widget.nutrition.saturatedFat,
              'g',
              'saturatedFat',
            ),
            _row('Trans fat', widget.nutrition.transFat, 'g', 'transFat'),
          ]),
          _group(context, l10n.other, [
            _row(
              'Cholesterol',
              widget.nutrition.cholesterol,
              'mg',
              'cholesterol',
            ),
            _row(l10n.sodium_mg, widget.nutrition.sodium, 'mg', 'sodium'),
            _row('Water', widget.nutrition.waterContent, 'g', 'waterContent'),
          ]),
        ],
      ],
    );
  }

  Widget _group(BuildContext context, String title, List<Widget> rows) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, double value, String unit, String key) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(_format(value, unit, key))],
    ),
  );

  String _format(double value, String unit, String key) {
    if (widget.nutrition.unavailableNutrients.contains(key)) return '—';
    if (unit == 'mg') return '${value.round()} mg';
    if (value == 0) return '0 g';
    return '${value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '')} g';
  }
}

Widget _nutritionIconBadge({
  required IconData icon,
  required Color color,
  double size = 40,
  double iconSize = 22,
}) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.12),
    shape: BoxShape.circle,
  ),
  child: ExcludeSemantics(
    child: Icon(icon, color: color, size: iconSize),
  ),
);

class const DailyNutritionSummaryCard({
  required final DailyRecall dailyRecall,
  final bool showTitle = true,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => NutritionSummaryCard(
    nutrition: sumNutritionFoods([
      for (final meal in dailyRecall.meals)
        if (!meal.isSkipped) ...meal.foods,
    ]),
    title: AppLocalizations.of(context)!.daily_nutrition_total,
    inCard: true,
    showTitle: showTitle,
  );
}

class const MealNutritionSummaryCard({required final MealLog meal, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => NutritionSummaryCard(
    nutrition: sumNutritionFoods(meal.foods),
    title: AppLocalizations.of(context)!.meal_nutrition,
    inCard: true,
  );
}

NutritionProfile sumNutritionFoods(List<FoodEntry> foods) {
  double energy = 0;
  double protein = 0;
  double carbs = 0;
  double fat = 0;
  double sugars = 0;
  double fiber = 0;
  double saturatedFat = 0;
  double transFat = 0;
  double cholesterol = 0;
  double sodium = 0;
  double water = 0;
  final micros = <String, double>{};
  final unavailable = <String>{};
  var unavailableItems = 0;
  for (final food in foods) {
    final n = food.nutrition;
    energy += n.energyKcal;
    protein += n.protein;
    carbs += n.carbs;
    fat += n.fat;
    sugars += n.sugars;
    fiber += n.fiber;
    saturatedFat += n.saturatedFat;
    transFat += n.transFat;
    cholesterol += n.cholesterol;
    sodium += n.sodium;
    water += n.waterContent;
    n.micros.forEach((key, value) => micros[key] = (micros[key] ?? 0) + value);
    unavailable.addAll(n.unavailableNutrients);
    if (n.unavailableNutrients.isNotEmpty) {
      unavailableItems += n.unavailableItemCount == 0
          ? 1
          : n.unavailableItemCount;
    }
  }
  return NutritionProfile(
    energyKcal: energy,
    protein: protein,
    carbs: carbs,
    fat: fat,
    sugars: sugars,
    fiber: fiber,
    saturatedFat: saturatedFat,
    transFat: transFat,
    cholesterol: cholesterol,
    sodium: sodium,
    waterContent: water,
    micros: micros,
    unavailableNutrients: unavailable,
    unavailableItemCount: unavailableItems,
  );
}
