import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/app_onboarding/loading_screen.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  tearDown(() {
    appConnectionStatusController.reset();
  });

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
