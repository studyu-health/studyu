import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_core/core.dart';

typedef NutritionRecallOpener = Future<void> Function(
  NutritionRecallRecord record,
  bool editable,
);

class const NutritionHistoryScreen({
  required final StudySubject subject,
  required final NutritionTask task,
  required final NutritionRecallOpener onOpenRecall,
  super.key,
}) extends StatefulWidget {
  static MaterialPageRoute<void> route({
    required StudySubject subject,
    required NutritionTask task,
    required NutritionRecallOpener onOpenRecall,
  }) => MaterialPageRoute(
    builder: (_) => NutritionHistoryScreen(
      subject: subject,
      task: task,
      onOpenRecall: onOpenRecall,
    ),
  );

  @override
  State<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState() extends State<NutritionHistoryScreen> {
  late Future<List<NutritionRecallRecord>> _records;

  @override
  void initState() {
    super.initState();
    _records = _loadRecords();
  }

  Future<List<NutritionRecallRecord>> _loadRecords() =>
      loadNutritionRecallRecords(
        subject: widget.subject,
        taskId: widget.task.id,
      );

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
              _recallCard(
                context,
                latest,
                currentStudyDay: currentStudyDay,
                showEditableAction: true,
              ),
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
    bool showEditableAction = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final editable =
        record.persistenceTarget != null &&
        isEditableNutritionRecallDay(
          studyDaySnapshot: record.studyDaySnapshot,
          currentStudyDay: currentStudyDay,
          hasUnambiguousPeriod:
              record.hasUnambiguousPeriod &&
              _hasCompletionPeriod(record.periodId),
        );
    final foodNames = record.recall.meals
        .expand((meal) => meal.foods)
        .map((food) => food.name)
        .toList();
    final additionalFoodCount = foodNames.length - 2;
    final isEditableLatest = showEditableAction && editable;

    return Card(
      elevation: isEditableLatest ? 2 : null,
      color: isEditableLatest
          ? Color.alphaBlend(
              colorScheme.primaryContainer.withValues(alpha: 0.55),
              colorScheme.surface,
            )
          : null,
      child: ListTile(
        minVerticalPadding: 2,
        visualDensity: const VisualDensity(vertical: -1),
        onTap: () async {
          await widget.onOpenRecall(record, editable);
          if (!mounted) return;
          setState(() {
            _records = _loadRecords();
          });
        },
        title: Text(
          MaterialLocalizations.of(context)
              .formatMediumDate(record.recall.date),
        ),
        subtitle: foodNames.isEmpty
            ? Text(l10n.nutrition_history_no_foods_logged)
            : Row(
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
        trailing: Icon(
          isEditableLatest ? Icons.edit_outlined : Icons.chevron_right,
        ),
      ),
    );
  }

  bool _hasCompletionPeriod(String? id) =>
      id != null &&
      widget.task.schedule.completionPeriods.any((period) => period.id == id);
}
