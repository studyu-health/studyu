import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:test/test.dart';

void main() {
  group('ValidationResult', () {
    test('empty() is valid with no errors', () {
      final r = ValidationResult.empty();
      expect(r.valid, isTrue);
      expect(r.errors, isEmpty);
      expect(r.warnings, isEmpty);
    });

    test('is invalid when errors list is non-empty', () {
      const r = ValidationResult(
        errors: [
          ValidationError(
            code: 'test.error',
            path: r'$.title',
            message: 'Title is required',
            fixHint: 'Add a title',
          ),
        ],
        warnings: [],
      );
      expect(r.valid, isFalse);
    });

    test('merge() combines errors and warnings from both results', () {
      const a = ValidationResult(
        errors: [
          ValidationError(code: 'a', path: '', message: 'A', fixHint: ''),
        ],
        warnings: [],
      );
      const b = ValidationResult(
        errors: [
          ValidationError(code: 'b', path: '', message: 'B', fixHint: ''),
        ],
        warnings: [],
      );
      final merged = ValidationResult.merge([a, b]);
      expect(merged.errors.length, 2);
      expect(merged.valid, isFalse);
    });

    test('merge() of empty list is valid', () {
      final merged = ValidationResult.merge([]);
      expect(merged.valid, isTrue);
    });
  });
}
