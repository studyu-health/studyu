import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/deferred_fitbit_request.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/task_overview.dart';
import 'package:studyu_app/util/cache.dart';
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
  testWidgets('next day preserves pending Fitbit windows', (tester) async {
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    final storage = <String, String>{};
    Cache.debugResetSynchronizationStateForTesting();
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      final args = call.arguments as Map;
      final key = args['key'] as String;
      return switch (call.method) {
        'write' => storage[key] = args['value'] as String,
        'read' => storage[key],
        'containsKey' => storage.containsKey(key),
        _ => null,
      };
    });
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
      Cache.debugResetSynchronizationStateForTesting();
    });
    await tester.pumpWidget(_dashboardWith(2));
    final subject = tester
        .element(find.byType(DashboardScreen))
        .read<AppState>()
        .activeSubject!;
    final start = subject.startedAt;
    final completedAt = DateTime.utc(2026, 8, 11);
    await tester.runAsync(
      () => Cache.storeDeferredFitbitRequests([
        DeferredFitbitRequest(
          subjectId: subject.id,
          interventionId: 'intervention-0',
          taskId: 'task',
          periodId: 'period',
          questionId: 'question',
          windowStart: completedAt,
          windowEnd: completedAt,
          completedAt: completedAt,
        ),
      ]),
    );
    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.fast_forward_rounded));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
    expect(
      find.text('Fitbit data will sync when a connection is available.'),
      findsOneWidget,
    );
    expect(subject.startedAt, start);
    expect(
      await tester.runAsync(Cache.loadDeferredFitbitRequests),
      hasLength(1),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
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
