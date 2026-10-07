import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late StudySubject subject;
  late DailyRecall canonical;
  late Map<String, dynamic> stored;
  late MockClientHandler handler;
  final progressRequests = <Map<String, dynamic>>[];
  final definitionRequests = <Map<String, dynamic>>[];
  var metadataBearing = true;
  var definitionsExist = true;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-key',
      debug: false,
      httpClient: MockClient((request) => handler(request)),
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        detectSessionInUri: false,
      ),
    );
    setEnv(
      'https://example.supabase.co',
      'test-key',
      supabaseClient: Supabase.instance.client,
    );
  });

  tearDownAll(() => Supabase.instance.dispose());

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    subject = _subject();
    canonical = _recall(studyDay: 1);
    stored = _serverResult(canonical);
    progressRequests.clear();
    definitionRequests.clear();
    metadataBearing = true;
    definitionsExist = true;
    handler = (request) async {
      if (request.method == 'GET') {
        if (request.url.path.endsWith('/study_subject')) {
          return _response(_subjectRow(subject, canonical), request);
        }
        if (request.url.path.endsWith('/nutrition_food_version')) {
          final ids = request.url.queryParameters['id'] ?? '';
          return _response([
            for (final food in _foods(canonical))
              if (ids.contains(food.foodVersionId))
                {'id': food.foodVersionId, 'food_id': food.foodId},
          ], request);
        }
        return _response(
          definitionsExist
              ? [
                  for (final food in _foods(canonical))
                    {
                      'id': food.foodId,
                      'current_version_id': food.foodVersionId,
                    },
                ]
              : [],
          request,
        );
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (request.url.path.endsWith('/subject_progress')) {
        progressRequests.add(body);
        final result = body['result'] as Map<String, dynamic>;
        if (metadataBearing && !_hasIntent(result)) return _rejection(request);
        stored = Map<String, dynamic>.from(result)
          ..remove(NutritionProfile.availabilityWriteIntentKey);
        return _response([
          {...body, 'result': stored},
        ], request);
      }
      if (request.url.path.contains('/rpc/')) {
        definitionRequests.add(body);
        final snapshot = body['p_snapshot'] as Map<String, dynamic>;
        if (metadataBearing && !_hasIntent(snapshot)) {
          return _rejection(request);
        }
        return _response({
          'definition': {
            'id': snapshot['foodId'],
            'subjectId': subject.id,
            'kind': 'food',
            'currentVersionId': snapshot['foodVersionId'],
            'snapshot': {...snapshot}
              ..remove(NutritionProfile.availabilityWriteIntentKey),
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          'progress': [],
          'selectedHistoricalUpdateCount': 0,
          'todayUpdateCount': 0,
        }, request);
      }
      return _response([subject.toJson()], request);
    };
  });

  for (final hasCompletedProgress in [false, true]) {
    test('legacy replay retains unsupported draft '
        '(completed progress: $hasCompletedProgress)', () async {
      if (hasCompletedProgress) {
        canonical.entryCompletedAt = canonical.date;
        stored = _serverResult(canonical);
        subject.progress.add(
          SupabaseQuery.extractSupabaseSingleRow<SubjectProgress>(
            _progressRow(canonical),
          ),
        );
      }
      final originalServer = jsonEncode(stored);
      final legacy = _legacyJson(canonical)..remove('entryCompletedAt');
      final parent = ((legacy['meals'] as List).single as Map)['foods'] as List;
      (parent.single as Map)['foodVersionId'] = 'missing-version';
      await _seedCache(legacy, studyDay: 1);
      final manager = NutritionRecallAutoSaveManager();
      final loaded = (await manager.scanPendingRecalls(subject.id))
          .single
          .recall;
      expect(loaded.canWriteAvailability, isFalse);
      await _save(manager, loaded);

      await manager.submitPendingRecalls(subject: subject, trackProgress: true);

      if (hasCompletedProgress) {
        expect(progressRequests, isEmpty);
        expect(definitionRequests, isEmpty);
        expect(jsonEncode(stored), originalServer);
        final pending = (await manager.scanPendingRecalls(subject.id)).single;
        expect(pending.recall.entryCompletedAt, isNull);
        expect(pending.recall.canWriteAvailability, isFalse);
        expect(
          pending.recall.meals.single.foods.single.foodVersionId,
          'missing-version',
        );
        await manager.submitPendingRecalls(
          subject: subject,
          trackProgress: true,
        );
        expect(progressRequests, isEmpty);
        expect(await manager.scanPendingRecalls(subject.id), hasLength(1));
        expect(jsonEncode(stored), originalServer);
        return;
      }

      expect(progressRequests, hasLength(1));
      _expectUnverifiedTransport(
        progressRequests.single['result'] as Map<String, dynamic>,
      );
      expect(definitionRequests, isEmpty);
      expect(jsonEncode(stored), originalServer);
      final pending = (await manager.scanPendingRecalls(subject.id)).single;
      expect(pending.recall.entryCompletedAt, isNotNull);
      expect(pending.recall.canWriteAvailability, isFalse);
      expect(
        pending.recall.meals.single.foods.single.foodVersionId,
        canonical.meals.single.foods.single.foodVersionId,
      );
      expect(
        _foods(pending.recall).every((food) => !food.availabilityVerified),
        isTrue,
      );
      await manager.submitPendingRecalls(subject: subject, trackProgress: true);
      expect(progressRequests, hasLength(2));
      expect(await manager.scanPendingRecalls(subject.id), hasLength(1));
      expect(jsonEncode(stored), originalServer);
    });
  }

  test(
    'restoration and unrelated edits cannot verify an older cache',
    () async {
      canonical = _recall(studyDay: 2);
      stored = _serverResult(canonical);
      final originalServer = jsonEncode(stored);
      final fetched = await SupabaseQuery.getById<StudySubject>(
        subject.id,
        selectedColumns: [
          '*',
          'study!study_subject_studyId_fkey(*)',
          'subject_progress(*)',
        ],
      );
      expect(
        (fetched.progress.single.result.result as DailyRecall)
            .canWriteAvailability,
        isTrue,
      );
      await _seedCache(
        _legacyJson(canonical)..['studyDaySnapshot'] = 99,
        studyDay: 2,
      );
      final manager = NutritionRecallAutoSaveManager();
      final viewModel = DailyRecallEntryViewModel(
        subject: fetched,
        task: NutritionTask()..id = 'task',
        completionPeriod: CompletionPeriod(
          id: 'period',
          unlockTime: StudyUTimeOfDay(),
          lockTime: StudyUTimeOfDay(hour: 23),
        ),
        autoSaveManager: manager,
      );
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.recall.canWriteAvailability, isFalse);
      expect(viewModel.recall.studyDaySnapshot, 2);
      viewModel.updateUsualIntake(true);
      viewModel.markCompleted();
      await expectLater(
        viewModel.flushPendingAutoSave(
          persistToDatabase: true,
          requireRemoteSuccess: true,
        ),
        throwsA(isA<PostgrestException>()),
      );
      expect(progressRequests, hasLength(1));
      _expectUnverifiedTransport(
        progressRequests.single['result'] as Map<String, dynamic>,
      );
      expect(jsonEncode(stored), originalServer);
      expect(
        (await manager.scanPendingRecalls(subject.id))
            .single
            .recall
            .canWriteAvailability,
        isFalse,
      );
      viewModel.dispose();
    },
  );

  test(
    'canonical snapshot rewrites do not verify an unsupported cached draft',
    () async {
      await _seedCache(_legacyJson(canonical), studyDay: 1);
      final manager = NutritionRecallAutoSaveManager();
      await manager.rewriteFoodDefinition(
        subjectId: subject.id,
        studyDaySnapshot: 1,
        definition: canonical.meals.single.foods.single,
      );
      final pending = (await manager.scanPendingRecalls(subject.id)).single;
      expect(pending.recall.canWriteAvailability, isFalse);
      expect(
        _foods(pending.recall).every((food) => !food.availabilityVerified),
        isTrue,
      );
      expect(
        pending.recall.meals.single.foods.single.nutrition.unavailableNutrients,
        {'protein'},
      );
      await manager.submitPendingRecalls(subject: subject, trackProgress: true);
      final result = progressRequests.single['result'] as Map<String, dynamic>;
      expect(_hasIntent(result), isFalse);
      expect(jsonEncode(result), isNot(contains('availabilityVerified')));
      expect(await manager.scanPendingRecalls(subject.id), hasLength(1));
    },
  );

  test(
    'targeted upsert preserves false when copying the study-day snapshot',
    () async {
      final unverified = DailyRecall.fromJson(_legacyJson(canonical))
        ..studyDaySnapshot = 99
        ..entryCompletedAt = canonical.date;
      await expectLater(
        subject.upsertNutritionResult(
          taskId: 'task',
          periodId: 'period',
          recall: unverified,
          persistenceTarget: NutritionRecallPersistenceTarget(
            taskId: 'task',
            periodId: 'period',
            interventionId: 'intervention',
            completedAt: canonical.date.toUtc(),
            studyDaySnapshot: 1,
          ),
        ),
        throwsA(isA<PostgrestException>()),
      );
      final result = progressRequests.single['result'] as Map<String, dynamic>;
      _expectUnverifiedTransport(result);
      expect((result['result'] as Map)['studyDaySnapshot'], 1);
    },
  );

  test(
    'metadata-free legacy drafts retain known zero and remain writable',
    () async {
      metadataBearing = false;
      final legacy = _legacyJson(canonical);
      stored = {'type': 'DailyRecall', 'periodId': 'period', 'result': legacy};
      await _seedCache(legacy, studyDay: 1);
      final manager = NutritionRecallAutoSaveManager();
      await manager.submitPendingRecalls(subject: subject, trackProgress: true);
      expect(progressRequests, hasLength(1));
      _expectUnverifiedTransport(
        progressRequests.single['result'] as Map<String, dynamic>,
      );
      final saved = DailyRecall.fromJson(
        stored['result'] as Map<String, dynamic>,
      );
      expect(saved.meals.single.foods.single.nutrition.protein, 0);
      expect(
        saved.meals.single.foods.single.nutrition.isKnown('protein'),
        isTrue,
      );
      expect(await manager.scanPendingRecalls(subject.id), isEmpty);
    },
  );

  test('metadata-free completed progress retains a different ambiguous legacy draft', () async {
    metadataBearing = false;
    canonical = DailyRecall.fromJson(_legacyJson(canonical))
      ..entryCompletedAt = canonical.date;
    stored = _serverResult(canonical);
    subject.progress.add(
      SupabaseQuery.extractSupabaseSingleRow<SubjectProgress>(
        _progressRow(canonical),
      ),
    );
    final originalServer = jsonEncode(stored);
    final originalProgress = jsonEncode(subject.progress.single.toJson());
    final legacy = _legacyJson(canonical)
      ..remove('entryCompletedAt')
      ..['id'] = 'different-older-draft';
    final foods = ((legacy['meals'] as List).single as Map)['foods'] as List;
    (foods.single as Map)['name'] = 'Stale draft content';
    ((foods.single as Map)['nutrition'] as Map)['energyKcal'] = 123;
    await _seedCache(legacy, studyDay: 1);
    final preferences = await SharedPreferences.getInstance();
    const key = 'studyu_nutrition_autosave_subject_task_period_1';
    final originalCache = preferences.getString(key);
    final manager = NutritionRecallAutoSaveManager();

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);
    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(progressRequests, isEmpty);
    expect(definitionRequests, isEmpty);
    expect(jsonEncode(stored), originalServer);
    expect(jsonEncode(subject.progress.single.toJson()), originalProgress);
    expect(preferences.getString(key), originalCache);
    final pending = (await manager.scanPendingRecalls(subject.id)).single;
    expect(pending.recall.id, 'different-older-draft');
    expect(pending.recall.entryCompletedAt, isNull);
    expect(pending.progressCompletedAt, isNull);
    expect(pending.recall.canWriteAvailability, isFalse);
    expect(
      pending.recall.meals.single.foods.single.name,
      'Stale draft content',
    );
    expect(pending.recall.meals.single.foods.single.nutrition.energyKcal, 123);
  });

  test(
    'verified cache replay allows explicit clearing to known zero',
    () async {
      final manager = NutritionRecallAutoSaveManager();
      await _save(manager, canonical);
      final verified = (await manager.scanPendingRecalls(subject.id))
          .single
          .recall;
      expect(verified.canWriteAvailability, isTrue);
      for (final food in _foods(verified)) {
        food.nutrition
          ..unavailableNutrients.clear()
          ..partialNutrients.clear()
          ..energyKcal = 0
          ..protein = 0;
      }
      await _save(manager, verified);
      await manager.submitPendingRecalls(subject: subject, trackProgress: true);
      expect(progressRequests, hasLength(1));
      final result = progressRequests.single['result'] as Map<String, dynamic>;
      expect(_hasIntent(result), isTrue);
      expect(jsonEncode(result), isNot(contains('availabilityVerified')));
      final saved = DailyRecall.fromJson(
        stored['result'] as Map<String, dynamic>,
      );
      expect(
        _foods(saved).every(
          (food) =>
              food.nutrition.protein == 0 &&
              food.nutrition.isKnown('protein') &&
              !food.nutrition.isPartial('energyKcal'),
        ),
        isTrue,
      );
      expect(await manager.scanPendingRecalls(subject.id), isEmpty);
    },
  );

  for (final operation in ['create', 'library', 'historical']) {
    test(
      'unverified nested $operation definition write cannot gain intent',
      () async {
        final originalServer = jsonEncode(stored);
        final unverified = DailyRecall.fromJson(_legacyJson(canonical));
        final food = unverified.meals.single.foods.single;
        final repository = NutritionFoodRepository();
        definitionsExist = operation != 'create';
        final Future<void> write = switch (operation) {
          'create' => repository.ensureDefinitions(
            subjectId: subject.id,
            foods: [food],
          ),
          'library' => repository.saveTemplate(
            subjectId: subject.id,
            name: 'Unrelated rename',
            food: food,
            expectedVersionId: food.foodVersionId,
          ),
          _ => repository.mutateHistoricalDefinition(
            subjectId: subject.id,
            snapshot: food,
            expectedVersionId: food.foodVersionId,
            entryId: food.id,
            target: {},
          ),
        };
        await expectLater(write, throwsA(isA<PostgrestException>()));
        expect(definitionRequests, hasLength(1));
        final snapshot =
            definitionRequests.single['p_snapshot'] as Map<String, dynamic>;
        _expectUnverifiedTransport(snapshot);
        expect(snapshot['componentSnapshots'], hasLength(1));
        expect(jsonEncode(stored), originalServer);
        expect(food.canWriteAvailability, isFalse);
      },
    );
  }
}

