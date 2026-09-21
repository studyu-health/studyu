import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class FitbitCredentialsFormData({
  required final String clientId,
  required final String clientSecret,
}) implements IStudyFormData {
  factory fromStudy(Study study) {
    final fitbitCredentials = study.fitbitCredentials;
    return FitbitCredentialsFormData(
      clientId: fitbitCredentials?.fitbitCredentials.clientId ?? '',
      clientSecret: fitbitCredentials?.fitbitCredentials.clientSecret ?? '',
    );
  }

  @override
  Study apply(Study study) {
    final credentials = FitbitAuthCredentials(
      clientId: clientId,
      clientSecret: clientSecret,
    );

    study.fitbitCredentials = StudyFitbitCredentials(study.id, credentials);

    return study;
  }

  @override
  IFormData copy() {
    throw UnimplementedError();
  }

  @override
  FormDataID get id => throw UnimplementedError();
}
