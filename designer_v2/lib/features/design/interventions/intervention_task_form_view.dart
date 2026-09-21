import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/styling_information.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_controls_view.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class const InterventionTaskFormView({
  required final InterventionTaskFormViewModel formViewModel,
  super.key,
}) extends StatefulWidget {
  @override
  State<InterventionTaskFormView> createState() =>
      _InterventionTaskFormViewState();
}

class _InterventionTaskFormViewState() extends State<InterventionTaskFormView> {
  bool isStylingInformationDismissed = true;

  void onDismissedCallback() => setState(() {
    isStylingInformationDismissed = !isStylingInformationDismissed;
  });

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormTableLayout(
              rowLayout: FormTableRowLayout.vertical,
              rows: [
                FormTableRow(
                  control: widget.formViewModel.taskTitleControl,
                  label: tr.form_field_intervention_task_title,
                  labelHelpText: tr.form_field_intervention_task_title_tooltip,
                  input: ReactiveTextField(
                    formControl: widget.formViewModel.taskTitleControl,
                    decoration: InputDecoration(
                      hintText: tr.form_field_intervention_task_title,
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(200)],
                    validationMessages: widget
                        .formViewModel
                        .taskTitleControl
                        .validationMessages,
                  ),
                ),
                FormTableRow(
                  control: widget.formViewModel.taskDescriptionControl,
                  labelBuilder: (context) => Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 3.0,
                    runSpacing: 8.0,
                    children: [
                      FormLabel(
                        labelText: tr.form_field_intervention_task_description,
                        helpText:
                            tr.form_field_intervention_task_description_tooltip,
                      ),
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
                  input: ReactiveTextField(
                    formControl: widget.formViewModel.taskDescriptionControl,
                    decoration: InputDecoration(
                      hintText:
                          tr.form_field_intervention_task_description_hint,
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(2000)],
                    validationMessages: widget
                        .formViewModel
                        .taskDescriptionControl
                        .validationMessages,
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: 5,
                  ),
                ),
              ],
            ),
            HtmlStylingBanner(
              isDismissed: isStylingInformationDismissed,
              onDismissed: onDismissedCallback,
            ),
            const SizedBox(height: 12.0),
            ReactiveFormConsumer(
              builder: (context, form, child) {
                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ReactiveCheckbox(
                      formControl: widget.formViewModel.markAsCompletedControl,
                    ),
                    const SizedBox(width: 3.0),
                    FormControlLabel(
                      formControl: widget.formViewModel.markAsCompletedControl,
                      text: tr
                          .form_field_intervention_task_mark_as_completed_label,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24.0),
            ScheduleControls(formViewModel: widget.formViewModel),
          ],
        ),
      ),
    );
  }
}
