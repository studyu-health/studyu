import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart' show ClientException;
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef NutritionRecallSubmitter = Future<void> Function(
  PendingRecall pending,
  DailyRecall recall,
);

class NutritionRecallAutoSaveManager {
  new({this._submitter}) : _memoryDrafts = null;

  new inMemory() : _submitter = null, _memoryDrafts = {};

  final NutritionRecallSubmitter? _submitter;
  final Map<String, Map<String, dynamic>>? _memoryDrafts;
  final _memoryMutationQueues = <String, Future<void>>{};

  static const _keyPrefix = 'studyu_nutrition_drafts_v1';
  static const debounceDuration = Duration(seconds: 2);
  static final _mutationQueues = <String, Future<void>>{};
  static final _uploadRequests = StreamController<String>.broadcast();

  static Stream<String> get uploadRequests => _uploadRequests.stream;

  static void requestUpload(String subjectId) => _uploadRequests.add(subjectId);

  static bool isRetryableError(Object error) =>
      error is SocketException ||
      error is ClientException ||
      error is TimeoutException ||
      error is PostgrestException &&
          const {
            '500',
            '502',
            '503',
            '504',
            '55P03',
            'PGRST000',
            'PGRST001',
            'PGRST002',
          }.contains(error.code);

  bool _isSubmitting = false;

  Future<void> saveRecall({
    required DailyRecall recall,
    required String subjectId,
    required String taskId,
    required String interventionId,
    required String periodId,
    required int studyDaySnapshot,
    DateTime? progressCompletedAt,
    int? nutritionRevision,
  }) {
    final identity = _identity(taskId, periodId, studyDaySnapshot);
    final draft = <String, dynamic>{
      'recall': recall.toJson(),
      'metadata': {
        'subjectId': subjectId,
        'taskId': taskId,
        'interventionId': interventionId,
        'periodId': periodId,
        'studyDaySnapshot': studyDaySnapshot,
        'progressCompletedAt': progressCompletedAt?.toUtc().toIso8601String(),
        'nutritionRevision': ?nutritionRevision,
        'lastModifiedAt': DateTime.now().toUtc().toIso8601String(),
      },
    };
    return _mutateForSubject(subjectId, () async {
      final drafts = await _readDrafts(subjectId);
      final stored = drafts[identity];
      final previous = _pendingFromJson(stored, identity);
      if (stored is Map<String, dynamic> &&
          previous?.recall.id == recall.id &&
          previous?.nutritionRevision == nutritionRevision &&
          stored['upload'] != null) {
        draft['upload'] = stored['upload'];
      }
      drafts[identity] = draft;
      await _writeDrafts(subjectId, drafts);
    });
  }

  Future<T> _mutateForSubject<T>(
    String subjectId,
    Future<T> Function() mutation,
  ) {
    final key = '${_keyPrefix}_$subjectId';
    final queues = _memoryDrafts == null
        ? _mutationQueues
        : _memoryMutationQueues;
    final previous = queues[key] ?? Future<void>.value();
    final operation = previous.then<T>(
      (_) => mutation(),
      onError: (_, _) => mutation(),
    );
    final queueTail = operation.then<void>((_) {}, onError: (_, _) {});
    queues[key] = queueTail;
    queueTail.whenComplete(() {
      if (identical(queues[key], queueTail)) {
        queues.remove(key);
      }
    });
    return operation;
  }

  String _subjectKey(String subjectId) => '${_keyPrefix}_$subjectId';

  Future<Map<String, dynamic>> _readDrafts(String subjectId) async {
    if (_memoryDrafts case final memory?) {
      return _copyDrafts(memory[subjectId] ?? {});
    }
    final stored = await SecureStorage.read(_subjectKey(subjectId));
    return stored == null
        ? <String, dynamic>{}
        : jsonDecode(stored) as Map<String, dynamic>;
  }

