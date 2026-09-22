import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/features/study/study_test_app_routes.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const StudyTestScreen(
  super.studyId, {
  final String? previewRoute,
  super.key,
}) extends StudyPageWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formViewModel = ref.watch(studyTestValidatorProvider(studyId));
    final canTest = !formViewModel.form.hasErrors;

    final frameController = ref.watch(
      studyTestPlatformControllerProvider(studyId),
    );
    load().then((hasHelped) {
      if (!hasHelped && context.mounted) {
        showHelp(ref, context);
      }
    });
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6.0),
              Text(tr.study_test_page_description),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.help),
                    label: Text(tr.navlink_study_test_help),
                    onPressed: () => showHelp(ref, context),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Text(tr.study_test_app_nav_title),
              const SizedBox(height: 12.0),
              ValueListenableBuilder<bool>(
                valueListenable: frameController.navigationEnabled,
                builder: (context, previewReady, child) {
                  final navigationEnabled = canTest && previewReady;
                  final screenerDisabled =
                      !navigationEnabled ||
                      formViewModel
                          .enrollmentFormViewModel
                          .questionModels
                          .isEmpty;
                  final interventionSelectionDisabled =
                      !navigationEnabled ||
                      formViewModel
                              .interventionsFormViewModel
                              .interventionsArray
                              .value!
                              .length <=
                          2;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(tr.navlink_study_test_app_overview),
                        onPressed: (!navigationEnabled)
                            ? null
                            : () {
                                frameController.navigate(
                                  route: TestAppRoutes.studyOverview,
                                );
                              },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(tr.navlink_study_test_app_eligibility),
                        onPressed: screenerDisabled
                            ? null
                            : () {
                                frameController.navigate(
                                  route: TestAppRoutes.eligibility,
                                );
                              },
                      ),
                      Row(
                        children: [
                          Tooltip(
                            message:
                                interventionSelectionDisabled &&
                                    navigationEnabled
                                ? tr.navlink_study_test_app_intervention_disabled
                                : '',
                            child: TextButton.icon(
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(
                                tr.navlink_study_test_app_intervention,
                              ),
                              onPressed: interventionSelectionDisabled
                                  ? null
                                  : () {
                                      frameController.navigate(
                                        route: TestAppRoutes.intervention,
                                      );
                                    },
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(tr.navlink_study_test_app_consent),
                        onPressed: (!navigationEnabled)
                            ? null
                            : () {
                                frameController.navigate(
                                  route: TestAppRoutes.consent,
                                );
                              },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(tr.navlink_study_test_app_journey),
                        onPressed: (!navigationEnabled)
                            ? null
                            : () {
                                frameController.navigate(
                                  route: TestAppRoutes.journey,
                                );
                              },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(tr.navlink_study_test_app_dashboard),
                        onPressed: (!navigationEnabled)
                            ? null
                            : () {
                                frameController.navigate(
                                  route: TestAppRoutes.dashboard,
                                );
                              },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: PreviewFrame(studyId, route: previewRoute),
            ),
          ],
        ),
        Flexible(child: Container()),
      ],
    );
  }

  @override
  Widget? banner(BuildContext context, WidgetRef ref) {
    final formViewModel = ref.watch(studyTestValidatorProvider(studyId));
    if (!formViewModel.form.hasErrors) {
      return null;
    }
    return BannerBox(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextParagraph(
            text: tr.banner_study_test_unavailable,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ReactiveForm(
            formGroup: formViewModel.form,
            child: ReactiveFormConsumer(
              builder: (context, form, child) {
                return TextParagraph(text: form.validationErrorSummary);
              },
            ),
          ),
        ],
      ),
      style: BannerStyle.warning,
    );
  }

  Future<bool> load() async {
    try {
      final bool? visited = await SecureStorage.readBool('testScreenVisited');
      if (visited != null) {
        return visited;
      }
    } catch (e) {
      rethrow;
    }
    return false;
  }

  Future<void> save() async {
    SecureStorage.write('testScreenVisited', "true");
  }

  void showHelp(WidgetRef ref, BuildContext context) {
    final theme = Theme.of(context);
    final Widget previewHelp = PointerInterceptor(
      child: StandardDialog(
        titleText: tr.dialog_study_test_help_title,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextParagraph(text: tr.dialog_study_test_help_description),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "\n${tr.dialog_study_test_section_tips}\n",
                style: theme.textTheme.headlineSmall,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextParagraph(text: tr.dialog_study_test_section_tips_text),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextParagraph(
                      text: tr.dialog_study_test_download_url_intro,
                    ),
                    Hyperlink(
                      text: tr.dialog_study_test_download_url_text,
                      url: tr.dialog_study_test_download_url,
                    ),
                    TextParagraph(
                      text: tr.dialog_study_test_download_url_outro,
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "\n${tr.dialog_study_test_section_notice}\n",
                style: theme.textTheme.headlineSmall,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextParagraph(
                text: tr.dialog_study_test_section_notice_text,
              ),
            ),
          ],
        ),
        actionButtons: [
          PrimaryButton(
            text: tr.dialog_action_study_test_start,
            icon: null,
            onPressed: () => Navigator.pop(context),
          ),
        ],
        maxWidth: 650,
        minWidth: 550,
      ),
    );
    showDialog(
      context: context,
      barrierColor: ThemeConfig.modalBarrierColor(theme),
      builder: (context) => previewHelp,
    );
    save();
  }
}
