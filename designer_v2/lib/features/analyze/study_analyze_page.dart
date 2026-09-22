import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/common_views/under_construction.dart';
import 'package:studyu_designer_v2/features/analyze/study_analyze_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class const StudyAnalyzeScreen(super.studyId, {super.key})
    extends StudyPageWidget {
  @override
  Widget? banner(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyAnalyzeControllerProvider(studyId));

    if (state.isDraft) {
      return BannerBox(
        noPrefix: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [TextParagraph(text: tr.banner_text_study_analyze_draft)],
        ),
        style: BannerStyle.info,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.watch(
      studyAnalyzeControllerProvider(studyId).notifier,
    );
    final state = ref.watch(studyAnalyzeControllerProvider(studyId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: ThemeConfig.containerColor(theme),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 48.0,
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SelectableText(
                  tr.action_button_study_export_prompt,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 24.0),
                PrimaryButton(
                  text: tr.action_button_study_export,
                  icon: Icons.download_rounded,
                  enabled: state.canExport,
                  tooltipDisabled: state.exportDisabledReason,
                  onPressedFuture: () => controller.onExport(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32.0),
        Container(
          width: double.infinity,
          color: theme.colorScheme.secondary.withValues(alpha: 0.03),
          height: 300,
          child: const Center(child: UnderConstruction()),
        ),
      ],
    );
  }
}
