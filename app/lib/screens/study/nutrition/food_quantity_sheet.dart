import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_core/core.dart';

enum FoodQuantityAction() {
  /// Legacy actions retained for source compatibility.
  existingMeal,
  addToSelection,
  addMealToSelection,
  updateSelection,
  addToMeal,
  update,
}

class const FoodQuantitySheet({
  required final FoodEntry food,
  final FoodEntry? baselineFood,
  final String? mealLabel,
  final FoodQuantityAction action = FoodQuantityAction.existingMeal,
  final double? initialAmount,
  final bool caloriesKnown = true,
  final bool gramsKnown = true,
  final bool? baselineGramsKnown,
  final ValueChanged<FoodEntry>? onConfirmed,
  final VoidCallback? onClose,
  super.key,
}) extends StatefulWidget {
  static Future<FoodEntry?> show(
    BuildContext context, {
    required FoodEntry food,
    FoodEntry? baselineFood,
    String? mealLabel,
    FoodQuantityAction action = FoodQuantityAction.existingMeal,
    double? initialAmount,
    bool caloriesKnown = true,
    bool gramsKnown = true,
    bool? baselineGramsKnown,
  }) => showModalBottomSheet<FoodEntry>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => FoodQuantitySheet(
      food: food,
      baselineFood: baselineFood,
      mealLabel: mealLabel,
      action: action,
      initialAmount: initialAmount,
      caloriesKnown: caloriesKnown,
      gramsKnown: gramsKnown,
      baselineGramsKnown: baselineGramsKnown,
    ),
  );

  @override
  State<FoodQuantitySheet> createState() => _FoodQuantitySheetState();
}

