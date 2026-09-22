import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet_form.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/domain/participation.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_view.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_logic_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_list_view.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class const StudyDesignEnrollmentFormView(super.studyId, {super.key})
    extends StudyDesignPageWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel = ref.watch(
          enrollmentFormViewModelProvider(studyId),
        );
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: ReactiveFormConsumer(
            builder: (context, formGroup, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextParagraph(
                  text: tr.form_study_design_enrollment_description,
                ),
                const SizedBox(height: 24.0),
                FormTableLayout(
                  rows: [
                    FormTableRow(
                      control: formViewModel.enrollmentTypeControl,
                      label: tr.form_field_enrollment_type,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      input: RadioGroup<Participation>(
                        groupValue: formViewModel.enrollmentTypeControl.value,
                        onChanged: (Participation? value) {
                          if (!formViewModel.isReadonly && value != null) {
                            formViewModel.enrollmentTypeControl.value = value;
                          }
                        },
                        child: Column(
                          children: formViewModel.enrollmentTypeControlOptions
                              .map<Widget>(
                                (option) => RadioListTile<Participation>(
                                  value: option.value,
                                  enabled: !formViewModel.isReadonly,
                                  // disables in readonly mode
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option.value.whoShort,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                      const SizedBox(height: 2.0),
                                    ],
                                  ),
                                  subtitle: (option.description) != null
                                      ? TextParagraph(
                                          text: option.description,
                                          selectable: false,
                                          style: ThemeConfig.bodyTextMuted(
                                            theme,
                                          ),
                                        )
                                      : null,
                                ),
                              )
                              .toList()
                              .separatedBy(() => const SizedBox(height: 8.0)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                ReactiveFormArray(
                  formArray: formViewModel.questionsArray,
                  builder: (context, formArray, child) {
                    return FormListView<ScreenerQuestionFormViewModel>(
                      control: formViewModel.questionsArray,
                      items: formViewModel.questionModels,
                      onSelectItem: (viewModel) {
                        final routeArgs = formViewModel
                            .buildScreenerQuestionFormRouteArgs(viewModel);
                        _showScreenerQuestionSidesheetWithArgs(
                          routeArgs,
                          context,
                          ref,
                          study.questionnaire,
                        );
                      },
                      getActionsAt: (viewModel, _) =>
                          formViewModel.availablePopupActions(viewModel),
                      onNewItem: () {
                        final routeArgs = formViewModel
                            .buildNewScreenerQuestionFormRouteArgs();
                        _showScreenerQuestionSidesheetWithArgs(
                          routeArgs,
                          context,
                          ref,
                          study.questionnaire,
                        );
                      },
                      sectionDescription:
                          tr.form_array_screener_questions_description,
                      onNewItemLabel: tr.form_array_screener_questions_new,
                      rowTitle: (viewModel) =>
                          viewModel.formData?.questionText ?? '',
                      leadingWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr.form_array_screener_questions_title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (formViewModel.canTestScreener)
                            Opacity(
                              opacity: ThemeConfig.kMuteFadeFactor,
                              child: TextButton.icon(
                                onPressed: formViewModel.testScreener,
                                icon: const Icon(
                                  Icons.play_circle_outline_rounded,
                                ),
                                label: Text(
                                  tr.form_array_screener_questions_test,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                      rowPrefix: (context, viewModel, rowIdx) {
                        return Row(
                          children: [
                            Tooltip(
                              message: viewModel.questionType.string,
                              child: Icon(
                                viewModel.questionType.icon,
                                color: ThemeConfig.dropdownMenuItemTheme(theme)
                                    .iconTheme!
                                    .color,
                                size: ThemeConfig.dropdownMenuItemTheme(theme)
                                    .iconTheme!
                                    .size,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                          ],
                        );
                      },
                      reorderable: !formViewModel.isReadonly,
                      onReorder: (oldIndex, newIndex) {
                        var effectiveNewIndex = newIndex;
                        if (effectiveNewIndex > oldIndex) {
                          effectiveNewIndex -= 1;
                        }
                        final item = formViewModel.questionModels.removeAt(
                          oldIndex,
                        );
                        formViewModel.questionModels.insert(
                          effectiveNewIndex,
                          item,
                        );
                        final controlItem = formViewModel.questionsArray
                            .removeAt(oldIndex);
                        formViewModel.questionsArray.insert(
                          effectiveNewIndex,
                          controlItem,
                        );
                        formViewModel.save();
                      },
                    );
                  },
                ),
                const SizedBox(height: 24.0),
                ReactiveFormArray(
                  formArray: formViewModel.consentItemArray,
                  builder: (context, formArray, child) {
                    return FormListView<ConsentItemFormViewModel>(
                      control: formViewModel.consentItemArray,
                      items: formViewModel.consentItemModels,
                      onSelectItem: (viewModel) {
                        final routeArgs = formViewModel
                            .buildConsentItemFormRouteArgs(viewModel);
                        _showConsentItemSidesheetWithArgs(
                          routeArgs,
                          context,
                          ref,
                        );
                      },
                      getActionsAt: (viewModel, _) => formViewModel
                          .consentItemDelegate
                          .availableActions(viewModel),
                      onNewItem: () {
                        final routeArgs = formViewModel
                            .buildNewConsentItemFormRouteArgs();
                        _showConsentItemSidesheetWithArgs(
                          routeArgs,
                          context,
                          ref,
                        );
                      },
                      sectionDescription:
                          tr.form_array_consent_items_description,
                      onNewItemLabel: tr.form_array_consent_items_new,
                      rowTitle: (viewModel) => viewModel.formData?.title ?? '',
                      leadingWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr.form_array_consent_items_title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (formViewModel.canTestConsent)
                            Opacity(
                              opacity: ThemeConfig.kMuteFadeFactor,
                              child: TextButton.icon(
                                onPressed: formViewModel.testConsent,
                                icon: const Icon(
                                  Icons.play_circle_outline_rounded,
                                ),
                                label: Text(tr.form_array_consent_items_test),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                      reorderable: !formViewModel.isReadonly,
                      onReorder: (oldIndex, newIndex) {
                        var effectiveNewIndex = newIndex;
                        if (effectiveNewIndex > oldIndex) {
                          effectiveNewIndex -= 1;
                        }
                        final item = formViewModel.consentItemModels.removeAt(
                          oldIndex,
                        );
                        formViewModel.consentItemModels.insert(
                          effectiveNewIndex,
                          item,
                        );
                        final controlItem = formViewModel.consentItemArray
                            .removeAt(oldIndex);
                        formViewModel.consentItemArray.insert(
                          effectiveNewIndex,
                          controlItem,
                        );
                        formViewModel.save();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
  void _showScreenerQuestionSidesheetWithArgs(
    ScreenerQuestionFormRouteArgs routeArgs,
    BuildContext context,
    WidgetRef ref,
    StudyUQuestionnaire questionnaire,
  ) {
    final formViewModel = ref.watch(
      screenerQuestionFormViewModelProvider(routeArgs),
    );

    showFormSideSheet<ScreenerQuestionFormViewModel>(
      context: context,
      formViewModel: formViewModel,
      tabs: <FormSideSheetTab<ScreenerQuestionFormViewModel>>[
        FormSideSheetTab(
          title: tr.navlink_screener_question_content,
          index: 0,
          formViewBuilder: (formViewModel) => SurveyQuestionFormView(
            formViewModel: formViewModel,
            studyId: studyId,
            isHtmlStyleable: false,
          ),
        ),
        FormSideSheetTab(
          title: tr.navlink_screener_question_logic,
          index: 1,
          formViewBuilder: (formViewModel) =>
              ScreenerQuestionLogicFormView(formViewModel: formViewModel),
        ),
        FormSideSheetTab(
          title: tr.navlink_question_visibility_logic,
          index: 2,
          formViewBuilder: (formViewModel) => ConditionalQuestionFormView(
            formViewModel: formViewModel,
            allQuestions: questionnaire.questions,
          ),
        ),
      ],
    );
  }

  // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
  void _showConsentItemSidesheetWithArgs(
    ConsentItemFormRouteArgs routeArgs,
    BuildContext context,
    WidgetRef ref,
  ) {
    final formViewModel = ref.watch(
      consentItemFormViewModelProvider(routeArgs),
    );

    showFormSideSheet<ConsentItemFormViewModel>(
      context: context,
      formViewModel: formViewModel,
      formViewBuilder: (formViewModel) =>
          ConsentItemFormView(formViewModel: formViewModel),
    );
  }
}
