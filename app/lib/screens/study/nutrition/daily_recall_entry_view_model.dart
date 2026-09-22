import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

typedef NutritionRecallRemoteSaver = Future<void> Function({
  required String taskId,
  required String periodId,
  required DailyRecall recall,
  required NutritionRecallPersistenceTarget? persistenceTarget,
  String? interventionIdOverride,
});

class DailyRecallEntryViewModel({
  final StudySubject? subject,
  final NutritionTask? task,
  final CompletionPeriod? completionPeriod,
  var NutritionRecallPersistenceTarget? _persistenceTarget,
  final String? interventionId,
  final bool readOnly = false,
  final bool historicalMode = false,
  DailyRecall? existingRecall,
  NutritionRecallAutoSaveManager? autoSaveManager,
  final NutritionRecallRemoteSaver? _remoteSaver,
}) extends ChangeNotifier {
  final NutritionRecallAutoSaveManager _autoSaveManager =
      autoSaveManager ?? NutritionRecallAutoSaveManager();
  late DailyRecall recall;
  bool isSaving = false;
  DateTime? lastSaveTime;

  Timer? _autoSaveTimer;
  Future<void> _localSaveFuture = Future.value();
  Future<void> _remoteSaveQueue = Future.value();
  int? _studyDaySnapshot;
  String? _interventionId;
  String? _periodId;
  bool _isDisposed = false;
  bool _persistenceSuspended = false;
  bool _hasExistingRecall = false;
  bool _historicalEligibilityExpired = false;
  bool _hasCompletedRecall = false;
  int _recallRevision = 0;

  this {
    _hasExistingRecall = existingRecall != null;
    if (existingRecall != null) {
      recall = existingRecall;
      _studyDaySnapshot =
          _persistenceTarget?.studyDaySnapshot ?? recall.studyDaySnapshot;
      _interventionId = _persistenceTarget?.interventionId ?? interventionId;
      _periodId = _persistenceTarget?.periodId;
      lastSaveTime = recall.lastAutoSavedAt;
    } else {
      final now = DateTime.now();
      recall = DailyRecall.withId(
        date: now,
        recallMode: RecallMode.realtimeRecord,
        entryStartedAt: now,
        meals: [],
      );
    }
    _initialize();
  }

  NutritionRecallPersistenceTarget? get persistenceTarget => _persistenceTarget;

  int? get studyDaySnapshot => _studyDaySnapshot;

  bool get historicalEligibilityExpired => _historicalEligibilityExpired;

  bool get isInTaskMode => task != null && completionPeriod != null;

  bool get meetsMinimumMeals {
    final minimum = task?.minimumMealsRequired;
    if (minimum == null) return true;
    return recall.meals.where((meal) => !meal.isSkipped).length >= minimum;
  }

  Future<void> _initialize() async {
    if (subject == null) return;
    if (!revalidateHistoricalEligibility()) return;

    _studyDaySnapshot ??= subject!.getDayOfStudyFor(
      _hasExistingRecall ? recall.date : DateTime.now(),
    );
    _interventionId ??=
        interventionId ??
        subject!
            .getInterventionForDate(
              _hasExistingRecall ? recall.date : DateTime.now(),
            )
            ?.id;
    _periodId ??= completionPeriod?.id;

    final didHydrateRemoteRecall = _hydrateCurrentRemoteRecall();
    _ensureStudyDaySnapshot();
    if (readOnly || _studyDaySnapshot == null || _periodId == null) {
      if (didHydrateRemoteRecall && !_isDisposed) notifyListeners();
      return;
    }

    final recallRevision = _recallRevision;
    final local = await _autoSaveManager.loadPendingRecall(
      subjectId: subject!.id,
      taskId: task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
      periodId: _periodId!,
      studyDay: _studyDaySnapshot!,
    );
    if (_isDisposed) return;
    if (local == null || _recallRevision != recallRevision) {
      if (didHydrateRemoteRecall) notifyListeners();
      return;
    }

    final remoteSavedAt =
        recall.lastAutoSavedAt ?? _persistenceTarget?.completedAt;
    final shouldRestore =
        !_hasExistingRecall ||
        remoteSavedAt == null ||
        local.lastModifiedAtDate.isAfter(remoteSavedAt);
    if (shouldRestore) {
      recall = _copyRecall(local.recall);
      lastSaveTime = local.recall.lastAutoSavedAt;
      notifyListeners();
    } else {
      _ensureStudyDaySnapshot();
      if (didHydrateRemoteRecall) notifyListeners();
    }
  }

  bool _hydrateCurrentRemoteRecall({bool force = false}) {
    final taskId = task?.id;
    final periodId = _periodId;
    final studyDay = _studyDaySnapshot;
    if ((!force && _hasExistingRecall) ||
        taskId == null ||
        periodId == null ||
        studyDay == null) {
      return false;
    }

    SubjectProgress? latestProgress;
    DailyRecall? latestRecall;
    DateTime? latestSavedAt;
    for (final progress in subject!.progress) {
      if (progress.taskId != taskId ||
          progress.resultType != 'DailyRecall' ||
          progress.result.periodId != periodId) {
        continue;
      }
      final candidate = progress.result.result;
      if (candidate is! DailyRecall) continue;
      final candidateStudyDay =
          candidate.studyDaySnapshot ??
          (progress.completedAt == null
              ? null
              : subject!.getDayOfStudyFor(progress.completedAt!.toLocal()));
      if (candidateStudyDay != studyDay) continue;

      final candidateSavedAt =
          candidate.lastAutoSavedAt ?? progress.completedAt;
      if (latestProgress == null ||
          (candidateSavedAt != null &&
              (latestSavedAt == null ||
                  candidateSavedAt.isAfter(latestSavedAt)))) {
        latestProgress = progress;
        latestRecall = candidate;
        latestSavedAt = candidateSavedAt;
      }
    }
    if (latestProgress == null || latestRecall == null) return false;

    recall = _copyRecall(latestRecall);
    _hasExistingRecall = true;
    _interventionId = latestProgress.interventionId;
    if (latestProgress.completedAt != null) {
      _persistenceTarget = NutritionRecallPersistenceTarget(
        taskId: taskId,
        periodId: periodId,
        interventionId: latestProgress.interventionId,
        completedAt: latestProgress.completedAt!,
        studyDaySnapshot: studyDay,
      );
    }
    lastSaveTime = recall.lastAutoSavedAt;
    return true;
  }

  Future<void> reloadCanonicalRecall() async {
    if (subject == null || _periodId == null || _studyDaySnapshot == null) {
      return;
    }
    var changed = _hydrateCurrentRemoteRecall(force: true);
    final local = await _autoSaveManager.loadPendingRecall(
      subjectId: subject!.id,
      taskId: task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
      periodId: _periodId!,
      studyDay: _studyDaySnapshot!,
    );
    if (_isDisposed) return;
    if (local != null) {
      recall = _copyRecall(local.recall);
      lastSaveTime = recall.lastAutoSavedAt;
      changed = true;
    }
    if (changed) {
      _recallRevision++;
      notifyListeners();
    }
  }

  void _ensureStudyDaySnapshot() {
    if (recall.studyDaySnapshot == _studyDaySnapshot) return;
    recall = _copyWithRecall();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoSaveTimer?.cancel();
    if (!_hasCompletedRecall &&
        !readOnly &&
        !_persistenceSuspended &&
        _hasRecallContent &&
        subject != null) {
      _performAutoSaveSync();
    }
    super.dispose();
  }

  void suspendPersistence() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    _persistenceSuspended = true;
  }

  void resumePersistence() {
    _persistenceSuspended = false;
    revalidateHistoricalEligibility();
  }

  void onAppLifecycleStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      revalidateHistoricalEligibility();
    } else if (!readOnly &&
        !_persistenceSuspended &&
        state == AppLifecycleState.paused &&
        _hasRecallContent &&
        !_hasCompletedRecall) {
      _autoSaveTimer?.cancel();
      _performAutoSaveSync();
    }
  }

  void updateUsualIntake(bool isUsual) {
    if (readOnly || isUsual == recall.isUsualIntakeDay) return;
    final specialOccasion = isUsual ? null : recall.specialOccasion;
    recall = _copyWithRecall(
      isUsualIntakeDay: isUsual,
      specialOccasion: specialOccasion,
      clearSpecialOccasion: specialOccasion == null,
    );
    _recallRevision++;
    notifyListeners();
    _scheduleAutoSave('usual day toggled');
  }

  void updateSpecialOccasion(String? occasion) {
    if (readOnly || occasion == recall.specialOccasion) return;
    recall = _copyWithRecall(
      specialOccasion: occasion,
      clearSpecialOccasion: occasion == null,
    );
    _recallRevision++;
    notifyListeners();
    _scheduleAutoSave('special occasion changed');
  }

  void addMeal(MealLog meal) {
    if (readOnly || !revalidateHistoricalEligibility()) return;
    recall.meals.add(meal);
    _recallRevision++;
    notifyListeners();
    _scheduleAutoSave('meal added');
  }

  void updateMeal(int index, MealLog meal) {
    if (readOnly || !revalidateHistoricalEligibility()) return;
    recall.meals[index] = meal;
    _recallRevision++;
    notifyListeners();
    _scheduleAutoSave('meal edited');
  }

  void updateMealById(String mealId, MealLog meal) {
    final index = recall.meals.indexWhere((entry) => entry.id == mealId);
    if (index >= 0) updateMeal(index, meal);
  }

  void removeMeal(int index) {
    if (readOnly || !revalidateHistoricalEligibility()) return;
    recall.meals.removeAt(index);
    _recallRevision++;
    notifyListeners();
    _scheduleAutoSave('meal removed');
  }

  void removeMealById(String mealId) {
    final index = recall.meals.indexWhere((entry) => entry.id == mealId);
    if (index >= 0) removeMeal(index);
  }

  DailyRecall _copyRecall(DailyRecall source) {
    final copy = DailyRecall.fromJson(source.toJson());
    if (copy.studyDaySnapshot == _studyDaySnapshot) return copy;
    return DailyRecall(
      id: copy.id,
      date: copy.date,
      isUsualIntakeDay: copy.isUsualIntakeDay,
      specialOccasion: copy.specialOccasion,
      recallMode: copy.recallMode,
      entryStartedAt: copy.entryStartedAt,
      entryCompletedAt: copy.entryCompletedAt,
      meals: copy.meals,
      studyDaySnapshot: _studyDaySnapshot,
      lastAutoSavedAt: copy.lastAutoSavedAt,
    );
  }

  DailyRecall _copyWithRecall({
    bool? isUsualIntakeDay,
    String? specialOccasion,
    bool clearSpecialOccasion = false,
    DateTime? entryCompletedAt,
    bool clearEntryCompletedAt = false,
    DateTime? lastAutoSavedAt,
  }) => DailyRecall(
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

  /// Retained for existing callers; late corrections never call this path.
  DailyRecall markCompleted() {
    if (readOnly) return recall;
    _hasCompletedRecall = true;
    recall = _copyWithRecall(entryCompletedAt: DateTime.now());
    _recallRevision++;
    notifyListeners();
    return recall;
  }

  Future<void> clearAutoSave() async {
    if (subject == null || _studyDaySnapshot == null) return;

    await _autoSaveManager.deleteRecall(
      subjectId: subject!.id,
      taskId: task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
      studyDay: _studyDaySnapshot!,
    );
  }

  Future<void> flushPendingAutoSave({
    bool persistToDatabase = false,
    bool requireRemoteSuccess = false,
  }) async {
    if (readOnly || !revalidateHistoricalEligibility()) return;
    final hadScheduledSave = _autoSaveTimer != null;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    await _localSaveFuture;
    if (persistToDatabase && (hadScheduledSave || requireRemoteSuccess)) {
      await _performAutoSave(propagateErrors: requireRemoteSuccess);
    } else {
      await _remoteSaveQueue;
    }
  }

  void _scheduleAutoSave([String reason = 'unspecified']) {
    if (readOnly ||
        _persistenceSuspended ||
        subject == null ||
        _studyDaySnapshot == null) {
      return;
    }
    StudyULogger.debug(
      '[DailyRecallVM] Schedule auto-save ($reason) | '
      'studyDay=$_studyDaySnapshot subject=${subject?.id}',
    );
    _persistLocalSnapshot();
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(NutritionRecallAutoSaveManager.debounceDuration, () {
      _autoSaveTimer = null;
      unawaited(_performAutoSaveAfterLocalSave());
    });
  }

  bool get _hasRecallContent =>
      recall.meals.isNotEmpty ||
      recall.specialOccasion != null ||
      recall.isUsualIntakeDay != null;

  void _performAutoSaveSync() {
    if (readOnly ||
        _persistenceSuspended ||
        subject == null ||
        _studyDaySnapshot == null) {
      return;
    }
    _persistLocalSnapshot();
  }

  void _persistLocalSnapshot() {
    if (readOnly ||
        _persistenceSuspended ||
        subject == null ||
        _studyDaySnapshot == null ||
        !revalidateHistoricalEligibility()) {
      return;
    }
    final savedAt = DateTime.now();
    recall = _copyWithRecall(lastAutoSavedAt: savedAt);
    lastSaveTime = savedAt;
    final recallToSave = DailyRecall.fromJson(recall.toJson());
    final localSave = _localSaveFuture.then<void>(
      (_) => _autoSaveManager.saveRecall(
        recall: recallToSave,
        subjectId: subject!.id,
        taskId:
            persistenceTarget?.taskId ??
            task?.id ??
            NutritionRecallAutoSaveManager.standaloneTaskId,
        interventionId:
            _interventionId ??
            NutritionRecallAutoSaveManager.unknownInterventionId,
        periodId: _periodId ?? NutritionRecallAutoSaveManager.defaultPeriodId,
        studyDaySnapshot: _studyDaySnapshot!,
        progressCompletedAt: persistenceTarget?.completedAt,
      ),
      onError: (_, _) => _autoSaveManager.saveRecall(
        recall: recallToSave,
        subjectId: subject!.id,
        taskId:
            persistenceTarget?.taskId ??
            task?.id ??
            NutritionRecallAutoSaveManager.standaloneTaskId,
        interventionId:
            _interventionId ??
            NutritionRecallAutoSaveManager.unknownInterventionId,
        periodId: _periodId ?? NutritionRecallAutoSaveManager.defaultPeriodId,
        studyDaySnapshot: _studyDaySnapshot!,
        progressCompletedAt: persistenceTarget?.completedAt,
      ),
    );
    _localSaveFuture = localSave;
    localSave.catchError((Object error, StackTrace stackTrace) {
      StudyULogger.error(
        '[DailyRecallVM] Local auto-save failed: $error\n$stackTrace',
      );
    });
  }

  Future<void> _performAutoSaveAfterLocalSave() async {
    await _localSaveFuture;
    await _performAutoSave();
  }

  Future<void> _performAutoSave({bool propagateErrors = false}) {
    if (readOnly ||
        _persistenceSuspended ||
        !revalidateHistoricalEligibility() ||
        subject == null ||
        _studyDaySnapshot == null ||
        !isInTaskMode) {
      return Future.value();
    }
    final recallToSave = DailyRecall.fromJson(recall.toJson());
    final now = recallToSave.lastAutoSavedAt ?? DateTime.now();
    final remoteSave = _remoteSaveQueue.then((_) async {
      isSaving = true;
      notifyListeners();
      try {
        if (shouldSaveToDb) {
          final taskId = persistenceTarget?.taskId ?? task!.id;
          final periodId =
              persistenceTarget?.periodId ?? _periodId ?? completionPeriod!.id;
          final remoteSaver = _remoteSaver;
          if (remoteSaver != null) {
            await remoteSaver(
              taskId: taskId,
              periodId: periodId,
              recall: recallToSave,
              persistenceTarget: persistenceTarget,
              interventionIdOverride: _interventionId,
            );
          } else {
            await subject!.upsertNutritionResult(
              taskId: taskId,
              periodId: periodId,
              recall: recallToSave,
              persistenceTarget: persistenceTarget,
              interventionIdOverride: _interventionId,
            );
          }
        }
        lastSaveTime = now;
      } catch (error, stackTrace) {
        StudyULogger.warning(
          '[DailyRecallVM] Remote auto-save failed; local recall is retained: '
          '$error\n$stackTrace',
        );
        if (propagateErrors) rethrow;
      } finally {
        isSaving = false;
        notifyListeners();
      }
    });
    _remoteSaveQueue = remoteSave.then<void>((_) {}, onError: (_, _) {});
    return remoteSave;
  }

  bool revalidateHistoricalEligibility() {
    final target = _persistenceTarget;
    if (readOnly || !historicalMode || target == null) return true;
    final activeSubject = subject;
    final valid =
        activeSubject != null &&
        target.studyDaySnapshot ==
            nutritionStudyDayFor(activeSubject, DateTime.now()) - 1;
    if (!valid && !_historicalEligibilityExpired) {
      _historicalEligibilityExpired = true;
      if (!_isDisposed) notifyListeners();
    }
    return valid;
  }

  bool shouldSaveToDb = true;
}
