import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/app_onboarding/loading_screen.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  tearDown(() {
    appConnectionStatusController.reset();
  });

  test('restoreCachedValueForStartup returns a remote value', () async {
    var loadCacheCalls = 0;
    var signInCalls = 0;

    final result = await restoreCachedValueForStartup<String>(
      fetchRemote: () async => 'remote-subject',
      loadCached: () async {
        loadCacheCalls++;
        return 'cached-subject';
      },
      signIn: () async {
        signInCalls++;
        return true;
      },
      isDeletedRemoteError: (_) => false,
    );

    expect(result, 'remote-subject');
    expect(loadCacheCalls, 0);
    expect(signInCalls, 0);
  });

  test('restoreCachedValueForStartup retries after successful auth', () async {
    var fetchCalls = 0;
    var loadCacheCalls = 0;

    final result = await restoreCachedValueForStartup<String>(
      fetchRemote: () async {
        fetchCalls++;
        if (fetchCalls == 1) throw Exception('authentication required');
        return 'remote-subject';
      },
      loadCached: () async {
        loadCacheCalls++;
        return 'cached-subject';
      },
      signIn: () async => true,
      isDeletedRemoteError: (_) => false,
    );

    expect(result, 'remote-subject');
    expect(fetchCalls, 2);
    expect(loadCacheCalls, 0);
  });

  test(
    'restoreCachedValueForStartup returns null when auth is rejected',
    () async {
      var loadCacheCalls = 0;

      final result = await restoreCachedValueForStartup<String>(
        fetchRemote: () =>
            Future<String?>.error(Exception('authentication required')),
        loadCached: () async {
          loadCacheCalls++;
          return 'cached-subject';
        },
        signIn: () async => false,
        isDeletedRemoteError: (_) => false,
      );

      expect(result, isNull);
      expect(loadCacheCalls, 0);
    },
  );

  test(
    'restoreCachedValueForStartup uses cache after auth transport failure',
    () async {
      final result = await restoreCachedValueForStartup<String>(
        fetchRemote: () =>
            Future<String?>.error(Exception('authentication required')),
        loadCached: () async => 'cached-subject',
        signIn: () =>
            Future<bool>.error(Exception('ClientException: Failed to fetch')),
        isDeletedRemoteError: (_) => false,
      );

      expect(result, 'cached-subject');
      expect(
        appConnectionStatusController.status,
        AppConnectionStatus.backendUnavailable,
      );
    },
  );

  test('restoreCachedValueForStartup returns cached value and skips sign-in on backend outage', () async {
    var signInCalls = 0;
    var fetchCalls = 0;

    final result = await restoreCachedValueForStartup<String>(
      fetchRemote: () {
        fetchCalls++;
        return Future<String?>.error(
          Exception('ClientException: Failed to fetch'),
        );
      },
      loadCached: () => Future.value('cached-subject'),
      signIn: () {
        signInCalls++;
        return Future.value(true);
      },
      isDeletedRemoteError: (_) => false,
    );

    expect(result, 'cached-subject');
    expect(fetchCalls, 1);
    expect(signInCalls, 0);
    expect(
      appConnectionStatusController.status,
      AppConnectionStatus.backendUnavailable,
    );
  });

  test('restoreCachedValueForStartup throws cache unavailable when backend is down and cache is missing', () async {
    await expectLater(
      () => restoreCachedValueForStartup<String>(
        fetchRemote: () => Future<String?>.error(
          Exception('ClientException: Failed to fetch'),
        ),
        loadCached: () =>
            Future<String>.error(Exception('No cached subject found')),
        signIn: () => Future.value(true),
        isDeletedRemoteError: (_) => false,
      ),
      throwsA(isA<SubjectCacheUnavailableException>()),
    );
  });

  test(
    'restoreCachedValueForStartup rejects a cached subject with another ID',
    () async {
      final cachedSubject = StudySubject(
        'cached-subject-id',
        'study-id',
        'user-id',
        const [],
      );

      await expectLater(
        () => restoreCachedValueForStartup<StudySubject>(
          fetchRemote: () => Future<StudySubject?>.error(
            Exception('ClientException: Failed to fetch'),
          ),
          loadCached: () => loadCachedSubjectForStartup(
            selectedSubjectId: 'selected-subject-id',
            loadCached: () async => cachedSubject,
          ),
          signIn: () async => true,
          isDeletedRemoteError: (_) => false,
        ),
        throwsA(
          isA<SubjectCacheUnavailableException>().having(
            (error) => error.cause,
            'cause',
            isA<StateError>(),
          ),
        ),
      );
    },
  );

  test('restoreCachedValueForStartup maps deleted remote subject without using cache', () async {
    var loadCacheCalls = 0;
    var signInCalls = 0;

    await expectLater(
      () => restoreCachedValueForStartup<String>(
        fetchRemote: () => Future<String?>.error(Exception('PGRST116')),
        loadCached: () {
          loadCacheCalls++;
          return Future.value('cached-subject');
        },
        signIn: () {
          signInCalls++;
          return Future.value(true);
        },
        isDeletedRemoteError: (error) => error.toString().contains('PGRST116'),
      ),
      throwsA(isA<SubjectDeletedException>()),
    );

    expect(loadCacheCalls, 0);
    expect(signInCalls, 0);
  });
}
