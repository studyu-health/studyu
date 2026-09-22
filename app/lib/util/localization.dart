import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

String? localeName(BuildContext context, String countryCode) {
  final localeStrings = {
    'en': AppLocalizations.of(context)!.en,
    'de': AppLocalizations.of(context)!.de,
    'ko': AppLocalizations.of(context)!.ko,
  };
  return localeStrings[countryCode];
}
