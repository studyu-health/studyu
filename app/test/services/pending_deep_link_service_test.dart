import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_core/core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
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

  test('clear removes a pending invite from memory and storage', () async {
    final state = AppState()
      ..setPendingDeepLink(
        study: Study('study-1', 'owner-1'),
        inviteCode: 'invite-1',
        preselectedInterventionIds: ['intervention-1'],
      );
    await PendingDeepLinkService.persist(inviteCode: 'invite-1');

    await PendingDeepLinkService.clear(state);

    expect(state.hasPendingDeepLink, isFalse);
    expect(state.selectedStudy, isNull);
    expect(state.inviteCode, isNull);
    expect(state.preselectedInterventionIds, isNull);
    expect(await PendingDeepLinkService.readStorage(), (
      studyId: null,
      inviteCode: null,
    ));
  });
}
