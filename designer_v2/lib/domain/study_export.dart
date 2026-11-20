import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

abstract class ResultTypes();

class MeasurementResultTypes() extends ResultTypes {
  static const String questionnaire = 'QuestionnaireState';
  static const String nutrition = 'DailyRecall';
  static List<String> get values => [questionnaire, nutrition];
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

  static DateTime _recordTime(SubjectProgress record) {
    final result = record.result.result;
    return (result is DailyRecall ? result.entryCompletedAt : null) ??
        record.completedAt!;
  }

  static dynamic _formatQuestionResponse(dynamic response, Question question) {
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

    final records = [...?participantsProgress];
    records.sort(
      (b, a) => _recordTime(a).compareTo(_recordTime(b)),
    ); // descending
    final inviteCodeByParticipant = {
      for (final participant in participants ?? <StudySubject>[])
        participant.id: participant.inviteCode,
    };

    // Key used as a placeholder for values that cannot be resolved by their
    // id anymore (e.g. because the study design has changed meanwhile)
    final invalidKey = 'N/A'.hardcoded;

    // Build columns dynamically for each question in each survey
    final Map<String, dynamic> surveyColumns = {};
    final Map<String, String> surveyAnsweredColumnById = {};
    final questionColumns =
        <(String, String), ({String column, Question question})>{};

    // Filter observations to only include QuestionnaireTask instances
    final questionnaireTasks = observations
        .whereType<QuestionnaireTask>()
        .toList();

    for (var i = 1; i < questionnaireTasks.length + 1; i++) {
      final surveyMeasurement = questionnaireTasks[i - 1];
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
        final key = (surveyMeasurement.id, question.id);
        questionColumns[key] = (
          column: 'survey${i}_question${j}_response',
          question: question,
        );
      }
    }

    for (final record in records) {
      final dailyRecall = record.resultType == MeasurementResultTypes.nutrition
          ? record.result.result as DailyRecall
          : null;
      final recallCompletion = dailyRecall?.entryCompletedAt;
      if (dailyRecall != null &&
          (recallCompletion == null ||
              dailyRecall.studyDaySnapshot == null ||
              record.result.periodId == null)) {
        continue;
      }

      final intervention = getIntervention(record.interventionId);
      final startedAt = record.startedAt;
      final completedAt = record.completedAt!;
      final studyDay = dailyRecall == null
          ? startedAt == null
                ? null
                : completedAt.difference(startedAt).inDays
          : dailyRecall.studyDaySnapshot;
      final Map<String, dynamic> rowShared = {
        'participant_id': record.subjectId,
        'participant_started_at': startedAt?.toString() ?? '',
        'invite_code': inviteCodeByParticipant[record.subjectId] ?? '',
        'current_day_of_study': studyDay?.toString() ?? '',
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
          'measurement_time': (recallCompletion ?? completedAt).toString(),
          'measurement_id': record.taskId,
          'measurement_name': measurement?.title ?? invalidKey,
          if (dailyRecall != null)
            'measurement_period_id': record.result.periodId,
          ...rowShared,
        };

        if (record.resultType == MeasurementResultTypes.questionnaire) {
          // Add survey + question columns
          row.addAll(surveyColumns);

          // Populate question columns with submitted response data
          final submittedSurvey = record.result.result as QuestionnaireState;
          final submittedQuestionAnswerPairs = submittedSurvey.answers.values;
          final surveyAnsweredColumn = surveyAnsweredColumnById[record.taskId];

          for (final questionAnswerPair in submittedQuestionAnswerPairs) {
            final key = (record.taskId, questionAnswerPair.question);
            final questionColumn = questionColumns[key];
            if (surveyAnsweredColumn == null || questionColumn == null) {
              continue; // skip unresolvable questions (e.g. because study design has changed)
            }
            final (:column, :question) = questionColumn;
            final responseValue = StudyExportX._formatQuestionResponse(
              questionAnswerPair.response,
              question,
            );
            row[column] = responseValue;
            row[surveyAnsweredColumn] = true;
            if (question is AudioRecordingQuestion ||
                question is ImageCapturingQuestion) {
              mediaData.add(responseValue.toString());
            }
          }
        } else if (dailyRecall != null) {
          final nutrition = dailyRecall.totalNutrition;

          for (final entry in {
            'total_calories': 'energyKcal',
            'total_protein': 'protein',
            'total_carbs': 'carbs',
            'total_fat': 'fat',
          }.entries) {
            final known = nutrition.isKnown(entry.value);
            row[entry.key] = known ? nutrition.valueFor(entry.value) : '';
            row['${entry.key}_status'] = !known
                ? 'unknown'
                : nutrition.isPartial(entry.value)
                ? 'partial'
                : 'complete';
          }
          row['meal_count'] = dailyRecall.meals
              .where((MealLog meal) => !meal.isSkipped)
              .length;
          row['entry_completed_at'] = recallCompletion!.toString();
          row['water_intake_ml'] = dailyRecall.waterIntakeMl;
        }
        measurementsData.add(row);
      } else if (isIntervention) {
        final task = intervention?.tasks.firstWhereOrNull(
          (e) => e.id == record.taskId,
        );
        final Map<String, dynamic> row = {
          'intervention_task_time': completedAt.toString(),
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
