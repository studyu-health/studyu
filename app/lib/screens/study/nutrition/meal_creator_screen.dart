import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart' as snapshots;
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_app/widgets/unsaved_changes_dialog.dart';
import 'package:studyu_core/core.dart';

class const MealCreatorScreen({
  final FoodEntry? existingMeal,
  final List<FoodEntry> initialFoods = const [],
  final String? initialName,
  final bool showCurrentDayPropagationOption = false,
  final bool showCurrentMealOnlyNotice = false,
  final bool showExpansionNotice = false,
  final ValueChanged<bool>? onCurrentDayPropagationChanged,
  final TemplateViewModel? templateViewModel,
  final void Function(FoodEntry food, Offset? source)? onSavedToSelection,
  super.key,
}) extends StatefulWidget {
  static MaterialPageRoute<FoodEntry> route({
    FoodEntry? existingMeal,
    List<FoodEntry> initialFoods = const [],
    String? initialName,
    bool showCurrentDayPropagationOption = false,
    bool showCurrentMealOnlyNotice = false,
    bool showExpansionNotice = false,
    ValueChanged<bool>? onCurrentDayPropagationChanged,
    TemplateViewModel? templateViewModel,
    void Function(FoodEntry food, Offset? source)? onSavedToSelection,
  }) => MaterialPageRoute(
    builder: (_) => MealCreatorScreen(
      existingMeal: existingMeal,
      initialFoods: initialFoods,
      initialName: initialName,
      showCurrentDayPropagationOption: showCurrentDayPropagationOption,
      showCurrentMealOnlyNotice: showCurrentMealOnlyNotice,
      showExpansionNotice: showExpansionNotice,
      onCurrentDayPropagationChanged: onCurrentDayPropagationChanged,
      templateViewModel: templateViewModel,
      onSavedToSelection: onSavedToSelection,
    ),
  );

  @override
  State<MealCreatorScreen> createState() => _MealCreatorScreenState();
}

