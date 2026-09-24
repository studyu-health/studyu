import 'dart:async';

import 'package:studyu_core/src/models/tables/app_config.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

void main() {
  group('shouldRethrowAppConfigError', () {
    test('returns true for timeout exceptions', () {
      expect(
        shouldRethrowAppConfigError(
          TimeoutException('Connection timeout after 5 seconds'),
        ),
        isTrue,
      );
    });

    test('returns true for transport-style client exceptions', () {
      expect(
        shouldRethrowAppConfigError(
          Exception('ClientException: Failed to fetch'),
        ),
        isTrue,
      );
    });

    test('returns true for postgrest exceptions', () {
      expect(
        shouldRethrowAppConfigError(
          const PostgrestException(message: 'forbidden', code: 'PGRST301'),
        ),
        isTrue,
      );
    });

    test('returns false for generic parsing failures', () {
      expect(
        shouldRethrowAppConfigError(Exception('unexpected JSON shape')),
        isFalse,
      );
    });
  });
}
