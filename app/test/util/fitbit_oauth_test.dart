import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyu_app/models/deferred_fitbit_request.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};
  late Study study;
  setUp(() {
    storage.clear();
    study = Study('study', 'user')
      ..fitbitCredentials = StudyFitbitCredentials(
        'study',
        FitbitAuthCredentials(clientId: 'client', clientSecret: 'secret'),
      )
      ..observations = [
        QuestionnaireTask.withId()
          ..questions.questions = [
            FitbitQuestion.withId(
              questionType: FitbitQuestion.questionType,
              types: [FitbitQuestionType.steps],
            ),
          ],
      ];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          final args = call.arguments as Map<Object?, Object?>;
          final key = args['key'] as String?;
          return switch (call.method) {
            'read' => storage[key],
            'containsKey' => storage.containsKey(key),
            'write' => storage[key!] = args['value']! as String,
            'delete' => storage.remove(key),
            _ => null,
          };
        });
  });
  tearDown(() {
    FitbitHandler.debugAuthHttpClient?.close();
    FitbitHandler.debugAuthHttpClient = null;
    FitbitHandler.debugAuthorizeBrowserOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  test(
    'an introspection outage preserves device tokens and does not prompt OAuth',
    () async {
      final existing = jsonEncode({
        'userID': 'fitbit-user',
        'fitbitAccessToken': 'old-access',
        'fitbitRefreshToken': 'old-refresh',
      });
      storage['fitbit_credentials_study'] = existing;
      FitbitHandler.debugAuthorizeBrowserOverride = (_, _) async =>
          fail('must not prompt OAuth for a transport failure');
      FitbitHandler.debugAuthHttpClient = MockClient(
        (request) async => throw http.ClientException('Failed to fetch'),
      );
      await expectLater(
        FitbitHandler.authorizeForOfflineParticipation(study),
        throwsA(isA<http.ClientException>()),
      );
      expect(storage['fitbit_credentials_study'], existing);
    },
  );
  for (final status in [200, 401, 503]) {
    test(
      'OAuth code exchange distinguishes HTTP $status without logging or uploading device tokens',
      () async {
        FitbitHandler.debugAuthorizeBrowserOverride = (url, _) async {
          final state = Uri.parse(url).queryParameters['state'];
          expect(state, isNotEmpty);
          return Uri(
            scheme: 'studyu',
            host: 'callback',
            queryParameters: {'code': 'code', 'state': state},
          ).toString();
        };
        FitbitHandler.debugAuthHttpClient = MockClient((request) async {
          expect(request.url.host, 'api.fitbit.com');
          expect(request.body, contains('grant_type=authorization_code'));
          return http.Response(
            jsonEncode({
              'user_id': 'fitbit-user',
              'access_token': 'access',
              'refresh_token': 'refresh',
            }),
            status,
          );
        });
        if (status == 503) {
          await expectLater(
            FitbitHandler.authorizeForOfflineParticipation(study),
            throwsA(
              predicate((Object e) => connectionStatusFromError(e) != null),
            ),
          );
        } else {
          expect(
            await FitbitHandler.authorizeForOfflineParticipation(study),
            status == 200,
          );
        }
        expect(
          storage.keys,
          status == 200 ? ['fitbit_credentials_study'] : isEmpty,
        );
      },
    );
  }
  for (final status in [200, 503]) {
    test(
      'expired token refresh HTTP $status preserves transport errors and device-only persistence',
      () async {
        final existing = jsonEncode({
          'userID': 'fitbit-user',
          'fitbitAccessToken': 'old-access',
          'fitbitRefreshToken': 'old-refresh',
        });
        storage['fitbit_credentials_study'] = existing;
        FitbitHandler.debugAuthorizeBrowserOverride = (_, _) async =>
            fail('must not prompt OAuth');
        var requests = 0;
        FitbitHandler.debugAuthHttpClient = MockClient((request) async {
          requests++;
          if (requests == 1) return http.Response('{}', 401);
          expect(request.body, contains('grant_type=refresh_token'));
          return http.Response(
            jsonEncode({
              'access_token': 'new-access',
              'refresh_token': 'new-refresh',
            }),
            status,
          );
        });
        if (status == 503) {
          await expectLater(
            FitbitHandler.authorizeForOfflineParticipation(study),
            throwsA(isA<http.ClientException>()),
          );
          expect(storage['fitbit_credentials_study'], existing);
        } else {
          expect(
            await FitbitHandler.authorizeForOfflineParticipation(study),
            isTrue,
          );
          expect(
            (jsonDecode(storage['fitbit_credentials_study']!)
                as Map<String, dynamic>)['fitbitAccessToken'],
            'new-access',
          );
        }
        expect(requests, 2);
      },
    );
  }
  for (final type in FitbitQuestionType.values) {
    test(
      'real $type data-manager path uses one durable validation and resolves empty data',
      () async {
        final question =
            (study.observations.single as QuestionnaireTask)
                    .questions
                    .questions
                    .single
                as FitbitQuestion;
        question.types = [type];
        storage['fitbit_credentials_study'] = jsonEncode({
          'userID': 'fitbit-user',
          'fitbitAccessToken': 'access',
          'fitbitRefreshToken': 'refresh',
        });
        var validations = 0;
        var fetches = 0;
        FitbitHandler.debugAuthHttpClient = MockClient((request) async {
          if (request.method == 'POST') {
            validations++;
            return http.Response('{"active":true}', 200);
          }
          fetches++;
          expect(request.headers['Authorization'], 'Bearer access');
          final body = switch (type) {
            FitbitQuestionType.sleep => {'sleep': <Object>[]},
            FitbitQuestionType.steps => {
              'activities-steps': [
                {'dateTime': '2026-03-05'},
              ],
              'activities-steps-intraday': {'dataset': <Object>[]},
            },
            FitbitQuestionType.heartrate => {
              'activities-heart': [
                {'dateTime': '2026-03-05'},
              ],
              'activities-heart-intraday': {'dataset': <Object>[]},
            },
          };
          return http.Response(jsonEncode(body), 200);
        });
        final subject = StudySubject.fromStudy(study, 'user', [], null);
        final time = DateTime(2026, 3, 5, 12);
        final request = DeferredFitbitRequest(
          subjectId: subject.id,
          interventionId: 'intervention',
          taskId: study.observations.single.id,
          periodId: 'period',
          questionId: question.id,
          windowStart: DateTime(2026, 3, 5).toUtc(),
          windowEnd: time.toUtc(),
          completedAt: time.toUtc(),
        );
        expect(
          await FitbitHandler.resolveDeferredRequest(
            subject,
            request,
            question,
          ),
          isEmpty,
        );
        expect(validations, 1);
        expect(fetches, 1);
      },
    );
  }
  for (final status in [0, 503, 401]) {
    test(
      'real data GET HTTP $status preserves transport versus authorization failure',
      () async {
        final question =
            (study.observations.single as QuestionnaireTask)
                    .questions
                    .questions
                    .single
                as FitbitQuestion;
        storage['fitbit_credentials_study'] = jsonEncode({
          'userID': 'fitbit-user',
          'fitbitAccessToken': 'access',
          'fitbitRefreshToken': 'refresh',
        });
        FitbitHandler.debugAuthHttpClient = MockClient((request) async {
          if (request.method == 'POST') {
            return http.Response('{"active":true}', 200);
          }
          if (status == 0) throw http.ClientException('Failed to fetch');
          return http.Response('{}', status);
        });
        final subject = StudySubject.fromStudy(study, 'user', [], null);
        await expectLater(
          FitbitHandler.syncFitbitData(
            study,
            question,
            study.observations.single.id,
            subject,
          ),
          throwsA(
            predicate(
              (Object error) => status == 401
                  ? connectionStatusFromError(error) == null
                  : connectionStatusFromError(error) != null,
            ),
          ),
        );
      },
    );
  }
  test('mismatched OAuth state cannot exchange or store credentials', () async {
    FitbitHandler.debugAuthorizeBrowserOverride = (_, _) async =>
        'studyu://callback?code=code&state=wrong';
    FitbitHandler.debugAuthHttpClient = MockClient(
      (_) async => fail('must not exchange a mismatched state'),
    );
    expect(
      await FitbitHandler.authorizeForOfflineParticipation(study),
      isFalse,
    );
    expect(storage, isEmpty);
  });
}
