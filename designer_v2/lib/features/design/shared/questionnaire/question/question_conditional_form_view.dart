import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_live_preview.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class ConditionalQuestionFormView({
  required final IConditionalQuestionProperties formViewModel,
  required final List<Question> allQuestions,
  super.key,
}) extends FormConsumerWidget {
  this {
    final newAvailableQuestions = availableQuestions;
    final oldAvailableQuestions = ConditionRowFormViewModel.availableQuestions;

    ConditionRowFormViewModel.availableQuestions = newAvailableQuestions;

    if (_hasQuestionsListChanged(
      oldAvailableQuestions,
      newAvailableQuestions,
    )) {
      formViewModel.cleanupInvalidConditions();
      for (final conditionModel in formViewModel.conditionModels) {
        conditionModel.refreshAvailableQuestions();
      }
    }

    if (newAvailableQuestions.isNotEmpty) {
      formViewModel.initializeDeferredConditions();
    }
  }

  static const List<String> ignoredQuestionTypes = [
    ImageCapturingQuestion.questionType,
    AudioRecordingQuestion.questionType,
    FitbitQuestion.questionType,
    PainQuestion.questionType,
  ];

  // Question types that cannot be depended upon by other questions
  // (others can't reference these in their conditions)
  static const List<String> nonDependableQuestionTypes = [
    ImageCapturingQuestion.questionType,
    AudioRecordingQuestion.questionType,
    FitbitQuestion.questionType,
    PainQuestion.questionType,
  ];

  List<Question> get availableQuestions {
    final currentIndex = allQuestions.indexWhere(
      (q) => q.id == formViewModel.currentQuestionId,
    );
    final questionsBeforeCurrent = currentIndex == -1
        ? allQuestions
        : allQuestions.take(currentIndex).toList();

    // Filter out questions that cannot be depended upon by other questions
    return questionsBeforeCurrent
        .where((q) => !nonDependableQuestionTypes.contains(q.type))
        .toList();
  }

  bool _hasQuestionsListChanged(
    List<Question> oldQuestions,
    List<Question> newQuestions,
  ) {
    if (oldQuestions.length != newQuestions.length) {
      return true;
    }

    final oldIds = oldQuestions.map((q) => q.id).toSet();
    final newIds = newQuestions.map((q) => q.id).toSet();

    return !oldIds.containsAll(newIds) || !newIds.containsAll(oldIds);
  }

  Widget _buildQuestionOptionContent(Question option, int index) {
    return Tooltip(
      message: option.prompt ?? '',
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Icon(
              SurveyQuestionType.of(option).icon,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Text('${index + 1}.', style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(option.prompt!, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparatorOptionContent(String label) {
    return Tooltip(
      message: label,
      child: SizedBox(
        width: double.infinity,
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  @override
  Widget build(BuildContext context, FormGroup form) {
    final theme = Theme.of(context);
    return ReactiveFormConsumer(
      builder: (context, form, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextParagraph(
              text: tr.form_array_question_visibility_logic_description,
              style: ThemeConfig.bodyTextMuted(theme),
            ),
            const SizedBox(height: 16.0),
            FormLabel(
              labelText: tr.form_array_question_visibility_logic_title,
              labelTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              helpText: tr.form_array_question_visibility_logic_tooltip,
            ),
            const SizedBox(height: 12.0),
            _buildLogicGroupingControl(theme),
            const SizedBox(height: 12.0),
            _buildConditionsList(),
            const SizedBox(height: 16.0),
            _buildAddConditionButton(),
            const Divider(height: 32.0),
            StreamBuilder(
              stream: formViewModel.conditionsValueChanges,
              builder: (context, snapshot) {
                return _buildLivePreview(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogicGroupingControl(ThemeData theme) {
    return Row(
      children: [
        Text(
          tr.form_array_question_visibility_logic_grouping_title,
          style: ThemeConfig.bodyTextMuted(theme),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ReactiveRadioListTile<LogicType>(
            formControl: formViewModel.logicTypeControl,
            value: LogicType.and,
            title: Text(
              tr.form_array_question_visibility_logic_grouping_and_title,
            ),
            onChanged: formViewModel.isReadonly ? null : (value) {},
          ),
        ),
        Expanded(
          child: ReactiveRadioListTile<LogicType>(
            formControl: formViewModel.logicTypeControl,
            value: LogicType.or,
            title: Text(
              tr.form_array_question_visibility_logic_grouping_or_title,
            ),
            onChanged: formViewModel.isReadonly ? null : (value) {},
          ),
        ),
      ],
    );
  }

  Widget _buildConditionsList() {
    return ReactiveFormArray(
      formArray: formViewModel.conditionsArray,
      builder: (context, formArray, child) {
        if (formArray.controls.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextParagraph(
              text: tr.from_array_question_visibility_logic_no_conditions,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        return Column(
          children: List.generate(formArray.controls.length, (index) {
            final control = formArray.controls[index] as FormGroup;
            // Get the corresponding view model
            final conditionVm = formViewModel.conditionModels[index];

            return KeyedSubtree(
              key: ValueKey(control),
              child: _buildSingleConditionRow(context, conditionVm, index),
            );
          }),
        );
      },
    );
  }

  Widget _buildSingleConditionRow(
    BuildContext context,
    ConditionRowFormViewModel conditionVm,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Tooltip(
              message: conditionVm.selectedQuestion?.prompt ?? '',
              child: ReactiveDropdownField<String>(
                formControl: conditionVm.questionIdControl,
                isExpanded: true,
                selectedItemBuilder: (context) => availableQuestions
                    .asMap()
                    .map(
                      (index, option) => MapEntry(
                        index,
                        _buildQuestionOptionContent(option, index),
                      ),
                    )
                    .values
                    .toList(),
                items: availableQuestions
                    .asMap()
                    .map(
                      (index, option) => MapEntry(
                        index,
                        DropdownMenuItem(
                          value: option.id,
                          child: _buildQuestionOptionContent(option, index),
                        ),
                      ),
                    )
                    .values
                    .toList(),
                decoration: InputDecoration(
                  labelText:
                      tr.form_array_question_visibility_logic_question_title,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Rebuild comparator when question changes
          ReactiveValueListenableBuilder<String>(
            formControl: conditionVm.questionIdControl,
            builder: (context, _, _) {
              if (conditionVm.selectedQuestion != null) {
                return Expanded(
                  child: ReactiveDropdownField<dynamic>(
                    formControl: conditionVm.comparatorControl,
                    isExpanded: true,
                    selectedItemBuilder: (context) => conditionVm
                        .availableComparators
                        .map(
                          (option) =>
                              _buildComparatorOptionContent(option.label),
                        )
                        .toList(),
                    items: conditionVm.availableComparators
                        .map(
                          (option) => DropdownMenuItem(
                            value: option.value,
                            child: _buildComparatorOptionContent(option.label),
                          ),
                        )
                        .toList(),
                    decoration: InputDecoration(
                      labelText: tr
                          .form_array_question_visibility_logic_comparator_title,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
          // Rebuild value when question or comparator changes
          ReactiveValueListenableBuilder<String>(
            formControl: conditionVm.questionIdControl,
            builder: (context, _, _) {
              return ReactiveValueListenableBuilder<dynamic>(
                formControl: conditionVm.comparatorControl,
                builder: (context, _, _) {
                  if (conditionVm.comparatorControl.value != null &&
                      conditionVm.selectedQuestion != null) {
                    return Expanded(
                      flex: 2,
                      child: _buildValueInputField(context, conditionVm),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: formViewModel.isReadonly
                ? null
                : () => formViewModel.removeCondition(index),
            tooltip: tr.action_delete,
          ),
        ],
      ),
    );
  }

  Widget _buildValueInputField(
    BuildContext context,
    ConditionRowFormViewModel conditionVm,
  ) {
    switch (conditionVm.selectedQuestion!.type) {
      case BooleanQuestion.questionType:
        return ReactiveDropdownField<dynamic>(
          formControl: conditionVm.valueControl,
          items: [
            DropdownMenuItem(
              value: true,
              child: Text(tr.form_array_question_visibility_logic_true),
            ),
            DropdownMenuItem(
              value: false,
              child: Text(tr.form_array_question_visibility_logic_false),
            ),
          ],
          decoration: InputDecoration(
            labelText: tr.form_array_question_visibility_logic_value_title,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        );
      case ChoiceQuestion.questionType:
        return Tooltip(
          message:
              conditionVm.availableChoiceValues
                  .firstWhereOrNull(
                    (option) => option.value == conditionVm.valueControl.value,
                  )
                  ?.label ??
              '',
          child: ReactiveDropdownField<dynamic>(
            formControl: conditionVm.valueControl,
            isExpanded: true,
            items: conditionVm.availableChoiceValues
                .map(
                  (option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(option.label, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            decoration: InputDecoration(
              labelText: tr.form_array_question_visibility_logic_value_title,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        );
      case ScaleQuestion.questionType:
        return ReactiveTextField<dynamic>(
          formControl: conditionVm.valueControl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
          ],
          validationMessages: {
            ValidationMessage.number: (error) => tr.validation_number_required,
          },
          decoration: InputDecoration(
            labelText: tr.form_array_question_visibility_logic_value_title,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        );
      case FreeTextQuestion.questionType:
        return ReactiveTextField<dynamic>(
          formControl: conditionVm.valueControl,
          keyboardType: freeTextThresholdKeyboardType(conditionVm),
          inputFormatters: freeTextThresholdInputFormatters(conditionVm),
          decoration: InputDecoration(
            labelText: tr.form_array_question_visibility_logic_value_title,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddConditionButton() {
    return Tooltip(
      message: availableQuestions.isEmpty
          ? tr.form_array_question_visibility_logic_add_condition_disabled_tooltip
          : '',
      child: ElevatedButton.icon(
        onPressed: (availableQuestions.isEmpty || formViewModel.isReadonly)
            ? null
            : () => formViewModel.addCondition(),
        icon: const Icon(Icons.add),
        label: Text(
          tr.form_array_question_visibility_logic_add_condition_button,
        ),
      ),
    );
  }

  Widget _buildLivePreview(BuildContext context) {
    return LiveConditionPreview(
      compositeExpression: formViewModel.compositeExpression,
      allQuestions: allQuestions,
      currentQuestionId: formViewModel.currentQuestionId,
    );
  }
}

List<TextInputFormatter>? freeTextThresholdInputFormatters(
  ConditionRowFormViewModel conditionVm,
) {
  if (!conditionVm.selectedComparatorUsesNumericThreshold) {
    return null;
  }

  return [
    FilteringTextInputFormatter.allow(
      conditionVm.selectedQuestionAllowsSignedNumericThreshold
          ? RegExp(r'^-?\d*\.?\d*')
          : RegExp(r'^\d*'),
    ),
  ];
}

TextInputType freeTextThresholdKeyboardType(
  ConditionRowFormViewModel conditionVm,
) {
  if (!conditionVm.selectedComparatorUsesNumericThreshold) {
    return TextInputType.text;
  }

  return conditionVm.selectedQuestionAllowsSignedNumericThreshold
      ? const TextInputType.numberWithOptions(signed: true)
      : TextInputType.number;
}
