import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class const SurveyPreview({
  required final MeasurementFormRouteArgs routeArgs,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primaryContainer
          .withValues(alpha: 0.25),
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
          if (previewBanner(ref, routeArgs.studyId) case final banner?)
            Positioned(top: 0, left: 0, right: 0, child: banner),
        ],
      ),
    );
  }
}
