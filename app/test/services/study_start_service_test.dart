import 'dart:io';

import 'package:fitbitter/fitbitter.dart' as fitbitter;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/study_start_service.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  tearDown(() {
    StudyStartService.debugSaveSubjectOverride = null;
    StudyStartService.debugFetchSubjectOverride = null;
    StudyStartService.debugLoadFitbitConfigurationOverride = null;
    FitbitHandler.debugAuthorizeForOfflineParticipationOverride = null;
    FitbitHandler.debugAuthorizeCredentialsOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
    appConnectionStatusController.reset();
  });
  StudySubject subject({bool fitbit = false}) {
    final study = Study('study', 'user')
      ..interventions = [Intervention('intervention', 'Intervention')];
    if (fitbit) {
      study.observations = [
        QuestionnaireTask.withId()
          ..questions.questions = [
            FitbitQuestion.withId(
              questionType: FitbitQuestion.questionType,
              types: [FitbitQuestionType.steps],
            ),
          ],
      ];
    }
    if (fitbit) {
      study.fitbitCredentials = StudyFitbitCredentials(
        study.id,
        FitbitAuthCredentials(clientId: 'client', clientSecret: 'secret'),
      );
    }
    return StudySubject.fromStudy(study, 'user', ['intervention'], null);
  }

  test('ordinary study succeeds without Fitbit authorization', () async {
    final s = subject();
    FitbitHandler.debugAuthorizeForOfflineParticipationOverride = (
      _,
      _,
    ) async => throw StateError('must not authorize');
    StudyStartService.debugSaveSubjectOverride = (s) async => s;
    StudyStartService.debugFetchSubjectOverride = (_) async => s;
    final result = await StudyStartService.createSubject(s);
    expect(result, isA<StudyStartSuccess>());
    expect(s.startedAt, isNotNull);
  });
  test('failed Fitbit authorization prevents subject creation', () async {
    final s = subject(fitbit: true);
    var saved = false;
    FitbitHandler.debugAuthorizeForOfflineParticipationOverride = (
      _,
      _,
    ) async => false;
    StudyStartService.debugSaveSubjectOverride = (s) async {
      saved = true;
      return s;
    };
    expect(
      await StudyStartService.createSubject(s),
      isA<StudyStartFitbitAuthFailed>(),
    );
    expect(saved, isFalse);
    expect(s.startedAt, isNull);
  });
  test('authorization precedes creation and fetch', () async {
    final s = subject(fitbit: true);
    final steps = <String>[];
    FitbitHandler.debugAuthorizeForOfflineParticipationOverride = (_, _) async {
      steps.add('auth');
      return true;
    };
    StudyStartService.debugSaveSubjectOverride = (s) async {
      steps.add('save');
      return s;
    };
    StudyStartService.debugFetchSubjectOverride = (_) async {
      steps.add('fetch');
      return s;
    };
    expect(await StudyStartService.createSubject(s), isA<StudyStartSuccess>());
    expect(steps, ['auth', 'save', 'fetch']);
  });
  test(
    'transport failure returns network result and leaves enrollment retryable',
    () async {
      final s = subject();
      StudyStartService.debugSaveSubjectOverride = (_) async =>
          throw const SocketException('offline');
      expect(
        await StudyStartService.createSubject(s),
        isA<StudyStartNetworkFailed>(),
      );
      expect(s.startedAt, isNull);
      expect(
        appConnectionStatusController.status,
        isNot(AppConnectionStatus.healthy),
      );
    },
  );
  test('enrollment loads eligible Fitbit configuration before authorization and save', () async {
    final s = subject(fitbit: true)..inviteCode = 'invite';
    s.study.fitbitCredentials = null;
    final steps = <String>[];
    StudyStartService.debugLoadFitbitConfigurationOverride = (subject) async {
      expect(subject.inviteCode, 'invite');
      steps.add('configuration');
      return StudyFitbitCredentials(
        subject.studyId,
        FitbitAuthCredentials(clientId: 'client', clientSecret: 'secret'),
      );
    };
    FitbitHandler.debugAuthorizeForOfflineParticipationOverride =
        (study, _) async {
          expect(study.fitbitCredentials, isNotNull);
          steps.add('auth');
          return true;
        };
    StudyStartService.debugSaveSubjectOverride = (s) async {
      steps.add('save');
      return s;
    };
    StudyStartService.debugFetchSubjectOverride = (_) async => s;
    expect(await StudyStartService.createSubject(s), isA<StudyStartSuccess>());
    expect(steps, ['configuration', 'auth', 'save']);
  });
  test(
    'configuration transport failure prevents enrollment and remains retryable',
    () async {
      final s = subject(fitbit: true);
      s.study.fitbitCredentials = null;
      StudyStartService.debugLoadFitbitConfigurationOverride = (_) async =>
          throw const SocketException('offline');
      StudyStartService.debugSaveSubjectOverride = (_) async =>
          fail('must not save');
      expect(
        await StudyStartService.createSubject(s),
        isA<StudyStartNetworkFailed>(),
      );
      expect(s.startedAt, isNull);
    },
  );
  test(
    'ineligible or unconfigured Fitbit enrollment does not authorize or save',
    () async {
      final s = subject(fitbit: true);
      s.study.fitbitCredentials = null;
      StudyStartService.debugLoadFitbitConfigurationOverride = (_) async =>
          null;
      FitbitHandler.debugAuthorizeForOfflineParticipationOverride = (
        _,
        _,
      ) async => fail('must not authorize');
      StudyStartService.debugSaveSubjectOverride = (_) async =>
          fail('must not save');
      expect(
        await StudyStartService.createSubject(s),
        isA<StudyStartFitbitAuthFailed>(),
      );
    },
  );
  test('OAuth transport failures remain distinct from auth refusal', () async {
    final s = subject(fitbit: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (_) async => false);
    FitbitHandler.debugAuthorizeCredentialsOverride = (_, _) async =>
        throw const SocketException('offline');
    StudyStartService.debugSaveSubjectOverride = (_) async =>
        fail('must not save');
    expect(
      await StudyStartService.createSubject(s),
      isA<StudyStartNetworkFailed>(),
    );
  });
  test(
    'OAuth tokens must be stored on the device before subject creation',
    () async {
      final s = subject(fitbit: true);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(storageChannel, (call) async {
            if (call.method == 'write') {
              throw PlatformException(code: 'storage_full');
            }
            return false;
          });
      FitbitHandler.debugAuthorizeCredentialsOverride = (_, _) async =>
          fitbitter.FitbitCredentials(
            userID: 'fitbit-user',
            fitbitAccessToken: 'access-token',
            fitbitRefreshToken: 'refresh-token',
          );
      StudyStartService.debugSaveSubjectOverride = (_) async =>
          fail('must not save');
      expect(
        await StudyStartService.createSubject(s),
        isA<StudyStartGenericFailed>(),
      );
      expect(s.startedAt, isNull);
    },
  );
  test(
    'preview Fitbit enrollment does not load configuration or authorize',
    () async {
      final s = subject(fitbit: true);
      s.study.fitbitCredentials = null;
      StudyStartService.debugLoadFitbitConfigurationOverride = (_) async =>
          fail('preview must not load enrollment configuration');
      FitbitHandler.debugAuthorizeForOfflineParticipationOverride = (
        _,
        _,
      ) async => fail('preview must not authorize');
      StudyStartService.debugSaveSubjectOverride = (s) async => s;
      StudyStartService.debugFetchSubjectOverride = (_) async => s;
      expect(
        await StudyStartService.createSubject(
          s,
          requireFitbitAuthorization: false,
        ),
        isA<StudyStartSuccess>(),
      );
    },
  );
  test('other failures return generic result', () async {
    final s = subject();
    StudyStartService.debugSaveSubjectOverride = (_) async =>
        throw StateError('unexpected');
    expect(
      await StudyStartService.createSubject(s),
      isA<StudyStartGenericFailed>(),
    );
    expect(s.startedAt, isNull);
  });
}
