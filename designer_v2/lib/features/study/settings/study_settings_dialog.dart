import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/study/settings/study_settings_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const StudySettingsDialog(super.studyId, {super.key})
    extends StudyPageWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formViewModel = ref.watch(
      studySettingsFormViewModelProvider(studyId),
    );

    return ReactiveForm(
      formGroup: formViewModel.form,
      child: StandardDialog(
        titleText: tr.study_settings,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12.0),
            FormSectionHeader(title: tr.navlink_public_studies),
            const SizedBox(height: 6.0),
            TextParagraph(text: tr.navlink_public_studies_description),
            const SizedBox(height: 24.0),
            ReactiveFormConsumer(
              builder: (context, form, child) {
                return FormTableLayout(
                  rows: [
                    FormTableRow(
                      label: tr.study_settings_publish_study,
                      labelHelpText: tr.study_settings_publish_study_tooltip,
                      input: Align(
                        alignment: Alignment.centerRight,
                        child: ReactiveSwitch(
                          formControl:
                              formViewModel.isPublishedToRegistryControl,
                        ),
                      ),
                    ),
                    FormTableRow(
                      label: tr.study_settings_publish_results,
                      labelHelpText: tr.study_settings_publish_results_tooltip,
                      input: Align(
                        alignment: Alignment.centerRight,
                        child: ReactiveSwitch(
                          formControl:
                              formViewModel.isPublishedToRegistryResultsControl,
                        ),
                      ),
                    ),
                  ],
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                );
              },
            ),
            const SizedBox(height: 12.0),
          ],
        ),
        actionButtons: buildFormButtons(formViewModel, formViewModel.formMode),
        minWidth: 650,
        maxWidth: 750,
        minHeight: 450,
      ),
    );
  }
}
