import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

class NutritionRecallAutoSaveManager() {
  static const String _keyPrefix = 'studyu_nutrition_autosave';
  static const Duration debounceDuration = Duration(seconds: 2);
  static const int maxRetentionDays = 7;

  static const String standaloneTaskId = 'standalone';
  static const String unknownInterventionId = 'unknown';
  static const String defaultPeriodId = 'default';

  static SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  bool _isSubmitting = false;

  Future<void> saveRecall({
    required DailyRecall recall,
    required String subjectId,
    required String taskId,
    required String interventionId,
    required String periodId,
    required int studyDaySnapshot,
  }) async {
    final prefs = await _getPrefs();
    _doSave(
      prefs,
      recall,
      subjectId,
      taskId,
      interventionId,
      periodId,
      studyDaySnapshot,
    );
  }

  void saveRecallImmediate({
    required DailyRecall recall,
    required String subjectId,
    required String taskId,
    required String interventionId,
    required String periodId,
    required int studyDaySnapshot,
  }) {
    if (_prefs == null) {
      // Fallback to fire-and-forget async if prefs not loaded
      saveRecall(
        recall: recall,
        subjectId: subjectId,
        taskId: taskId,
        interventionId: interventionId,
        periodId: periodId,
        studyDaySnapshot: studyDaySnapshot,
      );
      return;
    }
    _doSave(
      _prefs!,
      recall,
      subjectId,
      taskId,
      interventionId,
      periodId,
      studyDaySnapshot,
    );
  }

  void _doSave(
    SharedPreferences prefs,
    DailyRecall recall,
    String subjectId,
    String taskId,
    String interventionId,
    String periodId,
    int studyDaySnapshot,
  ) {
    final storageKey = _buildStorageKey(subjectId, taskId, studyDaySnapshot);

    final data = {
      'recall': recall.toJson(),
      'metadata': {
        'subjectId': subjectId,
        'taskId': taskId,
        'interventionId': interventionId,
        'periodId': periodId,
        'studyDaySnapshot': studyDaySnapshot,
        'createdAt': DateTime.now().toIso8601String(),
        'lastModifiedAt': DateTime.now().toIso8601String(),
      },
    };

    prefs.setString(storageKey, jsonEncode(data));

    _updateIndexSync(prefs, subjectId, taskId, studyDaySnapshot);

    StudyULogger.debug(
      '[AutoSave] Saved recall | subject=$subjectId task=$taskId studyDay=$studyDaySnapshot '
      'meals=${recall.meals.length} recallMode=${recall.recallMode} lastSaved=${recall.lastAutoSavedAt}',
    );
  }

  Future<DailyRecall?> loadRecall({
    required String subjectId,
    required String taskId,
    required int studyDay,
  }) async {
    final prefs = await _getPrefs();
    final storageKey = _buildStorageKey(subjectId, taskId, studyDay);

    final dataJson = prefs.getString(storageKey);
    if (dataJson == null) return null;

    try {
      final data = jsonDecode(dataJson) as Map<String, dynamic>;
      return DailyRecall.fromJson(data['recall'] as Map<String, dynamic>);
    } catch (e) {
      StudyULogger.error('Failed to load auto-saved recall: $e');
      return null;
    }
  }

  Future<List<PendingRecall>> scanPendingRecalls(String subjectId) async {
    final prefs = await _getPrefs();
    final indexKey = '${_keyPrefix}_index_$subjectId';
    final indexJson = prefs.getString(indexKey);

    if (indexJson == null) return [];

    final index = List<String>.from(jsonDecode(indexJson) as List);
    final pending = <PendingRecall>[];

    for (final entry in index) {
      final parts = entry.split('_');
      if (parts.length != 2) continue;

      final taskId = parts[0];
      final studyDay = int.tryParse(parts[1]);
      if (studyDay == null) continue;

      final storageKey = _buildStorageKey(subjectId, taskId, studyDay);
      final dataJson = prefs.getString(storageKey);

      if (dataJson != null) {
        try {
          final data = jsonDecode(dataJson) as Map<String, dynamic>;
          final metadata = data['metadata'] as Map<String, dynamic>;

          pending.add(
            PendingRecall(
              recall: DailyRecall.fromJson(
                data['recall'] as Map<String, dynamic>,
              ),
              subjectId: metadata['subjectId'] as String,
              taskId: metadata['taskId'] as String,
              interventionId: metadata['interventionId'] as String,
              periodId: metadata['periodId'] as String,
              studyDaySnapshot: metadata['studyDaySnapshot'] as int,
            ),
          );
        } catch (e) {
          StudyULogger.error('Failed to parse pending recall: $e');
        }
      }
    }

    StudyULogger.debug(
      '[AutoSave] scanPendingRecalls | subject=$subjectId found=${pending.length}',
    );

    return pending;
  }

  Future<void> deleteRecall({
    required String subjectId,
    required String taskId,
    required int studyDay,
  }) async {
    final prefs = await _getPrefs();
    final storageKey = _buildStorageKey(subjectId, taskId, studyDay);

    await prefs.remove(storageKey);
    await _removeFromIndex(subjectId, taskId, studyDay);

    StudyULogger.info(
      'Deleted auto-save for task $taskId, study day $studyDay',
    );
  }

