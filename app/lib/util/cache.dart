import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class Cache() {
  static bool isSynchronizing = false;
  static final _invalidatedSubjectIds = <String>{};

  /// Secure storage queues writes that already started before deletion.
  static void invalidateSubject(String subjectId) {
    _invalidatedSubjectIds.add(subjectId);
  }

  static Future<void> storeSubject(StudySubject? subject) async {
    // debugPrint("Store subject in cache");
    if (subject == null || _invalidatedSubjectIds.contains(subject.id)) return;
    await SecureStorage.write(
      cacheSubjectKey,
      jsonEncode(subject.toFullJson()),
    );
  }

  static Future<StudySubject> loadSubject({StudySubject? backupSubject}) async {
    final stored = await SecureStorage.read(cacheSubjectKey);
    if (stored == null) throw Exception('No cached subject found');

    final Map<String, dynamic> cachedSubject;
    try {
      cachedSubject = jsonDecode(stored) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Could not decode the cached subject.');
    }

    try {
      return StudySubject.fromJson(cachedSubject);
    } catch (_) {
      StudyULogger.warning('Could not parse the cached subject.');
    }

    if (backupSubject == null) throw Exception('No backup subject provided');
    if (backupSubject.id != cachedSubject['id']) {
      throw Exception('Cached subject ID does not match remote subject ID');
    }

    try {
      final cachedProgress = (cachedSubject['progress'] as List?)
          ?.map((e) => SubjectProgress.fromJson(e as Map<String, dynamic>))
          .toList();
      backupSubject.progress = cachedProgress ?? backupSubject.progress;
    } catch (_) {
      throw const FormatException('Could not decode cached subject progress.');
    }
    return backupSubject;
  }

  static Future<void> storeAnalytics(StudyUAnalytics analytics) async {
    SecureStorage.write(
      StudyUAnalytics.keyStudyUAnalytics,
      jsonEncode(analytics.toJson()),
    );
  }

  static Future<StudyUAnalytics?> loadAnalytics() async {
    try {
      if (await SecureStorage.containsKey(StudyUAnalytics.keyStudyUAnalytics)) {
        final analyticsData = await SecureStorage.read(
          StudyUAnalytics.keyStudyUAnalytics,
        );
        if (analyticsData != null) {
          return StudyUAnalytics.fromJson(
            jsonDecode(analyticsData) as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      StudyULogger.warning("Failed to load analytics from cache: $e");
    }
    return null;
  }

  static Future<void> delete() {
    StudyULogger.warning("Delete cache");
    return SecureStorage.delete(cacheSubjectKey);
  }

  static Future<void> uploadBlobFiles() async {
    final blobStorageHandler = BlobStorageHandler();
    final futureBlobFiles = await TemporaryStorageHandler.getFutureBlobFiles();
    for (final futureBlobFile in futureBlobFiles) {
      await blobStorageHandler.uploadObservation(
        futureBlobFile.futureBlobId,
        File(futureBlobFile.localFilePath),
      );
      await File(futureBlobFile.localFilePath).delete();
    }
  }

  static Future<StudySubject> synchronize(StudySubject remoteSubject) async {
    if (isSynchronizing) return remoteSubject;
    isSynchronizing = true;

    try {
      if (!await SecureStorage.containsKey(cacheSubjectKey)) {
        return remoteSubject;
      }
      final localSubject = await loadSubject(backupSubject: remoteSubject);
      if (localSubject.id != remoteSubject.id ||
          localSubject.startedAt?.toUtc() != remoteSubject.startedAt?.toUtc()) {
        return remoteSubject;
      }

      final savedTimes = remoteSubject.progress
          .map((progress) => progress.completedAt?.toUtc())
          .toSet();
      final pending = localSubject.progress
          .where(
            (progress) =>
                progress.subjectId == remoteSubject.id &&
                progress.completedAt != null &&
                progress.resultType != 'DailyRecall' &&
                !savedTimes.contains(progress.completedAt!.toUtc()),
          )
          .toList();
      if (pending.isEmpty) {
        if (localSubject != remoteSubject) await storeSubject(remoteSubject);
        return remoteSubject;
      }

      if (!kIsWeb) await uploadBlobFiles();
      var allSaved = true;
      for (final progress in pending) {
        final completedAt = progress.completedAt!.toUtc();
        if (savedTimes.contains(completedAt)) continue;
        try {
          remoteSubject.progress.add(await progress.save());
          savedTimes.add(completedAt);
        } catch (error) {
          allSaved = false;
          StudyULogger.warning(error);
        }
      }
      if (allSaved) await storeSubject(remoteSubject);
    } catch (exception) {
      StudyULogger.warning(exception);
    } finally {
      isSynchronizing = false;
    }
    return remoteSubject;
  }

  static Future<String> getCachedUserData() async {
    final debugInfo = StringBuffer();
    debugInfo.writeln('=== Cached User Data Debug Info ===');

    try {
      // Check selected subject ID
      if (await SecureStorage.containsKey('selected_study_object_id')) {
        final selectedSubjectId = await SecureStorage.read(
          'selected_study_object_id',
        );
        debugInfo.writeln('Selected Subject ID: $selectedSubjectId');
      } else {
        debugInfo.writeln('Selected Subject ID: NOT FOUND');
      }

      // Check user email
      if (await SecureStorage.containsKey('user_email')) {
        final userEmail = await SecureStorage.read('user_email');
        debugInfo.writeln('User Email: $userEmail');
      } else {
        debugInfo.writeln('User Email: NOT FOUND');
      }

      // Check cached subject
      if (await SecureStorage.containsKey('cache_subject')) {
        debugInfo.writeln('Cache Subject: EXISTS (data present)');
        try {
          final cachedSubject = await loadSubject();
          debugInfo.writeln('  - Subject ID: ${cachedSubject.id}');
          debugInfo.writeln('  - Study ID: ${cachedSubject.studyId}');
          debugInfo.writeln('  - Started At: ${cachedSubject.startedAt}');
          debugInfo.writeln(
            '  - Progress Count: ${cachedSubject.progress.length}',
          );
        } catch (e) {
          debugInfo.writeln('  - Error loading cached subject: $e');
        }
      } else {
        debugInfo.writeln('Cache Subject: NOT FOUND');
      }

      // Check user password (without revealing the actual password)
      if (await SecureStorage.containsKey('user_password')) {
        debugInfo.writeln('User Password: EXISTS (hidden for security)');
      } else {
        debugInfo.writeln('User Password: NOT FOUND');
      }
    } catch (e) {
      debugInfo.writeln('Error retrieving cached data: $e');
    }

    return debugInfo.toString();
  }
}
