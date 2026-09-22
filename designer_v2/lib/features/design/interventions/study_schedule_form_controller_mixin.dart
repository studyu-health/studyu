import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_schedule.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/input_formatter.dart';

mixin StudyScheduleControls {
  static const defaultScheduleType = PhaseSequence.alternating;
  static const defaultScheduleTypeSequence = 'ABAB';
  static const defaultNumCycles = 2;
  static const defaultPeriodLength = 7;
  static final RegExp customSequencePattern = RegExp(r'^[ABab]+$');

  final FormControl<PhaseSequence> sequenceTypeControl = FormControl(
    value: defaultScheduleType,
  );
  final FormControl<String> sequenceTypeCustomControl = FormControl(
    value: defaultScheduleTypeSequence,
  );
  final FormControl<int> phaseDurationControl = FormControl(
    value: defaultPeriodLength,
  );
  final FormControl<int> numCyclesControl = FormControl(
    value: defaultNumCycles,
  );
  final FormControl<bool> includeBaselineControl = FormControl(value: true);

  List<FormControlOption<PhaseSequence>> get sequenceTypeControlOptions =>
      PhaseSequence.values.map((v) => FormControlOption(v, v.string)).toList();

  late final studyScheduleControls = {
    'sequenceType': sequenceTypeControl,
    'sequenceTypeCustom': sequenceTypeCustomControl,
    'numCycles': numCyclesControl,
    'phaseDuration': phaseDurationControl,
    'includeBaseline': includeBaselineControl,
  };

  FormValidationConfigSet get studyScheduleValidationConfig => {
    StudyFormValidationSet.draft: [],
    StudyFormValidationSet.publish: [
      customSequenceRequired,
      numCyclesRange,
      phaseDurationRange,
    ],
    StudyFormValidationSet.test: [
      customSequenceRequired,
      numCyclesRange,
      phaseDurationRange,
    ],
  };

  static int kNumCyclesMin = 1;
  static int kNumCyclesMax = 9;
  FormControlValidation get numCyclesRange => FormControlValidation(
    control: numCyclesControl,
    validators: [
      Validators.required,
      Validators.min(kNumCyclesMin),
      Validators.max(kNumCyclesMax),
    ],
    validationMessages: {
      ValidationMessage.required: (error) =>
          tr.form_field_crossover_schedule_num_cycles_range(
            kNumCyclesMin,
            kNumCyclesMax,
          ),
      ValidationMessage.min: (error) =>
          tr.form_field_crossover_schedule_num_cycles_range(
            kNumCyclesMin,
            kNumCyclesMax,
          ),
      ValidationMessage.max: (error) =>
          tr.form_field_crossover_schedule_num_cycles_range(
            kNumCyclesMin,
            kNumCyclesMax,
          ),
    },
  );

  static int kPhaseDurationMin = 1;
  static int kPhaseDurationMax = 365;
  FormControlValidation get phaseDurationRange => FormControlValidation(
    control: phaseDurationControl,
    validators: [
      Validators.required,
      Validators.min(kPhaseDurationMin),
      Validators.max(kPhaseDurationMax),
    ],
    validationMessages: {
      ValidationMessage.required: (error) =>
          tr.form_field_crossover_schedule_phase_length_range(
            kPhaseDurationMin,
            kPhaseDurationMax,
          ),
      ValidationMessage.min: (error) =>
          tr.form_field_crossover_schedule_phase_length_range(
            kPhaseDurationMin,
            kPhaseDurationMax,
          ),
      ValidationMessage.max: (error) =>
          tr.form_field_crossover_schedule_phase_length_range(
            kPhaseDurationMin,
            kPhaseDurationMax,
          ),
    },
  );

  FormControlValidation get customSequenceRequired => FormControlValidation(
    control: sequenceTypeCustomControl,
    validators: [Validators.delegate(_validateCustomSequence)],
    validationMessages: {
      ValidationMessage.required: (error) =>
          'Custom sequence needs to be specified.',
      ValidationMessage.pattern: (error) =>
          'Custom sequence can only contain A and B.',
    },
  );

  Map<String, dynamic>? _validateCustomSequence(
    AbstractControl<dynamic> control,
  ) {
    if (!isSequencingCustom()) return null;

    final value = control.value as String?;
    if (value == null || value.isEmpty) {
      return {ValidationMessage.required: true};
    }

    if (!customSequencePattern.hasMatch(value)) {
      return {ValidationMessage.pattern: true};
    }

    return null;
  }

  void setStudyScheduleControlsFrom(StudyScheduleFormData data) {
    sequenceTypeControl.value = data.sequenceType;
    sequenceTypeCustomControl.value = data.sequenceTypeCustom;
    numCyclesControl.value = data.numCycles;
    phaseDurationControl.value = data.phaseDuration;
    includeBaselineControl.value = data.includeBaseline;
  }

  StudyScheduleFormData buildStudyScheduleFormData() {
    return StudyScheduleFormData(
      sequenceType: sequenceTypeControl.value!, // required
      sequenceTypeCustom: normalizeStudySequenceInput(
        sequenceTypeCustomControl.value!,
      ), // required
      numCycles: numCyclesControl.value!, // required
      phaseDuration: phaseDurationControl.value!, // required
      includeBaseline: includeBaselineControl.value!, // required
    );
  }

  bool isSequencingCustom() {
    return sequenceTypeControl.value == PhaseSequence.customized;
  }
}