  Future<void> _writeDrafts(
    String subjectId,
    Map<String, dynamic> drafts,
  ) async {
    if (_memoryDrafts case final memory?) {
      if (drafts.isEmpty) {
        memory.remove(subjectId);
      } else {
        memory[subjectId] = _copyDrafts(drafts);
      }
      return;
    }
    if (drafts.isEmpty) {
      await SecureStorage.delete(_subjectKey(subjectId));
    } else {
      await SecureStorage.write(_subjectKey(subjectId), jsonEncode(drafts));
    }
  }

  Map<String, dynamic> _copyDrafts(Map<String, dynamic> drafts) =>
      jsonDecode(jsonEncode(drafts)) as Map<String, dynamic>;

  Future<DailyRecall?> loadRecall({
    required String subjectId,
    required String taskId,
    required int studyDay,
    required String periodId,
  }) async => (await loadPendingRecall(
    subjectId: subjectId,
    taskId: taskId,
    periodId: periodId,
    studyDay: studyDay,
  ))?.recall;

  Future<PendingRecall?> loadPendingRecall({
    required String subjectId,
    required String taskId,
    required String periodId,
    required int studyDay,
  }) async {
    final identity = _identity(taskId, periodId, studyDay);
    final drafts = await _readDrafts(subjectId);
    return _pendingFromJson(drafts[identity], identity);
  }

  Future<List<PendingRecall>> scanPendingRecalls(String subjectId) async =>
      _pendingFrom(await _readDrafts(subjectId));

  List<PendingRecall> _pendingFrom(Map<String, dynamic> drafts) => [
    for (final entry in drafts.entries)
      ?_pendingFromJson(entry.value, entry.key),
  ];

  PendingRecall? _pendingFromJson(Object? stored, String storageKey) {
    if (stored == null) return null;
    try {
      final data = stored as Map<String, dynamic>;
      final metadata = data['metadata'] as Map<String, dynamic>;
      final completedAt = metadata['progressCompletedAt'] as String?;
      final upload = data['upload'] as Map<String, dynamic>?;
      return PendingRecall(
        recall: DailyRecall.fromJson(data['recall'] as Map<String, dynamic>),
        subjectId: metadata['subjectId'] as String,
        taskId: metadata['taskId'] as String,
        interventionId: metadata['interventionId'] as String,
        periodId: metadata['periodId'] as String,
        studyDaySnapshot: metadata['studyDaySnapshot'] as int,
        lastModifiedAt: metadata['lastModifiedAt'] as String,
        progressCompletedAt: completedAt == null
            ? null
            : DateTime.parse(completedAt),
        nutritionRevision: metadata['nutritionRevision'] as int?,
        stagedUpload: upload == null
            ? null
            : DailyRecall.fromJson(upload['recall'] as Map<String, dynamic>),
        stagedBaseRevision: upload?['baseRevision'] as int?,
        storageKey: storageKey,
      );
    } catch (error) {
      StudyULogger.warning('Could not read a stored nutrition draft.');
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
    List<SubjectProgress> canonicalProgress = const [],
  }) => _mutateForSubject(subjectId, () async {
    final drafts = await _readDrafts(subjectId);
    var changed = false;
    for (final entry in _pendingFrom(
      drafts,
    ).where((pending) => pending.studyDaySnapshot == studyDaySnapshot)) {
      final updatedRecall = replaceNutritionFoodSnapshots(
        entry.recall,
        definition,
        entryId: entryId,
      );
      var revision = entry.nutritionRevision;
      for (final saved in canonicalProgress) {
        final canonical = saved.result.result;
        if (canonical is DailyRecall &&
            saved.subjectId == entry.subjectId &&
            saved.taskId == entry.taskId &&
            saved.result.periodId == entry.periodId &&
            saved.interventionId == entry.interventionId &&
            saved.completedAt == entry.progressCompletedAt &&
            canonical.id == entry.recall.id &&
            entry.nutritionRevision == saved.nutritionRevision - 1) {
          revision = saved.nutritionRevision;
          break;
        }
      }
      if (revision == entry.nutritionRevision &&
          jsonEncode(updatedRecall.toJson()) ==
              jsonEncode(entry.recall.toJson())) {
        continue;
      }
      final data = drafts[entry.storageKey] as Map<String, dynamic>;
      final metadata = data['metadata'] as Map<String, dynamic>;
      metadata['lastModifiedAt'] = DateTime.now().toUtc().toIso8601String();
      if (revision != entry.nutritionRevision) {
        metadata['nutritionRevision'] = revision;
        data.remove('upload');
      }
      data['recall'] = updatedRecall.toJson();
      changed = true;
    }
    if (changed) await _writeDrafts(subjectId, drafts);
  });

