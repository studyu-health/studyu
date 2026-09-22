import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  group('FreeTextQuestion.validateResponse', () {
    // ── Any text type ──────────────────────────────────────────────────
    group('textType = any', () {
      late FreeTextQuestion question;

      setUp(() {
        question = FreeTextQuestion.withId(
          textType: FreeTextQuestionType.any,
          lengthRange: [0, 100],
        );
      });

      test('accepts text within length range', () {
        question.lengthRange = [0, 100];
        expect(question.validateResponse('Hello World'), isNull);
      });

      test('accepts empty when min=0', () {
        question.lengthRange = [0, 100];
        expect(question.validateResponse(''), isNull);
      });

      test('rejects too short', () {
        question.lengthRange = [5, 100];
        expect(
          question.validateResponse('Hey'),
          equals(FreeTextValidationError.tooShort),
        );
      });

      test('rejects too long', () {
        question.lengthRange = [0, 3];
        expect(
          question.validateResponse('Hello'),
          equals(FreeTextValidationError.tooLong),
        );
      });

      test('rejects empty when min > 0', () {
        question.lengthRange = [1, 100];
        expect(
          question.validateResponse(''),
          equals(FreeTextValidationError.tooShort),
        );
      });
    });

    // ── Alphanumeric text type ─────────────────────────────────────────
    group('textType = alphanumeric', () {
      late FreeTextQuestion question;

      setUp(() {
        question = FreeTextQuestion.withId(
          textType: FreeTextQuestionType.alphanumeric,
          lengthRange: [0, 100],
        );
      });

      test('accepts alphanumeric text abc123', () {
        expect(question.validateResponse('abc123'), isNull);
      });

      test('accepts empty when min=0', () {
        question.lengthRange = [0, 100];
        expect(question.validateResponse(''), isNull);
      });

      test('rejects text with spaces', () {
        expect(
          question.validateResponse('abc 123'),
          equals(FreeTextValidationError.notAlphanumeric),
        );
      });

      test('rejects text with hyphens', () {
        expect(
          question.validateResponse('abc-123'),
          equals(FreeTextValidationError.notAlphanumeric),
        );
      });

      test('rejects too short', () {
        question.lengthRange = [5, 100];
        expect(
          question.validateResponse('ab'),
          equals(FreeTextValidationError.tooShort),
        );
      });

      test('rejects too long', () {
        question.lengthRange = [0, 3];
        expect(
          question.validateResponse('abcd'),
          equals(FreeTextValidationError.tooLong),
        );
      });
    });

    // ── Numeric text type ──────────────────────────────────────────────
    group('textType = numeric', () {
      late FreeTextQuestion question;

      setUp(() {
        question = FreeTextQuestion.withId(
          textType: FreeTextQuestionType.numeric,
          lengthRange: [0, 100],
        );
      });

      test('accepts 123', () {
        expect(question.validateResponse('123'), isNull);
      });

      test('accepts -123', () {
        expect(question.validateResponse('-123'), isNull);
      });

      test('accepts 0', () {
        expect(question.validateResponse('0'), isNull);
      });

      test('accepts empty when min=0', () {
        question.lengthRange = [0, 100];
        expect(question.validateResponse(''), isNull);
      });

      test('rejects 12a', () {
        expect(
          question.validateResponse('12a'),
          equals(FreeTextValidationError.notNumeric),
        );
      });

      test('rejects empty when min=1', () {
        question.lengthRange = [1, 100];
        expect(
          question.validateResponse(''),
          equals(FreeTextValidationError.tooShort),
        );
      });

      test('rejects 1.5 (decimal)', () {
        expect(
          question.validateResponse('1.5'),
          equals(FreeTextValidationError.notNumeric),
        );
      });

      test('rejects too short', () {
        question.lengthRange = [3, 100];
        expect(
          question.validateResponse('12'),
          equals(FreeTextValidationError.tooShort),
        );
      });

      test('rejects too long', () {
        question.lengthRange = [0, 2];
        expect(
          question.validateResponse('123'),
          equals(FreeTextValidationError.tooLong),
        );
      });
    });

    // ── Custom text type ───────────────────────────────────────────────
    group('textType = custom', () {
      late FreeTextQuestion question;

      setUp(() {
        question = FreeTextQuestion.withId(
          textType: FreeTextQuestionType.custom,
          lengthRange: [10, 50],
          customTypeExpression: r'\d+',
        );
      });

      test('accepts matching pattern', () {
        expect(question.validateResponse('42'), isNull);
      });

      test('rejects non-matching input', () {
        expect(
          question.validateResponse('abc'),
          equals(FreeTextValidationError.customMismatch),
        );
      });

      test('ignores length validation (below minRange)', () {
        // lengthRange is [10, 50], but input '1' is shorter
        expect(question.validateResponse('1'), isNull);
      });

      test('ignores length validation (above maxRange)', () {
        // lengthRange is [10, 50], but very long numeric string is OK
        expect(question.validateResponse('1' * 100), isNull);
      });

      test('rejects empty when pattern does not match empty', () {
        question.customTypeExpression = r'\d+';
        expect(
          question.validateResponse(''),
          equals(FreeTextValidationError.customMismatch),
        );
      });

      test('missing custom expression returns invalidCustomExpression', () {
        question.customTypeExpression = null;
        expect(
          question.validateResponse('anything'),
          equals(FreeTextValidationError.invalidCustomExpression),
        );
      });

      test('empty custom expression returns invalidCustomExpression', () {
        question.customTypeExpression = '';
        expect(
          question.validateResponse('anything'),
          equals(FreeTextValidationError.invalidCustomExpression),
        );
      });

      test('malformed custom regex returns invalidCustomExpression', () {
        question.customTypeExpression = '[';
        expect(
          question.validateResponse('anything'),
          equals(FreeTextValidationError.invalidCustomExpression),
        );
      });
    });
  });
}
