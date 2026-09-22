import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class const ErrorPage({required final Exception? error, super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectableText(error.toString()),
          TextButton(
            onPressed: () =>
                ref.read(routerProvider).dispatch(RoutingIntents.studies),
            child: Text(tr.navlink_error_home),
          ),
        ],
      ),
    );
  }
}