class _MealCreatorScreenState() extends State<MealCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _servingsController;

  // Meal metadata controllers
  late TextEditingController _rawWeightController;
  late TextEditingController _cookedWeightController;
  late TextEditingController _preparationMethodController;

  // Quick Add controllers
  late TextEditingController _quickNameController;
  late TextEditingController _quickAmountController;
  late TextEditingController _quickCaloriesController;
  bool _showQuickAdd = false;
  bool _updateCurrentDayEntries = false;
  bool _invalidComponents = false;

  List<FoodComposition> _foods = [];
  final List<FoodEntry> _componentFoods = [];
  PreparationDetails? _preparationDetails;
  NutritionProfile? _cachedNutrition;
  late final String _initialSnapshot;
  bool _allowPop = false;
  final GlobalKey _saveButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.existingMeal != null) {
      final meal = widget.existingMeal!;
      _nameController = TextEditingController(text: meal.name);
      _descriptionController = TextEditingController(
        text: meal.description ?? '',
      );
      _servingsController = TextEditingController(text: meal.amount.toString());

      if (meal.preparationDetails != null) {
        _preparationDetails = meal.preparationDetails;
        _rawWeightController = TextEditingController(
          text: _preparationDetails!.rawWeight.toString(),
        );
        _cookedWeightController = TextEditingController(
          text: _preparationDetails!.cookedWeight.toString(),
        );
        _preparationMethodController = TextEditingController(
          text: _preparationDetails!.preparationMethod,
        );
      } else {
        _rawWeightController = TextEditingController();
        _cookedWeightController = TextEditingController();
        _preparationMethodController = TextEditingController();
      }

      try {
        final flattened = snapshots.flattenNutritionFoodEntries([meal]);
        _componentFoods.addAll(flattened);
        _foods = [
          for (var index = 0; index < flattened.length; index++)
            FoodComposition.withId(
              parentEntryId: '',
              foodId: flattened[index].foodId,
              amount: flattened[index].amount,
              unit: flattened[index].unit,
              sortOrder: index,
            ),
        ];
      } catch (_) {
        _invalidComponents = true;
      }
    } else {
      _nameController = TextEditingController(text: widget.initialName ?? '');
      _descriptionController = TextEditingController();
      _servingsController = TextEditingController(text: '1');
      _rawWeightController = TextEditingController();
      _cookedWeightController = TextEditingController();
      _preparationMethodController = TextEditingController();
      try {
        final flattened = snapshots.flattenNutritionFoodEntries(
          widget.initialFoods,
        );
        _componentFoods.addAll(flattened);
        _foods = [
          for (var index = 0; index < flattened.length; index++)
            FoodComposition.withId(
              parentEntryId: '',
              foodId: flattened[index].foodId,
              amount: flattened[index].amount,
              unit: flattened[index].unit,
              sortOrder: index,
            ),
        ];
      } catch (_) {
        _invalidComponents = true;
      }
    }

    // Initialize Quick Add controllers
    _quickNameController = TextEditingController();
    _quickAmountController = TextEditingController(text: '1');
    _quickCaloriesController = TextEditingController();
    _initialSnapshot = _snapshot;

    _servingsController.addListener(() {
      setState(() {
        _cachedNutrition = null;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _rawWeightController.dispose();
    _cookedWeightController.dispose();
    _preparationMethodController.dispose();
    _quickNameController.dispose();
    _quickAmountController.dispose();
    _quickCaloriesController.dispose();
    super.dispose();
  }

  Future<void> _addFood() async {
    final result = await Navigator.of(context).push(
      FoodSearchScreen.route(
        allowMeals: false,
        templateViewModel:
            widget.templateViewModel ??
            Provider.of<TemplateViewModel?>(context, listen: false),
      ),
    );
    if (result != null) {
      setState(() {
        _invalidComponents = false;
        _componentFoods.add(result);
        _foods.add(
          FoodComposition.withId(
            parentEntryId: '',
            foodId: result.foodId,
            amount: result.amount,
            unit: result.unit,
            sortOrder: _foods.length,
          ),
        );
        _cachedNutrition = null;
      });
    }
  }

  void _quickAddFood() {
    final name = _quickNameController.text.trim();
    final amount = double.tryParse(_quickAmountController.text) ?? 1;
    final calories = double.tryParse(_quickCaloriesController.text) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enter_food_name)),
      );
      return;
    }

    final quickFood = FoodEntry.withId(
      entryType: FoodEntryType.manualCustom,
      name: name,
      amount: amount,
      unit: 'serving',
      servingSizeGrams: 100,
      portionEstimationMethod: PortionEstimationMethod.householdMeasure,
      portionState: PortionState.asServed,
      nutrition: NutritionProfile(
        energyKcal: calories,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugars: 0,
        fiber: 0,
        saturatedFat: 0,
        transFat: 0,
        cholesterol: 0,
        sodium: 0,
        waterContent: 0,
        micros: {},
        unavailableNutrients: {
          ...NutritionProfile.nutrientKeys.where((key) => key != 'energyKcal'),
          if (double.tryParse(_quickCaloriesController.text) == null)
            'energyKcal',
        },
      ),
      source: FoodSource.manual,
      confidenceScore: 0.5,
      originalValues: {},
    );

    setState(() {
      _invalidComponents = false;
      _componentFoods.add(quickFood);
      _foods.add(
        FoodComposition.withId(
          parentEntryId: '',
          foodId: quickFood.foodId,
          amount: amount,
          unit: 'serving',
          sortOrder: _foods.length,
        ),
      );
      _cachedNutrition = null;

      // Clear quick add fields but keep form open for rapid entry
      _quickNameController.clear();
      _quickAmountController.text = '1';
      _quickCaloriesController.clear();
    });
  }

  void _removeFood(int index) {
    setState(() {
      _foods.removeAt(index);
      _componentFoods.removeAt(index);
      _cachedNutrition = null;
    });
  }

  void _updateFoodAmount(int index, double amount, String unit) {
    setState(() {
      _foods[index] = FoodComposition(
        id: _foods[index].id,
        parentEntryId: _foods[index].parentEntryId,
        foodId: _foods[index].foodId,
        amount: amount,
        unit: unit,
        sortOrder: _foods[index].sortOrder,
      );
      _cachedNutrition = null;
    });
  }

  NutritionProfile _calculateTotalNutrition() {
    final servings = double.tryParse(_servingsController.text) ?? 1;
    return scaleNutritionProfile(
      sumNutritionProfiles([
        for (var index = 0; index < _componentFoods.length; index++)
          scaleNutritionProfile(
            _componentFoods[index].nutrition,
            _foods[index].amount / _componentFoods[index].amount,
          ),
      ]),
      1 / servings,
    );
  }

  double _calculateServingSizeGrams() {
    final totalGrams = [
      for (var index = 0; index < _componentFoods.length; index++)
        _componentFoods[index].servingSizeGrams * _foods[index].amount,
    ].fold<double>(0, (total, grams) => total + grams);
    final servings = double.parse(_servingsController.text);
    return totalGrams / servings;
  }

  FoodEntry? _buildMeal() {
    if (_invalidComponents) {
      return null;
    }
    if (!_formKey.currentState!.validate() || _foods.isEmpty) {
      return null;
    }

    final nutrition = _calculateTotalNutrition();
    final servingSizeGrams = _calculateServingSizeGrams();

    PreparationDetails? preparationDetails;
    if (_rawWeightController.text.isNotEmpty &&
        _cookedWeightController.text.isNotEmpty &&
        _preparationMethodController.text.isNotEmpty) {
      final rawWeight = double.parse(_rawWeightController.text);
      final cookedWeight = double.parse(_cookedWeightController.text);
      preparationDetails = PreparationDetails(
        rawWeight: rawWeight,
        cookedWeight: cookedWeight,
        yieldFactor: cookedWeight / rawWeight,
        preparationMethod: _preparationMethodController.text,
        retentionFactors: {},
      );
    }

    final existing = widget.existingMeal;
    final servings = double.parse(_servingsController.text);
    final components = [
      for (var index = 0; index < _foods.length; index++)
        FoodComposition(
          id: _foods[index].id,
          parentEntryId: '',
          foodId: _foods[index].foodId,
          amount: _foods[index].amount / servings,
          unit: _foods[index].unit,
          sortOrder: index,
        ),
    ];
    final snapshots = [
      for (var index = 0; index < _componentFoods.length; index++)
        rescaleFoodAmount(
          _componentFoods[index],
          _foods[index].amount / servings,
        ),
    ];
    final meal = existing == null
        ? FoodEntry.withId(
            entryType: FoodEntryType.meal,
            name: _nameController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            amount: 1,
            unit: 'serving',
            servingSizeGrams: servingSizeGrams,
            portionEstimationMethod: PortionEstimationMethod.householdMeasure,
            portionState: PortionState.cooked,
            nutrition: nutrition,
            source: FoodSource.manual,
            confidenceScore: 0.9,
            originalValues: {},
            preparationDetails: preparationDetails,
            componentFoods: components,
            componentSnapshots: snapshots,
          )
        : FoodEntry(
            id: existing.id,
            availabilityVerified: existing.availabilityVerified,
            foodId: existing.foodId,
            foodVersionId: existing.foodVersionId,
            entryType: FoodEntryType.meal,
            name: _nameController.text,
            brandName: existing.brandName,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            amount: 1,
            unit: existing.unit,
            servingSizeGrams: servingSizeGrams,
            portionReference: existing.portionReference,
            portionEstimationMethod: existing.portionEstimationMethod,
            portionState: existing.portionState,
            yieldFactor: existing.yieldFactor,
            ediblePortion: existing.ediblePortion,
            nutrition: nutrition,
            foodCode: existing.foodCode,
            externalId: existing.externalId,
            source: existing.source,
            confidenceScore: existing.confidenceScore,
            templateId: existing.templateId,
            createdAt: existing.createdAt,
            modifiedAt: DateTime.now(),
            originalValues: existing.originalValues,
            parentEntryId: existing.parentEntryId,
            preparationDetails: preparationDetails,
            componentFoods: components,
            componentSnapshots: snapshots,
          );
    for (final composition in meal.componentFoods!) {
      composition.parentEntryId = meal.id;
    }
    return rescaleFoodAmount(meal, servings);
  }

  Future<void> _saveMeal() async {
    Offset? saveSource;
    final saveContext = _saveButtonKey.currentContext;
    if (widget.existingMeal == null && saveContext != null) {
      saveSource = globalCenter(saveContext);
    }
    final meal = _buildMeal();
    if (meal != null) {
      if (widget.existingMeal == null) {
        final appState = Provider.of<AppState>(context, listen: false);
        try {
          final viewModel =
              widget.templateViewModel ??
              Provider.of<TemplateViewModel?>(context, listen: false) ??
              TemplateViewModel(
                userId: appState.activeSubject?.id ?? 'anonymous',
              );
          final normalized = snapshots.normalizeNutritionFoodDefinition(meal);
          final servings = meal.amount;
          meal.templateId = await viewModel.saveFoodAsTemplate(
            name: meal.name,
            food: normalized,
          );
          meal
            ..componentFoods = normalized.componentFoods
            ..componentSnapshots = normalized.componentSnapshots
            ..amount = servings;
        } catch (error, stackTrace) {
          StudyULogger.error(
            'Failed to save meal to My items: $error\n$stackTrace',
          );
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.could_not_save_results)),
            );
          }
          return;
        }
      }
      if (mounted) {
        final onSavedToSelection =
            widget.existingMeal == null && widget.onSavedToSelection != null
            ? () => widget.onSavedToSelection!(meal, saveSource)
            : null;
        _pop(meal, onSavedToSelection);
      }
    } else if (_invalidComponents || _foods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _invalidComponents
                ? AppLocalizations.of(context)!.nutrition_invalid_saved_meal
                : AppLocalizations.of(context)!.nutrition_add_food_ingredient,
          ),
        ),
      );
    }
  }

  void _pop([FoodEntry? result, VoidCallback? afterPop]) {
    setState(() => _allowPop = true);
    final route = ModalRoute.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(result);
      if (afterPop == null) return;
      final completed = route?.completed;
      if (completed == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => afterPop());
      } else {
        completed.then((_) => afterPop());
      }
    });
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showUnsavedChangesDialog(
      context,
      title: l10n.unsaved_changes_title,
      message: l10n.unsaved_changes_message,
      discardLabel: l10n.discard_changes,
      continueLabel: l10n.continue_editing,
    );
    if (!mounted) return;

    switch (action) {
      case UnsavedChangesAction.discard:
        _pop();
      case null:
        return;
    }
  }

  String get _snapshot => jsonEncode({
    'name': _nameController.text,
    'description': _descriptionController.text,
    'servings': _servingsController.text,
    'rawWeight': _rawWeightController.text,
    'cookedWeight': _cookedWeightController.text,
    'preparationMethod': _preparationMethodController.text,
    'quickName': _quickNameController.text,
    'quickAmount': _quickAmountController.text,
    'quickCalories': _quickCaloriesController.text,
    'foodIds': [for (final food in _componentFoods) food.id],
    'compositions': [
      for (final food in _foods)
        {
          'id': food.id,
          'foodId': food.foodId,
          'amount': food.amount,
          'unit': food.unit,
          'sortOrder': food.sortOrder,
        },
    ],
  });

  bool get _hasUnsavedChanges => _snapshot != _initialSnapshot;

  Future<void> _saveAsTemplate() async {
    final meal = _buildMeal();
    if (meal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _invalidComponents
                ? AppLocalizations.of(context)!.nutrition_invalid_saved_meal
                : AppLocalizations.of(context)!.nutrition_add_food_ingredient,
          ),
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final result = await SaveTemplateDialog.show(
      context,
      initialName: _nameController.text,
      templateType: TemplateType.meal,
    );

    if (result != null && mounted) {
      try {
        final viewModel =
            widget.templateViewModel ??
            Provider.of<TemplateViewModel?>(context, listen: false) ??
            TemplateViewModel(userId: userId);
        await viewModel.saveFoodAsTemplate(
          name: result.name,
          food: snapshots.normalizeNutritionFoodDefinition(meal),
          tags: result.tags,
        );
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.template_saved)));
        }
      } catch (error, stackTrace) {
        StudyULogger.error('Failed to save meal template: $error\n$stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.could_not_save_results)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_foods.isNotEmpty && _cachedNutrition == null) {
      _cachedNutrition = _calculateTotalNutrition();
    }
    final nutrition = _cachedNutrition;

    final l10n = AppLocalizations.of(context)!;
    final canSave =
        !_invalidComponents &&
        _nameController.text.isNotEmpty &&
        _foods.isNotEmpty;
    final servingsCount = (double.tryParse(_servingsController.text) ?? 1)
        .toInt();

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingMeal == null
              ? l10n.nutrition_create_saved_meal
              : l10n.nutrition_edit_saved_meal,
        ),
        actions: [
          if (_foods.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: l10n.nutrition_create_saved_meal,
              onPressed: _saveAsTemplate,
            ),
        ],
      ),
      floatingActionButton: canSave
          ? FloatingActionButton.extended(
              key: _saveButtonKey,
              onPressed: _saveMeal,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: const Icon(Icons.check),
              label: Text(l10n.save),
            )
          : null,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.showCurrentMealOnlyNotice &&
                widget.existingMeal != null) ...[
              Card(
                color: theme.colorScheme.secondaryContainer,
                child: ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  title: Text(
                    l10n.current_meal_only_banner,
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ========== MEAL DETAILS ==========
            _MealInfoCard(
              nameController: _nameController,
              descriptionController: _descriptionController,
              servingsController: _servingsController,
              theme: theme,
              l10n: l10n,
            ),

            if (widget.onCurrentDayPropagationChanged != null) ...[
              Text(
                l10n.food_definition_edit_helper,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (widget.showCurrentDayPropagationOption)
              CheckboxListTile(
                value: _updateCurrentDayEntries,
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.update_current_day_entries),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  final selected = value ?? false;
                  setState(() => _updateCurrentDayEntries = selected);
                  widget.onCurrentDayPropagationChanged?.call(selected);
                },
              ),

            const SizedBox(height: 12),

            // ========== METADATA (Collapsible) ==========
            _PreparationDetailsCard(
              rawWeightController: _rawWeightController,
              cookedWeightController: _cookedWeightController,
              preparationMethodController: _preparationMethodController,
            ),

            const SizedBox(height: 16),

            if (widget.showExpansionNotice)
              Card(
                color: theme.colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.nutrition_saved_meals_expanded_notice),
                ),
              ),

            if (_invalidComponents)
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.nutrition_invalid_saved_meal),
                ),
              ),

            // ========== FOODS SECTION ==========
            _FoodsSectionHeader(
              foodCount: _foods.length,
              theme: theme,
              onAddFood: _addFood,
              onToggleQuickAdd: () =>
                  setState(() => _showQuickAdd = !_showQuickAdd),
              showQuickAdd: _showQuickAdd,
            ),

            // ========== QUICK ADD FORM ==========
            if (_showQuickAdd) ...[
              const SizedBox(height: 12),
              _QuickAddForm(
                nameController: _quickNameController,
                amountController: _quickAmountController,
                caloriesController: _quickCaloriesController,
                onAdd: _quickAddFood,
                theme: theme,
              ),
            ],

            const SizedBox(height: 12),

            // ========== FOODS LIST ==========
            if (_foods.isEmpty)
              _EmptyFoodsState(theme: theme)
            else
              ...List.generate(_foods.length, (index) {
                final food = _componentFoods[index];
                final composition = _foods[index];

                return _FoodCard(
                  food: food,
                  composition: composition,
                  theme: theme,
                  onRemove: () => _removeFood(index),
                  onUpdateAmount: (amount, unit) =>
                      _updateFoodAmount(index, amount, unit),
                );
              }),

            const SizedBox(height: 16),

            // ========== NUTRITION SUMMARY ==========
            if (nutrition != null)
              NutritionSummaryCard(
                nutrition: nutrition,
                title: l10n.nutrition_per_serving,
                subtitle: l10n.serving_amount(servingsCount),
              ),

            // Bottom padding for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_hasUnsavedChanges) {
          _confirmDiscard();
        } else {
          _pop();
        }
      },
      child: scaffold,
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

