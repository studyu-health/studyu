import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';

void main() {
  group('RestoreAccountService', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    final storage = <String, String>{};

    setUp(() {
      storage.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            final arguments = call.arguments as Map<Object?, Object?>;
            final key = arguments['key'] as String?;
            return switch (call.method) {
              'write' => storage[key!] = arguments['value']! as String,
              'read' => storage[key],
              'delete' => storage.remove(key),
              _ => throw UnimplementedError(call.method),
            };
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    tearDown(RestoreAccountService.clearCache);

    test('decodeRecoveryPhrase accepts German recovery phrases', () {
      final recoveryId = BigInt.parse(
        '1234567890ABCDEF1234567890ABCDEF',
        radix: 16,
      );
      final words = encode(recoveryId, wordlist: wordlistDe);

      expect(RestoreAccountService.decodeRecoveryPhrase(words), recoveryId);
    });

    test(
      'successful recovery clears old subject state before signing in',
      () async {
        final calls = <String>[];
        String? activeSubjectId = 'old-subject';
        RestoreAccountService.debugConfigureRecoveryForTesting(
          recoverAccount: (_) async => RecoveryResult(
            success: true,
            email: 'recovered@example.com',
            password: 'password',
            subjectId: 'recovered-subject',
          ),
          storeCredentials: (_, _) async => calls.add('store credentials'),
          signInParticipant: () async {
            calls.add('sign in with $activeSubjectId');
            return true;
          },
          confirmRecovery: () async {
            calls.add('confirm recovery');
            return true;
          },
          clearActiveSubjectState: () async {
            activeSubjectId = null;
            calls.add('clear old subject');
          },
          storeActiveSubjectId: (subjectId) async {
            activeSubjectId = subjectId;
            calls.add('store $subjectId');
          },
        );
        RestoreAccountService.debugSubjectGetterForTesting = (_) async =>
            StudySubject.fromStudy(Study('study', 'owner'), 'owner', [], null);
        addTearDown(RestoreAccountService.debugResetRecoveryForTesting);
        addTearDown(RestoreAccountService.debugResetSubjectGetterForTesting);

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isTrue);
        expect(calls, [
          'store credentials',
          'clear old subject',
          'store recovered-subject',
          'sign in with recovered-subject',
          'confirm recovery',
        ]);
      },
    );

    test(
      'account replacement clears persisted deep links and notifications',
      () async {
        final state = AppState()
          ..setPendingDeepLink(
            study: Study('study', 'owner'),
            inviteCode: 'former-account-invite',
          );
        await PendingDeepLinkService.persist(
          inviteCode: 'former-account-invite',
        );
        var notificationsCancelled = false;
        RestoreAccountService.debugConfigureRecoveryForTesting(
          recoverAccount: (_) async => RecoveryResult(
            success: true,
            email: 'recovered@example.com',
            password: 'password',
          ),
          storeCredentials: (_, _) async {},
          clearActiveSubjectState: () async {},
          signInParticipant: () async => true,
          confirmRecovery: () async => true,
          cancelNotifications: (_) async => notificationsCancelled = true,
        );
        addTearDown(RestoreAccountService.debugResetRecoveryForTesting);

        final result = await RestoreAccountService.performRecovery(
          BigInt.one,
          appState: state,
        );

        expect(result.success, isTrue);
        expect(notificationsCancelled, isTrue);
        expect(await PendingDeepLinkService.readStorage(), (
          studyId: null,
          inviteCode: null,
        ));
      },
    );

    test(
      'recovery without a subject clears stale state before signing in',
      () async {
        final calls = <String>[];
        String? activeSubjectId = 'old-subject';
        RestoreAccountService.debugConfigureRecoveryForTesting(
          recoverAccount: (_) async => RecoveryResult(
            success: true,
            email: 'recovered@example.com',
            password: 'password',
          ),
          storeCredentials: (_, _) async => calls.add('store credentials'),
          clearActiveSubjectState: () async {
            activeSubjectId = null;
            calls.add('clear old subject');
          },
          signInParticipant: () async {
            calls.add('sign in with $activeSubjectId');
            return true;
          },
          confirmRecovery: () async => true,
        );
        addTearDown(RestoreAccountService.debugResetRecoveryForTesting);

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isTrue);
        expect(result.subjectId, isNull);
        expect(calls, [
          'store credentials',
          'clear old subject',
          'sign in with null',
        ]);
      },
    );

    test(
      'storage failure leaves pending recovery retryable and clears state',
      () async {
        var cleared = false;
        RestoreAccountService.debugConfigureRecoveryForTesting(
          recoverAccount: (_) async => RecoveryResult(
            success: true,
            email: 'recovered@example.com',
            password: 'password',
          ),
          storeCredentials: (_, _) async => throw Exception('storage failed'),
          clearActiveSubjectState: () async => cleared = true,
        );
        addTearDown(RestoreAccountService.debugResetRecoveryForTesting);

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isFalse);
        expect(result.error, 'recovery_network_error');
        expect(cleared, isFalse);
      },
    );

    test(
      'sign-in failure clears account state without confirming recovery',
      () async {
        var cleared = 0;
        var confirmed = false;
        RestoreAccountService.debugConfigureRecoveryForTesting(
          recoverAccount: (_) async => RecoveryResult(
            success: true,
            email: 'recovered@example.com',
            password: 'password',
          ),
          storeCredentials: (_, _) async {},
          signInParticipant: () async => false,
          confirmRecovery: () async => confirmed = true,
          clearActiveSubjectState: () async => cleared++,
        );
        addTearDown(RestoreAccountService.debugResetRecoveryForTesting);

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isFalse);
        expect(cleared, 2);
        expect(confirmed, isFalse);
      },
    );

    test('validateSubject propagates failed subject lookups', () async {
      RestoreAccountService.debugSubjectGetterForTesting = (_) async =>
          throw const PostgrestException(
            message: 'permission denied',
            code: '42501',
          );
      addTearDown(RestoreAccountService.debugResetSubjectGetterForTesting);

      await expectLater(
        RestoreAccountService.validateSubject('subject-id'),
        throwsA(
          isA<PostgrestException>().having(
            (error) => error.code,
            'code',
            '42501',
          ),
        ),
      );
    });

    test('validateSubject accepts a confirmed missing subject', () async {
      RestoreAccountService.debugSubjectGetterForTesting = (_) async =>
          throw const PostgrestException(
            message: 'JSON object requested, multiple (or no) rows returned',
            code: 'PGRST116',
          );
      addTearDown(RestoreAccountService.debugResetSubjectGetterForTesting);

      expect(
        await RestoreAccountService.validateSubject('subject-id'),
        isFalse,
      );
    });

    test('rotateRecoveryPhrase replaces the cached phrase', () async {
      const oldRecoveryId = '00000000-0000-0000-0000-000000000001';
      const newRecoveryId = '00000000-0000-0000-0000-000000000002';
      var fetchCount = 0;

      RestoreAccountService.debugCurrentUserIdGetterForTesting = () => 'user';
      RestoreAccountService.debugRecoveryIdGetterForTesting = () async {
        fetchCount++;
        return oldRecoveryId;
      };
      RestoreAccountService.debugRecoveryIdRotatorForTesting = () async =>
          newRecoveryId;
      addTearDown(
        RestoreAccountService.debugResetCurrentUserIdGetterForTesting,
      );
      addTearDown(RestoreAccountService.debugResetRecoveryIdGetterForTesting);
      addTearDown(RestoreAccountService.debugResetRecoveryIdRotatorForTesting);

      expect(
        await RestoreAccountService.getRecoveryPhrase(),
        encode(BigInt.one),
      );
      expect(
        await RestoreAccountService.rotateRecoveryPhrase(),
        encode(BigInt.two),
      );
      expect(
        await RestoreAccountService.getRecoveryPhrase(),
        encode(BigInt.two),
      );
      expect(fetchCount, 1);
    });

    test('rotation result is discarded when current user changes', () async {
      var currentUserId = 'first-user';
      RestoreAccountService.debugCurrentUserIdGetterForTesting = () =>
          currentUserId;
      RestoreAccountService.debugRecoveryIdRotatorForTesting = () async {
        currentUserId = 'second-user';
        return '00000000-0000-0000-0000-000000000002';
      };
      addTearDown(
        RestoreAccountService.debugResetCurrentUserIdGetterForTesting,
      );
      addTearDown(RestoreAccountService.debugResetRecoveryIdRotatorForTesting);

      expect(await RestoreAccountService.rotateRecoveryPhrase(), isNull);
    });

    test('failed rotation clears the cached phrase', () async {
      var fetchCount = 0;
      RestoreAccountService.debugCurrentUserIdGetterForTesting = () => 'user';
      RestoreAccountService.debugRecoveryIdGetterForTesting = () async {
        fetchCount++;
        return '00000000-0000-0000-0000-000000000001';
      };
      RestoreAccountService.debugRecoveryIdRotatorForTesting = () async => null;
      addTearDown(
        RestoreAccountService.debugResetCurrentUserIdGetterForTesting,
      );
      addTearDown(RestoreAccountService.debugResetRecoveryIdGetterForTesting);
      addTearDown(RestoreAccountService.debugResetRecoveryIdRotatorForTesting);

      await RestoreAccountService.getRecoveryPhrase();
      expect(await RestoreAccountService.rotateRecoveryPhrase(), isNull);
      await RestoreAccountService.getRecoveryPhrase();

      expect(fetchCount, 2);
    });

    test(
      'getRecoveryPhrase refreshes cache when current user changes',
      () async {
        const firstRecoveryId = '00000000-0000-0000-0000-000000000001';
        const secondRecoveryId = '00000000-0000-0000-0000-000000000002';
        var currentUserId = 'first-user';
        var currentRecoveryId = firstRecoveryId;

        RestoreAccountService.debugCurrentUserIdGetterForTesting = () =>
            currentUserId;
        RestoreAccountService.debugRecoveryIdGetterForTesting = () async =>
            currentRecoveryId;
        addTearDown(
          RestoreAccountService.debugResetCurrentUserIdGetterForTesting,
        );
        addTearDown(RestoreAccountService.debugResetRecoveryIdGetterForTesting);

        final firstPhrase = await RestoreAccountService.getRecoveryPhrase();
        currentUserId = 'second-user';
        currentRecoveryId = secondRecoveryId;
        final secondPhrase = await RestoreAccountService.getRecoveryPhrase();

        expect(firstPhrase, isNot(secondPhrase));
        expect(secondPhrase, encode(BigInt.two));
      },
    );
  });
}
