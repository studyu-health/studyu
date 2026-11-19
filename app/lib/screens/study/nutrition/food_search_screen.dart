import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_library.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_result_widgets.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_bar.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_history.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_add_button.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/widgets/confirmation_dialog.dart';
import 'package:studyu_app/widgets/unsaved_changes_dialog.dart';
import 'package:studyu_core/core.dart' as studyu;

export 'package:studyu_app/screens/study/nutrition/food_search/food_search_view_model.dart';

part 'food_search/food_search_results_view.dart';
part 'food_search/food_selection_store.dart';
part 'food_search/food_selection_tray.dart';

IconData _foodIcon(studyu.FoodEntry food) =>
    food.entryType == studyu.FoodEntryType.meal
    ? Icons.restaurant_menu_outlined
    : Icons.restaurant_outlined;

ImageInfo? _cachedTransferImage(BuildContext context, String? imageUrl) {
  if (imageUrl == null || imageUrl.trim().isEmpty) return null;
  final provider = NetworkImage(imageUrl);
  final status = PaintingBinding.instance.imageCache.statusForKey(provider);
  if (status.pending || (!status.live && !status.keepAlive)) return null;

  ImageInfo? resolvedImage;
  final stream = provider.resolve(createLocalImageConfiguration(context));
  late final ImageStreamListener listener;
  listener = ImageStreamListener((image, synchronousCall) {
    if (synchronousCall) resolvedImage = image.clone();
  });
  stream.addListener(listener);
  stream.removeListener(listener);
  return resolvedImage;
}

Offset _quadraticPoint(
  Offset start,
  Offset control,
  Offset end,
  double progress,
) {
  final remaining = 1 - progress;
  return start * (remaining * remaining) +
      control * (2 * remaining * progress) +
      end * (progress * progress);
}

enum _FoodSearchSection() {
  recent,
  myItems,
}

enum _FoodSearchFilter() {
  all,
  recent,
  myItems,
  database;

  bool includes(_FoodSearchFilter source) => this == all || this == source;
}

enum _FoodSearchLayoutSlot() {
  content,
  tray,
}

class _FoodSearchLayoutDelegate({required final bool trayOverlapsContent})
    extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final traySize = layoutChild(
      _FoodSearchLayoutSlot.tray,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: size.height,
      ),
    );
    final contentHeight = trayOverlapsContent
        ? size.height
        : size.height - traySize.height;
    layoutChild(
      _FoodSearchLayoutSlot.content,
      BoxConstraints.tightFor(width: size.width, height: contentHeight),
    );
    positionChild(
      _FoodSearchLayoutSlot.tray,
      Offset(0, size.height - traySize.height),
    );
  }

  @override
  bool shouldRelayout(covariant _FoodSearchLayoutDelegate oldDelegate) =>
      trayOverlapsContent != oldDelegate.trayOverlapsContent;
}

