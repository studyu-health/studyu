import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/photo_reference.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/services/food_analysis_service.dart';
import 'package:studyu_app/services/photo_gallery_service.dart';
import 'package:studyu_app/widgets/food_item_selection_dialog.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_app/widgets/photo_recall_section.dart';
import 'package:studyu_app/widgets/photo_viewer_dialog.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_app/widgets/template_selection_sheet.dart';
import 'package:studyu_core/core.dart';

class const MealEntryScreen({
  final MealLog? existingMeal,
  final NutritionTask? task,
  super.key,
}) extends StatefulWidget {
  static MaterialPageRoute<MealLog> route({
    MealLog? existingMeal,
    NutritionTask? task,
  }) => MaterialPageRoute(
    builder: (_) => MealEntryScreen(existingMeal: existingMeal, task: task),
  );

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState() extends State<MealEntryScreen> {
  static const int _breakfastStart = 6;
  static const int _brunchStart = 10;
  static const int _lunchStart = 12;
  static const int _dinnerStart = 16;
  static const int _dinnerEnd = 21;

  late MealLog _meal;
  late MealType _mealType;
  late MealContext _mealContext;
  late DateTime _timestamp;
  late bool _isSkipped;
  CompanyContext? _companyContext;
  DistractionContext? _distractionContext;
  String? _customMealLabel;
  String? _locationDescription;
  String? _skipReason;

  late TextEditingController _customMealLabelController;
  late TextEditingController _locationDescriptionController;
  late TextEditingController _skipReasonController;

  bool _isSavingTemplate = false;
  bool _isSavingFoodTemplate = false;
  String? _analyzingPhotoId;

  final PhotoGalleryService _photoService = PhotoGalleryService();

  @override
  void initState() {
    super.initState();
    if (widget.existingMeal != null) {
      _meal = widget.existingMeal!;
      _mealType = _meal.mealType;
      _mealContext = _meal.mealContext;
      _timestamp = _meal.timestamp;
      _isSkipped = _meal.isSkipped;
      _companyContext = _meal.companyContext;
      _distractionContext = _meal.distractionContext;
      _customMealLabel = _meal.customMealLabel;
      _locationDescription = _meal.locationDescription;
      _skipReason = _meal.skipReason;
    } else {
      _timestamp = DateTime.now();
      _mealType = _getMealTypeByTime(_timestamp);
      _mealContext = MealContext.home;
      _isSkipped = false;
      _meal = MealLog.withId(
        mealType: _mealType,
        mealContext: _mealContext,
        timestamp: _timestamp,
        timezone: DateTime.now().timeZoneName,
        isSkipped: _isSkipped,
        foods: [],
      );
    }

    _customMealLabelController = TextEditingController(
      text: _customMealLabel ?? '',
    );
    _locationDescriptionController = TextEditingController(
      text: _locationDescription ?? '',
    );
    _skipReasonController = TextEditingController(text: _skipReason ?? '');
  }

  @override
  void dispose() {
    _customMealLabelController.dispose();
    _locationDescriptionController.dispose();
    _skipReasonController.dispose();
    super.dispose();
  }

  MealType _getMealTypeByTime(DateTime time) {
    final hour = time.hour;
    if (hour >= _breakfastStart && hour < _brunchStart) {
      return MealType.breakfast;
    }
    if (hour >= _brunchStart && hour < _lunchStart) return MealType.brunch;
    if (hour >= _lunchStart && hour < _dinnerStart) return MealType.lunch;
    if (hour >= _dinnerStart && hour < _dinnerEnd) return MealType.dinner;
    return MealType.snack;
  }

  Future<void> _addFood() async {
    final result = await Navigator.of(context).push(
      FoodSearchScreen.route(allowRecipes: widget.task?.allowRecipes ?? true),
    );
    if (result != null) {
      setState(() {
        _meal.foods.add(result);
      });
    }
  }

  Future<void> _editFood(FoodEntry food, int index) async {
    final result = await Navigator.of(context)
        .push(FoodEntryScreen.route(existingFood: food));
    if (result != null) {
      setState(() {
        _meal.foods[index] = result;
      });
    }
  }

  void _removeFood(int index) {
    setState(() {
      _meal.foods.removeAt(index);
    });
  }

  void _saveMeal() {
    _meal = MealLog(
      id: _meal.id,
      mealType: _mealType,
      customMealLabel: _customMealLabel,
      mealContext: _mealContext,
      locationDescription: _locationDescription,
      timestamp: _timestamp,
      timezone: DateTime.now().timeZoneName,
      isSkipped: _isSkipped,
      skipReason: _skipReason,
      companyContext: _companyContext,
      distractionContext: _distractionContext,
      foods: _meal.foods,
    );
    Navigator.of(context).pop(_meal);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (picked != null) {
      setState(() {
        _timestamp = DateTime(
          _timestamp.year,
          _timestamp.month,
          _timestamp.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  String _getMealTypeLabel(MealType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case MealType.breakfast:
        return l10n.meal_type_breakfast;
      case MealType.brunch:
        return l10n.meal_type_brunch;
      case MealType.lunch:
        return l10n.meal_type_lunch;
      case MealType.dinner:
        return l10n.meal_type_dinner;
      case MealType.snack:
        return l10n.meal_type_snack;
      case MealType.other:
        return l10n.meal_type_other;
    }
  }

  Future<void> _saveAsTemplate() async {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final result = await SaveTemplateDialog.show(
      context,
      initialName: _customMealLabel ?? _getMealTypeLabel(_mealType),
      templateType: TemplateType.meal,
    );

    if (result != null && mounted) {
      setState(() => _isSavingTemplate = true);
      final viewModel = TemplateViewModel(userId: userId);
      await viewModel.saveMealAsTemplate(
        name: result.name,
        meal: _meal,
        tags: result.tags,
      );
      if (mounted) {
        setState(() => _isSavingTemplate = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.template_saved)));
      }
    }
  }

  Future<void> _addFoodFromTemplate() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final food = await TemplateSelectionSheet.show(
      context,
      mode: TemplateSelectionMode.food,
      userId: userId,
    );
    if (food is FoodEntry) {
      setState(() => _meal.foods.add(food));
    }
  }

  Future<void> _saveFoodAsTemplate(FoodEntry food) async {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final templateType = food.entryType == FoodEntryType.recipe
        ? TemplateType.recipe
        : TemplateType.food;

    final result = await SaveTemplateDialog.show(
      context,
      initialName: food.name,
      templateType: templateType,
    );

    if (result != null && mounted) {
      setState(() => _isSavingFoodTemplate = true);
      final viewModel = TemplateViewModel(userId: userId);
      await viewModel.saveFoodAsTemplate(
        name: result.name,
        food: food,
        tags: result.tags,
      );
      if (mounted) {
        setState(() => _isSavingFoodTemplate = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.template_saved)));
      }
    }
  }

  Future<void> _analyzeAndAddFood(PhotoReference photo) async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _analyzingPhotoId = photo.id);

    try {
      // Get the full image bytes
      final asset = await _photoService.getAsset(photo.id);
      if (asset == null) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.foodAnalysisError)));
        }
        return;
      }

      // Get the origin file (full resolution)
      final file = await asset.originFile;
      if (file == null) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.foodAnalysisError)));
        }
        return;
      }

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Call the analysis service
      final result = await FoodAnalysisService.analyzeImage(
        imageBytes: bytes,
        mealTime: _timestamp,
        mealType: _mealType,
      );

      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? l10n.foodAnalysisError),
          ),
        );
        return;
      }

      if (result.items.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.foodAnalysisNoItems)));
        return;
      }

      // Handle single item directly
      if (result.items.length == 1) {
        final item = result.items.first;
        final editedFood = await Navigator.of(context).push<FoodEntry>(
          FoodEntryScreen.route(
            existingFood: item.foodEntry,
            confidenceScore: item.confidenceScore,
          ),
        );
        if (editedFood != null && mounted) {
          setState(() => _meal.foods.add(editedFood));
        }
        return;
      }

      // Handle multiple items with selection dialog
      final selectedItems = await FoodItemSelectionDialog.show(
        context,
        items: result.items,
        overallConfidence: result.overallConfidence,
        notes: result.notes,
      );

      if (selectedItems == null) {
        // User chose to analyze again - retry
        await _analyzeAndAddFood(photo);
        return;
      }

      // Add each selected food
      for (final item in selectedItems) {
        if (!mounted) return;
        final editedFood = await Navigator.of(context).push<FoodEntry>(
          FoodEntryScreen.route(
            existingFood: item.foodEntry,
            confidenceScore: item.confidenceScore,
          ),
        );
        if (editedFood != null && mounted) {
          setState(() => _meal.foods.add(editedFood));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.foodAnalysisError)));
      }
    } finally {
      if (mounted) {
        setState(() => _analyzingPhotoId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final canSave =
        (!_isSkipped && _meal.foods.isNotEmpty) ||
        (_isSkipped && _skipReason != null && _skipReason!.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.meal_entry_title),
        actions: [
          if (_meal.foods.isNotEmpty)
            IconButton(
              icon: _isSavingTemplate
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bookmark_add_outlined),
              tooltip: l10n.save_as_template,
              onPressed: _isSavingTemplate ? null : _saveAsTemplate,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MealTypeSelector(
                    mealType: _mealType,
                    customMealLabel: _customMealLabel,
                    customMealLabelController: _customMealLabelController,
                    customMealTypes: widget.task?.customMealTypes,
                    onMealTypeChanged: (value) {
                      setState(() => _mealType = value);
                    },
                    onCustomLabelChanged: (value) {
                      setState(() => _customMealLabel = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _TimeSelector(
                    timestamp: _timestamp,
                    onSelectTime: _selectTime,
                  ),
                  const SizedBox(height: 16),
                  _FoodListSection(
                    meal: _meal,
                    isSkipped: _isSkipped,
                    onAddFood: _addFood,
                    onAddFoodFromTemplate: _addFoodFromTemplate,
                    onEditFood: _editFood,
                    onRemoveFood: _removeFood,
                    onSaveFoodAsTemplate: _saveFoodAsTemplate,
                    isSavingFoodTemplate: _isSavingFoodTemplate,
                  ),
                  if (_meal.foods.isNotEmpty && !_isSkipped) ...[
                    const SizedBox(height: 16),
                    MealNutritionSummaryCard(meal: _meal),
                  ],
                  const SizedBox(height: 16),
                  PhotoRecallSection(
                    mealTime: _timestamp,
                    onPhotoTap: (photo) {
                      PhotoViewerDialog.show(
                        context,
                        photoId: photo.id,
                        photoDate: photo.createDateTime,
                        onAnalyze: () => _analyzeAndAddFood(photo),
                      );
                    },
                    onAnalyzePhoto: _analyzeAndAddFood,
                    analyzingPhotoId: _analyzingPhotoId,
                  ),
                  const SizedBox(height: 16),
                  _MealOptionsCard(
                    showMealContext: widget.task?.collectMealContext ?? true,
                    mealContext: _mealContext,
                    companyContext: _companyContext,
                    distractionContext: _distractionContext,
                    locationDescription: _locationDescription,
                    locationDescriptionController:
                        _locationDescriptionController,
                    isSkipped: _isSkipped,
                    skipReason: _skipReason,
                    skipReasonController: _skipReasonController,
                    onMealContextChanged: (value) {
                      setState(() => _mealContext = value);
                    },
                    onCompanyContextChanged: (value) {
                      setState(() => _companyContext = value);
                    },
                    onDistractionContextChanged: (value) {
                      setState(() => _distractionContext = value);
                    },
                    onLocationDescriptionChanged: (value) {
                      setState(() => _locationDescription = value);
                    },
                    onSkippedChanged: (value) {
                      setState(() => _isSkipped = value);
                    },
                    onSkipReasonChanged: (value) {
                      setState(() => _skipReason = value);
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: canSave
          ? FloatingActionButton.extended(
              onPressed: _saveMeal,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: const Icon(Icons.check),
              label: Text(l10n.save),
            )
          : null,
    );
  }
}

class const _MealTypeSelector({
  required final MealType mealType,
  required final String? customMealLabel,
  required final TextEditingController customMealLabelController,
  final List<String>? customMealTypes,
  required final ValueChanged<MealType> onMealTypeChanged,
  required final ValueChanged<String> onCustomLabelChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.meal_type_label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (customMealTypes != null && customMealTypes!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: customMealTypes!.map((customType) {
                    final isSelected =
                        mealType == MealType.other &&
                        customMealLabel == customType;
                    return _MealTypeChip(
                      label: customType,
                      isSelected: isSelected,
                      onSelect: () {
                        onMealTypeChanged(MealType.other);
                        onCustomLabelChanged(customType);
                      },
                    );
                  }).toList(),
                )
              else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MealType.values.map((type) {
                    final isSelected = mealType == type;
                    final label = _getMealTypeLabel(context, type);
                    return _MealTypeChip(
                      label: label,
                      isSelected: isSelected,
                      onSelect: () => onMealTypeChanged(type),
                    );
                  }).toList(),
                ),
                if (mealType == MealType.other) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: customMealLabelController,
                    decoration: InputDecoration(
                      labelText: l10n.custom_meal_label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onChanged: onCustomLabelChanged,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getMealTypeLabel(BuildContext context, MealType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case MealType.breakfast:
        return l10n.meal_type_breakfast;
      case MealType.brunch:
        return l10n.meal_type_brunch;
      case MealType.lunch:
        return l10n.meal_type_lunch;
      case MealType.dinner:
        return l10n.meal_type_dinner;
      case MealType.snack:
        return l10n.meal_type_snack;
      case MealType.other:
        return l10n.meal_type_other;
    }
  }
}

class const _MealTypeChip({
  required final String label,
  required final bool isSelected,
  required final VoidCallback onSelect,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class const _TimeSelector({
  required final DateTime timestamp,
  required final VoidCallback onSelectTime,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onSelectTime,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class const _FoodListSection({
  required final MealLog meal,
  required final bool isSkipped,
  required final VoidCallback onAddFood,
  required final VoidCallback onAddFoodFromTemplate,
  required final Function(FoodEntry, int) onEditFood,
  required final Function(int) onRemoveFood,
  required final Function(FoodEntry) onSaveFoodAsTemplate,
  final bool isSavingFoodTemplate = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (isSkipped) {
      return const SizedBox.shrink();
    }

    if (meal.foods.isEmpty) {
      return _EmptyFoodState(theme: theme, l10n: l10n, onAddFood: onAddFood);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.food_items,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Semantics(
                  label: l10n.from_template,
                  button: true,
                  child: IconButton.outlined(
                    onPressed: onAddFoodFromTemplate,
                    icon: const Icon(Icons.bookmark, size: 18),
                    tooltip: l10n.from_template,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: l10n.add_food,
                  button: true,
                  child: FilledButton(
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
                        const Icon(Icons.add, size: 18),
                        const SizedBox(width: 6),
                        Text(l10n.add_food),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(meal.foods.length, (index) {
          final food = meal.foods[index];
          return _FoodCard(
            food: food,
            index: index,
            onTap: () => onEditFood(food, index),
            onEdit: () => onEditFood(food, index),
            onDelete: () => onRemoveFood(index),
            onSaveTemplate: () => onSaveFoodAsTemplate(food),
            isSavingTemplate: isSavingFoodTemplate,
          );
        }),
      ],
    );
  }
}

class const _EmptyFoodState({
  required final ThemeData theme,
  required final AppLocalizations l10n,
  required final VoidCallback onAddFood,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAddFood,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
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
                Icons.add_circle_outline,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.add_food,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.tap_to_add_food,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
  required final int index,
  required final VoidCallback onTap,
  required final VoidCallback onEdit,
  required final VoidCallback onDelete,
  required final VoidCallback onSaveTemplate,
  final bool isSavingTemplate = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final (icon, color) = _getFoodIconAndColor(food.entryType);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(icon, size: 22, color: color)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${food.amount} ${food.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${food.nutrition.energyKcal.toStringAsFixed(0)} kcal',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                tooltip: l10n.more_options,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (isSavingTemplate) return;
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'save_template':
                      onSaveTemplate();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: _PopupMenuItem(
                      icon: Icons.edit_outlined,
                      label: l10n.edit,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'save_template',
                    enabled: !isSavingTemplate,
                    child: isSavingTemplate
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(l10n.saving),
                            ],
                          )
                        : _PopupMenuItem(
                            icon: Icons.bookmark_add_outlined,
                            label: l10n.save_as_template,
                          ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: _PopupMenuItem(
                      icon: Icons.delete_outline,
                      label: l10n.delete,
                      isDestructive: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getFoodIconAndColor(FoodEntryType entryType) {
    switch (entryType) {
      case FoodEntryType.recipe:
        return (Icons.menu_book_outlined, Colors.orange);
      case FoodEntryType.brandedProduct:
        return (Icons.shopping_bag_outlined, Colors.blue);
      case FoodEntryType.manualCustom:
        return (Icons.edit_note_outlined, Colors.purple);
      default:
        return (Icons.restaurant_outlined, Colors.green);
    }
  }
}

class const _MealOptionsCard({
  final bool showMealContext = true,
  required final MealContext mealContext,
  required final CompanyContext? companyContext,
  required final DistractionContext? distractionContext,
  required final String? locationDescription,
  required final TextEditingController locationDescriptionController,
  required final bool isSkipped,
  required final String? skipReason,
  required final TextEditingController skipReasonController,
  required final ValueChanged<MealContext> onMealContextChanged,
  required final ValueChanged<CompanyContext?> onCompanyContextChanged,
  required final ValueChanged<DistractionContext?> onDistractionContextChanged,
  required final ValueChanged<String> onLocationDescriptionChanged,
  required final ValueChanged<bool> onSkippedChanged,
  required final ValueChanged<String> onSkipReasonChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.details,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showMealContext) ...[
              const SizedBox(height: 12),
              _DropdownField<MealContext>(
                label: l10n.where_did_you_eat,
                value: mealContext,
                items: MealContext.values,
                itemLabel: (context) => _getMealContextLabel(context, l10n),
                onChanged: (value) {
                  if (value != null) onMealContextChanged(value);
                },
              ),
              if (mealContext == MealContext.other) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: locationDescriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.location_description,
                    hintText: l10n.location_description_hint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: onLocationDescriptionChanged,
                ),
              ],
              const SizedBox(height: 12),
              _DropdownField<CompanyContext?>(
                label: l10n.who_were_you_with,
                value: companyContext,
                items: const [null, ...CompanyContext.values],
                itemLabel: (context) => context == null
                    ? l10n.not_specified
                    : _getCompanyContextLabel(context, l10n),
                onChanged: onCompanyContextChanged,
              ),
              const SizedBox(height: 12),
              _DropdownField<DistractionContext?>(
                label: l10n.distractions_during_meal,
                value: distractionContext,
                items: const [null, ...DistractionContext.values],
                itemLabel: (context) => context == null
                    ? l10n.not_specified
                    : _getDistractionContextLabel(context, l10n),
                onChanged: onDistractionContextChanged,
              ),
            ],
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.skipped_this_meal),
              value: isSkipped,
              onChanged: onSkippedChanged,
            ),
            if (isSkipped) ...[
              const SizedBox(height: 8),
              TextField(
                controller: skipReasonController,
                decoration: InputDecoration(
                  labelText: l10n.reason_for_skipping,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: onSkipReasonChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMealContextLabel(MealContext context, AppLocalizations l10n) {
    switch (context) {
      case MealContext.home:
        return l10n.context_home;
      case MealContext.restaurant:
        return l10n.context_restaurant;
      case MealContext.takeout:
        return l10n.context_takeout;
      case MealContext.vending:
        return l10n.context_vending;
      case MealContext.other:
        return l10n.context_other;
    }
  }

  String _getCompanyContextLabel(
    CompanyContext context,
    AppLocalizations l10n,
  ) {
    switch (context) {
      case CompanyContext.alone:
        return l10n.company_alone;
      case CompanyContext.family:
        return l10n.company_family;
      case CompanyContext.friends:
        return l10n.company_friends;
      case CompanyContext.colleagues:
        return l10n.company_colleagues;
      case CompanyContext.other:
        return l10n.company_other;
    }
  }

  String _getDistractionContextLabel(
    DistractionContext context,
    AppLocalizations l10n,
  ) {
    switch (context) {
      case DistractionContext.none:
        return l10n.distraction_none;
      case DistractionContext.tv:
        return l10n.distraction_tv;
      case DistractionContext.phone:
        return l10n.distraction_phone;
      case DistractionContext.work:
        return l10n.distraction_work;
      case DistractionContext.other:
        return l10n.distraction_other;
    }
  }
}

class const _DropdownField<T>({
  required final String label,
  required final T? value,
  required final List<T?> items,
  required final String Function(T) itemLabel,
  required final ValueChanged<T?> onChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T?>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items
          .map((item) {
            if (item == null) return null;
            return DropdownMenuItem<T?>(
              value: item,
              child: Text(itemLabel(item as T)),
            );
          })
          .whereType<DropdownMenuItem<T?>>()
          .toList(),
      onChanged: onChanged,
    );
  }
}

class const _PopupMenuItem({
  required final IconData icon,
  required final String label,
  final bool isDestructive = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isDestructive ? Theme.of(context).colorScheme.error : null,
          ),
        ),
      ],
    );
  }
}
