import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/fitbit/fitbit_credentials_form_controller.dart';
import 'package:studyu_designer_v2/features/design/fitbit/fitbit_credentials_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/string_extensions.dart';

class const FitbitQuestionFormView({
  required final QuestionFormViewModel formViewModel,
  required final String studyId,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<FitbitQuestionFormView> createState() =>
      _FitbitQuestionFormViewState();
}

class _FitbitQuestionFormViewState()
    extends ConsumerState<FitbitQuestionFormView> {
  QuestionFormViewModel get formViewModel => widget.formViewModel;

  @override
  Widget build(BuildContext context) {
    final fitbitCredentialsFormViewModel = ref.watch(
      fitbitCredentialsFormViewModelProvider(widget.studyId),
    );
    widget.formViewModel.attachFitbitCredentialsFormViewModel(
      fitbitCredentialsFormViewModel,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.fitbit_question_title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        FormTableLayout(
          rows: [
            FormTableRow(
              control: formViewModel.fitbitResponseOptionsArray,
              label: '',
              input: _FitbitTypeSelector(formViewModel: formViewModel),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FitbitCredentialsSection(formViewModel: fitbitCredentialsFormViewModel),
      ],
    );
  }
}

class const _FitbitTypeSelector({
  required final QuestionFormViewModel formViewModel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ReactiveFormArray(
      formArray: formViewModel.fitbitResponseOptionsArray,
      builder: (context, formArray, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: FitbitQuestionType.values.asMap().entries.map((entry) {
            final index = entry.key;
            final type = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  ReactiveCheckbox(
                    formControl: formArray.controls[index] as FormControl<bool>,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          type.name.toPascalCase(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: _getTranslation(type),
                          child: const Icon(Icons.info_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _getTranslation(FitbitQuestionType type) {
    return switch (type) {
      FitbitQuestionType.heartrate =>
        tr.fitbit_question_type_heartrate_description,
      FitbitQuestionType.sleep => tr.fitbit_question_type_sleep_description,
      FitbitQuestionType.steps => tr.fitbit_question_type_steps_description,
    };
  }
}
