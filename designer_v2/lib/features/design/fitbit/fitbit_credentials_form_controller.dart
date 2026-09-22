import 'package:reactive_forms/reactive_forms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/fitbit_credentials_repository.dart';

part 'fitbit_credentials_form_controller.g.dart';

//TODO: right now FitbitCredentials is part of Study form controller, this is not an issue it still works but I think I need to refactor it.
class FitbitCredentialsFormViewModel({
  required final Study study,
  required final IFitbitCredentialsRepository fitbitCredentialsRepository,
  super.delegate,
  super.formData,
  super.autosave = true,
  super.validationSet,
}) extends FormViewModel<StudyFitbitCredentials> {
  // - Form fields

  final FormControl<String> clientIdControl = FormControl();
  final FormControl<String> clientSecretControl = FormControl();
  bool _questionValidationEnabled = false;

  @override
  void initControls() {
    clientIdControl.value =
        study.fitbitCredentials?.fitbitCredentials.clientId ?? '';
    clientSecretControl.value =
        study.fitbitCredentials?.fitbitCredentials.clientSecret ?? '';
  }

  @override
  late final FormGroup form = FormGroup({
    'client_id': clientIdControl,
    'client_secret': clientSecretControl,
  });

  @override
  void setControlsFrom(StudyFitbitCredentials data) {
    clientIdControl.value = data.fitbitCredentials.clientId;
    clientSecretControl.value = data.fitbitCredentials.clientSecret;
  }

  @override
  StudyFitbitCredentials buildFormData() {
    return StudyFitbitCredentials(
      study.id,
      FitbitAuthCredentials(
        clientId: clientIdControl.value ?? '',
        clientSecret: clientSecretControl.value ?? '',
      ),
    );
  }

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: _questionValidationEnabled
        ? [clientIdRequired, clientSecretRequired]
        : [],
    StudyFormValidationSet.publish: [
      if (_questionValidationEnabled) clientIdRequired,
      if (_questionValidationEnabled) clientSecretRequired,
      fitbitCredentialsValidation,
    ],
    StudyFormValidationSet.test: _questionValidationEnabled
        ? [clientIdRequired, clientSecretRequired]
        : [],
  };

  FormControlValidation get clientIdRequired => FormControlValidation(
    control: clientIdControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (_) => tr.fitbit_client_id_required,
    },
  );

  FormControlValidation get clientSecretRequired => FormControlValidation(
    control: clientSecretControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (_) => tr.fitbit_client_secret_required,
    },
  );

  void enableQuestionValidation() {
    _questionValidationEnabled = true;
    revalidate();
    form.updateValueAndValidity();
  }

  FormControlValidation get fitbitCredentialsValidation =>
      FormControlValidation(
        control: form,
        validators: [Validators.delegate(_validateFitbitCredentials)],
        validationMessages: {
          'fitbitCredentialsRequired': (_) => 'Fitbit credentials are required',
        },
      );

  //TODO: translations
  Map<String, dynamic>? _validateFitbitCredentials(
    AbstractControl<dynamic> control,
  ) {
    final hasFitbitQuestion = study.observations.any((observation) {
      if (observation.type != 'questionnaire') return false;

      final questionnaire = observation as QuestionnaireTask;
      return questionnaire.questions.questions.any(
        (question) => question is FitbitQuestion,
      );
    });

    if (!hasFitbitQuestion) return null;

    if (control is FormGroup) {
      final clientId = control.control('client_id').value as String?;
      final clientSecret = control.control('client_secret').value as String?;

      if (clientId == null || clientId.isEmpty) {
        return {'fitbitCredentialsRequired': true};
      }

      if (clientSecret == null || clientSecret.isEmpty) {
        return {'fitbitCredentialsRequired': true};
      }
    }

    return null;
  }

  Study apply(Study study) {
    return study;
  }

  @override
  Future<StudyFitbitCredentials> save({bool updateState = true}) {
    return fitbitCredentialsRepository
        .save(buildFormData())
        .then((wrapped) => wrapped!.model);
  }

  @override
  // TODO: implement titles
  Map<FormMode, String> get titles => throw UnimplementedError();
}

@riverpod
FitbitCredentialsFormViewModel fitbitCredentialsFormViewModel(
  Ref ref,
  StudyID studyId,
) {
  final state = ref.watch(studyControllerProvider(studyId));

  final fitbitCredentialsRepository = ref.watch(
    fitbitCredentialsRepositoryProvider(studyId),
  );

  return FitbitCredentialsFormViewModel(
    study: state.studyValueRequired,
    validationSet: StudyFormValidationSet.draft,
    fitbitCredentialsRepository: fitbitCredentialsRepository,
  );
}
