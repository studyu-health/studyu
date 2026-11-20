import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef NutritionRecallRemoteSaver = Future<void> Function({
  required String taskId,
  required String periodId,
  required DailyRecall recall,
  required NutritionRecallPersistenceTarget? persistenceTarget,
  String? interventionIdOverride,
});

typedef NutritionRecallRemoteLoader = Future<SubjectProgress?> Function(
  NutritionRecallPersistenceTarget? target,
);

class DailyRecallEntryViewModel({
  final StudySubject? subject,
  var NutritionTask? task,
  final CompletionPeriod? completionPeriod,
  var NutritionRecallPersistenceTarget? _persistenceTarget,
  final String? interventionId,
  final bool readOnly = false,
  final bool historicalMode = false,
  final DateTime Function() clock = DateTime.now,
  DailyRecall? existingRecall,
  NutritionRecallAutoSaveManager? autoSaveManager,
  final NutritionRecallRemoteSaver? _remoteSaver,
  final NutritionRecallRemoteLoader? _remoteLoader,
}) extends ChangeNotifier {
  final NutritionRecallAutoSaveManager _autoSaveManager =
      autoSaveManager ?? NutritionRecallAutoSaveManager();
  late DailyRecall recall;
  late final Future<void> _initialization;
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
  bool _currentDayExpired = false;
  SubjectProgress? _canonicalProgress;
  PendingRecall? _conflictingDraft;
  bool _isCheckingDraft = false;
  bool _remoteConflict = false;
  bool _isReloadingDraft = false;
  bool _requiresReopen = false;
  bool _showConflictingDraft = false;

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
      final now = clock();
      recall = DailyRecall.withId(
        date: now,
        recallMode: RecallMode.realtimeRecord,
        entryStartedAt: now.toUtc(),
        meals: [],
      );
    }
    _initialization = _initialize();
  }

  NutritionRecallPersistenceTarget? get persistenceTarget => _persistenceTarget;

  int? get studyDaySnapshot => _studyDaySnapshot;

  bool get historicalEligibilityExpired => _historicalEligibilityExpired;

  bool get currentDayExpired => _currentDayExpired;

  Future<void> get initialized => _initialization;

  bool get isCheckingDraft => _isCheckingDraft || _isReloadingDraft;

  bool get hasDraftConflict => _conflictingDraft != null || _remoteConflict;

  bool get canDiscardConflictingDraft =>
      _conflictingDraft != null && !isCheckingDraft;

  bool get canRefreshConflictingRecall => _remoteConflict && !isCheckingDraft;

  bool get canCompareConflictingDraft =>
      _conflictingDraft != null && _canonicalProgress != null;

  bool get showsConflictingDraft => _showConflictingDraft;

  DailyRecall get displayedRecall =>
      _showConflictingDraft ? _conflictingDraft?.recall ?? recall : recall;

  void toggleConflictPreview() {
    if (!canCompareConflictingDraft) return;
    _showConflictingDraft = !_showConflictingDraft;
    notifyListeners();
  }

  bool get requiresReopen => _requiresReopen;

  bool get canEdit =>
      !readOnly && !isCheckingDraft && !hasDraftConflict && !requiresReopen;

  bool revalidateEditingEligibility() => revalidateEligibility() && canEdit;

  bool get _canPersist =>
      !readOnly && !_isCheckingDraft && !hasDraftConflict && !requiresReopen;

  bool get isInTaskMode => task != null && completionPeriod != null;

  bool get meetsMinimumMeals {
    final minimum = task?.minimumMealsRequired;
    if (minimum == null) return true;
    return recall.meals.where((meal) => !meal.isSkipped).length >= minimum;
  }

  Future<void> _initialize() async {
    if (subject == null) return;
    if (!revalidateEligibility()) return;

    _studyDaySnapshot ??= nutritionStudyDayFor(
      subject!,
      _hasExistingRecall ? recall.date : clock(),
    );
    _interventionId ??=
        interventionId ??
        subject!.getNutritionInterventionForStudyDay(_studyDaySnapshot!)?.id;
    _periodId ??= completionPeriod?.id;

    final didHydrateRemoteRecall = !readOnly && _hydrateCurrentRemoteRecall();
    _ensureStudyDaySnapshot();
    if (readOnly || _studyDaySnapshot == null || _periodId == null) {
      if (didHydrateRemoteRecall && !_isDisposed) notifyListeners();
      return;
    }

    _isCheckingDraft = true;
    try {
      final local = await _loadPendingDraft();
      if (!_isDisposed && revalidateEligibility()) _applyPendingDraft(local);
    } catch (error, stackTrace) {
      _requiresReopen = true;
      StudyULogger.warning(
        'Failed to check the local nutrition draft: $error\n$stackTrace',
      );
    } finally {
      _isCheckingDraft = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<PendingRecall?> _loadPendingDraft() =>
      _autoSaveManager.loadPendingRecall(
        subjectId: subject!.id,
        taskId: task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
        periodId: _periodId!,
        studyDay: _studyDaySnapshot!,
      );

  void _applyPendingDraft(PendingRecall? local) {
    if (local == null) {
      _conflictingDraft = null;
      return;
    }
    final canonical = _canonicalProgress;
    if (canonical != null &&
        !local.canReplace(canonical) &&
        !_hasSamePayload(local, canonical)) {
      _conflictingDraft = local;
      return;
    }
    _conflictingDraft = null;
    if (_canRestore(local)) {
      recall = _copyRecall(local.recall);
      lastSaveTime = local.recall.lastAutoSavedAt;
    }
  }

  bool _hasSamePayload(PendingRecall local, SubjectProgress canonical) =>
      const DeepCollectionEquality().equals(
        local.recall.toJsonForStorage(),
        (canonical.result.result as DailyRecall).toJsonForStorage(),
      );

  Future<bool> discardConflictingDraft() async {
    final pending = _conflictingDraft;
    if (pending == null ||
        _isCheckingDraft ||
        _isReloadingDraft ||
        !revalidateEligibility()) {
      return false;
    }
    _isCheckingDraft = true;
    notifyListeners();
    try {
      final deleted = await _autoSaveManager.deletePendingRecall(pending);
      if (_isDisposed) return deleted;
      if (!deleted) {
        final local = await _loadPendingDraft();
        if (!_isDisposed) _conflictingDraft = local ?? pending;
        return false;
      }
      _conflictingDraft = null;
      _showConflictingDraft = false;
      _requiresReopen = _requiresReopen || _remoteConflict;
      _remoteConflict = false;
      return true;
    } finally {
      _isCheckingDraft = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  bool _hydrateCurrentRemoteRecall() {
    final taskId = task?.id;
    final periodId = _periodId;
    final studyDay = _studyDaySnapshot;
    if (taskId == null || periodId == null || studyDay == null) {
      return false;
    }

    SubjectProgress? latestProgress;
    DailyRecall? latestRecall;
    DateTime? latestSavedAt;
    var exactPeriod = false;
    var legacyMatches = 0;
    for (final progress in subject!.progress) {
      if (progress.taskId != taskId ||
          progress.resultType != 'DailyRecall' ||
          (progress.result.periodId != null &&
              progress.result.periodId != periodId)) {
        continue;
      }
      final candidate = progress.result.result;
      if (candidate is! DailyRecall) continue;
      final candidateStudyDay =
          candidate.studyDaySnapshot ??
          (progress.completedAt == null
              ? null
              : nutritionStudyDayFor(subject!, progress.completedAt!));
      if (candidateStudyDay != studyDay) continue;

      final candidateMatchesPeriod = progress.result.periodId == periodId;
      if (exactPeriod && !candidateMatchesPeriod) continue;
      if (!candidateMatchesPeriod) legacyMatches++;
      final candidateSavedAt =
          candidate.lastAutoSavedAt ?? progress.completedAt;
      if (latestProgress == null ||
          (candidateMatchesPeriod && !exactPeriod) ||
          (candidateSavedAt != null &&
              (latestSavedAt == null ||
                  candidateSavedAt.isAfter(latestSavedAt)))) {
        exactPeriod = candidateMatchesPeriod;
        latestProgress = progress;
        latestRecall = candidate;
        latestSavedAt = candidateSavedAt;
      }
    }
    if (latestProgress == null || latestRecall == null) return false;

    if (!exactPeriod && legacyMatches != 1) {
      _requiresReopen = true;
      return false;
    }

    _adoptCanonicalRecall(latestProgress, latestRecall, periodId, studyDay);
    return true;
  }

  void _adoptCanonicalRecall(
    SubjectProgress progress,
    DailyRecall canonical,
    String periodId,
    int studyDay,
  ) {
    _canonicalProgress = progress;
    recall = _copyRecall(canonical);
    _hasExistingRecall = true;
    _interventionId = progress.interventionId;
    if (progress.completedAt case final completedAt?) {
      _persistenceTarget = NutritionRecallPersistenceTarget(
        taskId: progress.taskId,
        periodId: periodId,
        interventionId: progress.interventionId,
        completedAt: completedAt,
        studyDaySnapshot: studyDay,
        nutritionRevision: progress.nutritionRevision,
      );
    }
    lastSaveTime = recall.lastAutoSavedAt;
  }

  Future<void> refreshConflictingRecall() async {
    final activeSubject = subject;
    final taskId = task?.id;
    final periodId = _periodId;
    final studyDay = _studyDaySnapshot;
    if (!canRefreshConflictingRecall ||
        activeSubject == null ||
        taskId == null ||
        periodId == null ||
        studyDay == null) {
      return;
    }

    _isReloadingDraft = true;
    notifyListeners();
    try {
      final load = _remoteLoader;
      final progress = load == null
          ? await activeSubject.fetchNutritionRecall(
              taskId: taskId,
              periodId: periodId,
              studyDaySnapshot: studyDay,
              target: persistenceTarget,
            )
          : await load(persistenceTarget);
      final canonical = progress?.result.result;
      if (_isDisposed || canonical is! DailyRecall || progress == null) return;

      activeSubject.applySavedProgress(progress);
      _adoptCanonicalRecall(progress, canonical, periodId, studyDay);
      _remoteConflict = false;
      _showConflictingDraft = false;
    } catch (error, stackTrace) {
      StudyULogger.warning(
        'Failed to refresh the conflicting nutrition recall: $error\n$stackTrace',
      );
    } finally {
      _isReloadingDraft = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> reloadCanonicalRecall() async {
    if (subject == null ||
        _periodId == null ||
        _studyDaySnapshot == null ||
        _isCheckingDraft ||
        _isReloadingDraft ||
        _isDisposed ||
        _remoteConflict ||
        _requiresReopen) {
      return;
    }
    _isReloadingDraft = true;
    notifyListeners();
    try {
      await _localSaveFuture;
      await _remoteSaveQueue;
      if (_isDisposed || _remoteConflict || _requiresReopen) return;
      if (!readOnly) _hydrateCurrentRemoteRecall();
      if (readOnly) return;
      final local = await _loadPendingDraft();
      if (!_isDisposed && revalidateEligibility()) _applyPendingDraft(local);
    } catch (error, stackTrace) {
      _requiresReopen = true;
      StudyULogger.warning(
        'Failed to reload the nutrition diary: $error\n$stackTrace',
      );
    } finally {
      _isReloadingDraft = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  bool _canRestore(PendingRecall local) {
    final canonical = _canonicalProgress;
    if (canonical != null) return local.canReplace(canonical);
    final savedAt = recall.lastAutoSavedAt ?? _persistenceTarget?.completedAt;
    final localTime = local.recall.lastAutoSavedAt ?? local.lastModifiedAtDate;
    return !_hasExistingRecall || savedAt == null || localTime.isAfter(savedAt);
  }

  void _ensureStudyDaySnapshot() {
    if (recall.studyDaySnapshot == _studyDaySnapshot) return;
    recall = _copyWithRecall();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void suspendPersistence() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    _persistenceSuspended = true;
  }

  void resumePersistence() {
    _persistenceSuspended = false;
    revalidateEligibility();
  }

  void onAppLifecycleStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) revalidateEligibility();
  }

  void updateUsualIntake(bool isUsual) {
    if (readOnly ||
        !revalidateEditingEligibility() ||
        isUsual == recall.isUsualIntakeDay) {
      return;
    }
    final specialOccasion = isUsual ? null : recall.specialOccasion;
    recall = _copyWithRecall(
      isUsualIntakeDay: isUsual,
      specialOccasion: specialOccasion,
      clearSpecialOccasion: specialOccasion == null,
    );
    notifyListeners();
    _scheduleAutoSave('usual day toggled');
  }

  void updateSpecialOccasion(String? occasion) {
    if (readOnly ||
        !revalidateEditingEligibility() ||
        occasion == recall.specialOccasion) {
      return;
    }
    recall = _copyWithRecall(
      specialOccasion: occasion,
      clearSpecialOccasion: occasion == null,
    );
    notifyListeners();
    _scheduleAutoSave('special occasion changed');
  }

  void addMeal(MealLog meal) {
    if (readOnly || !revalidateEditingEligibility()) return;
    recall.meals.add(meal);
    notifyListeners();
    _scheduleAutoSave('meal added');
  }

  void updateMeal(int index, MealLog meal) {
    if (readOnly || !revalidateEditingEligibility()) return;
    recall.meals[index] = meal;
    notifyListeners();
    _scheduleAutoSave('meal edited');
  }

  void updateMealById(String mealId, MealLog meal) {
    final index = recall.meals.indexWhere((entry) => entry.id == mealId);
    if (index >= 0) updateMeal(index, meal);
  }

  void removeMeal(int index) {
    if (readOnly || !revalidateEditingEligibility()) return;
    recall.meals.removeAt(index);
    notifyListeners();
    _scheduleAutoSave('meal removed');
  }

  void removeMealById(String mealId) {
    final index = recall.meals.indexWhere((entry) => entry.id == mealId);
    if (index >= 0) removeMeal(index);
  }

  Future<void> adjustWaterIntake(int deltaMl) async {
    await _initialization;
    if (_isDisposed ||
        readOnly ||
        task?.trackWaterIntake == false ||
        !revalidateEditingEligibility()) {
      return;
    }
    final currentMl = recall.waterIntakeMl ?? 0;
    final updatedMl = max(0, currentMl + deltaMl);
    if (updatedMl == currentMl) return;
    recall = _copyWithRecall(waterIntakeMl: updatedMl);
    notifyListeners();
    _scheduleAutoSave('water intake changed');
  }

  DailyRecall _copyRecall(DailyRecall source) {
    final copy = DailyRecall.fromJson(source.toJson());
    return copy..studyDaySnapshot = _studyDaySnapshot;
  }

  DailyRecall _copyWithRecall({
    bool? isUsualIntakeDay,
    String? specialOccasion,
    bool clearSpecialOccasion = false,
    DateTime? lastAutoSavedAt,
    int? waterIntakeMl,
  }) => DailyRecall(
    id: recall.id,
    date: recall.date,
    isUsualIntakeDay: isUsualIntakeDay ?? recall.isUsualIntakeDay,
    specialOccasion: clearSpecialOccasion
        ? null
        : specialOccasion ?? recall.specialOccasion,
    recallMode: recall.recallMode,
    entryStartedAt: recall.entryStartedAt,
    entryCompletedAt: recall.entryCompletedAt,
    meals: recall.meals,
    waterIntakeMl: waterIntakeMl ?? recall.waterIntakeMl,
    studyDaySnapshot: _studyDaySnapshot ?? recall.studyDaySnapshot,
    lastAutoSavedAt: lastAutoSavedAt ?? recall.lastAutoSavedAt,
    availabilityVerified: recall.availabilityVerified,
  );

  Future<void> clearAutoSave() async {
    if (!canEdit || subject == null || _studyDaySnapshot == null) return;

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
    if (!_canPersist || !revalidateEligibility()) return;
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

  void _persistLocalSnapshot() {
    if (readOnly ||
        _persistenceSuspended ||
        subject == null ||
        _studyDaySnapshot == null ||
        !revalidateEditingEligibility()) {
      return;
    }
    final savedAt = clock().toUtc();
    recall = _copyWithRecall(lastAutoSavedAt: savedAt);
    lastSaveTime = savedAt;
    final recallToSave = DailyRecall.fromJson(recall.toJson());
    Future<void> saveLocal() => _autoSaveManager.saveRecall(
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
      nutritionRevision: persistenceTarget?.nutritionRevision,
    );
    final localSave = _localSaveFuture.then<void>(
      (_) => saveLocal(),
      onError: (_, _) => saveLocal(),
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
    if (!_canPersist ||
        _persistenceSuspended ||
        !revalidateEligibility() ||
        subject == null ||
        _studyDaySnapshot == null ||
        !isInTaskMode) {
      return Future.value();
    }
    final recallToSave = DailyRecall.fromJson(recall.toJson());
    if (recallToSave.entryCompletedAt == null) {
      if (propagateErrors && shouldSaveToDb) {
        return Future.error(
          StateError('Complete the nutrition recall before saving it.'),
        );
      }
      return _remoteSaveQueue;
    }
    final now = recallToSave.lastAutoSavedAt ?? clock();
    final remoteSave = _remoteSaveQueue.then((_) async {
      if (_isDisposed || !_canPersist || !revalidateEligibility()) return;
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
            final previousRevision = persistenceTarget?.nutritionRevision;
            final saved = await subject!.upsertNutritionResult(
              taskId: taskId,
              periodId: periodId,
              recall: recallToSave,
              persistenceTarget: persistenceTarget,
              interventionIdOverride: _interventionId,
              createOnly: persistenceTarget == null,
            );
            _canonicalProgress = saved;
            _persistenceTarget = NutritionRecallPersistenceTarget(
              taskId: taskId,
              periodId: periodId,
              interventionId: saved.interventionId,
              completedAt: saved.completedAt!,
              studyDaySnapshot: _studyDaySnapshot!,
              nutritionRevision: saved.nutritionRevision,
            );
            await _autoSaveManager.acknowledgeRecallSave(
              saved: saved,
              uploaded: recallToSave,
              previousRevision: previousRevision,
            );
          }
        }
        lastSaveTime = now;
      } catch (error, stackTrace) {
        if (error is PostgrestException &&
            error.code == '40001' &&
            !_isDisposed) {
          _remoteConflict = true;
          _autoSaveTimer?.cancel();
          _autoSaveTimer = null;
          try {
            await _localSaveFuture;
            _conflictingDraft = await _loadPendingDraft();
          } catch (error, stackTrace) {
            StudyULogger.warning(
              'Failed to load the conflicting nutrition draft: $error\n$stackTrace',
            );
          }
          if (!_isDisposed) await refreshConflictingRecall();
        }
        StudyULogger.warning(
          '[DailyRecallVM] Remote auto-save failed; local recall is retained: '
          '$error\n$stackTrace',
        );
        if (propagateErrors) rethrow;
      } finally {
        isSaving = false;
        if (!_isDisposed) notifyListeners();
      }
    });
    _remoteSaveQueue = remoteSave.then<void>((_) {}, onError: (_, _) {});
    return remoteSave;
  }

  bool revalidateEligibility() {
    final target = _persistenceTarget;
    if (readOnly || !isInTaskMode) return true;
    final activeSubject = subject;
    if (activeSubject == null || activeSubject.startedAt == null) return true;
    final today = nutritionStudyDayFor(activeSubject, clock());
    if (historicalMode) {
      if (target == null) return true;
      if (_historicalEligibilityExpired) return false;
      if (target.studyDaySnapshot == today - 1) return true;
      _historicalEligibilityExpired = true;
    } else {
      if (_currentDayExpired) return false;
      if (_studyDaySnapshot == null || _studyDaySnapshot == today) return true;
      _currentDayExpired = true;
    }
    if (!_isDisposed) notifyListeners();
    return false;
  }

  bool shouldSaveToDb = true;
}
