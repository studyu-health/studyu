import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const AudioRecordingQuestionFormView({
  required final QuestionFormViewModel formViewModel,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FormTableLayout(
          rowLayout: FormTableRowLayout.vertical,
          rows: [
            FormTableRow(
              label: tr.form_field_response_audio_max_duration_label,
              input: ReactiveTextField(
                formControl: formViewModel.maxRecordingDurationSecondsControl,
                keyboardType: TextInputType.number,
                validationMessages: {
                  ValidationMessage.min: (error) =>
                      tr.audio_recording_max_duration_rangevalid_min,
                  ValidationMessage.max: (error) =>
                      tr.audio_recording_max_duration_rangevalid_max(
                        QuestionFormViewModel.kMaxRecordingDurationSeconds,
                      ),
                  ValidationMessage.number: (error) =>
                      tr.free_text_validation_number,
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
