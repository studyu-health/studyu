import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/my_templates_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_app/widgets/template_selection_sheet.dart';
import 'package:studyu_core/core.dart';

class const NutritionTaskWidget({
  final DailyRecall? existingRecall,
  final NutritionTask? task,
  final CompletionPeriod? completionPeriod,
  super.key,
}) extends StatefulWidget {
  static MaterialPageRoute<DailyRecall> route({
    DailyRecall? existingRecall,
    NutritionTask? task,
    CompletionPeriod? completionPeriod,
  }) => MaterialPageRoute(
    builder: (_) => NutritionTaskWidget(
      existingRecall: existingRecall,
      task: task,
      completionPeriod: completionPeriod,
    ),
  );

  @override
  State<NutritionTaskWidget> createState() => _NutritionTaskWidgetState();
}

class _NutritionTaskWidgetState()
    extends State<NutritionTaskWidget>
    with WidgetsBindingObserver {
  DailyRecallEntryViewModel? _viewModel;
  late TextEditingController _specialOccasionController;
  VoidCallback? _viewModelListener;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _specialOccasionController = TextEditingController(
      text: widget.existingRecall?.specialOccasion ?? '',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _viewModel?.onAppLifecycleStateChanged(state);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _specialOccasionController.dispose();
    if (_viewModelListener != null && _viewModel != null) {
      _viewModel!.removeListener(_viewModelListener!);
    }
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null) {
      final appState = Provider.of<AppState>(context, listen: false);
      _viewModel = DailyRecallEntryViewModel(
        subject: appState.activeSubject,
        task: widget.task,
        completionPeriod: widget.completionPeriod,
        existingRecall: widget.existingRecall,
      );
      _viewModel!.shouldSaveToDb = appState.trackParticipantProgress;

      _viewModelListener = () {
        if (_viewModel!.recall.specialOccasion != null &&
            _specialOccasionController.text !=
                _viewModel!.recall.specialOccasion) {
          if (_specialOccasionController.text.isEmpty &&
              _viewModel!.recall.specialOccasion!.isNotEmpty) {
            _specialOccasionController.text =
                _viewModel!.recall.specialOccasion!;
          }
        }
      };
      _viewModel!.addListener(_viewModelListener!);
    }

    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Consumer<DailyRecallEntryViewModel>(
        builder: (context, model, child) {
          final theme = Theme.of(context);
          final l10n = AppLocalizations.of(context)!;
          final recall = model.recall;

          return PopScope(
            canPop:
                !model.isInTaskMode ||
                widget.task?.minimumMealsRequired == null ||
                model.meetsMinimumMeals,
            onPopInvokedWithResult: (bool didPop, _) async {
              if (didPop) return;
              final shouldPop = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.min_meals_not_met_title),
                  content: Text(
                    l10n.min_meals_not_met_message(
                      widget.task!.minimumMealsRequired!,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(l10n.leave_anyway),
                    ),
                  ],
                ),
              );
              if (shouldPop == true && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              appBar: _buildAppBar(context, model, l10n, theme),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          if (widget.task?.header != null) ...[
                            HtmlText(widget.task!.header, centered: true),
                            const SizedBox(height: 16),
                          ],
                          if (model.isInTaskMode &&
                              (widget.task?.instructions != null ||
                                  widget.task?.minimumMealsRequired != null))
                            _buildInstructionsCard(context, theme, l10n),
                          _buildDateDisplayCard(
                            context,
                            model,
                            recall,
                            theme,
                            l10n,
                          ),
                          const SizedBox(height: 8),
                          _buildMealsSection(
                            context,
                            model,
                            recall,
                            theme,
                            l10n,
                          ),
                          if (recall.meals.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            DailyNutritionSummaryCard(dailyRecall: recall),
                          ],
                          if (widget.task?.footer != null) ...[
                            const SizedBox(height: 16),
                            HtmlText(widget.task!.footer, centered: true),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  if (model.isInTaskMode)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isCompleting || !model.meetsMinimumMeals
                              ? null
                              : () => _completeTask(model),
                          icon: _isCompleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: Text(l10n.complete),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _completeTask(DailyRecallEntryViewModel model) async {
    if (_isCompleting || !model.meetsMinimumMeals) return;
    setState(() => _isCompleting = true);
    try {
      await model.flushPendingAutoSave();
      final completedRecall = model.markCompleted();
      if (model.shouldSaveToDb && model.subject != null) {
        await model.subject!.upsertNutritionResult(
          taskId: widget.task!.id,
          periodId: widget.completionPeriod!.id,
          recall: completedRecall,
        );
      }
      if (mounted) Navigator.of(context).pop(completedRecall);
    } catch (error) {
      if (mounted) {
        setState(() => _isCompleting = false);
        StudyULogger.error('Failed to save nutrition results: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.could_not_save_results),
          ),
        );
      }
    }
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DailyRecallEntryViewModel model,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return AppBar(
      title: Text(
        widget.task?.title ?? l10n.daily_food_diary,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: model.lastSaveTime != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(32),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      model.isSaving ? Icons.cloud_queue : Icons.cloud_done,
                      size: 14,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      model.isSaving
                          ? l10n.saving
                          : l10n.saved_ago(
                              _formatTimeSince(context, model.lastSaveTime!),
                            ),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInstructionsCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.info_outline,
            size: 20,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          l10n.instructions,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Text(
            widget.task?.instructions ?? l10n.nutrition_instructions_default,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (widget.task?.minimumMealsRequired != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.min_meals_required(widget.task!.minimumMealsRequired!),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateDisplayCard(
    BuildContext context,
    DailyRecallEntryViewModel model,
    DailyRecall recall,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.today_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.today,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              _formatFullDate(recall.date),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date);
  }

  Widget _buildMealsSection(
    BuildContext context,
    DailyRecallEntryViewModel model,
    DailyRecall recall,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).push(MyTemplatesScreen.route());
          },
          icon: const Icon(Icons.bookmark_outline, size: 18),
          label: Text(l10n.my_templates),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  l10n.meals,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.task?.minimumMealsRequired != null) ...[
                  const SizedBox(width: 8),
                  _MinMealsProgressChip(
                    current: recall.meals.where((m) => !m.isSkipped).length,
                    minimum: widget.task!.minimumMealsRequired!,
                    theme: theme,
                  ),
                ],
              ],
            ),
            Row(
              children: [
                // Quick add from template button
                Semantics(
                  label: l10n.from_template,
                  button: true,
                  child: IconButton.outlined(
                    onPressed: () => _addMealFromTemplate(context, model),
                    icon: const Icon(Icons.bookmark, size: 18),
                    tooltip: l10n.from_template,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: l10n.add_meal,
                  button: true,
                  child: FilledButton(
                    onPressed: () => _addMeal(context, model),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 18),
                        const SizedBox(width: 6),
                        Text(l10n.add_meal),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recall.meals.isEmpty)
          _EmptyMealsState(theme: theme, l10n: l10n)
        else
          ...List.generate(recall.meals.length, (index) {
            final meal = recall.meals[index];
            return _MealCard(
              meal: meal,
              index: index,
              onTap: () => _editMeal(context, model, meal, index),
              onEdit: () => _editMeal(context, model, meal, index),
              onSaveTemplate: () => _saveMealAsTemplate(context, meal),
              onDelete: () => model.removeMeal(index),
              getMealTypeLabel: (type) => _getMealTypeLabel(context, type),
            );
          }),
      ],
    );
  }

  Future<void> _addMeal(
    BuildContext context,
    DailyRecallEntryViewModel model,
  ) async {
    final result = await Navigator.of(context)
        .push(MealEntryScreen.route(task: widget.task));
    if (result != null) {
      model.addMeal(result);
    }
  }

  Future<void> _editMeal(
    BuildContext context,
    DailyRecallEntryViewModel model,
    MealLog meal,
    int index,
  ) async {
    final result = await Navigator.of(context)
        .push(MealEntryScreen.route(existingMeal: meal, task: widget.task));
    if (result != null) {
      model.updateMeal(index, result);
    }
  }

  String _getMealTypeLabel(BuildContext context, MealType type) {
    final l10n = AppLocalizations.of(context)!;
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

  String _formatTimeSince(BuildContext context, DateTime time) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 10) {
      return l10n.just_now;
    } else if (diff.inSeconds < 60) {
      return l10n.seconds_ago(diff.inSeconds);
    } else if (diff.inMinutes < 60) {
      return l10n.minutes_ago(diff.inMinutes);
    } else {
      return l10n.hours_ago(diff.inHours);
    }
  }

  Future<void> _saveMealAsTemplate(BuildContext context, MealLog meal) async {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final result = await SaveTemplateDialog.show(
      context,
      initialName:
          meal.customMealLabel ?? _getMealTypeLabel(context, meal.mealType),
      templateType: TemplateType.meal,
    );

    if (result != null && context.mounted) {
      final viewModel = TemplateViewModel(userId: userId);
      await viewModel.saveMealAsTemplate(
        name: result.name,
        meal: meal,
        tags: result.tags,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.template_saved)));
      }
    }
  }

  Future<void> _addMealFromTemplate(
    BuildContext context,
    DailyRecallEntryViewModel model,
  ) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final result = await TemplateSelectionSheet.show(
      context,
      mode: TemplateSelectionMode.meal,
      userId: userId,
    );

    if (result is MealLog) {
      model.addMeal(result);
    }
  }
}

