import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/env.dart';
import 'package:url_launcher/url_launcher.dart';

class const AppOutdatedScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    String? storeUrl;
    IconData? storeIcon;
    if (!kIsWeb && Platform.isAndroid) {
      if (androidPackageName != null) {
        storeUrl =
            'https://play.google.com/store/apps/details?id=$androidPackageName';
      }
      storeIcon = Icons.shop;
    } else if (!kIsWeb && Platform.isIOS) {
      if (iosAppStoreId != null) {
        storeUrl = 'https://apps.apple.com/app/id$iosAppStoreId';
      }
      storeIcon = Icons.shop;
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              const Image(
                image: AssetImage('assets/icon/logo.png'),
                height: 200,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  loc.app_outdated_message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const Spacer(),
              if (storeUrl != null && storeIcon != null)
                OutlinedButton.icon(
                  icon: Icon(storeIcon),
                  onPressed: () async {
                    await launchUrl(
                      Uri.parse(storeUrl!),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  },
                  label: Text(
                    loc.update_now,
                    style: const TextStyle(fontSize: 20),
                  ),
                )
              else
                const SizedBox.shrink(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
