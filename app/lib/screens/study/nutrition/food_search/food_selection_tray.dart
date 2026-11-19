part of '../food_search_screen.dart';

class const _SelectionPeekTray({
  required final GlobalKey anchorKey,
  required final GlobalKey headerAnchorKey,
  required final GlobalKey Function(String key) rowAnchorFor,
  required final GlobalKey Function(String key) quantityAnchorFor,
  required final FoodSelectionStore store,
  required final String mealLabel,
  required final double maxHeight,
  required final bool isConfirming,
  required final VoidCallback onConfirm,
  required final ValueChanged<FoodSelectionItem> onEdit,
  required final void Function(String key, Offset? source) onIncrement,
  required final ValueChanged<String> onDecrement,
  required final ValueChanged<bool> onActivityChanged,
  super.key,
}) extends StatefulWidget {
  @override
  State<_SelectionPeekTray> createState() => _SelectionPeekTrayState();
}

class _SelectionPeekTrayState() extends State<_SelectionPeekTray> {
  bool _isExpanded = false;
  final ScrollController _expandedScrollController = ScrollController();

  void _setExpanded(bool expanded) {
    if (_isExpanded == expanded) return;
    setState(() => _isExpanded = expanded);
    widget.onActivityChanged(expanded);
  }

  void _toggleSelector() => _setExpanded(!_isExpanded);

  void collapse() => _setExpanded(false);

  bool handleSystemBack() {
    if (!_isExpanded) return false;
    collapse();
    return true;
  }

