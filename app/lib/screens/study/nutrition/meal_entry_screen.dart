import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_app/widgets/photo_recall_section.dart';
import 'package:studyu_app/widgets/photo_viewer_dialog.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_app/widgets/unsaved_changes_dialog.dart';
import 'package:studyu_core/core.dart';
import 'package:uuid/uuid.dart';

sealed class const MealEntryResult();

final class const SavedMealEntryResult(
  final MealLog meal, {
  final bool definitionMutated = false,
}) extends MealEntryResult;

final class const DeletedMealEntryResult() extends MealEntryResult;

final class const DiscardedMealEntryResult() extends MealEntryResult;

enum _FoodAction() {
  details,
  edit,
  editDefinition,
  saveTemplate,
  remove,
}

enum _LibraryEditChoice() {
  currentEntry,
  currentEntryAndLibrary,
}

enum _AddFoodSource() {
  search,
  photoRecall,
}

class const _MealTypeSelection(
  final MealType type, [
  final String? customLabel,
]);

class const _TimeSelection(
  final DateTime? timestamp,
  final MealOccurrenceTimePrecision precision,
);

class const _MealDetailsSelection({
  required final MealContext? mealContext,
  required final CompanyContext? companyContext,
  required final DistractionContext? distractionContext,
  required final String? locationDescription,
});

