import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/task_overview.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_history_screen.dart';
import 'package:studyu_app/screens/study/tasks/observation/nutrition_task_widget.dart';
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
  DailyRecall? historicalRecall,
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
  )..startedAt = startedAt ?? DateTime.now().add(const Duration(days: 1));
  if (nutritionTask != null && historicalRecall != null) {
    final progress = SubjectProgress(
      subjectId: subject.id,
      taskId: nutritionTask.id,
      resultType: 'DailyRecall',
      interventionId: Study.baselineID,
      result: Result<DailyRecall>.app(
        type: 'DailyRecall',
        periodId: nutritionTask.schedule.completionPeriods.single.id,
        result: historicalRecall,
      ),
    )..completedAt = historicalRecall.entryCompletedAt;
    subject.progress.add(progress);
  }
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

  testWidgets('opens yesterday from the dashboard without a task today', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime.now().toUtc();
    final yesterday = DateTime.utc(now.year, now.month, now.day - 1, 12);
    final task = NutritionTask.withId()
      ..title = 'One-day diary'
      ..scheduleRule = TaskScheduleRule.forSpecificDays([0]);
    final recall = DailyRecall.withId(
      date: yesterday,
      recallMode: RecallMode.realtimeRecord,
      entryCompletedAt: yesterday,
      studyDaySnapshot: 0,
      meals: [],
    );
    await tester.pumpWidget(
      _dashboardWith(
        2,
        startedAt: yesterday,
        nutritionTask: task,
        historicalRecall: recall,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('One-day diary'), findsNothing);
    await tester.tap(find.byType(PopupMenuButton<OverflowMenuItem>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.byType(NutritionHistoryScreen), findsOneWidget);
    await tester.tap(find.text('No foods logged'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<NutritionTaskWidget>(find.byType(NutritionTaskWidget))
          .readOnly,
      isFalse,
    );
  });
}

class _DashboardStudySubject(Study study, List<String> selectedInterventionIds)
    extends StudySubject {
  this : super.fromStudy(study, 'user', selectedInterventionIds, null);

  @override
  Future<void> setStartDateBackBy({required int days, bool persist = true}) {
    expect(persist, isTrue);
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
