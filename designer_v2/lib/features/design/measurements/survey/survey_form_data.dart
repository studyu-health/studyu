import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class MeasurementSurveyFormData({
  required final MeasurementID measurementId,
  required super.instanceId,
  required final String title,
  final String? introText,
  final String? outroText,
  required super.isTimeLocked,
  super.timeLockStart,
  super.timeLockEnd,
  required super.hasReminder,
  super.reminderTime,
  required final QuestionnaireFormData questionnaireFormData,
}) extends IFormDataWithSchedule {
  static String get kDefaultTitle =>
      tr.form_field_measurement_survey_title_default;

  @override
  FormDataID get id => measurementId;

  factory fromDomainModel(QuestionnaireTask questionnaireTask) {
    return MeasurementSurveyFormData(
      measurementId: questionnaireTask.id,
      title: questionnaireTask.title ?? '',
      introText: questionnaireTask.header,
      outroText: questionnaireTask.footer,
      questionnaireFormData: QuestionnaireFormData.fromDomainModel(
        questionnaireTask.questions,
        [],
      ),
      isTimeLocked: questionnaireTask.schedule.isTimeRestricted,
      timeLockStart: questionnaireTask.schedule.restrictedTimeStart,
      timeLockEnd: questionnaireTask.schedule.restrictedTimeEnd,
      hasReminder: questionnaireTask.schedule.hasReminder,
      reminderTime: questionnaireTask.schedule.reminderTime,
      instanceId: questionnaireTask.schedule.instanceId,
    );
  }

  QuestionnaireTask toQuestionnaireTask() {
    final questionnaireTask = QuestionnaireTask();
    questionnaireTask.id = measurementId;
    questionnaireTask.title = title;
    questionnaireTask.header = introText;
    questionnaireTask.footer = outroText;
    questionnaireTask.questions = questionnaireFormData.toQuestionnaire();
    questionnaireTask.schedule = toSchedule();
    return questionnaireTask;
  }

  @override
  MeasurementSurveyFormData copy() {
    return MeasurementSurveyFormData(
      measurementId: const Uuid().v4(), // always regenerate id
      instanceId: const Uuid().v4(), // always regenerate id
      title: title.withDuplicateLabel(),
      introText: introText,
      outroText: outroText,
      questionnaireFormData: questionnaireFormData.copy(),
      isTimeLocked: isTimeLocked,
      timeLockStart: timeLockStart,
      timeLockEnd: timeLockEnd,
      hasReminder: hasReminder,
      reminderTime: reminderTime,
    );
  }
}
