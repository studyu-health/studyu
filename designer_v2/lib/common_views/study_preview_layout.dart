import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/theme.dart';

class const StudyPreviewLayout({
  required final StudyFormRouteArgs routeArgs,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banner = previewBanner(ref, routeArgs.studyId);
    return ColoredBox(
      color: ThemeConfig.sidesheetBackgroundColor(Theme.of(context)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Expanded(
                  child: PreviewFrame(routeArgs.studyId, routeArgs: routeArgs),
                ),
              ],
            ),
          ),
          if (banner == null)
            const SizedBox.shrink()
          else
            Positioned(top: 0, left: 0, right: 0, child: banner),
        ],
      ),
    );
  }
}
