import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_core/core.dart';

class const RecipeBuilderScreen({final FoodEntry? existingRecipe, super.key})
    extends StatefulWidget {
  static MaterialPageRoute<FoodEntry> route({FoodEntry? existingRecipe}) =>
      MaterialPageRoute(
        builder: (_) => RecipeBuilderScreen(existingRecipe: existingRecipe),
      );

  @override
  State<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState() extends State<RecipeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _servingsController;

  // Recipe metadata controllers
  late TextEditingController _rawWeightController;
  late TextEditingController _cookedWeightController;
  late TextEditingController _preparationMethodController;

  // Quick Add controllers
  late TextEditingController _quickNameController;
  late TextEditingController _quickAmountController;
  late TextEditingController _quickCaloriesController;
  bool _showQuickAdd = false;

  List<RecipeComposition> _ingredients = [];
  final List<FoodEntry> _ingredientFoods = [];
  RecipeMetadata? _metadata;
  NutritionProfile? _cachedNutrition;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecipe != null) {
      final recipe = widget.existingRecipe!;
      _nameController = TextEditingController(text: recipe.name);
      _descriptionController = TextEditingController(
        text: recipe.description ?? '',
      );
      _servingsController = TextEditingController(
        text: recipe.amount.toString(),
      );

      if (recipe.recipeMetadata != null) {
        _metadata = recipe.recipeMetadata;
        _rawWeightController = TextEditingController(
          text: _metadata!.rawWeight.toString(),
        );
        _cookedWeightController = TextEditingController(
          text: _metadata!.cookedWeight.toString(),
        );
        _preparationMethodController = TextEditingController(
          text: _metadata!.preparationMethod,
        );
      } else {
        _rawWeightController = TextEditingController();
        _cookedWeightController = TextEditingController();
        _preparationMethodController = TextEditingController();
      }

      _ingredients = recipe.recipeIngredients ?? [];
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _servingsController = TextEditingController(text: '1');
      _rawWeightController = TextEditingController();
      _cookedWeightController = TextEditingController();
      _preparationMethodController = TextEditingController();
    }

    // Initialize Quick Add controllers
    _quickNameController = TextEditingController();
    _quickAmountController = TextEditingController(text: '1');
    _quickCaloriesController = TextEditingController();

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

  Future<void> _addIngredient() async {
    final result = await Navigator.of(context).push(FoodSearchScreen.route());
    if (result != null) {
      setState(() {
        _ingredientFoods.add(result);
        _ingredients.add(
          RecipeComposition.withId(
            recipeId: '',
            ingredientId: result.id,
            amount: result.amount,
            unit: result.unit,
            sortOrder: _ingredients.length,
          ),
        );
        _cachedNutrition = null;
      });
    }
  }

  void _quickAddIngredient() {
    final name = _quickNameController.text.trim();
    final amount = double.tryParse(_quickAmountController.text) ?? 1;
    final calories = double.tryParse(_quickCaloriesController.text) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ingredient name')),
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
      ),
      source: FoodSource.manual,
      confidenceScore: 0.5,
      originalValues: {},
    );

    setState(() {
      _ingredientFoods.add(quickFood);
      _ingredients.add(
        RecipeComposition.withId(
          recipeId: '',
          ingredientId: quickFood.id,
          amount: amount,
          unit: 'serving',
          sortOrder: _ingredients.length,
        ),
      );
      _cachedNutrition = null;

      // Clear quick add fields but keep form open for rapid entry
      _quickNameController.clear();
      _quickAmountController.text = '1';
      _quickCaloriesController.clear();
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      _ingredientFoods.removeAt(index);
      _cachedNutrition = null;
    });
  }

  void _updateIngredientAmount(int index, double amount, String unit) {
    setState(() {
      _ingredients[index] = RecipeComposition(
        id: _ingredients[index].id,
        recipeId: _ingredients[index].recipeId,
        ingredientId: _ingredients[index].ingredientId,
        amount: amount,
        unit: unit,
        sortOrder: _ingredients[index].sortOrder,
      );
      _cachedNutrition = null;
    });
  }

  NutritionProfile _calculateTotalNutrition() {
    double totalEnergy = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalSugars = 0;
    double totalFiber = 0;
    double totalSaturatedFat = 0;
    double totalTransFat = 0;
    double totalCholesterol = 0;
    double totalSodium = 0;
    double totalWater = 0;
    final Map<String, double> totalMicros = {};

    for (int i = 0; i < _ingredientFoods.length; i++) {
      final food = _ingredientFoods[i];
      final composition = _ingredients[i];

      final ratio = composition.amount / food.amount;

      totalEnergy += food.nutrition.energyKcal * ratio;
      totalProtein += food.nutrition.protein * ratio;
      totalCarbs += food.nutrition.carbs * ratio;
      totalFat += food.nutrition.fat * ratio;
      totalSugars += food.nutrition.sugars * ratio;
      totalFiber += food.nutrition.fiber * ratio;
      totalSaturatedFat += food.nutrition.saturatedFat * ratio;
      totalTransFat += food.nutrition.transFat * ratio;
      totalCholesterol += food.nutrition.cholesterol * ratio;
      totalSodium += food.nutrition.sodium * ratio;
      totalWater += food.nutrition.waterContent * ratio;

      food.nutrition.micros.forEach((key, value) {
        totalMicros[key] = (totalMicros[key] ?? 0) + (value * ratio);
      });
    }

    final servings = double.tryParse(_servingsController.text) ?? 1;

    return NutritionProfile(
      energyKcal: totalEnergy / servings,
      protein: totalProtein / servings,
      carbs: totalCarbs / servings,
      fat: totalFat / servings,
      sugars: totalSugars / servings,
      fiber: totalFiber / servings,
      saturatedFat: totalSaturatedFat / servings,
      transFat: totalTransFat / servings,
      cholesterol: totalCholesterol / servings,
      sodium: totalSodium / servings,
      waterContent: totalWater / servings,
      micros: totalMicros,
    );
  }

  FoodEntry? _buildRecipe() {
    if (!_formKey.currentState!.validate() || _ingredients.isEmpty) {
      return null;
    }

    final nutrition = _calculateTotalNutrition();

    RecipeMetadata? metadata;
    if (_rawWeightController.text.isNotEmpty &&
        _cookedWeightController.text.isNotEmpty &&
        _preparationMethodController.text.isNotEmpty) {
      final rawWeight = double.parse(_rawWeightController.text);
      final cookedWeight = double.parse(_cookedWeightController.text);
      metadata = RecipeMetadata(
        rawWeight: rawWeight,
        cookedWeight: cookedWeight,
        yieldFactor: cookedWeight / rawWeight,
        preparationMethod: _preparationMethodController.text,
        retentionFactors: {},
      );
    }

    return FoodEntry.withId(
      entryType: FoodEntryType.recipe,
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      amount: double.parse(_servingsController.text),
      unit: 'serving',
      servingSizeGrams: nutrition.energyKcal * 0.24,
      portionEstimationMethod: PortionEstimationMethod.householdMeasure,
      portionState: PortionState.cooked,
      nutrition: nutrition,
      source: FoodSource.manual,
      confidenceScore: 0.9,
      originalValues: {},
      recipeMetadata: metadata,
      recipeIngredients: _ingredients
          .map(
            (comp) => RecipeComposition(
              id: comp.id,
              recipeId: '',
              ingredientId: comp.ingredientId,
              amount: comp.amount,
              unit: comp.unit,
              sortOrder: comp.sortOrder,
            ),
          )
          .toList(),
    );
  }

  void _saveRecipe() {
    final recipe = _buildRecipe();
    if (recipe != null) {
      Navigator.of(context).pop(recipe);
    } else if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
    }
  }

  Future<void> _saveAsTemplate() async {
    final recipe = _buildRecipe();
    if (recipe == null) {
      if (_ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one ingredient')),
        );
      }
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final result = await SaveTemplateDialog.show(
      context,
      initialName: _nameController.text,
      templateType: TemplateType.recipe,
    );

    if (result != null && mounted) {
      final viewModel = TemplateViewModel(userId: userId);
      await viewModel.saveFoodAsTemplate(
        name: result.name,
        food: recipe,
        tags: result.tags,
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.template_saved)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_ingredients.isNotEmpty && _cachedNutrition == null) {
      _cachedNutrition = _calculateTotalNutrition();
    }
    final nutrition = _cachedNutrition;

    final l10n = AppLocalizations.of(context)!;
    final canSave = _nameController.text.isNotEmpty && _ingredients.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Builder'),
        actions: [
          if (_ingredients.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: l10n.save_as_template,
              onPressed: _saveAsTemplate,
            ),
        ],
      ),
      floatingActionButton: canSave
          ? FloatingActionButton.extended(
              onPressed: _saveRecipe,
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
            // ========== RECIPE BASIC INFO ==========
            _RecipeInfoCard(
              nameController: _nameController,
              descriptionController: _descriptionController,
              servingsController: _servingsController,
              theme: theme,
              l10n: l10n,
            ),

            const SizedBox(height: 12),

            // ========== METADATA (Collapsible) ==========
            _RecipeMetadataCard(
              rawWeightController: _rawWeightController,
              cookedWeightController: _cookedWeightController,
              preparationMethodController: _preparationMethodController,
              theme: theme,
            ),

            const SizedBox(height: 16),

            // ========== INGREDIENTS SECTION ==========
            _IngredientsSectionHeader(
              ingredientCount: _ingredients.length,
              theme: theme,
              onAddIngredient: _addIngredient,
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
                onAdd: _quickAddIngredient,
                theme: theme,
              ),
            ],

            const SizedBox(height: 12),

            // ========== INGREDIENTS LIST ==========
            if (_ingredients.isEmpty)
              _EmptyIngredientsState(theme: theme, l10n: l10n)
            else
              ...List.generate(_ingredients.length, (index) {
                final ingredient = _ingredientFoods[index];
                final composition = _ingredients[index];

                return _IngredientCard(
                  ingredient: ingredient,
                  composition: composition,
                  index: index,
                  theme: theme,
                  onRemove: () => _removeIngredient(index),
                  onUpdateAmount: (amount, unit) =>
                      _updateIngredientAmount(index, amount, unit),
                );
              }),

            const SizedBox(height: 16),

            // ========== NUTRITION SUMMARY ==========
            if (nutrition != null)
              _NutritionSummaryCard(
                nutrition: nutrition,
                theme: theme,
                servingsCount: (double.tryParse(_servingsController.text) ?? 1)
                    .toInt(),
              ),

            // Bottom padding for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

