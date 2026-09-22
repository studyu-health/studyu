import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/debug_mode.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class Cache() {
  static bool isSynchronizing = false;

  static Future<void> storeSubject(StudySubject? subject) async {
    // debugPrint("Store subject in cache");
    if (subject == null) return;
    SecureStorage.write(cacheSubjectKey, jsonEncode(subject.toFullJson()));
    assert(subject == (await loadSubject()));
  }

  static Future<StudySubject> loadSubject({StudySubject? backupSubject}) async {
    // debugPrint("Load subject from cache");
    if (await SecureStorage.containsKey(cacheSubjectKey)) {
      final cachedSubjectStr = await SecureStorage.read(cacheSubjectKey);
      final cachedSubject =
          jsonDecode(cachedSubjectStr!) as Map<String, dynamic>;
      try {
        return StudySubject.fromJson(cachedSubject);
      } catch (e) {
        StudyULogger.warning(
          "Failed to parse cached subject: $cachedSubjectStr",
        );
        if (backupSubject != null) {
          // Only take progress from cached subject and rest from backup,
          // as the cached subject might be outdated or corrupted

          // compare IDs to make sure we are not mixing up subjects
          // If IDs do not match we should not use the cached subject
          if (backupSubject.id != cachedSubject['id']) {
            throw Exception(
              "Cached subject ID does not match remote subject ID",
            );
          }
          final cachedProgress = (cachedSubject['progress'] as List?)
              ?.map((e) => SubjectProgress.fromJson(e as Map<String, dynamic>))
              .toList();
          backupSubject.progress = cachedProgress ?? backupSubject.progress;
          return backupSubject;
        }
        throw Exception("No backup subject provided");
      }
    } else {
      throw Exception("No cached subject found");
    }
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
    // No local subject found
    if (!(await SecureStorage.containsKey(cacheSubjectKey))) {
      return remoteSubject;
    }
    final localSubject = await loadSubject(backupSubject: remoteSubject);
    // local and remote subject are equal, nothing to synchronize
    if (localSubject == remoteSubject) return remoteSubject;
    // remote subject belongs to a different study
    if (!isDebugMode &&
        remoteSubject.startedAt!.isAfter(localSubject.startedAt!)) {
      return remoteSubject;
    }

    debugPrint("Synchronize subject with cache");
    isSynchronizing = true;

    try {
      await uploadBlobFiles();

      // only minimal update
      // Check if progress has changed
      if (localSubject.progress.length != remoteSubject.progress.length) {
        StudyULogger.info("Cache synchronization: Merging progress");
        /*if (remoteSubject.progress.isNotEmpty) {
        // sort remote progress list from oldest to newest
        remoteSubject.progress.sort((a, b) =>
            a.completedAt.compareTo(b.completedAt));
        // merge all local progress older than the latest remote progress to remote subject and upload
        newProgress = localSubject.progress.where((element) =>
            element.completedAt.isAfter(remoteSubject.progress.last.completedAt)
        ).toList();
      } else {
        newProgress = localSubject.progress;
      }*/
        // save new progress
        final List<SubjectProgress> newProgress = [
          ...localSubject.progress,
          ...remoteSubject.progress,
        ];
        newProgress.removeWhere(
          (element) =>
              localSubject.progress.contains(element) &&
              remoteSubject.progress.contains(element),
        );
        for (final p in newProgress) {
          await p.save();
        }

        // merge local and remote progress and remove duplicates
        final List<SubjectProgress> finalProgress = [
          ...localSubject.progress,
          ...remoteSubject.progress,
        ];
        final duplicates = <DateTime?>{};
        finalProgress.retainWhere(
          (element) => duplicates.add(element.completedAt),
        );
        // replace remote progress with our merge
        remoteSubject.progress = finalProgress;
        await remoteSubject.save(onlyUpdate: true);
      } else {
        // Unable to determine what has changed
        // We can either drop local or overwrite remote
        // ... for now do nothing
        if (!isDebugMode && localSubject.startedAt == remoteSubject.startedAt) {
          StudyULogger.fatal(
            "Cache synchronization found local changes that cannot be merged",
          );
          StudyULogger.error(
            "localSubject: ${localSubject.toFullJson()} \nremoteSubject: ${remoteSubject.toFullJson()}",
          );
        }
      }
    } catch (exception) {
      StudyULogger.warning(exception);
    }
    isSynchronizing = false;
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
