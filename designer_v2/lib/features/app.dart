import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/services/notification_dispatcher.dart';
import 'package:studyu_designer_v2/theme.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey();

/// Entry widget of the app.
class const App({super.key}) extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState() extends State<App> {
  @override
  Widget build(BuildContext context) {
    return const AppContent();
  }
}

class const AppContent({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<AppContent> createState() => _AppContentState();
}

class _AppContentState() extends ConsumerState<AppContent> {
  final settings = ValueNotifier(
    ThemeSettings(
      //sourceColor: Color(0xff2a4fda),
      //sourceColor: Color(0xff583aee),
      sourceColor: const Color(0xff4845e5),
      //sourceColor: const Color(0xff2962ff),
      themeMode: ThemeMode.system,
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppTranslation.init(ref);
    final router = ref.watch(routerProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => ThemeProvider(
        lightDynamic: lightDynamic,
        darkDynamic: darkDynamic,
        settings: settings,
        child: Builder(
          builder: (context) {
            final themeProvider = ThemeProvider.of(context);
            final theme = themeProvider.light(settings.value.sourceColor);
            return MaterialApp.router(
              title: 'StudyU Designer'.hardcoded,
              scaffoldMessengerKey: scaffoldMessengerKey,
              builder: (context, widget) => NotificationDispatcher(
                scaffoldMessengerKey: scaffoldMessengerKey,
                navigatorKey: router.routerDelegate.navigatorKey,
                child: widget,
              ),
              debugShowCheckedModeBanner: Config.isDebugMode,
              color: theme.colorScheme.surface,
              theme: theme,
              routeInformationProvider: router.routeInformationProvider,
              routeInformationParser: router.routeInformationParser,
              routerDelegate: router.routerDelegate,
              locale: ref.watch(localeProvider),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                ...AppLocalizations.localizationsDelegates,
                // See: https://github.com/danvick/flutter_form_builder/blob/master/packages/form_builder_validators/README.md#l10n
                // FormBuilderLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}