class const _MealInfoCard({
  required final TextEditingController nameController,
  required final TextEditingController descriptionController,
  required final TextEditingController servingsController,
  required final ThemeData theme,
  required final AppLocalizations l10n,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant_menu_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.meal_details,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.template_name_required,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enter_meal_name;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: servingsController,
                    decoration: InputDecoration(
                      labelText: l10n.nutrition_servings_required,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.people_outline),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      final servings = double.tryParse(value ?? '');
                      if (servings == null || servings <= 0) {
                        return l10n.required_error;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      border: const OutlineInputBorder(),
                      hintText: l10n.optional,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class const _PreparationDetailsCard({
  required final TextEditingController rawWeightController,
  required final TextEditingController cookedWeightController,
  required final TextEditingController preparationMethodController,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(Icons.science_outlined, color: Colors.grey.shade600),
        title: Text(l10n.nutrition_preparation_details),
        subtitle: Text(l10n.nutrition_preparation_details_subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: rawWeightController,
                  decoration: InputDecoration(
                    labelText: l10n.nutrition_raw_weight_grams,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: cookedWeightController,
                  decoration: InputDecoration(
                    labelText: l10n.nutrition_cooked_weight_grams,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: preparationMethodController,
            decoration: InputDecoration(
              labelText: l10n.nutrition_preparation_method,
              border: const OutlineInputBorder(),
              hintText: l10n.nutrition_preparation_method_hint,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class const _FoodsSectionHeader({
  required final int foodCount,
  required final ThemeData theme,
  required final VoidCallback onAddFood,
  required final VoidCallback onToggleQuickAdd,
  required final bool showQuickAdd,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.nutrition_ingredients_section(foodCount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            IconButton.outlined(
              onPressed: onToggleQuickAdd,
              icon: Icon(showQuickAdd ? Icons.close : Icons.bolt, size: 18),
              tooltip: l10n.nutrition_add_food_manually,
              style: IconButton.styleFrom(
                minimumSize: const Size(36, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onAddFood,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search, size: 18),
                  const SizedBox(width: 6),
                  Text(l10n.nutrition_add_food_ingredient),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class const _QuickAddForm({
  required final TextEditingController nameController,
  required final TextEditingController amountController,
  required final TextEditingController caloriesController,
  required final VoidCallback onAdd,
  required final ThemeData theme,
}) extends StatefulWidget {
  @override
  State<_QuickAddForm> createState() => _QuickAddFormState();
}

class _QuickAddFormState() extends State<_QuickAddForm> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bolt,
                  color: widget.theme.colorScheme.tertiary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.nutrition_add_food_manually,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.theme.colorScheme.tertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Name field - full width
            TextField(
              controller: widget.nameController,
              decoration: InputDecoration(
                labelText: l10n.food_name,
                hintText: l10n.nutrition_food_name_example,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _submitAndFocusNext(),
            ),
            const SizedBox(height: 8),
            // Amount and Calories - side by side
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.amountController,
                    decoration: InputDecoration(
                      labelText: l10n.nutrition_quantity_short,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _submitAndFocusNext(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: widget.caloriesController,
                    decoration: InputDecoration(
                      labelText: l10n.nutrition_calories_kcal,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => widget.onAdd(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: FilledButton.tonal(
                    onPressed: widget.onAdd,
                    child: Text(l10n.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitAndFocusNext() {
    if (widget.caloriesController.text.isEmpty) {
      FocusScope.of(context).nextFocus();
    } else {
      widget.onAdd();
    }
  }
}

class const _EmptyFoodsState({required final ThemeData theme})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.restaurant_outlined,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.nutrition_no_foods_yet,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.nutrition_search_or_add_food_manually,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class const _FoodCard({
  required final FoodEntry food,
  required final FoodComposition composition,
  required final ThemeData theme,
  required final VoidCallback onRemove,
  required final Function(double amount, String unit) onUpdateAmount,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final icon = food.entryType == FoodEntryType.meal
        ? Icons.restaurant_menu_outlined
        : Icons.restaurant_outlined;
    final imageUrl = foodImageUrl(food);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: ListTile(
        leading: SizedBox(
          width: 44,
          height: 44,
          child: imageUrl == null
              ? fallbackFoodIcon(theme, icon)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                    errorBuilder: (context, error, stackTrace) =>
                        fallbackFoodIcon(theme, icon),
                  ),
                ),
        ),
        title: Text(
          food.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${composition.amount} ${composition.unit} • ${food.nutrition.isKnown('energyKcal') ? l10n.kcal_value(food.nutrition.energyKcal.toStringAsFixed(0)) : '— kcal'}${food.nutrition.isPartial('energyKcal') ? ' (${l10n.nutrition_partial})' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => _showEditDialog(context),
              tooltip: l10n.food_quantity_edit_amount,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: onRemove,
              color: theme.colorScheme.error,
              tooltip: l10n.remove_from_meal,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amountController = TextEditingController(
      text: composition.amount.toString(),
    );
    final unitController = TextEditingController(text: composition.unit);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.edit_food_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: l10n.food_quantity_amount,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: InputDecoration(
                labelText: l10n.nutrition_unit_label,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final amount =
                  double.tryParse(amountController.text) ?? composition.amount;
              onUpdateAmount(amount, unitController.text);
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
