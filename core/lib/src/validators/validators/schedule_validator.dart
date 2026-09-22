import 'package:studyu_core/src/models/study_schedule/study_schedule.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

ValidationResult validateSchedule(Study study, ValidationLevel level) {
  final errors = <ValidationError>[];

  if (study.schedule.phaseDuration <= 0) {
    errors.add(
      const ValidationError(
        code: 'schedule.phase_duration_invalid',
        path: r'$.schedule.phaseDuration',
        message: 'phaseDuration must be greater than 0',
        fixHint: 'Set phaseDuration to at least 1',
      ),
    );
  }

  if (study.schedule.numberOfCycles <= 0) {
    errors.add(
      const ValidationError(
        code: 'schedule.number_of_cycles_invalid',
        path: r'$.schedule.numberOfCycles',
        message: 'numberOfCycles must be greater than 0',
        fixHint: 'Set numberOfCycles to at least 1',
      ),
    );
  }

  // Facts 19-20 — custom sequence validation
  if (study.schedule.sequence == PhaseSequence.customized) {
    final custom = study.schedule.sequenceCustom;
    if (custom.trim().isEmpty) {
      errors.add(
        const ValidationError(
          code: 'schedule.custom_sequence_empty',
          path: r'$.schedule.sequenceCustom',
          message:
              'sequenceCustom must not be blank when sequence is customized',
          fixHint: 'Set sequenceCustom to a non-empty string of A and B characters, e.g. "AABB".',
        ),
      );
    } else if (!RegExp(r'^[ABab]+$').hasMatch(custom)) {
      errors.add(
        ValidationError(
          code: 'schedule.custom_sequence_invalid_chars',
          path: r'$.schedule.sequenceCustom',
          message:
              'sequenceCustom "$custom" contains characters other than A and B',
          fixHint:
              'Use only A and B characters in sequenceCustom, e.g. "AABB".',
        ),
      );
    }
  }

  return ValidationResult(errors: errors, warnings: []);
}
