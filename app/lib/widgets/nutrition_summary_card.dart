import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

class const NutritionSummaryCard({
  required final NutritionProfile nutrition,
  final String? title,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cardTitle = title ?? l10n.nutrition_summary;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  cardTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calories
            _buildMainNutrient(
              context,
              l10n.energy_kcal,
              nutrition.energyKcal,
              'kcal',
              Icons.local_fire_department,
              Colors.orange,
            ),

            const Divider(height: 24),

            // Macronutrients
            Text(
              l10n.macronutrients,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildMacroNutrient(
                    context,
                    l10n.protein_g,
                    nutrition.protein,
                    'g',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMacroNutrient(
                    context,
                    l10n.carbs_g,
                    nutrition.carbs,
                    'g',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMacroNutrient(
                    context,
                    l10n.fat_g,
                    nutrition.fat,
                    'g',
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Macronutrient Distribution Chart
            _buildMacroDistributionBar(context),

            const Divider(height: 24),

            // Additional Nutrients
            ExpansionTile(
              title: Text(l10n.detailed_nutrients),
              leading: const Icon(Icons.more_horiz),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildDetailedNutrient(
                        l10n.fiber_g,
                        nutrition.fiber,
                        'g',
                      ),
                      _buildDetailedNutrient(
                        l10n.sugars_g,
                        nutrition.sugars,
                        'g',
                      ),
                      _buildDetailedNutrient(
                        l10n.saturated_fat_g,
                        nutrition.saturatedFat,
                        'g',
                      ),
                      _buildDetailedNutrient(
                        'Trans Fat',
                        nutrition.transFat,
                        'g',
                      ),
                      _buildDetailedNutrient(
                        'Cholesterol',
                        nutrition.cholesterol,
                        'mg',
                      ),
                      _buildDetailedNutrient(
                        l10n.sodium_mg,
                        nutrition.sodium,
                        'mg',
                      ),
                      _buildDetailedNutrient(
                        'Water Content',
                        nutrition.waterContent,
                        'g',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainNutrient(
    BuildContext context,
    String label,
    double value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${value.toStringAsFixed(0)} $unit',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroNutrient(
    BuildContext context,
    String label,
    double value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroDistributionBar(BuildContext context) {
    final totalCals =
        (nutrition.protein * 4) + (nutrition.carbs * 4) + (nutrition.fat * 9);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (totalCals == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 24,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.no_data_yet,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.start_tracking_nutrition,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final proteinPercent = (nutrition.protein * 4 / totalCals) * 100;
    final carbsPercent = (nutrition.carbs * 4 / totalCals) * 100;
    final fatPercent = (nutrition.fat * 9 / totalCals) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.calorie_distribution,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              if (proteinPercent > 0)
                Expanded(
                  flex: proteinPercent.round(),
                  child: Container(
                    height: 24,
                    color: Colors.blue,
                    alignment: Alignment.center,
                    child: proteinPercent >= 15
                        ? Text(
                            '${proteinPercent.round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              if (carbsPercent > 0)
                Expanded(
                  flex: carbsPercent.round(),
                  child: Container(
                    height: 24,
                    color: Colors.green,
                    alignment: Alignment.center,
                    child: carbsPercent >= 15
                        ? Text(
                            '${carbsPercent.round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              if (fatPercent > 0)
                Expanded(
                  flex: fatPercent.round(),
                  child: Container(
                    height: 24,
                    color: Colors.purple,
                    alignment: Alignment.center,
                    child: fatPercent >= 15
                        ? Text(
                            '${fatPercent.round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedNutrient(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class const DailyNutritionSummaryCard({
  required final DailyRecall dailyRecall,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final nutrition = dailyRecall.totalNutrition;
    final l10n = AppLocalizations.of(context)!;
    return NutritionSummaryCard(
      nutrition: nutrition,
      title: l10n.daily_nutrition_total,
    );
  }
}

class const MealNutritionSummaryCard({required final MealLog meal, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final nutrition = meal.totalNutrition;
    final l10n = AppLocalizations.of(context)!;
    return NutritionSummaryCard(
      nutrition: nutrition,
      title: l10n.meal_nutrition,
    );
  }
}
