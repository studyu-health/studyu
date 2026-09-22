import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';

abstract class const StudyPageWidget(final String studyId, {super.key})
    extends ConsumerWidget
    implements IWithBanner {
  @override
  Widget? banner(BuildContext context, WidgetRef ref) {
    return null; // override in subclasses to provide an optional banner
  }
}