  @override
  void dispose() {
    _expandedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final calorieText = _selectionCaloriesSummary(l10n, widget.store);
    final itemCountText = l10n.food_selection_items_count(
      widget.store.itemCount,
    );
    final headerSummary = '$itemCountText · $calorieText';
    final unavailable = widget.store.unknownCaloriesCount == 0
        ? ''
        : ', ${l10n.food_selection_calories_unavailable(widget.store.unknownCaloriesCount)}';
    final headerSemantics =
        '${l10n.food_selection_selected_items}, $itemCountText, '
        '$calorieText$unavailable';
    final expandedMaxHeight = (widget.maxHeight * 0.75).clamp(
      0.0,
      widget.maxHeight,
    );

    final surface = Material(
      key: widget.anchorKey,
      elevation: 8,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Container(
                  key: const ValueKey('selection-drag-handle'),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Semantics(
              key: const ValueKey('selection-header-semantics'),
              button: true,
              expanded: _isExpanded,
              label: headerSemantics,
              onTap: _toggleSelector,
              child: ExcludeSemantics(
                child: InkWell(
                  onTap: _toggleSelector,
                  child: Container(
                    key: widget.headerAnchorKey,
                    constraints: const BoxConstraints(minHeight: 56),
                    padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.food_selection_selected_items,
                                style: _isExpanded
                                    ? theme.textTheme.titleLarge
                                    : theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                headerSummary,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isExpanded)
                          IconButton(
                            tooltip: l10n.food_selection_collapse,
                            onPressed: collapse,
                            icon: const Icon(Icons.keyboard_arrow_down),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isExpanded)
              Flexible(
                child: ListView.builder(
                  key: const ValueKey('selection-expanded-list'),
                  controller: _expandedScrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.store.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.store.items.elementAt(index);
                    return _SelectionPreviewRow(
                      item: item,
                      onEdit: widget.onEdit,
                      onIncrement: widget.onIncrement,
                      onDecrement: widget.onDecrement,
                    );
                  },
                ),
              )
            else
              _compactRows(context),
            if (!_isExpanded &&
                MediaQuery.viewInsetsOf(context).bottom == 0 &&
                widget.store.itemCount >
                    widget.store.recentItems
                        .take(
                          MediaQuery.textScalerOf(context).scale(1) > 1.3
                              ? 1
                              : 2,
                        )
                        .length)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _setExpanded(true),
                  child: Text(
                    l10n.food_selection_view_more(widget.store.itemCount),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, _isExpanded ? 8 : 12),
              child: FilledButton(
                onPressed: widget.isConfirming || widget.store.isEmpty
                    ? null
                    : widget.onConfirm,
                child: Text(
                  l10n.food_selection_confirm(
                    widget.store.itemCount,
                    widget.mealLabel,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final constrainedSurface = _isExpanded
        ? ConstrainedBox(
            constraints: BoxConstraints(maxHeight: expandedMaxHeight),
            child: surface,
          )
        : surface;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: !_isExpanded
          ? (details) {
              if ((details.primaryVelocity ?? 0) < -200) {
                _setExpanded(true);
              }
            }
          : null,
      child: constrainedSurface,
    );
  }

  Widget _compactRows(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final previewLimit = mediaQuery.viewInsets.bottom > 0
        ? 0
        : (mediaQuery.textScaler.scale(1) > 1.3 ? 1 : 2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _SelectionPreviewRows(
        items: widget.store.recentItems.take(previewLimit).toList(),
        rowAnchorFor: widget.rowAnchorFor,
        quantityAnchorFor: widget.quantityAnchorFor,
        onEdit: widget.onEdit,
        onIncrement: widget.onIncrement,
        onDecrement: widget.onDecrement,
      ),
    );
  }
}

class const _SelectionPreviewRows({
  required final List<FoodSelectionItem> items,
  required final GlobalKey Function(String key) rowAnchorFor,
  required final GlobalKey Function(String key) quantityAnchorFor,
  required final ValueChanged<FoodSelectionItem> onEdit,
  required final void Function(String key, Offset? source) onIncrement,
  required final ValueChanged<String> onDecrement,
}) extends StatefulWidget {
  @override
  State<_SelectionPreviewRows> createState() => _SelectionPreviewRowsState();
}

class _SelectionPreviewRowsState() extends State<_SelectionPreviewRows> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late List<FoodSelectionItem> _items = List.of(widget.items);

  @override
  void didUpdateWidget(_SelectionPreviewRows oldWidget) {
    super.didUpdateWidget(oldWidget);
    final listState = _listKey.currentState;
    if (listState == null) {
      _items = List.of(widget.items);
      return;
    }

    final nextKeys = widget.items.map((item) => item.key).toSet();
    for (var index = _items.length - 1; index >= 0; index--) {
      if (nextKeys.contains(_items[index].key)) continue;
      final removed = _items.removeAt(index);
      listState.removeItem(
        index,
        (_, animation) => _buildRow(removed, animation, outgoing: true),
        duration: selectionAnimationDuration(context),
      );
    }

    for (
      var targetIndex = 0;
      targetIndex < widget.items.length;
      targetIndex++
    ) {
      final item = widget.items[targetIndex];
      final currentIndex = _items.indexWhere((entry) => entry.key == item.key);
      if (currentIndex == -1) {
        _items.insert(targetIndex, item);
        listState.insertItem(
          targetIndex,
          duration: selectionAnimationDuration(context),
        );
      } else if (currentIndex != targetIndex) {
        final moved = _items.removeAt(currentIndex);
        listState.removeItem(
          currentIndex,
          (_, animation) => const SizedBox.shrink(),
          duration: Duration.zero,
        );
        _items.insert(targetIndex, moved);
        listState.insertItem(targetIndex, duration: Duration.zero);
      }
      _items[targetIndex] = item;
    }
  }

  Widget _buildRow(
    FoodSelectionItem item,
    Animation<double> animation, {
    bool outgoing = false,
  }) {
    final row = _SelectionPreviewRow(
      key: ValueKey(outgoing ? 'removing:${item.key}' : item.key),
      anchorKey: outgoing ? null : widget.rowAnchorFor(item.key),
      quantityAnchorKey: outgoing ? null : widget.quantityAnchorFor(item.key),
      item: item,
      onEdit: widget.onEdit,
      onIncrement: widget.onIncrement,
      onDecrement: widget.onDecrement,
    );
    if (!outgoing) {
      return FadeTransition(opacity: animation, child: row);
    }
    return ExcludeSemantics(
      child: IgnorePointer(
        child: FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            alignment: Alignment.topCenter,
            child: row,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index, animation) =>
          _buildRow(_items[index], animation),
    );
  }
}

class const _SelectionPreviewRow({
  final GlobalKey? anchorKey,
  final GlobalKey? quantityAnchorKey,
  required final FoodSelectionItem item,
  required final ValueChanged<FoodSelectionItem> onEdit,
  required final void Function(String key, Offset? source) onIncrement,
  required final ValueChanged<String> onDecrement,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final overridden = item.servingWeightOverridden;
    final weightStyle = theme.textTheme.bodySmall?.copyWith(
      color: overridden
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurfaceVariant,
      fontWeight: overridden ? FontWeight.w600 : null,
    );
    final metadata = foodTotalMetadata(
      l10n,
      item.baseFood,
      item.quantity,
      gramsKnown: item.gramsKnown,
      caloriesKnown: item.caloriesKnown,
    );
    return Container(
      key: anchorKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showCustomLabel = overridden && constraints.maxWidth >= 320;
          return Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              metadata,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: weightStyle,
                            ),
                          ),
                          if (showCustomLabel) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  l10n.food_quantity_custom_weight,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SelectionQuantityButton(
                tooltip: l10n.food_quantity_edit_amount,
                onPressed: () => onEdit(item),
                icon: Icons.tune,
                visualDensity: VisualDensity.compact,
              ),
              SelectionQuantityControl(
                name: item.name,
                quantity: item.quantity,
                quantityAnchorKey: quantityAnchorKey,
                quantityStyle: theme.textTheme.titleMedium,
                onDecrement: () => onDecrement(item.key),
                onIncrement: (source) => onIncrement(item.key, source),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _selectionCaloriesSummary(
  AppLocalizations l10n,
  FoodSelectionStore store,
) {
  final known = store.knownCalories().round();
  return store.unknownCaloriesCount == 0
      ? l10n.kcal_value(known.toString())
      : !store.hasKnownCalories
      ? l10n.food_selection_unknown_calories(store.unknownCaloriesCount)
      : l10n.food_selection_known_calories(
          known.toString(),
          store.unknownCaloriesCount,
        );
}