  Future<void> submitPendingRecalls({
    required StudySubject subject,
    required bool trackProgress,
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;

    try {
      final todayStudyDay = subject.getDayOfStudyFor(DateTime.now());
      StudyULogger.debug(
        '[AutoSave] submitPendingRecalls start | subject=${subject.id} todayStudyDay=$todayStudyDay trackProgress=$trackProgress',
      );

      final pendingRecalls = await scanPendingRecalls(subject.id);

      for (final pending in pendingRecalls) {
        if (pending.studyDaySnapshot >= todayStudyDay) {
          StudyULogger.debug(
            '[AutoSave] skip pending submit (same/future day) | studyDay=${pending.studyDaySnapshot} today=$todayStudyDay',
          );
          continue; // skip same-day or future autosaves
        }

        if (pending.studyDaySnapshot < 0) {
          StudyULogger.warning(
            '[AutoSave] skip pending submit (invalid negative day) | studyDay=${pending.studyDaySnapshot}',
          );
          // Optionally delete invalid auto-save
          await deleteRecall(
            subjectId: pending.subjectId,
            taskId: pending.taskId,
            studyDay: pending.studyDaySnapshot,
          );
          continue;
        }

        final now = DateTime.now();
        final originalRecall = pending.recall;
        final lastSaved =
            originalRecall.lastAutoSavedAt ??
            originalRecall.entryCompletedAt ??
            now;

        final actualCompletion =
            originalRecall.entryCompletedAt ??
            originalRecall.lastAutoSavedAt ??
            originalRecall.entryStartedAt;

        final recall = DailyRecall(
          id: originalRecall.id,
          date: originalRecall.date,
          isUsualIntakeDay: originalRecall.isUsualIntakeDay,
          specialOccasion: originalRecall.specialOccasion,
          recallMode: originalRecall.recallMode,
          entryStartedAt: originalRecall.entryStartedAt,
          entryCompletedAt: actualCompletion,
          meals: originalRecall.meals,
          studyDaySnapshot:
              originalRecall.studyDaySnapshot ?? pending.studyDaySnapshot,
          lastAutoSavedAt: lastSaved,
        );

        StudyULogger.debug(
          '[AutoSave] submitting pending | task=${pending.taskId} studyDay=${pending.studyDaySnapshot} '
          'meals=${recall.meals.length} entryCompletedAt=${recall.entryCompletedAt}',
        );

        try {
          if (trackProgress) {
            await subject.upsertNutritionResult(
              taskId: pending.taskId,
              periodId: pending.periodId,
              recall: recall,
              completionDateOverride: recall.entryCompletedAt,
            );
          }

          await deleteRecall(
            subjectId: pending.subjectId,
            taskId: pending.taskId,
            studyDay: pending.studyDaySnapshot,
          );
        } on SocketException catch (_) {
          StudyULogger.warning(
            'Network error while submitting pending recall for study day '
            '${pending.studyDaySnapshot}. Will retry later.',
          );
        } catch (e) {
          StudyULogger.error(
            'Failed to submit pending recall for study day '
            '${pending.studyDaySnapshot}: $e',
          );
        }
      }

      await updateLastKnownStudyDay(subject.id, todayStudyDay);
      await _pruneOldRecalls(subject.id, todayStudyDay);
    } finally {
      _isSubmitting = false;
    }
  }

  Future<int?> getLastKnownStudyDay(String subjectId) async {
    final prefs = await _getPrefs();
    final key = '${_keyPrefix}_last_study_day_$subjectId';
    final value = prefs.getString(key);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> updateLastKnownStudyDay(String subjectId, int studyDay) async {
    final prefs = await _getPrefs();
    final key = '${_keyPrefix}_last_study_day_$subjectId';
    await prefs.setString(key, studyDay.toString());
  }

  Future<void> _pruneOldRecalls(String subjectId, int todayStudyDay) async {
    final pending = await scanPendingRecalls(subjectId);
    for (final recall in pending) {
      if (todayStudyDay - recall.studyDaySnapshot > maxRetentionDays) {
        await deleteRecall(
          subjectId: recall.subjectId,
          taskId: recall.taskId,
          studyDay: recall.studyDaySnapshot,
        );
      }
    }
  }

  String _buildStorageKey(String subjectId, String taskId, int studyDay) {
    return '${_keyPrefix}_${subjectId}_${taskId}_$studyDay';
  }

  void _updateIndexSync(
    SharedPreferences prefs,
    String subjectId,
    String taskId,
    int studyDay,
  ) {
    final indexKey = '${_keyPrefix}_index_$subjectId';
    final indexJson = prefs.getString(indexKey);

    final index = indexJson != null
        ? List<String>.from(jsonDecode(indexJson) as List)
        : <String>[];

    final entry = '${taskId}_$studyDay';
    if (!index.contains(entry)) {
      index.add(entry);
      prefs.setString(indexKey, jsonEncode(index));
    }
  }

  Future<void> _removeFromIndex(
    String subjectId,
    String taskId,
    int studyDay,
  ) async {
    final prefs = await _getPrefs();
    final indexKey = '${_keyPrefix}_index_$subjectId';
    final indexJson = prefs.getString(indexKey);

    if (indexJson == null) return;

    final index = List<String>.from(jsonDecode(indexJson) as List);
    final entry = '${taskId}_$studyDay';

    if (index.remove(entry)) {
      if (index.isEmpty) {
        await prefs.remove(indexKey);
      } else {
        await prefs.setString(indexKey, jsonEncode(index));
      }
    }
  }
}

class PendingRecall({
  required final DailyRecall recall,
  required final String subjectId,
  required final String taskId,
  required final String interventionId,
  required final String periodId,
  required final int studyDaySnapshot,
});
