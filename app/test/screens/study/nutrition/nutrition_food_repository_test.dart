import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'repository mutation and library hydration preserve availability',
    () async {
      final food = _food()
        ..nutrition.unavailableNutrients = {'protein', 'micros.iron'}
        ..nutrition.partialNutrients = {'energyKcal'};
      final repository = NutritionFoodRepository(
        client: _client((request) async {
          if (request.method == 'GET') {
            final row = _definitionRow()
              ..['nutrition_food_version'] = {
                'snapshot': food.toJsonForStorage(),
              };
            return _jsonResponse([row], request);
          }
          final params = jsonDecode(request.body) as Map<String, dynamic>;
          final snapshot = params['p_snapshot'] as Map<String, dynamic>;
          expect(jsonEncode(snapshot), isNot(contains('availabilityVerified')));
          expect(
            snapshot[NutritionProfile.availabilityWriteIntentKey],
            NutritionProfile.availabilityWriteIntent,
          );
          expect(
            snapshot['nutrition'] as Map<String, dynamic>,
            isNot(contains(NutritionProfile.availabilityWriteIntentKey)),
          );
          final sent = FoodEntry.fromJson(
            params['p_snapshot'] as Map<String, dynamic>,
          );
          expect(
            sent.nutrition.unavailableNutrients,
            food.nutrition.unavailableNutrients,
          );
          expect(sent.nutrition.partialNutrients, {'energyKcal'});
          return _jsonResponse(_mutationResponse(food: sent), request);
        }),
      );
      final loaded = (await repository.loadTemplates('subject')).single;
      expect(loaded.prototype.canWriteAvailability, isTrue);
      expect(loaded.prototype.nutrition.unavailableNutrients, {
        'protein',
        'micros.iron',
      });
      expect(loaded.prototype.nutrition.partialNutrients, {'energyKcal'});
      final saved = await repository.saveTemplate(
        subjectId: 'subject',
        name: 'Food',
        food: food,
        expectedVersionId: 'version-1',
      );
      expect(saved.prototype.canWriteAvailability, isTrue);
      expect(saved.prototype.nutrition.unavailableNutrients, {
        'protein',
        'micros.iron',
      });
      final mutation = await repository.mutateHistoricalDefinition(
        subjectId: 'subject',
        snapshot: food,
        expectedVersionId: 'version-1',
        entryId: food.id,
        target: {},
      );
      expect(mutation.definition.snapshot.nutrition.partialNutrients, {
        'energyKcal',
      });
    },
  );

  test('loads only active library-visible subject definitions', () async {
    late Uri requestedUri;
    final repository = NutritionFoodRepository(
      client: _client((request) async {
        requestedUri = request.url;
        return _jsonResponse([_definitionRow()], request);
      }),
    );

    final templates = await repository.loadTemplates('subject');

    expect(templates.single.id, 'food-definition');
    expect(templates.single.prototype.foodVersionId, 'version-1');
    expect(templates.single.tags, ['fruit']);
    expect(requestedUri.query, contains('subject_id=eq.subject'));
    expect(requestedUri.query, contains('library_visible=eq.true'));
    expect(requestedUri.query, contains('deleted_at=is.null'));
  });

  test('historical mutation returns explicit update counts', () async {
    late Map<String, dynamic> params;
    final repository = NutritionFoodRepository(
      client: _client((request) async {
        params = jsonDecode(request.body) as Map<String, dynamic>;
        return _jsonResponse(_mutationResponse(), request);
      }),
    );

    final result = await repository.mutateHistoricalDefinition(
      subjectId: 'subject',
      snapshot: _food(),
      expectedVersionId: 'version-1',
      entryId: 'selected-entry',
      target: const {'taskId': 'task'},
      currentStudyDay: 5,
      mutationId: 'mutation',
    );

    expect(params['p_historical_entry_id'], 'selected-entry');
    expect(params['p_food_id'], 'food-definition');
    expect(params['p_propagate_study_day'], 5);
    expect(result.progress, hasLength(3));
    expect(result.selectedHistoricalUpdateCount, 1);
    expect(result.todayUpdateCount, 3);
  });

  test('historical mutation forwards null propagation', () async {
    late Map<String, dynamic> params;
    final repository = NutritionFoodRepository(
      client: _client((request) async {
        params = jsonDecode(request.body) as Map<String, dynamic>;
        return _jsonResponse(_mutationResponse(), request);
      }),
    );

    await repository.mutateHistoricalDefinition(
      subjectId: 'subject',
      snapshot: _food(),
      expectedVersionId: 'version-1',
      entryId: 'selected-entry',
      target: const {'taskId': 'task'},
    );

    expect(params['p_propagate_study_day'], isNull);
  });

  test('historical composite setup uses the mutation transaction', () async {
    final requests = <http.BaseRequest>[];
    late Map<String, dynamic> params;
    final meal = _meal([
      _food(
        id: 'existing-component',
        foodId: 'existing-definition',
        versionId: 'existing-version',
      ),
      _food(
        id: 'missing-component',
        foodId: 'missing-definition',
        versionId: 'missing-version',
      ),
    ]);
    final repository = NutritionFoodRepository(
      client: _client((request) async {
        requests.add(request);
        params = jsonDecode(request.body) as Map<String, dynamic>;
        return _jsonResponse(
          _mutationResponse(food: meal, kind: 'meal'),
          request,
        );
      }),
    );

    await repository.mutateHistoricalDefinition(
      subjectId: 'subject',
      snapshot: meal,
      expectedVersionId: meal.foodVersionId,
      entryId: 'selected-meal',
      target: const {'taskId': 'task'},
    );

    expect(requests, hasLength(1));
    expect(params['p_food_id'], 'meal-definition');
    expect(params['p_propagate_study_day'], isNull);
    expect(
      (params['p_snapshot'] as Map<String, dynamic>)['componentSnapshots'],
      hasLength(2),
    );
    expect(
      ((params['p_snapshot'] as Map<String, dynamic>)['componentFoods']
              as List<dynamic>)
          .map((component) => (component as Map<String, dynamic>)['foodId']),
      ['existing-definition', 'missing-definition'],
    );
  });

  for (final definitionExists in [false, true]) {
    test(
      'repairs every duplicate occurrence version ($definitionExists)',
      () async {
        final repository = NutritionFoodRepository(
          client: _client((request) async {
            if (request.url.path.endsWith('/nutrition_food_definition')) {
              return _jsonResponse(
                definitionExists
                    ? [
                        {
                          'id': 'food-definition',
                          'current_version_id': 'version-1',
                        },
                      ]
                    : [],
                request,
              );
            }
            if (request.method == 'GET') return _jsonResponse([], request);
            return _jsonResponse(_mutationResponse(), request);
          }),
        );
        final foods = [
          _food(id: 'first', versionId: 'provisional-1'),
          _food(id: 'second', versionId: 'provisional-2'),
        ];

        await repository.ensureDefinitions(subjectId: 'subject', foods: foods);

        expect(foods.map((food) => food.foodVersionId), [
          'version-1',
          'version-1',
        ]);
      },
    );
  }

  test('creates missing entry definitions through the mutation RPC', () async {
    final requests = <http.BaseRequest>[];
    final repository = NutritionFoodRepository(
      client: _client((request) async {
        requests.add(request);
        if (request.method == 'GET') return _jsonResponse([], request);
        final params = jsonDecode(request.body) as Map<String, dynamic>;
        expect(params['p_food_id'], 'food-definition');
        expect(params['p_expected_version_id'], isNull);
        expect(params['p_library_visible'], isFalse);
        expect(params['p_mutation_id'], isA<String>());
        return _jsonResponse(_mutationResponse(), request);
      }),
    );
    final food = _food(versionId: 'provisional-version');

    await repository.ensureDefinitions(subjectId: 'subject', foods: [food]);

    expect(requests, hasLength(2));
    expect(food.foodVersionId, 'version-1');
  });
}

