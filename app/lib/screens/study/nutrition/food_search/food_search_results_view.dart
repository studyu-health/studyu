part of '../food_search_screen.dart';

class const _QuickSectionTabs({
  required final List<_FoodSearchSection> sections,
  required final _FoodSearchSection selectedSection,
  required final ValueChanged<_FoodSearchSection> onChanged,
  required final AppLocalizations l10n,
}) extends StatelessWidget {
  String label(_FoodSearchSection section) {
    return switch (section) {
      _FoodSearchSection.recent => l10n.recent_foods,
      _FoodSearchSection.myItems => l10n.my_saved_items,
    };
  }

  IconData icon(_FoodSearchSection section) {
    return switch (section) {
      _FoodSearchSection.recent => Icons.history,
      _FoodSearchSection.myItems => Icons.bookmark_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = sections.indexOf(selectedSection);
    return DefaultTabController(
      key: ValueKey(Object.hashAll(sections)),
      length: sections.length,
      initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
      child: TabBar(
        isScrollable: true,
        onTap: (index) => onChanged(sections[index]),
        tabs: [
          for (final section in sections)
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon(section), size: 18),
                  const SizedBox(width: 8),
                  Text(label(section)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class const _HistoryFoodCard({
  required final FoodSearchHistoryItem item,
  required final ValueChanged<Offset?> onTap,
  final ValueChanged<Offset?>? onAdd,
  required final ThemeData theme,
  final FoodSelectionStore? selectionStore,
  required final String selectionKey,
  required final ValueChanged<Offset?> onIncrement,
  required final VoidCallback onDecrement,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final food = item.food;
    final l10n = AppLocalizations.of(context)!;
    final typeLabel = food.entryType == studyu.FoodEntryType.meal
        ? l10n.nutrition_saved_meal_badge
        : l10n.nutrition_food_badge;
    final imageUrl = foodImageUrl(food);
    final photoKey = nutritionPhotoKey(
      nutritionPhotoScope(context.watch<AppState?>()),
      NutritionPhotoKind.item,
      food.foodId,
    );
    final selected = selectionStore?.itemFor(selectionKey);
    final metadata = foodTotalMetadata(
      l10n,
      selected?.baseFood ?? food,
      selected?.quantity ?? 1,
      caloriesKnown: selected?.caloriesKnown ?? true,
      gramsKnown: selected?.gramsKnown ?? true,
    );
    return FoodItemCard(
      name: food.name,
      metadata: metadata,
      icon: _foodIcon(food),
      imageUrl: imageUrl,
      photoKey: photoKey,
      typeLabel: typeLabel,
      titleStyle:
          ListTileTheme.of(context).titleTextStyle ?? theme.textTheme.bodyLarge,
      selected: selected != null,
      tapLabel:
          '$typeLabel, ${food.name}, ${selectionStore == null ? l10n.details : l10n.food_quantity_add_to_selection}',
      onTap: onTap,
      actions: [
        if (selected != null)
          SelectionQuantityControl(
            name: food.name,
            quantity: selected.amount,
            quantityStyle: theme.textTheme.titleMedium,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
          )
        else if (onAdd case final add?)
          Builder(
            builder: (buttonContext) => TextButton(
              onPressed: () => add(globalCenter(buttonContext)),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text(l10n.add),
            ),
          ),
      ],
    );
  }
}

class const _FoodResultCard({
  required final UnifiedFoodResult result,
  required final void Function(Offset? source) onTap,
  final void Function(Offset? source)? onAdd,
  final FoodSelectionStore? selectionStore,
  final String? selectionKey,
  required final void Function(Offset? source) onIncrement,
  required final VoidCallback onDecrement,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final selected = selectionKey == null
        ? null
        : selectionStore?.itemFor(selectionKey!);
    return FoodSearchResultCard(
      result: result,
      onTap: onTap,
      tapLabel:
          '${result.name}, ${selectionStore == null ? l10n.details : l10n.food_quantity_add_to_selection}',
      selected: selected != null,
      metadata: selected == null
          ? null
          : foodTotalMetadata(
              l10n,
              selected.baseFood,
              selected.quantity,
              caloriesKnown: selected.caloriesKnown,
              gramsKnown: selected.gramsKnown,
            ),
      trailing: switch (selected) {
        final item? => SelectionQuantityControl(
          name: result.name,
          quantity: item.amount,
          quantityStyle: theme.textTheme.titleMedium,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
        ),
        _ when onAdd != null => Builder(
          builder: (buttonContext) => TextButton(
            onPressed: () => onAdd!(globalCenter(buttonContext)),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: Text(l10n.add),
          ),
        ),
        _ => null,
      },
    );
  }
}

class const _NoResultsState({required final String query})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        AppLocalizations.of(context)!.no_results_for_query(query),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class const _SearchFallback({
  required final String query,
  required final VoidCallback onAddManually,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(l10n.cant_find_it, style: theme.textTheme.bodySmall),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.tonal(
                  onPressed: onAddManually,
                  child: Text(
                    l10n.create_food_from_search(query),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class const _FoodSearchListView({
  required final ScrollController scrollController,
  required final AppLocalizations l10n,
  required final ThemeData theme,
  required final TemplateViewModel templateViewModel,
  required final String query,
  required final bool showNoResults,
  required final FoodSearchViewModel search,
  required final String? errorMessage,
  required final List<UnifiedFoodResult> combinedResults,
  required final List<FoodSearchHistoryItem> recentMatches,
  required final List<studyu.SavedFoodTemplate> personalMatches,
  required final _FoodSearchSection selectedSection,
  required final ValueChanged<_FoodSearchSection> onSectionChanged,
  required final _FoodSearchFilter selectedFilter,
  required final ValueChanged<_FoodSearchFilter> onFilterChanged,
  required final void Function(FoodSearchHistoryItem, Offset? source)
  onSelectHistory,
  required final void Function(FoodSearchHistoryItem, Offset? source)
  onAddHistory,
  required final FoodLibrarySelectionAction onAddFoodTemplate,
  required final void Function(UnifiedFoodResult, Offset? source)
  onSelectResult,
  required final void Function(UnifiedFoodResult, Offset? source) onAddResult,
  required final VoidCallback onAddManually,
  required final VoidCallback onRetry,
  final bool allowMeals = true,
  final FoodSelectionStore? selectionStore,
  required final String Function(studyu.SavedFoodTemplate)
  selectionKeyForTemplate,
  required final String Function(FoodSearchHistoryItem) selectionKeyForHistory,
  final String Function(UnifiedFoodResult)? selectionKeyForResult,
  required final ValueChanged<String> onDecrementSelection,
}) extends StatelessWidget {
  Widget _historyCard(FoodSearchHistoryItem item) => _HistoryFoodCard(
    item: item,
    onTap: (source) => onSelectHistory(item, source),
    onAdd: selectionStore == null
        ? (source) => onAddHistory(item, source)
        : null,
    theme: theme,
    selectionStore: selectionStore,
    selectionKey: selectionKeyForHistory(item),
    onIncrement: (source) => onAddHistory(item, source),
    onDecrement: () => onDecrementSelection(selectionKeyForHistory(item)),
  );

  Widget _templateCard(studyu.SavedFoodTemplate template) {
    final key = selectionKeyForTemplate(template);
    final selected = selectionStore?.itemFor(key);
    return FoodLibraryItemCard(
      template: template,
      onTap: (template) => onAddFoodTemplate(template, null),
      onAdd: onAddFoodTemplate,
      addOnTap: selectionStore != null,
      isSelected: selected != null,
      selectedQuantity: selected?.amount,
      selectedFood: selected?.baseFood,
      onIncrement: (source) => onAddFoodTemplate(template, source),
      onDecrement: () => onDecrementSelection(key),
      showManagementActions: false,
    );
  }

  Widget _resultCard(UnifiedFoodResult result) {
    final selectionKey = selectionKeyForResult?.call(result);
    return _FoodResultCard(
      result: result,
      onTap: (source) => onSelectResult(result, source),
      onAdd: selectionStore == null
          ? (source) => onAddResult(result, source)
          : null,
      selectionStore: selectionStore,
      selectionKey: selectionKey,
      onIncrement: (source) => onAddResult(result, source),
      onDecrement: () => onDecrementSelection(selectionKey ?? result.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty && selectedSection == _FoodSearchSection.myItems) {
      return FoodLibrary(
        allowMeals: allowMeals,
        showSearch: false,
        scrollController: scrollController,
        header: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _QuickSectionTabs(
            sections: const [
              _FoodSearchSection.recent,
              _FoodSearchSection.myItems,
            ],
            selectedSection: selectedSection,
            onChanged: onSectionChanged,
            l10n: l10n,
          ),
        ),
        onTap: (template) => onAddFoodTemplate(template, null),
        onAdd: onAddFoodTemplate,
        addOnTap: selectionStore != null,
        isSelected: (template) =>
            selectionStore?.itemFor(selectionKeyForTemplate(template)) != null,
        selectedQuantity: (template) =>
            selectionStore?.itemFor(selectionKeyForTemplate(template))?.amount,
        selectedFood: (template) => selectionStore
            ?.itemFor(selectionKeyForTemplate(template))
            ?.baseFood,
        onIncrement: onAddFoodTemplate,
        onDecrement: (template) =>
            onDecrementSelection(selectionKeyForTemplate(template)),
        showManagementActions: false,
        showLibraryHeading: false,
      );
    }

    final children = <Widget>[];
    if (query.isEmpty) {
      children.add(
        _QuickSectionTabs(
          sections: const [
            _FoodSearchSection.recent,
            _FoodSearchSection.myItems,
          ],
          selectedSection: selectedSection,
          onChanged: onSectionChanged,
          l10n: l10n,
        ),
      );
      children.add(const SizedBox(height: 4));
      if (recentMatches.isEmpty) {
        children.add(
          EmptyState(
            icon: Icons.history_outlined,
            message: l10n.no_recent_items,
          ),
        );
      } else {
        children.addAll(recentMatches.map(_historyCard));
      }
      return ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: children,
      );
    }

    children.add(
      _SearchFilterChips(
        selectedFilter: selectedFilter,
        onChanged: onFilterChanged,
        l10n: l10n,
      ),
    );
    children.add(const SizedBox(height: 12));

    final showRecent = recentMatches.isNotEmpty;
    final showPersonal =
        selectedFilter == _FoodSearchFilter.myItems ||
        (selectedFilter == _FoodSearchFilter.all &&
            (personalMatches.isNotEmpty || templateViewModel.isLoading));
    final showDatabase = selectedFilter.includes(_FoodSearchFilter.database);

    if (showNoResults) {
      children
        ..add(_NoResultsState(query: query))
        ..add(_SearchFallback(query: query, onAddManually: onAddManually));
    } else {
      if (showRecent) {
        children.add(
          FoodSearchSectionHeader(
            icon: Icons.history,
            title: l10n.recent_foods,
          ),
        );
        children.addAll(recentMatches.map(_historyCard));
      }

      if (showPersonal) {
        if (showRecent) children.add(const SizedBox(height: 12));
        children.add(
          FoodSearchSectionHeader(
            icon: Icons.bookmark_outline,
            title: l10n.my_saved_items,
          ),
        );
        if (templateViewModel.isLoading && personalMatches.isEmpty) {
          children.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (personalMatches.isEmpty) {
          children.add(
            FoodSearchEmptyMessage(message: l10n.no_matching_templates),
          );
        } else {
          children.addAll(personalMatches.map(_templateCard));
        }
      }

      if (showDatabase) {
        if (showPersonal || showRecent) {
          children.add(const SizedBox(height: 12));
        }
        children.add(
          FoodSearchSectionHeader(
            icon: Icons.public,
            title: l10n.global_database,
          ),
        );
        children.addAll(
          buildFoodDatabaseResults(
            search: search,
            results: combinedResults,
            buildResult: _resultCard,
            errorMessage: errorMessage,
            onRetry: onRetry,
            emptyMessage: search.offSearched && search.usdaSearched
                ? l10n.no_matching_templates
                : null,
            endMessage: l10n.end_of_results,
          ),
        );
      }
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: children,
    );
  }
}

class const _SearchFilterChips({
  required final _FoodSearchFilter selectedFilter,
  required final ValueChanged<_FoodSearchFilter> onChanged,
  required final AppLocalizations l10n,
}) extends StatelessWidget {
  String label(_FoodSearchFilter filter) => switch (filter) {
    _FoodSearchFilter.all => l10n.filter_all,
    _FoodSearchFilter.recent => l10n.recent_foods,
    _FoodSearchFilter.myItems => l10n.my_saved_items,
    _FoodSearchFilter.database => l10n.database,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: [
        for (final filter in _FoodSearchFilter.values)
          FilterChip(
            selected: selectedFilter == filter,
            label: Text(label(filter)),
            onSelected: (_) => onChanged(filter),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
