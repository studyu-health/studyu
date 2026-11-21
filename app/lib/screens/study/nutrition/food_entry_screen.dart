import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_editor_layout.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_photo_widgets.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_save_button.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/services/nutrition_photo_storage.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/widgets/unsaved_changes_dialog.dart';
import 'package:studyu_core/core.dart';
import 'package:uuid/uuid.dart';

class const FoodEntryScreen({
  final FoodEntry? existingFood,

  /// Confidence score from AI analysis (0.0 to 1.0).
  /// If provided, shows a banner indicating AI-estimated values.
  final double? confidenceScore,
  final bool showSearchAction = true,
  final String? mealLabel,
  final bool editLoggedAmount = false,
  final bool isRecipeIngredient = false,
  final bool historicalMode = false,
  final NutritionRecallPersistenceTarget? historicalTarget,
  final bool editReusableDefinition = false,
  final ValueChanged<int>? onHistoricalDefinitionSaved,
  final bool hasCurrentStudyDayMatches = false,
  final bool showCurrentMealOnlyNotice = false,
  final bool isExternalLibraryCopy = false,
  final NutritionFoodRepository? repository,
  final TemplateViewModel? templateViewModel,
  final bool Function()? canEditRecall,
  final ValueChanged<NutritionPhotoChange?>? onPhotoChanged,
  final void Function(FoodEntry food, Offset? source)? onSavedToSelection,
  super.key,
}) extends StatefulWidget {
  this
    : assert(!editReusableDefinition || historicalTarget != null),
      assert(!isExternalLibraryCopy || existingFood != null);

  static MaterialPageRoute<FoodEntry> route({
    FoodEntry? existingFood,
    double? confidenceScore,
    bool showSearchAction = true,
    String? mealLabel,
    bool editLoggedAmount = false,
    bool isRecipeIngredient = false,
    bool historicalMode = false,
    NutritionRecallPersistenceTarget? historicalTarget,
    bool editReusableDefinition = false,
    ValueChanged<int>? onHistoricalDefinitionSaved,
    bool hasCurrentStudyDayMatches = false,
    bool showCurrentMealOnlyNotice = false,
    bool isExternalLibraryCopy = false,
    NutritionFoodRepository? repository,
    TemplateViewModel? templateViewModel,
    bool Function()? canEditRecall,
    void Function(FoodEntry food, Offset? source)? onSavedToSelection,
    ValueChanged<NutritionPhotoChange?>? onPhotoChanged,
  }) => MaterialPageRoute(
    builder: (_) => FoodEntryScreen(
      existingFood: existingFood,
      confidenceScore: confidenceScore,
      showSearchAction: showSearchAction,
      mealLabel: mealLabel,
      editLoggedAmount: editLoggedAmount,
      isRecipeIngredient: isRecipeIngredient,
      historicalMode: historicalMode,
      historicalTarget: historicalTarget,
      editReusableDefinition: editReusableDefinition,
      onHistoricalDefinitionSaved: onHistoricalDefinitionSaved,
      hasCurrentStudyDayMatches: hasCurrentStudyDayMatches,
      showCurrentMealOnlyNotice: showCurrentMealOnlyNotice,
      isExternalLibraryCopy: isExternalLibraryCopy,
      repository: repository,
      templateViewModel: templateViewModel,
      canEditRecall: canEditRecall,
      onSavedToSelection: onSavedToSelection,
      onPhotoChanged: onPhotoChanged,
    ),
  );

  @override
  State<FoodEntryScreen> createState() => _FoodEntryScreenState();
}

