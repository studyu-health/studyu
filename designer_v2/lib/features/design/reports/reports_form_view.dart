import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet_form.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/reports/report_badge.dart';
import 'package:studyu_designer_v2/features/design/reports/reports_form_data.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_list_view.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class const StudyDesignReportsFormView(super.studyId, {super.key})
    extends StudyDesignPageWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel = ref.watch(reportsFormViewModelProvider(studyId));
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: ReactiveFormConsumer(
            builder: (context, formGroup, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextParagraph(text: tr.form_array_report_items_description),
                const SizedBox(height: 32.0),
                ReactiveFormArray(
                  formArray: formViewModel.reportItemArray,
                  builder: (context, formArray, child) {
                    return FormListView<ReportItemFormViewModel>(
                      control: formViewModel.reportItemArray,
                      items: formViewModel.reportItemModels,
                      onSelectItem: (viewModel) {
                        final routeArgs = formViewModel
                            .buildReportItemFormRouteArgs(viewModel);
                        _showReportItemSidesheetWithArgs(
                          routeArgs,
                          context,
                          ref,
                        );
                      },
                      getActionsAt: (viewModel, _) => formViewModel
                          .reportItemDelegate
                          .availableActions(viewModel),
                      onNewItem: () {
                        final routeArgs = formViewModel
                            .buildNewReportItemFormRouteArgs();
                        _showReportItemSidesheetWithArgs(
                          routeArgs,
                          context,
                          ref,
                        );
                      },
                      rowTitle: (viewModel) =>
                          viewModel.formData?.section.title ?? '',
                      //rowTitle: (viewModel) => viewModel.formData?.title ?? '',
                      //sectionDescription: tr.form_array_report_items_description,
                      // sectionTitleDivider: false,
                      emptyIcon: Icons.content_paste_off_rounded,
                      emptyTitle: tr.form_array_reports_empty_title,
                      emptyDescription: tr.form_array_reports_empty_description,
                      onNewItemLabel: tr.form_array_reports_new,
                      hideLeadingTrailingWhenEmpty: true,
                      rowPrefix: (context, viewModel, rowIdx) {
                        return Row(
                          children: [
                            Text(
                              ''.alphabetLetterFrom(rowIdx).toUpperCase(),
                              style: TextStyle(
                                color: ThemeConfig.dropdownMenuItemTheme(theme)
                                    .iconTheme!
                                    .color,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                          ],
                        );
                      },
                      rowSuffix: (context, viewModel, rowIdx) {
                        return Row(
                          children: [
                            ReportBadge(
                              status: (viewModel.formData!.isPrimary)
                                  ? ReportStatus.primary
                                  : ReportStatus.secondary,
                              showPrefixIcon: false,
                            ),
                          ],
                        );
                      },
                      leadingWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr.form_array_report_items_title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          // Todo add report preview feature that generates test data to preview the selected reports
                          /*if (formViewModel.canTestConsent)
                            Opacity(
                              opacity: ThemeConfig.kMuteFadeFactor,
                              child: TextButton.icon(
                                //onPressed: formViewModel.testReport,
                                onPressed: null,
                                icon: const Icon(
                                  Icons.play_circle_outline_rounded,
                                ),
                                label: Text(tr.form_array_report_items_test),
                              ),
                            )
                          else
                            const SizedBox.shrink(),*/
                        ],
                      ),
                      reorderable: !formViewModel.isReadonly,
                      onReorder: (oldIndex, newIndex) {
                        var effectiveNewIndex = newIndex;
                        if (effectiveNewIndex > oldIndex) {
                          effectiveNewIndex -= 1;
                        }
                        final item = formViewModel.reportItemModels.removeAt(
                          oldIndex,
                        );
                        formViewModel.reportItemModels.insert(
                          effectiveNewIndex,
                          item,
                        );
                        final controlItem = formViewModel.reportItemArray
                            .removeAt(oldIndex);
                        formViewModel.reportItemArray.insert(
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
  void _showReportItemSidesheetWithArgs(
    ReportItemFormRouteArgs routeArgs,
    BuildContext context,
    WidgetRef ref,
  ) {
    final formViewModel = ref.watch(reportItemFormViewModelProvider(routeArgs));

    showFormSideSheet<ReportItemFormViewModel>(
      context: context,
      formViewModel: formViewModel,
      formViewBuilder: (formViewModel) =>
          ReportItemFormView(formViewModel: formViewModel, studyId: studyId),
    );
  }
}
