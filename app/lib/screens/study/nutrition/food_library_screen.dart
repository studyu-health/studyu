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
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
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

  static Widget createButton(BuildContext context) => FoodCreationButton(
    onCreateFood: () => Navigator.push<FoodEntry>(
      context,
      FoodEntryScreen.route(
        showSearchAction: false,
        templateViewModel: context.read<TemplateViewModel>(),
      ),
    ),
    onCreateMeal: () => Navigator.push<FoodEntry>(
      context,
      MealCreatorScreen.route(
        showServings: false,
        templateViewModel: context.read<TemplateViewModel>(),
      ),
    ),
  );

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
    final subject = appState.activeSubject;
    final draftStorage = appState.previewNutritionDrafts;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TemplateViewModel(
            userId: subject?.id ?? 'anonymous',
            repository:
                repository ??
                (appState.trackParticipantProgress
                    ? null
                    : PreviewNutritionFoodRepository()),
            loadDraftRecalls: subject == null
                ? null
                : () => loadNutritionDraftsForReuse(
                    subject: subject,
                    autoSaveManager: draftStorage,
                  ),
          ),
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
      bottomPadding: 24 + MediaQuery.paddingOf(context).bottom,
    );

    if (embedded) return library;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.food_library),
        actions: [FoodLibraryScreen.createButton(context)],
      ),
      body: library,
    );
  }
}