class const MealEntryScreen({
  final MealLog? existingMeal,
  final NutritionTask? task,
  final MealType? initialMealType,
  final String? initialCustomMealLabel,
  final DateTime? occurrenceDate,
  final NutritionRecallPersistenceTarget? historicalTarget,
  final NutritionFoodRepository? foodRepository,
  final bool openFoodSearch = false,
  super.key,
}) extends StatefulWidget {
  static MaterialPageRoute<MealEntryResult> route({
    MealLog? existingMeal,
    NutritionTask? task,
    MealType? initialMealType,
    String? initialCustomMealLabel,
    DateTime? occurrenceDate,
    NutritionRecallPersistenceTarget? historicalTarget,
    NutritionFoodRepository? foodRepository,
    bool openFoodSearch = false,
  }) => MaterialPageRoute(
    builder: (_) => MealEntryScreen(
      existingMeal: existingMeal,
      task: task,
      initialMealType: initialMealType,
      initialCustomMealLabel: initialCustomMealLabel,
      occurrenceDate: occurrenceDate,
      historicalTarget: historicalTarget,
      foodRepository: foodRepository,
      openFoodSearch: openFoodSearch,
    ),
  );

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState() extends State<MealEntryScreen> {
  late MealLog _meal;
  late MealType _mealType;
  late MealContext? _mealContext;
  DateTime? _timestamp;
  late MealOccurrenceTimePrecision _timePrecision;
  late bool _hasSelectedTime;
  late bool _isSkipped;
  CompanyContext? _companyContext;
  DistractionContext? _distractionContext;
  String? _customMealLabel;
  late bool _isLabelExplicitlyUnset;
  String? _locationDescription;
  String? _skipReason;
  late final String _initialMealSnapshot;
  bool _allowPop = false;
  bool _hasAttemptedSave = false;
  bool _definitionMutated = false;
  bool _saveToMyItems = true;
  bool _propagateToCurrentStudyDay = false;

  bool get _allowMeals => widget.task?.allowMeals ?? true;

  DateTime get _occurrenceDate =>
      widget.occurrenceDate ?? _meal.timestamp ?? DateTime.now();

  late TextEditingController _skipReasonController;

  @override
  void initState() {
    super.initState();
    if (widget.existingMeal != null) {
      _meal = cloneMealLog(widget.existingMeal!);
      _mealType = _meal.mealType;
      _mealContext = _meal.mealContext;
      _timestamp = _meal.timestamp;
      _timePrecision = _meal.timePrecision;
      _hasSelectedTime = true;
      _isSkipped = _meal.isSkipped;
      _companyContext = _meal.companyContext;
      _distractionContext = _meal.distractionContext;
      _customMealLabel = _meal.customMealLabel;
      _isLabelExplicitlyUnset = _meal.isLabelExplicitlyUnset;
      _locationDescription = _meal.locationDescription;
      _skipReason = _meal.skipReason;
    } else {
      _timestamp = null;
      _timePrecision = MealOccurrenceTimePrecision.unknown;
      _hasSelectedTime = false;
      _mealType = widget.initialMealType ?? MealType.other;
      _customMealLabel = widget.initialCustomMealLabel;
      _isLabelExplicitlyUnset =
          _mealType == MealType.other && _customMealLabel == null;
      _mealContext = null;
      _isSkipped = false;
      _meal = MealLog.withId(
        mealType: _mealType,
        customMealLabel: _customMealLabel,
        mealContext: _mealContext,
        timestamp: _timestamp,
        timePrecision: _timePrecision,
        isLabelExplicitlyUnset: _isLabelExplicitlyUnset,
        timezone: DateTime.now().timeZoneName,
        isSkipped: _isSkipped,
        foods: [],
      );
    }

    _skipReasonController = TextEditingController(text: _skipReason ?? '');
    _initialMealSnapshot = _mealSnapshot;
    if (widget.openFoodSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openFoodSearch();
      });
    }
  }

  @override
  void dispose() {
    _skipReasonController.dispose();
    super.dispose();
  }

  Future<void> _addFood() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<_AddFoodSource>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const ValueKey('add-food-search-option'),
            leading: const Icon(Icons.search_outlined),
            title: Text(l10n.nutrition_add_food_or_saved_meal),
            onTap: () => Navigator.pop(sheetContext, _AddFoodSource.search),
          ),
          ListTile(
            key: const ValueKey('add-food-photo-recall-option'),
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.photoRecallTitle),
            subtitle: Text(l10n.photoRecallSubtitle),
            onTap: () =>
                Navigator.pop(sheetContext, _AddFoodSource.photoRecall),
          ),
        ],
      ),
    );
    if (!mounted || source == null) return;
    switch (source) {
      case _AddFoodSource.search:
        await _openFoodSearch();
      case _AddFoodSource.photoRecall:
        await _showPhotoRecall();
    }
  }

  Future<void> _openFoodSearch() async {
    final result = await FoodSearchScreen.show(
      context,
      mealLabel: _mealLabel,
      allowMeals: widget.task?.allowMeals ?? true,
      historicalMode: widget.historicalTarget != null,
      repository: widget.foodRepository,
      templateViewModel: Provider.of<TemplateViewModel?>(
        context,
        listen: false,
      ),
    );
    if (!mounted || !_revalidateHistoricalEligibility()) return;
    if (result != null) {
      final foods = _allowMeals
          ? result.foods
          : result.foods
                .where((food) => food.entryType != FoodEntryType.meal)
                .toList();
      setState(() => _meal.foods.addAll(foods));
    }
  }

  int _foodIndex(String foodId) =>
      _meal.foods.indexWhere((food) => food.id == foodId);

  Future<bool> _hasCurrentStudyDayMatches(String foodId) async {
    final subject = Provider.of<AppState>(context, listen: false).activeSubject;
    if (subject == null || widget.historicalTarget == null) return false;
    final currentStudyDay = nutritionStudyDayFor(subject, DateTime.now());

    bool recallContains(DailyRecall recall) => recall.meals.any(
      (meal) => meal.foods.any((food) => food.foodId == foodId),
    );

    for (final progress in subject.progress) {
      final result = progress.result.result;
      if (progress.resultType == 'DailyRecall' &&
          result is DailyRecall &&
          result.studyDaySnapshot == currentStudyDay &&
          recallContains(result)) {
        return true;
      }
    }

    final pending = await NutritionRecallAutoSaveManager().scanPendingRecalls(
      subject.id,
    );
    return pending.any(
      (draft) =>
          draft.studyDaySnapshot == currentStudyDay &&
          recallContains(draft.recall),
    );
  }

  Future<_LibraryEditChoice?> _chooseLibraryEdit() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<_LibraryEditChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.library_edit_title),
        content: Text(l10n.library_edit_message),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(dialogContext)
                          .pop(_LibraryEditChoice.currentEntry),
                  child: Text(l10n.library_edit_current_entry),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(dialogContext)
                          .pop(_LibraryEditChoice.currentEntryAndLibrary),
                  child: Text(l10n.library_edit_current_entry_and_library),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _editFood(
    FoodEntry food, {
    bool editReusableDefinition = false,
  }) async {
    if (editReusableDefinition && food.entryType == FoodEntryType.meal) {
      await _editCompositeMealDefinition(food);
      return;
    }
    final isLibraryBacked = food.templateId?.isNotEmpty == true;
    var updateLibrary = false;
    if (!editReusableDefinition &&
        widget.historicalTarget == null &&
        isLibraryBacked) {
      final choice = await _chooseLibraryEdit();
      if (!mounted || choice == null) return;
      updateLibrary = choice == _LibraryEditChoice.currentEntryAndLibrary;
    }
    final hasCurrentDayMatches =
        editReusableDefinition && await _hasCurrentStudyDayMatches(food.foodId);
    if (!mounted) return;
    final FoodEntry? result;
    final showCurrentMealOnlyNotice =
        (editReusableDefinition || widget.historicalTarget != null) ||
        !isLibraryBacked;
    if (food.entryType == FoodEntryType.meal) {
      result = await Navigator.of(context).push(
        MealCreatorScreen.route(
          existingMeal: food,
          showCurrentMealOnlyNotice: showCurrentMealOnlyNotice,
        ),
      );
    } else {
      result = await Navigator.of(context).push(
        FoodEntryScreen.route(
          existingFood: food,
          showSearchAction: false,
          historicalTarget: widget.historicalTarget,
          editReusableDefinition: editReusableDefinition,
          hasCurrentStudyDayMatches: hasCurrentDayMatches,
          showCurrentMealOnlyNotice: showCurrentMealOnlyNotice,
          repository: widget.foodRepository,
        ),
      );
    }
    if (!mounted || !_revalidateHistoricalEligibility()) return;
    final editedResult = result;
    if (editedResult == null) return;
    var edited = editedResult;

    if (updateLibrary) {
      final subject = Provider.of<AppState>(
        context,
        listen: false,
      ).activeSubject;
      try {
        final viewModel =
            Provider.of<TemplateViewModel?>(context, listen: false) ??
            TemplateViewModel(
              userId: subject?.id ?? 'anonymous',
              repository: widget.foodRepository,
            );
        final updatedTemplate = await viewModel.updateFoodTemplatePrototype(
          food.templateId!,
          edited.entryType == FoodEntryType.meal
              ? normalizeNutritionFoodDefinition(edited)
              : edited,
        );
        if (updatedTemplate != null) {
          edited = cloneFoodEntry(edited)
            ..foodId = updatedTemplate.prototype.foodId
            ..foodVersionId = updatedTemplate.prototype.foodVersionId
            ..templateId = updatedTemplate.id;
        }
      } catch (error, stackTrace) {
        StudyULogger.error(
          'Failed to update reusable nutrition item: $error\n$stackTrace',
        );
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.could_not_save_results)));
        }
      }
    }

    final index = _foodIndex(food.id);
    if (index == -1) return;
    final updatedOccurrence = editReusableDefinition
        ? edited
        : (_replaceOccurrence(food, edited)
            ..foodId = updateLibrary ? edited.foodId : food.foodId
            ..foodVersionId = updateLibrary
                ? edited.foodVersionId
                : food.foodVersionId);
    setState(() {
      _definitionMutated = _definitionMutated || editReusableDefinition;
      _meal.foods[index] = updatedOccurrence;
    });
  }

  FoodEntry _replaceOccurrence(FoodEntry existing, FoodEntry edited) {
    final replacement = cloneFoodEntry(edited)
      ..id = existing.id
      ..foodId = existing.foodId
      ..foodVersionId = existing.foodVersionId
      ..templateId = existing.templateId
      ..createdAt = existing.createdAt
      ..parentEntryId = existing.parentEntryId;
    for (final component in replacement.componentFoods ?? <FoodComposition>[]) {
      component.parentEntryId = replacement.id;
    }
    return replacement;
  }

  Future<void> _editCompositeMealDefinition(FoodEntry existingMeal) async {
    final editableDefinition = normalizeNutritionFoodDefinition(existingMeal);
    final hasCurrentDayMatches = await _hasCurrentStudyDayMatches(
      existingMeal.foodId,
    );
    if (!mounted) return;
    _propagateToCurrentStudyDay = false;
    final edited = await Navigator.of(context).push(
      MealCreatorScreen.route(
        existingMeal: editableDefinition,
        showCurrentDayPropagationOption: hasCurrentDayMatches,
        onCurrentDayPropagationChanged: (value) {
          _propagateToCurrentStudyDay = value;
        },
      ),
    );
    if (!mounted || !_revalidateHistoricalEligibility() || edited == null) {
      return;
    }

    final subject = Provider.of<AppState>(context, listen: false).activeSubject;
    final historicalTarget = widget.historicalTarget;
    if (subject == null || historicalTarget == null) return;
    final currentStudyDay = _propagateToCurrentStudyDay
        ? nutritionStudyDayFor(subject, DateTime.now())
        : null;
    final repository = widget.foodRepository ?? NutritionFoodRepository();
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await repository.mutateHistoricalDefinition(
        subjectId: subject.id,
        snapshot: normalizeNutritionFoodDefinition(edited),
        expectedVersionId: existingMeal.foodVersionId,
        entryId: existingMeal.id,
        target: historicalTarget.toJson(),
        currentStudyDay: currentStudyDay,
        mutationId: const Uuid().v4(),
      );
      final updated = applyNutritionFoodSnapshot(
        existingMeal,
        result.definition.snapshot,
      );
      _reconcileProgress(subject, result.progress);
      final autoSaveManager = NutritionRecallAutoSaveManager();
      if (_propagateToCurrentStudyDay) {
        await autoSaveManager.rewriteFoodDefinition(
          subjectId: subject.id,
          studyDaySnapshot: currentStudyDay!,
          definition: result.definition.snapshot,
        );
      }
      await autoSaveManager.rewriteFoodDefinition(
        subjectId: subject.id,
        studyDaySnapshot: historicalTarget.studyDaySnapshot,
        definition: result.definition.snapshot,
        entryId: existingMeal.id,
      );
      if (!mounted || !_revalidateHistoricalEligibility()) return;
      final index = _foodIndex(existingMeal.id);
      if (index == -1) return;
      setState(() {
        _definitionMutated = true;
        _meal.foods[index] = updated;
      });
      final message = _propagateToCurrentStudyDay
          ? l10n.food_definition_updated_current_day_opt_in
          : l10n.food_definition_updated_current_day_opt_out;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (error, stackTrace) {
      StudyULogger.error(
        'Failed to update historical composite meal definition: '
        '$error\n$stackTrace',
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.could_not_save_results)));
      }
    }
  }

  void _reconcileProgress(
    StudySubject subject,
    List<Map<String, dynamic>> canonicalRows,
  ) {
    for (final row in canonicalRows) {
      final canonical = SupabaseQuery.extractSupabaseSingleRow<SubjectProgress>(
        row,
      );
      final index = subject.progress.indexWhere(
        (progress) =>
            progress.subjectId == canonical.subjectId &&
            progress.completedAt == canonical.completedAt,
      );
      if (index < 0) {
        subject.progress.add(canonical);
      } else {
        subject.progress[index] = canonical;
      }
    }
  }

  void _removeFood(FoodEntry food) {
    if (!_revalidateHistoricalEligibility()) return;
    final index = _foodIndex(food.id);
    if (index == -1) return;
    setState(() => _meal.foods.removeAt(index));
  }

  Future<void> _adjustFoodQuantity(FoodEntry food) async {
    final result = await FoodQuantitySheet.show(
      context,
      food: food,
      mealLabel: _mealLabel,
      action: FoodQuantityAction.update,
    );
    if (!mounted || !_revalidateHistoricalEligibility()) return;
    if (result == null) return;

    final index = _foodIndex(food.id);
    if (index == -1) return;
    setState(() => _meal.foods[index] = result);
  }

  Future<void> _showFoodActions(FoodEntry food) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final action = await showModalBottomSheet<_FoodAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: theme.textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _foodActionSubtitle(food, l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.details),
              onTap: () => Navigator.pop(sheetContext, _FoodAction.details),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.edit_this_entry),
              onTap: () => Navigator.pop(sheetContext, _FoodAction.edit),
            ),
            if (widget.historicalTarget != null)
              ListTile(
                leading: const Icon(Icons.sync_outlined),
                title: Text(l10n.edit_food_definition),
                onTap: () =>
                    Navigator.pop(sheetContext, _FoodAction.editDefinition),
              ),
            if (food.templateId == null &&
                widget.historicalTarget == null &&
                (_allowMeals || food.entryType != FoodEntryType.meal))
              ListTile(
                leading: const Icon(Icons.bookmark_add_outlined),
                title: Text(l10n.save_to_my_items_action),
                onTap: () =>
                    Navigator.pop(sheetContext, _FoodAction.saveTemplate),
              ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                l10n.remove_from_meal,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => Navigator.pop(sheetContext, _FoodAction.remove),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _FoodAction.details:
        // The menu is already dismissed before the quantity sheet opens.
        await _adjustFoodQuantity(food);
      case _FoodAction.edit:
        await _editFood(food);
      case _FoodAction.editDefinition:
        await _editFood(food, editReusableDefinition: true);
      case _FoodAction.saveTemplate:
        await _saveFoodAsTemplate(food);
      case _FoodAction.remove:
        _removeFood(food);
      case null:
        break;
    }
  }

  String _foodActionSubtitle(FoodEntry food, AppLocalizations l10n) {
    final amount = food.amount == food.amount.roundToDouble()
        ? food.amount.round().toString()
        : food.amount.toStringAsFixed(1);
    final serving = food.unit.trim().isEmpty
        ? l10n.serving_amount(food.amount)
        : '$amount ${food.unit.trim()}';
    final energy = food.nutrition.isKnown('energyKcal')
        ? l10n.kcal_value(food.nutrition.energyKcal.round().toString())
        : '— kcal';
    final partial = food.nutrition.isPartial('energyKcal')
        ? ' (${l10n.nutrition_partial})'
        : '';
    return '$serving · $energy$partial';
  }

  MealLog _buildMeal({bool normalizeSkipped = false}) {
    final clearDetails = normalizeSkipped && _isSkipped;
    return MealLog(
      id: _meal.id,
      mealType: _mealType,
      customMealLabel: _customMealLabel?.trim().isEmpty == true
          ? null
          : _customMealLabel?.trim(),
      isLabelExplicitlyUnset: _isLabelExplicitlyUnset,
      mealContext: _mealContext,
      locationDescription: clearDetails || _mealContext != MealContext.other
          ? null
          : _locationDescription?.trim(),
      timestamp: _timePrecision == MealOccurrenceTimePrecision.unknown
          ? null
          : _timestamp,
      timePrecision: _timePrecision,
      timezone: _meal.timezone,
      isSkipped: _isSkipped,
      skipReason: normalizeSkipped && !_isSkipped ? null : _skipReason?.trim(),
      companyContext: clearDetails ? null : _companyContext,
      distractionContext: clearDetails ? null : _distractionContext,
      templateId: clearDetails ? null : _meal.templateId,
      foods: clearDetails ? [] : _meal.foods,
    );
  }

  String get _mealSnapshot => jsonEncode(_buildMeal().toJson());

  bool get _hasUnsavedChanges => _mealSnapshot != _initialMealSnapshot;

  bool get _isMealValid =>
      _buildMeal().isValidForSave(hasSelectedTime: _hasSelectedTime);

  String get _mealLabel {
    final customLabel = _customMealLabel?.trim();
    return customLabel?.isNotEmpty == true
        ? customLabel!
        : _mealType == MealType.other && _isLabelExplicitlyUnset
        ? AppLocalizations.of(context)!.meal_neutral_label
        : _getMealTypeLabel(_mealType);
  }

  String get _pageTitle => AppLocalizations.of(context)!.log_meal;

  void _pop([MealEntryResult? result]) {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  Future<void> _saveMeal() async {
    if (!_isMealValid) {
      setState(() => _hasAttemptedSave = true);
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final subject = appState.activeSubject;
    final historicalTarget = widget.historicalTarget;
    if (!_revalidateHistoricalEligibility()) return;
    try {
      if (subject != null) {
        await (widget.foodRepository ?? NutritionFoodRepository())
            .ensureDefinitions(subjectId: subject.id, foods: _meal.foods);
      }
    } catch (error, stackTrace) {
      StudyULogger.warning(
        'Nutrition definitions remain queued for retry: $error\n$stackTrace',
      );
      if (historicalTarget != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.could_not_save_results)));
        }
        return;
      }
    }
    if (!_revalidateHistoricalEligibility()) return;

    _meal = _buildMeal(normalizeSkipped: true);
    if (widget.existingMeal == null &&
        widget.historicalTarget != null &&
        _saveToMyItems &&
        !_meal.isSkipped) {
      try {
        final userId = subject?.id ?? 'anonymous';
        await TemplateViewModel(
          userId: userId,
          repository: widget.foodRepository,
        ).saveMealAsTemplate(name: _mealLabel, meal: _meal);
      } catch (error, stackTrace) {
        StudyULogger.error(
          'Failed to save historical meal to My items: $error\n$stackTrace',
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.could_not_save_results)));
        }
        return;
      }
    }
    _pop(SavedMealEntryResult(_meal, definitionMutated: _definitionMutated));
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showUnsavedChangesDialog(
      context,
      title: l10n.discard_meal_changes_title,
      message: l10n.discard_meal_changes_message,
      discardLabel: l10n.discard_changes,
      continueLabel: l10n.continue_editing,
    );
    if (!mounted) return;

    switch (action) {
      case UnsavedChangesAction.discard:
        _pop(_definitionMutated ? const DiscardedMealEntryResult() : null);
      case null:
        return;
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.delete_meal_title),
        content: Text(l10n.delete_meal_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.continue_label),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (shouldDelete == true && mounted && _revalidateHistoricalEligibility()) {
      _pop(const DeletedMealEntryResult());
    }
  }

  bool _revalidateHistoricalEligibility() {
    final target = widget.historicalTarget;
    if (target == null) return true;
    final subject = Provider.of<AppState>(context, listen: false).activeSubject;
    final valid =
        subject != null &&
        isEditableNutritionRecallDay(
          studyDaySnapshot: target.studyDaySnapshot,
          currentStudyDay: nutritionStudyDayFor(subject, DateTime.now()),
          hasUnambiguousPeriod: true,
        );
    if (!valid && mounted && !_allowPop) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.historical_edit_expired),
        ),
      );
      _pop();
    }
    return valid;
  }

  Future<void> _selectMealType() async {
    final selection = await showModalBottomSheet<_MealTypeSelection>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => _MealTypeSheet(
        mealType: _mealType,
        customMealLabel: _customMealLabel,
        customMealTypes: widget.task?.customMealTypes,
      ),
    );
    if (selection == null || !mounted) return;

    setState(() {
      _mealType = selection.type;
      _customMealLabel = selection.type == MealType.other
          ? selection.customLabel?.trim()
          : null;
      _isLabelExplicitlyUnset =
          selection.type == MealType.other &&
          (selection.customLabel?.trim().isEmpty ?? true);
    });
  }

  Future<void> _editMealDetails() async {
    final selection = await showModalBottomSheet<_MealDetailsSelection>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => _MealDetailsSheet(
        mealContext: _mealContext,
        companyContext: _companyContext,
        distractionContext: _distractionContext,
        locationDescription: _locationDescription,
      ),
    );
    if (selection == null || !mounted) return;

    setState(() {
      _mealContext = selection.mealContext;
      _companyContext = selection.companyContext;
      _distractionContext = selection.distractionContext;
      _locationDescription = selection.locationDescription;
    });
  }

  String _mealDetailsSummary(AppLocalizations l10n) {
    final details = <String>[
      if (_mealContext == MealContext.other &&
          _locationDescription?.trim().isNotEmpty == true)
        _locationDescription!.trim()
      else if (_mealContext != null)
        _getMealContextLabel(_mealContext!, l10n),
      if (_companyContext != null)
        _getCompanyContextLabel(_companyContext!, l10n),
      if (_distractionContext != null)
        _getDistractionContextLabel(_distractionContext!, l10n),
    ];
    return details.isEmpty ? l10n.not_added : details.join(' • ');
  }

  Future<void> _selectTime() async {
    final selection = await showModalBottomSheet<_TimeSelection>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => _TimeSelectionSheet(
        timestamp: _timestamp,
        precision: _hasSelectedTime ? _timePrecision : null,
      ),
    );
    if (selection == null || !mounted) return;

    if (selection.precision == MealOccurrenceTimePrecision.unknown) {
      setState(() {
        _timestamp = null;
        _timePrecision = selection.precision;
        _hasSelectedTime = true;
      });
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: selection.timestamp == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(selection.timestamp!),
    );
    if (picked == null || !mounted) return;
    final date = _timePrecision == MealOccurrenceTimePrecision.unknown
        ? widget.occurrenceDate ?? DateTime.now()
        : selection.timestamp ?? widget.occurrenceDate ?? DateTime.now();
    setState(() {
      _timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        picked.hour,
        picked.minute,
      );
      _timePrecision = selection.precision;
      _hasSelectedTime = true;
    });
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

  Future<void> _openMealBuilder() async {
    try {
      final foods = flattenNutritionFoodEntries(_meal.foods);
      if (!mounted) return;
      await Navigator.of(context).push(
        MealCreatorScreen.route(
          initialFoods: foods,
          initialName: _mealLabel,
          showExpansionNotice: _meal.foods.any(
            (food) => food.entryType == FoodEntryType.meal,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.nutrition_invalid_saved_meal,
          ),
        ),
      );
    }
  }

  Future<void> _saveFoodAsTemplate(FoodEntry food) async {
    if (!_allowMeals && food.entryType == FoodEntryType.meal) return;
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final templateType = food.entryType == FoodEntryType.meal
        ? TemplateType.meal
        : TemplateType.food;

    final result = await SaveTemplateDialog.show(
      context,
      initialName: food.name,
      templateType: templateType,
    );

    if (result != null && mounted) {
      final viewModel = TemplateViewModel(
        userId: userId,
        repository: widget.foodRepository,
      );
      food.templateId = await viewModel.saveFoodAsTemplate(
        name: result.name,
        food: food,
        tags: result.tags,
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.template_saved)));
      }
    }
  }

  Future<void> _showPhotoRecall() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.photoRecallTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.photoRecallSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(context)
                          .closeButtonTooltip,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: PhotoRecallSection(
                    date: _occurrenceDate,
                    onPhotoTap: (photo) {
                      PhotoViewerDialog.show(
                        context,
                        photoId: photo.id,
                        photoDate: photo.createDateTime,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: _allowPop || !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_pageTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: _isSkipped || _isMealValid ? _saveMeal : null,
                child: Text(
                  widget.existingMeal == null ? l10n.done_label : l10n.save,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.existingMeal == null &&
                  widget.historicalTarget != null)
                CheckboxListTile(
                  value: _saveToMyItems,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.save_to_my_items),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) =>
                      setState(() => _saveToMyItems = value ?? false),
                ),
              if (!_isSkipped) ...[
                _FoodListSection(
                  meal: _meal,
                  isSkipped: false,
                  showValidationError: _hasAttemptedSave && _meal.foods.isEmpty,
                  allowMeals: _allowMeals,
                  onAddFood: _addFood,
                  onFoodTap: _adjustFoodQuantity,
                  onFoodActions: _showFoodActions,
                  onSaveToLibrary:
                      widget.historicalTarget == null && _allowMeals
                      ? _openMealBuilder
                      : null,
                ),
                const SizedBox(height: 16),
              ],
              if (widget.existingMeal?.isSkipped == true)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(l10n.skipped_this_meal),
                          value: _isSkipped,
                          onChanged: (value) {
                            setState(() => _isSkipped = value);
                          },
                        ),
                        if (_isSkipped)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: TextField(
                              controller: _skipReasonController,
                              decoration: InputDecoration(
                                labelText: l10n.reason_for_skipping,
                                errorText:
                                    _hasAttemptedSave &&
                                        _skipReason?.trim().isNotEmpty != true
                                    ? l10n.enter_skip_reason
                                    : null,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() => _skipReason = value);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (!_isSkipped) ...[
                const SizedBox(height: 16),
                _TimeSelector(
                  timestamp: _timestamp,
                  precision: _timePrecision,
                  hasSelection: _hasSelectedTime,
                  showValidationError:
                      _hasAttemptedSave &&
                      !_buildMeal().hasValidTimeAnswer(
                        hasSelectedTime: _hasSelectedTime,
                      ),
                  onSelectTime: _selectTime,
                ),
                const SizedBox(height: 8),
                _SettingsRow(
                  icon: Icons.label_outline,
                  label: l10n.meal_label,
                  value: _mealLabel == l10n.meal_neutral_label
                      ? l10n.no_meal_label
                      : _mealLabel,
                  onTap: _selectMealType,
                ),
                if (widget.task?.collectMealContext ?? true) ...[
                  const SizedBox(height: 16),
                  _SettingsRow(
                    icon: Icons.tune,
                    label: l10n.meal_details,
                    value: _mealDetailsSummary(l10n),
                    onTap: _editMealDetails,
                  ),
                ],
                if (_meal.foods.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  MealNutritionSummaryCard(meal: _meal),
                ],
              ],
              if (widget.existingMeal != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.delete_meal),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class const _SettingsRow({
  required final IconData icon,
  required final String label,
  required final String value,
  required final VoidCallback onTap,
  final String? errorText,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(label),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value),
            if (errorText != null)
              Text(
                errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class const _MealTypeSheet({
  required final MealType mealType,
  required final String? customMealLabel,
  final List<String>? customMealTypes,
}) extends StatefulWidget {
  @override
  State<_MealTypeSheet> createState() => _MealTypeSheetState();
}

class _MealTypeSheetState() extends State<_MealTypeSheet> {
  late final TextEditingController _customLabelController;
  late String _selectedKey;
  bool _editingOther = false;

  @override
  void initState() {
    super.initState();
    _customLabelController = TextEditingController(
      text: widget.customMealLabel ?? '',
    );
    _selectedKey = _initialChoiceKey;
  }

  String get _initialChoiceKey {
    if (widget.mealType != MealType.other) return widget.mealType.name;
    final customLabel = widget.customMealLabel?.trim();
    if (customLabel?.isNotEmpty == true) {
      if (widget.customMealTypes?.contains(customLabel) == true) {
        return 'custom:$customLabel';
      }
      return 'custom-editor';
    }
    return 'none';
  }

  void _onChoiceChanged(String? key) {
    if (key == null) return;
    if (key == 'custom-editor') {
      setState(() {
        _selectedKey = key;
        _editingOther = true;
      });
      return;
    }
    if (key == 'none') {
      Navigator.of(context).pop(const _MealTypeSelection(MealType.other, ''));
      return;
    }
    if (key.startsWith('custom:')) {
      Navigator.of(context)
          .pop(_MealTypeSelection(MealType.other, key.substring(7)));
      return;
    }
    final type = MealType.values.firstWhere((value) => value.name == key);
    Navigator.of(context).pop(_MealTypeSelection(type));
  }

  @override
  void dispose() {
    _customLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final customTypes = widget.customMealTypes;
    final visibleCustomTypes =
        customTypes?.where((label) => label != l10n.meal_type_other).toList() ??
        const <String>[];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.meal_type_label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _selectedKey == 'custom-editor' && !_editingOther
                  ? null
                  : _selectedKey,
              onChanged: _onChoiceChanged,
              child: Column(
                children: [
                  for (final type in [
                    MealType.breakfast,
                    MealType.lunch,
                    MealType.dinner,
                    MealType.snack,
                  ])
                    RadioListTile<String>(
                      value: type.name,
                      title: Text(_getMealTypeLabel(type, l10n)),
                    ),
                  ...visibleCustomTypes.map(
                    (label) => RadioListTile<String>(
                      value: 'custom:$label',
                      title: Text(label),
                    ),
                  ),
                  RadioListTile<String>(
                    value: 'custom-editor',
                    title: Text(l10n.custom_meal_label),
                  ),
                  RadioListTile<String>(
                    value: 'none',
                    title: Text(l10n.no_meal_label),
                  ),
                ],
              ),
            ),
            if (_editingOther) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customLabelController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.custom_meal_label,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  _MealTypeSelection(
                    MealType.other,
                    _customLabelController.text.trim(),
                  ),
                ),
                child: Text(l10n.apply),
              ),
            ],
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

class const _TimeSelectionSheet({
  required final DateTime? timestamp,
  required final MealOccurrenceTimePrecision? precision,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: RadioGroup<MealOccurrenceTimePrecision>(
        groupValue: precision,
        onChanged: (value) {
          final selectedPrecision = value ?? precision;
          if (selectedPrecision != null) {
            Navigator.of(context)
                .pop(_TimeSelection(timestamp, selectedPrecision));
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<MealOccurrenceTimePrecision>(
              value: MealOccurrenceTimePrecision.exact,
              toggleable: true,
              secondary: const Icon(Icons.schedule),
              title: Text(l10n.time_exact),
              subtitle: Text(l10n.time_exact_description),
            ),
            RadioListTile<MealOccurrenceTimePrecision>(
              value: MealOccurrenceTimePrecision.approximate,
              toggleable: true,
              secondary: const Icon(Icons.more_time),
              title: Text(l10n.time_approximate),
              subtitle: Text(l10n.time_approximate_description),
            ),
            RadioListTile<MealOccurrenceTimePrecision>(
              value: MealOccurrenceTimePrecision.unknown,
              toggleable: true,
              secondary: const Icon(Icons.help_outline),
              title: Text(l10n.time_unknown),
            ),
          ],
        ),
      ),
    );
  }
}

