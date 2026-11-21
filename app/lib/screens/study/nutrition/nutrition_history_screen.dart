import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/widgets/confirmation_dialog.dart';
import 'package:studyu_core/core.dart';

typedef NutritionRecallOpener = Future<void> Function(
  NutritionRecallRecord record,
);

class const NutritionHistoryScreen({
  required final StudySubject subject,
  required final NutritionTask task,
  required final NutritionRecallOpener onOpenRecall,
  final NutritionRecallAutoSaveManager? autoSaveManager,
  super.key,
}) extends StatefulWidget {
  static MaterialPageRoute<void> route({
    required StudySubject subject,
    required NutritionTask task,
    required NutritionRecallOpener onOpenRecall,
    NutritionRecallAutoSaveManager? autoSaveManager,
  }) => MaterialPageRoute(
    builder: (_) => NutritionHistoryScreen(
      subject: subject,
      task: task,
      onOpenRecall: onOpenRecall,
      autoSaveManager: autoSaveManager,
    ),
  );

  @override
  State<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState() extends State<NutritionHistoryScreen> {
  late Future<List<NutritionRecallRecord>> _records;
  late final _autoSaveManager =
      widget.autoSaveManager ?? NutritionRecallAutoSaveManager();

  @override
  void initState() {
    super.initState();
    _records = _loadRecords();
  }

  Future<List<NutritionRecallRecord>> _loadRecords() =>
      loadNutritionRecallRecords(
        subject: widget.subject,
        taskId: widget.task.id,
        autoSaveManager: _autoSaveManager,
        showLocalDraftsSeparately: true,
      );

  void _reloadRecords() {
    setState(() {
      _records = _loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentStudyDay = nutritionStudyDayFor(
      widget.subject,
      DateTime.now(),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nutrition_history)),
      body: FutureBuilder<List<NutritionRecallRecord>>(
        future: _records,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: FilledButton(
                onPressed: _reloadRecords,
                child: Text(l10n.try_again),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data!
              .where((record) => record.studyDaySnapshot < currentStudyDay)
              .toList();
          if (records.isEmpty) {
            return Center(child: Text(l10n.nutrition_history_empty));
          }
          final latest = records.first;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.nutrition_history_latest_study_day,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(l10n.nutrition_history_latest_study_day_description),
              const SizedBox(height: 8),
              _recallCard(context, latest, currentStudyDay: currentStudyDay),
              if (records.length > 1) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.nutrition_history_previous_study_days,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final record in records.skip(1)) ...[
                  _recallCard(
                    context,
                    record,
                    currentStudyDay: currentStudyDay,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _recallCard(
    BuildContext context,
    NutritionRecallRecord record, {
    required int currentStudyDay,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final editable = record.canEdit(widget.task, currentStudyDay);
    final foodNames = record.recall.meals
        .expand((meal) => meal.foods)
        .map((food) => food.name)
        .toList();
    final additionalFoodCount = foodNames.length - 2;
    final pending = record.pending;
    final expired =
        pending != null && record.studyDaySnapshot < currentStudyDay - 1;
    final previewStatus = expired
        ? l10n.nutrition_history_expired_draft
        : pending == null
        ? null
        : l10n.nutrition_history_local_draft;

    return Card(
      elevation: editable ? 2 : null,
      color: editable
          ? Color.alphaBlend(
              colorScheme.primaryContainer.withValues(alpha: 0.55),
              colorScheme.surface,
            )
          : null,
      child: ListTile(
        minVerticalPadding: 2,
        visualDensity: const VisualDensity(vertical: -1),
        onTap: () async {
          await widget.onOpenRecall(record);
          if (!mounted) return;
          _reloadRecords();
        },
        title: Text(
          '${MaterialLocalizations.of(context).formatMediumDate(widget.subject.nutritionDateForStudyDay(record.studyDaySnapshot))} UTC',
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (previewStatus != null) Text(previewStatus),
            if (foodNames.isEmpty)
              Text(l10n.nutrition_history_no_foods_logged)
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      foodNames.take(2).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (additionalFoodCount > 0) Text(' +$additionalFoodCount'),
                ],
              ),
          ],
        ),
        trailing: expired
            ? IconButton(
                tooltip: l10n.nutrition_recall_discard_draft,
                onPressed: () => _discardExpiredDraft(pending),
                icon: const Icon(Icons.delete_outline),
              )
            : Icon(editable ? Icons.edit_outlined : Icons.chevron_right),
      ),
    );
  }

  Future<void> _discardExpiredDraft(PendingRecall pending) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.nutrition_recall_discard_draft,
      message: l10n.nutrition_history_discard_expired_draft,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.nutrition_recall_discard_draft,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      if (await _autoSaveManager.deletePendingRecall(pending)) {
        if (mounted) _reloadRecords();
        return;
      }
    } catch (error, stackTrace) {
      StudyULogger.warning(
        'Could not discard a nutrition draft: $error\n$stackTrace',
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.nutrition_recall_discard_failed)),
    );
    _reloadRecords();
  }
}
