import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

class const StudyUnavailableScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final router = GoRouter.maybeOf(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Image(
                  image: AssetImage('assets/icon/logo.png'),
                  height: 200,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.study_not_available_for_testing_yet,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
                if (router != null) ...[
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.back),
                    onPressed: () {
                      if (router.canPop()) {
                        router.pop();
                      } else {
                        router.goNamed(RouteNames.welcome);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
