import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

abstract class const StudyDesignPageWidget(super.studyId, {super.key})
    extends StudyPageWidget {
  @override
  Widget? banner(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(studyFormViewModelProvider(studyId));

    if (viewModel.isStudyReadonly) {
      return BannerBox(
        noPrefix: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextParagraph(
              text: tr.banner_study_readonly_title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextParagraph(text: tr.banner_study_readonly_description),
          ],
        ),
        style: BannerStyle.info,
      );
    }

    return null;
  }
}
