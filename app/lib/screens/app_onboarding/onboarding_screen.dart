import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const OnboardingScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IntroductionScreen(
      rawPages: [
        _buildPage(
          title: l10n.onboarding_page0_title,
          body: l10n.onboarding_page0_subtitle,
          imagePath: 'assets/icon/logo.png',
        ),
        _buildPage(
          title: l10n.onboarding_page1_title,
          body: l10n.onboarding_page1_subtitle,
          imagePath: 'assets/images/onboarding/page1.svg',
        ),
        _buildPage(
          title: l10n.onboarding_page2_title,
          body: l10n.onboarding_page2_subtitle,
          imagePath: 'assets/images/onboarding/page2.svg',
        ),
        _buildPage(
          title: l10n.onboarding_page3_title,
          body: l10n.onboarding_page3_subtitle,
          imagePath: 'assets/images/onboarding/page3.svg',
        ),
        _buildPage(
          title: l10n.onboarding_page4_title,
          body: l10n.onboarding_page4_subtitle,
          imagePath: 'assets/images/onboarding/page4.svg',
        ),
      ],
      showBackButton: true,
      back: Text(l10n.back, key: const ValueKey('onboarding_back')),
      next: Text(l10n.next, key: const ValueKey('onboarding_next')),
      done: Text(
        key: const ValueKey('onboarding_done'),
        l10n.done,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onDone: () async {
        await SecureStorage.write('onboarded', 'true');
        if (!context.mounted) return;

        // If onboarding was shown again (from FAQ)
        final state = context.read<AppState>();
        if (state.activeSubject != null) {
          context.goNamed(RouteNames.dashboard);
        } else if (state.pendingDeepLinkStudyId != null ||
            state.pendingDeepLinkInviteCode != null) {
          context.goNamed(RouteNames.welcome);
        } else {
          context.goNamed(RouteNames.welcome);
        }
      },
    );
  }

  Widget _buildPage({
    required String title,
    required String body,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imagePath.endsWith('.svg'))
                    SvgPicture.asset(imagePath, height: 250)
                  else
                    Image.asset(imagePath, height: 250),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    body,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
