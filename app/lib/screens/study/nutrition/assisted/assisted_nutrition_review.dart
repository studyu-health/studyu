import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/photo_reference.dart';
import 'package:studyu_app/screens/study/nutrition/assisted/assisted_nutrition_fixtures.dart';
import 'package:studyu_app/screens/study/nutrition/assisted/assisted_nutrition_voice.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_action_menu.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

class const AssistedNutritionReview({
  required final List<MealLog> meals,
  required final DateTime diaryDay,
  required final NutritionTask? task,
  required final Future<bool> Function(List<MealLog>) onSave,
  final Map<String, PhotoReference> mealPhotos = const {},
  final NutritionFoodRepository? foodRepository,
  final TemplateViewModel? templateViewModel,
  super.key,
}) extends StatefulWidget {
  @override
  State<AssistedNutritionReview> createState() =>
      _AssistedNutritionReviewState();
}

typedef _FoodPosition = ({MealLog meal, int index});

class _AssistedNutritionReviewState() extends State<AssistedNutritionReview> {
  static const double _contentWidth = 600;

  late final _meals = widget.meals.map(_cloneMeal).toList();
  FoodEntry? _draggedFood;
  EdgeDraggingAutoScroller? _autoScroller;
  bool _saving = false;
  bool _saveFailed = false;

  bool get _canEdit => !_saving && _draggedFood == null;
  bool get _canSave =>
      _canEdit &&
      _meals.isNotEmpty &&
      _meals.every((meal) => meal.isValidForSave(hasSelectedTime: true));

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  static MealLog _cloneMeal(MealLog meal) =>
      cloneMealLog(meal)..foods = meal.foods.map(cloneFoodEntry).toList();

  @override
  void dispose() {
    _autoScroller?.stopAutoScroll();
    super.dispose();
  }

  String _mealLabel(MealLog meal) {
    final label = meal.customMealLabel?.trim();
    if (label != null && label.isNotEmpty) return label;
    return switch (meal.mealType) {
      MealType.breakfast => _l10n.meal_type_breakfast,
      MealType.brunch => _l10n.meal_type_brunch,
      MealType.lunch => _l10n.meal_type_lunch,
      MealType.dinner => _l10n.meal_type_dinner,
      MealType.snack => _l10n.meal_type_snack,
      MealType.other => _l10n.meal_neutral_label,
    };
  }

  String _mealTime(MealLog meal) {
    final timestamp = meal.timestamp;
    if (timestamp == null ||
        meal.timePrecision == MealOccurrenceTimePrecision.unknown) {
      return _l10n.time_not_remembered;
    }
    final time = TimeOfDay.fromDateTime(timestamp.toLocal()).format(context);
    return meal.timePrecision == MealOccurrenceTimePrecision.approximate
        ? _l10n.about_time(time)
        : time;
  }

  String _reviewMealLabel(MealLog meal) {
    final label = _mealLabel(meal);
    final matchingMeals = _meals.where((entry) => _mealLabel(entry) == label);
    if (matchingMeals.length < 2) return label;
    final index = matchingMeals.toList().indexOf(meal) + 1;
    return '$label ${MaterialLocalizations.of(context).formatDecimal(index)}';
  }

  Future<void> _editMeal(MealLog meal) async {
    final result = await Navigator.of(context).push(
      MealEntryScreen.route(
        existingMeal: meal,
        task: widget.task,
        occurrenceDate: widget.diaryDay,
        recallPhoto: widget.mealPhotos[meal.id],
        draftOnly: true,
        foodRepository: widget.foodRepository,
        templateViewModel: widget.templateViewModel,
      ),
    );
    if (!mounted || result is! SavedMealEntryResult) return;
    setState(() => _meals[_meals.indexOf(meal)] = result.meal);
  }

