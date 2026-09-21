import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/app_onboarding/iframe_helper.dart';

void main() {
  test('preview messages are skipped when no iframe parent exists', () {
    final helper = IFrameHelper();

    expect(() => helper.postPreviewStatus(status: 'loaded'), returnsNormally);
    expect(helper.postRouteFinished, returnsNormally);
  });

  group('deriveDesignerOrigin', () {
    const fallback = 'https://designer.dev.studyu.health';

    test('accepts the compiled designer host as referrer origin', () {
      expect(deriveDesignerOrigin('$fallback/study/abc', fallback), fallback);
    });

    test('accepts studyu-dev Firebase preview-channel origins', () {
      expect(
        deriveDesignerOrigin(
          'https://studyu-dev-designer--pr-909-abc123.web.app/',
          fallback,
        ),
        'https://studyu-dev-designer--pr-909-abc123.web.app',
      );
      expect(
        deriveDesignerOrigin(
          'https://studyu-dev-designer--pr-909-abc123.firebaseapp.com/',
          fallback,
        ),
        'https://studyu-dev-designer--pr-909-abc123.firebaseapp.com',
      );
    });

    test('rejects Designer origins outside the trusted HTTPS origin', () {
      const untrustedOrigins = [
        'http://designer.dev.studyu.health/study/abc',
        'https://designer.dev.studyu.health:444/study/abc',
        'http://studyu-dev-designer--pr909-example.web.app/',
        'https://studyu-dev-designer--pr909-example.web.app:444/',
        'https://studyu-dev-designer--channel.web.app:0/',
        'https://studyu-dev-designer.attacker.web.app/',
        'https://studyu-dev-designer-v2--pr909-example.web.app/',
      ];

      for (final referrer in untrustedOrigins) {
        expect(deriveDesignerOrigin(referrer, fallback), fallback);
      }
    });

    test('rejects untrusted referrer origins and falls back', () {
      expect(
        deriveDesignerOrigin('https://evil.example.com/', fallback),
        fallback,
      );
      expect(
        deriveDesignerOrigin('https://studyu-dev.evil.example.com/', fallback),
        fallback,
      );
      // Lookalike Firebase project id must not pass the prefix check.
      expect(
        deriveDesignerOrigin('https://studyu-devil.web.app/', fallback),
        fallback,
      );
      expect(
        deriveDesignerOrigin('https://studyu-devil.firebaseapp.com/', fallback),
        fallback,
      );
      expect(
        deriveDesignerOrigin('https://studyu-dev.evil.example.com/', null),
        isNull,
      );
    });

    test('falls back to the compiled designer url', () {
      expect(deriveDesignerOrigin(null, fallback), fallback);
      expect(deriveDesignerOrigin('', '$fallback/'), fallback);
      expect(deriveDesignerOrigin('not-a-url', null), isNull);
      expect(deriveDesignerOrigin(null, null), isNull);
    });
  });
}
