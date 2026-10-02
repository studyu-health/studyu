import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/deferred_fitbit_request.dart';
import 'package:studyu_app/util/cache.dart';

DeferredFitbitRequest request(int index) => DeferredFitbitRequest(
  subjectId: 'subject',
  interventionId: 'intervention',
  taskId: 'task',
  periodId: 'period',
  questionId: '$index',
  windowStart: DateTime.utc(2020),
  windowEnd: DateTime.utc(2020, 1, 2),
  completedAt: DateTime.utc(2020, 1, 2),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};
  setUp(() {
    storage.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          final args = call.arguments as Map<Object?, Object?>;
          final key = args['key']! as String;
          return switch (call.method) {
            'read' => storage[key],
            'write' => storage[key] = args['value']! as String,
            _ => throw UnimplementedError(call.method),
          };
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  test(
    'retains old requests and rejects overflow without changing storage',
    () async {
      for (var i = 0; i < Cache.maxDeferredFitbitRequests; i++) {
        await Cache.storeDeferredFitbitRequest(request(i));
      }
      final snapshot = Map<String, String>.from(storage);
      await expectLater(
        Cache.storeDeferredFitbitRequest(request(999)),
        throwsA(isA<DeferredFitbitQueueFullException>()),
      );
      expect(storage, snapshot);
      expect(
        (await Cache.loadDeferredFitbitRequests()).first.completedAt,
        DateTime.utc(2020, 1, 2),
      );
      await Cache.storeDeferredFitbitRequest(request(0));
      expect(
        (await Cache.loadDeferredFitbitRequests()).length,
        Cache.maxDeferredFitbitRequests,
      );
    },
  );

  test('concurrent appends retain all requests', () async {
    await Future.wait(
      List.generate(20, (i) => Cache.storeDeferredFitbitRequest(request(i))),
    );
    expect(
      (await Cache.loadDeferredFitbitRequests())
          .map((r) => r.id)
          .toSet()
          .length,
      20,
    );
  });

  test('removes only the resolved request', () async {
    await Cache.storeDeferredFitbitRequest(request(0));
    await Cache.storeDeferredFitbitRequest(request(1));
    await Cache.removeDeferredFitbitRequest(request(0).id);
    expect((await Cache.loadDeferredFitbitRequests()).single.id, request(1).id);
  });
}
