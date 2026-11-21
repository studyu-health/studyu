import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/task_overview.dart';
import 'package:studyu_app/screens/study/tasks/observation/nutrition_task_widget.dart';
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
  StudySchedule? studySchedule,
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
  if (studySchedule != null) study.schedule = studySchedule;
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

  for (final saved in [true, false]) {
    final entryType = saved ? 'saved entry' : 'local draft';
    testWidgets('corrects a $entryType across an intervention change', (
      tester,
    ) async {
      final now = DateTime.now().toUtc();
      final task = NutritionTask.withId()
        ..title = 'Nutrition diary'
        ..trackWaterIntake = true
        ..scheduleRule = TaskScheduleRule.forSpecificDays([1, 2]);
      SharedPreferences.setMockInitialValues({
        'nutrition_instructions_shown_${task.id}': true,
      });
      await tester.pumpWidget(
        _dashboardWith(
          2,
          startedAt: DateTime.utc(now.year, now.month, now.day - 2),
          nutritionTask: task,
          studySchedule: StudySchedule()
            ..includeBaseline = false
            ..phaseDuration = 3,
        ),
      );
      await tester.pumpAndSettle();
      final appState = tester
          .element(find.byType(DashboardScreen))
          .read<AppState>();
      final subject = appState.activeSubject!;
      final drafts = appState.previewNutritionDrafts!;
      final intervention = subject.getNutritionInterventionForStudyDay(2)!;
      final period = task.schedule.completionPeriods.single;
      final date = subject.nutritionDateForStudyDay(2);
      final recall = DailyRecall.withId(
        date: date,
        recallMode: RecallMode.realtimeRecord,
        entryCompletedAt: saved ? date : null,
        studyDaySnapshot: 2,
        meals: [],
      );
      if (saved) {
        subject.progress.add(
          SubjectProgress(
            subjectId: subject.id,
            interventionId: intervention.id,
            taskId: task.id,
            resultType: 'DailyRecall',
            result: Result<DailyRecall>.app(
              type: 'DailyRecall',
              periodId: period.id,
              result: recall,
            ),
          )..completedAt = date,
        );
      } else {
        await drafts.saveRecall(
          recall: recall,
          subjectId: subject.id,
          taskId: task.id,
          interventionId: intervention.id,
          periodId: period.id,
          studyDaySnapshot: 2,
        );
      }

      final review = find.text('Review previous day’s nutrition');
      expect(review, findsNothing);
      await tester.tap(find.text('Next day'));
      await tester.pumpAndSettle();
      expect(
        subject.getNutritionInterventionForStudyDay(3)?.id,
        isNot(intervention.id),
      );
      expect(subject.scheduleFor(now), isEmpty);
      await tester.tap(review);
      await tester.pumpAndSettle();
      await tester.tap(find.text('No foods logged'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<NutritionTaskWidget>(find.byType(NutritionTaskWidget))
            .readOnly,
        isFalse,
      );

      final addCup = find.byTooltip('Add a cup of water');
      await tester.ensureVisible(addCup);
      await tester.tap(addCup);
      await tester.pumpAndSettle();
      final corrected = (await drafts.scanPendingRecalls(subject.id)).single;
      expect(corrected.recall.waterIntakeMl, 250);
      expect(corrected.studyDaySnapshot, 2);
      expect(corrected.interventionId, intervention.id);
      expect(corrected.periodId, period.id);
      expect(
        corrected.progressCompletedAt,
        saved ? subject.progress.single.completedAt : null,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(review, findsOneWidget);

      task.scheduleRule = TaskScheduleRule.forSpecificDays([1, 2, 3]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(review, findsNothing);
      expect(subject.scheduleFor(now).single.task.id, task.id);

      await tester.tap(find.text('Next day'));
      await tester.pumpAndSettle();
      expect(review, findsNothing);
    });
  }
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
