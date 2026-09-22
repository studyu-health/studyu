import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class const CloseSuccessDialog(super.studyId, {super.key})
    extends StudyPageWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return StandardDialog(
      body: Column(
        children: [
          const SizedBox(height: 24.0),
          EmptyBody(
            leading: Text(
              "\u{1f512}".hardcoded,
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize:
                    (theme.textTheme.displayLarge?.fontSize ?? 48.0) * 1.5,
              ),
            ),
            title: tr.notification_study_closed,
            description: tr.notification_study_closed_description,
          ),
          const SizedBox(height: 8.0),
        ],
      ),
      actionButtons: [
        PrimaryButton(
          text: tr.dialog_close,
          icon: null,
          onPressedFuture: () => Navigator.maybePop(context),
        ),
      ],
      maxWidth: 450,
    );
  }
}