http.Response _jsonResponse(Object? body, http.BaseRequest request) =>
    http.Response(
      jsonEncode(body),
      200,
      headers: const {'content-type': 'application/json'},
      request: request,
    );

SupabaseClient _client(MockClientHandler handler) => SupabaseClient(
  'https://example.supabase.co',
  'test-key',
  httpClient: MockClient(handler),
);

Map<String, dynamic> _definitionRow() => {
  'id': 'food-definition',
  'subject_id': 'subject',
  'deleted_at': null,
  'created_at': '2026-07-15T08:00:00.000Z',
  'updated_at': '2026-07-15T08:00:00.000Z',
  'nutrition_food_version': {'snapshot': _food().toJsonForStorage()},
};

Map<String, dynamic> _mutationResponse({
  FoodEntry? food,
  String kind = 'food',
}) => {
  'definition': {
    'id': food?.foodId ?? 'food-definition',
    'subjectId': 'subject',
    'kind': kind,
    'currentVersionId': food?.foodVersionId ?? 'version-1',
    'deletedAt': null,
    'snapshot': (food ?? _food()).toJsonForStorage(),
    'createdAt': '2026-07-15T08:00:00.000Z',
    'updatedAt': '2026-07-15T08:00:00.000Z',
  },
  'progress': const [
    {'task_id': 'historical-task'},
    {'task_id': 'today-task-a'},
    {'task_id': 'today-task-b'},
  ],
  'selectedHistoricalUpdateCount': 1,
  'todayUpdateCount': 3,
};

FoodEntry _meal(List<FoodEntry> components) {
  final meal = _food(
    id: 'meal-snapshot',
    foodId: 'meal-definition',
    versionId: 'meal-version',
  )..entryType = FoodEntryType.meal;
  meal.componentFoods = [
    for (var index = 0; index < components.length; index++)
      FoodComposition(
        id: 'composition-$index',
        parentEntryId: meal.id,
        foodId: components[index].foodId,
        amount: components[index].amount,
        unit: components[index].unit,
        sortOrder: index,
      ),
  ];
  meal.componentSnapshots = components;
  return meal;
}

FoodEntry _food({
  String id = 'snapshot',
  String foodId = 'food-definition',
  String versionId = 'version-1',
}) => FoodEntry(
  id: id,
  foodId: foodId,
  foodVersionId: versionId,
  entryType: FoodEntryType.singleIngredient,
  name: 'Apple',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 100,
    protein: 1,
    carbs: 1,
    fat: 1,
    sugars: 0,
    fiber: 0,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: const {},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15, 8),
  originalValues: const {
    '_libraryTags': ['fruit'],
  },
);
