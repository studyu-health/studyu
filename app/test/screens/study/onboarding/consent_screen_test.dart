import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/consent.dart';
import 'package:studyu_core/core.dart';

void main() {
  testWidgets('uses the localized consent label as the native title', (
    tester,
  ) async {
    final study = Study.withId('user')..title = 'Study';
    final subject = StudySubject.fromStudy(study, 'user', [], null);
    final appState = AppState()..activeSubject = subject;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: Locale('de'),
          home: ConsentScreen(),
        ),
      ),
    );
    await tester.pump();

    final title = tester.widget<Title>(
      find.byWidgetPredicate(
        (widget) => widget is Title && widget.title == 'Einverständnis',
      ),
    );
    expect(
      title.color,
      Theme.of(tester.element(find.byType(ConsentScreen))).colorScheme.primary,
    );
  });
}
