import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

part 'user_repository.g.dart';

abstract class IUserRepository() {
  StudyUUser get user;
  StudyUUser? get cachedUser;
  Future<StudyUUser> fetchUser();
  Future<StudyUUser> saveUser();
  Future<StudyUUser> updatePreferences(
    PreferenceAction pinAction,
    String modelId,
  );
  Future<StudyUUser> updateDateFormat(DateFormatPreference? value);
  Future<StudyUUser> updateTimeFormat(TimeFormatPreference? value);
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
  Future<void> _preferenceUpdates = Future.value();

  @override
  StudyUUser get user => _user!;

  @override
  StudyUUser? get cachedUser => _user;

  @override
  Future<StudyUUser> fetchUser() async {
    if (_user != null) return user;

    // If a fetch is already in progress, return the same future
    if (_fetchFuture != null) {
      return await _fetchFuture!;
    }

    final userId = authRepository.currentUser!.id;

    _fetchFuture = apiClient.fetchUser(userId);
    _user = await _fetchFuture;
    _fetchFuture = null; // Clear the future once completed

    return user;
  }

  @override
  Future<StudyUUser> saveUser() {
    return _queuePreferenceUpdate(() async {
      await fetchUser();
      final savedUser = await apiClient.saveUser(user);
      _user = savedUser;
      return savedUser;
    });
  }

  @override
  Future<StudyUUser> updatePreferences(
    PreferenceAction pinAction,
    String modelId,
  ) {
    return _savePreferenceUpdate((preferences) {
      final pinnedStudies = Set<String>.from(preferences.pinnedStudies);
      switch (pinAction) {
        case PreferenceAction.pin:
          pinnedStudies.add(modelId);
        case PreferenceAction.pinOff:
          pinnedStudies.remove(modelId);
      }
      preferences.pinnedStudies = pinnedStudies;
    });
  }

  @override
  Future<StudyUUser> updateDateFormat(DateFormatPreference? value) {
    return _savePreferenceUpdate(
      (preferences) => preferences.dateFormat = value,
    );
  }

  @override
  Future<StudyUUser> updateTimeFormat(TimeFormatPreference? value) {
    return _savePreferenceUpdate(
      (preferences) => preferences.timeFormat = value,
    );
  }

  @override
  Future<StudyUUser> updateLanguage(String language) {
    return _savePreferenceUpdate(
      (preferences) => preferences.language = language,
    );
  }

  Future<StudyUUser> _savePreferenceUpdate(
    void Function(Preferences preferences) update,
  ) {
    return _queuePreferenceUpdate(() async {
      await fetchUser();
      final updatedUser = _copyUser();
      update(updatedUser.preferences);
      final savedUser = await apiClient.saveUser(updatedUser);
      _user = savedUser;
      return savedUser;
    });
  }

  Future<StudyUUser> _queuePreferenceUpdate(
    Future<StudyUUser> Function() update,
  ) {
    final operation = _preferenceUpdates.then((_) => update());
    _preferenceUpdates = operation.then<void>((_) {}, onError: (_, _) {});
    return operation;
  }

  StudyUUser _copyUser() {
    final currentUser = user;
    return StudyUUser(
      id: currentUser.id,
      email: currentUser.email,
      preferences: Preferences(
        language: currentUser.preferences.language,
        dateFormat: currentUser.preferences.dateFormat,
        timeFormat: currentUser.preferences.timeFormat,
        pinnedStudies: Set<String>.from(currentUser.preferences.pinnedStudies),
        studyFiltering: Map<String, dynamic>.from(
          currentUser.preferences.studyFiltering,
        ),
      ),
    );
  }

  @override
  Future<StudyUUser> saveCustomPreset(SavedFilter filter) {
    return _savePreferenceUpdate((preferences) {
      final presets = _getCustomPresets(preferences);
      final index = presets.indexWhere((preset) => preset.id == filter.id);
      if (index == -1) {
        presets.add(filter);
      } else {
        presets[index] = filter;
      }
      final filtering = Map<String, dynamic>.from(preferences.studyFiltering);
      filtering['custom_presets'] = presets
          .map((preset) => preset.toJson())
          .toList();
      preferences.studyFiltering = filtering;
    });
  }

  @override
  Future<StudyUUser> deleteCustomPreset(String id) {
    return _savePreferenceUpdate((preferences) {
      final presets = _getCustomPresets(preferences)
        ..removeWhere((preset) => preset.id == id);
      final filtering = Map<String, dynamic>.from(preferences.studyFiltering);
      filtering['custom_presets'] = presets
          .map((preset) => preset.toJson())
          .toList();
      preferences.studyFiltering = filtering;
    });
  }

  @override
  List<SavedFilter> getCustomPresets() {
    return _getCustomPresets(user.preferences);
  }

  List<SavedFilter> _getCustomPresets(Preferences preferences) {
    final presetsJson = preferences.studyFiltering['custom_presets'] as List?;
    if (presetsJson == null) return [];
    return presetsJson
        .map((item) => SavedFilter.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StudyUUser> saveActiveFilter({
    required String page,
    String? presetId,
    FilterGroup? filterGroup,
  }) {
    return _savePreferenceUpdate((preferences) {
      final filtering = Map<String, dynamic>.from(preferences.studyFiltering);
      final activeFilters = Map<String, dynamic>.from(
        filtering['active_filters'] as Map? ?? {},
      );

      activeFilters[page] = {
        'preset_id': ?presetId,
        if (filterGroup != null) 'filter_group': filterGroup.toJson(),
      };

      filtering['active_filters'] = activeFilters;
      preferences.studyFiltering = filtering;
    });
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
    return _savePreferenceUpdate((preferences) {
      final filtering = Map<String, dynamic>.from(preferences.studyFiltering);
      final activeSort = Map<String, dynamic>.from(
        filtering['active_sort'] as Map? ?? {},
      );

      activeSort[page] = {
        'sort_column': sortColumn,
        'sort_ascending': sortAscending,
      };

      filtering['active_sort'] = activeSort;
      preferences.studyFiltering = filtering;
    });
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

@riverpod
class UserState() extends _$UserState {
  @override
  Future<StudyUUser> build() {
    return ref.watch(userRepositoryProvider).fetchUser();
  }

  void setUser(StudyUUser user) {
    state = AsyncData(user);
  }
}