  Future<void> deleteRecall({
    required String subjectId,
    required String taskId,
    required int studyDay,
    required String periodId,
  }) => _mutateForSubject(subjectId, () async {
    final drafts = await _readDrafts(subjectId);
    if (drafts.remove(_identity(taskId, periodId, studyDay)) != null) {
      await _writeDrafts(subjectId, drafts);
    }
  });

  Future<void> deleteSubjectDrafts(String subjectId) =>
      _mutateForSubject(subjectId, () => _writeDrafts(subjectId, {}));

  Future<void> rekeyTrackedPreviewDrafts(StudySubject subject) =>
      _mutateForSubject(subject.id, () async {
        final drafts = await _readDrafts(subject.id);
        var changed = false;
        for (final pending in _pendingFrom(drafts)) {
          if (pending.subjectId != subject.id ||
              pending.progressCompletedAt == null) {
            continue;
          }
          final saved = _findCompletedRecall(subject, pending);
          if (saved == null ||
              saved.completedAt == pending.progressCompletedAt ||
              (saved.result.result as DailyRecall).id != pending.recall.id ||
              (saved.nutritionRevision != pending.nutritionRevision &&
                  !pending.canAcknowledge(saved, allowMovedRow: true))) {
            continue;
          }
          final data = drafts[pending.storageKey] as Map<String, dynamic>;
          final metadata = data['metadata'] as Map<String, dynamic>;
          metadata['progressCompletedAt'] = saved.completedAt!
              .toUtc()
              .toIso8601String();
          changed = true;
        }
        if (changed) await _writeDrafts(subject.id, drafts);
      });

  Future<bool> deletePendingRecall(PendingRecall pending) =>
      _mutateForSubject(pending.subjectId, () async {
        final drafts = await _readDrafts(pending.subjectId);
        final stored = drafts[pending.storageKey];
        if (stored == null) return true;
        if (!_isUnchanged(pending, stored)) return false;
        drafts.remove(pending.storageKey);
        await _writeDrafts(pending.subjectId, drafts);
        return true;
      });

  bool _isUnchanged(PendingRecall pending, Object? stored) {
    final current = _pendingFromJson(stored, pending.storageKey);
    return current?.lastModifiedAt == pending.lastModifiedAt &&
        current?.nutritionRevision == pending.nutritionRevision &&
        current?.progressCompletedAt == pending.progressCompletedAt &&
        const DeepCollectionEquality().equals(
          current?.recall.toJson(),
          pending.recall.toJson(),
        ) &&
        const DeepCollectionEquality().equals(
          current?.stagedUpload?.toJson(),
          pending.stagedUpload?.toJson(),
        ) &&
        current?.stagedBaseRevision == pending.stagedBaseRevision;
  }

  Future<bool> stageRecallUpload(PendingRecall pending, DailyRecall recall) =>
      _mutateForSubject(pending.subjectId, () async {
        final drafts = await _readDrafts(pending.subjectId);
        final stored = drafts[pending.storageKey];
        if (!_isUnchanged(pending, stored)) return false;
        if (pending.stagedUpload case final previous?) {
          return pending.stagedBaseRevision == pending.nutritionRevision &&
              _sameRecallPayload(previous, recall);
        }
        (stored as Map<String, dynamic>)['upload'] = {
          'recall': recall.toJson(),
          'editableRecall': pending.recall.toJson(),
          'baseRevision': pending.nutritionRevision,
        };
        await _writeDrafts(pending.subjectId, drafts);
        return true;
      });

