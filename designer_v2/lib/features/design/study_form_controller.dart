import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_data.dart';
import 'package:studyu_designer_v2/features/design/fitbit/fitbit_credentials_form_controller.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_controller.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_data.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/reports/reports_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/reports_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/fitbit_credentials_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';

part 'study_form_controller.g.dart';

class StudyFormViewModel({
  required final GoRouter router,
  required final IStudyRepository studyRepository,
  required final IAuthRepository authRepository,
  required final IFitbitCredentialsRepository fitbitCredentialsRepository,
  required super.formData, // Study
  super.validationSet = StudyFormValidationSet.draft,
}) extends FormViewModel<Study>
    implements IFormViewModelDelegate<FormViewModel> {
  this {
    if (isStudyReadonly) {
      read();
    }
  }

  /// On-write copy of the [Study] object managed by the view model
  Study? studyDirtyCopy;

  bool get isStudyReadonly =>
      formData?.isReadonly(authRepository.currentUser!) ?? false;

  late final StudyInfoFormViewModel studyInfoFormViewModel =
      StudyInfoFormViewModel(
        formData: StudyInfoFormData.fromStudy(formData!),
        delegate: this,
        study: formData!,
        validationSet: validationSet,
      );

  late final EnrollmentFormViewModel enrollmentFormViewModel =
      EnrollmentFormViewModel(
        formData: EnrollmentFormData.fromStudy(formData!),
        delegate: this,
        study: formData!,
        router: router,
        validationSet: validationSet,
      );

  late final MeasurementsFormViewModel measurementsFormViewModel =
      MeasurementsFormViewModel(
        formData: MeasurementsFormData.fromStudy(formData!),
        delegate: this,
        study: formData!,
        router: router,
        validationSet: validationSet,
      );

  late final ReportsFormViewModel reportsFormViewModel = ReportsFormViewModel(
    formData: ReportsFormData.fromStudy(formData!),
    delegate: this,
    study: formData!,
    router: router,
    validationSet: validationSet,
  );

  late final InterventionsFormViewModel interventionsFormViewModel =
      InterventionsFormViewModel(
        formData: InterventionsFormData.fromStudy(formData!),
        delegate: this,
        study: formData!,
        router: router,
        validationSet: validationSet,
      );

  late final FitbitCredentialsFormViewModel fitbitCredentialsFormViewModel =
      FitbitCredentialsFormViewModel(
        study: formData!,
        validationSet: validationSet,
        fitbitCredentialsRepository: fitbitCredentialsRepository,
      );

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [], // defined in subforms
    StudyFormValidationSet.publish: [], // defined in subforms
    StudyFormValidationSet.test: [], // defined in subforms
  };

  @override
  late final FormGroup form = FormGroup({
    'info': studyInfoFormViewModel.form,
    'enrollment': enrollmentFormViewModel.form,
    'measurements': measurementsFormViewModel.form,
    'interventions': interventionsFormViewModel.form,
    'reports': reportsFormViewModel.form,
    'fitbit': fitbitCredentialsFormViewModel.form,
  });

  @override
  void read([Study? formData]) {
    // Put all subforms into readonly mode
    studyInfoFormViewModel.read();
    enrollmentFormViewModel.read();
    measurementsFormViewModel.read();
    interventionsFormViewModel.read();
    reportsFormViewModel.read();
    fitbitCredentialsFormViewModel.read();
    super.read(formData);
  }

  @override
  void setControlsFrom(Study data) {
    return; // subforms manage their own controls
  }

  @override
  Study buildFormData() {
    final studyCopy = (formData!).exactDuplicate();
    studyInfoFormViewModel.buildFormData().apply(studyCopy);
    enrollmentFormViewModel.buildFormData().apply(studyCopy);
    measurementsFormViewModel.buildFormData().apply(studyCopy);
    interventionsFormViewModel.buildFormData().apply(studyCopy);
    reportsFormViewModel.buildFormData().apply(studyCopy);
    return studyCopy;
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // unused

  @override
  void dispose() {
    studyInfoFormViewModel.dispose();
    enrollmentFormViewModel.dispose();
    interventionsFormViewModel.dispose();
    measurementsFormViewModel.dispose();
    reportsFormViewModel.dispose();
    super.dispose();
  }

  @override
  void onCancel(FormViewModel formViewModel, FormMode prevFormMode) {
    return; // nothing to do
  }

  @override
  Future onSave(FormViewModel formViewModel, FormMode prevFormMode) async {
    assert(prevFormMode == FormMode.edit);
    await _applyAndSaveSubform(formViewModel.formData! as IStudyFormData);
  }

  Future _applyAndSaveSubform(IStudyFormData subformData) {
    studyDirtyCopy ??= formData!.exactDuplicate();
    subformData.apply(studyDirtyCopy!);
    // Flush the on-write study copy to the repository and clear it
    return studyRepository
        .save(studyDirtyCopy!)
        .then((study) => studyDirtyCopy = null);
  }
}

/// Provides the [FormViewModel] that is responsible for displaying and
/// editing the study design form.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
@riverpod
StudyFormViewModel studyFormViewModel(Ref ref, StudyID studyId) {
  final state = ref.watch(studyControllerProvider(studyId));
  return StudyFormViewModel(
    router: ref.watch(routerProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    fitbitCredentialsRepository: ref.watch(
      fitbitCredentialsRepositoryProvider(studyId),
    ),
    formData: state.studyValueRequired,
  );
}