class const _RecipeInfoCard({
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
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                    Icons.restaurant_menu,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recipe Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Recipe Name *',
                border: OutlineInputBorder(),
                filled: true,
                prefixIcon: Icon(Icons.edit),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a recipe name';
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
                    decoration: const InputDecoration(
                      labelText: 'Servings *',
                      border: OutlineInputBorder(),
                      filled: true,
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
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
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      filled: true,
                      hintText: 'Optional',
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

class const _RecipeMetadataCard({
  required final TextEditingController rawWeightController,
  required final TextEditingController cookedWeightController,
  required final TextEditingController preparationMethodController,
  required final ThemeData theme,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(Icons.science_outlined, color: Colors.grey.shade600),
        title: const Text('Recipe Metadata'),
        subtitle: const Text('Raw/cooked weights, preparation method'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: rawWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Raw Weight (g)',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Cooked Weight (g)',
                    border: OutlineInputBorder(),
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
            decoration: const InputDecoration(
              labelText: 'Preparation Method',
              border: OutlineInputBorder(),
              hintText: 'e.g., baked, fried, steamed',
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class const _IngredientsSectionHeader({
  required final int ingredientCount,
  required final ThemeData theme,
  required final VoidCallback onAddIngredient,
  required final VoidCallback onToggleQuickAdd,
  required final bool showQuickAdd,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Ingredients ($ingredientCount)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            IconButton.outlined(
              onPressed: onToggleQuickAdd,
              icon: Icon(showQuickAdd ? Icons.close : Icons.bolt, size: 18),
              tooltip: 'Quick Add',
              style: IconButton.styleFrom(
                minimumSize: const Size(36, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onAddIngredient,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, size: 18),
                  SizedBox(width: 6),
                  Text('Search Food'),
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
    return Card(
      elevation: 0,
      color: widget.theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
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
                  'Quick Add Ingredient',
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
                labelText: 'Name *',
                hintText: 'e.g., Olive oil',
                border: const OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.5),
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
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0x80FFFFFF),
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
                    decoration: const InputDecoration(
                      labelText: 'Calories (kcal)',
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0x80FFFFFF),
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
                    child: const Text('Add'),
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

class const _EmptyIngredientsState({
  required final ThemeData theme,
  required final AppLocalizations l10n,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_outlined,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No ingredients yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Search or use Quick Add to start',
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

class const _IngredientCard({
  required final FoodEntry ingredient,
  required final RecipeComposition composition,
  required final int index,
  required final ThemeData theme,
  required final VoidCallback onRemove,
  required final Function(double amount, String unit) onUpdateAmount,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        title: Text(
          ingredient.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${composition.amount} ${composition.unit} • ${ingredient.nutrition.energyKcal.toStringAsFixed(0)} kcal',
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
              tooltip: 'Edit amount',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: onRemove,
              color: theme.colorScheme.error,
              tooltip: 'Remove',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final amountController = TextEditingController(
      text: composition.amount.toString(),
    );
    final unitController = TextEditingController(text: composition.unit);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount =
                  double.tryParse(amountController.text) ?? composition.amount;
              onUpdateAmount(amount, unitController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class const _NutritionSummaryCard({
  required final NutritionProfile nutrition,
  required final ThemeData theme,
  required final int servingsCount,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 20,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nutrition per Serving',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$servingsCount ${servingsCount == 1 ? 'serving' : 'servings'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _NutritionChip(
                  label: 'Calories',
                  value: '${nutrition.energyKcal.toStringAsFixed(0)} kcal',
                  icon: Icons.local_fire_department,
                  theme: theme,
                  isPrimary: true,
                ),
                _NutritionChip(
                  label: 'Protein',
                  value: '${nutrition.protein.toStringAsFixed(1)}g',
                  icon: Icons.egg_alt,
                  theme: theme,
                ),
                _NutritionChip(
                  label: 'Carbs',
                  value: '${nutrition.carbs.toStringAsFixed(1)}g',
                  icon: Icons.bakery_dining,
                  theme: theme,
                ),
                _NutritionChip(
                  label: 'Fat',
                  value: '${nutrition.fat.toStringAsFixed(1)}g',
                  icon: Icons.water_drop,
                  theme: theme,
                ),
                _NutritionChip(
                  label: 'Fiber',
                  value: '${nutrition.fiber.toStringAsFixed(1)}g',
                  icon: Icons.grass,
                  theme: theme,
                ),
                _NutritionChip(
                  label: 'Sugar',
                  value: '${nutrition.sugars.toStringAsFixed(1)}g',
                  icon: Icons.cake,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class const _NutritionChip({
  required final String label,
  required final String value,
  required final IconData icon,
  required final ThemeData theme,
  final bool isPrimary = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: isPrimary
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
      ),
      label: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: isPrimary
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: isPrimary
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
