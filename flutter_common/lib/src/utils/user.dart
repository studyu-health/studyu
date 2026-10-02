import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';
import 'package:studyu_flutter_common/src/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const fakeStudyUEmailDomain = 'fake-studyu-email-domain.com';
String selectedSubjectIdKey = 'selected_study_object_id';
const userEmailKey = 'user_email';
const userPasswordKey = 'user_password';
const cacheSubjectKey = "cache_subject";

Future<void> storeFakeUserEmailAndPassword(
  String email,
  String password,
) async {
  await SecureStorage.write(userEmailKey, email);
  await SecureStorage.write(userPasswordKey, password);
}

Future<void> clearParticipantCredentials() async {
  await SecureStorage.delete(userEmailKey);
  await SecureStorage.delete(userPasswordKey);
}

Future<void> clearParticipantSession() async {
  await Supabase.instance.client.auth.signOut();
}

bool isInvalidParticipantSessionError(AuthException error) {
  return error is AuthInvalidJwtException ||
      error is AuthSessionMissingException ||
      error.statusCode == '401' ||
      error.statusCode == '403' ||
      error.statusCode == '404' ||
      error.code == 'invalid_jwt';
}

bool hasDegradedConnectionStatus() {
  return appConnectionStatusController.status != AppConnectionStatus.healthy;
}

bool shouldAttemptParticipantAuthRecovery(Object error) {
  return connectionStatusFromError(error) == null;
}

Future<bool> isParticipantSessionValid() async {
  if (!isUserLoggedIn()) return false;
  try {
    await Supabase.instance.client.auth.getUser();
    return true;
  } on AuthException catch (error, stacktrace) {
    if (isInvalidParticipantSessionError(error)) {
      return false;
    }
    SupabaseQuery.catchSupabaseException(error, stacktrace);
    rethrow;
  } catch (error, stacktrace) {
    SupabaseQuery.catchSupabaseException(error, stacktrace);
    rethrow;
  }
}

Future<bool> signInParticipant() async {
  final hasEmail = await SecureStorage.containsKey(userEmailKey);
  final hasPassword = await SecureStorage.containsKey(userPasswordKey);
  if (hasEmail && hasPassword) {
    try {
      final fakeEmail = await getFakeUserEmail();
      final fakePassword = await getFakeUserPassword();
      final authResponse = await Supabase.instance.client.auth
          .signInWithPassword(email: fakeEmail, password: fakePassword!);
      return authResponse.session != null;
    } on AuthApiException catch (error, stacktrace) {
      if (error.code == 'invalid_credentials') {
        await clearParticipantCredentials();
        return false;
      }
      SupabaseQuery.catchSupabaseException(error, stacktrace);
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
    }
  }
  return false;
}

Future<HealthyConnectionRecoveryResult> recoverSessionAfterDegradedStartup({
  bool Function()? isSignedIn,
  Future<String?> Function()? loadPersistedSession,
  Future<void> Function(String session)? recoverPersistedSession,
  Future<bool> Function()? hasStoredCredentials,
  Future<bool> Function()? signIn,
}) async {
  final currentStatus = isSignedIn ?? isUserLoggedIn;
  final credentialsAvailable =
      hasStoredCredentials ??
      () async =>
          await SecureStorage.containsKey(userEmailKey) &&
          await SecureStorage.containsKey(userPasswordKey);
  if (currentStatus()) return HealthyConnectionRecoveryResult.completed;

  var retryNeeded = false;
  try {
    final persistedSession =
        await (loadPersistedSession ??
            () => SecureStorage.read(supabasePersistSessionKey))();
    if (persistedSession != null) {
      await (recoverPersistedSession ??
          (session) async {
            await Supabase.instance.client.auth.recoverSession(session);
          })(persistedSession);
      retryNeeded = !currentStatus();
    }
  } catch (error) {
    retryNeeded = true;
    StudyULogger.warning('Could not recover the persisted session: $error');
  }

  if (currentStatus()) return HealthyConnectionRecoveryResult.completed;

  try {
    if (!await credentialsAvailable()) {
      return retryNeeded
          ? HealthyConnectionRecoveryResult.retryNeeded
          : HealthyConnectionRecoveryResult.completed;
    }
    if (await (signIn ?? signInParticipant)() || currentStatus()) {
      return HealthyConnectionRecoveryResult.completed;
    }
    return await credentialsAvailable()
        ? HealthyConnectionRecoveryResult.retryNeeded
        : HealthyConnectionRecoveryResult.completed;
  } catch (error) {
    StudyULogger.warning(
      'Could not recover participant credentials after reconnecting: $error',
    );
    return HealthyConnectionRecoveryResult.retryNeeded;
  }
}

Future<bool> ensureParticipantSignedIn({
  bool Function()? isSignedIn,
  Future<bool> Function()? validateSession,
  Future<void> Function()? clearSession,
  Future<bool> Function()? signIn,
  Future<bool> Function()? signUp,
}) async {
  final currentStatus = isSignedIn ?? isUserLoggedIn;

  if (hasDegradedConnectionStatus()) {
    return currentStatus();
  }

  if (currentStatus()) {
    try {
      if (await (validateSession ?? isParticipantSessionValid)()) return true;
      await (clearSession ?? clearParticipantSession)();
    } catch (error) {
      final status = connectionStatusFromError(error);
      if (status != null) {
        appConnectionStatusController.setStatus(status);
        return false;
      }
      rethrow;
    }
  }

  try {
    if (await (signIn ?? signInParticipant)()) return true;
  } catch (error) {
    final status = connectionStatusFromError(error);
    if (status != null) {
      appConnectionStatusController.setStatus(status);
      return false;
    }
    rethrow;
  }

  try {
    return await (signUp ?? anonymousSignUp)();
  } catch (error) {
    final status = connectionStatusFromError(error);
    if (status != null) {
      appConnectionStatusController.setStatus(status);
      return false;
    }
    rethrow;
  }
}

// Using a fake user email to enable anonymous users, while working with row-level security on postgres
Future<bool> anonymousSignUp() async {
  if (await signInParticipant()) return true;
  final fakeUserEmail = '${const Uuid().v4()}@$fakeStudyUEmailDomain';
  final fakeUserPassword = const Uuid().v4();
  try {
    final authResponse = await Supabase.instance.client.auth.signUp(
      email: fakeUserEmail,
      password: fakeUserPassword,
    );
    await storeFakeUserEmailAndPassword(fakeUserEmail, fakeUserPassword);
    return authResponse.session != null || await signInParticipant();
  } catch (error, stacktrace) {
    SupabaseQuery.catchSupabaseException(error, stacktrace);
    return false;
  }
}

Future<String?> getFakeUserEmail() async {
  return await SecureStorage.read(userEmailKey);
}

Future<String?> getFakeUserPassword() async {
  return await SecureStorage.read(userPasswordKey);
}

bool isUserLoggedIn() {
  return Supabase.instance.client.auth.currentSession != null;
}

Future<String?> getActiveSubjectId() async {
  return await SecureStorage.read(selectedSubjectIdKey);
}

Future<void> storeActiveSubjectId(String studyObjectId) async {
  await SecureStorage.write(selectedSubjectIdKey, studyObjectId);
}

Future<void> deleteActiveStudyReference() async {
  await SecureStorage.delete(selectedSubjectIdKey);
}

Future<void> deleteLocalData() async {
  await clearParticipantCredentials();
  await SecureStorage.delete(selectedSubjectIdKey);
  await SecureStorage.delete(cacheSubjectKey);
}

void previewSubjectIdKey() {
  selectedSubjectIdKey = 'preview_$selectedSubjectIdKey';
}
