import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/study_withdrawal_cleanup.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase/supabase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  const notificationsChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const pending = StudyWithdrawalCleanup(
    subjectId: 'withdrawn-subject',
    studyId: 'study',
    userId: 'participant',
  );
  const sessionToken = 'participant-token';
  const participant = {
    'id': 'participant',
    'app_metadata': <String, dynamic>{},
  };
  late Map<String, String> storage;
  late List<String> requests;
  late String? failingDeleteKey;
  late bool subjectExists;
  late bool rejectIdentity;
  late bool rejectSubjectRead;

  Future<void> saveDraft(String subjectId) =>
      NutritionRecallAutoSaveManager().saveRecall(
        recall: DailyRecall(
          id: 'recall',
          date: DateTime.utc(2026, 11, 20),
          meals: [],
          recallMode: RecallMode.realtimeRecord,
        ),
        subjectId: subjectId,
        taskId: 'task',
        interventionId: 'intervention',
        periodId: 'period',
        studyDaySnapshot: 0,
      );

  setUpAll(() async {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    final supabaseClient = SupabaseClient(
      'http://localhost',
      'test-key',
      httpClient: MockClient((request) async {
        requests.add(request.url.path);
        expect(request.headers['authorization'], 'Bearer $sessionToken');
        final int status;
        final Object body;
        switch (request.url.path) {
          case '/auth/v1/user':
            status = rejectIdentity ? 401 : 200;
            body = rejectIdentity
                ? {'message': 'Invalid token', 'code': 'bad_jwt'}
                : participant;
          case '/rest/v1/study_subject':
            expect(request.url.queryParameters, {
              'id': 'eq.withdrawn-subject',
              'user_id': 'eq.participant',
              'select': 'id',
            });
            status = rejectSubjectRead ? 403 : 200;
            body = rejectSubjectRead
                ? {'message': 'Access denied', 'code': '42501'}
                : [
                    if (subjectExists) {'id': pending.subjectId},
                  ];
          default:
            throw StateError('Unexpected request');
        }
        return http.Response(
          jsonEncode(body),
          status,
          headers: const {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
    setEnv('http://localhost', 'test-key', supabaseClient: supabaseClient);
    addTearDown(supabaseClient.dispose);
    await supabaseClient.auth.recoverSession(
      jsonEncode({
        'access_token': sessionToken,
        'token_type': 'bearer',
        'user': participant,
      }),
    );
  });

  setUp(() {
    requests = [];
    subjectExists = false;
    rejectIdentity = false;
    rejectSubjectRead = false;
    failingDeleteKey = null;
    storage = {
      selectedSubjectIdKey: pending.subjectId,
      cacheSubjectKey: 'cached subject data',
      userEmailKey: 'participant@example.test',
      userPasswordKey: 'fake password',
      'fitbit_credentials_study': 'credentials',
    };

    messenger.setMockMethodCallHandler(storageChannel, (call) async {
      final arguments = call.arguments as Map<Object?, Object?>;
      final key = arguments['key']! as String;
      return switch (call.method) {
        'read' => storage[key],
        'containsKey' => storage.containsKey(key),
        'write' => storage[key] = arguments['value']! as String,
        'delete' when key == failingDeleteKey => throw PlatformException(
          code: 'test cleanup failure',
        ),
        'delete' => storage.remove(key),
        _ => throw MissingPluginException(call.method),
      };
    });
    messenger.setMockMethodCallHandler(notificationsChannel, (_) async => null);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(storageChannel, null);
    messenger.setMockMethodCallHandler(notificationsChannel, null);
  });

  test(
    'uses the verified participant session to check subject presence',
    () async {
      await pending.record();
      final restored = (await StudyWithdrawalCleanup.load())!;
      expect(restored.confirmed, isFalse);
      expect(await restored.remoteSubjectExists(), isFalse);
      expect(requests, ['/auth/v1/user', '/rest/v1/study_subject']);

      subjectExists = true;
      expect(await restored.remoteSubjectExists(), isTrue);
    },
  );

  test('never uses a different account to confirm absence', () async {
    const other = StudyWithdrawalCleanup(
      subjectId: 'withdrawn-subject',
      studyId: 'study',
      userId: 'other-participant',
    );
    expect(await other.remoteSubjectExists(), isNull);
    expect(requests, isEmpty);
  });

  test('propagates authentication and subject read failures', () async {
    rejectIdentity = true;
    await expectLater(
      pending.remoteSubjectExists(),
      throwsA(isA<AuthException>()),
    );
    expect(requests, ['/auth/v1/user']);

    rejectIdentity = false;
    rejectSubjectRead = true;
    await expectLater(
      pending.remoteSubjectExists(),
      throwsA(isA<PostgrestException>()),
    );
  });

  test('resumes confirmed cleanup after a failed local delete', () async {
    const otherSubjectId = 'other-subject';
    const draftKey = 'studyu_nutrition_drafts_v1_withdrawn-subject';
    const otherDraftKey = 'studyu_nutrition_drafts_v1_$otherSubjectId';
    await saveDraft(pending.subjectId);
    await saveDraft(otherSubjectId);
    final confirmed = await pending.confirm();
    final subject = StudySubject(
      pending.subjectId,
      pending.studyId,
      pending.userId,
      [],
    )..study = Study(pending.studyId, 'researcher');
    final state = AppState()..activeSubject = subject;
    addTearDown(state.dispose);

    failingDeleteKey = cacheSubjectKey;
    await expectLater(
      confirmed.clearStudyData(state),
      throwsA(isA<PlatformException>()),
    );
    expect(storage, contains(cacheSubjectKey));
    expect(storage, isNot(contains(draftKey)));
    expect(storage, isNot(contains(selectedSubjectIdKey)));
    final restored = (await StudyWithdrawalCleanup.load())!;
    expect(restored.confirmed, isTrue);

    failingDeleteKey = null;
    await restored.clearStudyData(state);
    expect(await StudyWithdrawalCleanup.load(), isNull);
    expect(state.activeSubject, isNull);
    expect(requests, isEmpty);

    await saveDraft(subject.id);
    await Cache.storeSubject(subject);
    expect(storage.keys, [otherDraftKey]);
  });
}
