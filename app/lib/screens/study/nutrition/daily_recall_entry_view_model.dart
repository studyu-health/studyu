import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_core/core.dart';

class DailyRecallEntryViewModel({
  final StudySubject? subject,
  final NutritionTask? task,
  final CompletionPeriod? completionPeriod,
  DailyRecall? existingRecall,
}) extends ChangeNotifier {
  final NutritionRecallAutoSaveManager _autoSaveManager =
      NutritionRecallAutoSaveManager();

  late DailyRecall recall;
  bool isSaving = false;
  DateTime? lastSaveTime;

  Timer? _autoSaveTimer;
  Future<void>? _autoSaveFuture;
  int? _studyDaySnapshot;
  String? _interventionId;
  String? _periodId;
  bool _isDisposed = false;

  this {
    if (existingRecall != null) {
      recall = existingRecall;
      _studyDaySnapshot = recall.studyDaySnapshot;
      lastSaveTime = recall.lastAutoSavedAt;
    } else {
      recall = DailyRecall.withId(
        date: DateTime.now(),
        recallMode: RecallMode.realtimeRecord,
        entryStartedAt: DateTime.now(),
        meals: [],
      );
    }
    _initialize();
  }

  bool get isInTaskMode => task != null && completionPeriod != null;

  bool get meetsMinimumMeals {
    final minimum = task?.minimumMealsRequired;
    if (minimum == null) return true;
    final nonSkippedCount = recall.meals
        .where((MealLog meal) => !meal.isSkipped)
        .length;
    return nonSkippedCount >= minimum;
  }

  Future<void> _initialize() async {
    if (subject == null) return;

    _studyDaySnapshot ??= subject!.getDayOfStudyFor(DateTime.now());
    _interventionId ??= subject!.getInterventionForDate(DateTime.now())?.id;

    if (task != null && completionPeriod != null) {
      _periodId = completionPeriod!.id;
    }

    if (_studyDaySnapshot == null) return;

    if (recall.meals.isEmpty &&
        recall.specialOccasion == null &&
        recall.isUsualIntakeDay == null) {
      final existing = await _autoSaveManager.loadRecall(
        subjectId: subject!.id,
        taskId: task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
        studyDay: _studyDaySnapshot!,
      );

      if (existing != null && !_isDisposed) {
        recall = existing;
        lastSaveTime = existing.lastAutoSavedAt;
        notifyListeners();
      } else if (!_isDisposed) {
        recall = DailyRecall(
          id: recall.id,
          date: recall.date,
          recallMode: recall.recallMode,
          entryStartedAt: recall.entryStartedAt,
          meals: recall.meals,
          studyDaySnapshot: _studyDaySnapshot,
        );
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoSaveTimer?.cancel();
    if (recall.meals.isNotEmpty && subject != null) {
      _performAutoSaveSync();
    }
    super.dispose();
  }

  void onAppLifecycleStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _autoSaveTimer?.cancel();
      if (recall.meals.isNotEmpty && subject != null) {
        _performAutoSaveSync();
      }
    }
  }

  void updateUsualIntake(bool isUsual) {
    if (isUsual != recall.isUsualIntakeDay) {
      String? specialOccasion = recall.specialOccasion;
      if (isUsual) {
        specialOccasion = null;
      }
      recall = _copyWithRecall(
        isUsualIntakeDay: isUsual,
        specialOccasion: specialOccasion,
        clearSpecialOccasion: specialOccasion == null,
      );
      notifyListeners();
      _scheduleAutoSave('usual day toggled');
    }
  }

  void updateSpecialOccasion(String? occasion) {
    if (occasion != recall.specialOccasion) {
      recall = _copyWithRecall(
        specialOccasion: occasion,
        clearSpecialOccasion: occasion == null,
      );
      // Note: TextField controller text isn't reset here to prevent cursor jumps
      _scheduleAutoSave('special occasion changed');
    }
  }

  void addMeal(MealLog meal) {
    recall.meals.add(meal);
    notifyListeners();
    _scheduleAutoSave('meal added');
  }

  void updateMeal(int index, MealLog meal) {
    recall.meals[index] = meal;
    notifyListeners();
    _scheduleAutoSave('meal edited');
  }

  void removeMeal(int index) {
    recall.meals.removeAt(index);
    notifyListeners();
    _scheduleAutoSave('meal removed');
  }

  // Helper to copy recall with new fields
  DailyRecall _copyWithRecall({
    bool? isUsualIntakeDay,
    String? specialOccasion,
    bool clearSpecialOccasion = false,
    DateTime? entryCompletedAt,
    bool clearEntryCompletedAt = false,
    DateTime? lastAutoSavedAt,
  }) {
    return DailyRecall(
      id: recall.id,
      date: recall.date,
      isUsualIntakeDay: isUsualIntakeDay ?? recall.isUsualIntakeDay,
      specialOccasion: clearSpecialOccasion
          ? null
          : specialOccasion ?? recall.specialOccasion,
      recallMode: recall.recallMode,
      entryStartedAt: recall.entryStartedAt,
      entryCompletedAt: clearEntryCompletedAt
          ? null
          : entryCompletedAt ?? recall.entryCompletedAt,
      meals: recall.meals,
      studyDaySnapshot: _studyDaySnapshot ?? recall.studyDaySnapshot,
      lastAutoSavedAt: lastAutoSavedAt ?? recall.lastAutoSavedAt,
    );
  }

  DailyRecall markCompleted() {
    final completedAt = DateTime.now();
    recall = _copyWithRecall(entryCompletedAt: completedAt);
    notifyListeners();
    return recall;
  }

  /// Cancels a scheduled auto-save and waits for an already-running save.
  ///
  /// Completion must be persisted after any older auto-save so that an
  /// incomplete snapshot cannot overwrite the completed recall.
  Future<void> flushPendingAutoSave() async {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;

    final pendingSave = _autoSaveFuture;
    if (pendingSave == null) return;

    try {
      await pendingSave;
    } catch (error, stackTrace) {
      StudyULogger.warning(
        '[DailyRecallVM] Pending auto-save failed before completion: $error\n$stackTrace',
      );
    }
  }

  void _scheduleAutoSave([String reason = 'unspecified']) {
    if (subject == null || _studyDaySnapshot == null) return;

    StudyULogger.debug(
      '[DailyRecallVM] Schedule auto-save ($reason) | meals=${recall.meals.length} '
      'studyDay=$_studyDaySnapshot subject=${subject?.id}',
    );

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(NutritionRecallAutoSaveManager.debounceDuration, () {
      _autoSaveTimer = null;
      _autoSaveFuture = _performAutoSave();
    });
  }

  void _performAutoSaveSync() {
    if (subject == null || _studyDaySnapshot == null) return;

    StudyULogger.debug(
      '[DailyRecallVM] Sync auto-save (dispose/pause) | meals=${recall.meals.length} '
      'studyDay=$_studyDaySnapshot subject=${subject?.id}',
    );

    _autoSaveManager.saveRecallImmediate(
      recall: _copyWithRecall(lastAutoSavedAt: DateTime.now()),
      subjectId: subject!.id,
      taskId: task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
      interventionId:
          _interventionId ??
          NutritionRecallAutoSaveManager.unknownInterventionId,
      periodId: _periodId ?? NutritionRecallAutoSaveManager.defaultPeriodId,
      studyDaySnapshot: _studyDaySnapshot!,
    );
  }

  Future<void> _performAutoSave() async {
    if (isSaving || subject == null || _studyDaySnapshot == null) return;
    if (!isInTaskMode) {
      StudyULogger.debug('[DailyRecallVM] Skip auto-save (not in task mode)');
      return;
    }

    isSaving = true;
    notifyListeners();

    try {
      final now = DateTime.now();

      recall = _copyWithRecall(lastAutoSavedAt: now);

      StudyULogger.debug(
        '[DailyRecallVM] Auto-save firing | meals=${recall.meals.length} '
        'studyDay=$_studyDaySnapshot '
        'recallMode=${recall.recallMode} lastAutoSavedAt=${recall.lastAutoSavedAt}',
      );

      final recallToSave = recall;
      await _autoSaveManager.saveRecall(
        recall: recallToSave,
        subjectId: subject!.id,
        taskId: task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
        interventionId:
            _interventionId ??
            NutritionRecallAutoSaveManager.unknownInterventionId,
        periodId: _periodId ?? NutritionRecallAutoSaveManager.defaultPeriodId,
        studyDaySnapshot: _studyDaySnapshot!,
      );

      lastSaveTime = now;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  bool shouldSaveToDb = true;
}
