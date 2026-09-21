import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/task_overview.dart';
import 'package:studyu_core/core.dart';

Widget _dashboardWith(
  int interventionCount, {
  bool withTask = false,
  bool preview = true,
  DateTime? startedAt,
}) {
  final study = Study('study', 'user')
    ..status = StudyStatus.running
    ..interventions = List.generate(
      interventionCount,
      (index) => Intervention('intervention-$index', 'Intervention $index'),
    );
  if (withTask) {
    study.interventions.single.tasks = [
      CheckmarkTask.withId()..title = 'Ignored task',
    ];
  }

  final subject = StudySubject.fromStudy(
    study,
    'user',
    study.interventions.map((intervention) => intervention.id).toList(),
    null,
  )..startedAt = startedAt ?? DateTime.now().add(const Duration(days: 1));
  final appState = AppState()..activeSubject = subject;
  appState.updatePreviewMode(preview);

  return ChangeNotifierProvider.value(
    value: appState,
    child: const MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: Locale('en'),
      home: DashboardScreen(),
    ),
  );
}

void main() {
  testWidgets('study with one intervention stays unavailable despite tasks', (
    tester,
  ) async {
    await tester.pumpWidget(_dashboardWith(1, withTask: true));

    expect(
      find.text('This study is not available for testing yet.'),
      findsOneWidget,
    );
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(TaskOverview), findsNothing);
    expect(find.text('Dashboard'), findsNothing);
  });

  testWidgets('study with two interventions shows dashboard', (tester) async {
    await tester.pumpWidget(_dashboardWith(2));

    expect(
      find.text('This study is not available for testing yet.'),
      findsNothing,
    );
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
