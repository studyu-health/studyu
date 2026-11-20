import 'dart:convert';

import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const StudyWithdrawalCleanup({
  required final String subjectId,
  required final String studyId,
  required final String userId,
  final bool confirmed = false,
}) {
  static const _key = 'pending_study_withdrawal';

  static Future<StudyWithdrawalCleanup?> load() async {
    final stored = await SecureStorage.read(_key);
    if (stored == null) return null;
    final data = jsonDecode(stored) as Map<String, dynamic>;
    return StudyWithdrawalCleanup(
      subjectId: data['subjectId'] as String,
      studyId: data['studyId'] as String,
      userId: data['userId'] as String,
      confirmed: data['confirmed'] as bool,
    );
  }

  Future<void> record() => SecureStorage.write(
    _key,
    jsonEncode({
      'subjectId': subjectId,
      'studyId': studyId,
      'userId': userId,
      'confirmed': confirmed,
    }),
  );

  /// Returns null if the app cannot verify the participant's identity.
  Future<bool?> remoteSubjectExists() async {
    if (client.auth.currentUser?.id != userId) return null;
    final session = await client.auth.getSession();
    if (session == null || session.user.id != userId) return null;
    final token = session.accessToken;
    final response = await client.auth.getUser(token);
    if (response.user?.id != userId) return null;
    final subject = await client
        .from(StudySubject.tableName)
        .select('id')
        .eq('id', subjectId)
        .eq('user_id', userId)
        .setHeader('Authorization', 'Bearer $token')
        .maybeSingle();
    if (client.auth.currentUser?.id != userId) return null;
    return subject != null;
  }

  Future<StudyWithdrawalCleanup> confirm() async {
    final pending = StudyWithdrawalCleanup(
      subjectId: subjectId,
      studyId: studyId,
      userId: userId,
      confirmed: true,
    );
    await pending.record();
    return pending;
  }

  Future<void> clearStudyData(AppState state) async {
    assert(confirmed);
    Cache.invalidateSubject(subjectId);
    await NutritionRecallAutoSaveManager().deleteSubjectDrafts(subjectId);
    final activeSubjectId = await getActiveSubjectId();
    final inMemorySubjectId = state.activeSubject?.id;
    if ((activeSubjectId == null || activeSubjectId == subjectId) &&
        (inMemorySubjectId == null || inMemorySubjectId == subjectId)) {
      RestoreAccountService.clearCache();
      await FitbitHandler.deleteFitbitCredentials(studyId);
      await deleteLocalData();
      await cancelNotificationsForAppState(state);
      state.clearAccountState();
    }
    await finish();
  }

  Future<void> finish() => SecureStorage.delete(_key);
}
