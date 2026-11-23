import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_result_widgets.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_bar.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_action_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_photo_widgets.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/services/nutrition_photo_storage.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_app/widgets/confirmation_dialog.dart';
import 'package:studyu_app/widgets/empty_state.dart';
import 'package:studyu_core/core.dart' as studyu;
import 'package:studyu_core/core.dart';

export 'package:studyu_app/screens/study/nutrition/food_item_components.dart'
    show SelectionFeedbackCard, SelectionQuantityButton, SelectionQuantityText;

enum _FoodLibraryAction() {
  add,
  edit,
  duplicate,
  delete,
}

typedef FoodLibrarySelectionAction = void Function(
  studyu.SavedFoodTemplate template,
  Offset? source,
);

class const FoodLibrary({
  final bool allowMeals = true,
  final bool showSearch = true,
  final ScrollController? scrollController,
  final Widget? header,
  final ValueChanged<studyu.SavedFoodTemplate>? onTap,
  final FoodLibrarySelectionAction? onAdd,
  final bool addOnTap = false,
  final bool Function(studyu.SavedFoodTemplate)? isSelected,
  final num? Function(studyu.SavedFoodTemplate)? selectedQuantity,
  final studyu.FoodEntry? Function(studyu.SavedFoodTemplate)? selectedFood,
  final FoodLibrarySelectionAction? onIncrement,
  final ValueChanged<studyu.SavedFoodTemplate>? onDecrement,
  final bool showManagementActions = true,
  final double bottomPadding = 24,
  final bool showLibraryHeading = true,
  final bool includeExternalLibrary = false,
  final FoodSearchViewModel? externalSearchViewModel,
  final OpenFoodFactsSearch? openFoodFactsSearch,
  final UsdaFoodSearch? usdaFoodSearch,
  final NutritionFoodRepository? repository,
  super.key,
}) extends StatefulWidget {
  @override
  State<FoodLibrary> createState() => _FoodLibraryState();
}

class _FoodLibraryState() extends State<FoodLibrary> {
  final TextEditingController _searchController = TextEditingController();
  FoodSearchViewModel? _ownedExternalViewModel;
  FoodSearchViewModel? _externalViewModel;
  TemplateFilter _filter = TemplateFilter.all;
  bool _createdByMe = false;
  bool _copyInProgress = false;
  FoodEntry? _pendingCopyDraft;
  NutritionPhotoChange? _pendingCopyPhoto;

  bool get _externalEnabled => widget.includeExternalLibrary;
  bool get _canSearchExternal =>
      !_createdByMe && _filter != TemplateFilter.meals;

  @override
  void initState() {
    super.initState();
    unawaited(
      retryNutritionPhotoDeletes(
        nutritionPhotoScope(context.read<AppState?>()),
      ),
    );
    _setExternalViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateExternalLocale();
  }

  void _updateExternalLocale() {
    _externalViewModel?.setLanguageCode(
      Localizations.localeOf(context).languageCode,
    );
  }

