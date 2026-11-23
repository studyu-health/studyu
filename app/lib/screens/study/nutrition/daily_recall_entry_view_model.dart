import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
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
  late final StreamSubscription<SubjectProgress>? _creationSubscription;
  SubjectProgress? _acknowledgedCreation;
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
    _creationSubscription =
        historicalMode && !readOnly && _persistenceTarget == null
        ? NutritionRecallAutoSaveManager.acknowledgedCreations.listen(
            _acceptAcknowledgedCreation,
          )
        : null;
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
    if (subject?.startedAt == null) return;
    if (!revalidateEligibility()) return;

    if (_studyDaySnapshot == null && !_hasExistingRecall) {
      _studyDaySnapshot = nutritionStudyDayFor(subject!, clock());
      recall.date = subject!.nutritionDateForStudyDay(_studyDaySnapshot!);
    }
    if (_studyDaySnapshot == null) {
      _requiresReopen = true;
      return;
    }
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
      await _restorePendingDraft();
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
        taskId: task!.id,
        periodId: _periodId!,
        studyDay: _studyDaySnapshot!,
      );

  Future<PendingRecall?> _recoverPendingDraft(PendingRecall? local) async {
    final canonical = _canonicalProgress;
    if (_isDisposed ||
        local == null ||
        canonical == null ||
        !local.canAcknowledge(canonical)) {
      return local;
    }
    return await _autoSaveManager.recoverSavedUpload(
      pending: local,
      saved: canonical,
    );
  }

  Future<void> _restorePendingDraft() async {
    var local = await _recoverPendingDraft(await _loadPendingDraft());
    final created = _acknowledgedCreation;
    if (created != null && local?.canAcknowledge(created) == true) {
      local = await _loadPendingDraft();
    }
    if (!_isDisposed && revalidateEligibility()) _applyPendingDraft(local);
  }

  void _applyPendingDraft(PendingRecall? local) {
    if (local == null) {
      _conflictingDraft = null;
      return;
    }
    final canonical = _canonicalProgress;
    if (canonical != null &&
        !local.canReplace(canonical) &&
        !local.matchesUploadedRecall(canonical.result.result as DailyRecall)) {
      _conflictingDraft = local;
      return;
    }
    _conflictingDraft = null;
    if (_canRestore(local)) {
      recall = _copyRecall(local.recall);
      lastSaveTime = local.recall.lastAutoSavedAt;
    }
  }

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

    final latestProgress = _findCanonicalProgress(taskId, periodId, studyDay);
    if (latestProgress == null) return false;
    final latestRecall = latestProgress.result.result as DailyRecall;

    _adoptCanonicalRecall(latestProgress, latestRecall, periodId, studyDay);
    return true;
  }

  SubjectProgress? _findCanonicalProgress(
    String taskId,
    String periodId,
    int studyDay,
  ) {
    SubjectProgress? latestProgress;
    for (final progress in subject!.progress) {
      if (progress.taskId != taskId ||
          progress.resultType != 'DailyRecall' ||
          progress.result.periodId != periodId ||
          progress.completedAt == null) {
        continue;
      }
      final candidate = progress.result.result;
      if (candidate is! DailyRecall ||
          candidate.entryCompletedAt == null ||
          candidate.studyDaySnapshot != studyDay) {
        continue;
      }
      if (latestProgress == null ||
          progress.nutritionRevision > latestProgress.nutritionRevision ||
          progress.nutritionRevision == latestProgress.nutritionRevision &&
              progress.completedAt!.isAfter(latestProgress.completedAt!)) {
        latestProgress = progress;
      }
    }
    return latestProgress;
  }

  void _adoptCanonicalRecall(
    SubjectProgress progress,
    DailyRecall canonical,
    String periodId,
    int studyDay,
  ) {
    _pinCanonicalProgress(progress, periodId, studyDay);
    recall = _copyRecall(canonical);
    _hasExistingRecall = true;
    lastSaveTime = recall.lastAutoSavedAt;
  }

  void _pinCanonicalProgress(
    SubjectProgress progress,
    String periodId,
    int studyDay,
  ) {
    _canonicalProgress = progress;
    _interventionId = progress.interventionId;
    _persistenceTarget = NutritionRecallPersistenceTarget(
      taskId: progress.taskId,
      periodId: periodId,
      interventionId: progress.interventionId,
      completedAt: progress.completedAt!,
      studyDaySnapshot: studyDay,
      nutritionRevision: progress.nutritionRevision,
    );
  }

  void _acceptAcknowledgedCreation(SubjectProgress progress) {
    final canonical = progress.result.result;
    if (_isDisposed ||
        persistenceTarget != null ||
        canonical is! DailyRecall ||
        progress.subjectId != subject?.id ||
        progress.taskId != task?.id ||
        progress.result.periodId != _periodId ||
        progress.interventionId != _interventionId ||
        canonical.studyDaySnapshot != _studyDaySnapshot ||
        canonical.id != recall.id ||
        progress.completedAt == null) {
      return;
    }
    _pinCanonicalProgress(progress, _periodId!, _studyDaySnapshot!);
    _acknowledgedCreation = progress;
    recall
      ..date = canonical.date
      ..entryCompletedAt = canonical.entryCompletedAt;
    notifyListeners();
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
      await _restorePendingDraft();
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
    unawaited(_creationSubscription?.cancel());
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

  bool addMeal(MealLog meal) {
    if (readOnly || !revalidateEditingEligibility()) return false;
    recall.meals.add(meal);
    notifyListeners();
    _scheduleAutoSave('meal added');
    return true;
  }

  Future<bool> saveAssistedMeals(List<MealLog> meals) async {
    await _initialization;
    if (_isDisposed ||
        !revalidateEditingEligibility() ||
        meals.isEmpty ||
        meals.any((meal) => !meal.isValidForSave(hasSelectedTime: true))) {
      return false;
    }
    final hadScheduledSave = _autoSaveTimer != null;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    await _remoteSaveQueue;
    if (_isDisposed || !revalidateEditingEligibility()) return false;

    final mealsById = {
      for (final meal in recall.meals) meal.id: meal,
      for (final meal in meals) meal.id: meal,
    };
    final canSaveLocally = _canSaveLocalSnapshot;
    final updated = _copyWithRecall(
      meals: mealsById.values.toList(),
      lastAutoSavedAt: canSaveLocally ? clock().toUtc() : null,
    );
    if (canSaveLocally) {
      // Commit the whole batch before showing it in the diary.
      final save = _queueLocalSnapshot(updated);
      try {
        await save;
      } catch (_) {
        if (hadScheduledSave && !_isDisposed) _scheduleRemoteAutoSave();
        rethrow;
      }
      _localSaveFuture = save;
    }
    if (_isDisposed) return true;
    recall = updated;
    lastSaveTime = updated.lastAutoSavedAt;
    if (canSaveLocally) _scheduleRemoteAutoSave();
    notifyListeners();
    return true;
  }

  bool updateMeal(int index, MealLog meal) {
    if (readOnly || !revalidateEditingEligibility()) return false;
    recall.meals[index] = meal;
    notifyListeners();
    _scheduleAutoSave('meal edited');
    return true;
  }

  bool updateMealById(String mealId, MealLog meal) {
    final index = recall.meals.indexWhere((entry) => entry.id == mealId);
    return index >= 0 && updateMeal(index, meal);
  }

  bool removeMeal(int index) {
    if (readOnly || !revalidateEditingEligibility()) return false;
    recall.meals.removeAt(index);
    notifyListeners();
    _scheduleAutoSave('meal removed');
    return true;
  }

  bool removeMealById(String mealId) {
    final index = recall.meals.indexWhere((entry) => entry.id == mealId);
    return index >= 0 && removeMeal(index);
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
    List<MealLog>? meals,
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
    meals: meals ?? recall.meals,
    waterIntakeMl: waterIntakeMl ?? recall.waterIntakeMl,
    studyDaySnapshot: _studyDaySnapshot ?? recall.studyDaySnapshot,
    lastAutoSavedAt: lastAutoSavedAt ?? recall.lastAutoSavedAt,
  );

  Future<void> clearAutoSave() async {
    if (!canEdit ||
        subject == null ||
        _studyDaySnapshot == null ||
        _periodId == null) {
      return;
    }
    await _localSaveFuture;

    await _autoSaveManager.deleteRecall(
      subjectId: subject!.id,
      taskId: task!.id,
      studyDay: _studyDaySnapshot!,
      periodId: _periodId!,
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
    if (persistToDatabase && _requestInitialHistoricalUpload()) {
      return;
    }
    if (persistToDatabase && (hadScheduledSave || requireRemoteSuccess)) {
      await _performAutoSave(propagateErrors: requireRemoteSuccess);
    } else {
      await _remoteSaveQueue;
    }
  }

  bool _requestInitialHistoricalUpload() {
    if (!historicalMode || persistenceTarget != null || subject == null) {
      return false;
    }
    if (shouldSaveToDb) {
      NutritionRecallAutoSaveManager.requestUpload(subject!.id);
    }
    return true;
  }

  void _scheduleAutoSave([String reason = 'unspecified']) {
    if (!_canSaveLocalSnapshot) return;
    StudyULogger.debug(
      '[DailyRecallVM] Schedule auto-save ($reason) | '
      'studyDay=$_studyDaySnapshot subject=${subject?.id}',
    );
    _persistLocalSnapshot();
    _scheduleRemoteAutoSave();
  }

  bool get _canSaveLocalSnapshot =>
      !readOnly &&
      !_persistenceSuspended &&
      subject != null &&
      _studyDaySnapshot != null &&
      _periodId != null &&
      _interventionId != null;

  void _scheduleRemoteAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(NutritionRecallAutoSaveManager.debounceDuration, () {
      _autoSaveTimer = null;
      unawaited(_performAutoSaveAfterLocalSave());
    });
  }

  void _persistLocalSnapshot() {
    if (!_canSaveLocalSnapshot || !revalidateEditingEligibility()) {
      return;
    }
    final savedAt = clock().toUtc();
    recall = _copyWithRecall(lastAutoSavedAt: savedAt);
    lastSaveTime = savedAt;
    final localSave = _queueLocalSnapshot(recall);
    _localSaveFuture = localSave;
    localSave.catchError((Object error, StackTrace stackTrace) {
      StudyULogger.error(
        '[DailyRecallVM] Local auto-save failed: $error\n$stackTrace',
      );
    });
  }

  Future<void> _queueLocalSnapshot(DailyRecall snapshot) {
    final recallToSave = DailyRecall.fromJson(snapshot.toJson());
    final target = persistenceTarget;
    Future<void> saveLocal() => _autoSaveManager.saveRecall(
      recall: recallToSave,
      subjectId: subject!.id,
      taskId: task!.id,
      interventionId: _interventionId!,
      periodId: _periodId!,
      studyDaySnapshot: _studyDaySnapshot!,
      progressCompletedAt: target?.completedAt,
      nutritionRevision: target?.nutritionRevision,
      acknowledgedCreation: target == null && historicalMode
          ? () => _acknowledgedCreation
          : null,
    );
    return _localSaveFuture.then<void>(
      (_) => saveLocal(),
      onError: (_, _) => saveLocal(),
    );
  }

  Future<void> _performAutoSaveAfterLocalSave() async {
    try {
      await _localSaveFuture;
      if (!_requestInitialHistoricalUpload()) await _performAutoSave();
    } catch (error, stackTrace) {
      StudyULogger.warning(
        'Could not finish nutrition autosave: $error\n$stackTrace',
      );
    }
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
            final stored = await _loadPendingDraft();
            if (stored == null) return;
            if (stored.nutritionRevision != previousRevision) {
              await _refreshDraftAfterUpload();
              if (propagateErrors) {
                throw StateError('The local nutrition draft changed.');
              }
              NutritionRecallAutoSaveManager.requestUpload(subject!.id);
              return;
            }
            final prepared =
                stored.stagedUpload ??
                await NutritionFoodRepository(client: client)
                    .prepareRecallForUpload(
                      subjectId: subject!.id,
                      recall: stored.recall,
                    );
            if (!await _autoSaveManager.stageRecallUpload(stored, prepared)) {
              if (propagateErrors) {
                throw StateError('The local nutrition draft changed.');
              }
              NutritionRecallAutoSaveManager.requestUpload(subject!.id);
              return;
            }
            if (_isDisposed ||
                !_canPersist ||
                _persistenceSuspended ||
                !revalidateEligibility()) {
              return;
            }
            final saved = await subject!.upsertNutritionResult(
              taskId: taskId,
              periodId: periodId,
              recall: prepared,
              persistenceTarget: persistenceTarget,
              interventionIdOverride: _interventionId,
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
            await _localSaveFuture;
            await _autoSaveManager.acknowledgeRecallSave(
              saved: saved,
              uploaded: prepared,
              previousRevision: previousRevision,
            );
            if (propagateErrors && await _loadPendingDraft() != null) {
              throw StateError('A nutrition update still needs to sync.');
            }
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
        if (NutritionRecallAutoSaveManager.isRetryableError(error)) {
          NutritionRecallAutoSaveManager.requestUpload(subject!.id);
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

  Future<void> _refreshDraftAfterUpload() async {
    final progress = await subject!.fetchNutritionRecall(
      taskId: task!.id,
      periodId: _periodId!,
      studyDaySnapshot: _studyDaySnapshot!,
      target: persistenceTarget,
    );
    final canonical = progress?.result.result;
    if (_isDisposed || progress == null || canonical is! DailyRecall) return;
    subject!.applySavedProgress(progress);
    _adoptCanonicalRecall(progress, canonical, _periodId!, _studyDaySnapshot!);
    await _restorePendingDraft();
  }

  bool revalidateEligibility() {
    final target = _persistenceTarget;
    if (readOnly || !isInTaskMode) return true;
    final activeSubject = subject;
    if (activeSubject == null || activeSubject.startedAt == null) return true;
    final today = nutritionStudyDayFor(activeSubject, clock());
    if (historicalMode) {
      final studyDay = target?.studyDaySnapshot ?? _studyDaySnapshot;
      if (_historicalEligibilityExpired) return false;
      if (studyDay == null || studyDay == today - 1) return true;
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
