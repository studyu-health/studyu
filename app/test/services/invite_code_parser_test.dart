import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/invite_code_parser.dart';

void main() {
  test('keeps a raw invite code and trims surrounding whitespace', () {
    expect(inviteCodeFromScan('  AbC-123  '), 'AbC-123');
  });

  test('extracts a code from the StudyU web invite URL', () {
    expect(
      inviteCodeFromScan('https://app.studyu.health/invite/AbC-123?source=qr'),
      'AbC-123',
    );
  });

  test('extracts a code from the StudyU app invite URL', () {
    expect(inviteCodeFromScan('studyu-app://invite/AbC-123'), 'AbC-123');
  });

  test('extracts a code from the StudyU app invite URL with an empty host', () {
    expect(inviteCodeFromScan('studyu-app:///invite/AbC-123'), 'AbC-123');
  });

  test('decodes reserved characters exactly once', () {
    const expected = 'abc/xyz#part%value';
    expect(
      inviteCodeFromScan(
        'https://app.studyu.health/invite/abc%2Fxyz%23part%25value',
      ),
      expected,
    );
    expect(
      inviteCodeFromScan('studyu-app://invite/abc%2Fxyz%23part%25value'),
      expected,
    );
  });

  test(
    'keeps the original scan string when encoded invite code is malformed',
    () {
      const malformedCodeUrl = 'studyu-app://invite/%E0%A4%A';
      expect(inviteCodeFromScan(malformedCodeUrl), malformedCodeUrl);
    },
  );

  test('rejects an empty scan result', () {
    expect(inviteCodeFromScan('  '), isNull);
  });
}
