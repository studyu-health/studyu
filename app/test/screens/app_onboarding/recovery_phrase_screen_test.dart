import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/recovery_phrase_screen.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_core/core.dart';

Widget _wrap(Widget child) => ChangeNotifierProvider.value(
  value: AppState(),
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: child,
  ),
);

void main() {
  testWidgets(
    'reveals the recovery phrase and its save confirmation on demand',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const RecoveryPhraseScreen(initialPhrase: ['first', 'second'])),
      );

      expect(find.text('Show Recovery Phrase'), findsOneWidget);
      expect(find.text('first'), findsNothing);
      expect(find.widgetWithText(TextButton, 'Why?'), findsOneWidget);

      await tester.tap(find.text('Show Recovery Phrase'));
      await tester.pumpAndSettle();

      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2));
      expect(find.widgetWithText(TextButton, 'Why?'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);

      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Next'))
            .onPressed,
        isNull,
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Next'))
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('study launch confirmation opens the dashboard', (tester) async {
    var clearedSubjectId = '';
    RecoveryPhraseStorage.debugConfigureForTesting(
      clearPending: (subjectId) async => clearedSubjectId = subjectId,
    );
    addTearDown(RecoveryPhraseStorage.debugResetForTesting);

    final study = Study('study-1', 'user-1');
    final subject = StudySubject('subject-1', study.id, 'user-1', const [])
      ..study = study;
    final appState = AppState()..activeSubject = subject;
    final router = GoRouter(
      initialLocation: '/recovery',
      routes: [
        GoRoute(
          path: '/recovery',
          builder: (_, _) => const RecoveryPhraseScreen(
            initialPhrase: ['first', 'second'],
            continueToDashboard: true,
          ),
        ),
        GoRoute(
          path: '/dashboard',
          name: RouteNames.dashboard,
          builder: (_, _) => const Scaffold(body: Text('Dashboard')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp.router(
          routerConfig: router,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Show Recovery Phrase'), findsNothing);
    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
    expect(find.byType(Chip), findsNWidgets(2));

    final confirmation = find.byType(CheckboxListTile);
    await tester.ensureVisible(confirmation);
    await tester.tap(confirmation);
    await tester.pump();
    await tester.tap(confirmation);
    await tester.pump();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(clearedSubjectId, 'subject-1');
  });
}