  Future<void> _editFood(MealLog meal, FoodEntry food) async {
    final result = food.entryType == FoodEntryType.meal
        ? await FoodQuantitySheet.show(
            context,
            food: food,
            action: FoodQuantityAction.updateSelection,
          )
        : await Navigator.of(context).push(
            FoodEntryScreen.route(
              existingFood: food,
              editLoggedAmount: true,
              showSearchAction: false,
              mealLabel: _mealLabel(meal),
              showCurrentMealOnlyNotice: true,
              repository: widget.foodRepository,
              templateViewModel: widget.templateViewModel,
            ),
          );
    if (!mounted || result == null) return;
    final index = meal.foods.indexOf(food);
    if (index != -1) setState(() => meal.foods[index] = result);
  }

  Future<void> _correctByVoice() async {
    await showAssistedNutritionCorrection(
      context,
      onApply: (text) {
        if (!mounted || !applyAssistedNutritionCorrection(_meals, text)) {
          return false;
        }
        setState(() {});
        return true;
      },
    );
  }

  void _moveFood(_FoodPosition source, _FoodPosition destination) {
    setState(() {
      final food = source.meal.foods.removeAt(source.index);
      destination.meal.foods.insert(destination.index, food);
    });
  }

  void _dropFood(FoodEntry food, _FoodPosition target) {
    final sourceMeal = _meals.firstWhere((meal) => meal.foods.contains(food));
    final index = sourceMeal.foods.indexOf(food);
    final targetIndex = sourceMeal == target.meal && index < target.index
        ? target.index - 1
        : target.index;
    _moveFood(
      (meal: sourceMeal, index: index),
      (meal: target.meal, index: targetIndex),
    );
  }

  Widget _buildDropGap(MealLog meal, int index) {
    final colors = Theme.of(context).colorScheme;
    return DragTarget<FoodEntry>(
      onWillAcceptWithDetails: (details) {
        final sourceIndex = meal.foods.indexOf(details.data);
        return sourceIndex == -1 ||
            (index != sourceIndex && index != sourceIndex + 1);
      },
      onAcceptWithDetails: (details) =>
          _dropFood(details.data, (meal: meal, index: index)),
      builder: (context, candidates, _) => SizedBox(
        height: 24,
        child: candidates.isEmpty
            ? const Divider()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    border: Border.all(color: colors.primary),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
      ),
    );
  }

