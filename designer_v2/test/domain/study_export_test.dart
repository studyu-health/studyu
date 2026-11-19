import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';

void main() {
  test(
    'nutrition export retains zero and discloses per-nutrient availability',
    () {
      final study = Study('study', 'owner')..participants = [];
      final zero = _food(0);
      final missing = _food(999)
        ..nutrition.unavailableNutrients = {'energyKcal'};
      final partial = _food(10)
        ..amount = 2
        ..nutrition.partialNutrients = {'energyKcal'};
      study.participantsProgress = [
        for (final (index, foods) in <List<FoodEntry>>[
          [zero],
          [missing],
          [partial],
          [zero, missing],
        ].indexed)
          SubjectProgress(
              subjectId: 'subject',
              interventionId: Study.baselineID,
              taskId: 'task',
              resultType: 'DailyRecall',
              result: Result<DailyRecall>.app(
                type: 'DailyRecall',
                periodId: 'period',
                result: DailyRecall(
                  id: 'recall-$index',
                  date: DateTime(2026, 1, index + 1),
                  recallMode: RecallMode.realtimeRecord,
                  entryCompletedAt: DateTime(2026, 1, index + 1, 18),
                  meals: [
                    MealLog(
                      id: 'meal',
                      mealType: MealType.lunch,
                      mealContext: MealContext.home,
                      timestamp: DateTime(2026),
                      timezone: 'UTC',
                      isSkipped: false,
                      foods: foods,
                    ),
                  ],
                ),
              ),
            )
            ..startedAt = DateTime(2026)
            ..completedAt = DateTime(2026, 1, index + 1, 18),
      ];
      final rows = study.exportData.measurementsData;
      final byDate = {for (final row in rows) row['measurement_time']: row};
      final legacy = byDate[DateTime(2026, 1, 1, 18).toString()]!;
      expect(legacy['total_calories'], 0);
      expect(legacy['total_calories_status'], 'complete');
      final unknown = byDate[DateTime(2026, 1, 2, 18).toString()]!;
      expect(unknown['total_calories'], '');
      expect(unknown['total_calories_status'], 'unknown');
      final subtotal = byDate[DateTime(2026, 1, 3, 18).toString()]!;
      expect(subtotal['total_calories'], 10);
      expect(subtotal['total_calories_status'], 'partial');
      final partialZero = byDate[DateTime(2026, 1, 4, 18).toString()]!;
      expect(partialZero['total_calories'], 0);
      expect(partialZero['total_calories_status'], 'partial');
      for (final row in rows) {
        expect(row['total_protein_status'], 'complete');
        expect(row['total_carbs_status'], 'complete');
        expect(row['total_fat_status'], 'complete');
        expect(row['meal_count'], 1);
      }
      expect(unknown['total_protein'], 999);
      expect(partialZero['total_protein'], 999);
    },
  );

  test('exports the saved study day and uses UTC dates for legacy recalls', () {
    final study = Study('study', 'owner')..participants = [];
    final startedAt = DateTime.utc(2026, 1, 1, 23);
    final completedAt = DateTime.utc(2026, 1, 2, 8);
    study.participantsProgress = [
      _recallProgress(startedAt, completedAt, studyDay: 0),
      _recallProgress(startedAt, completedAt.add(const Duration(hours: 1))),
    ];

    final rows = study.exportData.measurementsData;
    expect(rows.map((row) => row['current_day_of_study']), ['1', '0']);
  });

  test('exports zero water and keeps unanswered water empty', () {
    final study = Study('study', 'owner')..participants = [];
    final startedAt = DateTime.utc(2026);
    final completedAt = DateTime.utc(2026, 1, 2);
    study.participantsProgress = [
      _recallProgress(startedAt, completedAt),
      _recallProgress(
        startedAt,
        completedAt.add(const Duration(days: 1)),
        waterIntakeMl: 0,
      ),
    ];

    final rows = study.exportData.measurementsData;
    expect(rows.first['water_intake_ml'], 0);
    expect(rows.last, containsPair('water_intake_ml', null));
  });

  test('excludes legacy nutrition drafts from measurement exports', () {
    final study = Study('study', 'owner')..participants = [];
    final startedAt = DateTime.utc(2026);
    final completedAt = DateTime.utc(2026, 1, 2);
    study.participantsProgress = [
      _recallProgress(startedAt, completedAt),
      _recallProgress(
        startedAt,
        completedAt.add(const Duration(hours: 1)),
        isComplete: false,
      ),
    ];

    final row = study.exportData.measurementsData.single;
    expect(row['entry_completed_at'], completedAt.toString());
  });

  test('exports nutrition alongside a removed questionnaire', () {
    final study = Study('study', 'owner')..participants = [];
    final startedAt = DateTime.utc(2026);
    final completedAt = DateTime.utc(2026, 1, 2);
    final survey = QuestionnaireState()
      ..answers['removed-question'] = (Answer<String>(
        'removed-question',
        completedAt,
      )..response = 'Previously answered');
    final removedQuestionnaire =
        SubjectProgress(
            subjectId: 'subject',
            interventionId: Study.baselineID,
            taskId: 'removed-questionnaire',
            resultType: 'QuestionnaireState',
            result: Result<QuestionnaireState>.app(
              type: 'QuestionnaireState',
              periodId: 'period',
              result: survey,
            ),
          )
          ..startedAt = startedAt
          ..completedAt = completedAt.add(const Duration(hours: 1));
    study.participantsProgress = [
      _recallProgress(startedAt, completedAt, waterIntakeMl: 250),
      removedQuestionnaire,
    ];

    final rows = study.exportData.measurementsData;
    expect(rows.map((row) => row['measurement_id']), [
      'removed-questionnaire',
      'nutrition',
    ]);
    expect(rows.last['water_intake_ml'], 250);
  });

  test('exports recalls with a missing participant start date', () {
    final study = Study('study', 'owner')..participants = [];
    final completedAt = DateTime.utc(2026, 1, 2);
    study.participantsProgress = [
      _recallProgress(null, completedAt, studyDay: 1),
      _recallProgress(null, completedAt.add(const Duration(hours: 1))),
    ];

    final rows = study.exportData.measurementsData;
    expect(rows.map((row) => row['participant_started_at']), ['', '']);
    expect(rows.map((row) => row['current_day_of_study']), ['', '1']);
  });
}

SubjectProgress _recallProgress(
  DateTime? startedAt,
  DateTime completedAt, {
  int? studyDay,
  int? waterIntakeMl,
  bool isComplete = true,
}) =>
    SubjectProgress(
        subjectId: 'subject',
        interventionId: Study.baselineID,
        taskId: 'nutrition',
        resultType: 'DailyRecall',
        result: Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: 'period',
          result: DailyRecall.withId(
            date: completedAt,
            recallMode: RecallMode.realtimeRecord,
            entryCompletedAt: isComplete ? completedAt : null,
            waterIntakeMl: waterIntakeMl,
            studyDaySnapshot: studyDay,
            meals: [],
          ),
        ),
      )
      ..startedAt = startedAt
      ..completedAt = completedAt;

FoodEntry _food(double energy) => FoodEntry.withId(
  entryType: FoodEntryType.manualCustom,
  name: 'Food',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  source: FoodSource.manual,
  confidenceScore: 1,
  originalValues: {},
  nutrition: NutritionProfile(
    energyKcal: energy,
    protein: energy,
    carbs: 0,
    fat: 0,
    sugars: 0,
    fiber: 0,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: {},
  ),
);