  Future<PendingRecall?> recoverSavedUpload({
    required PendingRecall pending,
    required SubjectProgress saved,
  }) => _mutateForSubject(pending.subjectId, () async {
    final drafts = await _readDrafts(pending.subjectId);
    final stored = drafts[pending.storageKey] as Map<String, dynamic>?;
    final current = _pendingFromJson(stored, pending.storageKey);
    if (current == null || !current.canAcknowledge(saved)) return current;
    return await _acknowledgeUpload(saved, drafts, current, stored!);
  });

  Future<void> acknowledgeRecallSave({
    required SubjectProgress saved,
    required DailyRecall uploaded,
    required int? previousRevision,
  }) => _mutateForSubject(saved.subjectId, () async {
    final identity = _identity(
      saved.taskId,
      saved.result.periodId!,
      uploaded.studyDaySnapshot!,
    );
    final drafts = await _readDrafts(saved.subjectId);
    final stored = drafts[identity] as Map<String, dynamic>?;
    final local = _pendingFromJson(stored, identity);
    final staged = local?.stagedUpload;
    if (local == null ||
        staged == null ||
        local.stagedBaseRevision != previousRevision ||
        !_sameRecallPayload(staged, uploaded) ||
        !local.canAcknowledge(saved)) {
      return;
    }
    final remaining = await _acknowledgeUpload(saved, drafts, local, stored!);
    if (remaining != null) requestUpload(saved.subjectId);
  });

  Future<PendingRecall?> _acknowledgeUpload(
    SubjectProgress saved,
    Map<String, dynamic> drafts,
    PendingRecall local,
    Map<String, dynamic> stored,
  ) async {
    final uploaded = saved.result.result as DailyRecall;
    final upload = stored['upload'] as Map<String, dynamic>;
    final unchanged = const DeepCollectionEquality().equals(
      local.recall.toJson(),
      upload['editableRecall'],
    );
    if (unchanged) {
      drafts.remove(local.storageKey);
    } else {
      final metadata = stored['metadata'] as Map<String, dynamic>;
      metadata['progressCompletedAt'] = saved.completedAt!
          .toUtc()
          .toIso8601String();
      metadata['nutritionRevision'] = saved.nutritionRevision;
      local.recall
        ..date = uploaded.date
        ..entryCompletedAt ??= uploaded.entryCompletedAt;
      stored
        ..remove('upload')
        ..['recall'] = local.recall.toJson();
    }
    await _writeDrafts(saved.subjectId, drafts);
    return unchanged ? null : _pendingFromJson(stored, local.storageKey);
  }

  Future<void> _removeExpiredUpload(PendingRecall pending) =>
      _mutateForSubject(pending.subjectId, () async {
        final drafts = await _readDrafts(pending.subjectId);
        final stored = drafts[pending.storageKey];
        if (!_isUnchanged(pending, stored)) return;
        (stored as Map<String, dynamic>).remove('upload');
        await _writeDrafts(pending.subjectId, drafts);
      });

