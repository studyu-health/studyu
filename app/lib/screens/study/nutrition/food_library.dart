import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_bar.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/open_food_facts_attribution.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
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
  final Widget? listHeader,
  final ValueChanged<studyu.SavedFoodTemplate>? onTap,
  final FoodLibrarySelectionAction? onAdd,
  final bool Function(studyu.SavedFoodTemplate)? isSelected,
  final int Function(studyu.SavedFoodTemplate)? selectedQuantity,
  final FoodLibrarySelectionAction? onIncrement,
  final ValueChanged<studyu.SavedFoodTemplate>? onDecrement,
  final bool showManagementActions = true,
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
  bool _copyInProgress = false;
  FoodEntry? _pendingCopyDraft;

  bool get _externalEnabled => widget.includeExternalLibrary;

  @override
  void initState() {
    super.initState();
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

  void _onSearchChanged(String value, TemplateViewModel viewModel) {
    viewModel.setSearchQuery(value);
    final external = _externalViewModel;
    if (external == null) return;
    if (viewModel.currentFilter == TemplateFilter.meals) {
      external.search('');
    } else {
      external.search(value);
    }
  }

  void _onFilterChanged(TemplateFilter filter, TemplateViewModel viewModel) {
    viewModel.setFilter(filter);
    final external = _externalViewModel;
    if (external == null) return;
    if (filter == TemplateFilter.meals) {
      external.search('');
    } else {
      external.search(_searchController.text);
    }
  }

  Future<void> _scanBarcode() async {
    if (_copyInProgress || !mounted) return;
    final result = await Navigator.push<studyu.FoodEntry>(
      context,
      BarcodeScannerScreen.route(),
    );
    if (result == null || !mounted) return;
    await _copyFood(result);
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
      ),
    );
  }

  Future<void> _saveCopiedFood(TemplateViewModel viewModel) async {
    while (mounted) {
      final draft = _pendingCopyDraft;
      if (draft == null) return;
      try {
        await viewModel.saveFoodAsTemplate(name: draft.name, food: draft);
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
        title: Text(l10n.external_library_copy_save_error),
        content: Text(l10n.external_library_copy_save_error),
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
    final templates = viewModel.filteredTemplates
        .where(
          (template) =>
              widget.allowMeals ||
              template.prototype.entryType != studyu.FoodEntryType.meal,
        )
        .toList();
    final external = _externalViewModel;
    final query = _searchController.text.trim();
    final showExternal =
        external != null &&
        query.isNotEmpty &&
        viewModel.currentFilter != TemplateFilter.meals;
    final children = <Widget>[];

    if (widget.listHeader != null) children.add(widget.listHeader!);
    if (viewModel.isLoading && templates.isEmpty) {
      children.add(const Center(child: CircularProgressIndicator()));
    } else if (viewModel.currentFilter != TemplateFilter.meals) {
      if (widget.showLibraryHeading) {
        children.add(
          _FoodLibrarySectionHeader(
            title: l10n.my_saved_items,
            icon: Icons.bookmark_outline,
          ),
        );
      }
      if (templates.isEmpty && !showExternal) {
        children.add(
          FoodLibraryEmptyState(
            icon: _templateFilterIcon(viewModel.currentFilter),
            message: query.isEmpty
                ? l10n.no_templates_saved
                : l10n.no_matching_templates,
          ),
        );
      } else if (templates.isNotEmpty) {
        children.addAll(
          templates.map(
            (template) => FoodLibraryItemCard(
              template: template,
              onTap: widget.onTap,
              onAdd: widget.onAdd,
              isSelected: widget.isSelected?.call(template) ?? false,
              selectedQuantity: widget.selectedQuantity?.call(template) ?? 1,
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
      }
    } else if (templates.isEmpty) {
      children.add(
        FoodLibraryEmptyState(
          icon: _templateFilterIcon(viewModel.currentFilter),
          message: l10n.no_matching_templates,
        ),
      );
    } else {
      children.addAll(
        templates.map(
          (template) => FoodLibraryItemCard(
            template: template,
            onTap: widget.onTap,
            onAdd: widget.onAdd,
            isSelected: widget.isSelected?.call(template) ?? false,
            selectedQuantity: widget.selectedQuantity?.call(template) ?? 1,
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
    }

    if (showExternal) {
      children.add(const SizedBox(height: 16));
      children.add(
        _FoodLibrarySectionHeader(
          title: l10n.external_library,
          icon: Icons.public_outlined,
        ),
      );
      if (external.isInitialLoading && external.results.isEmpty) {
        children.add(
          Semantics(
            liveRegion: true,
            label: l10n.external_library_loading,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      }
      if (external.results.isNotEmpty) {
        children.add(
          Semantics(
            liveRegion: true,
            label: l10n.external_library_results_count(external.results.length),
            child: const SizedBox(height: 1),
          ),
        );
      }
      children.addAll(
        external.results.map(
          (result) => FoodLibraryExternalResultCard(
            result: result,
            busy: _copyInProgress,
            onCopy: () => _copyExternalResult(result),
          ),
        ),
      );
      if (external.results.any(
        (result) => result.source == studyu.FoodSource.openfoodfacts,
      )) {
        children.add(const OpenFoodFactsAttribution());
      }
      if (external.hasError) {
        children.add(
          _FoodLibraryInlineError(
            message: l10n.external_library_error,
            onRetry: () => external.retry(query),
          ),
        );
      } else if (external.hasSearched &&
          !external.isInitialLoading &&
          external.results.isEmpty) {
        children.add(
          _FoodLibraryInlineMessage(message: l10n.no_matching_templates),
        );
      }
      if (external.isLoadingMore) {
        children.add(
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }
    }

    return Column(
      children: [
        if (widget.showSearch)
          FoodSearchBar(
            controller: _searchController,
            hintText: _externalEnabled
                ? l10n.food_library_search_hint
                : l10n.search_templates,
            onChanged: (value) => _onSearchChanged(value, viewModel),
            onScanBarcode: _externalEnabled ? _scanBarcode : null,
            barcodeTooltip: _externalEnabled ? l10n.scan_barcode : null,
          ),
        if (widget.header != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: double.infinity, child: widget.header),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _FoodLibraryToolbar(
            viewModel: viewModel,
            l10n: l10n,
            onChanged: (filter) => _onFilterChanged(filter, viewModel),
          ),
        ),
        const SizedBox(height: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [...children, const SizedBox(height: 24)],
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

class const _FoodLibrarySectionHeader({
  required final String title,
  required final IconData icon,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class const _FoodLibraryInlineMessage({required final String message})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class const _FoodLibraryInlineError({
  required final String message,
  required final VoidCallback onRetry,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.try_again)),
          ],
        ),
      ),
    );
  }
}

class const FoodLibraryExternalResultCard({
  required final UnifiedFoodResult result,
  required final VoidCallback onCopy,
  final bool busy = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final brand = result.brand?.trim();
    final metadata = formatFoodMetadata(
      l10n,
      grams: result.servingSizeGrams,
      servingDescription: l10n.serving_amount(1),
      calories: result.calories,
    );
    final details = [
      if (brand != null && brand.isNotEmpty) brand,
      metadata,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: result.imageUrl == null
                  ? fallbackFoodIcon(theme, Icons.restaurant_outlined)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        result.imageUrl!,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                        errorBuilder: (_, _, _) =>
                            fallbackFoodIcon(theme, Icons.restaurant_outlined),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: l10n.external_library_copy_label(result.name),
              child: TextButton(
                onPressed: busy ? null : onCopy,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                child: Text(l10n.external_library_copy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class const FoodLibraryItemCard({
  required final studyu.SavedFoodTemplate template,
  final ValueChanged<studyu.SavedFoodTemplate>? onTap,
  final FoodLibrarySelectionAction? onAdd,
  final bool isSelected = false,
  final int selectedQuantity = 1,
  final ValueChanged<Offset?>? onIncrement,
  final VoidCallback? onDecrement,
  final bool showManagementActions = true,
  super.key,
}) extends StatelessWidget {
  bool get _isMeal => template.prototype.entryType == studyu.FoodEntryType.meal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typeLabel = _isMeal
        ? l10n.nutrition_saved_meal_badge
        : l10n.nutrition_food_badge;
    final icon = _isMeal
        ? Icons.restaurant_menu_outlined
        : Icons.restaurant_outlined;
    final imageUrl = foodImageUrl(template.prototype);
    final quantity = isSelected ? selectedQuantity : 1;
    final metadata = foodTotalMetadata(
      l10n,
      template.prototype,
      quantity,
      caloriesKnown: !template.prototype.nutrition.unavailableNutrients
          .contains('energyKcal'),
    );

    return SelectionFeedbackCard(
      selected: isSelected,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: '$typeLabel, ${template.name}, ${l10n.details}',
                child: InkWell(
                  onTap: () {
                    if (onTap case final onTap?) {
                      onTap(template);
                    } else {
                      _edit(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  overlayColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.pressed)
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
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
                                      excludeFromSemantics: true,
                                      errorBuilder: (_, _, _) =>
                                          fallbackFoodIcon(theme, icon),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  typeLabel,
                                  style: theme.textTheme.labelSmall,
                                ),
                                Text(
                                  template.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                AnimatedSwitcher(
                                  duration: selectionAnimationDuration(context),
                                  child: Text(
                                    metadata,
                                    key: ValueKey(metadata),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const FoodDetailsAffordance(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isSelected && onIncrement != null && onDecrement != null)
              SelectionQuantityControl(
                name: template.name,
                quantity: selectedQuantity,
                onIncrement: onIncrement!,
                onDecrement: onDecrement!,
              )
            else if (onAdd != null)
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
              PopupMenuButton<_FoodLibraryAction>(
                onSelected: (action) => _handleAction(context, action),
                itemBuilder: (_) => [
                  if (onAdd != null && !isSelected)
                    PopupMenuItem(
                      value: _FoodLibraryAction.add,
                      child: _menuItem(Icons.add, l10n.add),
                    ),
                  PopupMenuItem(
                    value: _FoodLibraryAction.edit,
                    child: _menuItem(Icons.edit_outlined, l10n.edit),
                  ),
                  PopupMenuItem(
                    value: _FoodLibraryAction.duplicate,
                    child: _menuItem(Icons.copy_outlined, l10n.duplicate),
                  ),
                  PopupMenuItem(
                    value: _FoodLibraryAction.delete,
                    child: _menuItem(Icons.delete_outline, l10n.delete),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    _FoodLibraryAction action,
  ) async {
    final viewModel = context.read<TemplateViewModel>();
    switch (action) {
      case _FoodLibraryAction.add:
        onAdd?.call(template, null);
      case _FoodLibraryAction.edit:
        await _edit(context);
      case _FoodLibraryAction.duplicate:
        await viewModel.duplicateFoodTemplate(template.id);
      case _FoodLibraryAction.delete:
        await _delete(context, viewModel);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final prototype = studyu.FoodEntry.fromJson(template.prototype.toJson());
    final edited = await Navigator.push<studyu.FoodEntry>(
      context,
      _isMeal
          ? MealCreatorScreen.route(existingMeal: prototype)
          : FoodEntryScreen.route(
              existingFood: prototype,
              showSearchAction: false,
            ),
    );
    if (edited == null || !context.mounted) return;
    await context.read<TemplateViewModel>().updateFoodTemplatePrototype(
      template.id,
      edited.entryType == FoodEntryType.meal
          ? normalizeNutritionFoodDefinition(edited)
          : edited,
    );
  }

  Future<void> _delete(
    BuildContext context,
    TemplateViewModel viewModel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.delete_template),
        content: Text(l10n.delete_template_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) await viewModel.deleteFoodTemplate(template.id);
  }

  Widget _menuItem(IconData icon, String label) =>
      Row(children: [Icon(icon), const SizedBox(width: 8), Text(label)]);
}

class const _FoodLibraryToolbar({
  required final TemplateViewModel viewModel,
  required final AppLocalizations l10n,
  required final ValueChanged<TemplateFilter> onChanged,
}) extends StatelessWidget {
  String _label(TemplateFilter filter) => switch (filter) {
    TemplateFilter.all => l10n.filter_all,
    TemplateFilter.foods => l10n.filter_foods,
    TemplateFilter.meals => l10n.nutrition_saved_meals_filter,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in TemplateFilter.values) ...[
            FilterChip(
              selected: viewModel.currentFilter == filter,
              label: Text(_label(filter)),
              onSelected: (_) => onChanged(filter),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

IconData _templateFilterIcon(TemplateFilter filter) => switch (filter) {
  TemplateFilter.all => Icons.bookmark_border,
  TemplateFilter.foods => Icons.restaurant_outlined,
  TemplateFilter.meals => Icons.restaurant_menu_outlined,
};

class const FoodLibraryEmptyState({
  required final IconData icon,
  required final String message,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
