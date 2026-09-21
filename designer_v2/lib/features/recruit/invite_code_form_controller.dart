import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/domain/study_schedule.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_repository.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:uuid/uuid.dart';

class InviteCodeFormViewModel({
  required final Study study,
  required final InviteCodeFormRepository inviteCodeRepository,
  super.formData,
  super.delegate,
  super.validationSet = StudyFormValidationSet.draft,
}) extends FormViewModel<StudyInvite> {
  @override
  Map<FormMode, String> get titles => {
    FormMode.create: tr.form_code_create,
    FormMode.edit: tr.form_code_readonly,
    FormMode.readonly: tr.form_code_readonly,
  };

  // - Form Fields

  final codeControl = FormControl<String>(touched: true);
  final isPreconfiguredScheduleControl = FormControl<bool>(value: false);
  final preconfiguredScheduleTypeControl = FormControl<PhaseSequence>(
    value: PhaseSequence.alternating,
  );
  final interventionAControl = FormControl<String>();
  final interventionBControl = FormControl<String>();

  // todo add validation for preconfigured schedule if enabled
  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [codeValidation],
    StudyFormValidationSet.test: [codeValidation],
    StudyFormValidationSet.publish: [codeValidation],
  };

  FormControlValidation get codeRequired => FormControlValidation(
    control: codeControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (error) => tr.form_field_code_required,
    },
  );

  FormControlValidation get codeValidation => FormControlValidation(
    control: codeControl,
    validators: [
      Validators.required,
      Validators.minLength(8),
      Validators.maxLength(24),
    ],
    asyncValidators: [
      Validators.delegateAsync(
        (control) => _uniqueInviteCode(control),
        debounceTime: 200,
      ),
    ],
    validationMessages: {
      ValidationMessage.required: (error) => tr.form_field_code_required,
      ValidationMessage.minLength: (error) =>
          tr.form_field_code_minlength((error as Map)['requiredLength'] as int),
      ValidationMessage.maxLength: (error) =>
          tr.form_field_code_maxlength((error as Map)['requiredLength'] as int),
      'inviteCodeAlreadyUsed': (_) => tr.form_field_code_alreadyused,
    },
  );

  List<FormControlOption<String>> get interventionControlOptions => study
      .interventions
      .map(
        (intervention) =>
            FormControlOption(intervention.id, intervention.name!),
      )
      .toList();

  List<FormControlOption<PhaseSequence>> get preconfiguredScheduleTypeOptions =>
      [
        FormControlOption(
          PhaseSequence.alternating,
          PhaseSequence.alternating.string,
        ),
      ];

  bool get isPreconfiguredSchedule => isPreconfiguredScheduleControl.value!;

  List<String>? get preconfiguredSchedule =>
      (isPreconfiguredSchedule &&
          interventionAControl.value != null &&
          interventionBControl.value != null)
      ? [interventionAControl.value!, interventionBControl.value!]
      : null;

  @override
  late final form = FormGroup({
    'code': codeControl,
    'isPreconfiguredSchedule': isPreconfiguredScheduleControl,
    'interventionA': interventionAControl,
    'interventionB': interventionBControl,
  });

  @override
  void initControls() {
    regenerateCode(); // initialize randomly
    syncCodeControlEnabledState();
    prevFormValue = {...form.value};
  }

  @override
  set formMode(FormMode mode) {
    super.formMode = mode;
    syncCodeControlEnabledState();
  }

  void syncCodeControlEnabledState() {
    if (formMode == FormMode.edit) {
      codeControl.markAsDisabled();
      return;
    }
    codeControl.markAsEnabled();
  }

  // - Validation

  Future<Map<String, dynamic>?> _uniqueInviteCode(
    AbstractControl control,
  ) async {
    final code = _normalizeCode(control.value as String?);
    if (code.isEmpty || _matchesExistingInviteCode(code)) {
      return null;
    }

    final isCodeAlreadyUsed = await inviteCodeRepository.isCodeAlreadyUsed(
      code,
    );
    final error = {'inviteCodeAlreadyUsed': true};

    if (isCodeAlreadyUsed) {
      control.markAsTouched();
      return error;
    }
    return null;
  }

  bool _matchesExistingInviteCode(String code) {
    final existingCode = formData?.code;
    if (existingCode == null) {
      return false;
    }
    return code == _normalizeCode(existingCode);
  }

  String _normalizeCode(String? code) {
    return code?.trim().toLowerCase() ?? '';
  }

  void regenerateCode() {
    codeControl.value = _generateCode();
  }

  String _generateCode() {
    final studyComponent = study.id.substring(0, 8);
    final uniqueComponent = const Uuid().v4().substring(0, 8);
    final code = "$uniqueComponent-$studyComponent";
    return code;
  }

  @override
  StudyInvite buildFormData() {
    final code = formMode == FormMode.edit && formData != null
        ? formData!.code
        : codeControl.value!.trim().toLowerCase();
    return StudyInvite(
      code,
      study.id,
      preselectedInterventionIds: preconfiguredSchedule,
    );
  }

  @override
  void setControlsFrom(StudyInvite data) {
    codeControl.value = data.code;
    isPreconfiguredScheduleControl.value = data.hasPreconfiguredSchedule;
    if (data.hasPreconfiguredSchedule) {
      interventionAControl.value = data.preselectedInterventionIds![0];
      interventionBControl.value = data.preselectedInterventionIds![1];
    }
    syncCodeControlEnabledState();
  }

  @override
  Future<StudyInvite> save({bool updateState = true}) {
    final nextInvite = buildFormData();
    final saveOperation = inviteCodeRepository.save(
      nextInvite,
      runOptimistically: false,
    );

    return saveOperation.then((wrapped) {
      if (updateState) {
        formData = wrapped!.model;
        syncCodeControlEnabledState();
        finalizeInitializationBaseline();
      }
      return wrapped!.model;
    });
  }
}
