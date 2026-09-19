import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/onboarding/study_selection.dart';
import 'package:studyu_core/core.dart';

Widget setup(Future<ExtractionResult<Study>> studies) => MaterialApp(
  locale: const Locale('en'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: StudySelectionScreen(publicStudies: studies),
);

void main() {
  testWidgets('shows an empty state when no public studies are available', (
    tester,
  ) async {
    await tester.pumpWidget(setup(Future.value(ExtractionSuccess<Study>([]))));
    await tester.pumpAndSettle();

    expect(find.byType(NoPublicStudiesWidget), findsOneWidget);

  });

  testWidgets('shows a warning when some public studies cannot be extracted', (
    tester,
  ) async {
    final result = ExtractionFailedException<Study>(
      [Study('study-1', 'owner-1')..title = 'Available study'],
      [JsonWithError(const {}, StateError('invalid study'))],
    );

    await tester.pumpWidget(setup(Future.value(result)));
    await tester.pumpAndSettle();
    expect(find.text('Available study'), findsOneWidget);
    expect(find.byType(MaterialBanner), findsOneWidget);
  });
}
