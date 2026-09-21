import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/domain/participation.dart';
import 'package:studyu_designer_v2/features/study/settings/study_settings_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class const PublishConfirmationDialog(super.studyId, {super.key})
    extends StudyPageWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(studyControllerProvider(studyId).notifier);
    final state = ref.watch(studyControllerProvider(studyId));
    final formViewModel = ref.watch(
      studySettingsFormViewModelProvider(studyId),
    );
    formViewModel.setLaunchDefaults();

    final theme = Theme.of(context);

    return ReactiveForm(
      formGroup: formViewModel.form,
      child: StandardDialog(
        titleText: tr.study_launch_title,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: tr.study_launch_participation_intro,
                          children: [
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: state.studyParticipation!.asAdjective,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: '.'),
                            TextSpan(text: tr.study_launch_participation_outro),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      SelectableText(
                        state.studyParticipation!.launchDescription,
                        style: ThemeConfig.bodyTextMuted(theme)
                            .copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4.0),
                Opacity(
                  opacity: ThemeConfig.kMuteFadeFactor,
                  child: TextButton(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 8.0,
                      ),
                      child: Text(
                        tr.action_button_study_participation_change,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onPressed: () {
                      Navigator.maybePop(context)
                          .then((_) => controller.onChangeStudyParticipation());
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            SelectableText(tr.study_launch_post_launch_intro),
            const SizedBox(height: 4.0),
            SelectableText(
              tr.study_launch_post_launch_summary,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32.0),
            ReactiveFormConsumer(
              builder: (context, form, child) {
                return ColoredBox(
                  color: ThemeConfig.containerColor(theme),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 8.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReactiveCheckbox(
                          formControl:
                              formViewModel.isPublishedToRegistryControl,
                        ),
                        const SizedBox(width: 8.0),
                        Flexible(
                          child: FormControlLabel(
                            formControl:
                                formViewModel.isPublishedToRegistryControl,
                            text: tr
                                .study_settings_publish_study_launch_description,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actionButtons: [
          const DismissButton(),
          ReactiveFormConsumer(
            builder: (context, form, child) {
              return PrimaryButton(
                text: tr.action_button_study_launch,
                icon: null,
                onPressedFuture: () => controller.publishStudy(
                  toRegistry: formViewModel.isPublishedToRegistryControl.value!,
                ),
                //.whenComplete(() => Navigator.maybePop(context)),
              );
            },
          ),
        ],
        maxWidth: 650,
        minWidth: 610,
      ),
    );
  }
}
