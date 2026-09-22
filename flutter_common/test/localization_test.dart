import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  const supportedLocales = [
    Locale('en', 'US'),
    Locale('de', 'DE'),
    Locale('pt', 'BR'),
  ];

  test('resolves a BCP-47 locale tag', () {
    expect(
      resolveSupportedLocale('de-DE', supportedLocales),
      const Locale('de', 'DE'),
    );
  });

  test('resolves a legacy language code to its supported locale', () {
    expect(
      resolveSupportedLocale('de', supportedLocales),
      const Locale('de', 'DE'),
    );
  });

  test('accepts underscore-separated locale tags', () {
    expect(
      resolveSupportedLocale('pt_BR', supportedLocales),
      const Locale('pt', 'BR'),
    );
  });

  test('returns null for an unsupported locale', () {
    expect(resolveSupportedLocale('fr-FR', supportedLocales), isNull);
  });
}
