import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorage = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory directory;
  late String? cachedSubject;
  late List<Map<String, dynamic>> uploads;

  setUpAll(() {
    final client = SupabaseClient(
      'http://localhost',
      'test-key',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, endsWith('/subject_progress'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        uploads.add(body);
        return http.Response(
          jsonEncode([body]),
          201,
          headers: const {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
    setEnv('http://localhost', 'test-key', supabaseClient: client);
    addTearDown(client.dispose);
  });

  setUp(() async {
    cachedSubject = null;
    uploads = [];
    directory = await Directory.systemTemp.createTemp();
    messenger.setMockMethodCallHandler(
      pathProvider,
      (_) async => directory.path,
    );
    messenger.setMockMethodCallHandler(secureStorage, (call) async {
      switch (call.method) {
        case 'containsKey':
          return cachedSubject != null;
        case 'read':
          return cachedSubject;
        case 'write':
          cachedSubject = (call.arguments as Map)['value'] as String;
          return null;
      }
      throw MissingPluginException(call.method);
    });
  });

  tearDown(() async {
    messenger.setMockMethodCallHandler(secureStorage, null);
    messenger.setMockMethodCallHandler(pathProvider, null);
    await directory.delete(recursive: true);
  });

  test(
    'sync uploads missing progress even when both caches have equal counts',
    () async {
      final start = DateTime.utc(2026, 7, 15);
      final remote = _subject(start);
      final local = _subject(start);
      final sharedTime = start.add(const Duration(hours: 1));
      final queued = _progress(start.add(const Duration(hours: 2)));
      final saved = _progress(start.add(const Duration(hours: 3)));
      final shared = _progress(sharedTime, result: false);
      remote.progress = [shared, saved];
      local.progress = [_progress(sharedTime), queued];
      await Cache.storeSubject(local);

      final synchronized = await Cache.synchronize(remote);

      expect(uploads, [queued.toJson()]);
      expect(synchronized.progress, [shared, saved, queued]);
      expect((await Cache.loadSubject()).progress, synchronized.progress);
    },
  );

  test('sync skips expired recalls and still uploads other progress', () async {
    final start = DateTime.utc(2020);
    final remote = _subject(start);
    final local = _subject(start);
    final remoteRecall = _nutrition(start);
    final localRecall = _nutrition(start, title: 'Stale');
    final queued = _progress(start.add(const Duration(hours: 2)));
    final expired = _nutrition(start.add(const Duration(days: 1)), studyDay: 1);
    remote.progress = [remoteRecall];
    local.progress = [localRecall, expired, queued];
    await Cache.storeSubject(local);

    final synchronized = await Cache.synchronize(remote);

    expect(uploads, [queued.toJson()]);
    expect(synchronized.progress, [remoteRecall, queued]);
    expect((await Cache.loadSubject()).progress, contains(expired));
  });
}

StudySubject _subject(DateTime start) =>
    StudySubject('subject', 'study', 'user', [])
      ..startedAt = start
      ..study = Study('study', 'user');

SubjectProgress _progress(DateTime completedAt, {bool result = true}) =>
    SubjectProgress(
      subjectId: 'subject',
      taskId: 'task',
      interventionId: 'intervention',
      resultType: 'bool',
      result: Result<bool>.app(
        type: 'bool',
        periodId: 'period',
        result: result,
      ),
    )..completedAt = completedAt;

SubjectProgress _nutrition(
  DateTime completedAt, {
  String title = 'Original',
  int studyDay = 0,
}) => SubjectProgress(
  subjectId: 'subject',
  taskId: 'nutrition',
  interventionId: 'intervention',
  resultType: 'DailyRecall',
  result: Result<DailyRecall>.app(
    type: 'DailyRecall',
    periodId: 'period',
    result: DailyRecall(
      id: 'recall-$studyDay',
      date: completedAt,
      specialOccasion: title,
      recallMode: RecallMode.realtimeRecord,
      meals: [],
      studyDaySnapshot: studyDay,
      entryCompletedAt: completedAt,
    ),
  ),
)..completedAt = completedAt;
