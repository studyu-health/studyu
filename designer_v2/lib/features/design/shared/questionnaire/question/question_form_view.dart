import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/styling_information.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/audio_recording_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/bool_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/choice_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/date_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/fitbit_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/free_text_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/image_capturing_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/pain_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/scale_question_form_view.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

/// Wrapper that dispatches to the appropriate widget for the corresponding
/// [SurveyQuestionType] as given by [formViewModel.questionType]
class const SurveyQuestionFormView({
  required final QuestionFormViewModel formViewModel,
  required final String studyId,
  final bool isHtmlStyleable = true,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<SurveyQuestionFormView> createState() =>
      _SurveyQuestionFormViewState();
}

class _SurveyQuestionFormViewState()
    extends ConsumerState<SurveyQuestionFormView> {
  QuestionFormViewModel get formViewModel => widget.formViewModel;

  late bool isQuestionHelpTextFieldVisible =
      formViewModel.questionInfoTextControl.value?.isNotEmpty ?? false;
  bool isStylingInformationDismissed = true;

  void onDismissedCallback() => setState(() {
    isStylingInformationDismissed = !isStylingInformationDismissed;
  });

  WidgetBuilder get questionTypeBodyBuilder {
    final Map<SurveyQuestionType, WidgetBuilder> questionTypeWidgets = {
      SurveyQuestionType.choice: (_) =>
          ChoiceQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.bool: (_) =>
          BoolQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.scale: (_) =>
          ScaleQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.image: (_) =>
          ImageCapturingQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.audio: (_) =>
          AudioRecordingQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.freeText: (_) =>
          FreeTextQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.fitbit: (_) => FitbitQuestionFormView(
        formViewModel: formViewModel,
        studyId: widget.studyId,
      ),
      SurveyQuestionType.pain: (_) =>
          PainQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.date: (_) =>
          DateQuestionFormView(formViewModel: formViewModel),
    };

    final questionType = formViewModel.questionType;

    if (!questionTypeWidgets.containsKey(questionType)) {
      throw Exception(
        "Failed to build widget for SurveyQuestionType $questionType because there is no registered WidgetBuilder",
      );
    }
    final builder = questionTypeWidgets[questionType]!;
    return builder;
  }

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: SelectionArea(
        child: Column(
          children: [
            _buildQuestionText(context),
            if (isQuestionHelpTextFieldVisible)
              Column(
                children: [
                  const SizedBox(height: 16.0),
                  _buildQuestionHelpText(context),
                ],
              )
            else
              const SizedBox.shrink(),
            if (widget.isHtmlStyleable)
              HtmlStylingBanner(
                isDismissed: isStylingInformationDismissed,
                onDismissed: onDismissedCallback,
              ),
            const SizedBox(height: 24.0),
            ReactiveFormConsumer(
              builder: (context, formGroup, child) {
                return Column(
                  children: [
                    _buildResponseTypeHeader(context),
                    const SizedBox(height: 16.0),
                    questionTypeBodyBuilder(context),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Column _buildResponseTypeHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              label: tr.form_field_question_response_options,
              labelHelpText: tr.form_field_question_response_options_tooltip,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              // TODO: extract custom dropdown component with theme + focus fix
              input: Theme(
                data: theme.copyWith(
                  inputDecorationTheme:
                      ThemeConfig.dropdownInputDecorationTheme(theme),
                ),
                child: ReactiveDropdownField<SurveyQuestionType>(
                  formControl: formViewModel.questionTypeControl,
                  items: formViewModel.questionTypeControlOptions.map((option) {
                    final menuItemTheme = ThemeConfig.dropdownMenuItemTheme(
                      theme,
                    );
                    final iconTheme =
                        menuItemTheme.iconTheme ?? theme.iconTheme;
                    return DropdownMenuItem(
                      value: option.value,
                      child: Row(
                        children: [
                          if (option.value.icon != null)
                            Icon(
                              option.value.icon,
                              size: iconTheme.size,
                              color: iconTheme.color,
                              shadows: iconTheme.shadows,
                            )
                          else
                            const SizedBox.shrink(),
                          const SizedBox(width: 16.0),
                          Text(option.label),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        TextParagraph(
          text: tr.form_field_question_response_options_description,
          style: ThemeConfig.bodyTextMuted(theme),
        ),
      ],
    );
  }

  FormTableLayout _buildQuestionText(BuildContext context) {
    return FormTableLayout(
      rowLayout: FormTableRowLayout.vertical,
      rows: [
        FormTableRow(
          control: formViewModel.questionTextControl,
          labelBuilder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FormLabel(
                    labelText: tr.form_field_question,
                    helpText: tr.form_field_question_tooltip,
                  ),
                  if (widget.isHtmlStyleable) const SizedBox(width: 8),
                  if (widget.isHtmlStyleable)
                    Opacity(
                      opacity: ThemeConfig.kMuteFadeFactor,
                      child: Tooltip(
                        message: "Use html to style your content",
                        child: Hyperlink(
                          text: "styleable",
                          onClick: () => setState(() {
                            isStylingInformationDismissed =
                                !isStylingInformationDismissed;
                          }),
                          visitedColor: null,
                        ),
                      ),
                    ),
                ],
              ),
              if (!isQuestionHelpTextFieldVisible && !formViewModel.isReadonly)
                Opacity(
                  opacity: ThemeConfig.kMuteFadeFactor,
                  child: Tooltip(
                    message: tr.form_field_question_help_text_add_tooltip,
                    child: Hyperlink(
                      text: "+ ${tr.form_field_question_help_text_add}",
                      onClick: () => setState(() {
                        isQuestionHelpTextFieldVisible = true;
                      }),
                      visitedColor: null,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
          input: ReactiveTextField(
            formControl: formViewModel.questionTextControl,
            decoration: InputDecoration(hintText: tr.form_field_question),
            validationMessages:
                formViewModel.questionTextControl.validationMessages,
            minLines: 3,
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  FormTableLayout _buildQuestionHelpText(BuildContext context) {
    return FormTableLayout(
      rowLayout: FormTableRowLayout.vertical,
      rows: [
        FormTableRow(
          control: formViewModel.questionInfoTextControl,
          label: tr.form_field_question_help_text,
          labelHelpText: tr.form_field_question_help_text_tooltip,
          labelBuilder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FormLabel(
                    labelText: tr.form_field_question_help_text,
                    helpText: tr.form_field_question_help_text_tooltip,
                  ),
                  if (widget.isHtmlStyleable) const SizedBox(width: 8),
                  if (widget.isHtmlStyleable)
                    Opacity(
                      opacity: ThemeConfig.kMuteFadeFactor,
                      child: Tooltip(
                        message: "Use html to style your content",
                        child: Hyperlink(
                          text: "styleable",
                          onClick: () => setState(() {
                            isStylingInformationDismissed =
                                !isStylingInformationDismissed;
                          }),
                          visitedColor: null,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          input: ReactiveTextField(
            formControl: formViewModel.questionInfoTextControl,
            validationMessages:
                formViewModel.questionInfoTextControl.validationMessages,
            minLines: 3,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: tr.form_field_question_help_text_hint,
              //helperText: "", // reserve space
            ),
          ),
        ),
      ],
    );
  }
}
