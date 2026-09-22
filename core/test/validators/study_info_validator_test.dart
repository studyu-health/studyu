import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/study_info_validator.dart';
import 'package:test/test.dart';

Study _study({String? title, String? description}) {
  final s = Study('test-id', 'test-user');
  s.title = title;
  s.description = description;
  return s;
}

void main() {
  group('validateStudyInfo - draft', () {
    test('passes when title is present', () {
      final r = validateStudyInfo(
        _study(title: 'My Study'),
        ValidationLevel.draft,
      );
      expect(r.valid, isTrue);
    });

    test('fails when title is null', () {
      final r = validateStudyInfo(_study(), ValidationLevel.draft);
      expect(r.valid, isFalse);
      expect(r.errors.first.code, 'study_info.title_required');
      expect(r.errors.first.path, r'$.title');
    });
  });

  group('validateStudyInfo - publish', () {
    test('fails when description is null', () {
      final r = validateStudyInfo(
        _study(title: 'My Study'),
        ValidationLevel.publish,
      );
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'study_info.description_required'),
        isTrue,
      );
    });

    test('passes with all fields set', () {
      final s = _study(title: 'My Study', description: 'Desc');
      s.contact.email = 'a@b.com';
      s.contact.organization = 'Org';
      s.contact.institutionalReviewBoard = 'IRB';
      s.contact.institutionalReviewBoardNumber = '123';
      s.contact.researchers = 'Alice';
      s.contact.phone = '+1234';
      s.iconName = 'accountHeart';
      final r = validateStudyInfo(s, ValidationLevel.publish);
      expect(r.valid, isTrue);
    });

    test('email without "@" at publish -> study_info.email_invalid_format', () {
      final s = _study(title: 'My Study', description: 'Desc');
      s.contact.email = 'not-an-email';
      s.contact.organization = 'Org';
      s.contact.institutionalReviewBoard = 'IRB';
      s.contact.institutionalReviewBoardNumber = '123';
      s.contact.researchers = 'Alice';
      s.contact.phone = '+1234';
      s.iconName = 'accountHeart';
      final r = validateStudyInfo(s, ValidationLevel.publish);
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'study_info.email_invalid_format'),
        isTrue,
      );
    });

    test('email with "@" at publish -> passes format check', () {
      final s = _study(title: 'My Study', description: 'Desc');
      s.contact.email = 'valid@example.com';
      s.contact.organization = 'Org';
      s.contact.institutionalReviewBoard = 'IRB';
      s.contact.institutionalReviewBoardNumber = '123';
      s.contact.researchers = 'Alice';
      s.contact.phone = '+1234';
      s.iconName = 'accountHeart';
      final r = validateStudyInfo(s, ValidationLevel.publish);
      expect(
        r.errors.where((e) => e.code == 'study_info.email_invalid_format'),
        isEmpty,
      );
    });

    test(
      'empty email at publish -> email_required, not email_invalid_format',
      () {
        final s = _study(title: 'My Study', description: 'Desc');
        s.contact.email = '';
        s.contact.organization = 'Org';
        s.contact.institutionalReviewBoard = 'IRB';
        s.contact.institutionalReviewBoardNumber = '123';
        s.contact.researchers = 'Alice';
        s.contact.phone = '+1234';
        s.iconName = 'accountHeart';
        final r = validateStudyInfo(s, ValidationLevel.publish);
        expect(r.valid, isFalse);
        expect(
          r.errors.any((e) => e.code == 'study_info.email_required'),
          isTrue,
        );
        expect(
          r.errors.where((e) => e.code == 'study_info.email_invalid_format'),
          isEmpty,
        );
      },
    );

    test('email check does not run at draft level', () {
      final s = _study(title: 'My Study');
      s.contact.email = 'not-valid';
      final r = validateStudyInfo(s, ValidationLevel.draft);
      expect(
        r.errors.where((e) => e.code == 'study_info.email_invalid_format'),
        isEmpty,
      );
    });
  });
}