  /// Returns true when a transport failure needs a retry.
  Future<bool> submitPendingRecalls({
    required StudySubject subject,
    required bool trackProgress,
    DateTime? now,
  }) async {
    if (_memoryDrafts != null ||
        _isSubmitting ||
        !trackProgress ||
        subject.startedAt == null) {
      return false;
    }
    _isSubmitting = true;

    try {
      final todayStudyDay = nutritionStudyDayFor(
        subject,
        now ?? DateTime.now(),
      );
      final pendingRecalls = await scanPendingRecalls(subject.id);
      var needsRetry = false;
      for (final draft in pendingRecalls) {
        var pending = draft;
        if (pending.subjectId != subject.id) continue;
        if (!isWritableNutritionStudyDay(
          pending.studyDaySnapshot,
          todayStudyDay,
        )) {
          if (pending.stagedUpload != null &&
              pending.studyDaySnapshot < todayStudyDay - 1) {
            await _removeExpiredUpload(pending);
          }
          continue;
        }

        final isPreviousDay = pending.studyDaySnapshot < todayStudyDay;
        var canonical = _findCompletedRecall(subject, pending);
        if (pending.stagedUpload != null && _submitter == null) {
          try {
            final remote = await subject.fetchNutritionRecall(
              taskId: pending.taskId,
              periodId: pending.periodId,
              studyDaySnapshot: pending.studyDaySnapshot,
            );
            if (remote != null) {
              subject.applySavedProgress(remote);
              canonical = _findCompletedRecall(subject, pending) ?? remote;
            }
          } catch (error) {
            if (isRetryableError(error)) {
              needsRetry = true;
              continue;
            }
            StudyULogger.warning(
              'Could not check the outcome of an earlier nutrition upload: $error',
            );
            continue;
          }
        }
        final canonicalRecall = canonical?.result.result as DailyRecall?;
        if (canonical != null && pending.canAcknowledge(canonical)) {
          final remaining = await recoverSavedUpload(
            pending: pending,
            saved: canonical,
          );
          if (remaining == null) continue;
          pending = remaining;
        }
        if (pending.stagedUpload == null &&
            canonicalRecall != null &&
            pending.matchesUploadedRecall(canonicalRecall)) {
          try {
            await deletePendingRecall(pending);
          } catch (error) {
            needsRetry = true;
            StudyULogger.warning(
              'Could not clear a synced nutrition draft: $error',
            );
          }
          continue;
        }

        final target =
            pending.progressCompletedAt == null ||
                canonical?.completedAt != pending.progressCompletedAt
            ? null
            : canonical;
        if (target != null && !pending.canReplace(target)) continue;
        if (pending.progressCompletedAt != null && target == null) continue;

        final existingCompletion =
            (target?.result.result as DailyRecall?)?.entryCompletedAt;
        if (!isPreviousDay &&
            pending.recall.entryCompletedAt == null &&
            existingCompletion == null) {
          continue;
        }
        if (target == null && canonical != null) continue;
        final recall = DailyRecall.fromJson(
          (pending.stagedUpload ?? pending.recall).toJson(),
        )..studyDaySnapshot = pending.studyDaySnapshot;
        if (target == null && pending.stagedUpload == null) {
          recall.date = subject.nutritionDateForStudyDay(
            pending.studyDaySnapshot,
          );
        }
        recall.entryCompletedAt ??=
            existingCompletion ??
            _rolloverCompletionTime(
              recall,
              subject.nutritionDateForStudyDay(pending.studyDaySnapshot),
            );
        recall.lastAutoSavedAt ??= recall.entryCompletedAt;
        try {
          if (_submitter != null) {
            await _submitter(pending, recall);
          } else {
            final prepared =
                pending.stagedUpload ??
                await NutritionFoodRepository(
                  client: client,
                ).prepareRecallForUpload(subjectId: subject.id, recall: recall);
            if (!await stageRecallUpload(pending, prepared)) {
              needsRetry = true;
              continue;
            }
            final saved = await subject.upsertNutritionResult(
              taskId: pending.taskId,
              periodId: pending.periodId,
              recall: prepared,
              completionDateOverride: isPreviousDay
                  ? recall.entryCompletedAt
                  : null,
              interventionIdOverride: pending.interventionId,
              persistenceTarget: target == null
                  ? null
                  : NutritionRecallPersistenceTarget(
                      taskId: target.taskId,
                      periodId: pending.periodId,
                      interventionId: target.interventionId,
                      completedAt: target.completedAt!,
                      studyDaySnapshot: pending.studyDaySnapshot,
                      nutritionRevision: target.nutritionRevision,
                    ),
            );
            await acknowledgeRecallSave(
              saved: saved,
              uploaded: prepared,
              previousRevision: pending.nutritionRevision,
            );
            continue;
          }
          await deletePendingRecall(pending);
        } catch (error) {
          if (isRetryableError(error)) {
            needsRetry = true;
            StudyULogger.warning(
              'Network error while submitting nutrition recall for study day '
              '${pending.studyDaySnapshot}. Will retry later.',
            );
          } else {
            StudyULogger.error(
              'Failed to submit nutrition recall for study day '
              '${pending.studyDaySnapshot}: $error',
            );
          }
        }
      }
      return needsRetry;
    } finally {
      _isSubmitting = false;
    }
  }

