import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/photo_reference.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/food_library_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_action_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_add_button.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_help_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_history_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_statistics_view.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_water_card.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/widgets/confirmation_dialog.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_app/widgets/photo_recall_section.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_core/core.dart';

class const NutritionTaskWidget({
  final DailyRecall? existingRecall,
  final NutritionTask? task,
  final CompletionPeriod? completionPeriod,
  final NutritionRecallPersistenceTarget? persistenceTarget,
  final DateTime? historicalDate,
  final String? interventionId,
  final bool readOnly = false,
  final NutritionFoodRepository? foodRepository,
  super.key,
}) extends StatefulWidget {
  static MaterialPageRoute<DailyRecall> route({
    DailyRecall? existingRecall,
    NutritionTask? task,
    CompletionPeriod? completionPeriod,
    NutritionRecallPersistenceTarget? persistenceTarget,
    DateTime? historicalDate,
    String? interventionId,
    bool readOnly = false,
    NutritionFoodRepository? foodRepository,
  }) => MaterialPageRoute(
    builder: (_) => NutritionTaskWidget(
      existingRecall: existingRecall,
      task: task,
      completionPeriod: completionPeriod,
      persistenceTarget: persistenceTarget,
      historicalDate: historicalDate,
      interventionId: interventionId,
      readOnly: readOnly,
      foodRepository: foodRepository,
    ),
  );

  @override
  State<NutritionTaskWidget> createState() => _NutritionTaskWidgetState();
}