  @override
  void didUpdateWidget(FoodLibrary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.includeExternalLibrary != widget.includeExternalLibrary ||
        oldWidget.externalSearchViewModel != widget.externalSearchViewModel ||
        oldWidget.openFoodFactsSearch != widget.openFoodFactsSearch ||
        oldWidget.usdaFoodSearch != widget.usdaFoodSearch) {
      _setExternalViewModel();
      _updateExternalLocale();
    }
  }

  void _setExternalViewModel() {
    final previous = _externalViewModel;
    if (previous != null && previous != _ownedExternalViewModel) {
      previous.removeListener(_onExternalChanged);
    }
    _ownedExternalViewModel
      ?..removeListener(_onExternalChanged)
      ..dispose();
    _ownedExternalViewModel = null;
    _externalViewModel = null;
    if (!_externalEnabled) return;

    final provided = widget.externalSearchViewModel;
    if (provided != null) {
      _externalViewModel = provided..addListener(_onExternalChanged);
      return;
    }

    _ownedExternalViewModel = FoodSearchViewModel(
      openFoodFactsSearch: widget.openFoodFactsSearch,
      usdaFoodSearch: widget.usdaFoodSearch,
    )..addListener(_onExternalChanged);
    _externalViewModel = _ownedExternalViewModel;
  }

  @override
  void dispose() {
    final owned = _ownedExternalViewModel;
    owned
      ?..removeListener(_onExternalChanged)
      ..dispose();
    final provided = _externalViewModel;
    if (provided != null && provided != owned) {
      provided.removeListener(_onExternalChanged);
    }
    _searchController.dispose();
    super.dispose();
  }

  void _onExternalChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged(String value) {
    setState(() {});
    if (_canSearchExternal) _externalViewModel?.search(value);
  }

  void _setFilters(TemplateFilter filter, bool createdByMe) {
    if (filter == _filter && createdByMe == _createdByMe) return;
    final couldSearchExternal = _canSearchExternal;
    setState(() {
      _filter = filter;
      _createdByMe = createdByMe;
    });
    if (couldSearchExternal != _canSearchExternal) {
      _externalViewModel?.search(
        _canSearchExternal ? _searchController.text : '',
      );
    }
  }

  Future<void> _scanBarcode() async {
    if (_copyInProgress || !mounted) return;
    final result = await Navigator.push(context, BarcodeScannerScreen.route());
    if (!mounted) return;
    switch (result) {
      case BarcodeFoodFound(:final food):
        await _copyExternalResult(food);
      case BarcodeManualEntryRequested():
        await Navigator.push(
          context,
          FoodEntryScreen.route(
            showSearchAction: false,
            templateViewModel: context.read<TemplateViewModel>(),
          ),
        );
      case null:
        break;
    }
  }

  Future<void> _copyExternalResult(UnifiedFoodResult result) async {
    await _copyFood(convertFoodResultToFoodEntry(result));
  }

  Future<void> _copyFood(studyu.FoodEntry draft) async {
    if (_copyInProgress) return;
    setState(() {
      _copyInProgress = true;
      _pendingCopyDraft = draft;
    });
    try {
      final viewModel = context.read<TemplateViewModel>();
      final result = await _openCopyEditor(draft);
      if (result == null || !mounted) return;
      _pendingCopyDraft = result;
      await _saveCopiedFood(viewModel);
    } finally {
      if (mounted) {
        setState(() {
          _copyInProgress = false;
          _pendingCopyDraft = null;
          _pendingCopyPhoto = null;
        });
      }
    }
  }

  Future<studyu.FoodEntry?> _openCopyEditor(studyu.FoodEntry draft) {
    return Navigator.push<studyu.FoodEntry>(
      context,
      FoodEntryScreen.route(
        existingFood: draft,
        showSearchAction: false,
        isExternalLibraryCopy: true,
        onPhotoChanged: (change) => _pendingCopyPhoto = change,
      ),
    );
  }

  Future<void> _saveCopiedFood(TemplateViewModel viewModel) async {
    final photoScope = nutritionPhotoScope(context.read<AppState?>());
    while (mounted) {
      final draft = _pendingCopyDraft;
      if (draft == null) return;
      try {
        final id = await viewModel.saveFoodAsTemplate(
          name: draft.name,
          food: draft,
        );
        if (mounted) {
          await saveNutritionPhoto(
            context,
            nutritionPhotoKey(photoScope, NutritionPhotoKind.item, id),
            _pendingCopyPhoto,
          );
        }
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.external_library_copy_saved)),
          );
        }
        return;
      } catch (error, stackTrace) {
        StudyULogger.error('Failed to save copied food: $error\\n$stackTrace');
        if (!mounted) return;
        final action = await _copySaveFailureAction();
        switch (action) {
          case _CopySaveFailureAction.retry:
            continue;
          case _CopySaveFailureAction.continueEditing:
            final edited = await _openCopyEditor(draft);
            if (edited == null || !mounted) return;
            _pendingCopyDraft = edited;
          case _CopySaveFailureAction.discard:
          case null:
            return;
        }
      }
    }
  }

  Future<_CopySaveFailureAction?> _copySaveFailureAction() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<_CopySaveFailureAction>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(l10n.external_library_copy_save_error),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _CopySaveFailureAction.discard),
            child: Text(l10n.discard_changes),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              _CopySaveFailureAction.continueEditing,
            ),
            child: Text(l10n.continue_editing),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _CopySaveFailureAction.retry),
            child: Text(l10n.try_again),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<TemplateViewModel>();
    final query = _searchController.text.trim();
    final templates = viewModel
        .filterTemplates(_filter, query)
        .where(
          (template) =>
              (widget.allowMeals ||
                  template.prototype.entryType != studyu.FoodEntryType.meal) &&
              (!_createdByMe || template.prototype.source == FoodSource.manual),
        )
        .toList();
    final external = _externalViewModel;
    final showExternal =
        external != null && query.isNotEmpty && _canSearchExternal;
    final children = <Widget>[
      _FoodLibraryToolbar(
        selectedFilter: _filter,
        createdByMe: _createdByMe,
        allowMeals: widget.allowMeals,
        onChanged: _setFilters,
      ),
      const SizedBox(height: 8),
    ];

    final showingMeals = _filter == TemplateFilter.meals;
    if (viewModel.error != null) {
      children.add(
        ListTile(
          title: Text(l10n.loading_error_title),
          trailing: TextButton(
            onPressed: viewModel.loadAllTemplates,
            child: Text(l10n.try_again),
          ),
        ),
      );
    }
    if (viewModel.isLoading && templates.isEmpty) {
      children.add(const Center(child: CircularProgressIndicator()));
    } else {
      if (!showingMeals && widget.showLibraryHeading) {
        children.add(
          FoodSearchSectionHeader(
            title: l10n.my_saved_items,
            icon: Icons.bookmark_outline,
          ),
        );
      }
      if (templates.isNotEmpty) {
        children.addAll(
          templates.map(
            (template) => FoodLibraryItemCard(
              template: template,
              onTap: widget.onTap,
              onAdd: widget.onAdd,
              addOnTap: widget.addOnTap,
              isSelected: widget.isSelected?.call(template) ?? false,
              selectedQuantity: widget.selectedQuantity?.call(template),
              selectedFood: widget.selectedFood?.call(template),
              onIncrement: widget.onIncrement == null
                  ? null
                  : (source) => widget.onIncrement!(template, source),
              onDecrement: widget.onDecrement == null
                  ? null
                  : () => widget.onDecrement!(template),
              showManagementActions: widget.showManagementActions,
            ),
          ),
        );
      } else if (!showExternal && viewModel.error == null) {
        children.add(
          EmptyState(
            icon: _templateFilterIcon(_filter),
            message: l10n.food_library_empty,
          ),
        );
      }
    }

    if (showExternal) {
      children.addAll([
        const SizedBox(height: 12),
        FoodSearchSectionHeader(
          title: l10n.external_library,
          icon: Icons.public,
        ),
        ...buildFoodDatabaseResults(
          search: external,
          results: external.results,
          buildResult: (result) => FoodSearchResultCard(
            result: result,
            showBrand: true,
            trailing: Tooltip(
              message: l10n.external_library_copy_label(result.name),
              child: TextButton(
                onPressed: _copyInProgress
                    ? null
                    : () => _copyExternalResult(result),
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                child: Text(l10n.external_library_copy),
              ),
            ),
          ),
          errorMessage: external.hasError ? l10n.external_library_error : null,
          onRetry: () => external.retry(query),
          emptyMessage: external.hasSearched ? l10n.food_library_empty : null,
          loadingLabel: l10n.external_library_loading,
          resultsLabel: l10n.external_library_results_count,
        ),
      ]);
    }

    return Column(
      children: [
        if (widget.showSearch)
          FoodSearchBar(
            controller: _searchController,
            hintText: _externalEnabled
                ? l10n.food_library_search_hint
                : l10n.search_templates,
            onChanged: _onSearchChanged,
            onScanBarcode: _externalEnabled ? _scanBarcode : null,
            barcodeTooltip: _externalEnabled ? l10n.scan_barcode : null,
          ),
        if (widget.header != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: double.infinity, child: widget.header),
          ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 200 && showExternal) {
                external.loadMore(query);
              }
              return false;
            },
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.fromLTRB(16, 0, 16, widget.bottomPadding),
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

