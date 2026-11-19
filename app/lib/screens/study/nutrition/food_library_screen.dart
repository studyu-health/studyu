import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_library.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_add_button.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

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

  static Widget addButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton(
      tooltip: l10n.add,
      heroTag: null,
      onPressed: () async {
        final action = await showFoodCreationSheet(
          context,
          mealLabel: l10n.add_meal_action,
        );
        if (!context.mounted) return;
        switch (action) {
          case FoodCreationAction.food:
            Navigator.push<FoodEntry>(
              context,
              FoodEntryScreen.route(
                showSearchAction: false,
                templateViewModel: context.read<TemplateViewModel>(),
              ),
            );
          case FoodCreationAction.meal:
            Navigator.push<FoodEntry>(
              context,
              MealCreatorScreen.route(
                templateViewModel: context.read<TemplateViewModel>(),
              ),
            );
          case null:
            break;
        }
      },
      child: const Icon(Icons.add),
    );
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
      bottomPadding: 88 + MediaQuery.paddingOf(context).bottom,
    );

    if (embedded) return library;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.food_library)),
      body: library,
      floatingActionButton: FoodLibraryScreen.addButton(context),
    );
  }
}
