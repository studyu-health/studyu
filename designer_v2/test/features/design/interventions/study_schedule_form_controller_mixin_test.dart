import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';

void main() {
  group('StudyScheduleControls', () {
    test('does not require an empty custom sequence after switching away from custom sequencing', () {
      final controls = _StudyScheduleTestControls();
      final validation = controls.customSequenceRequired;
      controls.sequenceTypeCustomControl.setValidators(validation.validators);

      controls.sequenceTypeControl.value = PhaseSequence.customized;
      controls.sequenceTypeCustomControl.value = '';
      controls.sequenceTypeCustomControl.updateValueAndValidity();

      expect(controls.sequenceTypeCustomControl.valid, isFalse);
      expect(
        controls.sequenceTypeCustomControl.errors,
        contains(ValidationMessage.required),
      );

      controls.sequenceTypeControl.value = PhaseSequence.alternating;
      controls.sequenceTypeCustomControl.updateValueAndValidity();

      expect(controls.sequenceTypeCustomControl.valid, isTrue);
      expect(controls.sequenceTypeCustomControl.errors, isEmpty);
    });
  });
}

class _StudyScheduleTestControls() with StudyScheduleControls;
