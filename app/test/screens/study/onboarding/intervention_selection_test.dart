import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/intervention_selection.dart';
import 'package:studyu_core/core.dart';

void main() {
  testWidgets('debug selects the first two interventions', (tester) async {
    final study = Study('study', 'user')
      ..interventions = [
        Intervention('one', 'One'),
        Intervention('two', 'Two'),
        Intervention('three', 'Three'),
      ];
    final appState = AppState()..selectedStudy = study;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const InterventionSelectionScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .map((box) => box.value),
      [true, true, false],
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Next'))
          .onPressed,
      isNotNull,
    );
  });
}
