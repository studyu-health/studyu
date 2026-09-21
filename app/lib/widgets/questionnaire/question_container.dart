import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/audio_recording_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/image_capturing_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/question_header.dart';
import 'package:studyu_app/widgets/questionnaire/questions/annotated_scale_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/boolean_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/choice_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/date_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/fitbit_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/free_text_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/pain_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/scale_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/visual_analogue_question_widget.dart';
import 'package:studyu_core/core.dart';

class const QuestionContainer({
  required final Function(Answer, int) onDone,
  required final Question question,
  required final int index,
  final VoidCallback? onCleared,
  final String? taskId,
  final GlobalKey? containerKey,
  final Answer? initialAnswer,
  final void Function(String questionId, String value)? onFreeTextDraftChanged,
  final bool isLastQuestion = false,
  final GlobalKey<FreeTextQuestionWidgetState>? freeTextKey,
  super.key,
}) extends StatelessWidget {
  QuestionWidget _buildQuestionBody(BuildContext context) {
    switch (question) {
      case final ChoiceQuestion choiceQuestion:
        return ChoiceQuestionWidget(
          question: choiceQuestion,
          onDone: (answer) => onDone(answer, index),
          initialAnswer: initialAnswer as Answer<List<String>>?,
          onCleared: onCleared,
          multiSelectionText: AppLocalizations.of(context)!
              .eligible_choice_multi_selection,
          requiredMultiSelectionText: AppLocalizations.of(context)!
              .eligible_choice_multi_selection_required,
        );
      case final BooleanQuestion booleanQuestion:
        return BooleanQuestionWidget(
          question: booleanQuestion,
          onDone: (answer) => onDone(answer, index),
          initialAnswer: initialAnswer as Answer<bool>?,
        );
      case final ScaleQuestion scaleQuestion:
        return ScaleQuestionWidget(
          question: scaleQuestion,
          onDone: (answer) => onDone(answer, index),
          initialAnswer: initialAnswer as Answer<num>?,
        );
      case final ImageCapturingQuestion imageCapturingQuestion:
        // No initialAnswer until image widget can render restored captures.
        return ImageCapturingQuestionWidget(
          question: imageCapturingQuestion,
          onDone: (answer) => onDone(answer, index),
        );
      case final AudioRecordingQuestion audioRecordingQuestion:
        // No initialAnswer until audio widget can render restored recordings.
        return AudioRecordingQuestionWidget(
          question: audioRecordingQuestion,
          onDone: (answer) => onDone(answer, index),
        );
      case final VisualAnalogueQuestion visualAnalogueQuestion:
        // todo remove this when older studies are finished
        return VisualAnalogueQuestionWidget(
          question: visualAnalogueQuestion,
          onDone: (answer) => onDone(answer, index),
          initialAnswer: initialAnswer as Answer<num>?,
        );
      case final AnnotatedScaleQuestion annotatedScaleQuestion:
        return AnnotatedScaleQuestionWidget(
          question: annotatedScaleQuestion,
          onDone: (answer) => onDone(answer, index),
          initialAnswer: initialAnswer as Answer<num>?,
        );
      case final FreeTextQuestion freeTextQuestion:
        return FreeTextQuestionWidget(
          key: freeTextKey,
          question: freeTextQuestion,
          onDone: (answer) => onDone(answer, index),
          initialAnswer: initialAnswer as Answer<String>?,
          onDraftChanged: onFreeTextDraftChanged,
          isLastQuestion: isLastQuestion,
        );
      case final FitbitQuestion fitbitQuestion:
        // No initialAnswer until Fitbit widget can render restored values.
        return FitbitQuestionWidget(
          question: fitbitQuestion,
          onDone: (answer) => onDone(answer, index),
          taskId: taskId!,
        );
      case final PainQuestion painQuestion:
        // No initialAnswer until pain widget can render restored values.
        return PainQuestionWidget(
          question: painQuestion,
          onDone: (answer) => onDone(answer, index),
        );
      case final DateQuestion dateQuestion:
        return DateQuestionWidget(
          question: dateQuestion,
          onDone: (answer) => onDone(answer, index),
          onCleared: onCleared,
          initialAnswer: initialAnswer as Answer<DateTime>?,
        );
      default:
        throw ArgumentError('Question type ${question.type} not supported');
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionBody = _buildQuestionBody(context);

    return Card(
      key: containerKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuestionHeader(
              prompt: question.prompt,
              subtitle: questionBody.subtitle,
              rationale: question.rationale,
            ),
            const SizedBox(height: 24),
            questionBody,
          ],
        ),
      ),
    );
  }
}
