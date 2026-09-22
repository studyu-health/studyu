import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// The server is the authoritative library; snapshots in recalls stay immutable.
class NutritionFoodRepository({final SupabaseClient? _client}) {
  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<List<SavedFoodTemplate>> loadTemplates(String subjectId) async {
    final rows = await _supabase
        .from('nutrition_food_definition')
        .select(
          'id, subject_id, deleted_at, created_at, updated_at, '
          'nutrition_food_version!nutrition_food_definition_current_version_id_fkey(snapshot)',
        )
        .eq('subject_id', subjectId)
        .eq('library_visible', true)
        .isFilter('deleted_at', null);
    return (rows as List<dynamic>)
        .map((row) => _templateFromRow(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<SavedFoodTemplate> saveTemplate({
    required String subjectId,
    required String name,
    required FoodEntry food,
    List<String>? tags,
    String? expectedVersionId,
  }) async {
    final persisted = food.entryType == FoodEntryType.meal
        ? normalizeCompositeNutritionFoodDefinition(food)
        : FoodEntry.fromJson(food.toJson());
    await ensureDefinitions(
      subjectId: subjectId,
      foods: _validatedComponents(persisted),
    );
    final definitionId = persisted.foodId;
    final snapshot = Map<String, dynamic>.from(persisted.toJson())
      ..['foodId'] = definitionId
      ..['name'] = name
      ..['originalValues'] = {
        ...persisted.originalValues,
        '_libraryTags': tags ?? const <String>[],
      };
    final response = await _mutate(
      subjectId: subjectId,
      foodId: definitionId,
      expectedVersionId:
          expectedVersionId ?? await _currentVersionId(subjectId, definitionId),
      snapshot: snapshot,
      libraryVisible: true,
    );
    return _templateFromDefinition(response.definition);
  }

  /// Creates server definitions for newly sourced foods before they are logged.
  Future<void> ensureDefinitions({
    required String subjectId,
    required Iterable<FoodEntry> foods,
  }) async {
    final sourceById = {for (final food in foods) food.foodId: food};
    if (sourceById.isEmpty) return;
    final byId = {
      for (final food in sourceById.values)
        food.foodId: food.entryType == FoodEntryType.meal
            ? normalizeCompositeNutritionFoodDefinition(food)
            : food,
    };
    final existing = await _supabase
        .from('nutrition_food_definition')
        .select('id,current_version_id')
        .eq('subject_id', subjectId)
        .inFilter('id', byId.keys.toList());
    final currentVersions = {
      for (final row in existing as List<dynamic>)
        (row as Map<String, dynamic>)['id'] as String:
            row['current_version_id'] as String,
    };
    if (currentVersions.isNotEmpty) {
      final localVersionIds = byId.values
          .where((food) => currentVersions.containsKey(food.foodId))
          .map((food) => food.foodVersionId)
          .toList();
      final versions = await _supabase
          .from('nutrition_food_version')
          .select('id,food_id')
          .inFilter('id', localVersionIds);
      final validLinkages = {
        for (final row in versions as List<dynamic>)
          '${(row as Map<String, dynamic>)['food_id']}:${row['id']}',
      };
      for (final food in byId.values.where(
        (food) => currentVersions.containsKey(food.foodId),
      )) {
        if (!validLinkages.contains('${food.foodId}:${food.foodVersionId}')) {
          sourceById[food.foodId]!.foodVersionId =
              currentVersions[food.foodId]!;
        }
      }
    }
    for (final food in byId.values.where(
      (food) => !currentVersions.containsKey(food.foodId),
    )) {
      final result = await _mutate(
        subjectId: subjectId,
        foodId: food.foodId,
        expectedVersionId: null,
        snapshot: food.toJson(),
        libraryVisible: false,
      );
      sourceById[food.foodId]!.foodVersionId =
          result.definition.currentVersionId;
    }
  }

  Future<String?> _currentVersionId(String subjectId, String foodId) async {
    final row = await _supabase
        .from('nutrition_food_definition')
        .select('current_version_id')
        .eq('subject_id', subjectId)
        .eq('id', foodId)
        .maybeSingle();
    return row?['current_version_id'] as String?;
  }

  Future<void> deleteTemplate({
    required String subjectId,
    required SavedFoodTemplate template,
  }) async {
    await _mutate(
      subjectId: subjectId,
      foodId: template.id,
      expectedVersionId: template.prototype.foodVersionId,
      snapshot: template.prototype.toJson(),
      deleted: true,
    );
  }

  Future<NutritionFoodMutationResult> mutateHistoricalDefinition({
    required String subjectId,
    required FoodEntry snapshot,
    required String expectedVersionId,
    required String entryId,
    required Map<String, dynamic> target,
    int? currentStudyDay,
    String? mutationId,
  }) {
    final persisted = snapshot.entryType == FoodEntryType.meal
        ? normalizeCompositeNutritionFoodDefinition(snapshot)
        : snapshot;
    _validatedComponents(persisted).toList();
    return _mutate(
      subjectId: subjectId,
      foodId: persisted.foodId,
      expectedVersionId: expectedVersionId,
      snapshot: persisted.toJson(),
      historicalTarget: target,
      historicalEntryId: entryId,
      propagateStudyDay: currentStudyDay,
      mutationId: mutationId,
    );
  }

  Iterable<FoodEntry> _validatedComponents(FoodEntry food) {
    if (food.entryType != FoodEntryType.meal) {
      return food.componentSnapshots ?? const [];
    }
    final compositions = food.componentFoods;
    final snapshots = food.componentSnapshots;
    if (compositions == null ||
        snapshots == null ||
        compositions.length != snapshots.length) {
      throw StateError('Saved meals require complete component snapshots');
    }
    for (var index = 0; index < compositions.length; index++) {
      if (compositions[index].foodId != snapshots[index].foodId) {
        throw StateError('Saved meal components must match in order');
      }
      if (snapshots[index].entryType == FoodEntryType.meal) {
        throw StateError('Saved meal ingredients must be leaf foods');
      }
    }
    return snapshots;
  }

  Future<NutritionFoodMutationResult> _mutate({
    required String subjectId,
    required String foodId,
    required String? expectedVersionId,
    required Map<String, dynamic> snapshot,
    bool deleted = false,
    Map<String, dynamic>? historicalTarget,
    String? historicalEntryId,
    int? propagateStudyDay,
    bool? libraryVisible,
    String? mutationId,
  }) async {
    final response = await _supabase.rpc(
      'apply_nutrition_food_mutation',
      params: {
        'p_subject_id': subjectId,
        'p_mutation_id': mutationId ?? const Uuid().v4(),
        'p_food_id': foodId,
        'p_expected_version_id': expectedVersionId,
        'p_snapshot': snapshot,
        'p_deleted': deleted,
        'p_historical_target': historicalTarget,
        'p_historical_entry_id': historicalEntryId,
        'p_propagate_study_day': propagateStudyDay,
        'p_library_visible': libraryVisible,
      },
    );
    return NutritionFoodMutationResult.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  SavedFoodTemplate _templateFromDefinition(
    NutritionFoodDefinition definition,
  ) {
    final snapshot = definition.snapshot;
    final tags = snapshot.originalValues['_libraryTags'];
    return SavedFoodTemplate(
      id: definition.id,
      userId: definition.subjectId,
      name: snapshot.name,
      tags: tags is List ? List<String>.from(tags) : null,
      isPublic: false,
      createdAt: definition.createdAt,
      updatedAt: definition.updatedAt,
      prototype: snapshot,
    );
  }

  SavedFoodTemplate _templateFromRow(Map<String, dynamic> row) {
    final version = Map<String, dynamic>.from(
      row['nutrition_food_version'] as Map,
    );
    final food = FoodEntry.fromJson(
      Map<String, dynamic>.from(version['snapshot'] as Map),
    );
    final tags = food.originalValues['_libraryTags'];
    return SavedFoodTemplate(
      id: row['id'] as String,
      userId: row['subject_id'] as String,
      name: food.name,
      tags: tags is List ? List<String>.from(tags) : null,
      isPublic: false,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      prototype: food,
    );
  }
}