class _FoodEntryScreenState() extends State<FoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _unitController;
  late TextEditingController _servingSizeController;
  late TextEditingController _portionReferenceController;
  late TextEditingController _yieldFactorController;
  late TextEditingController _ediblePortionController;

  // Nutrition controllers
  late TextEditingController _energyController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _sugarsController;
  late TextEditingController _fiberController;
  late TextEditingController _saturatedFatController;
  late TextEditingController _sodiumController;

  FoodEntryType _entryType = FoodEntryType.singleIngredient;
  PortionEstimationMethod _portionMethod =
      PortionEstimationMethod.householdMeasure;
  PortionState _portionState = PortionState.asServed;
  FoodSource _source = FoodSource.manual;
  bool _saveToMyItems = false;
  bool _propagateToCurrentStudyDay = false;
  late final String _initialSnapshot;
  bool _allowPop = false;
  bool _isSaving = false;
  String? _newFoodId;
  final GlobalKey _saveButtonKey = GlobalKey();
  NutritionPhotoChange? _photoChange;

  /// Whether the food entry data comes from AI analysis.
  bool get _isAiAnalyzed => widget.confidenceScore != null;

  /// Whether the confidence is low and fields should be highlighted.
  bool get _isLowConfidence =>
      widget.confidenceScore != null && widget.confidenceScore! < 0.6;

  bool get _showServings => widget.editLoggedAmount || widget.mealLabel != null;

  late final FoodEntry? _nutritionBasis = switch (widget.existingFood) {
    final food?
        when (_showServings || widget.editReusableDefinition) &&
            food.amount.isFinite &&
            food.amount > 0 =>
      rescaleFoodAmount(food, 1),
    final food => food,
  };

  @override
  void initState() {
    super.initState();
    if (widget.existingFood != null) {
      final food = widget.existingFood!;
      _nameController = TextEditingController(text: food.name);
      _brandController = TextEditingController(text: food.brandName ?? '');
      _descriptionController = TextEditingController(
        text: food.description ?? '',
      );
      _amountController = TextEditingController(text: food.amount.toString());
      _unitController = TextEditingController(text: food.unit);
      _servingSizeController = TextEditingController(
        text: food.servingSizeGrams > 0 ? food.servingSizeGrams.toString() : '',
      );
      _portionReferenceController = TextEditingController(
        text: food.portionReference ?? '',
      );
      _yieldFactorController = TextEditingController(
        text: food.yieldFactor?.toString() ?? '',
      );
      _ediblePortionController = TextEditingController(
        text: food.ediblePortion?.toString() ?? '',
      );

      final nutrition = _nutritionBasis!.nutrition;
      _energyController = TextEditingController(
        text: nutrition.isKnown('energyKcal')
            ? nutrition.energyKcal.toString()
            : '',
      );
      _proteinController = TextEditingController(
        text: nutrition.isKnown('protein') ? nutrition.protein.toString() : '',
      );
      _carbsController = TextEditingController(
        text: nutrition.isKnown('carbs') ? nutrition.carbs.toString() : '',
      );
      _fatController = TextEditingController(
        text: nutrition.isKnown('fat') ? nutrition.fat.toString() : '',
      );
      _sugarsController = TextEditingController(
        text: nutrition.isKnown('sugars') ? nutrition.sugars.toString() : '',
      );
      _fiberController = TextEditingController(
        text: nutrition.isKnown('fiber') ? nutrition.fiber.toString() : '',
      );
      _saturatedFatController = TextEditingController(
        text: nutrition.isKnown('saturatedFat')
            ? nutrition.saturatedFat.toString()
            : '',
      );
      _sodiumController = TextEditingController(
        text: nutrition.isKnown('sodium') ? nutrition.sodium.toString() : '',
      );

      _entryType = food.entryType;
      _portionMethod = food.portionEstimationMethod;
      _portionState = food.portionState;
      _source = food.source;
    } else {
      _nameController = TextEditingController();
      _brandController = TextEditingController();
      _descriptionController = TextEditingController();
      _amountController = TextEditingController(text: '1');
      _unitController = TextEditingController(text: 'serving');
      _servingSizeController = TextEditingController(text: '100');
      _portionReferenceController = TextEditingController();
      _yieldFactorController = TextEditingController();
      _ediblePortionController = TextEditingController();

      _energyController = TextEditingController();
      _proteinController = TextEditingController();
      _carbsController = TextEditingController();
      _fatController = TextEditingController();
      _sugarsController = TextEditingController();
      _fiberController = TextEditingController();
      _saturatedFatController = TextEditingController();
      _sodiumController = TextEditingController();
    }
    _initialSnapshot = _snapshot;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    _servingSizeController.dispose();
    _portionReferenceController.dispose();
    _yieldFactorController.dispose();
    _ediblePortionController.dispose();
    _energyController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _sugarsController.dispose();
    _fiberController.dispose();
    _saturatedFatController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  Future<void> _saveFood() async {
    if (_isSaving || widget.canEditRecall?.call() == false) return;
    Offset? saveSource;
    final saveContext = _saveButtonKey.currentContext;
    if (widget.existingFood == null && saveContext != null) {
      saveSource = globalCenter(saveContext);
    }
    var food = _buildFoodEntry();
    if (food == null) return;
    setState(() => _isSaving = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final photoScope = nutritionPhotoScope(appState);

    final historicalTarget = widget.historicalTarget;
    final subject = appState.activeSubject;
    final existingFood = widget.existingFood;
    int? currentStudyDay;
    if (historicalTarget != null) {
      if (subject == null || existingFood == null) {
        if (mounted) setState(() => _isSaving = false);
        return;
      }
      currentStudyDay = nutritionStudyDayFor(subject, DateTime.now());
      if (!isEditableNutritionRecallDay(
        studyDaySnapshot: historicalTarget.studyDaySnapshot,
        currentStudyDay: currentStudyDay,
        hasUnambiguousPeriod: true,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.historical_edit_expired)));
          _pop();
        }
        return;
      }
    }
    if (widget.editReusableDefinition) {
      try {
        final result = await (widget.repository ?? NutritionFoodRepository())
            .mutateHistoricalDefinition(
              subjectId: subject!.id,
              snapshot: normalizeNutritionFoodDefinition(food),
              expectedVersionId: existingFood!.foodVersionId,
              entryId: existingFood.id,
              target: historicalTarget!.toJson(),
              currentStudyDay: _propagateToCurrentStudyDay
                  ? currentStudyDay
                  : null,
              mutationId: const Uuid().v4(),
            );
        food = applyNutritionFoodSnapshot(
          existingFood,
          result.definition.snapshot,
        );
        final progress = _reconcileProgress(subject, result.progress);
        final updatedRecall = progress
            .where((item) => item.completedAt == historicalTarget.completedAt)
            .firstOrNull;
        if (updatedRecall != null) {
          widget.onHistoricalDefinitionSaved?.call(
            updatedRecall.nutritionRevision,
          );
        }
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
            entryId: existingFood.id,
          ),
        ]).then<void>((_) {}).onError((error, stackTrace) {
          StudyULogger.warning(
            'Could not synchronize the local draft after saving the food definition: '
            '$error\n$stackTrace',
          );
        });
        if (mounted) {
          final message = _propagateToCurrentStudyDay
              ? l10n.food_definition_updated_current_day_opt_in
              : l10n.food_definition_updated_current_day_opt_out;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      } catch (error, stackTrace) {
        StudyULogger.error(
          'Failed to update historical nutrition definition: '
          '$error\n$stackTrace',
        );
        if (mounted) {
          final conflict = NutritionFoodRepository.isVersionConflict(error);
          final message = conflict
              ? l10n.nutrition_food_definition_conflict
              : l10n.could_not_save_results;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
          setState(() => _isSaving = false);
        }
        return;
      }
    }

    // A current recall saves new food definitions when it syncs.
    final saveToLibrary =
        !widget.isRecipeIngredient &&
        (widget.historicalMode ? _saveToMyItems : widget.mealLabel == null);
    if (widget.existingFood == null && saveToLibrary) {
      if (!mounted) return;
      final userId = appState.activeSubject?.id ?? 'anonymous';
      try {
        final viewModel =
            widget.templateViewModel ??
            Provider.of<TemplateViewModel?>(context, listen: false) ??
            TemplateViewModel(userId: userId, repository: widget.repository);
        final definition = normalizeNutritionFoodDefinition(food);
        final templateId = await viewModel.saveFoodAsTemplate(
          name: food.name,
          food: definition,
        );
        food
          ..templateId = templateId
          ..foodId = definition.foodId
          ..foodVersionId = definition.foodVersionId;
      } catch (error, stackTrace) {
        StudyULogger.error(
          'Failed to save food to My items: $error\n$stackTrace',
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.could_not_save_results)));
          setState(() => _isSaving = false);
        }
        return;
      }
    }

    if (mounted && widget.onPhotoChanged != null) {
      widget.onPhotoChanged!(_photoChange);
    } else if (mounted && widget.existingFood == null && saveToLibrary) {
      await saveNutritionPhoto(
        context,
        nutritionPhotoKey(photoScope, NutritionPhotoKind.item, food.foodId),
        _photoChange,
      );
    }
    if (mounted) {
      final savedFood = food;
      final onSavedToSelection =
          widget.existingFood == null && widget.onSavedToSelection != null
          ? () => widget.onSavedToSelection!(savedFood, saveSource)
          : null;
      _pop(food, onSavedToSelection);
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

  void _pop([FoodEntry? result, VoidCallback? afterPop]) {
    setState(() => _allowPop = true);
    final route = ModalRoute.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || route?.isCurrent != true) return;
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

  Future<void> _confirmDiscard({FoodEntry? replacement}) async {
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
        _pop(replacement);
      case null:
        return;
    }
  }

  FoodEntry? _buildFoodEntry() {
    if (!_formKey.currentState!.validate()) return null;

    final nutrientControllers = {
      'energyKcal': _energyController,
      'protein': _proteinController,
      'carbs': _carbsController,
      'fat': _fatController,
      'sugars': _sugarsController,
      'fiber': _fiberController,
      'saturatedFat': _saturatedFatController,
      'sodium': _sodiumController,
    };
    final optionalInputs = [
      ...nutrientControllers.values,
      _yieldFactorController,
      _ediblePortionController,
    ];
    if (optionalInputs.any(
      (field) =>
          field.text.trim().isNotEmpty &&
          parseNutritionAmount(field.text) == null,
    )) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.free_text_numeric_error)));
      return null;
    }

    final existingNutrition = _nutritionBasis?.nutrition;
    double enteredValue(String key, TextEditingController controller) =>
        parseNutritionAmount(controller.text) ??
        (existingNutrition != null && !existingNutrition.isKnown(key)
            ? existingNutrition.valueFor(key)
            : 0);
    final nutrition = NutritionProfile(
      energyKcal: enteredValue('energyKcal', _energyController),
      protein: enteredValue('protein', _proteinController),
      carbs: enteredValue('carbs', _carbsController),
      fat: enteredValue('fat', _fatController),
      sugars: enteredValue('sugars', _sugarsController),
      fiber: enteredValue('fiber', _fiberController),
      saturatedFat: enteredValue('saturatedFat', _saturatedFatController),
      transFat: existingNutrition?.transFat ?? 0,
      cholesterol: existingNutrition?.cholesterol ?? 0,
      sodium: enteredValue('sodium', _sodiumController),
      waterContent: existingNutrition?.waterContent ?? 0,
      micros: Map.of(existingNutrition?.micros ?? const {}),
      unavailableNutrients: {
        ...?existingNutrition?.unavailableNutrients,
        if (existingNutrition == null) 'transFat',
        if (existingNutrition == null) 'cholesterol',
        if (existingNutrition == null) 'waterContent',
      },
      partialNutrients: {...?existingNutrition?.partialNutrients},
    );
    for (final entry in nutrientControllers.entries) {
      final value = parseNutritionAmount(entry.value.text);
      if (value == null) {
        nutrition.unavailableNutrients.add(entry.key);
        nutrition.partialNutrients.remove(entry.key);
      } else {
        nutrition.unavailableNutrients.remove(entry.key);
        // A name-only edit must retain an existing partial subtotal.
        final originalText =
            existingNutrition == null || !existingNutrition.isKnown(entry.key)
            ? ''
            : existingNutrition.valueFor(entry.key).toString();
        if (entry.value.text != originalText) {
          nutrition.partialNutrients.remove(entry.key);
        }
      }
    }

    final amount = widget.editReusableDefinition
        ? 1.0
        : parseNutritionAmount(_amountController.text)!;
    final servingSizeGrams =
        parseNutritionAmount(_servingSizeController.text) ?? 0;
    final savedNutrition = _showServings
        ? scaleNutritionProfile(nutrition, amount)
        : nutrition;
    final existingFood = widget.existingFood;
    if (existingFood == null) {
      return FoodEntry.withId(
        foodId: _newFoodId ??= const Uuid().v4(),
        entryType: _entryType,
        name: _nameController.text,
        brandName: _brandController.text.isEmpty ? null : _brandController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        amount: amount,
        unit: _unitController.text,
        servingSizeGrams: servingSizeGrams,
        portionReference: _portionReferenceController.text.isEmpty
            ? null
            : _portionReferenceController.text,
        portionEstimationMethod: _portionMethod,
        portionState: _portionState,
        yieldFactor: _yieldFactorController.text.isEmpty
            ? null
            : parseNutritionAmount(_yieldFactorController.text),
        ediblePortion: _ediblePortionController.text.isEmpty
            ? null
            : parseNutritionAmount(_ediblePortionController.text),
        nutrition: savedNutrition,
        source: _source,
        confidenceScore: 1.0,
        originalValues: {},
      );
    }

    final copiedExisting = FoodEntry.fromJson(
      jsonDecode(jsonEncode(existingFood.toJson())) as Map<String, dynamic>,
    );

    return copiedExisting
      ..entryType = _entryType
      ..name = _nameController.text
      ..brandName = _brandController.text.isEmpty ? null : _brandController.text
      ..description = _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text
      ..amount = amount
      ..unit = _unitController.text
      ..servingSizeGrams = servingSizeGrams
      ..portionReference = _portionReferenceController.text.isEmpty
          ? null
          : _portionReferenceController.text
      ..portionEstimationMethod = _portionMethod
      ..portionState = _portionState
      ..yieldFactor = _yieldFactorController.text.isEmpty
          ? null
          : parseNutritionAmount(_yieldFactorController.text)
      ..ediblePortion = _ediblePortionController.text.isEmpty
          ? null
          : parseNutritionAmount(_ediblePortionController.text)
      ..nutrition = savedNutrition
      ..modifiedAt = DateTime.now();
  }

  String get _snapshot => jsonEncode({
    'name': _nameController.text,
    'brand': _brandController.text,
    'description': _descriptionController.text,
    'amount': _amountController.text,
    'unit': _unitController.text,
    'servingSize': _servingSizeController.text,
    'portionReference': _portionReferenceController.text,
    'yieldFactor': _yieldFactorController.text,
    'ediblePortion': _ediblePortionController.text,
    'energy': _energyController.text,
    'protein': _proteinController.text,
    'carbs': _carbsController.text,
    'fat': _fatController.text,
    'sugars': _sugarsController.text,
    'fiber': _fiberController.text,
    'saturatedFat': _saturatedFatController.text,
    'sodium': _sodiumController.text,
    'entryType': _entryType.name,
    'portionMethod': _portionMethod.name,
    'portionState': _portionState.name,
  });

  bool get _hasUnsavedChanges =>
      _photoChange != null || _snapshot != _initialSnapshot;

  String? get _productImageUrl {
    final value = widget.existingFood?.originalValues['image_front_small_url'];
    return value is String && value.trim().isNotEmpty ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existingFood != null;
    final useSaveButton =
        !widget.isExternalLibraryCopy &&
        (isEditing || widget.mealLabel == null);
    final saveFood = _isSaving ? null : _saveFood;

    final scaffold = Scaffold(
      appBar: AppBar(
        title: NutritionEditorTitle(
          title: widget.isExternalLibraryCopy
              ? l10n.review_copied_food
              : isEditing
              ? l10n.edit_food_title
              : l10n.add_food_manually,
        ),
        actions: [
          if (widget.showSearchAction && !widget.historicalMode)
            IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  FoodSearchScreen.route(
                    templateViewModel: widget.templateViewModel,
                  ),
                );
                if (result == null || !context.mounted) return;
                if (_hasUnsavedChanges) {
                  await _confirmDiscard(replacement: result);
                } else {
                  _pop(result);
                }
              },
              icon: const Icon(Icons.search_outlined),
              tooltip: l10n.search_food_database,
            ),
        ],
      ),
      floatingActionButton: useSaveButton
          ? NutritionSaveButton(key: _saveButtonKey, onPressed: saveFood)
          : null,
      bottomNavigationBar: useSaveButton
          ? null
          : SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: nutritionEditorWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: _saveButtonKey,
                        onPressed: saveFood,
                        icon: const Icon(Icons.check),
                        label: Text(
                          widget.isExternalLibraryCopy
                              ? l10n.external_library_save_copy
                              : l10n.save_and_add_to_meal(widget.mealLabel!),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      body: NutritionEditorForm(
        formKey: _formKey,
        bottomClearance: useSaveButton
            ? NutritionSaveButton.scrollClearance
            : 0,
        children: [
          if (_isAiAnalyzed)
            _AiEstimationBanner(
              confidenceScore: widget.confidenceScore!,
              isLowConfidence: _isLowConfidence,
              l10n: l10n,
              theme: theme,
            ),

          if (widget.isExternalLibraryCopy)
            _ExternalCopyNotice(theme: theme, l10n: l10n),

          if (widget.showCurrentMealOnlyNotice &&
              widget.existingFood != null &&
              !widget.editReusableDefinition &&
              !widget.isExternalLibraryCopy)
            Card(
              margin: EdgeInsets.zero,
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

          if (widget.existingFood == null && widget.historicalMode)
            CheckboxListTile(
              value: _saveToMyItems,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.save_to_my_items),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: _isSaving
                  ? null
                  : (value) => setState(() {
                      _saveToMyItems = value ?? false;
                      if (!_saveToMyItems) _photoChange = null;
                    }),
            ),

          if (widget.editReusableDefinition) ...[
            Text(
              l10n.food_definition_edit_helper,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.hasCurrentStudyDayMatches)
              CheckboxListTile(
                value: _propagateToCurrentStudyDay,
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.update_current_day_entries),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) => setState(
                  () => _propagateToCurrentStudyDay = value ?? false,
                ),
              ),
          ],

          if (nutritionPhotoScope(context.watch<AppState?>()) case final scope?)
            if (widget.onPhotoChanged != null ||
                (widget.existingFood == null &&
                    !widget.isRecipeIngredient &&
                    (widget.historicalMode
                        ? _saveToMyItems
                        : widget.mealLabel == null)))
              NutritionPhotoEditor(
                photoKey: widget.isExternalLibraryCopy
                    ? null
                    : nutritionPhotoKey(
                        scope,
                        NutritionPhotoKind.item,
                        widget.existingFood?.foodId,
                      ),
                change: _photoChange,
                onChanged: (change) => setState(() => _photoChange = change),
                enabled: !_isSaving,
              ),
          _FoodDetailsSection(
            nameController: _nameController,
            amountController: _showServings ? _amountController : null,
            imageUrl: _productImageUrl,
            foodName: widget.existingFood?.name,
          ),
          NutritionEditorSection(
            title: l10n.nutrition_information,
            icon: Icons.pie_chart_outline,
            subtitle: l10n.nutrition_known_values_hint,
            children: [
              TextFormField(
                controller: _servingSizeController,
                decoration: nutritionFieldDecoration(
                  l10n.nutrition_values_are_for,
                  icon: Icons.scale_outlined,
                  unit: 'g',
                  helper:
                      widget.existingFood?.servingSizeGrams == 0 &&
                          _portionReferenceController.text.isNotEmpty
                      ? _portionReferenceController.text
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (widget.existingFood?.servingSizeGrams == 0 &&
                      (value ?? '').trim().isEmpty) {
                    return null;
                  }
                  final grams = parseNutritionAmount(value ?? '');
                  return grams == null || grams <= 0
                      ? l10n.food_quantity_invalid_amount
                      : null;
                },
              ),
              NutritionEditorFields(
                minimumFieldWidth: 132,
                children: [
                  _NutrientField(
                    controller: _energyController,
                    label: l10n.energy_kcal,
                    unit: 'kcal',
                  ),
                  _NutrientField(
                    controller: _proteinController,
                    label: l10n.protein,
                    unit: 'g',
                  ),
                ],
              ),
              NutritionEditorFields(
                minimumFieldWidth: 132,
                children: [
                  _NutrientField(
                    controller: _carbsController,
                    label: l10n.carbohydrate,
                    unit: 'g',
                  ),
                  _NutrientField(
                    controller: _fatController,
                    label: l10n.fat,
                    unit: 'g',
                  ),
                ],
              ),
            ],
          ),
          _DetailedNutritionCard(
            fiberController: _fiberController,
            sugarsController: _sugarsController,
            saturatedFatController: _saturatedFatController,
            sodiumController: _sodiumController,
          ),
          _AdvancedOptionsCard(
            entryType: _entryType,
            brandController: _brandController,
            descriptionController: _descriptionController,
            portionReferenceController: _portionReferenceController,
            portionMethod: _portionMethod,
            portionState: _portionState,
            yieldFactorController: _yieldFactorController,
            ediblePortionController: _ediblePortionController,
            l10n: l10n,
            onEntryTypeChanged: (value) {
              if (value != null) setState(() => _entryType = value);
            },
            onPortionMethodChanged: (value) {
              if (value != null) setState(() => _portionMethod = value);
            },
            onPortionStateChanged: (value) {
              if (value != null) setState(() => _portionState = value);
            },
          ),
        ],
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

