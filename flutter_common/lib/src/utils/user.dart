import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
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
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
    }
  }
  return false;
}

Future<bool> ensureParticipantSignedIn({
  bool Function()? isSignedIn,
  Future<bool> Function()? signIn,
  Future<bool> Function()? signUp,
}) async {
  if ((isSignedIn ?? isUserLoggedIn)()) return true;
  if (await (signIn ?? signInParticipant)()) return true;
  return await (signUp ?? anonymousSignUp)();
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
  await SecureStorage.delete(userEmailKey);
  await SecureStorage.delete(userPasswordKey);
  await SecureStorage.delete(selectedSubjectIdKey);
  await SecureStorage.delete(cacheSubjectKey);
}

void previewSubjectIdKey() {
  selectedSubjectIdKey = 'preview_$selectedSubjectIdKey';
}