bool _hasIntent(Map<String, dynamic> json) =>
    json[NutritionProfile.availabilityWriteIntentKey] ==
    NutritionProfile.availabilityWriteIntent;

void _expectUnverifiedTransport(Map<String, dynamic> json) {
  expect(json, isNot(contains(NutritionProfile.availabilityWriteIntentKey)));
  expect(jsonEncode(json), isNot(contains('availabilityVerified')));
  expect(jsonEncode(json), isNot(contains('unavailableNutrients')));
  expect(jsonEncode(json), isNot(contains('partialNutrients')));
}

// This HTTP fixture models the existing SQL rejection. It is not a database test.
http.Response _rejection(http.BaseRequest request) => _response(
  {'code': '22023', 'message': 'Availability-aware write intent is required.'},
  request,
  status: 400,
);

http.Response _response(
  Object? body,
  http.BaseRequest request, {
  int status = 200,
}) => http.Response(
  jsonEncode(body),
  status,
  headers: const {'content-type': 'application/json'},
  request: request,
);

Map<String, dynamic> _serverResult(DailyRecall recall) =>
    Result<DailyRecall>.app(
      type: 'DailyRecall',
      periodId: 'period',
      result: recall,
    ).toJsonForStorage()..remove(NutritionProfile.availabilityWriteIntentKey);