class _NutritionTaskWidgetState()
    extends State<NutritionTaskWidget>
    with WidgetsBindingObserver {
  static const _exitDestination = 3;
  static const _cupSizeKey = 'nutrition_water_cup_size_ml';
  static const _defaultCupSizeMl = 250;

  DailyRecallEntryViewModel? _viewModel;
  TemplateViewModel? _templateViewModel;
  int _selectedDestination = 0;
  bool _didHandleExpiredHistoricalEdit = false;
  int? _cupSizeMl;
  bool _isSavingCupSize = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!widget.readOnly) unawaited(_loadCupSize());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_showInstructionsIfNeeded());
    });
  }

  Future<void> _loadCupSize() async {
    int? savedSize;
    try {
      final preferences = await SharedPreferences.getInstance();
      savedSize = preferences.getInt(_cupSizeKey);
    } catch (error) {
      StudyULogger.warning('Could not load the water cup size: $error');
    }
    if (!mounted) return;
    setState(() {
      _cupSizeMl = savedSize != null && isValidWaterCupSize(savedSize)
          ? savedSize
          : _defaultCupSizeMl;
    });
  }

  Future<void> _editCupSize(BuildContext context, int cupSizeMl) async {
    final size = await showWaterCupSizeDialog(context, cupSizeMl);
    if (size == null || size == cupSizeMl || !context.mounted) return;
    setState(() => _isSavingCupSize = true);
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!await preferences.setInt(_cupSizeKey, size)) {
        throw StateError('Could not save the water cup size.');
      }
      if (mounted) setState(() => _cupSizeMl = size);
    } catch (error) {
      StudyULogger.warning('Could not save the water cup size: $error');
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.nutrition_water_cup_size_save_error)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingCupSize = false);
    }
  }

  Future<void> _showInstructionsIfNeeded() async {
    final task = widget.task;
    if (task == null || widget.readOnly) return;

    final preferences = await SharedPreferences.getInstance();
    final key = 'nutrition_instructions_shown_${task.id}';
    if (!mounted || preferences.getBool(key) == true) return;

    await preferences.setBool(key, true);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.instructions),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nutritionInstructionsText(context, task)),
              if (task.minimumMealsRequired case final minimumMeals?) ...[
                const SizedBox(height: 8),
                Text(l10n.min_meals_required(minimumMeals)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _viewModel?.onAppLifecycleStateChanged(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel?.dispose();
    _templateViewModel?.dispose();
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
        persistenceTarget: widget.persistenceTarget,
        interventionId: widget.interventionId,
        readOnly: widget.readOnly,
        historicalMode: _isHistoricalMode,
      )..shouldSaveToDb = appState.trackParticipantProgress;
      if (!_isHistoricalMode) {
        _templateViewModel = TemplateViewModel(
          userId: appState.activeSubject?.id ?? 'anonymous',
          repository: widget.foodRepository,
        );
      }
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _viewModel!),
        if (_templateViewModel != null)
          ChangeNotifierProvider.value(value: _templateViewModel!),
      ],
      child: Consumer<DailyRecallEntryViewModel>(
        builder: (context, model, child) {
          final l10n = AppLocalizations.of(context)!;
          final appState = context.read<AppState>();
          if (model.historicalEligibilityExpired) {
            _returnToHistoryAfterExpiration(context, l10n);
          }
          return PopScope(
            canPop:
                widget.readOnly ||
                model.historicalEligibilityExpired ||
                !model.isInTaskMode,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop || widget.readOnly) return;
              if (!model.meetsMinimumMeals) {
                final shouldLeave = await showConfirmationDialog(
                  context,
                  title: l10n.min_meals_not_met_title,
                  message: l10n.min_meals_not_met_message(
                    widget.task!.minimumMealsRequired!,
                  ),
                  cancelLabel: l10n.cancel,
                  confirmLabel: l10n.leave_anyway,
                );
                if (!shouldLeave || !context.mounted) return;
              }
              try {
                await model.flushPendingAutoSave(persistToDatabase: true);
                if (context.mounted) Navigator.of(context).pop();
              } catch (error) {
                if (!context.mounted) return;
                StudyULogger.error('Failed to save nutrition results: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.could_not_save_results)),
                );
              }
            },
            child: Scaffold(
              appBar: _buildAppBar(
                context,
                model,
                l10n,
                appState.activeSubject,
              ),
              body: _isHistoricalMode
                  ? _buildToday(context, model, l10n)
                  : IndexedStack(
                      index: _selectedDestination,
                      children: [
                        _buildToday(context, model, l10n),
                        NutritionStatisticsView(
                          isVisible: _selectedDestination == 1,
                          subject: appState.activeSubject,
                          taskId: widget.task?.id,
                          activeRecall: model.recall,
                          activeStudyDay: model.studyDaySnapshot,
                          activePeriodId:
                              model.persistenceTarget?.periodId ??
                              widget.completionPeriod?.id,
                          onOpenRecall: widget.task == null
                              ? null
                              : (record) => _openRecall(
                                  context,
                                  appState.activeSubject,
                                  widget.task!,
                                  record,
                                ),
                        ),
                        const FoodLibraryScreen(embedded: true),
                      ],
                    ),
              bottomNavigationBar: _isHistoricalMode
                  ? null
                  : NavigationBar(
                      selectedIndex: _selectedDestination,
                      onDestinationSelected: (index) async {
                        if (index == _exitDestination) {
                          await Navigator.of(context).maybePop();
                          return;
                        }
                        setState(() => _selectedDestination = index);
                        if (index == 2) {
                          await _templateViewModel?.loadAllTemplates();
                        }
                      },
                      destinations: [
                        NavigationDestination(
                          icon: const Icon(Icons.today_outlined),
                          selectedIcon: const Icon(Icons.today),
                          label: l10n.today,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.bar_chart_outlined),
                          selectedIcon: const Icon(Icons.bar_chart),
                          label: l10n.nutrition_statistics,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.bookmark_outline),
                          selectedIcon: const Icon(Icons.bookmark),
                          label: l10n.food_library,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.exit_to_app),
                          label: l10n.nutrition_exit,
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  bool get _isHistoricalMode => widget.historicalDate != null;

  void _returnToHistoryAfterExpiration(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (_didHandleExpiredHistoricalEdit) return;
    _didHandleExpiredHistoricalEdit = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final historicalRoute = ModalRoute.of(context);
      if (historicalRoute == null) return;
      final navigator = Navigator.of(context);
      navigator.popUntil((route) => route == historicalRoute);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.historical_edit_expired)));
      navigator.maybePop();
    });
  }

  String _historicalDateTitle(BuildContext context, AppLocalizations l10n) {
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(widget.historicalDate!);
    return widget.readOnly ? date : l10n.historical_editing_date(date);
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DailyRecallEntryViewModel model,
    AppLocalizations l10n,
    StudySubject? subject,
  ) => AppBar(
    automaticallyImplyLeading: _isHistoricalMode,
    centerTitle: _isHistoricalMode ? null : false,
    title: Text(
      _isHistoricalMode
          ? _historicalDateTitle(context, l10n)
          : switch (_selectedDestination) {
              0 => l10n.nutrition_tracking,
              1 => l10n.nutrition_statistics,
              _ => l10n.food_library,
            },
    ),
    actions: _isHistoricalMode
        ? const []
        : [
            if (widget.readOnly && _selectedDestination != 1)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(l10n.nutrition_read_only),
                ),
              ),
            if (_selectedDestination == 0 && widget.task != null)
              IconButton(
                icon: const Icon(Icons.history_outlined),
                tooltip: l10n.nutrition_history,
                onPressed: subject == null
                    ? null
                    : () => _openHistory(context, subject, widget.task!),
              ),
            if (widget.task != null)
              IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: l10n.help,
                onPressed: _selectedDestination == 1
                    ? () => showDialog<void>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(l10n.nutrition_statistics),
                          content: Text(l10n.nutrition_statistics_help_message),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(l10n.close),
                            ),
                          ],
                        ),
                      )
                    : () => Navigator.of(context)
                          .push(NutritionHelpScreen.route(task: widget.task!)),
              ),
            if (_selectedDestination == 2)
              FoodLibraryScreen.createButton(context),
          ],
  );

  Widget _buildToday(
    BuildContext context,
    DailyRecallEntryViewModel model,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final recall = model.recall;
    final bottomInset = _isHistoricalMode
        ? MediaQuery.paddingOf(context).bottom
        : 0.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isHistoricalMode) ...[
            const SizedBox(height: 16),
            MaterialBanner(
              padding: const EdgeInsets.all(8),
              leading: Icon(
                Icons.edit_calendar_outlined,
                color: theme.colorScheme.onSecondaryContainer,
                size: 24,
              ),
              content: DefaultTextStyle.merge(
                style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.historical_edit_mode_heading,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.readOnly
                          ? l10n.nutrition_read_only
                          : l10n.historical_edit_mode_description,
                    ),
                  ],
                ),
              ),
              actions: const [SizedBox.shrink()],
              elevation: 0,
              backgroundColor: theme.colorScheme.secondaryContainer,
              dividerColor: Colors.transparent,
            ),
            const SizedBox(height: 32),
          ] else if (widget.task?.header case final header?
              when header.trim().isNotEmpty) ...[
            HtmlText(header, centered: true),
            const SizedBox(height: 16),
          ],
          _buildMealsSection(context, model, recall, theme, l10n),
          const SizedBox(height: 24),
          NutritionWaterCard(
            waterIntakeMl: recall.waterIntakeMl,
            cupSizeMl: _cupSizeMl ?? _defaultCupSizeMl,
            readOnly: widget.readOnly,
            onAdjust: _cupSizeMl == null || _isSavingCupSize
                ? null
                : (deltaMl) => unawaited(model.adjustWaterIntake(deltaMl)),
            onEditCupSize: _cupSizeMl == null || _isSavingCupSize
                ? null
                : () => _editCupSize(context, _cupSizeMl!),
          ),
          if (!_isHistoricalMode && !widget.readOnly && !kIsWeb) ...[
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.photoRecallTitle),
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(
                    l10n.photoRecallSubtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  PhotoRecallSection(
                    date: recall.date,
                    onPhotoTap: (photo) =>
                        _addMeal(context, model, recallPhoto: photo),
                  ),
                ],
              ),
            ),
          ],
          if (_isHistoricalMode) ...[
            const SizedBox(height: 24),
            Text(
              l10n.daily_summary,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            DailyNutritionSummaryCard(dailyRecall: recall, showTitle: false),
          ],
          if (!_isHistoricalMode && widget.task?.footer != null) ...[
            const SizedBox(height: 16),
            HtmlText(widget.task!.footer, centered: true),
          ],
        ],
      ),
    );
  }

  Future<void> _openHistory(
    BuildContext context,
    StudySubject subject,
    NutritionTask task,
  ) async {
    await _viewModel?.flushPendingAutoSave(persistToDatabase: true);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      NutritionHistoryScreen.route(
        subject: subject,
        task: task,
        onOpenRecall: (record, editable) =>
            _openRecall(context, subject, task, record, editable: editable),
      ),
    );
    await _viewModel?.reloadCanonicalRecall();
  }

  Future<void> _openRecall(
    BuildContext context,
    StudySubject? subject,
    NutritionTask task,
    NutritionRecallRecord record, {
    bool? editable,
  }) async {
    if (subject == null) return;
    await _viewModel?.flushPendingAutoSave(persistToDatabase: true);
    if (!context.mounted) return;
    final period = _completionPeriodFor(task, record.periodId);
    final target = record.persistenceTarget;
    final canEdit =
        (editable ??
            isEditableNutritionRecallDay(
              studyDaySnapshot: record.studyDaySnapshot,
              currentStudyDay: nutritionStudyDayFor(subject, DateTime.now()),
              hasUnambiguousPeriod:
                  record.hasUnambiguousPeriod && period != null,
            )) &&
        target != null;
    await Navigator.of(context).push(
      NutritionTaskWidget.route(
        existingRecall: record.recall,
        task: task,
        completionPeriod: period,
        persistenceTarget: target,
        historicalDate: record.recall.date,
        interventionId: record.interventionId,
        readOnly: !canEdit,
        foodRepository: widget.foodRepository,
      ),
    );
    if (!context.mounted) return;
    await _loadCupSize();
    await _templateViewModel?.loadAllTemplates();
    if (canEdit &&
        context.mounted &&
        ModalRoute.of(context)?.isCurrent == true &&
        !isEditableNutritionRecallDay(
          studyDaySnapshot: record.studyDaySnapshot,
          currentStudyDay: nutritionStudyDayFor(subject, DateTime.now()),
          hasUnambiguousPeriod: period != null,
        )) {
      await _openHistory(context, subject, task);
      return;
    }
    await _viewModel?.reloadCanonicalRecall();
  }

  CompletionPeriod? _completionPeriodFor(NutritionTask task, String? id) {
    if (id == null) return null;
    for (final period in task.schedule.completionPeriods) {
      if (period.id == id) return period;
    }
    return null;
  }

  Widget _buildMealsSection(
    BuildContext context,
    DailyRecallEntryViewModel model,
    DailyRecall recall,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final entries =
        [
          for (var index = 0; index < recall.meals.length; index++)
            (index: index, meal: recall.meals[index]),
        ]..sort((left, right) {
          final leftTime = _knownTimestamp(left.meal);
          final rightTime = _knownTimestamp(right.meal);
          if (leftTime == null && rightTime == null) {
            return left.index.compareTo(right.index);
          }
          if (leftTime == null) return 1;
          if (rightTime == null) return -1;
          final comparison = leftTime.compareTo(rightTime);
          return comparison == 0
              ? left.index.compareTo(right.index)
              : comparison;
        });
    final groups = _buildTimelineGroups(context, entries);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 8,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    l10n.meals,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        MaterialLocalizations.of(context)
                            .formatMediumDate(recall.date),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (widget.task?.minimumMealsRequired case final minimum?)
                        _MinMealsProgressChip(
                          current: recall.meals
                              .where((meal) => !meal.isSkipped)
                              .length,
                          minimum: minimum,
                          theme: theme,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (!widget.readOnly)
              Flexible(
                child: NutritionAddButton(
                  onPressed: () => _addMeal(context, model),
                  label: l10n.log_meal,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l10n.no_meals_recorded),
          ),
        for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) ...[
          if (groups[groupIndex].isUnknown &&
              (groupIndex == 0 || !groups[groupIndex - 1].isUnknown))
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                l10n.time_not_remembered,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          _MealTimelineGroupHeader(category: groups[groupIndex].category),
          for (final entry in groups[groupIndex].entries)
            _MealTimelineCard(
              key: ValueKey('meal-${entry.meal.id}'),
              meal: entry.meal,
              categoryLabel: groups[groupIndex].category.label,
              onTap: widget.readOnly
                  ? null
                  : () => _editMeal(context, model, entry.meal),
              onSaveTemplate: widget.readOnly || _isHistoricalMode
                  ? null
                  : () => _saveMealAsTemplate(context, entry.meal),
              onDelete: widget.readOnly
                  ? null
                  : () => _confirmDeleteMeal(context, model, entry.meal.id),
            ),
        ],
      ],
    );
  }

  List<_MealTimelineGroup> _buildTimelineGroups(
    BuildContext context,
    List<({int index, MealLog meal})> entries,
  ) {
    final groups = <_MealTimelineGroup>[];
    for (final entry in entries) {
      final isUnknown = _knownTimestamp(entry.meal) == null;
      final category = _timelineCategory(context, entry.meal);
      final previous = groups.isEmpty ? null : groups.last;
      if (previous == null ||
          previous.isUnknown != isUnknown ||
          previous.category.key != category.key) {
        groups.add(
          _MealTimelineGroup(
            category: category,
            isUnknown: isUnknown,
            entries: [entry],
          ),
        );
      } else {
        previous.entries.add(entry);
      }
    }
    return groups;
  }

  _MealTimelineCategory _timelineCategory(BuildContext context, MealLog meal) {
    final l10n = AppLocalizations.of(context)!;
    final customLabel = meal.customMealLabel?.trim();
    if (customLabel?.isNotEmpty == true) {
      return _MealTimelineCategory(
        key: 'custom:$customLabel',
        icon: Icons.restaurant_outlined,
        color: Theme.of(context).colorScheme.primary,
        label: customLabel!,
      );
    }
    switch (meal.mealType) {
      case MealType.breakfast:
        return _MealTimelineCategory(
          key: 'breakfast',
          icon: Icons.breakfast_dining_outlined,
          color: Colors.amber,
          label: l10n.meal_type_breakfast,
        );
      case MealType.brunch:
        return _MealTimelineCategory(
          key: 'brunch',
          icon: Icons.brunch_dining_outlined,
          color: Colors.orange,
          label: l10n.meal_type_brunch,
        );
      case MealType.lunch:
        return _MealTimelineCategory(
          key: 'lunch',
          icon: Icons.lunch_dining_outlined,
          color: Colors.green,
          label: l10n.meal_type_lunch,
        );
      case MealType.dinner:
        return _MealTimelineCategory(
          key: 'dinner',
          icon: Icons.dinner_dining_outlined,
          color: Colors.indigo,
          label: l10n.meal_type_dinner,
        );
      case MealType.snack:
        return _MealTimelineCategory(
          key: 'snack',
          icon: Icons.cookie_outlined,
          color: Colors.purple,
          label: l10n.meal_type_snack,
        );
      case MealType.other:
        return _MealTimelineCategory(
          key: meal.isLabelExplicitlyUnset ? 'meal' : 'other',
          icon: Icons.restaurant_outlined,
          color: Theme.of(context).colorScheme.primary,
          label: meal.isLabelExplicitlyUnset
              ? l10n.meal_neutral_label
              : l10n.meal_type_other,
        );
    }
  }

  Future<void> _addMeal(
    BuildContext context,
    DailyRecallEntryViewModel model, {
    PhotoReference? recallPhoto,
  }) async {
    final result = await _openMealEditor(context, model, (navigator) async {
      var foods = const <FoodEntry>[];
      if (recallPhoto == null) {
        final selection = await FoodSearchScreen.show(
          context,
          mealLabel: AppLocalizations.of(context)!.meal_neutral_label,
          allowMeals: widget.task?.allowMeals ?? true,
          historicalMode: widget.persistenceTarget != null,
          repository: widget.foodRepository,
          templateViewModel: _templateViewModel,
        );
        if (!context.mounted ||
            !model.revalidateHistoricalEligibility() ||
            selection == null ||
            selection.foods.isEmpty) {
          return null;
        }
        foods = selection.foods;
      }
      return await navigator.push(
        MealEntryScreen.route(
          task: widget.task,
          initialFoods: foods,
          recallPhoto: recallPhoto,
          occurrenceDate: model.recall.date,
          historicalTarget: widget.persistenceTarget,
          foodRepository: widget.foodRepository,
        ),
      );
    });
    if (result case SavedMealEntryResult(:final meal)) model.addMeal(meal);
  }

  Future<void> _editMeal(
    BuildContext context,
    DailyRecallEntryViewModel model,
    MealLog meal,
  ) async {
    final result = await _openMealEditor(
      context,
      model,
      (navigator) => navigator.push(
        MealEntryScreen.route(
          existingMeal: meal,
          task: widget.task,
          occurrenceDate: model.recall.date,
          historicalTarget: widget.persistenceTarget,
          foodRepository: widget.foodRepository,
        ),
      ),
    );
    switch (result) {
      case SavedMealEntryResult(:final meal):
        model.updateMealById(meal.id, meal);
      case DeletedMealEntryResult():
        model.removeMealById(meal.id);
      case DiscardedMealEntryResult() || null:
        break;
    }
  }

  Future<MealEntryResult?> _openMealEditor(
    BuildContext context,
    DailyRecallEntryViewModel model,
    Future<MealEntryResult?> Function(NavigatorState) open,
  ) async {
    if (!await _flushHistoricalRecallBeforeNestedMutation(context, model) ||
        !context.mounted) {
      return null;
    }

    final suspendPersistence = _isHistoricalMode && !widget.readOnly;
    if (suspendPersistence) model.suspendPersistence();
    try {
      final result = await open(Navigator.of(context));
      if (!context.mounted || !model.revalidateHistoricalEligibility()) {
        return null;
      }
      final definitionMutated = switch (result) {
        SavedMealEntryResult(:final definitionMutated) => definitionMutated,
        DiscardedMealEntryResult() => true,
        _ => false,
      };
      if (definitionMutated) await model.reloadCanonicalRecall();
      return result;
    } finally {
      if (suspendPersistence) model.resumePersistence();
    }
  }

  Future<bool> _flushHistoricalRecallBeforeNestedMutation(
    BuildContext context,
    DailyRecallEntryViewModel model,
  ) async {
    if (!_isHistoricalMode || widget.readOnly) return true;
    try {
      await model.flushPendingAutoSave(
        persistToDatabase: true,
        requireRemoteSuccess: true,
      );
      return !model.historicalEligibilityExpired;
    } catch (error, stackTrace) {
      StudyULogger.error(
        'Failed to flush historical nutrition recall: $error\n$stackTrace',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.could_not_save_results),
          ),
        );
      }
      return false;
    }
  }

  Future<void> _confirmDeleteMeal(
    BuildContext context,
    DailyRecallEntryViewModel model,
    String mealId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.delete_meal_title,
      message: l10n.delete_meal_message,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed && context.mounted) model.removeMealById(mealId);
  }

  DateTime? _knownTimestamp(MealLog meal) =>
      meal.timePrecision == MealOccurrenceTimePrecision.unknown
      ? null
      : meal.timestamp;

  String _getMealTypeLabel(BuildContext context, MealType type) {
    final l10n = AppLocalizations.of(context)!;
    return switch (type) {
      MealType.breakfast => l10n.meal_type_breakfast,
      MealType.brunch => l10n.meal_type_brunch,
      MealType.lunch => l10n.meal_type_lunch,
      MealType.dinner => l10n.meal_type_dinner,
      MealType.snack => l10n.meal_type_snack,
      MealType.other => l10n.meal_type_other,
    };
  }

  Future<void> _saveMealAsTemplate(BuildContext context, MealLog meal) async {
    if (meal.isSkipped) return;
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final result = await SaveTemplateDialog.show(
      context,
      initialName:
          meal.customMealLabel ??
          (meal.mealType == MealType.other
              ? ''
              : _getMealTypeLabel(context, meal.mealType)),
      templateType: TemplateType.meal,
    );
    if (result == null || !context.mounted) return;
    await TemplateViewModel(
      userId: appState.activeSubject?.id ?? 'anonymous',
      repository: widget.foodRepository,
    ).saveMealAsTemplate(name: result.name, meal: meal, tags: result.tags);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.template_saved)));
    }
  }
}

