import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_library.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

enum _NewItemType() {
  food,
  meal,
}

class const FoodLibraryScreen({
  final bool embedded = false,
  final OpenFoodFactsSearch? openFoodFactsSearch,
  final UsdaFoodSearch? usdaFoodSearch,
  final NutritionFoodRepository? repository,
  super.key,
}) extends StatelessWidget {
  static MaterialPageRoute<void> route({
    OpenFoodFactsSearch? openFoodFactsSearch,
    UsdaFoodSearch? usdaFoodSearch,
    NutritionFoodRepository? repository,
  }) => MaterialPageRoute(
    builder: (_) => FoodLibraryScreen(
      openFoodFactsSearch: openFoodFactsSearch,
      usdaFoodSearch: usdaFoodSearch,
      repository: repository,
    ),
  );

  static Widget newItemButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<_NewItemType>(
      tooltip: l10n.new_item,
      onSelected: (type) {
        switch (type) {
          case _NewItemType.food:
            _createFood(context);
          case _NewItemType.meal:
            _createMeal(context);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _NewItemType.food,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restaurant_outlined),
              const SizedBox(width: 12),
              Text(l10n.add_food_action),
            ],
          ),
        ),
        PopupMenuItem(
          value: _NewItemType.meal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restaurant_menu_outlined),
              const SizedBox(width: 12),
              Text(l10n.add_meal_action),
            ],
          ),
        ),
      ],
      icon: const Icon(Icons.add),
    );
  }

  static Future<void> _createMeal(BuildContext context) async {
    final meal = await Navigator.push<FoodEntry>(
      context,
      MealCreatorScreen.route(
        templateViewModel: Provider.of<TemplateViewModel?>(
          context,
          listen: false,
        ),
      ),
    );
    if (meal == null || !context.mounted) return;
  }

  static Future<void> _createFood(BuildContext context) async {
    final food = await Navigator.push<FoodEntry>(
      context,
      FoodEntryScreen.route(
        showSearchAction: false,
        templateViewModel: Provider.of<TemplateViewModel?>(
          context,
          listen: false,
        ),
      ),
    );
    if (food == null || !context.mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    if (embedded) {
      return ChangeNotifierProvider(
        create: (_) => FoodSearchViewModel(
          openFoodFactsSearch: openFoodFactsSearch,
          usdaFoodSearch: usdaFoodSearch,
        ),
        child: const _FoodLibraryScreenContent(embedded: true),
      );
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              TemplateViewModel(userId: userId, repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => FoodSearchViewModel(
            openFoodFactsSearch: openFoodFactsSearch,
            usdaFoodSearch: usdaFoodSearch,
          ),
        ),
      ],
      child: const _FoodLibraryScreenContent(embedded: false),
    );
  }
}

class const _FoodLibraryScreenContent({required final bool embedded})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final library = FoodLibrary(
      includeExternalLibrary: true,
      externalSearchViewModel: context.read<FoodSearchViewModel>(),
    );

    if (embedded) return library;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.food_library),
        actions: [FoodLibraryScreen.newItemButton(context)],
      ),
      body: library,
    );
  }
}
