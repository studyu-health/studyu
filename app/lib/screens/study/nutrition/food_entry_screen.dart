import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
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
  final bool historicalMode = false,
  final NutritionRecallPersistenceTarget? historicalTarget,
  final bool editReusableDefinition = false,
  final bool hasCurrentStudyDayMatches = false,
  final bool showCurrentMealOnlyNotice = false,
  final bool isExternalLibraryCopy = false,
  final NutritionFoodRepository? repository,
  final TemplateViewModel? templateViewModel,
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
    bool historicalMode = false,
    NutritionRecallPersistenceTarget? historicalTarget,
    bool editReusableDefinition = false,
    bool hasCurrentStudyDayMatches = false,
    bool showCurrentMealOnlyNotice = false,
    bool isExternalLibraryCopy = false,
    NutritionFoodRepository? repository,
    TemplateViewModel? templateViewModel,
    void Function(FoodEntry food, Offset? source)? onSavedToSelection,
  }) => MaterialPageRoute(
    builder: (_) => FoodEntryScreen(
      existingFood: existingFood,
      confidenceScore: confidenceScore,
      showSearchAction: showSearchAction,
      mealLabel: mealLabel,
      historicalMode: historicalMode,
      historicalTarget: historicalTarget,
      editReusableDefinition: editReusableDefinition,
      hasCurrentStudyDayMatches: hasCurrentStudyDayMatches,
      showCurrentMealOnlyNotice: showCurrentMealOnlyNotice,
      isExternalLibraryCopy: isExternalLibraryCopy,
      repository: repository,
      templateViewModel: templateViewModel,
      onSavedToSelection: onSavedToSelection,
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
  bool _saveToMyItems = true;
  bool _propagateToCurrentStudyDay = false;
  late final String _initialSnapshot;
  bool _allowPop = false;
  bool _isSaving = false;
  final GlobalKey _saveButtonKey = GlobalKey();

  /// Whether the food entry data comes from AI analysis.
  bool get _isAiAnalyzed => widget.confidenceScore != null;

  /// Whether the confidence is low and fields should be highlighted.
  bool get _isLowConfidence =>
      widget.confidenceScore != null && widget.confidenceScore! < 0.6;

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
        text: food.servingSizeGrams.toString(),
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

      _energyController = TextEditingController(
        text: food.nutrition.isKnown('energyKcal')
            ? food.nutrition.energyKcal.toString()
            : '',
      );
      _proteinController = TextEditingController(
        text: food.nutrition.isKnown('protein')
            ? food.nutrition.protein.toString()
            : '',
      );
      _carbsController = TextEditingController(
        text: food.nutrition.isKnown('carbs')
            ? food.nutrition.carbs.toString()
            : '',
      );
      _fatController = TextEditingController(
        text: food.nutrition.isKnown('fat')
            ? food.nutrition.fat.toString()
            : '',
      );
      _sugarsController = TextEditingController(
        text: food.nutrition.isKnown('sugars')
            ? food.nutrition.sugars.toString()
            : '',
      );
      _fiberController = TextEditingController(
        text: food.nutrition.isKnown('fiber')
            ? food.nutrition.fiber.toString()
            : '',
      );
      _saturatedFatController = TextEditingController(
        text: food.nutrition.isKnown('saturatedFat')
            ? food.nutrition.saturatedFat.toString()
            : '',
      );
      _sodiumController = TextEditingController(
        text: food.nutrition.isKnown('sodium')
            ? food.nutrition.sodium.toString()
            : '',
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
    if (_isSaving) return;
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
          entryId: existingFood.id,
        );
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.could_not_save_results)));
          setState(() => _isSaving = false);
        }
        return;
      }
    }

    if (widget.existingFood == null &&
        (!widget.historicalMode || _saveToMyItems)) {
      if (!mounted) return;
      final userId = appState.activeSubject?.id ?? 'anonymous';
      try {
        final viewModel =
            widget.templateViewModel ??
            Provider.of<TemplateViewModel?>(context, listen: false) ??
            TemplateViewModel(userId: userId, repository: widget.repository);
        food.templateId = await viewModel.saveFoodAsTemplate(
          name: food.name,
          food: food,
        );
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

    if (mounted) {
      final savedFood = food;
      final onSavedToSelection =
          widget.existingFood == null && widget.onSavedToSelection != null
          ? () => widget.onSavedToSelection!(savedFood, saveSource)
          : null;
      _pop(food, onSavedToSelection);
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

    final existingNutrition = widget.existingFood?.nutrition;
    double enteredValue(String key, TextEditingController controller) =>
        double.tryParse(controller.text) ??
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
    for (final entry in nutrientControllers.entries) {
      final value = double.tryParse(entry.value.text);
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

    final existingFood = widget.existingFood;
    if (existingFood == null) {
      return FoodEntry.withId(
        entryType: _entryType,
        name: _nameController.text,
        brandName: _brandController.text.isEmpty ? null : _brandController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        amount: double.parse(_amountController.text),
        unit: _unitController.text,
        servingSizeGrams: double.parse(_servingSizeController.text),
        portionReference: _portionReferenceController.text.isEmpty
            ? null
            : _portionReferenceController.text,
        portionEstimationMethod: _portionMethod,
        portionState: _portionState,
        yieldFactor: _yieldFactorController.text.isEmpty
            ? null
            : double.tryParse(_yieldFactorController.text),
        ediblePortion: _ediblePortionController.text.isEmpty
            ? null
            : double.tryParse(_ediblePortionController.text),
        nutrition: nutrition,
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
      ..amount = double.parse(_amountController.text)
      ..unit = _unitController.text
      ..servingSizeGrams = double.parse(_servingSizeController.text)
      ..portionReference = _portionReferenceController.text.isEmpty
          ? null
          : _portionReferenceController.text
      ..portionEstimationMethod = _portionMethod
      ..portionState = _portionState
      ..yieldFactor = _yieldFactorController.text.isEmpty
          ? null
          : double.tryParse(_yieldFactorController.text)
      ..ediblePortion = _ediblePortionController.text.isEmpty
          ? null
          : double.tryParse(_ediblePortionController.text)
      ..nutrition = nutrition
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

  bool get _hasUnsavedChanges => _snapshot != _initialSnapshot;

  String? get _productImageUrl {
    final value = widget.existingFood?.originalValues['image_front_small_url'];
    return value is String && value.trim().isNotEmpty ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existingFood != null;

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isExternalLibraryCopy
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            key: _saveButtonKey,
            onPressed: _isSaving ? null : _saveFood,
            icon: const Icon(Icons.check),
            label: Text(
              widget.isExternalLibraryCopy
                  ? l10n.external_library_save_copy
                  : widget.mealLabel != null
                  ? l10n.save_and_add_to_meal(widget.mealLabel!)
                  : l10n.save,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ========== AI ESTIMATION BANNER ==========
            if (_isAiAnalyzed)
              _AiEstimationBanner(
                confidenceScore: widget.confidenceScore!,
                isLowConfidence: _isLowConfidence,
                l10n: l10n,
                theme: theme,
              ),
            if (_isAiAnalyzed) const SizedBox(height: 12),

            if (widget.isExternalLibraryCopy) ...[
              _ExternalCopyNotice(theme: theme, l10n: l10n),
              const SizedBox(height: 12),
            ],

            if (widget.showCurrentMealOnlyNotice &&
                widget.existingFood != null &&
                !widget.editReusableDefinition &&
                !widget.isExternalLibraryCopy) ...[
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

            if (widget.existingFood == null && widget.historicalMode)
              CheckboxListTile(
                value: _saveToMyItems,
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.save_to_my_items),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) =>
                    setState(() => _saveToMyItems = value ?? false),
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
              const SizedBox(height: 12),
            ],

            if (_productImageUrl case final imageUrl?)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                semanticLabel: widget.existingFood!.name,
                frameBuilder: (_, child, _, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  ),
                ),
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),

            // ========== ESSENTIAL FIELDS ==========
            _EssentialFieldsCard(
              nameController: _nameController,
              servingSizeController: _servingSizeController,
              energyController: _energyController,
              proteinController: _proteinController,
              carbsController: _carbsController,
              fatController: _fatController,
              l10n: l10n,
              theme: theme,
              isEditing: isEditing,
            ),

            const SizedBox(height: 12),

            // ========== DETAILED NUTRITION (Collapsed) ==========
            _DetailedNutritionCard(
              fiberController: _fiberController,
              sugarsController: _sugarsController,
              saturatedFatController: _saturatedFatController,
              sodiumController: _sodiumController,
              l10n: l10n,
            ),

            const SizedBox(height: 12),

            // ========== ADVANCED OPTIONS (Collapsed) ==========
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

            const SizedBox(height: 16),
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

class const _EssentialFieldsCard({
  required final TextEditingController nameController,
  required final TextEditingController servingSizeController,
  required final TextEditingController energyController,
  required final TextEditingController proteinController,
  required final TextEditingController carbsController,
  required final TextEditingController fatController,
  required final AppLocalizations l10n,
  required final ThemeData theme,
  required final bool isEditing,
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
            // Card Header
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
                    Icons.restaurant_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.basic_information,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Food Name
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.food_name,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit),
              ),
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enter_food_name;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: servingSizeController,
              decoration: InputDecoration(
                labelText: l10n.nutrition_values_are_for,
                border: const OutlineInputBorder(),
                suffixText: 'g',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.required_error;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Calories
            TextFormField(
              controller: energyController,
              decoration: InputDecoration(
                labelText: l10n.energy_kcal,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.local_fire_department),
                hintText: '0',
                suffixText: 'kcal',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),

            // Macros Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.pie_chart_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.macronutrients,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Macros Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: proteinController,
                    decoration: InputDecoration(
                      labelText: l10n.protein,
                      helperText: l10n.optional,
                      border: const OutlineInputBorder(),
                      hintText: '0',
                      suffixText: 'g',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
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
                    controller: carbsController,
                    decoration: InputDecoration(
                      labelText: l10n.carbohydrate,
                      helperText: l10n.optional,
                      border: const OutlineInputBorder(),
                      hintText: '0',
                      suffixText: 'g',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
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
                    controller: fatController,
                    decoration: InputDecoration(
                      labelText: l10n.fat,
                      helperText: l10n.optional,
                      border: const OutlineInputBorder(),
                      hintText: '0',
                      suffixText: 'g',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
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
          ],
        ),
      ),
    );
  }
}

class const _DetailedNutritionCard({
  required final TextEditingController fiberController,
  required final TextEditingController sugarsController,
  required final TextEditingController saturatedFatController,
  required final TextEditingController sodiumController,
  required final AppLocalizations l10n,
}) extends StatefulWidget {
  @override
  State<_DetailedNutritionCard> createState() => _DetailedNutritionCardState();
}

class _DetailedNutritionCardState() extends State<_DetailedNutritionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.science_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.l10n.detailed_nutrition,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.l10n.detailed_nutrition_subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.fiberController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.fiber_g,
                            border: const OutlineInputBorder(),
                            hintText: '0',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
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
                          controller: widget.sugarsController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.sugars_g,
                            border: const OutlineInputBorder(),
                            hintText: '0',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.saturatedFatController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.saturated_fat_g,
                            border: const OutlineInputBorder(),
                            hintText: '0',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
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
                          controller: widget.sodiumController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.sodium_mg,
                            border: const OutlineInputBorder(),
                            hintText: '0',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
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
                ],
              ),
            ),
        ],
      ),
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
}) extends StatefulWidget {
  @override
  State<_AdvancedOptionsCard> createState() => _AdvancedOptionsCardState();
}