enum _CopySaveFailureAction() {
  retry,
  continueEditing,
  discard,
}

class const FoodLibraryItemCard({
  required final studyu.SavedFoodTemplate template,
  final ValueChanged<studyu.SavedFoodTemplate>? onTap,
  final FoodLibrarySelectionAction? onAdd,
  final bool addOnTap = false,
  final bool isSelected = false,
  final num? selectedQuantity,
  final studyu.FoodEntry? selectedFood,
  final ValueChanged<Offset?>? onIncrement,
  final VoidCallback? onDecrement,
  final bool showManagementActions = true,
  super.key,
}) extends StatelessWidget {
  bool get _isMeal => template.prototype.entryType == studyu.FoodEntryType.meal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeLabel = _isMeal
        ? l10n.nutrition_saved_meal_badge
        : l10n.nutrition_food_badge;
    final icon = _isMeal
        ? Icons.restaurant_menu_outlined
        : Icons.restaurant_outlined;
    final food = selectedFood ?? template.prototype;
    final baseAmount = food.amount;
    final amount = isSelected
        ? selectedQuantity ?? selectedFood?.amount ?? 1
        : 1;
    final quantity = baseAmount > 0 ? amount / baseAmount : 1;
    final metadata = foodTotalMetadata(
      l10n,
      food,
      quantity,
      caloriesKnown: food.nutrition.isKnown('energyKcal'),
    );

    return FoodItemCard(
      name: template.name,
      metadata: metadata,
      icon: icon,
      imageUrl: foodImageUrl(template.prototype),
      photoKey: nutritionPhotoKey(
        nutritionPhotoScope(context.watch<AppState?>()),
        NutritionPhotoKind.item,
        template.id,
      ),
      typeLabel: typeLabel,
      selected: isSelected,
      tapLabel:
          '$typeLabel, ${template.name}, ${addOnTap ? l10n.food_quantity_add_to_selection : l10n.details}',
      onTap: (source) {
        if (addOnTap) {
          onAdd?.call(template, source);
        } else if (onTap case final onTap?) {
          onTap(template);
        } else {
          _edit(context);
        }
      },
      actions: [
        if (isSelected && onIncrement != null && onDecrement != null)
          SelectionQuantityControl(
            name: template.name,
            quantity: amount,
            onIncrement: onIncrement!,
            onDecrement: onDecrement!,
          )
        else if (_canAdd)
          Builder(
            builder: (buttonContext) => TextButton(
              onPressed: () => onAdd!(
                template,
                globalCenter(buttonContext) ?? globalCenter(context),
              ),
              child: Text(l10n.add),
            ),
          ),
        if (showManagementActions)
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            tooltip: l10n.more_options,
            onPressed: () => _showActions(context),
          ),
      ],
    );
  }

  bool get _canAdd => !addOnTap && !isSelected && onAdd != null;

  Future<void> _showActions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showNutritionActionSheet<_FoodLibraryAction>(
      context,
      title: template.name,
      actions: [
        if (_canAdd)
          NutritionSheetAction(
            value: _FoodLibraryAction.add,
            label: l10n.add,
            icon: Icons.add,
          ),
        NutritionSheetAction(
          value: _FoodLibraryAction.edit,
          label: l10n.edit,
          icon: Icons.edit_outlined,
        ),
        NutritionSheetAction(
          value: _FoodLibraryAction.duplicate,
          label: l10n.duplicate,
          icon: Icons.copy_outlined,
        ),
        NutritionSheetAction(
          value: _FoodLibraryAction.delete,
          label: l10n.delete,
          icon: Icons.delete_outline,
          isDestructive: true,
        ),
      ],
    );
    if (action == null || !context.mounted) return;
    await _handleAction(context, action);
  }

  Future<void> _handleAction(
    BuildContext context,
    _FoodLibraryAction action,
  ) async {
    final viewModel = context.read<TemplateViewModel>();
    switch (action) {
      case _FoodLibraryAction.add:
        if (_canAdd) onAdd?.call(template, null);
      case _FoodLibraryAction.edit:
        await _edit(context);
      case _FoodLibraryAction.duplicate:
        await _manage(
          context,
          () => viewModel.duplicateFoodTemplate(template.id),
        );
      case _FoodLibraryAction.delete:
        await _delete(context, viewModel);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final prototype = _isMeal
        ? studyu.FoodEntry.fromJson(template.prototype.toJson())
        : normalizeNutritionFoodDefinition(template.prototype);
    NutritionPhotoChange? photoChange;
    final photoKey = nutritionPhotoKey(
      nutritionPhotoScope(context.read<AppState?>()),
      NutritionPhotoKind.item,
      template.id,
    );
    final edited = await Navigator.push<studyu.FoodEntry>(
      context,
      _isMeal
          ? MealCreatorScreen.route(
              existingMeal: prototype,
              onPhotoChanged: (change) => photoChange = change,
              showServings: false,
              templateViewModel: context.read<TemplateViewModel>(),
            )
          : FoodEntryScreen.route(
              existingFood: prototype,
              onPhotoChanged: (change) => photoChange = change,
              showSearchAction: false,
            ),
    );
    if (edited == null || !context.mounted) return;
    final viewModel = context.read<TemplateViewModel>();
    await _manage(context, () async {
      final saved = await viewModel.updateFoodTemplatePrototype(
        template.id,
        edited.entryType == FoodEntryType.meal
            ? normalizeNutritionFoodDefinition(edited)
            : edited,
        expectedVersionId: template.prototype.foodVersionId,
      );
      if (saved != null && context.mounted) {
        await saveNutritionPhoto(context, photoKey, photoChange);
      }
    });
  }

  Future<void> _delete(
    BuildContext context,
    TemplateViewModel viewModel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.delete_template(template.name),
      message: l10n.delete_template_confirmation,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed && context.mounted) {
      final key = nutritionPhotoKey(
        nutritionPhotoScope(context.read<AppState?>()),
        NutritionPhotoKind.item,
        template.id,
      );
      await _manage(context, () async {
        if (await viewModel.deleteFoodTemplate(template.id)) {
          await deleteNutritionPhoto(key);
        }
      });
    }
  }

  Future<void> _manage(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final viewModel = context.read<TemplateViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      await action();
    } catch (error, stackTrace) {
      StudyULogger.error(
        'Failed to change nutrition library: $error\n$stackTrace',
      );
      final conflict = NutritionFoodRepository.isVersionConflict(error);
      if (conflict) await viewModel.loadAllTemplates();
      if (messenger.mounted) {
        final message = conflict
            ? l10n.nutrition_food_definition_conflict
            : l10n.could_not_save_results;
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
}

class const _FoodLibraryToolbar({
  required final TemplateFilter selectedFilter,
  required final bool createdByMe,
  required final bool allowMeals,
  required final void Function(TemplateFilter, bool) onChanged,
}) extends StatelessWidget {
  String _label(AppLocalizations l10n, TemplateFilter filter) =>
      switch (filter) {
        TemplateFilter.all => l10n.filter_all,
        TemplateFilter.foods => l10n.filter_foods,
        TemplateFilter.meals => l10n.filter_meals,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final headingStyle = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.nutrition_library_available_filters,
            style: headingStyle,
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              selected: selectedFilter == TemplateFilter.all && !createdByMe,
              label: Text(l10n.filter_all),
              onSelected: (_) => onChanged(TemplateFilter.all, false),
            ),
            for (final filter in [
              TemplateFilter.foods,
              if (allowMeals) TemplateFilter.meals,
            ])
              FilterChip(
                selected: selectedFilter == filter,
                label: Text(_label(l10n, filter)),
                onSelected: (selected) => onChanged(
                  selected ? filter : TemplateFilter.all,
                  createdByMe,
                ),
              ),
            FilterChip(
              selected: createdByMe,
              label: Text(l10n.nutrition_library_created_by_me),
              onSelected: (selected) => onChanged(selectedFilter, selected),
            ),
          ],
        ),
        if (selectedFilter != TemplateFilter.all || createdByMe) ...[
          const SizedBox(height: 4),
          Semantics(
            header: true,
            child: Text(
              l10n.nutrition_library_selected_filters,
              style: headingStyle,
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              if (selectedFilter != TemplateFilter.all)
                InputChip(
                  label: Text(_label(l10n, selectedFilter)),
                  deleteButtonTooltipMessage:
                      l10n.nutrition_library_remove_filter,
                  onDeleted: () => onChanged(TemplateFilter.all, createdByMe),
                ),
              if (createdByMe)
                InputChip(
                  label: Text(l10n.nutrition_library_created_by_me),
                  deleteButtonTooltipMessage:
                      l10n.nutrition_library_remove_filter,
                  onDeleted: () => onChanged(selectedFilter, false),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

IconData _templateFilterIcon(TemplateFilter filter) => switch (filter) {
  TemplateFilter.all => Icons.bookmark_border,
  TemplateFilter.foods => Icons.restaurant_outlined,
  TemplateFilter.meals => Icons.restaurant_menu_outlined,
};
