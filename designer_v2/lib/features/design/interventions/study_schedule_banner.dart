import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/reusable_banner.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const StudyScheduleBanner({
  final bool isDismissed = false,
  final Function()? onDismissed,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ReusableBanner(
      isDismissed: isDismissed,
      onDismissed: onDismissed,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(tr.study_schedule_banner_explanation),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
