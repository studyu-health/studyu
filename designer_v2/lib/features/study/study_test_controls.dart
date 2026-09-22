import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

// todo move this either to study_test_fame_views or do something like PreviewWidget(
class const FrameControlsWidget({
  final bool enabled = true,
  final bool openNewTabEnabled = false,
  final VoidCallback? onRefresh,
  final VoidCallback? onOpenNewTab,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.restart_alt),
          label: Text(tr.action_button_study_test_reset),
          onPressed: (!enabled) ? null : onRefresh,
        ),
        TextButton.icon(
          icon: const Icon(Icons.open_in_new_sharp),
          label: Text(tr.action_button_study_test_open_new_tab),
          onPressed: (!openNewTabEnabled) ? null : onOpenNewTab,
        ),
      ],
    );
  }
}