class _FoodQuantitySheetState() extends State<FoodQuantitySheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _servingWeightController;
  FoodEntry? _scaledFood;

  bool get _canEditServingWeight =>
      widget.action == FoodQuantityAction.updateSelection;
  FoodEntry get _baselineFood => widget.baselineFood ?? widget.food;
  bool get _baselineGramsKnown =>
      widget.baselineGramsKnown ?? widget.gramsKnown;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: _formatNumber(widget.initialAmount ?? widget.food.amount),
    );
    _servingWeightController = TextEditingController(
      text:
          widget.gramsKnown &&
              widget.food.servingSizeGrams.isFinite &&
              widget.food.servingSizeGrams > 0
          ? _formatNumber(widget.food.servingSizeGrams)
          : '',
    );
    _updateAmount();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _servingWeightController.dispose();
    super.dispose();
  }

  static String _formatNumber(double value) => value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  double? _parseNumber(String value) =>
      double.tryParse(value.replaceFirst(',', '.'));

  void _updateAmount([String? _]) {
    final amount = _parseNumber(_amountController.text);
    final weightText = _servingWeightController.text.trim();
    final weight = _canEditServingWeight
        ? _parseNumber(weightText)
        : widget.food.servingSizeGrams;
    final weightRequired =
        _canEditServingWeight &&
        (_baselineGramsKnown || widget.gramsKnown || weightText.isNotEmpty);
    final weightSource = _baselineGramsKnown ? _baselineFood : widget.food;
    final sourceAmount = weightSource.amount;
    final sourceWeight = weightSource.servingSizeGrams;
    final hasKnownSourceWeight =
        (_baselineGramsKnown || widget.gramsKnown) &&
        sourceWeight.isFinite &&
        sourceWeight > 0;
    setState(() {
      if (amount == null ||
          !amount.isFinite ||
          amount <= 0 ||
          (weightRequired &&
              (weight == null || !weight.isFinite || weight <= 0)) ||
          !sourceAmount.isFinite ||
          sourceAmount <= 0) {
        _scaledFood = null;
        return;
      }
      if (!weightRequired) {
        _scaledFood = rescaleFoodAmount(widget.food, amount);
        return;
      }
      final foodAtWeight = _canEditServingWeight
          ? ((hasKnownSourceWeight
                  ? rescaleFoodAmount(
                      weightSource,
                      sourceAmount * weight! / sourceWeight,
                    )
                  : cloneFoodEntry(weightSource))
              ..amount = sourceAmount
              ..servingSizeGrams = weight!)
          : widget.food;
      _scaledFood = rescaleFoodAmount(foodAtWeight, amount);
    });
  }

  bool get _servingWeightOverridden {
    final weight = _parseNumber(_servingWeightController.text);
    if (!_canEditServingWeight || weight == null || !weight.isFinite) {
      return false;
    }
    if (!_baselineGramsKnown) {
      return widget.gramsKnown ||
          _servingWeightController.text.trim().isNotEmpty;
    }
    return (weight - _baselineFood.servingSizeGrams).abs() > 0.000001;
  }

  void _resetServingWeight() {
    _servingWeightController.text = _formatNumber(
      _baselineFood.servingSizeGrams,
    );
    _servingWeightController.selection = TextSelection.collapsed(
      offset: _servingWeightController.text.length,
    );
    _updateAmount();
  }

  void _changeAmount(double delta) {
    final current = _scaledFood?.amount ?? widget.food.amount;
    final next = current + delta;
    if (!next.isFinite || next <= 0) return;
    _amountController.text = _formatNumber(next);
    _amountController.selection = TextSelection.collapsed(
      offset: _amountController.text.length,
    );
    _updateAmount(_amountController.text);
  }

  void _changeServingWeight(double delta) {
    final current = _parseNumber(_servingWeightController.text);
    if (current == null || !current.isFinite) return;
    final next = current + delta;
    if (!next.isFinite || next <= 0) return;
    _servingWeightController.text = _formatNumber(next);
    _servingWeightController.selection = TextSelection.collapsed(
      offset: _servingWeightController.text.length,
    );
    _updateAmount(_servingWeightController.text);
  }

  String _servingDescription(AppLocalizations l10n, FoodEntry food) {
    final portionReference = widget.food.portionReference?.trim();
    if (!widget.gramsKnown && !_servingWeightOverridden) {
      return portionReference == null || portionReference.isEmpty
          ? l10n.serving_amount(1)
          : portionReference;
    }
    final servingWeight = l10n.grams_per_serving(
      _formatNumber(food.servingSizeGrams),
    );
    if (portionReference != null &&
        portionReference.isNotEmpty &&
        food.servingSizeGrams == widget.food.servingSizeGrams) {
      return '$portionReference · $servingWeight';
    }
    return servingWeight;
  }

  String _amountUnit(AppLocalizations l10n, double amount) {
    final unit = widget.food.unit.trim();
    return unit.isEmpty || unit.toLowerCase() == 'serving'
        ? l10n.food_quantity_serving_unit(amount)
        : unit;
  }

  bool get _isLibraryBaseline => _baselineFood.templateId?.isNotEmpty == true;

  String _resetLabel(AppLocalizations l10n) {
    final weight = _formatNumber(_baselineFood.servingSizeGrams);
    return _isLibraryBaseline
        ? l10n.food_quantity_use_library_weight(weight)
        : l10n.food_quantity_use_default_weight(weight);
  }

  String? _foodImageUrl() {
    for (final key in [
      'image_front_small_url',
      'image_front_url',
      'image_url',
      'imageUrl',
    ]) {
      final value = widget.food.originalValues[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final embedded = widget.onConfirmed != null;
    final food = _scaledFood ?? widget.food;
    final amount = food.amount;
    final servingWeight = _parseNumber(_servingWeightController.text);
    final servingWeightKnown =
        servingWeight != null && servingWeight.isFinite && servingWeight > 0;
    final unavailable = widget.food.nutrition.unavailableNutrients;
    final caloriesKnown =
        widget.caloriesKnown && !unavailable.contains('energyKcal');
    final nutritionUnavailable =
        !caloriesKnown ||
        const {'protein', 'carbs', 'fat'}.any(unavailable.contains);
    final brand = widget.food.brandName?.trim();
    final portionReference = widget.food.portionReference?.trim();
    final servingSubtitle = _canEditServingWeight
        ? portionReference
        : _servingDescription(l10n, food);
    final imageUrl = _foodImageUrl();
    final subtitle = [
      if (brand != null && brand.isNotEmpty) brand,
      if (servingSubtitle != null && servingSubtitle.isNotEmpty)
        servingSubtitle,
    ].join(' · ');
    final totalGrams = food.servingSizeGrams * amount;
    final currentGramsKnown =
        (widget.gramsKnown || (_canEditServingWeight && servingWeightKnown)) &&
        totalGrams.isFinite &&
        totalGrams > 0;
    final nutritionHeading = l10n.food_quantity_nutrition_for_amount(
      currentGramsKnown ? _formatNumber(totalGrams) : _formatNumber(amount),
      currentGramsKnown ? 'g' : _amountUnit(l10n, amount),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 +
            (widget.onConfirmed == null
                ? MediaQuery.viewInsetsOf(context).bottom
                : 0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (embedded) ...[
                    Row(
                      children: [
                        IconButton(
                          key: const ValueKey('food-quantity-back'),
                          onPressed: widget.onClose,
                          tooltip: l10n.back,
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l10n.food_quantity_edit_amount,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: imageUrl == null
                            ? _FoodImageFallback(
                                theme: theme,
                                semanticLabel: widget.food.name,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  semanticLabel: widget.food.name,
                                  errorBuilder: (_, _, _) => _FoodImageFallback(
                                    theme: theme,
                                    semanticLabel: widget.food.name,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.food.name,
                              style: theme.textTheme.headlineSmall,
                            ),
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!embedded)
                        IconButton(
                          onPressed:
                              widget.onClose ?? () => Navigator.pop(context),
                          tooltip: l10n.close,
                          icon: const Icon(Icons.close),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.food_quantity_amount,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: amount > 1
                                    ? () => _changeAmount(-1)
                                    : null,
                                tooltip: l10n.food_selection_decrement(
                                  widget.food.name,
                                ),
                                icon: const Icon(Icons.remove),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp('[0-9.,]'),
                                    ),
                                  ],
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    suffixText: _amountUnit(l10n, amount),
                                  ),
                                  onChanged: _updateAmount,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _changeAmount(1),
                                tooltip: l10n.food_selection_increment(
                                  widget.food.name,
                                ),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_canEditServingWeight) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.food_quantity_weight_per_serving,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed:
                                      servingWeightKnown && servingWeight > 1
                                      ? () => _changeServingWeight(-1)
                                      : null,
                                  tooltip: l10n.food_quantity_decrease_weight,
                                  icon: const Icon(Icons.remove),
                                ),
                                Expanded(
                                  child: Semantics(
                                    label:
                                        l10n.food_quantity_weight_per_serving,
                                    child: TextField(
                                      key: const ValueKey(
                                        'food-quantity-weight-field',
                                      ),
                                      controller: _servingWeightController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp('[0-9.,]'),
                                        ),
                                      ],
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        suffixText: 'g',
                                      ),
                                      onChanged: _updateAmount,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: servingWeightKnown
                                      ? () => _changeServingWeight(1)
                                      : null,
                                  tooltip: l10n.food_quantity_increase_weight,
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_scaledFood != null &&
                        amount > 1 &&
                        servingWeightKnown) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.food_quantity_total_weight(
                          _formatNumber(_scaledFood!.servingSizeGrams * amount),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (_servingWeightOverridden &&
                        _baselineGramsKnown &&
                        _baselineFood.servingSizeGrams.isFinite &&
                        _baselineFood.servingSizeGrams > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _resetServingWeight,
                          child: Text(_resetLabel(l10n)),
                        ),
                      ),
                  ],
                  if (_scaledFood == null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.food_quantity_invalid_amount,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                nutritionHeading,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              caloriesKnown
                                  ? l10n.kcal_value(
                                      food.nutrition.energyKcal.toStringAsFixed(
                                        0,
                                      ),
                                    )
                                  : '— kcal',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _NutrientGrid(
                          nutrients: [
                            (
                              l10n.food_quantity_protein,
                              unavailable.contains('protein')
                                  ? '—'
                                  : '${food.nutrition.protein.toStringAsFixed(1)} g',
                            ),
                            (
                              l10n.food_quantity_carbs,
                              unavailable.contains('carbs')
                                  ? '—'
                                  : '${food.nutrition.carbs.toStringAsFixed(1)} g',
                            ),
                            (
                              l10n.food_quantity_fat,
                              unavailable.contains('fat')
                                  ? '—'
                                  : '${food.nutrition.fat.toStringAsFixed(1)} g',
                            ),
                          ],
                        ),
                        if (nutritionUnavailable) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.food_quantity_nutrition_unavailable,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _scaledFood == null
                  ? null
                  : () {
                      final result = _scaledFood!;
                      if (widget.onConfirmed case final callback?) {
                        callback(result);
                      } else {
                        Navigator.pop(context, result);
                      }
                    },
              child: Text(switch (widget.action) {
                FoodQuantityAction.addToSelection =>
                  l10n.food_quantity_add_to_selection,
                FoodQuantityAction.addMealToSelection =>
                  widget.mealLabel == null
                      ? l10n.add_food
                      : l10n.food_quantity_add_to_meal(widget.mealLabel!),
                FoodQuantityAction.addToMeal =>
                  widget.mealLabel == null
                      ? l10n.add_food
                      : l10n.food_quantity_add_to_meal(widget.mealLabel!),
                FoodQuantityAction.update => l10n.update,
                FoodQuantityAction.updateSelection =>
                  l10n.food_quantity_update_selection,
                FoodQuantityAction.existingMeal => l10n.update,
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class const _FoodImageFallback({
  required final ThemeData theme,
  required final String semanticLabel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      Icons.restaurant_outlined,
      color: theme.colorScheme.onSurfaceVariant,
      semanticLabel: semanticLabel,
    ),
  );
}

class const _NutrientGrid({required final List<(String, String)> nutrients})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
      final columns = largeText
          ? 1
          : constraints.maxWidth < 260
          ? 2
          : 3;
      const spacing = 12.0;
      final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: 8,
        children: [
          for (final nutrient in nutrients)
            SizedBox(
              width: width,
              child: _NutrientValue(label: nutrient.$1, value: nutrient.$2),
            ),
        ],
      );
    },
  );
}

class const _NutrientValue({
  required final String label,
  required final String value,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    excludeSemantics: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
