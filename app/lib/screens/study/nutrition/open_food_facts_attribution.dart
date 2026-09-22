import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class const OpenFoodFactsAttribution({super.key}) extends StatelessWidget {
  static final _termsUri = Uri.parse(
    'https://world.openfoodfacts.org/terms-of-use',
  );

  Future<void> _openTerms(BuildContext context) async {
    var launched = false;
    try {
      launched = await launchUrl(
        _termsUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Show accessible feedback below.
    }
    if (launched || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Semantics(
          liveRegion: true,
          child: Text(
            AppLocalizations.of(context)!
                .open_food_facts_attribution_launch_error,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: TextButton(
        onPressed: () => _openTerms(context),
        child: Text(AppLocalizations.of(context)!.open_food_facts_attribution),
      ),
    );
  }
}
