import 'package:studyu_core/env.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    setEnv(
      'https://example.supabase.co',
      'test-anon-key',
      envAppUrl: 'https://app.dev.studyu.health',
      envAppDeepLinkScheme: 'studyu-app://',
      supabaseClient: SupabaseClient('https://example.supabase.co', 'test'),
    );
  });

  test('keeps web links separate from the native app scheme', () {
    expect(
      generateAppDeepLink('invite/hallo123'),
      'https://app.dev.studyu.health/invite/hallo123',
    );
    expect(
      generateAppSchemeLink('invite/hallo123'),
      'studyu-app://invite/hallo123',
    );
  });
}
