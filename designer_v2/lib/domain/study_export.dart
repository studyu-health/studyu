import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

abstract class ResultTypes();

class MeasurementResultTypes() extends ResultTypes {
  static const String questionnaire = 'QuestionnaireState';
  static List<String> get values => [questionnaire];
}

class InterventionResultTypes() extends ResultTypes {
  static const String checkmarkTask = 'bool';
  static List<String> get values => [checkmarkTask];
}

class StudyExportData({
  required final Study study,
  required final List<Map<String, dynamic>> measurementsData,
  required final List<Map<String, dynamic>> interventionsData,
  required final List<String> mediaData,
}) {
  bool get isEmpty => measurementsData.isEmpty && interventionsData.isEmpty;
}

extension StudyExportX on Study {
  // TODO: add missing records from generated schedule

  static dynamic _formatQuestionResponse(dynamic response, Question? question) {
    if (question is ChoiceQuestion && response is List<String>) {
      return _formatChoiceResponse(response, question);
    }
    return response.toString();
  }

  static List<Map<String, String>> _formatChoiceResponse(
    List<String> choiceIds,
    ChoiceQuestion question,
  ) {
    return choiceIds.map((id) {
      final choice = question.choices.firstWhereOrNull((c) => c.id == id);
      final text = choice?.text ?? id;
      return {'id': id, 'text': text};
    }).toList();
  }

  StudyExportData get exportData {
    final List<Map<String, dynamic>> measurementsData = [];
    final List<Map<String, dynamic>> interventionsData = [];
    final List<String> mediaData = [];

    final List<SubjectProgress> records = participantsProgress ?? [];
    records.sort(
      (b, a) => a.completedAt!.compareTo(b.completedAt!),
    ); // descending

    // Key used as a placeholder for values that cannot be resolved by their
    // id anymore (e.g. because the study design has changed meanwhile)
    final invalidKey = 'N/A'.hardcoded;

    // Build columns dynamically for each question in each survey
    final Map<String, dynamic> surveyColumns = {};
    final Map<String, String> responseColumnById = {};
    final Map<String, String> surveyAnsweredColumnById = {};
    final Map<String, Question> questionById = {};
    final mediaIndices = [];

    for (var i = 1; i < observations.length + 1; i++) {
      final surveyMeasurement = observations[i - 1] as QuestionnaireTask;
      final surveyQuestions = surveyMeasurement.questions.questions;
      surveyColumns['survey${i}_id'] = surveyMeasurement.id;
      surveyColumns['survey${i}_name'] = surveyMeasurement.title;
      surveyColumns['is_survey$i'] = false;
      surveyAnsweredColumnById[surveyMeasurement.id] = 'is_survey$i';

      for (var j = 1; j < surveyQuestions.length + 1; j++) {
        final question = surveyQuestions[j - 1];
        surveyColumns['survey${i}_question${j}_id'] = question.id;
        surveyColumns['survey${i}_question${j}_text'] = question.prompt;
        surveyColumns['survey${i}_question${j}_response'] = '';
        responseColumnById[question.id] = 'survey${i}_question${j}_response';
        questionById[question.id] = question;
        if (question.type == AudioRecordingQuestion.questionType ||
            question.type == ImageCapturingQuestion.questionType) {
          mediaIndices.add(question.id);
        }
      }
    }

    for (final record in records) {
      final intervention = getIntervention(record.interventionId);
      final Map<String, dynamic> rowShared = {
        'participant_id': record.subjectId,
        'participant_started_at': record.startedAt!.toString(),
        'invite_code':
            participants!
                .where((element) => element.id == record.subjectId)
                .firstWhereOrNull((_) => true)
                ?.inviteCode ??
            '',
        'current_day_of_study': record.completedAt!
            .difference(record.startedAt!)
            .inDays
            .toString(),
        'current_intervention_id': record.interventionId,
        'current_intervention_name': intervention?.name ?? invalidKey,
      };

      final isMeasurement = MeasurementResultTypes.values.contains(
        record.resultType,
      );
      final isIntervention = InterventionResultTypes.values.contains(
        record.resultType,
      );

      if (isMeasurement) {
        final measurement = observations.firstWhereOrNull(
          (o) => o.id == record.taskId,
        );
        final Map<String, dynamic> row = {
          'measurement_time': record.completedAt!.toString(),
          'measurement_id': record.taskId,
          'measurement_name': measurement?.title ?? invalidKey,
          ...rowShared,
        };

        if (record.resultType == MeasurementResultTypes.questionnaire) {
          // Add survey + question columns
          row.addAll(surveyColumns);

          // Populate question columns with submitted response data
          final submittedSurvey = record.result.result as QuestionnaireState;
          final submittedQuestionAnswerPairs = submittedSurvey.answers.values;

          for (final questionAnswerPair in submittedQuestionAnswerPairs) {
            final questionId = questionAnswerPair.question;
            final questionResponseColumn = responseColumnById[questionId];
            final surveyAnsweredColumn =
                surveyAnsweredColumnById[record.taskId]!;
            if (questionResponseColumn == null) {
              continue; // skip unresolvable questions (e.g. because study design has changed)
            }
            final responseValue = StudyExportX._formatQuestionResponse(
              questionAnswerPair.response,
              questionById[questionId],
            );
            row[questionResponseColumn] = responseValue;
            row[surveyAnsweredColumn] = true;
            for (final mediaIndex in mediaIndices) {
              if (mediaIndex == questionId) {
                mediaData.add(responseValue.toString());
              }
            }
          }
        }
        measurementsData.add(row);
      } else if (isIntervention) {
        final task = intervention?.tasks.firstWhereOrNull(
          (e) => e.id == record.taskId,
        );
        final Map<String, dynamic> row = {
          'intervention_task_time': record.completedAt!.toString(),
          'intervention_task_id': record.taskId,
          'intervention_task_name': task?.title ?? invalidKey,
          'is_completed': true, // TODO add missed task from generated schedule
          ...rowShared,
        };
        interventionsData.add(row);
      }
    }
    return StudyExportData(
      study: this,
      measurementsData: measurementsData,
      interventionsData: interventionsData,
      mediaData: mediaData,
    );
  }
}
