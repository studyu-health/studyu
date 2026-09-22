import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/welcome_entry_hub.dart';
import 'package:studyu_app/screens/study/onboarding/study_selection.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/util/debug_screen.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const WelcomeScreen({super.key}) extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState() extends State<WelcomeScreen> {
  bool _inviteDialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<AppState>();
    if (!_inviteDialogShown &&
        state.hasPendingDeepLink &&
        state.selectedStudy != null) {
      _inviteDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showInviteDialog());
    }
  }

  Future<void> _showInviteDialog() async {
    if (!mounted) return;
    final state = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;

    while (state.hasPendingDeepLink && state.selectedStudy != null) {
      if (!mounted) return;
      final accepted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(l10n.you_have_been_invited),
          content: Text(state.selectedStudy?.title ?? ''),
          actions: [
            TextButton(
              key: const ValueKey('invite_dialog_decline'),
              onPressed: () => context.pop(false),
              child: Text(l10n.decline),
            ),
            FilledButton(
              key: const ValueKey('invite_dialog_accept'),
              onPressed: () => context.pop(true),
              child: Text(l10n.accept),
            ),
          ],
        ),
      );

      if (!mounted) return;
      if (accepted == true) {
        await context.push('/${RouteNames.studyOverview}');
      } else {
        await PendingDeepLinkService.clear(state);
      }
    }

    _inviteDialogShown = false;
  }

  Future<void> _showInviteCodeDialog() => showDialog<void>(
    context: context,
    animationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 220),
      reverseDuration: Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
    builder: (_) => const InviteCodeDialog(),
  );

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<AppLanguage?>();

    return WelcomeEntryHub(
      onLogoDoubleTap: () => DebugScreen.showDebugScreen(context),
      onBrowsePublicStudies: () =>
          context.push('/${RouteNames.studySelection}'),
      onUseInviteCode: _showInviteCodeDialog,
      onRestoreAccount: () => context.pushNamed(RouteNames.restoreAccount),
      onAbout: () => context.push('/${RouteNames.about}'),
      onFaq: () => context.push('/${RouteNames.faq}'),
      onContact: () => context.push('/${RouteNames.contact}'),
      selectedLocale:
          appLanguage?.appLocal ??
          resolveSupportedLocale(
            Localizations.localeOf(context).toLanguageTag(),
            AppLocalizations.supportedLocales,
          ),
      onLocaleChanged: appLanguage?.changeLanguage,
    );
  }
}
