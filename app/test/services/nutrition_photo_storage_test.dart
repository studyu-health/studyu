import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyu_app/services/nutrition_photo_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const scope = (userId: 'participant', subjectId: 'subject');
  const key = NutritionPhotoKey(scope, NutritionPhotoKind.meal, 'meal');
  const secureStorage = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  test(
    'retries an upload at the same path and persists failed cleanup',
    () async {
      final pending = <String, String>{};
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(secureStorage, (call) async {
        final arguments = call.arguments as Map;
        final key = arguments['key'] as String;
        switch (call.method) {
          case 'read':
            return pending[key];
          case 'write':
            pending[key] = arguments['value'] as String;
          case 'delete':
            pending.remove(key);
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(secureStorage, null),
      );

      var offline = true;
      var uploads = 0;
      var deletes = 0;
      final client = SupabaseClient(
        'http://localhost',
        'test-key',
        httpClient: MockClient((request) async {
          expect(request.headers['authorization'], 'Bearer participant-token');
          switch (request.method) {
            case 'POST':
              expect(
                request.url.path,
                '/storage/v1/object/nutrition-photos/${key.path}',
              );
              expect(request.headers['x-upsert'], 'true');
              uploads++;
            case 'DELETE':
              expect(request.url.path, '/storage/v1/object/nutrition-photos');
              expect(jsonDecode(request.body), {
                'prefixes': [key.path],
              });
              deletes++;
          }
          return http.Response(
            offline
                ? '{"message":"Offline"}'
                : request.method == 'POST'
                ? jsonEncode({'Key': 'nutrition-photos/${key.path}'})
                : '[]',
            offline ? 503 : 200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      await client.auth.recoverSession(
        jsonEncode({
          'access_token': 'participant-token',
          'token_type': 'bearer',
          'user': {'id': scope.userId, 'app_metadata': <String, dynamic>{}},
        }),
      );

      final storage = NutritionPhotoStorage.forClient(client);
      final change = NutritionPhotoChange.replace(
        Uint8List.fromList([255, 216]),
      );
      storage.stage(key, change);
      await expectLater(
        storage.apply(key, change),
        throwsA(isA<StorageException>()),
      );
      expect(storage.pendingChange(key), same(change));

      offline = false;
      await storage.apply(key, change);
      expect(uploads, 2);
      expect(storage.pendingChange(key), isNull);

      offline = true;
      await storage.deleteWithRetry(key);
      expect(pending.values.single, jsonEncode([key.path]));
      offline = false;
      await storage.retryDeletes(scope);
      expect(deletes, 2);
      expect(pending, isEmpty);
    },
  );
}
