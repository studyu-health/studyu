import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/app_onboarding/welcome_entry_hub.dart';

PreviewLocalizationsData studyuEnglishPreviewLocalizations() =>
    const PreviewLocalizationsData(
      locale: Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );

PreviewLocalizationsData studyuGermanPreviewLocalizations() =>
    const PreviewLocalizationsData(
      locale: Locale('de'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );

@Preview(
  group: 'Onboarding',
  name: 'Welcome hub · English',
  size: Size(390, 844),
  localizations: studyuEnglishPreviewLocalizations,
)
@Preview(
  group: 'Onboarding',
  name: 'Welcome hub · compact German',
  size: Size(320, 568),
  textScaleFactor: 1.1,
  localizations: studyuGermanPreviewLocalizations,
)
Widget welcomeEntryHubPreview() => const WelcomeEntryHub(
  logoAssetPath: 'packages/studyu_app/assets/icon/logo.png',
  onLogoDoubleTap: _noop,
  onBrowsePublicStudies: _noop,
  onUseInviteCode: _noop,
  onRestoreAccount: _noop,
  onAbout: _noop,
  onFaq: _noop,
  onContact: _noop,
  selectedLocale: Locale('en'),
  onLocaleChanged: _noopLocale,
);

void _noop() {}
void _noopLocale(Locale? _) {}