Map<String, dynamic> _progressRow(DailyRecall recall) => {
  'subject_id': 'subject',
  'task_id': 'task',
  'intervention_id': 'intervention',
  'result_type': 'DailyRecall',
  'result': _serverResult(recall),
  'completed_at': recall.date.toUtc().toIso8601String(),
};

Map<String, dynamic> _subjectRow(StudySubject subject, DailyRecall recall) =>
    subject.toFullJson()..['subject_progress'] = [_progressRow(recall)];

Map<String, dynamic> _legacyJson(DailyRecall recall) {
  final json = recall.toJsonForStorage();
  void strip(dynamic value) {
    if (value is Map) {
      value.remove('unavailableNutrients');
      value.remove('partialNutrients');
      for (final nested in value.values) {
        strip(nested);
      }
    } else if (value is List) {
      for (final nested in value) {
        strip(nested);
      }
    }
  }

  strip(json);
  return json;
}

Future<void> _seedCache(
  Map<String, dynamic> recall, {
  required int studyDay,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    'studyu_nutrition_autosave_subject_task_period_$studyDay',
    jsonEncode({
      'recall': recall,
      'metadata': {
        'subjectId': 'subject',
        'taskId': 'task',
        'periodId': 'period',
        'interventionId': 'intervention',
        'studyDaySnapshot': studyDay,
        'lastModifiedAt': DateTime.now()
            .add(const Duration(minutes: 1))
            .toIso8601String(),
      },
    }),
  );
  await prefs.setString(
    'studyu_nutrition_autosave_index_subject',
    jsonEncode([
      {'taskId': 'task', 'periodId': 'period', 'studyDaySnapshot': studyDay},
    ]),
  );
}

