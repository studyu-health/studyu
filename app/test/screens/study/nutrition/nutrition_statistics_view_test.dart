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
  test('daily and period aggregation preserve partial and unknown zero', () {
    final today = DateTime(2026, 1, 3);
    final known = _record(date: today, studyDay: 3, energyKcal: 0);
    final missing = _record(
      date: addCalendarDays(today, -1),
      studyDay: 2,
      energyKcal: 999,
      unavailableNutrients: {'energyKcal', 'protein'},
    );
    final days = nutritionStatisticsDays([known, missing]);
    expect(days.first.nutrition.isKnown('energyKcal'), isFalse);
    final period = nutritionStatisticsPeriod(days, endDate: today, dayCount: 3);
    expect(period.averageFor('energyKcal'), 0);
    expect(period.averageNutrition.isKnown('energyKcal'), isTrue);
    expect(period.partialNutrients, contains('energyKcal'));
    expect(period.unavailableNutrients, isNot(contains('energyKcal')));
    final unknown = nutritionStatisticsPeriod(
      [days.first],
      endDate: today,
      dayCount: 3,
    );
    expect(unknown.averageFor('energyKcal'), isNull);
    expect(unknown.averageFor('protein'), isNull);
    expect(unknown.averageFor('carbs'), isNotNull);
    expect(missing.recall.meals.single.foods.single.nutrition.energyKcal, 999);
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'opens today and updates the calorie change with the live diary',
    (tester) async {
      final today = DateUtils.dateOnly(DateTime.now());
      final yesterday = addCalendarDays(today, -1);
      final subject = _statisticsSubject(yesterday, [
        _record(date: yesterday, studyDay: 1, energyKcal: 500),
        _record(date: today, studyDay: 2, energyKcal: 900),
      ]);

      for (final (energy, expectedChange) in [
        (620.0, '+120'),
        (100.0, '−400'),
        (500.4, '0'),
      ]) {
        await tester.pumpWidget(
          _statisticsApp(
            subject,
            activeRecall: _recall(date: today, studyDay: 2, energyKcal: energy),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Today so far'), findsOneWidget);
        expect(find.text('Daily summary'), findsOneWidget);
        expect(find.text('${energy.round()} kcal'), findsOneWidget);
        expect(
          find.text('$expectedChange kcal vs. previous day'),
          findsOneWidget,
        );
        expect(find.text('Average across completed days'), findsNothing);
        expect(find.byTooltip('Next period'), findsNothing);
      }
    },
  );

  testWidgets('navigates past a gap and resets to today at large text sizes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = addCalendarDays(today, -1);
    final oldest = addCalendarDays(today, -3);

    await tester.pumpWidget(
      _statisticsApp(
        _statisticsSubject(oldest, [
          _record(date: oldest, studyDay: 1, energyKcal: 400),
          _record(date: yesterday, studyDay: 3, energyKcal: 500),
        ]),
        activeRecall: _recall(date: today, studyDay: 4, energyKcal: 800),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('+300 kcal vs. previous day'), findsOneWidget);

    await _tapPeriodControl(tester, 'Previous period');
    expect(find.text('500 kcal'), findsOneWidget);
    expect(find.textContaining('vs. previous day'), findsNothing);

    await _tapPeriodControl(tester, 'Previous period');
    expect(find.text('No nutrition entries for this day.'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byTooltip('Next period'))
          .getSemanticsData()
          .tooltip,
      'Next period',
    );

    await _tapPeriodControl(tester, 'Previous period');
    expect(find.text(DateFormat.yMMMd('en').format(oldest)), findsOneWidget);
    expect(find.text('400 kcal'), findsOneWidget);
    expect(find.byTooltip('Previous period'), findsNothing);

    await _tapPeriodControl(tester, 'Next period');
    expect(find.text('No nutrition entries for this day.'), findsOneWidget);
    await _tapPeriodControl(tester, 'Jump to today');
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('800 kcal'), findsOneWidget);
    expect(find.byTooltip('Next period'), findsNothing);
    expect(find.byTooltip('Jump to today'), findsNothing);
    semantics.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'hides changes when calories or diary completion are incomplete',
    (tester) async {
      final today = DateUtils.dateOnly(DateTime.now());
      final yesterday = addCalendarDays(today, -1);
      final earlier = addCalendarDays(today, -2);
      for (final (completed, unavailable, partial) in [
        (false, <String>{}, <String>{}),
        (true, {'energyKcal'}, <String>{}),
        (true, <String>{}, {'energyKcal'}),
      ]) {
        final subject = _statisticsSubject(earlier, [
          _record(date: earlier, studyDay: 1, energyKcal: 400),
          _record(
            date: yesterday,
            studyDay: 2,
            energyKcal: 500,
            completed: completed,
            unavailableNutrients: unavailable,
            partialNutrients: partial,
          ),
        ]);
        await tester.pumpWidget(
          _statisticsApp(
            subject,
            activeRecall: _recall(date: today, studyDay: 3, energyKcal: 600),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('600 kcal'), findsOneWidget);
        expect(find.textContaining('vs. previous day'), findsNothing);
        await _tapPeriodControl(tester, 'Previous period');
        expect(find.text('Daily summary'), findsOneWidget);
        expect(find.textContaining('vs. previous day'), findsNothing);
        await _tapPeriodControl(tester, 'Jump to today');
      }
    },
  );

  testWidgets('moves aggregate charts and comparisons by the selected range', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final today = DateUtils.dateOnly(DateTime.now());
    final subject = _statisticsSubject(addCalendarDays(today, -40), [
      for (final (offset, energy) in [
        (1, 400.0),
        (2, 400.0),
        (8, 200.0),
        (9, 200.0),
        (15, 100.0),
        (16, 100.0),
        (38, 50.0),
        (39, 50.0),
      ])
        _record(
          date: addCalendarDays(today, -offset),
          studyDay: 40 - offset,
          energyKcal: energy,
        ),
    ]);

    await tester.pumpWidget(_statisticsApp(subject));
    await tester.pumpAndSettle();
    final energyChart = find.descendant(
      of: find.ancestor(
        of: find.text('Energy by study day'),
        matching: find.byType(Card),
      ),
      matching: find.byType(BarChart),
    );
    await _selectPeriod(tester, 'Week');
    expect(find.text('+200 kcal/day'), findsOneWidget);
    expect(find.text('Compared with the previous 7 days'), findsWidgets);
    expect(find.byTooltip('Next period'), findsNothing);

    await _tapPeriodControl(tester, 'Previous period');
    expect(find.text('+100 kcal/day'), findsOneWidget);
    final oldWeekChart = tester.widget<BarChart>(energyChart);
    expect(oldWeekChart.data.barGroups, hasLength(7));
    expect(oldWeekChart.data.barGroups[5].barRods.single.toY, 200);

    await _selectPeriod(tester, 'Month');
    expect(find.byTooltip('Next period'), findsNothing);
    expect(find.text('+183 kcal/day'), findsOneWidget);
    expect(find.text('Compared with the previous 30 days'), findsWidgets);
    await _tapPeriodControl(tester, 'Previous period');
    final oldMonthChart = tester.widget<BarChart>(energyChart);
    expect(oldMonthChart.data.barGroups, hasLength(30));
    expect(oldMonthChart.data.barGroups[21].barRods.single.toY, 50);
    expect(find.byTooltip('Previous period'), findsNothing);

    await _tapPeriodControl(tester, 'Jump to today');
    expect(find.text('+183 kcal/day'), findsOneWidget);
  });

  test(
    'uses calendar dates when records and study days have different boundaries',
    () {
      final today = DateTime(2026, 1, 3);
      final yesterday = addCalendarDays(today, -1);
      final days = nutritionStatisticsDays([
        _record(date: today, studyDay: 3, energyKcal: 150),
        _record(date: today, studyDay: 2, energyKcal: 100),
        _record(date: yesterday, studyDay: 2, energyKcal: 200),
      ]);

      expect(days.map((day) => day.date), [yesterday, today]);
      expect(days.map((day) => day.nutrition.energyKcal), [200, 250]);
    },
  );

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
    await _selectPeriod(tester, 'Woche');

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

    await _selectPeriod(tester, 'Monat');

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
    await _selectPeriod(tester, 'Woche');

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
    expect(period.averageFor('energyKcal'), 150);
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
    await _selectPeriod(tester, 'Woche');

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
    await _selectPeriod(tester, 'Woche');

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
    await _selectPeriod(tester, 'Week');

    final overview = find.ancestor(
      of: find.text('Macronutrients'),
      matching: find.byType(Card),
    );
    expect(overview, findsOneWidget);
    expect(find.text('Average across completed days'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
    expect(
      find.descendant(of: overview, matching: find.text('—')),
      findsOneWidget,
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

  testWidgets('retains measured zero energy in trend output', (tester) async {
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
    await _selectPeriod(tester, 'Woche');

    final energyCard = find.ancestor(
      of: find.text('Energie pro Studientag'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(
        of: energyCard,
        matching: find.text('Durchschnitt 0 kcal über abgeschlossene Tage'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: energyCard, matching: find.text('0 kcal')),
      findsNothing,
    );
    expect(
      tester
          .widget<BarChart>(
            find.descendant(of: energyCard, matching: find.byType(BarChart)),
          )
          .data
          .barGroups[5]
          .barRods,
      hasLength(1),
    );
    expect(
      find.descendant(
        of: energyCard,
        matching: find.bySemanticsLabel(RegExp(r', 0 kcal$')),
      ),
      findsOneWidget,
    );
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
    expect(period.averageFor('carbs'), 0);
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
      current.averageFor('energyKcal')! - previous.averageFor('energyKcal')!,
      100,
    );
  });
}

Widget _statisticsApp(
  StudySubject subject, {
  DailyRecall? activeRecall,
  TextScaler textScaler = TextScaler.noScaling,
}) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  locale: const Locale('en'),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: textScaler),
    child: child!,
  ),
  home: NutritionStatisticsView(
    subject: subject,
    taskId: 'task',
    activeRecall: activeRecall,
    activePeriodId: 'period',
  ),
);

StudySubject _statisticsSubject(
  DateTime startedAt,
  List<NutritionRecallRecord> records,
) => StudySubject('subject', 'study', 'user', [])
  ..startedAt = startedAt
  ..progress.addAll(records.map((record) => record.progress!));

Future<void> _selectPeriod(WidgetTester tester, String label) async {
  final control = find.text(label);
  await tester.ensureVisible(control);
  await tester.tap(control);
  await tester.pumpAndSettle();
}

Future<void> _tapPeriodControl(WidgetTester tester, String tooltip) async {
  await tester.tap(find.byTooltip(tooltip));
  await tester.pumpAndSettle();
}

NutritionRecallRecord _record({
  required DateTime date,
  required int studyDay,
  required double energyKcal,
  double carbs = 0.2,
  bool completed = true,
  Set<String> unavailableNutrients = const {},
  Set<String> partialNutrients = const {},
}) {
  final recall = _recall(
    date: date,
    studyDay: studyDay,
    energyKcal: energyKcal,
    carbs: carbs,
    completed: completed,
    unavailableNutrients: unavailableNutrients,
    partialNutrients: partialNutrients,
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
  Set<String> partialNutrients = const {},
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
      partialNutrients: partialNutrients,
    ),
  ],
  studyDaySnapshot: studyDay,
);

MealLog _meal({
  required double energyKcal,
  required double carbs,
  Set<String> unavailableNutrients = const {},
  Set<String> partialNutrients = const {},
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
      partialNutrients: partialNutrients,
    ),
  ],
);

FoodEntry _food({
  required double energyKcal,
  required double carbs,
  Set<String> unavailableNutrients = const {},
  Set<String> partialNutrients = const {},
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
    partialNutrients: partialNutrients,
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.now(),
  originalValues: {},
);
