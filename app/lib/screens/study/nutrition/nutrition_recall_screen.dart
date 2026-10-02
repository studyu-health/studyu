import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/tasks/observation/nutrition_task_widget.dart';
import 'package:studyu_core/core.dart';

class const NutritionRecallScreen({super.key}) extends StatefulWidget {
  static MaterialPageRoute<void> route() =>
      MaterialPageRoute(builder: (_) => const NutritionRecallScreen());

  @override
  State<NutritionRecallScreen> createState() => _NutritionRecallScreenState();
}

class _NutritionRecallScreenState() extends State<NutritionRecallScreen> {
  List<DailyRecall> dailyRecalls = [];

  Future<void> _startNewRecall() async {
    final result = await Navigator.of(context)
        .push(NutritionTaskWidget.route());
    if (result != null && mounted) {
      setState(() {
        dailyRecalls.add(result);
      });
    }
  }

  Future<void> _viewRecall(DailyRecall recall) async {
    await Navigator.of(context)
        .push(NutritionTaskWidget.route(existingRecall: recall));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.daily_food_diary)),
      body: dailyRecalls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.no_meals_recorded,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.add_meal, style: theme.textTheme.bodyMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dailyRecalls.length,
              itemBuilder: (context, index) {
                final recall = dailyRecalls[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${recall.meals.length}'),
                    ),
                    title: Text(
                      '${recall.date.day}/${recall.date.month}/${recall.date.year}',
                    ),
                    subtitle: Text(l10n.meals_count(recall.meals.length)),
                    trailing: Icon(
                      recall.entryCompletedAt != null
                          ? Icons.check_circle
                          : Icons.edit,
                      color: recall.entryCompletedAt != null
                          ? Colors.green
                          : Colors.orange,
                    ),
                    onTap: () => _viewRecall(recall),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewRecall,
        child: const Icon(Icons.add),
      ),
    );
  }
}
