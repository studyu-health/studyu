import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_statistics_view.dart';
import 'package:studyu_core/core.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows localized averages for completed study days', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();
    final today = DateUtils.dateOnly(DateTime.now());
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = today.subtract(const Duration(days: 1));
    final recall = _recall(
      date: today,
      studyDay: 1,
      energyKcal: 1234,
      completed: true,
    );
    subject.progress.add(_progress(recall));

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('de'),
        home: NutritionStatisticsView(subject: subject, taskId: 'task'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Durchschnitt abgeschlossener Tage'), findsOneWidget);
    expect(find.text('1.234 kcal'), findsWidgets);
    expect(find.text('1,5 g'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(Card).first).getSemanticsData().label,
      contains('Kohlenhydrate 2%, Protein 16%, Fett 82%'),
    );
    final energyCard = find.ancestor(
      of: find.text('Energie pro Studientag'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(of: energyCard, matching: find.text('kcal')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: energyCard, matching: find.text('Heute')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Heute bisher, 1\\.234 kcal')),
      findsOneWidget,
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(NutritionStatisticsView)),
    )!;
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.nutrition_statistics_help_message), findsOneWidget);
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pump();

    final nutrientTitle = find.text('Nährstoffverlauf').first;
    final nutrientCard = find
        .ancestor(of: nutrientTitle, matching: find.byType(Card))
        .first;
    expect(
      find.descendant(of: nutrientCard, matching: find.text('g')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nutrientCard, matching: find.text('Heute')),
      findsOneWidget,
    );
    for (final label in ['0', '0,05', '0,1', '0,15', '0,2']) {
      expect(
        find.descendant(of: nutrientCard, matching: find.text(label)),
        findsOneWidget,
      );
    }
    for (var offset = 6; offset > 0; offset--) {
      final label = DateFormat.E('de').format(addCalendarDays(today, -offset));
      expect(
        find.descendant(of: nutrientCard, matching: find.text(label)),
        findsOneWidget,
      );
    }
    semantics.dispose();

    await tester.ensureVisible(find.text('Letzte 30 Tage'));
    await tester.tap(find.text('Letzte 30 Tage'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 abgeschlossener Tag'), findsOneWidget);
    final thirtyDayEnergyCard = find
        .ancestor(
          of: find.text('Energie pro Studientag'),
          matching: find.byType(Card),
        )
        .first;
    for (final index in [0, 5, 10, 15, 20, 25]) {
      final label = DateFormat(
        'd MMM',
        'de',
      ).format(addCalendarDays(today, index - 29));
      expect(
        find.descendant(of: thirtyDayEnergyCard, matching: find.text(label)),
        findsOneWidget,
      );
    }
    expect(
      find.descendant(of: thirtyDayEnergyCard, matching: find.text('Heute')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('chart data responds to taps', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = addCalendarDays(today, -1);
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = yesterday;
    final recall = _recall(
      date: yesterday,
      studyDay: 1,
      energyKcal: 500,
      completed: true,
    );
    subject.progress.add(_progress(recall));
    NutritionRecallRecord? openedRecord;

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('de'),
        home: NutritionStatisticsView(
          subject: subject,
          taskId: 'task',
          onOpenRecall: (record) async => openedRecord = record,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final energyCard = find.ancestor(
      of: find.text('Energie pro Studientag'),
      matching: find.byType(Card),
    );
    final energyBar = find.descendant(
      of: energyCard,
      matching: find.byType(BarChart),
    );
    final barRect = tester.getRect(energyBar);
    const historicalIndex = 5;
    final barPlotLeft = barRect.left + 50;
    await tester.tapAt(
      Offset(
        barPlotLeft +
            (barRect.right - barPlotLeft) * (historicalIndex + 0.5) / 7,
        barRect.bottom - 70,
      ),
    );
    await tester.pumpAndSettle();
    expect(openedRecord?.recall.id, recall.id);

    final lineChart = tester.widget<LineChart>(find.byType(LineChart));
    expect(lineChart.data.lineTouchData.touchSpotThreshold, 24);
    final lineRect = tester.getRect(find.byType(LineChart));
    final linePlotLeft = lineRect.left + 50;
    await tester.tapAt(
      Offset(
        linePlotLeft + (lineRect.right - linePlotLeft) * historicalIndex / 6,
        lineRect.center.dy,
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  test('excludes incomplete today from averages but keeps it in charts', () {
    final today = DateUtils.dateOnly(DateTime.now());
    final records = [
      _record(
        date: today.subtract(const Duration(days: 2)),
        studyDay: 1,
        energyKcal: 100,
      ),
      _record(
        date: today.subtract(const Duration(days: 1)),
        studyDay: 2,
        energyKcal: 200,
      ),
      _record(date: today, studyDay: 3, energyKcal: 250),
    ];
    final activeRecall = _recall(date: today, studyDay: 3, energyKcal: 300);

    final period = nutritionStatisticsPeriod(
      nutritionStatisticsDays(
        records,
        activeRecall: activeRecall,
        activeStudyDay: 3,
        activePeriodId: 'period',
      ),
      endDate: today,
      dayCount: 7,
    );

    expect(period.recordedCount, 2);
    expect(period.average((value) => value.energyKcal), 150);
    expect(period.days.last.isRecorded, isFalse);
    expect(period.days.last.hasChartData, isTrue);
    expect(period.hasTodaySoFar, isTrue);
    expect(period.days.first.hasChartData, isFalse);
  });

  testWidgets('separates nutrient lines at missing days', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final today = DateUtils.dateOnly(DateTime.now());
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = addCalendarDays(today, -6);
    for (final (offset, studyDay) in [(6, 1), (4, 3)]) {
      final recall = _recall(
        date: addCalendarDays(today, -offset),
        studyDay: studyDay,
        energyKcal: 100,
        completed: true,
      );
      subject.progress.add(_progress(recall));
    }

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('de'),
        home: NutritionStatisticsView(subject: subject, taskId: 'task'),
      ),
    );
    await tester.pumpAndSettle();

    final segments = tester
        .widget<LineChart>(find.byType(LineChart))
        .data
        .lineBarsData;
    expect(segments, hasLength(2));
    expect(segments.map((segment) => segment.spots.single.x), [0, 2]);
  });

  testWidgets('labels incomplete today as today so far', (tester) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = addCalendarDays(today, -1);
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = yesterday;
    final completedRecall = _recall(
      date: yesterday,
      studyDay: 1,
      energyKcal: 500,
      completed: true,
    );
    subject.progress.add(_progress(completedRecall));

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('de'),
        home: NutritionStatisticsView(
          subject: subject,
          taskId: 'task',
          activeRecall: _recall(date: today, studyDay: 2, energyKcal: 100),
          activeStudyDay: 2,
          activePeriodId: 'period',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('1 abgeschlossener Tag · Heute bisher'),
      findsOneWidget,
    );
    expect(
      find.text('Durchschnitt 500 kcal über abgeschlossene Tage'),
      findsOneWidget,
    );
    final energyCard = find.ancestor(
      of: find.text('Energie pro Studientag'),
      matching: find.byType(Card),
    );
    final todayRod = tester
        .widget<BarChart>(
          find.descendant(of: energyCard, matching: find.byType(BarChart)),
        )
        .data
        .barGroups
        .last
        .barRods
        .single;
    final theme = Theme.of(
      tester.element(find.byType(NutritionStatisticsView)),
    );
    expect(todayRod.color, theme.colorScheme.primary.withValues(alpha: 0.65));
    expect(todayRod.borderSide.width, 0);
  });

  testWidgets('average preserves unavailable nutrient placeholders', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final today = DateUtils.dateOnly(DateTime.now());
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = today.subtract(const Duration(days: 1));
    subject.progress.add(
      _progress(
        _recall(
          date: today,
          studyDay: 1,
          energyKcal: 500,
          completed: true,
          unavailableNutrients: {'energyKcal', 'protein'},
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: NutritionStatisticsView(subject: subject, taskId: 'task'),
      ),
    );
    await tester.pumpAndSettle();

    final overview = find.ancestor(
      of: find.text('Average across completed days'),
      matching: find.byType(Card),
    );
    expect(overview, findsOneWidget);
    expect(
      find.descendant(of: overview, matching: find.text('—')),
      findsNWidgets(2),
    );
    expect(
      find.descendant(
        of: overview,
        matching: find.text('Energy by macronutrient'),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides contradictory zero energy from trend output', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();
    final today = DateUtils.dateOnly(DateTime.now());
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = today.subtract(const Duration(days: 1));
    subject.progress.add(
      _progress(
        _recall(
          date: today.subtract(const Duration(days: 1)),
          studyDay: 1,
          energyKcal: 0,
          completed: true,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('de'),
        home: NutritionStatisticsView(subject: subject, taskId: 'task'),
      ),
    );
    await tester.pumpAndSettle();

    final energyCard = find.ancestor(
      of: find.text('Energie pro Studientag'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(
        of: energyCard,
        matching: find.text('Durchschnitt — über abgeschlossene Tage'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: energyCard, matching: find.text('0 kcal')),
      findsNothing,
    );
    expect(
      tester.widget<BarChart>(find.byType(BarChart)).data.barGroups[5].barRods,
      isEmpty,
    );
    expect(find.bySemanticsLabel(RegExp(r', —$')), findsOneWidget);
    semantics.dispose();
    expect(tester.takeException(), isNull);
  });

  test('shows recorded zeros but hides incomplete and missing days', () {
    final today = DateUtils.dateOnly(DateTime.now());
    final period = nutritionStatisticsPeriod(
      nutritionStatisticsDays([
        _record(
          date: addCalendarDays(today, -3),
          studyDay: 1,
          energyKcal: 0,
          carbs: 0,
        ),
        _record(
          date: addCalendarDays(today, -2),
          studyDay: 2,
          energyKcal: 0,
          carbs: 0,
          completed: false,
        ),
      ]),
      endDate: today,
      dayCount: 7,
    );

    final recordedZero = period.days[3];
    final incomplete = period.days[4];
    final missing = period.days[5];
    expect(recordedZero.isRecorded, isTrue);
    expect(recordedZero.hasChartData, isTrue);
    expect(period.average((nutrition) => nutrition.carbs), 0);
    expect(incomplete.isRecorded, isFalse);
    expect(incomplete.hasChartData, isFalse);
    expect(missing.data, isNull);
    expect(missing.hasChartData, isFalse);
  });

  test('adds calendar days without carrying an elapsed-time offset', () {
    final nextDay = addCalendarDays(DateTime(2026, 3, 29), 1);

    expect(nextDay, DateTime(2026, 3, 30));
    expect(nextDay.hour, 0);
  });

  test('compares equal-length periods using recorded days only', () {
    final today = DateUtils.dateOnly(DateTime.now());
    final statisticsDays = nutritionStatisticsDays([
      _record(
        date: today.subtract(const Duration(days: 1)),
        studyDay: 14,
        energyKcal: 200,
      ),
      _record(
        date: today.subtract(const Duration(days: 2)),
        studyDay: 13,
        energyKcal: 100,
      ),
      _record(
        date: today.subtract(const Duration(days: 8)),
        studyDay: 7,
        energyKcal: 50,
      ),
      _record(
        date: today.subtract(const Duration(days: 9)),
        studyDay: 6,
        energyKcal: 50,
      ),
    ]);
    final current = nutritionStatisticsPeriod(
      statisticsDays,
      endDate: today,
      dayCount: 7,
    );
    final previous = nutritionStatisticsPeriod(
      statisticsDays,
      endDate: today.subtract(const Duration(days: 7)),
      dayCount: 7,
    );

    expect(current.recordedCount, 2);
    expect(previous.recordedCount, 2);
    expect(
      current.average((value) => value.energyKcal)! -
          previous.average((value) => value.energyKcal)!,
      100,
    );
  });
}

NutritionRecallRecord _record({
  required DateTime date,
  required int studyDay,
  required double energyKcal,
  double carbs = 0.2,
  bool completed = true,
  Set<String> unavailableNutrients = const {},
}) {
  final recall = _recall(
    date: date,
    studyDay: studyDay,
    energyKcal: energyKcal,
    carbs: carbs,
    completed: completed,
    unavailableNutrients: unavailableNutrients,
  );
  return NutritionRecallRecord(
    recall: recall,
    taskId: 'task',
    periodId: 'period',
    interventionId: 'intervention',
    studyDaySnapshot: studyDay,
    progress: _progress(recall),
  );
}

SubjectProgress _progress(DailyRecall recall) => SubjectProgress(
  subjectId: 'subject',
  interventionId: 'intervention',
  taskId: 'task',
  resultType: 'DailyRecall',
  result: Result<DailyRecall>.app(
    type: 'DailyRecall',
    periodId: 'period',
    result: recall,
  ),
)..completedAt = recall.date.add(const Duration(hours: 12));

DailyRecall _recall({
  required DateTime date,
  required int studyDay,
  required double energyKcal,
  double carbs = 0.2,
  bool completed = false,
  Set<String> unavailableNutrients = const {},
}) => DailyRecall(
  id: 'recall-$studyDay-$energyKcal',
  date: date,
  recallMode: RecallMode.realtimeRecord,
  entryCompletedAt: completed ? date.add(const Duration(hours: 12)) : null,
  meals: [
    _meal(
      energyKcal: energyKcal,
      carbs: carbs,
      unavailableNutrients: unavailableNutrients,
    ),
  ],
  studyDaySnapshot: studyDay,
);

MealLog _meal({
  required double energyKcal,
  required double carbs,
  Set<String> unavailableNutrients = const {},
}) => MealLog(
  id: 'meal-$energyKcal',
  mealType: MealType.breakfast,
  mealContext: MealContext.home,
  timezone: 'UTC',
  isSkipped: false,
  foods: [
    _food(
      energyKcal: energyKcal,
      carbs: carbs,
      unavailableNutrients: unavailableNutrients,
    ),
  ],
);

FoodEntry _food({
  required double energyKcal,
  required double carbs,
  Set<String> unavailableNutrients = const {},
}) => FoodEntry(
  id: 'food-$energyKcal',
  foodId: 'food-definition-$energyKcal',
  foodVersionId: 'food-version-$energyKcal',
  entryType: FoodEntryType.singleIngredient,
  name: 'Food',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: energyKcal,
    protein: 1.5,
    carbs: carbs,
    fat: 3.5,
    sugars: 0,
    fiber: 4.5,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: {},
    unavailableNutrients: unavailableNutrients,
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.now(),
  originalValues: {},
);
