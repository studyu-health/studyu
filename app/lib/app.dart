import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/main.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_app/util/date_time_preferences.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const MyApp(
  final Map<String, String> queryParameters,
  final AppConfig? appConfig, {
  super.key,
  required final String initialRoute,
}) extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState() extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(
      queryParameters: widget.queryParameters,
      initialLocation: widget.initialRoute,
      navigatorKey: navigatorKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLanguage>(
          create: (context) => AppLanguage(AppLocalizations.supportedLocales),
        ),
        ChangeNotifierProvider<DateTimePreferences>(
          create: (context) => DateTimePreferences(),
        ),
        ChangeNotifierProvider<AppState>(create: (context) => AppState()),
      ],
      child: Consumer<AppLanguage>(
        builder: (context, model, child) {
          return MaterialApp.router(
            title: 'StudyU',
            theme: theme,
            routerConfig: _router,
            localeListResolutionCallback: (locales, supportedLocales) {
              // print('device locales=$locales supported locales=$supportedLocales');
              final supportedLanguageCodes = supportedLocales.map(
                (e) => e.languageCode,
              );
              if (locales != null) {
                for (final locale in locales) {
                  if (supportedLanguageCodes.contains(locale.languageCode)) {
                    return locale;
                  }
                }
              }
              return const Locale('en');
            },
            locale: model.appLocal,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          );
        },
      ),
    );
  }
}
