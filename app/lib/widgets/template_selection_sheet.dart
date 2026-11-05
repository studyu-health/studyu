import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

enum TemplateSelectionMode() {
  meal,
  food,
}

class const TemplateSelectionSheet({
  required final TemplateSelectionMode mode,
  required final String userId,
  super.key,
}) extends StatefulWidget {
  static Future<dynamic> show(
    BuildContext context, {
    required TemplateSelectionMode mode,
    required String userId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (sheetContext, scrollController) => ChangeNotifierProvider(
          create: (_) => TemplateViewModel(userId: userId),
          child: _TemplateSelectionSheetContent(
            mode: mode,
            scrollController: scrollController,
          ),
        ),
      ),
    );
  }

  @override
  State<TemplateSelectionSheet> createState() => _TemplateSelectionSheetState();
}

class _TemplateSelectionSheetState() extends State<TemplateSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TemplateViewModel(userId: widget.userId),
      child: _TemplateSelectionSheetContent(
        mode: widget.mode,
        scrollController: ScrollController(),
      ),
    );
  }
}

class const _TemplateSelectionSheetContent({
  required final TemplateSelectionMode mode,
  required final ScrollController scrollController,
}) extends StatefulWidget {
  @override
  State<_TemplateSelectionSheetContent> createState() =>
      _TemplateSelectionSheetContentState();
}

class _TemplateSelectionSheetContentState()
    extends State<_TemplateSelectionSheetContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Consumer<TemplateViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final templates = widget.mode == TemplateSelectionMode.meal
            ? viewModel.mealTemplates
            : viewModel.foodTemplates;

        final filteredTemplates = viewModel.searchQuery.isEmpty
            ? templates
            : templates.where((t) {
                final name = t is SavedMealTemplate
                    ? t.name
                    : (t as SavedFoodTemplate).name;
                return name.toLowerCase().contains(
                  viewModel.searchQuery.toLowerCase(),
                );
              }).toList();

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.mode == TemplateSelectionMode.meal
                        ? l10n.select_meal_template
                        : l10n.select_food_template,
                    style: theme.textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.search_templates,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: viewModel.setSearchQuery,
              ),
            ),
            Expanded(
              child: filteredTemplates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: theme.colorScheme.primary.withAlpha(128),
                          ),
                          const SizedBox(height: 16),
                          Text(l10n.no_templates_saved),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: widget.scrollController,
                      itemCount: filteredTemplates.length,
                      itemBuilder: (context, index) {
                        final template = filteredTemplates[index];
                        return _buildTemplateItem(
                          context,
                          template,
                          viewModel,
                          l10n,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTemplateItem(
    BuildContext context,
    dynamic template,
    TemplateViewModel viewModel,
    AppLocalizations l10n,
  ) {
    if (template is SavedMealTemplate) {
      return ListTile(
        leading: const CircleAvatar(child: Icon(Icons.restaurant_menu)),
        title: Text(template.name),
        subtitle: Text(l10n.items_count(template.prototypes.length)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          final meal = viewModel.applyMealTemplate(template);
          Navigator.pop(context, meal);
        },
      );
    } else if (template is SavedFoodTemplate) {
      final isRecipe = template.prototype.entryType == FoodEntryType.recipe;
      return ListTile(
        leading: CircleAvatar(
          child: Icon(isRecipe ? Icons.menu_book : Icons.fastfood),
        ),
        title: Text(template.name),
        subtitle: Text(
          l10n.kcal_value(
            template.prototype.nutrition.energyKcal.toStringAsFixed(0),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          final food = viewModel.applyFoodTemplate(template);
          Navigator.pop(context, food);
        },
      );
    }
    return const SizedBox.shrink();
  }
}