class const _EmptyMealsState({
  required final ThemeData theme,
  required final AppLocalizations l10n,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_outlined,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.no_meals_recorded,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.tap_to_add_first_meal,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class const _MealCard({
  required final MealLog meal,
  required final int index,
  required final VoidCallback onTap,
  required final VoidCallback onEdit,
  required final VoidCallback onSaveTemplate,
  required final VoidCallback onDelete,
  required final String Function(MealType) getMealTypeLabel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _MealTypeAvatar(meal: meal, getMealTypeLabel: getMealTypeLabel),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.customMealLabel ?? getMealTypeLabel(meal.mealType),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.food_items_count(meal.foods.length)} • ${_formatTime(meal.timestamp)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                tooltip: l10n.more_options,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'save_template':
                      onSaveTemplate();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: _PopupMenuItem(
                      icon: Icons.edit_outlined,
                      label: l10n.edit,
                    ),
                  ),
                  if (meal.foods.isNotEmpty)
                    PopupMenuItem(
                      value: 'save_template',
                      child: _PopupMenuItem(
                        icon: Icons.bookmark_add_outlined,
                        label: l10n.save_as_template,
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: _PopupMenuItem(
                      icon: Icons.delete_outline,
                      label: l10n.delete,
                      isDestructive: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class const _MealTypeAvatar({
  required final MealLog meal,
  required final String Function(MealType) getMealTypeLabel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;

    switch (meal.mealType) {
      case MealType.breakfast:
        icon = Icons.wb_sunny_outlined;
        color = Colors.amber;
      case MealType.brunch:
        icon = Icons.brunch_dining_outlined;
        color = Colors.orange;
      case MealType.lunch:
        icon = Icons.lunch_dining_outlined;
        color = Colors.green;
      case MealType.dinner:
        icon = Icons.dinner_dining_outlined;
        color = Colors.indigo;
      case MealType.snack:
        icon = Icons.cookie_outlined;
        color = Colors.purple;
      case MealType.other:
        icon = Icons.restaurant_outlined;
        color = theme.colorScheme.primary;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Icon(icon, size: 22, color: color)),
    );
  }
}

class const _PopupMenuItem({
  required final IconData icon,
  required final String label,
  final bool isDestructive = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isDestructive ? Theme.of(context).colorScheme.error : null,
          ),
        ),
      ],
    );
  }
}

class const _MinMealsProgressChip({
  required final int current,
  required final int minimum,
  required final ThemeData theme,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final met = current >= minimum;
    final color = met ? Colors.green : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle_outline : Icons.restaurant_menu,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$current/$minimum',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
