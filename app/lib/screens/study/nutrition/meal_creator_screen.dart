import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_save_button.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart' as snapshots;
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_app/widgets/unsaved_changes_dialog.dart';
import 'package:studyu_core/core.dart';
import 'package:uuid/uuid.dart';

class const MealCreatorScreen({
  final FoodEntry? existingMeal,
  final List<FoodEntry> initialFoods = const [],
  final String? initialName,
  final bool showCurrentDayPropagationOption = false,
  final bool showCurrentMealOnlyNotice = false,
  final bool showServings = true,
  final bool editLoggedAmount = false,
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
    bool showServings = true,
    bool editLoggedAmount = false,
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
      showServings: showServings,
      editLoggedAmount: editLoggedAmount,
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
  bool _isSaving = false;
  String? _newFoodId;
  String? _copyFoodId;
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
        final recipe = widget.editLoggedAmount
            ? snapshots.normalizeNutritionFoodDefinition(meal)
            : meal;
        final flattened = snapshots.flattenNutritionFoodEntries([recipe]);
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
    if (result != null && mounted) {
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
    final amount = parseNutritionAmount(_quickAmountController.text);
    final caloriesText = _quickCaloriesController.text.trim();
    final calories = parseNutritionAmount(caloriesText);
    final l10n = AppLocalizations.of(context)!;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.enter_food_name)));
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.food_quantity_invalid_amount)),
      );
      return;
    }
    if (caloriesText.isNotEmpty && calories == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.nutrition_invalid_calories)));
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
        energyKcal: calories ?? 0,
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
          if (calories == null) 'energyKcal',
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

  void _updateFoodAmount(int index, double amount) {
    setState(() {
      _foods[index].amount = amount;
      _cachedNutrition = null;
    });
  }

  double get _ingredientServings {
    if (widget.editLoggedAmount) return 1;
    final servings = parseNutritionAmount(_servingsController.text);
    return servings != null && servings > 0 ? servings : 1;
  }

  NutritionProfile _calculateTotalNutrition() {
    return scaleNutritionProfile(
      sumNutritionProfiles([
        for (var index = 0; index < _componentFoods.length; index++)
          scaleNutritionProfile(
            _componentFoods[index].nutrition,
            _foods[index].amount / _componentFoods[index].amount,
          ),
      ]),
      1 / _ingredientServings,
    );
  }

  double _calculateServingSizeGrams() {
    if (_componentFoods.any((food) => food.servingSizeGrams <= 0)) return 0;
    final totalGrams = [
      for (var index = 0; index < _componentFoods.length; index++)
        _componentFoods[index].servingSizeGrams * _foods[index].amount,
    ].fold<double>(0, (total, grams) => total + grams);
    return totalGrams / _ingredientServings;
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
    final rawWeightInput = _rawWeightController.text.trim();
    final cookedWeightInput = _cookedWeightController.text.trim();
    final preparationMethod = _preparationMethodController.text.trim();
    final preparationInputs = [
      rawWeightInput,
      cookedWeightInput,
      preparationMethod,
    ];
    if (preparationInputs.any((input) => input.isNotEmpty)) {
      final l10n = AppLocalizations.of(context)!;
      if (preparationInputs.any((input) => input.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.nutrition_preparation_details_subtitle} (${l10n.required_error})',
            ),
          ),
        );
        return null;
      }

      final rawWeight = parseNutritionAmount(rawWeightInput);
      final cookedWeight = parseNutritionAmount(cookedWeightInput);
      if (rawWeight == null ||
          rawWeight <= 0 ||
          cookedWeight == null ||
          cookedWeight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.food_quantity_invalid_amount)),
        );
        return null;
      }
      preparationDetails = PreparationDetails(
        rawWeight: rawWeight,
        cookedWeight: cookedWeight,
        yieldFactor: cookedWeight / rawWeight,
        preparationMethod: preparationMethod,
        retentionFactors: {...?_preparationDetails?.retentionFactors},
      );
    }

    final existing = widget.existingMeal;
    final servings = parseNutritionAmount(_servingsController.text)!;
    final components = [
      for (var index = 0; index < _foods.length; index++)
        FoodComposition(
          id: _foods[index].id,
          parentEntryId: '',
          foodId: _foods[index].foodId,
          amount: _foods[index].amount / _ingredientServings,
          unit: _foods[index].unit,
          sortOrder: index,
        ),
    ];
    final snapshots = [
      for (var index = 0; index < _componentFoods.length; index++)
        rescaleFoodAmount(
          _componentFoods[index],
          _foods[index].amount / _ingredientServings,
        ),
    ];
    final meal = existing == null
        ? FoodEntry.withId(
            foodId: _newFoodId ??= const Uuid().v4(),
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
    if (_isSaving) return;
    Offset? saveSource;
    final saveContext = _saveButtonKey.currentContext;
    if (widget.existingMeal == null && saveContext != null) {
      saveSource = globalCenter(saveContext);
    }
    final meal = _buildMeal();
    if (meal != null) {
      setState(() => _isSaving = true);
      if (widget.existingMeal == null && widget.onSavedToSelection == null) {
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
            ..foodVersionId = normalized.foodVersionId
            ..componentFoods = normalized.componentFoods
            ..componentSnapshots = normalized.componentSnapshots
            ..amount = servings;
        } catch (error, stackTrace) {
          StudyULogger.error(
            'Failed to save meal to My items: $error\n$stackTrace',
          );
          if (mounted) {
            setState(() => _isSaving = false);
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
      if (route?.isCurrent != true) return;
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
    if (_isSaving) return;
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

    if (result != null && mounted && !_isSaving) {
      setState(() => _isSaving = true);
      try {
        final viewModel =
            widget.templateViewModel ??
            Provider.of<TemplateViewModel?>(context, listen: false) ??
            TemplateViewModel(userId: userId);
        final copy =
            duplicateFoodEntry(snapshots.normalizeNutritionFoodDefinition(meal))
              ..foodId = _copyFoodId ??= const Uuid().v4()
              ..foodVersionId = const Uuid().v4()
              ..templateId = null;
        await viewModel.saveFoodAsTemplate(
          name: result.name,
          food: copy,
          tags: result.tags,
        );
        _copyFoodId = null;
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
      } finally {
        if (mounted) setState(() => _isSaving = false);
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
    final servingsCount = parseNutritionAmount(_servingsController.text) ?? 1;

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingMeal == null
              ? l10n.create_meal
              : l10n.nutrition_edit_saved_meal,
        ),
        actions: [
          if (_foods.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: l10n.create_meal,
              onPressed: _isSaving ? null : _saveAsTemplate,
            ),
        ],
      ),
      floatingActionButton: canSave
          ? NutritionSaveButton(
              key: _saveButtonKey,
              onPressed: _isSaving ? null : _saveMeal,
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
              servingsController: widget.showServings
                  ? _servingsController
                  : null,
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
                  onUpdateAmount: (amount) => _updateFoodAmount(index, amount),
                );
              }),

            const SizedBox(height: 16),

            // ========== NUTRITION SUMMARY ==========
            if (nutrition != null)
              NutritionSummaryCard(
                nutrition: nutrition,
                title: l10n.nutrition_per_serving,
                subtitle: widget.showServings
                    ? l10n.serving_amount(servingsCount)
                    : null,
              ),

            const SizedBox(height: NutritionSaveButton.scrollClearance),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _isSaving) return;
        if (_hasUnsavedChanges) {
          _confirmDiscard();
        } else {
          _pop();
        }
      },
      child: AbsorbPointer(absorbing: _isSaving, child: scaffold),
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