class const _TimeSelector({
  required final DateTime? timestamp,
  required final MealOccurrenceTimePrecision precision,
  required final bool hasSelection,
  required final bool showValidationError,
  required final VoidCallback onSelectTime,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = !hasSelection
        ? l10n.time_picker_hint
        : timestamp == null || precision == MealOccurrenceTimePrecision.unknown
        ? l10n.time_not_remembered
        : precision == MealOccurrenceTimePrecision.approximate
        ? l10n.about_time(TimeOfDay.fromDateTime(timestamp!).format(context))
        : TimeOfDay.fromDateTime(timestamp!).format(context);
    return _SettingsRow(
      icon: Icons.access_time_rounded,
      label: l10n.time,
      value: value,
      errorText: showValidationError ? l10n.required_error : null,
      onTap: onSelectTime,
    );
  }
}

class const _FoodListSection({
  required final MealLog meal,
  required final bool isSkipped,
  required final VoidCallback onAddFood,
  required final Future<void> Function(FoodEntry) onFoodTap,
  required final Future<void> Function(FoodEntry) onFoodActions,
  required final VoidCallback? onSaveToLibrary,
  required final bool allowMeals,
  final bool showValidationError = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (isSkipped) {
      return const SizedBox.shrink();
    }

    if (meal.foods.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            allowMeals
                ? l10n.nutrition_logged_foods_and_meals
                : l10n.food_items,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _EmptyFoodState(
            theme: theme,
            l10n: l10n,
            onAddFood: onAddFood,
            showValidationError: showValidationError,
            allowMeals: allowMeals,
          ),
        ],
      );
    }

    final compactActions = MediaQuery.sizeOf(context).width < 480;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              allowMeals
                  ? l10n.nutrition_logged_foods_and_meals
                  : l10n.food_items,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (onSaveToLibrary != null)
                    if (compactActions)
                      IconButton(
                        tooltip: l10n.nutrition_create_saved_meal_from_log,
                        onPressed: onSaveToLibrary,
                        icon: const Icon(Icons.bookmark_add_outlined),
                      )
                    else
                      TextButton.icon(
                        onPressed: onSaveToLibrary,
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: Text(l10n.nutrition_create_saved_meal_from_log),
                      ),
                  if (compactActions)
                    IconButton(
                      tooltip: allowMeals
                          ? l10n.nutrition_add_food_or_saved_meal
                          : l10n.add_food_action,
                      onPressed: onAddFood,
                      icon: const Icon(Icons.add),
                    )
                  else
                    Tooltip(
                      message: allowMeals
                          ? l10n.nutrition_add_food_or_saved_meal
                          : l10n.add_food_action,
                      child: TextButton.icon(
                        onPressed: onAddFood,
                        icon: const Icon(Icons.add),
                        label: Text(
                          allowMeals
                              ? l10n.nutrition_add_food_or_saved_meal
                              : l10n.add_food_action,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...meal.foods.map(
          (food) => _FoodCard(
            food: food,
            onTap: () => onFoodTap(food),
            onOverflow: () => onFoodActions(food),
          ),
        ),
      ],
    );
  }
}