class const FoodSearchScreen({
  final bool allowMeals = true,
  final String? mealLabel,
  final List<studyu.FoodEntry> initialFoods = const [],
  final OpenFoodFactsSearch? openFoodFactsSearch,
  final UsdaFoodSearch? usdaFoodSearch,
  final NutritionFoodRepository? repository,
  final TemplateViewModel? templateViewModel,
  final bool historicalMode = false,
  super.key,
}) extends StatelessWidget {
  static MaterialPageRoute<studyu.FoodEntry> route({
    bool allowMeals = true,
    bool historicalMode = false,
    NutritionFoodRepository? repository,
    TemplateViewModel? templateViewModel,
  }) => MaterialPageRoute(
    builder: (_) => FoodSearchScreen(
      allowMeals: allowMeals,
      historicalMode: historicalMode,
      repository: repository,
      templateViewModel: templateViewModel,
    ),
  );

  static Future<FoodSearchSelection?> show(
    BuildContext context, {
    required String mealLabel,
    List<studyu.FoodEntry> initialFoods = const [],
    bool allowMeals = true,
    OpenFoodFactsSearch? openFoodFactsSearch,
    UsdaFoodSearch? usdaFoodSearch,
    bool historicalMode = false,
    NutritionFoodRepository? repository,
    TemplateViewModel? templateViewModel,
  }) => Navigator.of(context).push(
    MaterialPageRoute<FoodSearchSelection>(
      fullscreenDialog: true,
      builder: (_) => FoodSearchScreen(
        allowMeals: allowMeals,
        mealLabel: mealLabel,
        initialFoods: initialFoods,
        openFoodFactsSearch: openFoodFactsSearch,
        usdaFoodSearch: usdaFoodSearch,
        historicalMode: historicalMode,
        repository: repository,
        templateViewModel: templateViewModel,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final activeSubject = appState.activeSubject;
    final userId = activeSubject?.id ?? 'anonymous';
    final inheritedViewModel =
        templateViewModel ?? Provider.of<TemplateViewModel?>(context);
    final content = Consumer<TemplateViewModel>(
      builder: (_, templates, _) => _FoodSearchScreenContent(
        allowMeals: allowMeals,
        mealLabel: mealLabel,
        initialFoods: initialFoods,
        openFoodFactsSearch: openFoodFactsSearch,
        usdaFoodSearch: usdaFoodSearch,
        historicalMode: historicalMode,
        history: activeSubject == null
            ? FoodSearchHistory.empty
            : buildFoodSearchHistory(
                activeSubject.progress,
                subjectId: activeSubject.id,
                libraryFoodIds: {
                  for (final template in templates.foodTemplates) template.id,
                },
              ),
      ),
    );
    if (inheritedViewModel != null) {
      return ChangeNotifierProvider.value(
        value: inheritedViewModel,
        child: content,
      );
    }
    return ChangeNotifierProvider(
      create: (_) => TemplateViewModel(userId: userId, repository: repository),
      child: content,
    );
  }
}

class const _FoodSearchScreenContent({
  final bool allowMeals = true,
  final String? mealLabel,
  required final List<studyu.FoodEntry> initialFoods,
  final OpenFoodFactsSearch? openFoodFactsSearch,
  final UsdaFoodSearch? usdaFoodSearch,
  required final bool historicalMode,
  required final FoodSearchHistory history,
}) extends StatefulWidget {
  @override
  State<_FoodSearchScreenContent> createState() =>
      _FoodSearchScreenContentState();
}

class _FoodSearchScreenContentState()
    extends State<_FoodSearchScreenContent>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  late final FoodSelectionStore? _selectionStore = widget.mealLabel == null
      ? null
      : (FoodSelectionStore()..seed(widget.initialFoods));
  _FoodSearchSection _selectedSection = _FoodSearchSection.recent;
  _FoodSearchFilter _selectedFilter = _FoodSearchFilter.all;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _trayAnchorKey = GlobalKey();
  final GlobalKey _trayHeaderAnchorKey = GlobalKey();
  final GlobalKey<_SelectionPeekTrayState> _selectionTrayKey =
      GlobalKey<_SelectionPeekTrayState>();
  final Map<String, GlobalKey> _rowAnchorKeys = {};
  final Map<String, GlobalKey> _quantityAnchorKeys = {};
  late final AnimationController _transferController;
  OverlayEntry? _transferEntry;
  int _transferGeneration = 0;
  String? _activeTransferKey;
  bool _activeTransferPending = false;
  ImageInfo? _activeTransferImage;

  late final FoodSearchViewModel _searchViewModel;
  bool _isConfirming = false;
  bool _isConfirmingRemoval = false;
  bool _allowPop = false;
  bool _selectionChanged = false;
  bool _selectionSurfaceActive = false;
  bool get _updatesExistingMeal => widget.initialFoods.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _transferController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addStatusListener(_onTransferStatus);
    WidgetsBinding.instance.addObserver(this);
    _selectionStore?.addListener(_onSelectionChanged);
    _searchViewModel = FoodSearchViewModel(
      openFoodFactsSearch: widget.openFoodFactsSearch,
      usdaFoodSearch: widget.usdaFoodSearch,
    )..addListener(_onSearchStateChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _searchViewModel.setLanguageCode(
      Localizations.localeOf(context).languageCode,
    );
  }

  void _onSelectionChanged() {
    if (mounted) setState(() => _selectionChanged = true);
  }

  void _onSelectionSurfaceActivityChanged(bool active) {
    if (mounted && active != _selectionSurfaceActive) {
      setState(() => _selectionSurfaceActive = active);
    }
  }

  void _onSearchStateChanged() {
    _removeTransfer();
    if (mounted) setState(() {});
  }

  @override
  void didChangeMetrics() {
    _removeTransfer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _removeTransfer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeTransfer();
    _transferController.dispose();
    _selectionStore?.removeListener(_onSelectionChanged);
    _selectionStore?.dispose();
    _searchViewModel
      ..removeListener(_onSearchStateChanged)
      ..dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onTransferStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _removeTransfer(stopController: false);
    }
  }

  void _removeTransfer({bool stopController = true}) {
    _transferGeneration++;
    if (stopController) _transferController.stop();
    _transferEntry?.remove();
    _transferEntry = null;
    _activeTransferImage?.dispose();
    _activeTransferImage = null;
    _activeTransferKey = null;
    _activeTransferPending = false;
  }

  GlobalKey _rowAnchorFor(String key) =>
      _rowAnchorKeys.putIfAbsent(key, GlobalKey.new);

  GlobalKey _quantityAnchorFor(String key) =>
      _quantityAnchorKeys.putIfAbsent(key, GlobalKey.new);

  RenderBox? _renderBoxFor(GlobalKey? key) {
    final renderObject = key?.currentContext?.findRenderObject();
    return renderObject is RenderBox &&
            renderObject.attached &&
            renderObject.hasSize
        ? renderObject
        : null;
  }

  Offset? _transferDestination(
    RenderBox overlayBox,
    String key, {
    required bool quantity,
  }) {
    final quantityBox = quantity
        ? _renderBoxFor(_quantityAnchorKeys[key])
        : null;
    final rowBox = _renderBoxFor(_rowAnchorKeys[key]);
    final headerBox = _renderBoxFor(_trayHeaderAnchorKey);
    final trayBox = _renderBoxFor(_trayAnchorKey);
    final destinationBox = quantityBox ?? rowBox ?? headerBox ?? trayBox;
    if (destinationBox == null) return null;

    final localDestination = destinationBox == trayBox
        ? Offset(destinationBox.size.width / 2, 16)
        : destinationBox.size.center(Offset.zero);
    return overlayBox.globalToLocal(
      destinationBox.localToGlobal(localDestination),
    );
  }

  Widget _transferToken(
    BuildContext context, {
    required double size,
    required IconData icon,
    required ImageInfo? image,
  }) {
    final theme = Theme.of(context);
    final fallback = fallbackFoodIcon(theme, icon, size: 20);
    return Material(
      elevation: 2,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image == null)
              fallback
            else
              RawImage(
                image: image.image,
                scale: image.scale,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }

  void _animateTransfer(
    Offset? source, {
    required String key,
    required IconData icon,
    required ImageInfo? image,
    required bool firstSelection,
    required bool isIncrement,
  }) {
    if (isIncrement &&
        _activeTransferKey == key &&
        (_activeTransferPending || _transferEntry != null)) {
      image?.dispose();
      return;
    }

    _removeTransfer();
    if (!mounted || source == null || MediaQuery.disableAnimationsOf(context)) {
      image?.dispose();
      return;
    }

    _activeTransferImage = image;
    _activeTransferKey = key;
    _activeTransferPending = true;
    final generation = _transferGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _transferGeneration) return;
      try {
        final overlay = Overlay.of(context, rootOverlay: true);
        final overlayBox = overlay.context.findRenderObject();
        if (overlayBox is! RenderBox ||
            !overlayBox.attached ||
            !overlayBox.hasSize) {
          _removeTransfer();
          return;
        }

        final start = overlayBox.globalToLocal(source);
        final end = _transferDestination(
          overlayBox,
          key,
          quantity: isIncrement,
        );
        if (end == null ||
            !(Offset.zero & overlayBox.size).inflate(24).contains(start)) {
          _removeTransfer();
          return;
        }

        final distance = (end - start).distance;
        final lift = (distance * 0.08).clamp(18.0, 32.0);
        final upperY = start.dy < end.dy ? start.dy : end.dy;
        final control = Offset((start.dx + end.dx) / 2, upperY - lift);
        final size = isIncrement ? 32.0 : 34.0;
        _transferController.duration = Duration(
          milliseconds: isIncrement ? 250 : (firstSelection ? 320 : 300),
        );
        _activeTransferPending = false;
        _transferEntry = OverlayEntry(
          builder: (overlayContext) => AnimatedBuilder(
            animation: _transferController,
            builder: (context, _) {
              final elapsed = _transferController.value;
              final progress = Curves.easeOutCubic.transform(elapsed);
              final destination =
                  _transferDestination(
                    overlayBox,
                    key,
                    quantity: isIncrement,
                  ) ??
                  end;
              final position = _quadraticPoint(
                start,
                control,
                destination,
                progress,
              );
              final entrance = (elapsed / 0.12).clamp(0.0, 1.0);
              final fade = ((elapsed - 0.75) / 0.25).clamp(0.0, 1.0);
              return Positioned(
                left: position.dx - size / 2,
                top: position.dy - size / 2,
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: Opacity(
                      opacity: entrance * (1 - fade),
                      child: Transform.scale(
                        scale: 1 - 0.3 * progress,
                        child: _transferToken(
                          context,
                          size: size,
                          icon: icon,
                          image: image,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
        overlay.insert(_transferEntry!);
        _transferController.forward(from: 0);
      } catch (error) {
        debugPrint('Selection transfer animation skipped: $error');
        if (mounted && generation == _transferGeneration) {
          _removeTransfer();
        }
      }
    });
  }

  void _onScroll() {
    if (_transferEntry != null || _activeTransferPending) _removeTransfer();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _removeTransfer();
    _searchViewModel.search(
      _selectedFilter.includes(_FoodSearchFilter.database) ? value : '',
    );
  }

  void _retrySearch() {
    _searchViewModel.retry(_searchController.text);
  }

  void _loadMore() {
    if (!_selectedFilter.includes(_FoodSearchFilter.database)) return;
    _searchViewModel.loadMore(_searchController.text);
  }

  bool _isAllowedFood(studyu.FoodEntry food) {
    return widget.allowMeals || food.entryType != studyu.FoodEntryType.meal;
  }

  Future<void> _selectHistoryItem(
    FoodSearchHistoryItem item,
    Offset? source,
  ) async {
    if (_selectionStore != null) {
      _addHistoryItem(item, source);
      return;
    }
    if (!_isAllowedFood(item.food)) return;
    final result = await FoodQuantitySheet.show(
      context,
      food: item.createSelection(),
      action: FoodQuantityAction.addToMeal,
    );
    if (result != null && mounted) _completeSingleSelection(result);
  }

  void _addHistoryItem(FoodSearchHistoryItem item, Offset? source) {
    if (!_isAllowedFood(item.food)) return;
    final food = item.createSelection();
    _addToSelection(food, key: canonicalFoodSelectionKey(food), source: source);
  }

  studyu.FoodEntry _foodEntryForResult(UnifiedFoodResult result) =>
      convertFoodResultToFoodEntry(result);

  bool _caloriesKnownForResult(UnifiedFoodResult result) =>
      resultCaloriesKnown(result);

  void _selectResult(UnifiedFoodResult result, Offset? source) {
    if (_selectionStore != null) {
      _addResult(result, source);
      return;
    }
    final food = _foodEntryForResult(result);
    if (_isAllowedFood(food)) _navigateToEdit(food);
  }

  void _addResult(UnifiedFoodResult result, Offset? source) {
    final food = _foodEntryForResult(result);
    if (!_isAllowedFood(food)) return;
    _addToSelection(
      food,
      key: canonicalFoodSelectionKey(food),
      caloriesKnown: _caloriesKnownForResult(result),
      gramsKnown: result.servingSizeGrams != null,
      source: source,
      imageUrl: result.imageUrl,
    );
  }

  studyu.FoodEntry _foodEntryForTemplate(studyu.SavedFoodTemplate template) {
    return Provider.of<TemplateViewModel>(
      context,
      listen: false,
    ).applyFoodTemplate(template);
  }

  void _addFoodTemplate(studyu.SavedFoodTemplate template, Offset? source) {
    if (!_isAllowedFood(template.prototype)) return;
    final food = _foodEntryForTemplate(template);
    _addToSelection(food, key: canonicalFoodSelectionKey(food), source: source);
  }

  void _confirmSelection(FoodSelectionStore store) {
    if (_isConfirming || (store.isEmpty && !_updatesExistingMeal)) return;
    _removeTransfer();
    setState(() => _isConfirming = true);
    _pop(FoodSearchSelection(store.materialize()));
  }

  void _pop([Object? result]) {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  Future<void> _confirmDiscard() async {
    if (!_selectionChanged ||
        (!_updatesExistingMeal && _selectionStore!.isEmpty)) {
      _pop();
      return;
    }

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
        _pop();
      case null:
        return;
    }
  }

  void _addToSelection(
    studyu.FoodEntry food, {
    required String key,
    bool caloriesKnown = true,
    bool gramsKnown = true,
    Offset? source,
    String? imageUrl,
  }) {
    if (!_isAllowedFood(food)) return;
    if (_selectionStore == null) {
      _completeSingleSelection(food);
      return;
    }
    final existing = _selectionStore.itemFor(key);
    final firstSelection = _selectionStore.isEmpty;
    final image = _cachedTransferImage(context, imageUrl ?? foodImageUrl(food));
    _selectionStore.addOrIncrement(
      key,
      food,
      caloriesKnown: caloriesKnown,
      gramsKnown: gramsKnown,
    );

    try {
      _animateTransfer(
        source,
        key: key,
        icon: _foodIcon(food),
        image: image,
        firstSelection: firstSelection,
        isIncrement: existing != null,
      );
    } catch (error) {
      _removeTransfer();
      debugPrint('Selection transfer animation skipped: $error');
    }
  }

  Future<void> _editTrayItem(FoodSelectionItem item) async {
    final store = _selectionStore!;
    _removeTransfer();
    _searchFocusNode.unfocus();
    final food = rescaleFoodAmount(item.baseFood, item.amount);
    final result = await Navigator.of(context).push(
      food.entryType == studyu.FoodEntryType.meal
          ? MealCreatorScreen.route(existingMeal: food, editLoggedAmount: true)
          : FoodEntryScreen.route(
              existingFood: food,
              showSearchAction: false,
              editLoggedAmount: true,
            ),
    );
    if (result == null || !mounted) return;

    final weightChanged =
        (result.servingSizeGrams - item.baseFood.servingSizeGrams).abs() >
        0.000001;
    store.replaceBase(
      item.key,
      result,
      caloriesKnown: result.nutrition.isKnown('energyKcal'),
      gramsKnown: item.gramsKnown || weightChanged,
    );
  }

  Future<void> _decrementSelection(String key) async {
    final store = _selectionStore;
    final item = store?.itemFor(key);
    if (store == null || item == null || _isConfirmingRemoval) return;

    _removeTransfer();
    if (item.canDecrement) {
      store.decrement(key);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    _isConfirmingRemoval = true;
    final shouldRemove = await showConfirmationDialog(
      context,
      title: l10n.food_selection_remove_title(item.name),
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.food_selection_remove,
      isDestructive: true,
    );
    _isConfirmingRemoval = false;
    if (!mounted ||
        !shouldRemove ||
        store.itemFor(key) != item ||
        item.canDecrement) {
      return;
    }
    store.delete(key);
    if (store.isEmpty) _selectionTrayKey.currentState?.collapse();
  }

  void _incrementTraySelection(String key, Offset? _) {
    _selectionStore?.increment(key);
  }

  void _completeSingleSelection(studyu.FoodEntry foodEntry) {
    if (!_isAllowedFood(foodEntry)) return;
    _pop(
      widget.mealLabel != null
          ? FoodSearchSelection.single(foodEntry)
          : foodEntry,
    );
  }

  void _navigateToEdit(studyu.FoodEntry foodEntry) {
    _removeTransfer();
    Navigator.push(
      context,
      FoodEntryScreen.route(
        existingFood: foodEntry,
        showSearchAction: false,
        templateViewModel: context.read<TemplateViewModel>(),
      ),
    ).then((result) {
      if (result != null && mounted) {
        _completeSingleSelection(result);
      }
    });
  }

  void _addManually() {
    _removeTransfer();
    final onSavedToSelection = _selectionStore == null
        ? null
        : (studyu.FoodEntry food, Offset? source) {
            if (!mounted) return;
            _addToSelection(
              food,
              key: canonicalFoodSelectionKey(food),
              source: source,
            );
          };
    Navigator.push(
      context,
      FoodEntryScreen.route(
        showSearchAction: false,
        mealLabel: widget.mealLabel,
        historicalMode: widget.historicalMode,
        templateViewModel: context.read<TemplateViewModel>(),
        onSavedToSelection: onSavedToSelection,
      ),
    ).then((result) {
      if (result != null && mounted && _selectionStore == null) {
        _completeSingleSelection(result);
      }
    });
  }

  void _createMeal() {
    _removeTransfer();
    final onSavedToSelection = _selectionStore == null
        ? null
        : (studyu.FoodEntry food, Offset? source) {
            if (!mounted) return;
            _addToSelection(
              food,
              key: canonicalFoodSelectionKey(food),
              source: source,
            );
          };
    Navigator.push<studyu.FoodEntry>(
      context,
      MealCreatorScreen.route(
        templateViewModel: context.read<TemplateViewModel>(),
        onSavedToSelection: onSavedToSelection,
      ),
    ).then((result) {
      if (result != null && mounted && _selectionStore == null) {
        _completeSingleSelection(result);
      }
    });
  }

  Future<void> _scanBarcode() async {
    _removeTransfer();
    final result = await Navigator.push(context, BarcodeScannerScreen.route());
    if (result == null || !mounted) return;
    _selectResult(result, null);
  }

  List<FoodSearchHistoryItem> _recentMatches(String query) {
    final history = widget.history;
    final items = [...history.frequentlyUsed, ...history.recent]
        .where(
          (item) =>
              _isAllowedFood(item.food) &&
              item.food.name.toLowerCase().contains(query),
        )
        .toList();
    return items..sort((left, right) {
      final dateComparison = right.lastUsedAt.compareTo(left.lastUsedAt);
      if (dateComparison != 0) return dateComparison;
      final countComparison = right.useCount.compareTo(left.useCount);
      return countComparison != 0
          ? countComparison
          : left.identity.compareTo(right.identity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final templateViewModel = Provider.of<TemplateViewModel>(context);
    final query = _searchController.text.trim();
    final normalizedQuery = query.toLowerCase();
    final showRecent = _selectedFilter.includes(_FoodSearchFilter.recent);
    final showPersonal = _selectedFilter.includes(_FoodSearchFilter.myItems);
    final showDatabase = _selectedFilter.includes(_FoodSearchFilter.database);
    final recentMatches = showRecent || query.isEmpty
        ? _recentMatches(normalizedQuery)
        : const <FoodSearchHistoryItem>[];
    final personalMatches = [
      if (showPersonal && query.isNotEmpty)
        for (final template in templateViewModel.foodTemplates)
          if (_isAllowedFood(template.prototype) &&
              template.name.toLowerCase().contains(normalizedQuery))
            template,
    ];
    final search = _searchViewModel;
    final results = search.results;
    final errorMessage = showDatabase && search.hasError
        ? l10n.food_search_error
        : null;
    final visibleResultCount =
        recentMatches.length +
        personalMatches.length +
        (showDatabase ? results.length : 0);
    final hasSearched =
        query.isNotEmpty && (!showDatabase || search.hasSearched);
    final databaseComplete = search.offSearched && search.usdaSearched;
    final showNoResults =
        hasSearched &&
        errorMessage == null &&
        (!showPersonal || !templateViewModel.isLoading) &&
        visibleResultCount == 0 &&
        (!showDatabase || (!search.isInitialLoading && databaseComplete));
    String? searchStatus;
    if (showDatabase && (search.isInitialLoading || search.isLoadingMore)) {
      searchStatus = l10n.searching_databases;
    } else if (errorMessage != null) {
      searchStatus = errorMessage;
    } else if (showNoResults) {
      searchStatus = l10n.no_results_for_query(query);
    } else if (hasSearched && visibleResultCount > 0) {
      searchStatus = l10n.food_search_results_count(visibleResultCount);
    }

    final scaffold = Scaffold(
      appBar: AppBar(
        leading: widget.mealLabel == null ? null : const CloseButton(),
        centerTitle: true,
        title: Text(
          widget.mealLabel == null
              ? l10n.add_food_title
              : _updatesExistingMeal
              ? l10n.food_selection_update_selection
              : widget.allowMeals
              ? l10n.nutrition_add_foods_or_saved_meals_to_meal(
                  widget.mealLabel!.toLowerCase(),
                )
              : l10n.nutrition_add_food_to_meal(
                  widget.mealLabel!.toLowerCase(),
                ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: MediaQuery.sizeOf(context).width < 480
              ? theme.textTheme.titleMedium
              : null,
        ),
        actions: [
          FoodCreationButton(
            onCreateFood: _addManually,
            onCreateMeal: widget.historicalMode || !widget.allowMeals
                ? null
                : _createMeal,
            filled: _selectionStore == null,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, bodyConstraints) {
          final selectionSurface = AnimatedSwitcher(
            duration: selectionAnimationDuration(context),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(animation),
                child: SizeTransition(
                  sizeFactor: animation,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            ),
            child: switch (_selectionStore) {
              final store? => Visibility(
                key: const ValueKey('selection-tray'),
                visible: _updatesExistingMeal || !store.isEmpty,
                maintainState: true,
                child: _SelectionPeekTray(
                  key: _selectionTrayKey,
                  anchorKey: _trayAnchorKey,
                  headerAnchorKey: _trayHeaderAnchorKey,
                  rowAnchorFor: _rowAnchorFor,
                  quantityAnchorFor: _quantityAnchorFor,
                  store: store,
                  mealLabel: widget.mealLabel!,
                  updatesExistingMeal: _updatesExistingMeal,
                  maxHeight: bodyConstraints.maxHeight,
                  isConfirming: _isConfirming,
                  onConfirm: () => _confirmSelection(store),
                  onEdit: _editTrayItem,
                  onIncrement: _incrementTraySelection,
                  onDecrement: _decrementSelection,
                  onActivityChanged: _onSelectionSurfaceActivityChanged,
                ),
              ),
              _ => const SizedBox.shrink(key: ValueKey('empty-selection-tray')),
            },
          );
          // Keep the tray mounted in the same layout slot as its mode changes.
          return CustomMultiChildLayout(
            delegate: _FoodSearchLayoutDelegate(
              trayOverlapsContent: _selectionSurfaceActive,
            ),
            children: [
              LayoutId(
                id: _FoodSearchLayoutSlot.content,
                child: Column(
                  children: [
                    // Search Bar
                    FoodSearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      hintText: widget.allowMeals
                          ? l10n.nutrition_search_foods_saved_meals_or_brands
                          : l10n.nutrition_search_foods_or_brands,
                      onChanged: _onSearchChanged,
                      onScanBarcode: _scanBarcode,
                      barcodeTooltip: l10n.scan_barcode,
                    ),
                    Semantics(
                      container: true,
                      liveRegion: true,
                      label: searchStatus,
                      child: const SizedBox.shrink(),
                    ),

                    // Content
                    Expanded(
                      child: _FoodSearchListView(
                        scrollController: _scrollController,
                        l10n: l10n,
                        theme: theme,
                        templateViewModel: templateViewModel,
                        query: query,
                        search: search,
                        showNoResults: showNoResults,
                        errorMessage: errorMessage,
                        combinedResults: results,
                        recentMatches: recentMatches,
                        personalMatches: personalMatches,
                        selectedSection: _selectedSection,
                        selectedFilter: _selectedFilter,
                        onSectionChanged: (section) {
                          _removeTransfer();
                          setState(() {
                            _selectedSection = section;
                          });
                        },
                        onFilterChanged: (filter) {
                          if (_selectedFilter == filter) return;
                          final previousFilter = _selectedFilter;
                          _removeTransfer();
                          setState(() {
                            _selectedFilter = filter;
                          });
                          final includeDatabase = filter.includes(
                            _FoodSearchFilter.database,
                          );
                          if (includeDatabase !=
                              previousFilter.includes(
                                _FoodSearchFilter.database,
                              )) {
                            _searchViewModel.search(
                              includeDatabase ? _searchController.text : '',
                            );
                          }
                        },
                        onSelectHistory: _selectHistoryItem,
                        onAddHistory: _addHistoryItem,
                        onAddFoodTemplate: _addFoodTemplate,
                        onSelectResult: _selectResult,
                        onAddResult: _addResult,
                        onAddManually: _addManually,
                        onRetry: _retrySearch,
                        allowMeals: widget.allowMeals,
                        selectionStore: _selectionStore,
                        selectionKeyForResult: (result) =>
                            canonicalFoodSelectionKey(
                              _foodEntryForResult(result),
                            ),
                        onDecrementSelection: _decrementSelection,
                      ),
                    ),
                  ],
                ),
              ),
              LayoutId(id: _FoodSearchLayoutSlot.tray, child: selectionSurface),
            ],
          );
        },
      ),
    );

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_selectionTrayKey.currentState?.handleSystemBack() == true) return;
        _confirmDiscard();
      },
      child: scaffold,
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================
