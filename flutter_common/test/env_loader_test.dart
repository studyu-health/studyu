import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';
import 'package:studyu_flutter_common/src/utils/env_loader.dart';
import 'package:studyu_flutter_common/src/utils/storage.dart';

void main() {
  tearDown(() {
    appConnectionStatusController.reset();
    SupabaseStorage.suppressPersistedSessionRecovery = false;
  });

  test(
    'findWorkingSupabaseUrl suppresses session recovery when all URLs fail',
    () async {
      final result = await findWorkingSupabaseUrl(const [
        'http://127.0.0.1:1',
      ], 'anon-key');

      expect(result.url, 'http://127.0.0.1:1');
      expect(result.status, AppConnectionStatus.backendUnavailable);
      expect(result.suppressPersistedSessionRecovery, isTrue);
    },
  );

  test(
    'supabase storage hides persisted session while recovery is suppressed',
    () async {
      final storage = SupabaseStorage();

      SupabaseStorage.suppressPersistedSessionRecovery = true;
      expect(await storage.hasAccessToken(), isFalse);
      expect(await storage.accessToken(), isNull);
    },
  );
}