class const _EmptyFoodState({
  required final ThemeData theme,
  required final AppLocalizations l10n,
  required final VoidCallback onAddFood,
  required final bool showValidationError,
  required final bool allowMeals,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onAddFood,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 36,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  allowMeals
                      ? l10n.nutrition_add_food_or_saved_meal
                      : l10n.add_food_action,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  allowMeals
                      ? l10n.nutrition_add_food_or_choose_saved_meal
                      : l10n.tap_to_add_food,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (showValidationError) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.add_food_before_saving,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class const _FoodCard({
  required final FoodEntry food,
  required final VoidCallback onTap,
  required final VoidCallback onOverflow,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final icon = food.entryType == FoodEntryType.meal
        ? Icons.restaurant_menu_outlined
        : Icons.restaurant_outlined;
    final imageUrl = foodImageUrl(food);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: imageUrl == null
                            ? fallbackFoodIcon(theme, icon)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      fallbackFoodIcon(theme, icon),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              label: food.entryType == FoodEntryType.meal
                                  ? l10n.nutrition_saved_meal_badge
                                  : l10n.nutrition_food_badge,
                              child: Text(
                                food.entryType == FoodEntryType.meal
                                    ? l10n.nutrition_saved_meal_badge
                                    : l10n.nutrition_food_badge,
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                            Text(
                              food.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              foodTotalMetadata(l10n, food, 1),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              tooltip: l10n.more_options,
              onPressed: onOverflow,
            ),
          ],
        ),
      ),
    );
  }
}

