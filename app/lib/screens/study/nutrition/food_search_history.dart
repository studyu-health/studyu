import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_core/core.dart';

const _historySectionLimit = 5;

final class const FoodSearchHistory({
  required final List<FoodSearchHistoryItem> recent,
  required final List<FoodSearchHistoryItem> frequentlyUsed,
}) {
  static const empty = FoodSearchHistory(recent: [], frequentlyUsed: []);
}

final class const FoodSearchHistoryItem({
  required final String identity,
  required final FoodEntry food,
  required final int useCount,
  required final DateTime lastUsedAt,
}) {
  FoodEntry createSelection() => duplicateFoodEntry(food);
}

FoodSearchHistory buildFoodSearchHistory(
  Iterable<SubjectProgress> progress, {
  required String subjectId,
}) {
  final entries = <String, _HistoryAccumulator>{};

  for (final item in progress) {
    if (item.subjectId != subjectId || item.resultType != 'DailyRecall') {
      continue;
    }
    final result = item.result.result;
    if (result is! DailyRecall) continue;

    for (final meal in result.meals) {
      final occurrenceTimestamp =
          meal.timePrecision == MealOccurrenceTimePrecision.unknown
          ? null
          : meal.timestamp;
      final historyDate = occurrenceTimestamp ?? result.date;
      for (final food in meal.foods) {
        final identity = foodHistoryIdentity(food);
        final existing = entries[identity];
        if (existing == null) {
          entries[identity] = _HistoryAccumulator(
            food: cloneFoodEntry(food),
            useCount: 1,
            lastUsedAt: historyDate,
          );
          continue;
        }

        existing.useCount++;
        if (historyDate.isAfter(existing.lastUsedAt) ||
            (historyDate == existing.lastUsedAt &&
                food.id.compareTo(existing.food.id) < 0)) {
          existing
            ..food = cloneFoodEntry(food)
            ..lastUsedAt = historyDate;
        }
      }
    }
  }

  final all = entries.entries
      .map(
        (entry) => FoodSearchHistoryItem(
          identity: entry.key,
          food: entry.value.food,
          useCount: entry.value.useCount,
          lastUsedAt: entry.value.lastUsedAt,
        ),
      )
      .toList();

  final frequentlyUsed = all.where((item) => item.useCount > 1).toList()
    ..sort(_compareFrequentlyUsed);
  final visibleFrequentlyUsed = frequentlyUsed
      .take(_historySectionLimit)
      .toList(growable: false);
  final frequentIdentities = visibleFrequentlyUsed
      .map((item) => item.identity)
      .toSet();

  final recent =
      all.where((item) => !frequentIdentities.contains(item.identity)).toList()
        ..sort(_compareRecent);

  return FoodSearchHistory(
    recent: recent.take(_historySectionLimit).toList(growable: false),
    frequentlyUsed: visibleFrequentlyUsed,
  );
}

String foodHistoryIdentity(FoodEntry food) => food.foodId;

int _compareFrequentlyUsed(
  FoodSearchHistoryItem left,
  FoodSearchHistoryItem right,
) {
  final countComparison = right.useCount.compareTo(left.useCount);
  if (countComparison != 0) return countComparison;
  return _compareRecent(left, right);
}

int _compareRecent(FoodSearchHistoryItem left, FoodSearchHistoryItem right) {
  final dateComparison = right.lastUsedAt.compareTo(left.lastUsedAt);
  if (dateComparison != 0) return dateComparison;
  return left.identity.compareTo(right.identity);
}

final class _HistoryAccumulator({
  required var FoodEntry food,
  required var int useCount,
  required var DateTime lastUsedAt,
});
