import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/consent_validator.dart';
import 'package:studyu_core/src/validators/validators/eligibility_consent_validator.dart';
import 'package:studyu_core/src/validators/validators/interventions_validator.dart';
import 'package:studyu_core/src/validators/validators/observations_validator.dart';
import 'package:studyu_core/src/validators/validators/questionnaire_validator.dart';
import 'package:studyu_core/src/validators/validators/report_validator.dart';
import 'package:studyu_core/src/validators/validators/schedule_validator.dart';
import 'package:studyu_core/src/validators/validators/study_info_validator.dart';

export 'validation_result.dart';

ValidationResult validateStudy(Study study, ValidationLevel level) =>
    ValidationResult.merge([
      validateStudyInfo(study, level),
      validateInterventions(study, level),
      validateQuestionnaire(study.questionnaire, r'$.questionnaire', level),
      validateSchedule(study, level),
      validateConsent(study, level),
      validateObservations(study, level),
      validateReport(study, level),
      validateEligibilityConsent(study, level),
    ]);