Future<void> _save(
  NutritionRecallAutoSaveManager manager,
  DailyRecall recall,
) => manager.saveRecall(
  recall: recall,
  subjectId: 'subject',
  taskId: 'task',
  interventionId: 'intervention',
  periodId: 'period',
  studyDaySnapshot: recall.studyDaySnapshot!,
);

Iterable<FoodEntry> _foods(DailyRecall recall) =>
    recall.meals.expand((meal) => meal.foods).expand(_snapshots);

Iterable<FoodEntry> _snapshots(FoodEntry food) sync* {
  yield food;
  for (final child in food.componentSnapshots ?? <FoodEntry>[]) {
    yield* _snapshots(child);
  }
}

StudySubject _subject() => StudySubject('subject', 'study', 'user', [])
  ..startedAt = DateTime.now().subtract(const Duration(days: 2))
  ..study = (Study('study', 'user')
    ..schedule = (StudySchedule()..numberOfCycles = 0)
    ..interventions = []);

DailyRecall _recall({required int studyDay}) {
  final leaf = _food('leaf')
    ..nutrition.unavailableNutrients = {'protein'}
    ..nutrition.partialNutrients = {'energyKcal'};
  final child = _food('component')
    ..entryType = FoodEntryType.meal
    ..componentSnapshots = [leaf]
    ..componentFoods = [
      FoodComposition.withId(
        parentEntryId: 'component',
        foodId: leaf.foodId,
        amount: 1,
        unit: 'serving',
        sortOrder: 0,
      ),
    ]
    ..nutrition.unavailableNutrients = {'protein'}
    ..nutrition.partialNutrients = {'energyKcal'};
  final parent = _food('parent')
    ..entryType = FoodEntryType.meal
    ..componentSnapshots = [child]
    ..componentFoods = [
      FoodComposition.withId(
        parentEntryId: 'parent',
        foodId: child.foodId,
        amount: 1,
        unit: 'serving',
        sortOrder: 0,
      ),
    ]
    ..nutrition.unavailableNutrients = {'protein'}
    ..nutrition.partialNutrients = {'energyKcal'};
  return DailyRecall(
    id: 'recall',
    date: DateTime.now().subtract(Duration(days: 2 - studyDay)),
    recallMode: RecallMode.realtimeRecord,
    studyDaySnapshot: studyDay,
    entryStartedAt: DateTime.now().subtract(Duration(days: 2 - studyDay)),
    meals: [
      MealLog.withId(
        mealType: MealType.breakfast,
        timezone: 'UTC',
        isSkipped: false,
        foods: [parent],
      ),
    ],
  );
}

FoodEntry _food(String id) => FoodEntry(
  id: id,
  foodId: '$id-definition',
  foodVersionId: '$id-version',
  entryType: FoodEntryType.singleIngredient,
  name: id,
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 50,
    protein: 0,
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
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.now(),
  originalValues: {},
);