  SubjectProgress? _findCompletedRecall(
    StudySubject subject,
    PendingRecall pending,
  ) {
    SubjectProgress? latest;
    for (final progress in subject.resultsFor(pending.taskId)) {
      if (progress.resultType != 'DailyRecall' ||
          progress.result.periodId != pending.periodId ||
          progress.completedAt == null ||
          progress.interventionId != pending.interventionId) {
        continue;
      }
      final recall = progress.result.result;
      if (recall is DailyRecall &&
          recall.entryCompletedAt != null &&
          recall.studyDaySnapshot == pending.studyDaySnapshot &&
          (latest == null ||
              progress.nutritionRevision > latest.nutritionRevision)) {
        latest = progress;
      }
    }
    return latest;
  }

  DateTime _rolloverCompletionTime(DailyRecall recall, DateTime dayStart) {
    final dayEnd = dayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));
    final completionCandidate =
        recall.lastAutoSavedAt ?? recall.entryStartedAt ?? DateTime.now();
    return completionCandidate.isBefore(dayStart)
        ? dayStart
        : completionCandidate.isAfter(dayEnd)
        ? dayEnd
        : completionCandidate;
  }

  String _identity(String taskId, String periodId, int studyDay) =>
      '$taskId\u0000$periodId\u0000$studyDay';
}

class PendingRecall({
  required final DailyRecall recall,
  required final String subjectId,
  required final String taskId,
  required final String interventionId,
  required final String periodId,
  required final int studyDaySnapshot,
  required final String lastModifiedAt,
  final DateTime? progressCompletedAt,
  final int? nutritionRevision,
  final DailyRecall? stagedUpload,
  final int? stagedBaseRevision,
  required final String storageKey,
}) {
  DateTime get lastModifiedAtDate =>
      DateTime.tryParse(lastModifiedAt) ??
      DateTime.fromMillisecondsSinceEpoch(0);

  bool matchesUploadedRecall(DailyRecall uploaded) =>
      _sameRecallPayload(recall, uploaded, normalizeUploadFields: true);

  bool canAcknowledge(SubjectProgress progress, {bool allowMovedRow = false}) {
    final staged = stagedUpload;
    final saved = progress.result.result;
    if (staged == null ||
        saved is! DailyRecall ||
        progress.subjectId != subjectId ||
        progress.taskId != taskId ||
        progress.result.periodId != periodId ||
        progress.interventionId != interventionId ||
        saved.studyDaySnapshot != studyDaySnapshot ||
        !_sameRecallPayload(staged, saved)) {
      return false;
    }
    final base = stagedBaseRevision;
    if (nutritionRevision != base) return false;
    return base == null
        ? progress.nutritionRevision == 0
        : (allowMovedRow || progress.completedAt == progressCompletedAt) &&
              (progress.nutritionRevision == base ||
                  progress.nutritionRevision == base + 1);
  }

  bool canReplace(SubjectProgress progress) {
    final canonical = progress.result.result as DailyRecall;
    if (recall.id != canonical.id) return false;
    return nutritionRevision == progress.nutritionRevision &&
        progressCompletedAt == progress.completedAt &&
        periodId == progress.result.periodId &&
        studyDaySnapshot == canonical.studyDaySnapshot &&
        !matchesUploadedRecall(canonical);
  }
}

// Uploads may finalise a draft and update food linkage. Retain all other data
// from the editable snapshot when checking whether it changed during upload.
bool _sameRecallPayload(
  DailyRecall left,
  DailyRecall right, {
  bool normalizeUploadFields = false,
}) {
  if (left.id != right.id) return false;
  final leftJson = left.toJson();
  final rightJson = right.toJson();
  if (normalizeUploadFields) {
    leftJson['entryCompletedAt'] ??= rightJson['entryCompletedAt'];
  }
  return const DeepCollectionEquality().equals(leftJson, rightJson);
}
