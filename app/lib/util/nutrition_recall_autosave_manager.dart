import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

typedef NutritionRecallSubmitter = Future<void> Function(
  PendingRecall pending,
  DailyRecall recall,
);
typedef NutritionRecallStringWriter = Future<bool> Function(
  SharedPreferences preferences,
  String key,
  String value,
);
typedef NutritionRecallKeyRemover = Future<bool> Function(
  SharedPreferences preferences,
  String key,
);

class NutritionRecallAutoSaveManager({
  final SharedPreferences? _preferences,
  final NutritionRecallSubmitter? _submitter,
  NutritionRecallStringWriter? stringWriter,
  NutritionRecallKeyRemover? keyRemover,
}) {
  static const String _keyPrefix = 'studyu_nutrition_autosave';
  static const Duration debounceDuration = Duration(seconds: 2);

  static const String standaloneTaskId = 'standalone';
  static const String unknownInterventionId = 'unknown';
  static const String defaultPeriodId = 'default';

  final NutritionRecallStringWriter _stringWriter =
      stringWriter ?? _defaultStringWriter;
  final NutritionRecallKeyRemover _keyRemover =
      keyRemover ?? _defaultKeyRemover;
  static final Map<String, Future<void>> _mutationQueues = {};
  SharedPreferences? _prefs;
  bool _isSubmitting = false;

  static Future<bool> _defaultStringWriter(
    SharedPreferences preferences,
    String key,
    String value,
  ) => preferences.setString(key, value);

  static Future<bool> _defaultKeyRemover(
    SharedPreferences preferences,
    String key,
  ) => preferences.remove(key);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= _preferences ?? await SharedPreferences.getInstance();
  }

  Future<void> saveRecall({
    required DailyRecall recall,
    required String subjectId,
    required String taskId,
    required String interventionId,
    required String periodId,
    required int studyDaySnapshot,
    DateTime? progressCompletedAt,
  }) {
    final storageKey = _buildStorageKey(
      subjectId,
      taskId,
      periodId,
      studyDaySnapshot,
    );
    final now = DateTime.now().toIso8601String();
    final dataJson = jsonEncode({
      'recall': recall.toJson(),
      'metadata': {
        'subjectId': subjectId,
        'taskId': taskId,
        'interventionId': interventionId,
        'periodId': periodId,
        'studyDaySnapshot': studyDaySnapshot,
        'progressCompletedAt': progressCompletedAt?.toIso8601String(),
        'createdAt': now,
        'lastModifiedAt': now,
      },
    });

    return _mutateForSubject(subjectId, () async {
      final prefs = await _getPrefs();
      await _writeString(prefs, storageKey, dataJson);
      await _updateIndex(prefs, subjectId, taskId, periodId, studyDaySnapshot);
      await _removeMatchingLegacyCache(
        prefs,
        subjectId,
        taskId,
        periodId,
        studyDaySnapshot,
      );

      StudyULogger.debug(
        '[AutoSave] Saved recall | subject=$subjectId task=$taskId '
        'period=$periodId studyDay=$studyDaySnapshot meals=${recall.meals.length}',
      );
    });
  }

  Future<T> _mutateForSubject<T>(
    String subjectId,
    Future<T> Function() mutation,
  ) {
    final key = '${_keyPrefix}_$subjectId';
    final previous = _mutationQueues[key] ?? Future<void>.value();
    final operation = previous.then<T>(
      (_) => mutation(),
      onError: (_, _) => mutation(),
    );
    final queueTail = operation.then<void>((_) {}, onError: (_, _) {});
    _mutationQueues[key] = queueTail;
    queueTail.whenComplete(() {
      if (identical(_mutationQueues[key], queueTail)) {
        _mutationQueues.remove(key);
      }
    });
    return operation;
  }

  Future<void> _writeString(
    SharedPreferences preferences,
    String key,
    String value,
  ) async {
    if (!await _stringWriter(preferences, key, value)) {
      throw StateError('Failed to save nutrition recall cache.');
    }
  }

  Future<void> _removeKey(SharedPreferences preferences, String key) async {
    if (!await _keyRemover(preferences, key)) {
      throw StateError('Failed to remove nutrition recall cache.');
    }
  }

  /// Reads a recall for an exact period. Without [periodId], it returns the
  /// only matching task/day cache for backward-compatible standalone callers.
  Future<DailyRecall?> loadRecall({
    required String subjectId,
    required String taskId,
    required int studyDay,
    String? periodId,
  }) async {
    if (periodId != null) {
      final pending = await loadPendingRecall(
        subjectId: subjectId,
        taskId: taskId,
        periodId: periodId,
        studyDay: studyDay,
      );
      return pending?.recall;
    }
    final matches = (await scanPendingRecalls(subjectId))
        .where(
          (pending) =>
              pending.taskId == taskId && pending.studyDaySnapshot == studyDay,
        )
        .toList();
    return matches.length == 1 ? matches.single.recall : null;
  }

  Future<PendingRecall?> loadPendingRecall({
    required String subjectId,
    required String taskId,
    required String periodId,
    required int studyDay,
  }) async {
    final prefs = await _getPrefs();
    final storageKey = _buildStorageKey(subjectId, taskId, periodId, studyDay);
    final stored = prefs.getString(storageKey);
    final current = stored == null
        ? null
        : _pendingFromJson(stored, storageKey: storageKey);
    if (current != null) return current;

    final legacyKey = _buildLegacyStorageKey(subjectId, taskId, studyDay);
    final legacy = prefs.getString(legacyKey);
    final legacyPending = legacy == null
        ? null
        : _pendingFromJson(legacy, storageKey: legacyKey);
    return legacyPending?.periodId == periodId ? legacyPending : null;
  }

  Future<List<PendingRecall>> scanPendingRecalls(String subjectId) async {
    final prefs = await _getPrefs();
    final index = await _readIndex(prefs, subjectId);
    final pendingByIdentity = <String, PendingRecall>{};

    for (final entry in index) {
      final location = _indexLocation(subjectId, entry);
      if (location == null) continue;
      final dataJson = prefs.getString(location.storageKey);
      if (dataJson == null) continue;
      final pending = _pendingFromJson(
        dataJson,
        storageKey: location.storageKey,
      );
      if (pending == null) continue;
      final identity = _identity(
        pending.taskId,
        pending.periodId,
        pending.studyDaySnapshot,
      );
      final existing = pendingByIdentity[identity];
      if (existing == null ||
          pending.lastModifiedAtDate.isAfter(existing.lastModifiedAtDate)) {
        pendingByIdentity[identity] = pending;
      }
    }

    StudyULogger.debug(
      '[AutoSave] scanPendingRecalls | subject=$subjectId '
      'found=${pendingByIdentity.length}',
    );
    return pendingByIdentity.values.toList();
  }

  PendingRecall? _pendingFromJson(
    String dataJson, {
    required String storageKey,
  }) {
    try {
      final data = Map<String, dynamic>.from(
        jsonDecode(dataJson) as Map<String, dynamic>,
      );
      final metadata = Map<String, dynamic>.from(
        data['metadata'] as Map<String, dynamic>,
      );
      final progressCompletedAt = metadata['progressCompletedAt'] as String?;
      return PendingRecall(
        recall: DailyRecall.fromJson(
          Map<String, dynamic>.from(data['recall'] as Map<String, dynamic>),
        ),
        subjectId: metadata['subjectId'] as String,
        taskId: metadata['taskId'] as String,
        interventionId: metadata['interventionId'] as String,
        periodId: metadata['periodId'] as String? ?? defaultPeriodId,
        studyDaySnapshot: (metadata['studyDaySnapshot'] as num).toInt(),
        lastModifiedAt: metadata['lastModifiedAt'] as String,
        progressCompletedAt: progressCompletedAt == null
            ? null
            : DateTime.tryParse(progressCompletedAt),
        storageKey: storageKey,
      );
    } catch (error) {
      StudyULogger.error('Failed to parse pending recall: $error');
      return null;
    }
  }

  /// Rewrites drafts after the server commits a definition edit.
  /// Subject serialization ensures older queued writes finish before this one.
  Future<void> rewriteFoodDefinition({
    required String subjectId,
    required int studyDaySnapshot,
    required FoodEntry definition,
    String? entryId,
  }) => _mutateForSubject(subjectId, () async {
    final prefs = await _getPrefs();
    final pending = await scanPendingRecalls(subjectId);
    for (final entry in pending.where(
      (pending) => pending.studyDaySnapshot == studyDaySnapshot,
    )) {
      final updatedRecall = replaceNutritionFoodSnapshots(
        entry.recall,
        definition,
        entryId: entryId,
      );
      if (jsonEncode(updatedRecall.toJson()) ==
          jsonEncode(entry.recall.toJson())) {
        continue;
      }
      final stored = prefs.getString(entry.storageKey);
      if (stored == null) continue;
      final data = Map<String, dynamic>.from(
        jsonDecode(stored) as Map<String, dynamic>,
      );
      final metadata = Map<String, dynamic>.from(
        data['metadata'] as Map<String, dynamic>,
      )..['lastModifiedAt'] = DateTime.now().toIso8601String();
      data
        ..['recall'] = updatedRecall.toJson()
        ..['metadata'] = metadata;
      await _writeString(prefs, entry.storageKey, jsonEncode(data));
    }
  });

  Future<void> deleteRecall({
    required String subjectId,
    required String taskId,
    required int studyDay,
    String? periodId,
  }) => _mutateForSubject(subjectId, () async {
    final prefs = await _getPrefs();
    final pending = await scanPendingRecalls(subjectId);
    final matches = pending.where((entry) {
      return entry.taskId == taskId &&
          entry.studyDaySnapshot == studyDay &&
          (periodId == null || entry.periodId == periodId);
    });
    for (final entry in matches) {
      await _removeKey(prefs, entry.storageKey);
      await _removeFromIndex(
        prefs,
        subjectId,
        entry.taskId,
        entry.periodId,
        entry.studyDaySnapshot,
      );
    }
  });

  Future<void> _deleteRecallIfUnchanged(PendingRecall pending) {
    return _mutateForSubject(pending.subjectId, () async {
      final prefs = await _getPrefs();
      final dataJson = prefs.getString(pending.storageKey);
      if (dataJson == null) return;
      final current = _pendingFromJson(
        dataJson,
        storageKey: pending.storageKey,
      );
      if (current?.lastModifiedAt != pending.lastModifiedAt) return;

      await _removeKey(prefs, pending.storageKey);
      await _removeFromIndex(
        prefs,
        pending.subjectId,
        pending.taskId,
        pending.periodId,
        pending.studyDaySnapshot,
      );
    });
  }

  Future<void> submitPendingRecalls({
    required StudySubject subject,
    required bool trackProgress,
    DateTime? now,
  }) async {
    if (_isSubmitting || !trackProgress) return;
    _isSubmitting = true;

    try {
      final todayStudyDay = nutritionStudyDayFor(
        subject,
        now ?? DateTime.now(),
      );
      final pendingRecalls = await scanPendingRecalls(subject.id);
      for (final pending in pendingRecalls) {
        if (pending.studyDaySnapshot > todayStudyDay ||
            pending.studyDaySnapshot < 0) {
          continue;
        }

        final isPreviousDay = pending.studyDaySnapshot < todayStudyDay;
        if (isPreviousDay &&
            pending.progressCompletedAt == null &&
            pending.recall.entryCompletedAt == null &&
            _hasCompletedProgressFor(
              subject,
              taskId: pending.taskId,
              periodId: pending.periodId,
              studyDay: pending.studyDaySnapshot,
            )) {
          // An ambiguous draft must not replace completed participant data.
          if (pending.recall.canWriteAvailability) {
            await _deleteRecallIfUnchanged(pending);
          }
          continue;
        }
        final recall = isPreviousDay && pending.progressCompletedAt == null
            ? _finalizeRecall(pending.recall, pending.studyDaySnapshot)
            : pending.recall;
        try {
          var pendingForDelete = pending;
          if (_submitter != null) {
            await _submitter(pending, recall);
          } else {
            final versionsBefore = {
              for (final food in recall.meals.expand((meal) => meal.foods))
                food.id: food.foodVersionId,
            };
            await NutritionFoodRepository().ensureDefinitions(
              subjectId: subject.id,
              foods: recall.meals.expand((meal) => meal.foods),
            );
            final linkageChanged = recall.meals
                .expand((meal) => meal.foods)
                .any((food) => versionsBefore[food.id] != food.foodVersionId);
            if (linkageChanged) {
              await saveRecall(
                recall: recall,
                subjectId: pending.subjectId,
                taskId: pending.taskId,
                interventionId: pending.interventionId,
                periodId: pending.periodId,
                studyDaySnapshot: pending.studyDaySnapshot,
                progressCompletedAt: pending.progressCompletedAt,
              );
              pendingForDelete =
                  await loadPendingRecall(
                    subjectId: pending.subjectId,
                    taskId: pending.taskId,
                    periodId: pending.periodId,
                    studyDay: pending.studyDaySnapshot,
                  ) ??
                  pending;
            }
            await subject.upsertNutritionResult(
              taskId: pending.taskId,
              periodId: pending.periodId,
              recall: recall,
              completionDateOverride: isPreviousDay
                  ? recall.entryCompletedAt
                  : null,
              interventionIdOverride:
                  pending.interventionId == unknownInterventionId
                  ? null
                  : pending.interventionId,
              persistenceTarget: pending.progressCompletedAt == null
                  ? null
                  : NutritionRecallPersistenceTarget(
                      taskId: pending.taskId,
                      periodId: pending.periodId,
                      interventionId: pending.interventionId,
                      completedAt: pending.progressCompletedAt!,
                      studyDaySnapshot: pending.studyDaySnapshot,
                    ),
            );
          }
          if (isPreviousDay) {
            await _deleteRecallIfUnchanged(pendingForDelete);
          }
        } on SocketException {
          StudyULogger.warning(
            'Network error while submitting nutrition recall for study day '
            '${pending.studyDaySnapshot}. Will retry later.',
          );
        } catch (error) {
          StudyULogger.error(
            'Failed to submit nutrition recall for study day '
            '${pending.studyDaySnapshot}: $error',
          );
        }
      }
      await updateLastKnownStudyDay(subject.id, todayStudyDay);
    } finally {
      _isSubmitting = false;
    }
  }

  bool _hasCompletedProgressFor(
    StudySubject subject, {
    required String taskId,
    required String periodId,
    required int studyDay,
  }) {
    return subject.progress.any((progress) {
      if (progress.taskId != taskId || progress.resultType != 'DailyRecall') {
        return false;
      }
      final resultPeriodId = progress.result.periodId;
      if (resultPeriodId != periodId && resultPeriodId != null) return false;
      final result = progress.result.result;
      if (result is! DailyRecall || result.entryCompletedAt == null) {
        return false;
      }
      if (result.studyDaySnapshot == studyDay) return true;
      return result.studyDaySnapshot == null &&
          progress.completedAt != null &&
          subject.getDayOfStudyFor(progress.completedAt!.toLocal()) == studyDay;
    });
  }

  DailyRecall _finalizeRecall(DailyRecall recall, int studyDaySnapshot) {
    final now = DateTime.now();
    final dayStart = DateTime(
      recall.date.year,
      recall.date.month,
      recall.date.day,
    );
    final dayEnd = DateTime(
      recall.date.year,
      recall.date.month,
      recall.date.day + 1,
    ).subtract(const Duration(microseconds: 1));
    final completionCandidate =
        recall.entryCompletedAt ??
        recall.lastAutoSavedAt ??
        recall.entryStartedAt ??
        now;
    final completedAt = completionCandidate.isBefore(dayStart)
        ? dayStart
        : completionCandidate.isAfter(dayEnd)
        ? dayEnd
        : completionCandidate;
    return DailyRecall(
      id: recall.id,
      date: recall.date,
      isUsualIntakeDay: recall.isUsualIntakeDay,
      specialOccasion: recall.specialOccasion,
      recallMode: recall.recallMode,
      entryStartedAt: recall.entryStartedAt,
      entryCompletedAt: completedAt,
      meals: recall.meals,
      studyDaySnapshot: recall.studyDaySnapshot ?? studyDaySnapshot,
      lastAutoSavedAt: recall.lastAutoSavedAt ?? recall.entryCompletedAt ?? now,
      availabilityVerified: recall.availabilityVerified,
    );
  }

  Future<int?> getLastKnownStudyDay(String subjectId) async {
    final prefs = await _getPrefs();
    final value = prefs.getString('${_keyPrefix}_last_study_day_$subjectId');
    return value == null ? null : int.tryParse(value);
  }

  Future<void> updateLastKnownStudyDay(String subjectId, int studyDay) async {
    final prefs = await _getPrefs();
    await _writeString(
      prefs,
      '${_keyPrefix}_last_study_day_$subjectId',
      studyDay.toString(),
    );
  }

  String _buildStorageKey(
    String subjectId,
    String taskId,
    String periodId,
    int studyDay,
  ) => '${_keyPrefix}_${subjectId}_${taskId}_${periodId}_$studyDay';

  String _buildLegacyStorageKey(
    String subjectId,
    String taskId,
    int studyDay,
  ) => '${_keyPrefix}_${subjectId}_${taskId}_$studyDay';

  String _identity(String taskId, String periodId, int studyDay) =>
      '$taskId\u0000$periodId\u0000$studyDay';

  Future<List<dynamic>> _readIndex(
    SharedPreferences prefs,
    String subjectId,
  ) async {
    final indexJson = prefs.getString('${_keyPrefix}_index_$subjectId');
    if (indexJson == null) return [];
    try {
      return List<dynamic>.from(jsonDecode(indexJson) as List);
    } catch (error) {
      StudyULogger.error('Failed to parse nutrition recall index: $error');
      return [];
    }
  }

  _IndexLocation? _indexLocation(String subjectId, dynamic entry) {
    if (entry is Map) {
      final data = Map<String, dynamic>.from(entry);
      final taskId = data['taskId'] as String?;
      final periodId = data['periodId'] as String?;
      final studyDay = data['studyDaySnapshot'];
      if (taskId == null || periodId == null || studyDay is! num) return null;
      return _IndexLocation(
        _buildStorageKey(subjectId, taskId, periodId, studyDay.toInt()),
      );
    }
    if (entry is! String) return null;
    final separator = entry.lastIndexOf('_');
    if (separator <= 0) return null;
    final taskId = entry.substring(0, separator);
    final studyDay = int.tryParse(entry.substring(separator + 1));
    if (studyDay == null) return null;
    return _IndexLocation(_buildLegacyStorageKey(subjectId, taskId, studyDay));
  }

  Future<void> _updateIndex(
    SharedPreferences prefs,
    String subjectId,
    String taskId,
    String periodId,
    int studyDay,
  ) async {
    final index = await _readIndex(prefs, subjectId);
    final contains = index.any((entry) {
      if (entry is! Map) return false;
      return entry['taskId'] == taskId &&
          entry['periodId'] == periodId &&
          entry['studyDaySnapshot'] == studyDay;
    });
    if (!contains) {
      index.add({
        'taskId': taskId,
        'periodId': periodId,
        'studyDaySnapshot': studyDay,
      });
      await _writeString(
        prefs,
        '${_keyPrefix}_index_$subjectId',
        jsonEncode(index),
      );
    }
  }

  Future<void> _removeMatchingLegacyCache(
    SharedPreferences prefs,
    String subjectId,
    String taskId,
    String periodId,
    int studyDay,
  ) async {
    final legacyKey = _buildLegacyStorageKey(subjectId, taskId, studyDay);
    final dataJson = prefs.getString(legacyKey);
    final legacy = dataJson == null
        ? null
        : _pendingFromJson(dataJson, storageKey: legacyKey);
    if (legacy?.periodId != periodId) return;
    await _removeKey(prefs, legacyKey);
    final index = await _readIndex(prefs, subjectId);
    final retained = index
        .where((entry) => entry is! String || entry != '${taskId}_$studyDay')
        .toList();
    final indexKey = '${_keyPrefix}_index_$subjectId';
    if (retained.length == index.length) return;
    await _writeString(prefs, indexKey, jsonEncode(retained));
  }

  Future<void> _removeFromIndex(
    SharedPreferences prefs,
    String subjectId,
    String taskId,
    String periodId,
    int studyDay,
  ) async {
    final index = await _readIndex(prefs, subjectId);
    final legacyKey = _buildLegacyStorageKey(subjectId, taskId, studyDay);
    final legacyJson = prefs.getString(legacyKey);
    final legacy = legacyJson == null
        ? null
        : _pendingFromJson(legacyJson, storageKey: legacyKey);
    final retained = index.where((entry) {
      if (entry is Map) {
        return !(entry['taskId'] == taskId &&
            entry['periodId'] == periodId &&
            entry['studyDaySnapshot'] == studyDay);
      }
      if (entry is! String) return true;
      final separator = entry.lastIndexOf('_');
      return !(separator > 0 &&
          entry.substring(0, separator) == taskId &&
          int.tryParse(entry.substring(separator + 1)) == studyDay &&
          legacy?.periodId == periodId);
    }).toList();
    final indexKey = '${_keyPrefix}_index_$subjectId';
    if (retained.length == index.length) return;
    if (retained.isEmpty) {
      await _removeKey(prefs, indexKey);
    } else {
      await _writeString(prefs, indexKey, jsonEncode(retained));
    }
  }
}

class const _IndexLocation(final String storageKey);

class PendingRecall({
  required final DailyRecall recall,
  required final String subjectId,
  required final String taskId,
  required final String interventionId,
  required final String periodId,
  required final int studyDaySnapshot,
  required final String lastModifiedAt,
  final DateTime? progressCompletedAt,
  required final String storageKey,
}) {
  DateTime get lastModifiedAtDate =>
      DateTime.tryParse(lastModifiedAt) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
