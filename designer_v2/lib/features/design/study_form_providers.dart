import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/reports_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/fitbit_credentials_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

part 'study_form_providers.g.dart';

// - Study Info

@riverpod
StudyInfoFormViewModel studyInfoFormViewModel(Ref ref, StudyID studyId) {
  return ref.watch(studyFormViewModelProvider(studyId)).studyInfoFormViewModel;
}

// - Enrollment

@riverpod
EnrollmentFormViewModel enrollmentFormViewModel(Ref ref, StudyID studyId) {
  return ref.watch(studyFormViewModelProvider(studyId)).enrollmentFormViewModel;
}

@riverpod
ScreenerQuestionFormViewModel screenerQuestionFormViewModel(
  Ref ref,
  ScreenerQuestionFormRouteArgs args,
) {
  return ref.watch(enrollmentFormViewModelProvider(args.studyId)).provide(args);
}

@riverpod
ConsentItemFormViewModel consentItemFormViewModel(
  Ref ref,
  ConsentItemFormRouteArgs args,
) {
  return ref
      .watch(enrollmentFormViewModelProvider(args.studyId))
      .consentItemDelegate
      .provide(args);
}

// - Interventions

@riverpod
InterventionsFormViewModel interventionsFormViewModel(
  Ref ref,
  StudyID studyId,
) {
  return ref
      .watch(studyFormViewModelProvider(studyId))
      .interventionsFormViewModel;
}

@riverpod
InterventionFormViewModel interventionFormViewModel(
  Ref ref,
  InterventionFormRouteArgs args,
) {
  return ref
      .watch(interventionsFormViewModelProvider(args.studyId))
      .provide(args);
}

@riverpod
InterventionTaskFormViewModel interventionTaskFormViewModel(
  Ref ref,
  InterventionTaskFormRouteArgs args,
) {
  return ref.watch(interventionFormViewModelProvider(args)).provide(args);
}

// - Measurements

@riverpod
MeasurementsFormViewModel measurementsFormViewModel(Ref ref, StudyID studyId) {
  return ref
      .watch(studyFormViewModelProvider(studyId))
      .measurementsFormViewModel;
}

@riverpod
ManagedFormViewModel? measurementFormViewModel(
  Ref ref,
  MeasurementFormRouteArgs args,
) {
  try {
    return ref
            .watch(measurementsFormViewModelProvider(args.studyId))
            .provideWithType(args, args.queryParams['type'])
        as ManagedFormViewModel;
  } on MeasurementNotFoundException {
    return null;
  }
}

@riverpod
QuestionFormViewModel surveyQuestionFormViewModel(
  Ref ref,
  SurveyQuestionFormRouteArgs args,
) {
  return (ref.watch(measurementFormViewModelProvider(args))!
          as MeasurementSurveyFormViewModel)
      .provide(args);
}

// - Reports

@riverpod
ReportsFormViewModel reportsFormViewModel(Ref ref, StudyID studyId) {
  return ref.watch(studyFormViewModelProvider(studyId)).reportsFormViewModel;
}

@riverpod
ReportItemFormViewModel reportItemFormViewModel(
  Ref ref,
  ReportItemFormRouteArgs args,
) {
  return ref
      .watch(reportsFormViewModelProvider(args.studyId))
      .reportItemDelegate
      .provide(args);
}

// - Validators

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.publish]
@riverpod
StudyFormViewModel studyPublishValidator(Ref ref, StudyID studyId) {
  final state = ref.watch(studyControllerProvider(studyId));
  return StudyFormViewModel(
    router: ref.watch(routerProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    fitbitCredentialsRepository: ref.watch(
      fitbitCredentialsRepositoryProvider(studyId),
    ),
    formData: state.studyValueRequired,
    validationSet: StudyFormValidationSet.publish,
  );
}

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.test]
@riverpod
StudyFormViewModel studyTestValidator(Ref ref, StudyID studyId) {
  final formViewModel = ref.watch(studyFormViewModelProvider(studyId));
  final subscription = formViewModel.form.valueChanges.listen(
    (_) => ref.invalidateSelf(),
  );
  ref.onDispose(subscription.cancel);

  return StudyFormViewModel(
    router: ref.watch(routerProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    fitbitCredentialsRepository: ref.watch(
      fitbitCredentialsRepositoryProvider(studyId),
    ),
    formData: formViewModel.buildFormData(),
    validationSet: StudyFormValidationSet.test,
  );
}
