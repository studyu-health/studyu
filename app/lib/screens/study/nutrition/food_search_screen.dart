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
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_bar.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_history.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/open_food_facts_attribution.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
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
  myItems,
  database,
}

enum _FoodSearchAction() {
  food,
  meal,
}

class const FoodSearchScreen({
  final bool allowMeals = true,
  final String? mealLabel,
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
    final history = activeSubject == null
        ? FoodSearchHistory.empty
        : buildFoodSearchHistory(
            activeSubject.progress,
            subjectId: activeSubject.id,
          );

    final inheritedViewModel =
        templateViewModel ?? Provider.of<TemplateViewModel?>(context);
    final content = _FoodSearchScreenContent(
      allowMeals: allowMeals,
      mealLabel: mealLabel,
      openFoodFactsSearch: openFoodFactsSearch,
      usdaFoodSearch: usdaFoodSearch,
      historicalMode: historicalMode,
      history: history,
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
      : FoodSelectionStore();
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
  bool _showServingHint = true;
  bool _isConfirming = false;
  bool _allowPop = false;
  bool _selectionSurfaceActive = false;

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

  void _onSelectionChanged() {
    if (mounted) setState(() {});
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

  void _onSearchChanged(String value, TemplateViewModel templateViewModel) {
    _removeTransfer();
    templateViewModel.setSearchQuery(value);
    _searchViewModel.search(value);
  }

  void _retrySearch(TemplateViewModel templateViewModel) {
    templateViewModel.setSearchQuery(_searchController.text.trim());
    _searchViewModel.retry(_searchController.text);
  }

  void _loadMore() {
    _searchViewModel.loadMore(_searchController.text);
  }

  bool _isAllowedFood(studyu.FoodEntry food) {
    return widget.allowMeals || food.entryType != studyu.FoodEntryType.meal;
  }

  void _selectHistoryItem(FoodSearchHistoryItem item) {
    if (!_isAllowedFood(item.food)) return;
    final food = item.createSelection();
    if (_selectionStore == null) {
      _showQuantity(food, action: FoodQuantityAction.addToMeal);
      return;
    }
    final key = canonicalFoodSelectionKey(food);
    final selected = _selectionStore.itemFor(key);
    _showQuantity(
      selected?.baseFood ?? food,
      key: key,
      action: selected == null
          ? FoodQuantityAction.addToSelection
          : FoodQuantityAction.updateSelection,
    );
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

  void _selectResult(UnifiedFoodResult result) {
    final foodEntry = _foodEntryForResult(result);
    if (!_isAllowedFood(foodEntry)) return;
    if (widget.mealLabel == null) {
      _navigateToEdit(foodEntry);
      return;
    }
    final key = canonicalFoodSelectionKey(foodEntry);
    final selected = _selectionStore!.itemFor(key);
    _showQuantity(
      selected?.baseFood ?? foodEntry,
      key: key,
      action: selected == null
          ? FoodQuantityAction.addToSelection
          : FoodQuantityAction.updateSelection,
      caloriesKnown: _caloriesKnownForResult(result),
      gramsKnown: result.servingSizeGrams != null,
    );
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

  void _selectFoodTemplate(studyu.SavedFoodTemplate template) {
    if (!_isAllowedFood(template.prototype)) return;
    final foodEntry = _foodEntryForTemplate(template);
    if (widget.mealLabel == null) {
      _completeSingleSelection(foodEntry);
      return;
    }
    final key = canonicalFoodSelectionKey(foodEntry);
    final selected = _selectionStore!.itemFor(key);
    _showQuantity(
      selected?.baseFood ?? foodEntry,
      key: key,
      action: selected == null
          ? FoodQuantityAction.addToSelection
          : FoodQuantityAction.updateSelection,
    );
  }

  void _addFoodTemplate(studyu.SavedFoodTemplate template, Offset? source) {
    if (!_isAllowedFood(template.prototype)) return;
    final food = _foodEntryForTemplate(template);
    _addToSelection(food, key: canonicalFoodSelectionKey(food), source: source);
  }

  Future<void> _showQuantity(
    studyu.FoodEntry foodEntry, {
    String? key,
    required FoodQuantityAction action,
    bool caloriesKnown = true,
    bool gramsKnown = true,
  }) async {
    _removeTransfer();
    if (_showServingHint) {
      setState(() => _showServingHint = false);
    }
    final store = _selectionStore;
    if (store != null) {
      _selectionTrayKey.currentState?.showDetails(
        food: foodEntry,
        key: key,
        action: action,
        caloriesKnown: caloriesKnown,
        gramsKnown: gramsKnown,
      );
      if (mounted) setState(() {});
      return;
    }
    final result = await FoodQuantitySheet.show(
      context,
      food: foodEntry,
      mealLabel: widget.mealLabel,
      action: action,
      caloriesKnown: caloriesKnown,
      gramsKnown: gramsKnown,
    );
    if (result == null || !mounted) return;
    _completeSingleSelection(result);
  }

  void _onEmbeddedDetailsConfirmed(
    studyu.FoodEntry result,
    String? key,
    FoodQuantityAction action,
    studyu.FoodEntry sourceFood,
    bool caloriesKnown,
    bool gramsKnown,
  ) {
    final store = _selectionStore;
    if (store == null) return;
    final selected = key == null ? null : store.itemFor(key);
    if (action == FoodQuantityAction.updateSelection && key != null) {
      final weightChanged =
          selected != null &&
          (result.servingSizeGrams - selected.baseFood.servingSizeGrams).abs() >
              0.000001;
      store.replaceBase(
        key,
        result,
        caloriesKnown: selected?.caloriesKnown ?? caloriesKnown,
        gramsKnown:
            selected?.gramsKnown == true ||
            selected?.baselineGramsKnown == true ||
            weightChanged,
      );
    } else {
      final weightChanged =
          (result.servingSizeGrams - sourceFood.servingSizeGrams).abs() >
          0.000001;
      _addToSelection(
        result,
        key: key ?? canonicalFoodSelectionKey(result),
        sourceFood: sourceFood,
        caloriesKnown: caloriesKnown,
        gramsKnown: gramsKnown || weightChanged,
        baselineGramsKnown: gramsKnown,
      );
    }
  }

  void _confirmSelection(FoodSelectionStore store) {
    if (_isConfirming || store.isEmpty) return;
    if (!widget.allowMeals &&
        store.items.any(
          (item) => item.baseFood.entryType == studyu.FoodEntryType.meal,
        )) {
      return;
    }
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
    final store = _selectionStore;
    if (store == null || store.isEmpty) {
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
    studyu.FoodEntry? sourceFood,
    bool caloriesKnown = true,
    bool gramsKnown = true,
    bool? baselineGramsKnown,
    Offset? source,
    String? imageUrl,
  }) {
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
      sourceFood: sourceFood,
      caloriesKnown: caloriesKnown,
      gramsKnown: gramsKnown,
      baselineGramsKnown: baselineGramsKnown,
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

  void _selectTrayItem(FoodSelectionItem item) {
    _showQuantity(
      item.baseFood,
      key: item.key,
      action: FoodQuantityAction.updateSelection,
      caloriesKnown: item.caloriesKnown,
      gramsKnown: item.gramsKnown,
    );
  }

  void _decrementSelection(String key) {
    _removeTransfer();
    _selectionStore?.decrement(key);
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
    final result = await Navigator.push<studyu.FoodEntry>(
      context,
      BarcodeScannerScreen.route(),
    );
    if (result == null || !mounted) return;
    if (widget.mealLabel == null) {
      _navigateToEdit(result);
    } else {
      final key = canonicalFoodSelectionKey(result);
      final selected = _selectionStore!.itemFor(key);
      await _showQuantity(
        selected?.baseFood ?? result,
        key: key,
        action: selected == null
            ? FoodQuantityAction.addToSelection
            : FoodQuantityAction.updateSelection,
      );
    }
  }

  bool _isAllowedTemplate(studyu.SavedFoodTemplate template) {
    return widget.allowMeals ||
        template.prototype.entryType != studyu.FoodEntryType.meal;
  }

  int _personalResultCount(TemplateViewModel templateViewModel) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return 0;
    return templateViewModel.foodTemplates
        .where(
          (template) =>
              _isAllowedTemplate(template) &&
              template.name.toLowerCase().contains(query),
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final templateViewModel = Provider.of<TemplateViewModel>(context);
    final query = _searchController.text.trim();
    final search = _searchViewModel;
    final results = search.results;
    final errorMessage = search.hasError ? l10n.food_search_error : null;
    final personalResultCount = _personalResultCount(templateViewModel);
    final visibleResultCount = switch (_selectedFilter) {
      _FoodSearchFilter.all => personalResultCount + results.length,
      _FoodSearchFilter.myItems => personalResultCount,
      _FoodSearchFilter.database => results.length,
    };
    final databaseComplete = search.offSearched && search.usdaSearched;
    final searchComplete =
        search.hasSearched &&
        !search.isInitialLoading &&
        (_selectedFilter == _FoodSearchFilter.myItems || databaseComplete);
    final showSearchFallback =
        query.isNotEmpty &&
        searchComplete &&
        visibleResultCount == 0 &&
        (_selectedFilter == _FoodSearchFilter.myItems || errorMessage == null);
    String? searchStatus;
    if ((search.isInitialLoading || search.isLoadingMore) &&
        _selectedFilter != _FoodSearchFilter.myItems) {
      searchStatus = l10n.searching_databases;
    } else if (errorMessage != null &&
        _selectedFilter != _FoodSearchFilter.myItems) {
      searchStatus = errorMessage;
    } else if (searchComplete && visibleResultCount == 0) {
      searchStatus = l10n.no_results_for_query(query);
    } else if (search.hasSearched && visibleResultCount > 0) {
      searchStatus = l10n.food_search_results_count(visibleResultCount);
    }

    final scaffold = Scaffold(
      appBar: AppBar(
        leading: widget.mealLabel == null ? null : const CloseButton(),
        centerTitle: true,
        title: Text(
          widget.mealLabel == null
              ? l10n.add_food_title
              : widget.allowMeals
              ? l10n.nutrition_add_foods_or_saved_meals_to_meal(
                  widget.mealLabel!.toLowerCase(),
                )
              : l10n.nutrition_add_food_to_meal(
                  widget.mealLabel!.toLowerCase(),
                ),
        ),
        actions: [
          if (widget.historicalMode)
            IconButton(
              tooltip: l10n.add_food_action,
              onPressed: _addManually,
              icon: const Icon(Icons.add),
            )
          else
            PopupMenuButton<_FoodSearchAction>(
              tooltip: l10n.create,
              onSelected: (action) {
                switch (action) {
                  case _FoodSearchAction.food:
                    _addManually();
                  case _FoodSearchAction.meal:
                    _createMeal();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _FoodSearchAction.food,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.restaurant_outlined),
                      const SizedBox(width: 12),
                      Text(l10n.add_food_action),
                    ],
                  ),
                ),
                if (widget.allowMeals)
                  PopupMenuItem(
                    value: _FoodSearchAction.meal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.restaurant_menu_outlined),
                        const SizedBox(width: 12),
                        Text(l10n.nutrition_create_saved_meal),
                      ],
                    ),
                  ),
              ],
              icon: const Icon(Icons.add),
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
                visible: !store.isEmpty || _selectionSurfaceActive,
                maintainState: true,
                child: _SelectionPeekTray(
                  key: _selectionTrayKey,
                  anchorKey: _trayAnchorKey,
                  headerAnchorKey: _trayHeaderAnchorKey,
                  rowAnchorFor: _rowAnchorFor,
                  quantityAnchorFor: _quantityAnchorFor,
                  store: store,
                  mealLabel: widget.mealLabel!,
                  maxHeight: bodyConstraints.maxHeight,
                  isConfirming: _isConfirming,
                  onConfirm: () => _confirmSelection(store),
                  onSelect: _selectTrayItem,
                  onIncrement: _incrementTraySelection,
                  onDecrement: _decrementSelection,
                  onDetailsConfirmed: _onEmbeddedDetailsConfirmed,
                  onActivityChanged: _onSelectionSurfaceActivityChanged,
                ),
              ),
              _ => const SizedBox.shrink(key: ValueKey('empty-selection-tray')),
            },
          );
          return Stack(
            children: [
              Column(
                children: [
                  // Search Bar
                  FoodSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: widget.allowMeals
                        ? l10n.nutrition_search_foods_saved_meals_or_brands
                        : l10n.nutrition_search_foods_or_brands,
                    onChanged: (val) =>
                        _onSearchChanged(val, templateViewModel),
                    onScanBarcode: _scanBarcode,
                    barcodeTooltip: l10n.scan_barcode,
                  ),
                  Semantics(
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
                      searchController: _searchController,
                      isInitialLoading: search.isInitialLoading,
                      isLoadingMore: search.isLoadingMore,
                      hasSearched: search.hasSearched,
                      offSearched: search.offSearched,
                      usdaSearched: search.usdaSearched,
                      offHasMore: search.offHasMore,
                      usdaHasMore: search.usdaHasMore,
                      errorMessage: errorMessage,
                      combinedResults: results,
                      history: widget.history,
                      selectedSection: _selectedSection,
                      selectedFilter: _selectedFilter,
                      onSectionChanged: (section) {
                        _removeTransfer();
                        setState(() {
                          _selectedSection = section;
                        });
                      },
                      onFilterChanged: (filter) {
                        _removeTransfer();
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      onSelectHistory: _selectHistoryItem,
                      onAddHistory: _addHistoryItem,
                      onSelectFoodTemplate: _selectFoodTemplate,
                      onAddFoodTemplate: _addFoodTemplate,
                      onSelectResult: _selectResult,
                      onAddResult: _addResult,
                      onRetry: () => _retrySearch(templateViewModel),
                      allowMeals: widget.allowMeals,
                      showServingHint:
                          _showServingHint && widget.mealLabel != null,
                      selectionStore: _selectionStore,
                      selectionKeyForResult: (result) =>
                          canonicalFoodSelectionKey(
                            _foodEntryForResult(result),
                          ),
                      onDecrementSelection: _decrementSelection,
                    ),
                  ),
                  if (showSearchFallback)
                    _SearchFallback(query: query, onAddManually: _addManually),
                  if (!_selectionSurfaceActive) selectionSurface,
                ],
              ),
              if (_selectionSurfaceActive)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: selectionSurface,
                ),
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