  void _stopDragging() {
    _autoScroller?.stopAutoScroll();
    _autoScroller = null;
    if (mounted) setState(() => _draggedFood = null);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    final bool saved;
    try {
      saved = await widget.onSave(_meals.map(_cloneMeal).toList());
    } catch (error, stackTrace) {
      StudyULogger.warning(
        'Could not save assisted diary entries (${error.runtimeType}).\n$stackTrace',
      );
      if (mounted) _showSaveFailure();
      return;
    }
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
    } else {
      _showSaveFailure();
    }
  }

  void _showSaveFailure() {
    setState(() {
      _saving = false;
      _saveFailed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope<bool>(
      canPop: _canEdit,
      child: Scaffold(
        appBar: AppBar(title: Text(_l10n.assisted_review_meals)),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _contentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Text(
                      _l10n.assisted_review_instructions,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_meals.isEmpty) Text(_l10n.no_meals_recorded),
                    for (final meal in _meals) _buildMeal(meal),
                    if (_meals.isNotEmpty)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: _canEdit ? _correctByVoice : null,
                        icon: const Icon(Icons.mic_none),
                        label: Text(_l10n.nutrition_assisted_correct_voice),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildSaveBar(theme),
      ),
    );
  }

  Widget _buildSaveBar(ThemeData theme) => Material(
    color: theme.colorScheme.surface,
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  if (_saveFailed)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _l10n.assisted_save_failed,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: _canSave ? _save : null,
                    child: _saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _l10n.assisted_save_diary_entries(_meals.length),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildMeal(MealLog meal) {
    final theme = Theme.of(context);
    final label = _reviewMealLabel(meal);
    final details = mealContextDetails(
      _l10n,
      mealContext: meal.mealContext,
      locationDescription: meal.locationDescription,
      companyContext: meal.companyContext,
      distractionContext: meal.distractionContext,
    );
    final empty = meal.foods.isEmpty && !meal.isSkipped;
    return Card(
      key: ValueKey(meal.id),
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 48,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 8,
                children: [
                  Flexible(
                    flex: 3,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Flexible(
                          child: Semantics(
                            header: true,
                            child: Text(
                              label,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ),
                        const Icon(Icons.edit_outlined, size: 18),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        const Icon(Icons.schedule_outlined, size: 18),
                        Flexible(
                          child: Text(
                            _mealTime(meal),
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: details.isEmpty ? null : Text(details.join(' • ')),
              onTap: _canEdit ? () => _editMeal(meal) : null,
            ),
            if (empty) ...[
              if (_draggedFood != null) _buildDropGap(meal, 0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l10n.assisted_empty_meal,
                    style: theme.textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: _canEdit
                        ? () => setState(() => _meals.remove(meal))
                        : null,
                    child: Text(_l10n.assisted_remove_empty_meal),
                  ),
                ],
              ),
            ] else if (meal.isSkipped)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  meal.skipReason ?? _l10n.enter_skip_reason,
                  style: theme.textTheme.bodySmall,
                ),
              )
            else ...[
              for (final (index, food) in meal.foods.indexed) ...[
                if (_draggedFood != null)
                  _buildDropGap(meal, index)
                else
                  const Divider(height: 1),
                _buildFoodRow(meal, index, food),
              ],
              if (_draggedFood != null) _buildDropGap(meal, meal.foods.length),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFoodRow(MealLog meal, int index, FoodEntry food) {
    final textTheme = Theme.of(context).textTheme;
    final reference = food.portionReference?.trim();
    final portion =
        food.amount == 1 && reference != null && reference.isNotEmpty
        ? reference
        : foodTotalPortion(_l10n, food, 1);
    return Row(
      key: ValueKey(food.id),
      children: [
        Expanded(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: 56,
            leading: const Icon(Icons.restaurant_outlined, size: 20),
            horizontalTitleGap: 8,
            title: Text(food.name, style: textTheme.titleSmall),
            subtitle: Text(
              _l10n.assisted_estimated_portion(portion),
              style: textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: _canEdit ? () => _editFood(meal, food) : null,
          ),
        ),
        _buildMoveHandle(meal, index, food),
      ],
    );
  }

  Widget _buildMoveHandle(MealLog meal, int index, FoodEntry food) {
    final otherMeals = _meals.where(
      (other) => other != meal && !other.isSkipped,
    );
    final source = (meal: meal, index: index);
    return Builder(
      builder: (context) => Draggable<FoodEntry>(
        data: food,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        maxSimultaneousDrags: _canEdit ? 1 : 0,
        onDragStarted: () {
          _autoScroller = EdgeDraggingAutoScroller(
            Scrollable.of(context),
            velocityScalar: 10,
          );
          setState(() => _draggedFood = food);
        },
        onDragUpdate: (update) => _autoScroller?.startAutoScrollIfNecessary(
          Rect.fromCenter(center: update.globalPosition, width: 1, height: 48),
        ),
        onDragEnd: (_) => _stopDragging(),
        feedback: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(food.name),
            ),
          ),
        ),
        child: SizedBox.square(
          dimension: 48,
          child: PopupMenuButton<VoidCallback>(
            enabled:
                _canEdit && (meal.foods.length > 1 || otherMeals.isNotEmpty),
            icon: const Icon(Icons.drag_indicator),
            tooltip: _l10n.assisted_food_order_actions(food.name),
            position: PopupMenuPosition.under,
            onSelected: (action) => action(),
            itemBuilder: (_) => [
              if (index > 0)
                nutritionActionMenuItem(
                  _l10n.assisted_move_food_up,
                  Icons.arrow_upward,
                  () => _moveFood(source, (meal: meal, index: index - 1)),
                ),
              if (index < meal.foods.length - 1)
                nutritionActionMenuItem(
                  _l10n.assisted_move_food_down,
                  Icons.arrow_downward,
                  () => _moveFood(source, (meal: meal, index: index + 1)),
                ),
              for (final other in otherMeals)
                nutritionActionMenuItem(
                  _l10n.assisted_move_food_to_meal(_reviewMealLabel(other)),
                  Icons.drive_file_move_outlined,
                  () => _moveFood(source, (
                    meal: other,
                    index: other.foods.length,
                  )),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