class const _ExternalCopyNotice({
  required final ThemeData theme,
  required final AppLocalizations l10n,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: l10n.external_library_copy_notice,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.external_library_copy_notice,
                style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner displayed when food entry data comes from AI analysis.
class const _AiEstimationBanner({
  required final double confidenceScore,
  required final bool isLowConfidence,
  required final AppLocalizations l10n,
  required final ThemeData theme,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLowConfidence
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowConfidence
              ? theme.colorScheme.error.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLowConfidence ? Icons.warning_amber : Icons.auto_awesome,
            color: isLowConfidence
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiEstimatedBanner,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLowConfidence
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.confidenceLabel((confidenceScore * 100).round()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isLowConfidence
                        ? theme.colorScheme.onErrorContainer.withValues(
                            alpha: 0.8,
                          )
                        : theme.colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.8,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class const _FoodDetailsSection({
  required final TextEditingController nameController,
  final TextEditingController? amountController,
  final String? imageUrl,
  final String? foodName,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NutritionEditorSection(
      title: l10n.basic_information,
      icon: Icons.restaurant_outlined,
      subtitle: l10n.nutrition_food_details_subtitle,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl case final url?)
              Image.network(
                url,
                height: 128,
                fit: BoxFit.contain,
                semanticLabel: foodName,
                frameBuilder: (_, child, frame, _) => frame == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(
                          bottom: nutritionEditorSpacing,
                        ),
                        child: child,
                      ),
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            TextFormField(
              controller: nameController,
              decoration: nutritionFieldDecoration(
                l10n.food_name,
                icon: Icons.restaurant_outlined,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  value == null || value.isEmpty ? l10n.enter_food_name : null,
            ),
          ],
        ),
        if (amountController != null)
          TextFormField(
            controller: amountController,
            decoration: nutritionFieldDecoration(
              l10n.nutrition_servings_required,
              icon: Icons.format_list_numbered,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final amount = parseNutritionAmount(value ?? '');
              return amount == null || amount <= 0
                  ? l10n.food_quantity_invalid_amount
                  : null;
            },
          ),
      ],
    );
  }
}

class const _NutrientField({
  required final TextEditingController controller,
  required final String label,
  final String? unit,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: nutritionFieldDecoration(label, unit: unit),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}

class const _DetailedNutritionCard({
  required final TextEditingController fiberController,
  required final TextEditingController sugarsController,
  required final TextEditingController saturatedFatController,
  required final TextEditingController sodiumController,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NutritionEditorExpansion(
      icon: Icons.science_outlined,
      title: l10n.detailed_nutrition,
      subtitle: l10n.detailed_nutrition_subtitle,
      children: [
        NutritionEditorFields(
          children: [
            _NutrientField(controller: fiberController, label: l10n.fiber_g),
            _NutrientField(controller: sugarsController, label: l10n.sugars_g),
          ],
        ),
        NutritionEditorFields(
          minimumFieldWidth: 184,
          children: [
            _NutrientField(
              controller: saturatedFatController,
              label: l10n.saturated_fat_g,
            ),
            _NutrientField(controller: sodiumController, label: l10n.sodium_mg),
          ],
        ),
      ],
    );
  }
}

class const _AdvancedOptionsCard({
  required final FoodEntryType entryType,
  required final TextEditingController brandController,
  required final TextEditingController descriptionController,
  required final TextEditingController portionReferenceController,
  required final PortionEstimationMethod portionMethod,
  required final PortionState portionState,
  required final TextEditingController yieldFactorController,
  required final TextEditingController ediblePortionController,
  required final AppLocalizations l10n,
  required final ValueChanged<FoodEntryType?> onEntryTypeChanged,
  required final ValueChanged<PortionEstimationMethod?> onPortionMethodChanged,
  required final ValueChanged<PortionState?> onPortionStateChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => NutritionEditorExpansion(
    icon: Icons.tune_outlined,
    title: l10n.advanced_options,
    subtitle: l10n.advanced_options_subtitle,
    children: [
      DropdownButtonFormField<FoodEntryType>(
        initialValue: entryType == FoodEntryType.meal
            ? FoodEntryType.manualCustom
            : entryType,
        decoration: InputDecoration(
          labelText: l10n.entry_type,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        isExpanded: true,
        items: FoodEntryType.values
            .where((type) => type != FoodEntryType.meal)
            .map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  _getEntryTypeLabel(type),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            })
            .toList(),
        onChanged: onEntryTypeChanged,
      ),

      if (entryType == FoodEntryType.brandedProduct) ...[
        TextFormField(
          controller: brandController,
          decoration: nutritionFieldDecoration(
            l10n.brand_name,
            icon: Icons.local_offer_outlined,
          ),
        ),
      ],

      TextFormField(
        controller: descriptionController,
        decoration: nutritionFieldDecoration(
          l10n.description,
          icon: Icons.notes_outlined,
          hint: l10n.description_hint,
        ),
        maxLines: 2,
        minLines: 1,
      ),

      TextFormField(
        controller: portionReferenceController,
        decoration: nutritionFieldDecoration(
          l10n.portion_reference,
          icon: Icons.straighten_outlined,
          hint: l10n.portion_reference_hint,
        ),
      ),

      NutritionEditorFields(
        minimumFieldWidth: 192,
        children: [
          DropdownButtonFormField<PortionEstimationMethod>(
            initialValue: portionMethod,
            decoration: InputDecoration(
              labelText: l10n.portion_estimation_method,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            isExpanded: true,
            items: PortionEstimationMethod.values.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(
                  _getPortionMethodLabel(method),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onPortionMethodChanged,
          ),
          DropdownButtonFormField<PortionState>(
            initialValue: portionState,
            decoration: InputDecoration(
              labelText: l10n.portion_state,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            isExpanded: true,
            items: PortionState.values.map((state) {
              return DropdownMenuItem(
                value: state,
                child: Text(
                  _getPortionStateLabel(state),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onPortionStateChanged,
          ),
        ],
      ),

      NutritionEditorFields(
        children: [
          TextFormField(
            controller: yieldFactorController,
            decoration: InputDecoration(
              labelText: l10n.yield_factor,
              border: const OutlineInputBorder(),
              hintText: l10n.yield_factor_hint,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          TextFormField(
            controller: ediblePortionController,
            decoration: InputDecoration(
              labelText: l10n.edible_portion,
              border: const OutlineInputBorder(),
              hintText: l10n.edible_portion_hint,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    ],
  );

  String _getEntryTypeLabel(FoodEntryType type) {
    switch (type) {
      case FoodEntryType.singleIngredient:
        return l10n.entry_type_single_ingredient;
      case FoodEntryType.meal:
        return l10n.entry_type_meal;
      case FoodEntryType.brandedProduct:
        return l10n.entry_type_branded_product;
      case FoodEntryType.manualCustom:
        return l10n.entry_type_manual_entry;
    }
  }

  String _getPortionMethodLabel(PortionEstimationMethod method) {
    switch (method) {
      case PortionEstimationMethod.householdMeasure:
        return l10n.portion_method_household;
      case PortionEstimationMethod.photograph:
        return l10n.portion_method_photograph;
      case PortionEstimationMethod.standardUnit:
        return l10n.portion_method_standard_unit;
      case PortionEstimationMethod.userWeighted:
        return l10n.portion_method_user_weighted;
      case PortionEstimationMethod.unknown:
        return l10n.portion_method_unknown;
    }
  }

  String _getPortionStateLabel(PortionState state) {
    switch (state) {
      case PortionState.raw:
        return l10n.portion_state_raw;
      case PortionState.cooked:
        return l10n.portion_state_cooked;
      case PortionState.asServed:
        return l10n.portion_state_as_served;
    }
  }
}