class const _MealTimelineCategory({
  required final String key,
  required final IconData icon,
  required final Color color,
  required final String label,
});

class _MealTimelineGroup({
  required final _MealTimelineCategory category,
  required final bool isUnknown,
  required final List<({int index, MealLog meal})> entries,
});

class const _MealTimelineGroupHeader({
  required final _MealTimelineCategory category,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: category.label,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, size: 22, color: category.color),
              ),
              const SizedBox(width: 12),
              Text(
                category.label,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MealTimelineAction() { edit, delete }

class const _MealTimelineCard({
  super.key,
  required final MealLog meal,
  required final String categoryLabel,
  final VoidCallback? onTap,
  final VoidCallback? onSaveTemplate,
  final VoidCallback? onDelete,
}) extends StatelessWidget {
  Future<void> _showActions(BuildContext context, String subtitle) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showNutritionActionSheet<_MealTimelineAction>(
      context,
      title: categoryLabel,
      subtitle: subtitle,
      actions: [
        NutritionSheetAction(
          value: _MealTimelineAction.edit,
          label: l10n.edit,
          icon: Icons.edit_outlined,
        ),
        if (onDelete != null)
          NutritionSheetAction(
            value: _MealTimelineAction.delete,
            label: l10n.delete,
            icon: Icons.delete_outline,
            isDestructive: true,
          ),
      ],
    );
    if (!context.mounted) return;
    switch (action) {
      case _MealTimelineAction.edit:
        onTap?.call();
      case _MealTimelineAction.delete:
        onDelete?.call();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final foodNames = meal.foods.map((food) => food.name).join(', ');
    final totalEnergy = meal.foods.fold<double>(
      0,
      (sum, food) => sum + food.nutrition.energyKcal,
    );
    final time =
        meal.timestamp == null ||
            meal.timePrecision == MealOccurrenceTimePrecision.unknown
        ? l10n.time_not_remembered
        : meal.timePrecision == MealOccurrenceTimePrecision.approximate
        ? l10n.about_time(
            MaterialLocalizations.of(context)
                .formatTimeOfDay(TimeOfDay.fromDateTime(meal.timestamp!)),
          )
        : MaterialLocalizations.of(context)
              .formatTimeOfDay(TimeOfDay.fromDateTime(meal.timestamp!));

    final subtitle = [
      time,
      if (meal.isSkipped && meal.skipReason?.trim().isNotEmpty == true)
        meal.skipReason!.trim()
      else if (!meal.isSkipped)
        l10n.kcal_value(totalEnergy.toStringAsFixed(0)),
    ].join(' • ');

    return Semantics(
      container: true,
      label: [
        categoryLabel,
        if (meal.isSkipped)
          l10n.skipped_this_meal
        else if (foodNames.isNotEmpty)
          foodNames
        else
          l10n.no_foods_added,
        time,
        if (meal.isSkipped && meal.skipReason?.trim().isNotEmpty == true)
          meal.skipReason!.trim(),
        if (!meal.isSkipped) l10n.kcal_value(totalEnergy.toStringAsFixed(0)),
      ].join('. '),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.isSkipped
                              ? l10n.skipped_this_meal
                              : foodNames.isEmpty
                              ? l10n.no_foods_added
                              : foodNames,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (onTap != null)
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    tooltip: l10n.more_options,
                    onPressed: () => _showActions(context, subtitle),
                  ),
              ],
            ),
          ),
        ),
      ),
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
