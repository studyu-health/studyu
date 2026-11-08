import 'package:studyu_core/core.dart';
import 'package:studyu_core/testing.dart';
import 'package:test/test.dart';

void main() {
  group('validateStudy', () {
    test('returns valid for a minimal draft study with a title', () {
      final s = Study('id', 'user');
      s.title = 'My Study';
      final r = validateStudy(s, ValidationLevel.draft);
      expect(r.valid, isTrue);
    });

    test('returns invalid for a draft with missing title', () {
      final s = Study('id', 'user');
      final r = validateStudy(s, ValidationLevel.draft);
      expect(r.valid, isFalse);
    });

    test(
      'catches eligibility reference error and study info error together',
      () {
        final s = Study('id', 'user');
        // no title → study_info error
        final criterion = EligibilityCriterion.withId();
        final expr = ChoiceExpression();
        expr.target = 'ghost-id';
        criterion.condition = expr;
        s.eligibilityCriteria = [criterion];

        final r = validateStudy(s, ValidationLevel.draft);
        expect(r.valid, isFalse);
        expect(r.errors.length, greaterThanOrEqualTo(2));
        expect(
          r.errors.any((e) => e.code == 'study_info.title_required'),
          isTrue,
        );
        expect(
          r.errors.any((e) => e.code == 'eligibility.target_question_missing'),
          isTrue,
        );
      },
    );

    test('StudyFixtures.fullValid() passes validateStudy at publish level', () {
      final r = validateStudy(
        StudyFixtures.fullValid(),
        ValidationLevel.publish,
      );
      expect(
        r.valid,
        isTrue,
        reason: 'Errors: ${r.errors.map((e) => e.code).join(', ')}',
      );
    });

    test(
      'StudyFixtures.invalidNoConsentItems() fails with consent.no_items',
      () {
        final r = validateStudy(
          StudyFixtures.invalidNoConsentItems(),
          ValidationLevel.publish,
        );
        expect(r.valid, isFalse);
        expect(r.errors.any((e) => e.code == 'consent.no_items'), isTrue);
      },
    );

    test('StudyFixtures.invalidInterventionNoTasks() passes with interventions.no_tasks as warning', () {
      final r = validateStudy(
        StudyFixtures.invalidInterventionNoTasks(),
        ValidationLevel.publish,
      );
      expect(r.valid, isTrue);
      expect(r.warnings.any((w) => w.code == 'interventions.no_tasks'), isTrue);
    });

    test('StudyFixtures.warningAlwaysTrueEligibility() has no errors but has warnings', () {
      final r = validateStudy(
        StudyFixtures.warningAlwaysTrueEligibility(),
        ValidationLevel.publish,
      );
      expect(r.valid, isTrue);
      expect(r.warnings, isNotEmpty);
      expect(
        r.warnings.any((w) => w.code == 'eligibility.condition_always_true'),
        isTrue,
      );
    });

    test('StudyFixtures.invalidDuplicateInterventionId() fails with interventions.duplicate_intervention_id', () {
      final r = validateStudy(
        StudyFixtures.invalidDuplicateInterventionId(),
        ValidationLevel.publish,
      );
      expect(r.valid, isFalse);
      expect(
        r.errors.any(
          (e) => e.code == 'interventions.duplicate_intervention_id',
        ),
        isTrue,
      );
    });

    test('StudyFixtures.invalidThreeInterventionsAlternating() passes (count enforced at enrolment)', () {
      final r = validateStudy(
        StudyFixtures.invalidThreeInterventionsAlternating(),
        ValidationLevel.publish,
      );
      expect(
        r.errors.where(
          (e) => e.code == 'interventions.count_must_be_two_for_sequence',
        ),
        isEmpty,
      );
    });

    test('StudyFixtures.invalidCustomSequenceBadChars() fails with schedule.custom_sequence_invalid_chars', () {
      final r = validateStudy(
        StudyFixtures.invalidCustomSequenceBadChars(),
        ValidationLevel.publish,
      );
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'schedule.custom_sequence_invalid_chars'),
        isTrue,
      );
    });

    test('StudyFixtures.invalidBadEmailFormat() fails with study_info.email_invalid_format', () {
      final r = validateStudy(
        StudyFixtures.invalidBadEmailFormat(),
        ValidationLevel.publish,
      );
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'study_info.email_invalid_format'),
        isTrue,
      );
    });
  });
}