class _AdvancedOptionsCardState() extends State<_AdvancedOptionsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.tune_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.l10n.advanced_options,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.l10n.advanced_options_subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Entry Type Dropdown
                  DropdownButtonFormField<FoodEntryType>(
                    initialValue: widget.entryType == FoodEntryType.meal
                        ? FoodEntryType.manualCustom
                        : widget.entryType,
                    decoration: InputDecoration(
                      labelText: widget.l10n.entry_type,
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
                    onChanged: widget.onEntryTypeChanged,
                  ),
                  const SizedBox(height: 8),

                  // Brand (conditional)
                  if (widget.entryType == FoodEntryType.brandedProduct) ...[
                    TextFormField(
                      controller: widget.brandController,
                      decoration: InputDecoration(
                        labelText: widget.l10n.brand_name,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Description
                  TextFormField(
                    controller: widget.descriptionController,
                    decoration: InputDecoration(
                      labelText: widget.l10n.description,
                      border: const OutlineInputBorder(),
                      hintText: widget.l10n.description_hint,
                    ),
                    maxLines: 2,
                    minLines: 1,
                  ),
                  const SizedBox(height: 8),

                  // Portion Reference
                  TextFormField(
                    controller: widget.portionReferenceController,
                    decoration: InputDecoration(
                      labelText: widget.l10n.portion_reference,
                      border: const OutlineInputBorder(),
                      hintText: widget.l10n.portion_reference_hint,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Portion Method & State (side by side)
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<PortionEstimationMethod>(
                          initialValue: widget.portionMethod,
                          decoration: InputDecoration(
                            labelText: widget.l10n.portion_estimation_method,
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
                          onChanged: widget.onPortionMethodChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<PortionState>(
                          initialValue: widget.portionState,
                          decoration: InputDecoration(
                            labelText: widget.l10n.portion_state,
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
                          onChanged: widget.onPortionStateChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Yield & Edible Portion (side by side)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.yieldFactorController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.yield_factor,
                            border: const OutlineInputBorder(),
                            hintText: widget.l10n.yield_factor_hint,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,4}'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: widget.ediblePortionController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.edible_portion,
                            border: const OutlineInputBorder(),
                            hintText: widget.l10n.edible_portion_hint,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,4}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getEntryTypeLabel(FoodEntryType type) {
    switch (type) {
      case FoodEntryType.singleIngredient:
        return widget.l10n.entry_type_single_ingredient;
      case FoodEntryType.meal:
        return widget.l10n.entry_type_meal;
      case FoodEntryType.brandedProduct:
        return widget.l10n.entry_type_branded_product;
      case FoodEntryType.manualCustom:
        return widget.l10n.entry_type_manual_entry;
    }
  }

  String _getPortionMethodLabel(PortionEstimationMethod method) {
    switch (method) {
      case PortionEstimationMethod.householdMeasure:
        return widget.l10n.portion_method_household;
      case PortionEstimationMethod.photograph:
        return widget.l10n.portion_method_photograph;
      case PortionEstimationMethod.standardUnit:
        return widget.l10n.portion_method_standard_unit;
      case PortionEstimationMethod.userWeighted:
        return widget.l10n.portion_method_user_weighted;
      case PortionEstimationMethod.unknown:
        return widget.l10n.portion_method_unknown;
    }
  }

  String _getPortionStateLabel(PortionState state) {
    switch (state) {
      case PortionState.raw:
        return widget.l10n.portion_state_raw;
      case PortionState.cooked:
        return widget.l10n.portion_state_cooked;
      case PortionState.asServed:
        return widget.l10n.portion_state_as_served;
    }
  }
}