class const _MealInfoCard({
  required final TextEditingController nameController,
  required final TextEditingController descriptionController,
  final TextEditingController? servingsController,
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
                if (servingsController != null) ...[
                  Expanded(
                    child: TextFormField(
                      controller: servingsController,
                      decoration: InputDecoration(
                        labelText: l10n.nutrition_servings_required,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.people_outline),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final servings = parseNutritionAmount(value ?? '');
                        if (servings == null || servings <= 0) {
                          return l10n.food_quantity_invalid_amount;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Text(
          l10n.nutrition_ingredients_section(foodCount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
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
                  Flexible(child: Text(l10n.nutrition_add_food_ingredient)),
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
  required final ValueChanged<double> onUpdateAmount,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final icon = food.entryType == FoodEntryType.meal
        ? Icons.restaurant_menu_outlined
        : Icons.restaurant_outlined;
    final imageUrl = foodImageUrl(food);
    final energy = food.nutrition.energyKcal * composition.amount / food.amount;

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
          '${composition.amount} ${composition.unit} • ${food.nutrition.isKnown('energyKcal') ? l10n.kcal_value(energy.toStringAsFixed(0)) : '— kcal'}${food.nutrition.isPartial('energyKcal') ? ' (${l10n.nutrition_partial})' : ''}',
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
                suffixText: composition.unit,
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
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
              final amount = parseNutritionAmount(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.food_quantity_invalid_amount)),
                );
                return;
              }
              onUpdateAmount(amount);
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
