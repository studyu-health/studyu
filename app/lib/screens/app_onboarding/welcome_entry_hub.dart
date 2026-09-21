import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/util/localization.dart';

class const WelcomeEntryHub({
  required final VoidCallback onLogoDoubleTap,
  required final VoidCallback onBrowsePublicStudies,
  required final VoidCallback onUseInviteCode,
  required final VoidCallback onRestoreAccount,
  required final VoidCallback onAbout,
  required final VoidCallback onFaq,
  required final VoidCallback onContact,
  required final Locale? selectedLocale,
  required final ValueChanged<Locale?>? onLocaleChanged,
  final String logoAssetPath = 'assets/icon/logo.png',
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final madeWithLove = l10n.made_with_love_in_potsdam.split('♥');
    final primaryButtonStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      textStyle: theme.textTheme.titleMedium,
    );
    final secondaryButtonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      textStyle: theme.textTheme.titleMedium,
    );
    final tertiaryButtonStyle = TextButton.styleFrom(
      foregroundColor: theme.colorScheme.primary,
      minimumSize: const Size(0, 32),
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
    );
    final footerLinkStyle = TextButton.styleFrom(
      foregroundColor: theme.colorScheme.onSurfaceVariant,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            key: const PageStorageKey('welcome_entry_hub_scroll'),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 440,
                  minHeight: constraints.maxHeight > 24
                      ? constraints.maxHeight - 24
                      : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onDoubleTap: onLogoDoubleTap,
                          child: Image.asset(logoAssetPath, height: 140),
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.welcome_find_study_title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // const SizedBox(height: 8),
                        // Text(
                        //   l10n.welcome_find_study_description,
                        //   style: theme.textTheme.bodyLarge,
                        //   textAlign: TextAlign.center,
                        // ),
                        const SizedBox(height: 40),
                        FilledButton.icon(
                          key: const ValueKey('welcome_get_started'),
                          style: primaryButtonStyle,
                          icon: const Icon(Icons.search),
                          onPressed: onBrowsePublicStudies,
                          label: Text(l10n.browse_public_studies),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const ValueKey('welcome_use_invite_code'),
                          style: secondaryButtonStyle,
                          icon: const Icon(Icons.vpn_key_outlined),
                          onPressed: onUseInviteCode,
                          label: Text(l10n.invite_code_button),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.welcome_returning_participant,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        TextButton.icon(
                          key: const ValueKey('welcome_restore_account'),
                          style: tertiaryButtonStyle,
                          icon: const Icon(Icons.restore),
                          onPressed: onRestoreAccount,
                          label: Text(l10n.restore_account),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                key: const ValueKey('welcome_about'),
                                style: footerLinkStyle,
                                onPressed: onAbout,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      MdiIcons.helpCircleOutline,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(child: Text(l10n.about)),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                key: const ValueKey('welcome_faq'),
                                style: footerLinkStyle,
                                onPressed: onFaq,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      MdiIcons.frequentlyAskedQuestions,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(child: Text(l10n.faq)),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                key: const ValueKey('welcome_contact'),
                                style: footerLinkStyle,
                                onPressed: onContact,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(MdiIcons.email, size: 18),
                                    const SizedBox(width: 4),
                                    Flexible(child: Text(l10n.contact)),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: PopupMenuButton<Locale>(
                                key: const ValueKey('welcome_language_picker'),
                                tooltip: l10n.language,
                                enabled: onLocaleChanged != null,
                                onSelected: (locale) =>
                                    onLocaleChanged?.call(locale),
                                itemBuilder: (context) => [
                                  PopupMenuItem<Locale>(
                                    enabled: false,
                                    child: Text(
                                      l10n.language,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  for (final locale
                                      in AppLocalizations.supportedLocales)
                                    PopupMenuItem<Locale>(
                                      value: locale,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            child:
                                                selectedLocale?.languageCode ==
                                                    locale.languageCode
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 18,
                                                  )
                                                : null,
                                          ),
                                          Text(
                                            localeName(
                                              context,
                                              locale.languageCode,
                                            )!,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                                child: SizedBox(
                                  height: 48,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.language,
                                        size: 18,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          l10n.language,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 13,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text.rich(
                            TextSpan(
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.65),
                                fontSize: 11,
                              ),
                              children: [
                                TextSpan(text: madeWithLove.first),
                                TextSpan(
                                  text: '♥',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                if (madeWithLove.length > 1)
                                  TextSpan(text: madeWithLove.last),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
