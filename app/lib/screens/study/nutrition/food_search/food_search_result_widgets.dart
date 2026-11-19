import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/open_food_facts_attribution.dart';
import 'package:studyu_core/core.dart' as studyu;

class const FoodSearchSectionHeader({
  required final IconData icon,
  required final String title,
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
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class const FoodSearchResultCard({
  required final UnifiedFoodResult result,
  final bool selected = false,
  final bool showBrand = false,
  final String? metadata,
  final String? tapLabel,
  final ValueChanged<Offset?>? onTap,
  final Widget? trailing,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brand = showBrand ? result.brand?.trim() : null;
    final details = [
      if (brand != null && brand.isNotEmpty) brand,
      metadata ??
          formatFoodMetadata(
            l10n,
            grams: result.servingSizeGrams,
            servingDescription: l10n.serving_amount(1),
            calories: result.calories,
          ),
    ].join(' · ');
    return FoodItemCard(
      name: result.name,
      metadata: details,
      icon: Icons.restaurant_outlined,
      imageUrl: result.imageUrl,
      selected: selected,
      tapLabel: tapLabel,
      onTap: onTap,
      actions: [?trailing],
    );
  }
}

Iterable<Widget> buildFoodDatabaseResults({
  required FoodSearchViewModel search,
  required List<UnifiedFoodResult> results,
  required Widget Function(UnifiedFoodResult) buildResult,
  required String? errorMessage,
  required VoidCallback onRetry,
  String? emptyMessage,
  String? loadingLabel,
  String Function(int)? resultsLabel,
  String? endMessage,
}) sync* {
  if (search.isInitialLoading && results.isEmpty) {
    yield Semantics(
      liveRegion: loadingLabel != null,
      label: loadingLabel,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  } else {
    if (resultsLabel != null && results.isNotEmpty) {
      yield Semantics(
        liveRegion: true,
        label: resultsLabel(results.length),
        child: const SizedBox(height: 1),
      );
    }
    yield* results.map(buildResult);
    if (results.any(
      (result) => result.source == studyu.FoodSource.openfoodfacts,
    )) {
      yield const OpenFoodFactsAttribution();
    }
    if (errorMessage != null) {
      yield _ErrorMessage(message: errorMessage, onRetry: onRetry);
    } else if (emptyMessage != null && results.isEmpty) {
      yield FoodSearchEmptyMessage(message: emptyMessage);
    }
  }

  if (search.isLoadingMore || (search.isInitialLoading && results.isNotEmpty)) {
    yield const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
  if (endMessage != null &&
      search.hasSearched &&
      results.isNotEmpty &&
      !search.offHasMore &&
      !search.usdaHasMore &&
      !search.isInitialLoading &&
      !search.isLoadingMore) {
    yield Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(endMessage, style: TextStyle(color: Colors.grey.shade500)),
      ),
    );
  }
}

class const _ErrorMessage({
  required final String message,
  required final VoidCallback onRetry,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.try_again)),
          ],
        ),
      ),
    );
  }
}

class const FoodSearchEmptyMessage({required final String message})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
