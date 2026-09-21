import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

part 'user_repository.g.dart';

abstract class IUserRepository() {
  StudyUUser get user;
  Future<StudyUUser> fetchUser();
  Future<StudyUUser> saveUser();
  Future<StudyUUser> updatePreferences(
    PreferenceAction pinAction,
    String modelId,
  );
  Future<StudyUUser> updateLanguage(String language);
  Future<StudyUUser> saveCustomPreset(SavedFilter filter);
  Future<StudyUUser> deleteCustomPreset(String id);
  List<SavedFilter> getCustomPresets();
  ({String? presetId, FilterGroup? filterGroup}) getActiveFilter(String page);
  Future<StudyUUser> saveActiveFilter({
    required String page,
    String? presetId,
    FilterGroup? filterGroup,
  });

  /// Active sort column + direction for the given dashboard page.
  /// `sortColumn` is the [StudiesTableColumn] enum name (e.g. `'createdAt'`);
  /// callers map it back to the enum value. Returns `(null, null)` when the
  /// user has not set a sort yet, in which case defaults apply.
  ({String? sortColumn, bool? sortAscending}) getActiveSort(String page);

  /// Persists the sort selection for the given dashboard page. Fire-and-forget
  /// from the controller — failure to save should not block UI updates.
  Future<StudyUUser> saveActiveSort({
    required String page,
    required String sortColumn,
    required bool sortAscending,
  });
}

enum PreferenceAction() {
  pin,
  pinOff,
}

class UserRepository({
  required final IAuthRepository authRepository,
  required final StudyUApi apiClient,
  required final Ref ref,
}) implements IUserRepository {
  StudyUUser? _user;
  Future<StudyUUser>? _fetchFuture;

  @override
  StudyUUser get user => _user!;

  @override
  Future<StudyUUser> fetchUser() async {
    if (_user != null) return user;

    // If a fetch is already in progress, return the same future
    if (_fetchFuture != null) {
      return await _fetchFuture!;
    }

    final userId = ref.read(authRepositoryProvider).currentUser!.id;

    _fetchFuture = apiClient.fetchUser(userId);
    _user = await _fetchFuture;
    _fetchFuture = null; // Clear the future once completed

    return user;
  }

  @override
  Future<StudyUUser> saveUser() async {
    _user = await apiClient.saveUser(user);
    return user;
  }

  @override
  Future<StudyUUser> updatePreferences(
    PreferenceAction pinAction,
    String modelId,
  ) {
    final newPinnedStudies = Set<String>.from(user.preferences.pinnedStudies);
    switch (pinAction) {
      case PreferenceAction.pin:
        newPinnedStudies.add(modelId);
      case PreferenceAction.pinOff:
        newPinnedStudies.remove(modelId);
    }
    user.preferences.pinnedStudies = newPinnedStudies;
    return saveUser();
  }

  @override
  Future<StudyUUser> updateLanguage(String language) async {
    await fetchUser();
    user.preferences.language = language;
    return await saveUser();
  }

  @override
  Future<StudyUUser> saveCustomPreset(SavedFilter filter) {
    final presets = getCustomPresets();
    final index = presets.indexWhere((p) => p.id == filter.id);
    if (index != -1) {
      presets[index] = filter;
    } else {
      presets.add(filter);
    }
    return _updateStudyFiltering(
      'custom_presets',
      presets.map((e) => e.toJson()).toList(),
    );
  }

  @override
  Future<StudyUUser> deleteCustomPreset(String id) {
    final presets = getCustomPresets();
    presets.removeWhere((p) => p.id == id);
    return _updateStudyFiltering(
      'custom_presets',
      presets.map((e) => e.toJson()).toList(),
    );
  }

  @override
  List<SavedFilter> getCustomPresets() {
    final filtering = user.preferences.studyFiltering;
    final presetsJson = filtering['custom_presets'] as List?;
    if (presetsJson == null) return [];
    return presetsJson
        .map((e) => SavedFilter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StudyUUser> saveActiveFilter({
    required String page,
    String? presetId,
    FilterGroup? filterGroup,
  }) {
    final filtering = Map<String, dynamic>.from(
      user.preferences.studyFiltering,
    );
    final activeFilters = Map<String, dynamic>.from(
      filtering['active_filters'] as Map? ?? {},
    );

    activeFilters[page] = {
      'preset_id': ?presetId,
      if (filterGroup != null) 'filter_group': filterGroup.toJson(),
    };

    filtering['active_filters'] = activeFilters;
    user.preferences.studyFiltering = filtering;
    return saveUser();
  }

  @override
  ({String? presetId, FilterGroup? filterGroup}) getActiveFilter(String page) {
    final filtering = user.preferences.studyFiltering;
    final activeFilters = filtering['active_filters'] as Map?;
    if (activeFilters == null) return (presetId: null, filterGroup: null);

    final pageFilter = activeFilters[page] as Map?;
    if (pageFilter == null) return (presetId: null, filterGroup: null);

    final presetId = pageFilter['preset_id'] as String?;
    final filterGroupJson = pageFilter['filter_group'] as Map<String, dynamic>?;
    final filterGroup = filterGroupJson != null
        ? FilterGroup.fromJson(filterGroupJson)
        : null;

    return (presetId: presetId, filterGroup: filterGroup);
  }

  @override
  ({String? sortColumn, bool? sortAscending}) getActiveSort(String page) {
    final filtering = user.preferences.studyFiltering;
    final activeSort = filtering['active_sort'] as Map?;
    if (activeSort == null) return (sortColumn: null, sortAscending: null);

    final pageSort = activeSort[page] as Map?;
    if (pageSort == null) return (sortColumn: null, sortAscending: null);

    return (
      sortColumn: pageSort['sort_column'] as String?,
      sortAscending: pageSort['sort_ascending'] as bool?,
    );
  }

  @override
  Future<StudyUUser> saveActiveSort({
    required String page,
    required String sortColumn,
    required bool sortAscending,
  }) {
    final filtering = Map<String, dynamic>.from(
      user.preferences.studyFiltering,
    );
    final activeSort = Map<String, dynamic>.from(
      filtering['active_sort'] as Map? ?? {},
    );

    activeSort[page] = {
      'sort_column': sortColumn,
      'sort_ascending': sortAscending,
    };

    filtering['active_sort'] = activeSort;
    user.preferences.studyFiltering = filtering;
    return saveUser();
  }

  Future<StudyUUser> _updateStudyFiltering(String key, dynamic value) {
    final filtering = Map<String, dynamic>.from(
      user.preferences.studyFiltering,
    );
    filtering[key] = value;
    user.preferences.studyFiltering = filtering;
    return saveUser();
  }
}

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository(
    authRepository: ref.watch(authRepositoryProvider),
    apiClient: ref.watch(apiClientProvider),
    ref: ref,
  );
}
