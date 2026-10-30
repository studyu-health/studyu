import 'package:studyu_core/src/models/interventions/intervention.dart';
import 'package:studyu_core/src/models/study_schedule/study_schedule.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/schedule_validator.dart';
import 'package:test/test.dart';

void main() {
  test('fails when phaseDuration is 0', () {
    final s = Study('id', 'user');
    s.schedule.phaseDuration = 0;
    final r = validateSchedule(s, ValidationLevel.publish);
    expect(r.valid, isFalse);
    expect(r.errors.first.code, 'schedule.phase_duration_invalid');
  });

  test('passes with valid schedule and matching intervention count', () {
    final s = Study('id', 'user');
    s.schedule.phaseDuration = 7;
    s.schedule.numberOfCycles = 2;
    s.interventions = [Intervention.withId(), Intervention.withId()];
    final r = validateSchedule(s, ValidationLevel.publish);
    expect(r.valid, isTrue);
  });

  group('custom sequence', () {
    test('customized sequence with empty sequenceCustom -> schedule.custom_sequence_empty', () {
      final s = Study('id', 'user');
      s.schedule.phaseDuration = 7;
      s.schedule.numberOfCycles = 2;
      s.schedule.sequence = PhaseSequence.customized;
      s.schedule.sequenceCustom = '';
      final r = validateSchedule(s, ValidationLevel.draft);
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'schedule.custom_sequence_empty'),
        isTrue,
      );
    });

    test('customized sequence with whitespace-only sequenceCustom -> schedule.custom_sequence_empty', () {
      final s = Study('id', 'user');
      s.schedule.phaseDuration = 7;
      s.schedule.numberOfCycles = 2;
      s.schedule.sequence = PhaseSequence.customized;
      s.schedule.sequenceCustom = '   ';
      final r = validateSchedule(s, ValidationLevel.draft);
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'schedule.custom_sequence_empty'),
        isTrue,
      );
    });

    test('customized sequence with invalid chars "ABCX" -> schedule.custom_sequence_invalid_chars', () {
      final s = Study('id', 'user');
      s.schedule.phaseDuration = 7;
      s.schedule.numberOfCycles = 2;
      s.schedule.sequence = PhaseSequence.customized;
      s.schedule.sequenceCustom = 'ABCX';
      final r = validateSchedule(s, ValidationLevel.draft);
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'schedule.custom_sequence_invalid_chars'),
        isTrue,
      );
    });

    test('customized sequence with valid "AABB" -> passes', () {
      final s = Study('id', 'user');
      s.schedule.phaseDuration = 7;
      s.schedule.numberOfCycles = 2;
      s.schedule.sequence = PhaseSequence.customized;
      s.schedule.sequenceCustom = 'AABB';
      final r = validateSchedule(s, ValidationLevel.draft);
      expect(r.valid, isTrue);
    });

    test(
      'alternating sequence with non-empty sequenceCustom -> no custom check',
      () {
        final s = Study('id', 'user');
        s.schedule.phaseDuration = 7;
        s.schedule.numberOfCycles = 2;
        s.schedule.sequence = PhaseSequence.alternating;
        s.schedule.sequenceCustom = 'INVALID';
        final r = validateSchedule(s, ValidationLevel.draft);
        expect(
          r.errors.where(
            (e) => e.code == 'schedule.custom_sequence_invalid_chars',
          ),
          isEmpty,
        );
      },
    );
  });
}