class const _MealDetailsSheet({
  required final MealContext? mealContext,
  required final CompanyContext? companyContext,
  required final DistractionContext? distractionContext,
  required final String? locationDescription,
}) extends StatefulWidget {
  @override
  State<_MealDetailsSheet> createState() => _MealDetailsSheetState();
}

class _MealDetailsSheetState() extends State<_MealDetailsSheet> {
  late MealContext? _mealContext;
  CompanyContext? _companyContext;
  DistractionContext? _distractionContext;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _mealContext = widget.mealContext;
    _companyContext = widget.companyContext;
    _distractionContext = widget.distractionContext;
    _locationController = TextEditingController(
      text: widget.locationDescription ?? '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.meal_details,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _DropdownField<MealContext>(
              label: l10n.where_did_you_eat,
              value: _mealContext,
              items: const [null, ...MealContext.values],
              itemLabel: (value) => value == null
                  ? l10n.not_added
                  : _getMealContextLabel(value, l10n),
              onChanged: (value) => setState(() => _mealContext = value),
            ),
            if (_mealContext == MealContext.other) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: l10n.location_description,
                  hintText: l10n.location_description_hint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _DropdownField<CompanyContext>(
              label: l10n.who_were_you_with,
              value: _companyContext,
              items: const [null, ...CompanyContext.values],
              itemLabel: (value) => value == null
                  ? l10n.not_specified
                  : _getCompanyContextLabel(value, l10n),
              onChanged: (value) => setState(() => _companyContext = value),
            ),
            const SizedBox(height: 12),
            _DropdownField<DistractionContext>(
              label: l10n.distractions_during_meal,
              value: _distractionContext,
              items: const [null, ...DistractionContext.values],
              itemLabel: (value) => value == null
                  ? l10n.not_specified
                  : _getDistractionContextLabel(value, l10n),
              onChanged: (value) => setState(() => _distractionContext = value),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final location = _locationController.text.trim();
                    Navigator.of(context).pop(
                      _MealDetailsSelection(
                        mealContext: _mealContext,
                        companyContext: _companyContext,
                        distractionContext: _distractionContext,
                        locationDescription:
                            _mealContext == MealContext.other &&
                                location.isNotEmpty
                            ? location
                            : null,
                      ),
                    );
                  },
                  child: Text(l10n.apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _getMealTypeLabel(MealType type, AppLocalizations l10n) {
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

String _getMealContextLabel(MealContext value, AppLocalizations l10n) {
  switch (value) {
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

String _getCompanyContextLabel(CompanyContext value, AppLocalizations l10n) {
  switch (value) {
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
  DistractionContext value,
  AppLocalizations l10n,
) {
  switch (value) {
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

class const _DropdownField<T>({
  required final String label,
  required final T? value,
  required final List<T?> items,
  required final String Function(T?) itemLabel,
  required final ValueChanged<T?> onChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T?>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T?>(value: item, child: Text(itemLabel(item))),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
