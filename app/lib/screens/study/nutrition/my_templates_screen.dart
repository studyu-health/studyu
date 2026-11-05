import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

class const MyTemplatesScreen({super.key}) extends StatelessWidget {
  static MaterialPageRoute<void> route() =>
      MaterialPageRoute(builder: (_) => const MyTemplatesScreen());

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    return ChangeNotifierProvider(
      create: (_) => TemplateViewModel(userId: userId),
      child: const _MyTemplatesScreenContent(),
    );
  }
}

class const _MyTemplatesScreenContent() extends StatefulWidget {
  @override
  State<_MyTemplatesScreenContent> createState() =>
      _MyTemplatesScreenContentState();
}

class _MyTemplatesScreenContentState()
    extends State<_MyTemplatesScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getFilterLabel(AppLocalizations l10n, TemplateFilter filter) {
    switch (filter) {
      case TemplateFilter.all:
        return l10n.filter_all;
      case TemplateFilter.meals:
        return l10n.filter_meals;
      case TemplateFilter.foods:
        return l10n.filter_foods;
      case TemplateFilter.recipes:
        return l10n.filter_recipes;
    }
  }

  String _getMealTypeLabel(AppLocalizations l10n, MealType type) {
    switch (type) {
      case MealType.breakfast:
        return l10n.meal_type_breakfast;
      case MealType.brunch:
        return l10n.meal_type_brunch;
      case MealType.lunch:
        return l10n.meal_type_lunch;
      case MealType.dinner:
        return l10n.meal_type_dinner;
      case MealType.snack:
        return l10n.meal_type_snack;
      case MealType.other:
        return l10n.meal_type_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Consumer<TemplateViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.my_templates)),
          body: Column(
            children: [
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: TemplateFilter.values.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: viewModel.currentFilter == filter,
                        label: Text(_getFilterLabel(l10n, filter)),
                        onSelected: (_) => viewModel.setFilter(filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.filteredTemplates.isEmpty
                    ? _buildEmptyState(l10n, theme)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.filteredTemplates.length,
                        itemBuilder: (context, index) {
                          final template = viewModel.filteredTemplates[index];
                          return _buildTemplateCard(
                            context,
                            template,
                            viewModel,
                            l10n,
                            theme,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: theme.colorScheme.primary.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(l10n.no_templates_saved, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l10n.save_templates_hint,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    dynamic template,
    TemplateViewModel viewModel,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (template is SavedMealTemplate) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.restaurant_menu,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(template.name),
          subtitle: Text(
            '${l10n.items_count(template.prototypes.length)} - ${_getMealTypeLabel(l10n, template.mealType)}',
          ),
          trailing: PopupMenuButton<String>(
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(l10n.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      l10n.delete,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'rename') {
                _showRenameDialog(context, viewModel, template, l10n);
              } else if (value == 'delete') {
                _confirmDelete(context, viewModel, template, l10n);
              }
            },
          ),
        ),
      );
    } else if (template is SavedFoodTemplate) {
      final isRecipe = template.prototype.entryType == FoodEntryType.recipe;
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isRecipe
                ? Colors.orange.shade100
                : theme.colorScheme.secondaryContainer,
            child: Icon(
              isRecipe ? Icons.menu_book : Icons.fastfood,
              color: isRecipe
                  ? Colors.orange.shade700
                  : theme.colorScheme.onSecondaryContainer,
            ),
          ),
          title: Text(template.name),
          subtitle: Text(
            l10n.kcal_value(
              template.prototype.nutrition.energyKcal.toStringAsFixed(0),
            ),
          ),
          trailing: PopupMenuButton<String>(
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(l10n.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      l10n.delete,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'rename') {
                _showRenameDialog(context, viewModel, template, l10n);
              } else if (value == 'delete') {
                _confirmDelete(context, viewModel, template, l10n);
              }
            },
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TemplateViewModel viewModel,
    dynamic template,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.delete_template),
        content: Text(l10n.delete_template_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (template is SavedMealTemplate) {
        await viewModel.deleteMealTemplate(template.id);
      } else if (template is SavedFoodTemplate) {
        await viewModel.deleteFoodTemplate(template.id);
      }
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    TemplateViewModel viewModel,
    dynamic template,
    AppLocalizations l10n,
  ) async {
    final currentName = template is SavedMealTemplate
        ? template.name
        : (template as SavedFoodTemplate).name;

    final controller = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rename_template),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.new_name,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    controller.dispose();

    if (newName != null && newName != currentName) {
      if (template is SavedMealTemplate) {
        await viewModel.renameMealTemplate(template.id, newName);
      } else if (template is SavedFoodTemplate) {
        await viewModel.renameFoodTemplate(template.id, newName);
      }
    }
  }
}
