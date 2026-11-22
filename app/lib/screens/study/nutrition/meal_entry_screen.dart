import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/photo_reference.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_action_menu.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_add_button.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_photo_widgets.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/services/nutrition_photo_storage.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/widgets/confirmation_dialog.dart';
import 'package:studyu_app/widgets/photo_recall_section.dart';
import 'package:studyu_app/widgets/photo_viewer_dialog.dart';
import 'package:studyu_app/widgets/unsaved_changes_dialog.dart';
import 'package:studyu_core/core.dart';
import 'package:uuid/uuid.dart';

sealed class const MealEntryResult();

final class const SavedMealEntryResult(
  final MealLog meal, {
  final bool definitionMutated = false,
  final int? expectedNutritionRevision,
  final NutritionPhotoChange? photoChange,
}) extends MealEntryResult;

final class const DeletedMealEntryResult() extends MealEntryResult;

final class const DiscardedMealEntryResult() extends MealEntryResult;

enum _LibraryEditChoice() {
  currentEntry,
  currentEntryAndLibrary,
}

typedef _MealTypeSelection = ({MealType type, String? customLabel});

class const _TimeSelection(
  final DateTime? timestamp,
  final MealOccurrenceTimePrecision precision,
);

class const _MealDetailsSelection({
  required final _MealTypeSelection mealType,
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
  final List<FoodEntry> initialFoods = const [],
  final PhotoReference? recallPhoto,
  final DateTime? occurrenceDate,
  final NutritionRecallPersistenceTarget? historicalTarget,
  final NutritionFoodRepository? foodRepository,
  final TemplateViewModel? templateViewModel,
  final bool Function()? canEditRecall,
  final Future<NutritionRecallPersistenceTarget?> Function(
    int? expectedRevision,
  )?
  prepareHistoricalDefinitionEdit,
  super.key,
}) extends StatefulWidget {
  static MaterialPageRoute<MealEntryResult> route({
    MealLog? existingMeal,
    NutritionTask? task,
    MealType? initialMealType,
    String? initialCustomMealLabel,
    List<FoodEntry> initialFoods = const [],
    PhotoReference? recallPhoto,
    DateTime? occurrenceDate,
    NutritionRecallPersistenceTarget? historicalTarget,
    NutritionFoodRepository? foodRepository,
    TemplateViewModel? templateViewModel,
    bool Function()? canEditRecall,
    Future<NutritionRecallPersistenceTarget?> Function(int? expectedRevision)?
    prepareHistoricalDefinitionEdit,
  }) => MaterialPageRoute(
    builder: (_) => MealEntryScreen(
      existingMeal: existingMeal,
      task: task,
      initialMealType: initialMealType,
      initialCustomMealLabel: initialCustomMealLabel,
      initialFoods: initialFoods,
      recallPhoto: recallPhoto,
      occurrenceDate: occurrenceDate,
      historicalTarget: historicalTarget,
      foodRepository: foodRepository,
      templateViewModel: templateViewModel,
      canEditRecall: canEditRecall,
      prepareHistoricalDefinitionEdit: prepareHistoricalDefinitionEdit,
    ),
  );

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState() extends State<MealEntryScreen> {
  late MealLog _meal;
  NutritionPhotoChange? _photoChange;
  late MealType _mealType;
  late MealContext? _mealContext;
  DateTime? _timestamp;
  String? _selectedTimeZoneName;
  late MealOccurrenceTimePrecision _timePrecision;
  late bool _hasSelectedTime;
  late bool _isSkipped;
  CompanyContext? _companyContext;
  DistractionContext? _distractionContext;
  String? _customMealLabel;
  String? _locationDescription;
  String? _skipReason;
  late final String _initialMealSnapshot;
  bool _allowPop = false;
  bool _hasAttemptedSave = false;
  bool _isSaving = false;
  bool _definitionMutated = false;
  int? _definitionMutationRevision;
  bool _saveToMyItems = true;
  String? _reusableFoodId;
  bool _propagateToCurrentStudyDay = false;

  bool get _allowMeals => widget.task?.allowMeals ?? true;
  NutritionFoodRepository get _foodRepository =>
      widget.foodRepository ??
      widget.templateViewModel?.repository ??
      NutritionFoodRepository();

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
      _locationDescription = _meal.locationDescription;
      _skipReason = _meal.skipReason;
    } else {
      _timestamp = null;
      _timePrecision = MealOccurrenceTimePrecision.unknown;
      _hasSelectedTime = false;
      _mealType = widget.initialMealType ?? MealType.other;
      _customMealLabel = widget.initialCustomMealLabel;
      _mealContext = null;
      _isSkipped = false;
      _meal = MealLog.withId(
        mealType: _mealType,
        mealContext: _mealContext,
        timestamp: _timestamp,
        timePrecision: _timePrecision,
        timezone: DateTime.now().timeZoneName,
        isSkipped: _isSkipped,
        foods: [],
      );
    }

    _skipReasonController = TextEditingController(text: _skipReason ?? '');
    _initialMealSnapshot = _mealSnapshot;
    if (widget.existingMeal == null) _addSelectedFoods(widget.initialFoods);
  }

  @override
  void dispose() {
    _skipReasonController.dispose();
    super.dispose();
  }

  Future<void> _openFoodSearch() async {
    if (_isSaving || !_revalidateHistoricalEligibility()) return;
    final result = await FoodSearchScreen.show(
      context,
      mealLabel: _mealLabel,
      initialFoods: _meal.foods,
      allowMeals: widget.task?.allowMeals ?? true,
      historicalMode: widget.historicalTarget != null,
      repository: widget.foodRepository,
      templateViewModel:
          widget.templateViewModel ??
          Provider.of<TemplateViewModel?>(context, listen: false),
    );
    if (!mounted || !_revalidateHistoricalEligibility()) return;
    if (result != null) {
      setState(() {
        _meal.foods
          ..clear()
          ..addAll(result.foods);
      });
    }
  }

  void _addSelectedFoods(List<FoodEntry> foods) {
    _meal.foods.addAll(
      _allowMeals
          ? foods
          : foods.where((food) => food.entryType != FoodEntryType.meal),
    );
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
        scrollable: true,
        title: Text(l10n.library_edit_title),
        content: Text(l10n.library_edit_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          OutlinedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _LibraryEditChoice.currentEntry),
            child: Text(l10n.library_edit_current_entry),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              _LibraryEditChoice.currentEntryAndLibrary,
            ),
            child: Text(l10n.library_edit_current_entry_and_library),
          ),
        ],
      ),
    );
  }

  Future<void> _editFood(
    FoodEntry food, {
    bool editReusableDefinition = false,
  }) async {
    if (_isSaving || !_revalidateHistoricalEligibility()) return;
    final isLibraryBacked = food.templateId?.isNotEmpty == true;
    var updateLibrary = false;
    if (!editReusableDefinition &&
        widget.historicalTarget == null &&
        isLibraryBacked) {
      final choice = await _chooseLibraryEdit();
      if (!mounted || choice == null || !_revalidateHistoricalEligibility()) {
        return;
      }
      updateLibrary = choice == _LibraryEditChoice.currentEntryAndLibrary;
    }

    final editableFood = editReusableDefinition || updateLibrary
        ? await _loadReusableEditorFood(food)
        : food;
    if (!mounted ||
        editableFood == null ||
        !_revalidateHistoricalEligibility()) {
      return;
    }
    var historicalTarget = widget.historicalTarget;
    final prepare = widget.prepareHistoricalDefinitionEdit;
    if (editReusableDefinition && prepare != null) {
      historicalTarget = await prepare(
        _definitionMutationRevision ?? historicalTarget?.nutritionRevision,
      );
      if (!mounted || historicalTarget == null) return;
    }
    if (editReusableDefinition &&
        editableFood.entryType == FoodEntryType.meal) {
      await _editCompositeMealDefinition(food, editableFood, historicalTarget);
      return;
    }
    final hasCurrentDayMatches =
        editReusableDefinition && await _hasCurrentStudyDayMatches(food.foodId);
    if (!mounted || !_revalidateHistoricalEligibility()) return;
    final FoodEntry? result;
    final showCurrentMealOnlyNotice =
        (editReusableDefinition || widget.historicalTarget != null) ||
        !isLibraryBacked;
    if (food.entryType == FoodEntryType.meal) {
      result = await Navigator.of(context).push(
        MealCreatorScreen.route(
          existingMeal: editableFood,
          editLoggedAmount: true,
          showCurrentMealOnlyNotice: showCurrentMealOnlyNotice,
          templateViewModel: widget.templateViewModel,
        ),
      );
    } else {
      result = await Navigator.of(context).push(
        FoodEntryScreen.route(
          existingFood: editableFood,
          editLoggedAmount: !editReusableDefinition,
          showSearchAction: false,
          historicalTarget: historicalTarget,
          editReusableDefinition: editReusableDefinition,
          hasCurrentStudyDayMatches: hasCurrentDayMatches,
          showCurrentMealOnlyNotice: showCurrentMealOnlyNotice,
          repository: widget.foodRepository,
          canEditRecall: _revalidateHistoricalEligibility,
          onHistoricalDefinitionSaved: (revision) {
            _definitionMutationRevision = revision;
          },
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
      final inheritedViewModel =
          widget.templateViewModel ??
          Provider.of<TemplateViewModel?>(context, listen: false);
      final viewModel =
          inheritedViewModel ??
          TemplateViewModel(
            userId: subject?.id ?? 'anonymous',
            repository: widget.foodRepository,
          );
      setState(() => _isSaving = true);
      try {
        final updatedTemplate = await viewModel.updateFoodTemplatePrototype(
          food.templateId!,
          normalizeNutritionFoodDefinition(edited),
          expectedVersionId: editableFood.foodVersionId,
        );
        if (updatedTemplate == null) {
          throw StateError('Nutrition item is unavailable.');
        }
        edited = cloneFoodEntry(edited)
          ..foodId = updatedTemplate.prototype.foodId
          ..foodVersionId = updatedTemplate.prototype.foodVersionId
          ..templateId = updatedTemplate.id;
      } catch (error, stackTrace) {
        StudyULogger.error(
          'Failed to update reusable nutrition item: $error\n$stackTrace',
        );
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          final message = NutritionFoodRepository.isVersionConflict(error)
              ? l10n.nutrition_food_definition_conflict
              : l10n.could_not_save_results;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
        return;
      } finally {
        if (inheritedViewModel == null) viewModel.dispose();
        if (mounted && !_allowPop) setState(() => _isSaving = false);
      }
    }

    if (!mounted || !_revalidateHistoricalEligibility()) return;
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

  Future<FoodEntry?> _loadReusableEditorFood(FoodEntry occurrence) async {
    final subject = context.read<AppState>().activeSubject;
    if (subject == null) return null;
    final l10n = AppLocalizations.of(context)!;
    try {
      final definition = await _foodRepository.loadCurrentFoodDefinition(
        subjectId: subject.id,
        foodId: occurrence.foodId,
      );
      return definition == null
          ? occurrence
          : applyNutritionFoodSnapshot(occurrence, definition);
    } catch (error, stackTrace) {
      StudyULogger.error(
        'Failed to load current nutrition definition: $error\n$stackTrace',
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.loading_error_title)));
      }
      return null;
    }
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

  Future<void> _editCompositeMealDefinition(
    FoodEntry existingMeal,
    FoodEntry editableMeal,
    NutritionRecallPersistenceTarget? historicalTarget,
  ) async {
    final editableDefinition = normalizeNutritionFoodDefinition(editableMeal);
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
    if (subject == null || historicalTarget == null) return;
    final currentStudyDay = _propagateToCurrentStudyDay
        ? nutritionStudyDayFor(subject, DateTime.now())
        : null;
    final repository = _foodRepository;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      final result = await repository.mutateHistoricalDefinition(
        subjectId: subject.id,
        snapshot: normalizeNutritionFoodDefinition(edited),
        expectedVersionId: editableMeal.foodVersionId,
        entryId: existingMeal.id,
        target: historicalTarget.toJson(),
        currentStudyDay: currentStudyDay,
        mutationId: const Uuid().v4(),
      );
      final updated = applyNutritionFoodSnapshot(
        existingMeal,
        result.definition.snapshot,
      );
      final progress = _reconcileProgress(subject, result.progress);
      final updatedRecall = progress
          .where((item) => item.completedAt == historicalTarget.completedAt)
          .firstOrNull;
      _definitionMutationRevision = updatedRecall?.nutritionRevision;
      final autoSaveManager = NutritionRecallAutoSaveManager();
      await Future.wait([
        if (_propagateToCurrentStudyDay)
          autoSaveManager.rewriteFoodDefinition(
            subjectId: subject.id,
            studyDaySnapshot: currentStudyDay!,
            definition: result.definition.snapshot,
            canonicalProgress: progress,
          ),
        autoSaveManager.rewriteFoodDefinition(
          subjectId: subject.id,
          studyDaySnapshot: historicalTarget.studyDaySnapshot,
          definition: result.definition.snapshot,
          canonicalProgress: progress,
          entryId: existingMeal.id,
        ),
      ]).then<void>((_) {}).onError((error, stackTrace) {
        StudyULogger.warning(
          'Could not synchronize the local draft after saving the food definition: '
          '$error\n$stackTrace',
        );
      });
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
        final message = NutritionFoodRepository.isVersionConflict(error)
            ? l10n.nutrition_food_definition_conflict
            : l10n.could_not_save_results;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted && !_allowPop) setState(() => _isSaving = false);
    }
  }

  List<SubjectProgress> _reconcileProgress(
    StudySubject subject,
    List<Map<String, dynamic>> canonicalRows,
  ) {
    final reconciled = [
      for (final row in canonicalRows)
        SupabaseQuery.extractSupabaseSingleRow<SubjectProgress>(row),
    ];
    for (final canonical in reconciled) {
      subject.applySavedProgress(canonical);
    }
    return reconciled;
  }

  void _removeFood(FoodEntry food) {
    if (_isSaving || !_revalidateHistoricalEligibility()) return;
    final index = _foodIndex(food.id);
    if (index == -1) return;
    setState(() => _meal.foods.removeAt(index));
  }

  Widget _buildFoodActionMenu(FoodEntry food) {
    final l10n = AppLocalizations.of(context)!;
    final isHistorical = widget.historicalTarget != null;
    final editLabel = isHistorical
        ? l10n.edit_this_entry
        : food.entryType == FoodEntryType.meal
        ? l10n.nutrition_edit_saved_meal
        : l10n.edit_food_title;

    return NutritionActionMenu(
      enabled: !_isSaving,
      itemBuilder: (context) {
        if (!_revalidateHistoricalEligibility()) return [];
        return [
          nutritionActionMenuItem(
            editLabel,
            Icons.edit_outlined,
            () => _editFood(food),
          ),
          if (isHistorical)
            nutritionActionMenuItem(
              l10n.edit_food_definition,
              Icons.sync_outlined,
              () => _editFood(food, editReusableDefinition: true),
            ),
          nutritionActionMenuItem(
            l10n.remove_from_meal,
            Icons.delete_outline,
            () => _removeFood(food),
            color: Theme.of(context).colorScheme.error,
          ),
        ];
      },
    );
  }

  MealLog _buildMeal({bool normalizeSkipped = false}) {
    final clearDetails = normalizeSkipped && _isSkipped;
    return MealLog(
      id: _meal.id,
      mealType: _mealType,
      customMealLabel: _customMealLabel?.trim().isEmpty == true
          ? null
          : _customMealLabel?.trim(),
      mealContext: _mealContext,
      locationDescription: clearDetails || _mealContext != MealContext.other
          ? null
          : _locationDescription?.trim(),
      timestamp: _timePrecision == MealOccurrenceTimePrecision.unknown
          ? null
          : _timestamp,
      timePrecision: _timePrecision,
      timezone: _selectedTimeZoneName ?? _meal.timezone,
      isSkipped: _isSkipped,
      skipReason: normalizeSkipped && !_isSkipped ? null : _skipReason?.trim(),
      companyContext: clearDetails ? null : _companyContext,
      distractionContext: clearDetails ? null : _distractionContext,
      templateId: clearDetails ? null : _meal.templateId,
      foods: clearDetails ? [] : _meal.foods,
    );
  }

  String get _mealSnapshot => jsonEncode(_buildMeal().toJson());

  bool get _hasUnsavedChanges =>
      _photoChange != null || _mealSnapshot != _initialMealSnapshot;

  bool get _isMealValid =>
      _buildMeal().isValidForSave(hasSelectedTime: _hasSelectedTime);

  String get _mealLabel {
    final customLabel = _customMealLabel?.trim();
    return customLabel?.isNotEmpty == true
        ? customLabel!
        : _mealType == MealType.other
        ? AppLocalizations.of(context)!.meal_neutral_label
        : _getMealTypeLabel(_mealType);
  }

  _MealTypeSelection get _mealTypeSelection {
    final customLabel = _customMealLabel?.trim();
    return (
      type: _mealType,
      customLabel: customLabel?.isNotEmpty == true ? customLabel : null,
    );
  }

  String get _pageTitle => AppLocalizations.of(context)!.log_meal;

  void _pop([MealEntryResult? result]) {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context).pop(result);
      }
    });
  }

  Future<void> _saveMeal() async {
    if (_isSaving) return;
    if (!_isMealValid) {
      setState(() => _hasAttemptedSave = true);
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final subject = appState.activeSubject;
    final historicalTarget = widget.historicalTarget;
    if (!_revalidateHistoricalEligibility()) return;
    setState(() => _isSaving = true);
    try {
      final meal = _buildMeal(normalizeSkipped: true);
      meal.foods = meal.foods.map(cloneFoodEntry).toList();
      try {
        if (subject != null && appState.trackParticipantProgress) {
          await _foodRepository.ensureDefinitions(
            subjectId: subject.id,
            foods: meal.foods,
          );
        }
      } catch (error, stackTrace) {
        StudyULogger.warning(
          'Nutrition definitions remain queued for retry: $error\n$stackTrace',
        );
        if (historicalTarget != null &&
            !NutritionRecallAutoSaveManager.isRetryableError(error)) {
          rethrow;
        }
      }
      if (!mounted || !_revalidateHistoricalEligibility()) return;

      if (widget.existingMeal == null &&
          historicalTarget != null &&
          _saveToMyItems &&
          !meal.isSkipped) {
        final viewModel = TemplateViewModel(
          userId: subject?.id ?? 'anonymous',
          repository: widget.foodRepository,
        );
        try {
          await viewModel.saveMealAsTemplate(
            name: _mealLabel,
            meal: meal,
            foodId: _reusableFoodId ??= const Uuid().v4(),
          );
        } catch (error) {
          if (!NutritionRecallAutoSaveManager.isRetryableError(error)) {
            rethrow;
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.could_not_save_results)),
            );
          }
        } finally {
          viewModel.dispose();
        }
      }
      if (!mounted || !_revalidateHistoricalEligibility()) return;

      _meal = meal;
      _pop(
        SavedMealEntryResult(
          meal,
          definitionMutated: _definitionMutated,
          expectedNutritionRevision: _definitionMutationRevision,
          photoChange: meal.isSkipped ? null : _photoChange,
        ),
      );
    } catch (error, stackTrace) {
      StudyULogger.error('Failed to save nutrition meal: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.could_not_save_results)));
      }
    } finally {
      if (mounted && !_allowPop) setState(() => _isSaving = false);
    }
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
    final shouldDelete = await showConfirmationDialog(
      context,
      title: l10n.delete_meal_title,
      message: l10n.delete_meal_message,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (shouldDelete &&
        mounted &&
        !_isSaving &&
        _revalidateHistoricalEligibility()) {
      _pop(const DeletedMealEntryResult());
    }
  }

  bool _revalidateHistoricalEligibility() {
    if (widget.canEditRecall?.call() == false) return false;
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
        value: _mealTypeSelection,
        customMealTypes: widget.task?.customMealTypes,
      ),
    );
    if (selection == null || !mounted) return;

    setState(() {
      _mealType = selection.type;
      _customMealLabel = selection.customLabel;
    });
  }

  Future<void> _editMealDetails() async {
    final selection = await showModalBottomSheet<_MealDetailsSelection>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _MealDetailsSheet(
        mealType: _mealTypeSelection,
        customMealTypes: widget.task?.customMealTypes,
        mealContext: _mealContext,
        companyContext: _companyContext,
        distractionContext: _distractionContext,
        locationDescription: _locationDescription,
      ),
    );
    if (selection == null || !mounted) return;

    setState(() {
      _mealType = selection.mealType.type;
      _customMealLabel = selection.mealType.customLabel;
      _mealContext = selection.mealContext;
      _companyContext = selection.companyContext;
      _distractionContext = selection.distractionContext;
      _locationDescription = selection.locationDescription;
    });
  }

  String _mealDetailsSummary(AppLocalizations l10n) {
    final details = <String>[
      if (_mealType != MealType.other || _mealTypeSelection.customLabel != null)
        _mealLabel,
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
    return details.isEmpty ? l10n.optional : details.join(' • ');
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

    final existingLocalTime =
        (selection.timestamp ?? widget.recallPhoto?.createDateTime)?.toLocal();
    final picked = await showTimePicker(
      context: context,
      initialTime: existingLocalTime == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(existingLocalTime),
    );
    if (picked == null || !mounted) return;
    final selectedDay = widget.occurrenceDate;
    final DateTime? timestamp;
    if (selectedDay?.isUtc == true) {
      final times = localMealTimesOnUtcDay(
        selectedDay!,
        hour: picked.hour,
        minute: picked.minute,
      );
      if (times.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.time_picker_validation_range,
            ),
          ),
        );
        return;
      }
      timestamp = times.length == 1
          ? times.single
          : await _chooseLocalMealTime(times);
    } else {
      final date = existingLocalTime ?? selectedDay ?? DateTime.now();
      timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        picked.hour,
        picked.minute,
      );
    }
    final selectedTime = timestamp;
    if (selectedTime == null || !mounted) return;
    _setMealTime(selectedTime, selection.precision);
  }

  bool _canUseCurrentTime(DateTime now) {
    final selectedDay = widget.occurrenceDate;
    return selectedDay == null ||
        DateUtils.isSameDay(selectedDay, selectedDay.isUtc ? now.toUtc() : now);
  }

  void _setTimeToNow() {
    final now = DateTime.now();
    if (_canUseCurrentTime(now)) {
      _setMealTime(now, MealOccurrenceTimePrecision.exact);
    }
  }

  void _setMealTime(DateTime localTime, MealOccurrenceTimePrecision precision) {
    setState(() {
      _timestamp = widget.occurrenceDate?.isUtc == true
          ? localTime.toUtc()
          : localTime;
      _selectedTimeZoneName = localTime.timeZoneName;
      _timePrecision = precision;
      _hasSelectedTime = true;
    });
  }

  Future<DateTime?> _chooseLocalMealTime(List<DateTime> times) {
    final l10n = AppLocalizations.of(context)!;
    final material = MaterialLocalizations.of(context);
    return showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.datetime_picker_validation_required),
        children: [
          for (final time in times)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, time),
              child: Text(
                '${material.formatMediumDate(time)} · '
                '${TimeOfDay.fromDateTime(time).format(dialogContext)} '
                '${time.timeZoneName}',
              ),
            ),
        ],
      ),
    );
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
          templateViewModel: widget.templateViewModel,
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

  void _showRecallPhoto(PhotoReference photo) {
    PhotoViewerDialog.show(
      context,
      photoId: photo.id,
      photoDate: photo.createDateTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasValidTime = _buildMeal().hasValidTimeAnswer(
      hasSelectedTime: _hasSelectedTime,
    );
    final saveHint = _isSkipped
        ? null
        : _meal.foods.isEmpty
        ? l10n.add_food_before_saving
        : !hasValidTime
        ? l10n.nutrition_select_time_to_save
        : null;

    return PopScope(
      canPop: _allowPop || (!_isSaving && !_hasUnsavedChanges),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isSaving) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_pageTitle)),
        bottomNavigationBar: Material(
          color: theme.colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (saveHint != null) ...[
                        Text(
                          saveHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      FilledButton.icon(
                        onPressed: !_isSaving && (_isSkipped || _isMealValid)
                            ? _saveMeal
                            : null,
                        icon: const Icon(Icons.check),
                        label: Text(l10n.nutrition_save_meal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.recallPhoto case final photo?) ...[
                Tooltip(
                  message: l10n.photoRecallTapToEnlarge,
                  child: SizedBox.square(
                    dimension: 128,
                    child: PhotoRecallThumbnail(
                      photo: photo,
                      onTap: () => _showRecallPhoto(photo),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
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
                if (nutritionPhotoScope(context.watch<AppState?>())
                    case final scope?)
                  NutritionPhotoEditor(
                    photoKey: nutritionPhotoKey(
                      scope,
                      NutritionPhotoKind.meal,
                      _meal.id,
                    ),
                    change: _photoChange,
                    onChanged: (change) =>
                        setState(() => _photoChange = change),
                    enabled: !_isSaving,
                  ),
                _FoodListSection(
                  meal: _meal,
                  showValidationError: _hasAttemptedSave && _meal.foods.isEmpty,
                  allowMeals: _allowMeals,
                  onAddFood: _openFoodSearch,
                  onFoodTap: _editFood,
                  foodActionMenuBuilder: _buildFoodActionMenu,
                  onSaveToLibrary:
                      widget.historicalTarget == null && _allowMeals
                      ? _openMealBuilder
                      : null,
                ),
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
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _TimeSelector(
                        timestamp: _timestamp,
                        precision: _timePrecision,
                        hasSelection: _hasSelectedTime,
                        showValidationError: _hasAttemptedSave && !hasValidTime,
                        onSelectTime: _selectTime,
                        onSetNow: _canUseCurrentTime(DateTime.now())
                            ? _setTimeToNow
                            : null,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      if (widget.task?.collectMealContext ?? true)
                        _SettingsRow(
                          icon: Icons.tune,
                          label: l10n.meal_details,
                          value: _mealDetailsSummary(l10n),
                          onTap: _editMealDetails,
                        )
                      else
                        _SettingsRow(
                          icon: Icons.label_outline,
                          label: l10n.meal_label,
                          value: _mealTypeChoiceLabel(_mealTypeSelection, l10n),
                          onTap: _selectMealType,
                        ),
                    ],
                  ),
                ),
              ],
              if (widget.existingMeal != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _confirmDelete,
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
  final bool inlineChevron = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      minLeadingWidth: 24,
      horizontalTitleGap: 12,
      title: Text(label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (inlineChevron)
            Row(
              spacing: 2,
              children: [
                Flexible(child: Text(value)),
                const Icon(Icons.chevron_right, size: 18),
              ],
            )
          else
            Text(value),
          if (errorText != null)
            Text(
              errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      trailing: inlineChevron ? null : const Icon(Icons.chevron_right),
    );
  }
}

class const _MealTypeSheet({
  required final _MealTypeSelection value,
  final List<String>? customMealTypes,
}) extends StatelessWidget {
  Widget _choiceTile(
    BuildContext context, {
    required _MealTypeSelection choice,
    required String label,
  }) {
    final selected =
        value.type == choice.type &&
        (value.type != MealType.other ||
            (value.customLabel ?? '') == (choice.customLabel ?? ''));
    return ListTile(
      leading: Icon(_mealTypeChoiceIcon(choice)),
      title: Text(label),
      selected: selected,
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: () => Navigator.of(context).pop(choice),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.meal_type_label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final choice in _mealTypeChoices(l10n, customMealTypes))
              _choiceTile(
                context,
                choice: choice,
                label: _mealTypeChoiceLabel(choice, l10n),
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
  required final VoidCallback? onSetNow,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = !hasSelection
        ? l10n.time_picker_hint
        : timestamp == null || precision == MealOccurrenceTimePrecision.unknown
        ? l10n.time_not_remembered
        : precision == MealOccurrenceTimePrecision.approximate
        ? l10n.about_time(
            TimeOfDay.fromDateTime(timestamp!.toLocal()).format(context),
          )
        : TimeOfDay.fromDateTime(timestamp!.toLocal()).format(context);
    return Row(
      children: [
        Expanded(
          child: _SettingsRow(
            icon: Icons.access_time_rounded,
            label: l10n.time,
            value: value,
            errorText: showValidationError ? l10n.required_error : null,
            onTap: onSelectTime,
            inlineChevron: true,
          ),
        ),
        if (onSetNow != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: TextButton(onPressed: onSetNow, child: Text(l10n.time_now)),
          ),
      ],
    );
  }
}

class const _FoodListSection({
  required final MealLog meal,
  required final VoidCallback onAddFood,
  required final Future<void> Function(FoodEntry) onFoodTap,
  required final Widget Function(FoodEntry) foodActionMenuBuilder,
  required final VoidCallback? onSaveToLibrary,
  required final bool allowMeals,
  final bool showValidationError = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final saveToLibrary = onSaveToLibrary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                l10n.nutrition_meal_items,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              NutritionAddButton(
                label: l10n.add_food,
                tooltip: allowMeals
                    ? l10n.nutrition_add_food_or_saved_meal
                    : null,
                onPressed: onAddFood,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (meal.foods.isEmpty)
          SizedBox(
            width: double.infinity,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  showValidationError
                      ? l10n.add_food_before_saving
                      : l10n.no_foods_added,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: showValidationError
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ...meal.foods.map(
            (food) => _FoodCard(
              food: food,
              onTap: () => onFoodTap(food),
              actionMenu: foodActionMenuBuilder(food),
            ),
          ),
        if (meal.foods.isNotEmpty && saveToLibrary != null)
          Tooltip(
            message: l10n.nutrition_create_saved_meal_from_log,
            child: TextButton.icon(
              onPressed: saveToLibrary,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: Text(l10n.save_to_my_items_action),
            ),
          ),
      ],
    );
  }
}

class const _FoodCard({
  required final FoodEntry food,
  required final VoidCallback onTap,
  required final Widget actionMenu,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isSavedMeal = food.entryType == FoodEntryType.meal;
    final icon = isSavedMeal
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
                        child: NutritionPhotoThumbnail(
                          photoKey: nutritionPhotoKey(
                            nutritionPhotoScope(context.watch<AppState?>()),
                            NutritionPhotoKind.item,
                            food.foodId,
                          ),
                          fallback: imageUrl == null
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isSavedMeal)
                              Text(
                                l10n.nutrition_saved_meal_badge,
                                style: theme.textTheme.labelSmall,
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
            actionMenu,
          ],
        ),
      ),
    );
  }
}

class const _MealDetailsSheet({
  required final _MealTypeSelection mealType,
  required final List<String>? customMealTypes,
  required final MealContext? mealContext,
  required final CompanyContext? companyContext,
  required final DistractionContext? distractionContext,
  required final String? locationDescription,
}) extends StatefulWidget {
  @override
  State<_MealDetailsSheet> createState() => _MealDetailsSheetState();
}

class _MealDetailsSheetState() extends State<_MealDetailsSheet> {
  late _MealTypeSelection _mealType;
  late MealContext? _mealContext;
  CompanyContext? _companyContext;
  DistractionContext? _distractionContext;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _mealType = widget.mealType;
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
    final mealTypeChoices = _mealTypeChoices(l10n, widget.customMealTypes);
    if (!mealTypeChoices.contains(widget.mealType)) {
      mealTypeChoices.insert(1, widget.mealType);
    }
    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
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
                  Text(
                    l10n.meal_details,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _MealDetailChoices<_MealTypeSelection>(
                    label: l10n.meal_label,
                    value: _mealType,
                    choices: mealTypeChoices,
                    choiceLabel: (value) => _mealTypeChoiceLabel(value, l10n),
                    choiceIcon: _mealTypeChoiceIcon,
                    onChanged: (value) => setState(() => _mealType = value),
                  ),
                  const SizedBox(height: 12),
                  _MealDetailChoices<MealContext?>(
                    label: l10n.where_did_you_eat,
                    value: _mealContext,
                    choices: const [null, ...MealContext.values],
                    choiceLabel: (value) => value == null
                        ? l10n.not_added
                        : _getMealContextLabel(value, l10n),
                    choiceIcon: (value) => switch (value) {
                      null => Icons.remove,
                      MealContext.home => Icons.home_outlined,
                      MealContext.restaurant => Icons.restaurant_outlined,
                      MealContext.takeout => Icons.takeout_dining_outlined,
                      MealContext.vending => Icons.local_drink_outlined,
                      MealContext.other => Icons.more_horiz,
                    },
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
                  _MealDetailChoices<CompanyContext?>(
                    label: l10n.who_were_you_with,
                    value: _companyContext,
                    choices: const [null, ...CompanyContext.values],
                    choiceLabel: (value) => value == null
                        ? l10n.not_specified
                        : _getCompanyContextLabel(value, l10n),
                    choiceIcon: (value) => switch (value) {
                      null => Icons.remove,
                      CompanyContext.alone => Icons.person_outline,
                      CompanyContext.family => Icons.family_restroom_outlined,
                      CompanyContext.friends => Icons.group_outlined,
                      CompanyContext.colleagues => Icons.badge_outlined,
                      CompanyContext.other => Icons.more_horiz,
                    },
                    onChanged: (value) =>
                        setState(() => _companyContext = value),
                  ),
                  const SizedBox(height: 12),
                  _MealDetailChoices<DistractionContext?>(
                    label: l10n.distractions_during_meal,
                    value: _distractionContext,
                    choices: const [null, ...DistractionContext.values],
                    choiceLabel: (value) => value == null
                        ? l10n.not_specified
                        : _getDistractionContextLabel(value, l10n),
                    choiceIcon: (value) => switch (value) {
                      null => Icons.remove,
                      DistractionContext.none =>
                        Icons.notifications_off_outlined,
                      DistractionContext.tv => Icons.tv_outlined,
                      DistractionContext.phone => Icons.smartphone_outlined,
                      DistractionContext.work => Icons.work_outlined,
                      DistractionContext.other => Icons.more_horiz,
                    },
                    onChanged: (value) =>
                        setState(() => _distractionContext = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final location = _locationController.text.trim();
                  Navigator.of(context).pop(
                    _MealDetailsSelection(
                      mealType: _mealType,
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
    );
  }
}

IconData _mealTypeChoiceIcon(_MealTypeSelection choice) =>
    switch (choice.type) {
      MealType.breakfast => Icons.breakfast_dining_outlined,
      MealType.brunch => Icons.brunch_dining_outlined,
      MealType.lunch => Icons.lunch_dining_outlined,
      MealType.dinner => Icons.dinner_dining_outlined,
      MealType.snack => Icons.cookie_outlined,
      MealType.other =>
        choice.customLabel == null
            ? Icons.label_off_outlined
            : Icons.restaurant_outlined,
    };

List<_MealTypeSelection> _mealTypeChoices(
  AppLocalizations l10n,
  List<String>? customMealTypes,
) => [
  (type: MealType.other, customLabel: null),
  for (final type in const [
    MealType.breakfast,
    MealType.lunch,
    MealType.dinner,
    MealType.snack,
  ])
    (type: type, customLabel: null),
  for (final label in customMealTypes ?? const <String>[])
    if (label != l10n.meal_type_other)
      (type: MealType.other, customLabel: label.trim()),
];

String _mealTypeChoiceLabel(_MealTypeSelection choice, AppLocalizations l10n) =>
    choice.customLabel ??
    (choice.type == MealType.other
        ? l10n.no_meal_label
        : _getMealTypeLabel(choice.type, l10n));

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

class const _MealDetailChoices<T>({
  required final String label,
  required final T value,
  required final List<T> choices,
  required final String Function(T) choiceLabel,
  required final IconData Function(T) choiceIcon,
  required final ValueChanged<T> onChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final choice in choices)
              ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    Icon(choiceIcon(choice), size: 18),
                    Flexible(child: Text(choiceLabel(choice))),
                  ],
                ),
                selected: value == choice,
                onSelected: (_) => onChanged(choice),
              ),
          ],
        ),
      ],
    );
  }
}
