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
                  studyDaySnapshot: index,
                  meals: [
                    MealLog(
                      id: 'meal',
                      mealType: MealType.lunch,
                      mealContext: MealContext.home,
                      timestamp: DateTime(2026),
                      timePrecision: MealOccurrenceTimePrecision.approximate,
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
      final knownZero = byDate[DateTime(2026, 1, 1, 18).toString()]!;
      expect(knownZero['total_calories'], 0);
      expect(knownZero['total_calories_status'], 'complete');
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

  test('exports the recorded study day and skips recalls without one', () {
    final study = Study('study', 'owner')..participants = [];
    final startedAt = DateTime.utc(2026, 1, 1, 23);
    final completedAt = DateTime.utc(2026, 1, 2, 8);
    study.participantsProgress = [
      _recallProgress(startedAt, completedAt),
      _recallProgress(
        startedAt,
        completedAt.add(const Duration(hours: 1)),
        studyDay: null,
      ),
    ];

    final rows = study.exportData.measurementsData;
    expect(rows.single['current_day_of_study'], '0');
  });

  test('exports nutrition periods with their recorded completion time', () {
    final study = Study('study', 'owner');
    final startedAt = DateTime.utc(2026);
    final completedAt = DateTime.utc(
      2026,
      1,
      2,
    ).subtract(const Duration(microseconds: 1));
    study.participantsProgress = [
      _recallProgress(startedAt, completedAt, periodId: 'morning'),
      _recallProgress(startedAt, completedAt, periodId: 'evening')
        ..completedAt = completedAt.add(const Duration(microseconds: 1)),
    ];

    final rows = study.exportData.measurementsData;
    expect(
      rows.map((row) => row['measurement_period_id']),
      unorderedEquals(['morning', 'evening']),
    );
    for (final row in rows) {
      expect(row['measurement_time'], completedAt.toString());
      expect(row['current_day_of_study'], '0');
    }
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

  test('excludes unfinished nutrition recalls from measurement exports', () {
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
      _recallProgress(
        null,
        completedAt.add(const Duration(hours: 1)),
        studyDay: 2,
      ),
    ];

    final rows = study.exportData.measurementsData;
    expect(rows.map((row) => row['participant_started_at']), ['', '']);
    expect(rows.map((row) => row['current_day_of_study']), ['2', '1']);
  });

  test('exports shared preset question IDs in their own survey columns', () {
    final study = Study('study', 'owner');
    final startedAt = DateTime.utc(2026);
    final surveys = [
      FFQQuestions.createFFQTask()..title = 'Baseline FFQ',
      FFQQuestions.createFFQTask()..title = 'Follow-up FFQ',
    ];
    study.observations = surveys;
    study.participantsProgress = [
      for (final (index, survey) in surveys.indexed)
        SubjectProgress(
            subjectId: 'subject',
            interventionId: Study.baselineID,
            taskId: survey.id,
            resultType: 'QuestionnaireState',
            result: Result<QuestionnaireState>.app(
              type: 'QuestionnaireState',
              periodId: 'period',
              result: QuestionnaireState()
                ..answers[survey.questions.questions.first.id] =
                    Answer<List<String>>.forQuestion(
                      survey.questions.questions.first,
                      ['less_than_once_per_month'],
                    ),
            ),
          )
          ..startedAt = startedAt
          ..completedAt = startedAt.add(Duration(days: index)),
    ];
    final byTask = {
      for (final row in study.exportData.measurementsData)
        row['measurement_id']: row,
    };

    for (final (index, survey) in surveys.indexed) {
      final row = byTask[survey.id]!;
      expect(row['survey${index + 1}_question1_response'], [
        {'id': 'less_than_once_per_month', 'text': 'Less than once per month'},
      ]);
      expect(row['survey${2 - index}_question1_response'], '');
    }
  });
}

SubjectProgress _recallProgress(
  DateTime? startedAt,
  DateTime completedAt, {
  int? studyDay = 0,
  String periodId = 'period',
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
          periodId: periodId,
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
