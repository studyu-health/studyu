import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/task_overview.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

import '../../../util/mock_nutrition_draft_storage.dart';

Widget _dashboardWith(
  int interventionCount, {
  bool withTask = false,
  bool preview = true,
  bool trackedPreview = false,
  DateTime? startedAt,
  NutritionTask? nutritionTask,
  NutritionRecallAutoSaveManager? autoSaveManager,
}) {
  final study = Study('study', 'user')
    ..status = trackedPreview ? StudyStatus.draft : StudyStatus.running
    ..interventions = List.generate(
      interventionCount,
      (index) => Intervention('intervention-$index', 'Intervention $index'),
    );
  if (withTask) {
    study.interventions.single.tasks = [
      CheckmarkTask.withId()..title = 'Ignored task',
    ];
  }

  if (nutritionTask != null) study.observations = [nutritionTask];
  final subject = _DashboardStudySubject(
    study,
    study.interventions.map((intervention) => intervention.id).toList(),
    expectPersistedAdvance: preview && trackedPreview,
  )..startedAt = startedAt ?? DateTime.now().add(const Duration(days: 1));
  final appState = AppState()..activeSubject = subject;
  appState.updatePreviewMode(preview);

  return ChangeNotifierProvider.value(
    value: appState,
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      home: DashboardScreen(nutritionAutoSaveManager: autoSaveManager),
    ),
  );
}

void main() {
  setUp(mockNutritionDraftStorage);

  testWidgets('uploads on request and backs off after failure', (tester) async {
    final manager = _TestNutritionAutoSaveManager();
    await tester.pumpWidget(
      _dashboardWith(
        2,
        preview: false,
        startedAt: DateTime.now().subtract(const Duration(days: 1)),
        autoSaveManager: manager,
      ),
    );
    await tester.pumpAndSettle();
    expect(manager.attempts, 1);

    NutritionRecallAutoSaveManager.requestUpload(manager.subjectId!);
    await tester.pump();
    expect(manager.attempts, 2);

    await tester.pump(const Duration(minutes: 4));
    NutritionRecallAutoSaveManager.requestUpload(manager.subjectId!);
    await tester.pump();
    expect(manager.attempts, 2);

    await tester.pump(const Duration(minutes: 1));
    expect(manager.attempts, 3);
  });

  testWidgets('syncs the new study day after an active preview sync', (
    tester,
  ) async {
    final manager = _HeldNutritionAutoSaveManager();
    await tester.pumpWidget(
      _dashboardWith(
        2,
        trackedPreview: true,
        startedAt: DateTime.now().subtract(const Duration(days: 1)),
        autoSaveManager: manager,
      ),
    );
    await tester.pumpAndSettle();
    expect(manager.studyDays, [1]);

    await tester.tap(find.text('Next day'));
    await tester.pumpAndSettle();
    expect(manager.studyDays, [1]);

    manager.firstPass.complete(false);
    await tester.pumpAndSettle();
    expect(manager.studyDays, [1, 2]);
  });

  testWidgets('advances the study day in debug without preview', (
    tester,
  ) async {
    await DashboardShowcaseStorage.markCompleted();
    final startedAt = DateTime.now().subtract(const Duration(days: 1));
    await tester.pumpWidget(
      _dashboardWith(
        2,
        preview: false,
        startedAt: startedAt,
        autoSaveManager: _TestNutritionAutoSaveManager(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next day'));
    await tester.pumpAndSettle();

    final appState = tester
        .element(find.byType(DashboardScreen))
        .read<AppState>();
    expect(
      appState.activeSubject!.startedAt,
      startedAt.subtract(const Duration(days: 1)),
    );
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

  testWidgets('dashboard menu shows report history only', (tester) async {
    await tester.pumpWidget(
      _dashboardWith(
        2,
        startedAt: DateTime.now().subtract(const Duration(days: 1)),
        nutritionTask: NutritionTask.withId()..title = 'Nutrition diary',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<OverflowMenuItem>));
    await tester.pumpAndSettle();
    expect(find.text('Report history'), findsOneWidget);
    expect(find.text('History'), findsNothing);
  });
}

class _DashboardStudySubject(
  Study study,
  List<String> selectedInterventionIds, {
  required final bool expectPersistedAdvance,
}) extends StudySubject {
  this : super.fromStudy(study, 'user', selectedInterventionIds, null);

  @override
  Future<void> setStartDateBackBy({required int days, bool persist = true}) {
    expect(persist, expectPersistedAdvance);
    return super.setStartDateBackBy(days: days, persist: false);
  }
}

class _TestNutritionAutoSaveManager() extends NutritionRecallAutoSaveManager {
  int attempts = 0;
  String? subjectId;

  @override
  Future<bool> submitPendingRecalls({
    required StudySubject subject,
    required bool trackProgress,
    bool trackedPreview = false,
    DateTime? now,
  }) async {
    subjectId = subject.id;
    return ++attempts == 2;
  }
}

class _HeldNutritionAutoSaveManager() extends NutritionRecallAutoSaveManager {
  final firstPass = Completer<bool>();
  final studyDays = <int>[];

  @override
  Future<bool> submitPendingRecalls({
    required StudySubject subject,
    required bool trackProgress,
    bool trackedPreview = false,
    DateTime? now,
  }) {
    expect(trackedPreview, isTrue);
    studyDays.add(nutritionStudyDayFor(subject, DateTime.now()));
    return studyDays.length == 1 ? firstPass.future : Future.value(false);
  }
}
