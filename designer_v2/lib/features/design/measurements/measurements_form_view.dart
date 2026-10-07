import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurement_picker_dialog.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_list_view.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class const StudyDesignMeasurementsFormView(super.studyId, {super.key})
    extends StudyDesignPageWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel = ref.watch(
          measurementsFormViewModelProvider(studyId),
        );

        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(
                text: tr.form_study_design_measurements_description,
              ),
              const SizedBox(height: 32.0),
              ReactiveFormConsumer(
                builder: (context, form, child) {
                  final measurements = formViewModel.measurementViewModels;

                  return FormListView<
                    ManagedFormViewModel<IFormDataWithSchedule>
                  >(
                    control: formViewModel.measurementsArray,
                    items: measurements,
                    onSelectItem: formViewModel.onSelectItem,
                    getActionsAt: (viewModel, _) =>
                        formViewModel.availablePopupActions(viewModel),
                    onNewItem: formViewModel.canAddMeasurement
                        ? () =>
                              _showAddMeasurementDialog(context, formViewModel)
                        : null,
                    onNewItemLabel: tr.form_array_measurements_surveys_new,
                    rowTitle: formViewModel.measurementTitle,
                    rowPrefix: (context, viewModel, _) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        viewModel is NutritionFormViewModel
                            ? Icons.restaurant_outlined
                            : Icons.assignment_outlined,
                      ),
                    ),
                    sectionTitle: tr.form_array_measurements_surveys,
                    emptyIcon: Icons.content_paste_off_rounded,
                    emptyTitle: tr.form_array_measurements_surveys_empty_title,
                    emptyDescription:
                        tr.form_array_measurements_surveys_empty_description,
                    hideLeadingTrailingWhenEmpty: true,
                    reorderable: !formViewModel.isReadonly,
                    onReorder: (oldIndex, newIndex) {
                      var effectiveNewIndex = newIndex;
                      if (effectiveNewIndex > oldIndex) {
                        effectiveNewIndex -= 1;
                      }
                      final item = formViewModel.measurementViewModels.removeAt(
                        oldIndex,
                      );
                      formViewModel.measurementViewModels.insert(
                        effectiveNewIndex,
                        item,
                      );
                      final controlItem = formViewModel.measurementsArray
                          .removeAt(oldIndex);
                      formViewModel.measurementsArray.insert(
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
        );
      },
    );
  }
}

Future<void> _showAddMeasurementDialog(
  BuildContext context,
  MeasurementsFormViewModel formViewModel,
) async {
  final selection = await showDialog<MeasurementSelection>(
    context: context,
    barrierColor: ThemeConfig.modalBarrierColor(Theme.of(context)),
    builder: (_) => MeasurementPickerDialog(
      formViewModel: formViewModel,
      canAddNutrition: !formViewModel.isNutritionEnabled,
    ),
  );
  if (!context.mounted || selection != MeasurementSelection.blankSurvey) {
    return;
  }
  formViewModel.onNewSurvey();
}
