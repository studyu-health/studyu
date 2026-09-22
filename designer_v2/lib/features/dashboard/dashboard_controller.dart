import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_navigation.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_to_postgrest.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController()
    extends _$DashboardController
    implements IModelActionProvider<Study> {
  @override
  DashboardState build() {
    _studyRepository = ref.watch(studyRepositoryProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    _userRepository = ref.watch(userRepositoryProvider);
    _dispatch = ref.watch(dashboardDispatchProvider);

    ref.onDispose(() {
      _searchDebounce?.cancel();
    });

    _loadInitial();

    return DashboardState(
      currentUser: _authRepository.currentUser!,
      searchController: SearchController(),
    );
  }

  late final IStudyRepository _studyRepository;
  late final IAuthRepository _authRepository;
  late final IUserRepository _userRepository;
  late final DashboardDispatch _dispatch;

  Timer? _searchDebounce;
  static const _searchDebounceDuration = Duration(milliseconds: 300);

  /// Monotonic counter used to discard responses from stale fetches when the
  /// user changes filter/sort/search faster than the network responds.
  int _fetchToken = 0;

  Future<void> _loadInitial() async {
    await _loadSavedFilters();
    // Note: page-specific active filter / sort and the first list fetch are
    // driven by setStudiesFilter(widget.filter) from DashboardScreen.initState.
    // We deliberately do NOT call _resetAndReload here, otherwise we would
    // race against that path and fire two redundant HTTP fetches per nav.
  }

  /// Loads only page-agnostic UI metadata: the user record (so getActiveFilter
  /// has data to read later) and the saved-preset list (which is shared across
  /// all dashboard page-keys). Per-page active filter + sort restoration lives
  /// in [setStudiesFilter] so it always matches the route the widget mounted.
  Future<void> _loadSavedFilters() async {
    try {
      await _userRepository.fetchUser();
      if (!ref.mounted) return;
      final savedFilters = _userRepository.getCustomPresets();
      state = state.copyWith(savedFilters: () => savedFilters);
    } catch (e) {
      print("Failed to load user preferences: $e");
    }
  }

  Future<void> _resetAndReload({bool clearStudies = false, int? limit}) async {
    _searchDebounce?.cancel();
    final token = ++_fetchToken;
    final retainedStudies = clearStudies
        ? null
        : state.displayedStudies.asData?.value;
    state = state.copyWith(
      loadedStudies: () => clearStudies ? const [] : state.loadedStudies,
      pinnedStudiesList: () =>
          clearStudies ? const [] : state.pinnedStudiesList,
      retainedStudies: () => retainedStudies,
      totalCount: clearStudies ? 0 : state.totalCount,
      isLoadingInitial: retainedStudies == null,
      isRefreshing: retainedStudies != null,
      isLoadingMore: false,
      isLoadingPinned: true,
      hasMore: clearStudies || state.hasMore,
      loadError: () => null,
      advancedFilterUnsupported: false,
    );

    final pinnedError = await _fetchPinnedFor(token);
    if (!ref.mounted || token != _fetchToken) return;

    final pageTotalFuture = _fetchPageTotalCount(token);
    await _fetchPageWithLimit(token, isInitial: true, limit: limit);
    if (!ref.mounted || token != _fetchToken) return;
    final pageTotalError = await pageTotalFuture;
    if (!ref.mounted || token != _fetchToken) return;

    final auxiliaryError = pinnedError ?? pageTotalError;
    if (state.loadError == null && auxiliaryError != null) {
      state = state.copyWith(loadError: () => auxiliaryError);
    }
    state = state.copyWith(isLoadingInitial: false, isRefreshing: false);
  }

  Future<Object?> _fetchPinnedFor(int token) async {
    final pinnedIds = _userRepository.user.preferences.pinnedStudies;
    if (pinnedIds.isEmpty) {
      if (!ref.mounted || token != _fetchToken) return null;
      state = state.copyWith(
        pinnedStudiesList: () => const [],
        isLoadingPinned: false,
      );
      return null;
    }
    try {
      final pinned = await _studyRepository.fetchPinned(pinnedIds.toSet());
      if (!ref.mounted || token != _fetchToken) return null;
      state = state.copyWith(
        pinnedStudiesList: () => pinned,
        isLoadingPinned: false,
      );
      return null;
    } catch (e) {
      if (!ref.mounted || token != _fetchToken) return null;
      state = state.copyWith(isLoadingPinned: false);
      return e;
    }
  }

  Future<void> _fetchPage(int token, {required bool isInitial}) async {
    await _fetchPageWithLimit(token, isInitial: isInitial);
  }

  Future<void> _fetchPageWithLimit(
    int token, {
    required bool isInitial,
    int? limit,
  }) async {
    try {
      final pinnedIds = state.pinnedStudiesList.map((study) => study.id);
      final offset = isInitial ? 0 : state.loadedStudies.length;
      final fetchLimit = limit ?? DashboardState.pageSize;

      final page = await _studyRepository.fetchPage(
        offset: offset,
        limit: fetchLimit,
        sortBy: state.sortByColumn,
        ascending: state.sortAscending,
        preset: state.studiesFilter ?? DashboardState.defaultFilter,
        currentUser: state.currentUser,
        searchQuery: state.query,
        advancedFilter: state.activeFilter,
        excludeIds: pinnedIds.toList(),
      );

      if (!ref.mounted || token != _fetchToken) return;

      final updatedLoaded = isInitial
          ? page.studies
          : [...state.loadedStudies, ...page.studies];
      final hasMore = updatedLoaded.length < page.totalCount;

      state = state.copyWith(
        loadedStudies: () => updatedLoaded,
        retainedStudies: () => null,
        totalCount: page.totalCount,
        isLoadingMore: false,
        hasMore: hasMore,
        loadError: () => null,
        advancedFilterUnsupported: false,
      );
    } on UnsupportedFilterException catch (e) {
      if (!ref.mounted || token != _fetchToken) return;
      state = state.copyWith(
        loadedStudies: () => const [],
        retainedStudies: () => null,
        totalCount: 0,
        isLoadingMore: false,
        hasMore: false,
        loadError: () => e,
        advancedFilterUnsupported: true,
      );
    } catch (e) {
      if (!ref.mounted || token != _fetchToken) return;
      state = state.copyWith(
        isLoadingMore: false,
        hasMore: false,
        loadError: () => e,
      );
    }
  }

  Future<void> _refreshAfterMutation({int? targetLoadedStudyCount}) {
    return _resetAndReload(
      limit: max(
        targetLoadedStudyCount ?? state.loadedStudies.length,
        DashboardState.pageSize,
      ),
    );
  }

  Future<void> _runStudyAction(
    String studyId,
    Future<void> Function() execute,
  ) async {
    if (state.pendingStudyIds.contains(studyId)) return;
    state = state.copyWith(
      pendingStudyIds: {...state.pendingStudyIds, studyId},
      loadError: () => null,
    );
    try {
      await execute();
    } catch (e) {
      if (ref.mounted) state = state.copyWith(loadError: () => e);
    } finally {
      if (ref.mounted) {
        state = state.copyWith(
          pendingStudyIds: {...state.pendingStudyIds}..remove(studyId),
        );
      }
    }
  }

  void _removeStudyLocally(String studyId) {
    final updatedPinnedStudies = [
      for (final study in state.pinnedStudiesList)
        if (study.id != studyId) study,
    ];
    final updatedLoadedStudies = [
      for (final study in state.loadedStudies)
        if (study.id != studyId) study,
    ];

    final removedPinnedCount =
        state.pinnedStudiesList.length - updatedPinnedStudies.length;
    final removedLoadedCount =
        state.loadedStudies.length - updatedLoadedStudies.length;
    final retainedContainsStudy =
        state.retainedStudies?.any((study) => study.id == studyId) ?? false;
    if (removedPinnedCount + removedLoadedCount == 0 &&
        !retainedContainsStudy) {
      return;
    }

    final updatedTotalCount = max(state.totalCount - removedLoadedCount, 0);
    final updatedPageTotalCount = max(
      state.pageTotalCount - removedLoadedCount,
      0,
    );
    final updatedRetainedStudies = state.retainedStudies
        ?.where((study) => study.id != studyId)
        .toList();

    state = state.copyWith(
      pinnedStudiesList: () => updatedPinnedStudies,
      loadedStudies: () => updatedLoadedStudies,
      retainedStudies: () => updatedRetainedStudies,
      totalCount: updatedTotalCount,
      pageTotalCount: updatedPageTotalCount,
      hasMore: updatedLoadedStudies.length < updatedTotalCount,
      loadError: () => null,
    );
  }

  Future<Object?> _fetchPageTotalCount(int token) async {
    try {
      final pinnedIds = state.pinnedStudiesList.map((study) => study.id);
      final page = await _studyRepository.fetchPage(
        offset: 0,
        limit: 1,
        sortBy: state.sortByColumn,
        ascending: state.sortAscending,
        preset: state.studiesFilter ?? DashboardState.defaultFilter,
        currentUser: state.currentUser,
        excludeIds: pinnedIds.toList(),
      );

      if (!ref.mounted || token != _fetchToken) return null;

      state = state.copyWith(pageTotalCount: page.totalCount);
      return null;
    } catch (e) {
      if (!ref.mounted || token != _fetchToken) return null;
      return e;
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.isLoadingInitial ||
        state.isRefreshing ||
        state.pendingStudyIds.isNotEmpty) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    await _fetchPage(_fetchToken, isInitial: false);
  }

  Future<void> retry() async {
    await _refreshAfterMutation();
  }

  void setSearchText(String? text) {
    state.searchController.setText(text ?? state.query);
  }

  Future<void> setStudiesFilter(StudiesFilter? filter) async {
    await _userRepository.fetchUser();
    if (!ref.mounted) return;
    final newFilter = filter ?? DashboardState.defaultFilter;
    final pageKey = _getPageKey(newFilter);
    final active = _userRepository.getActiveFilter(pageKey);
    final activeSort = _resolveActiveSort(pageKey);

    state = state.copyWith(
      studiesFilter: () => newFilter,
      activeFilter: () => active.filterGroup,
      selectedSavedFilterId: () => active.presetId,
      sortByColumn: activeSort.sortByColumn,
      sortAscending: activeSort.sortAscending,
    );
    await _resetAndReload(clearStudies: true);
  }

  Future<void> updateFilter(FilterGroup filter, {String? presetId}) async {
    state = state.copyWith(
      retainedStudies: () => state.displayedStudies.asData?.value,
      activeFilter: () => filter,
      selectedSavedFilterId: () => presetId,
    );
    final pageKey = _getPageKey(state.studiesFilter);
    _userRepository.saveActiveFilter(
      page: pageKey,
      presetId: presetId,
      filterGroup: filter,
    );
    await _resetAndReload();
  }

  Future<void> saveFilter(SavedFilter filter) async {
    await _userRepository.saveCustomPreset(filter);
    if (!ref.mounted) return;
    state = state.copyWith(
      savedFilters: () => _userRepository.getCustomPresets(),
    );
  }

  Future<void> deleteFilter(String id) async {
    await _userRepository.deleteCustomPreset(id);
    if (!ref.mounted) return;
    state = state.copyWith(
      savedFilters: () => _userRepository.getCustomPresets(),
    );
  }

  String _getPageKey(StudiesFilter? filter) {
    return switch (filter) {
      StudiesFilter.owned => 'my_studies',
      StudiesFilter.shared => 'shared_studies',
      StudiesFilter.public => 'public_studies',
      StudiesFilter.all => 'all_studies',
      null => 'my_studies',
    };
  }

  void onSelectStudy(Study study) {
    _dispatch(study.id);
  }

  void onClickNewStudy() {
    final Study newStudy = _studyRepository.delegate.createNewInstance();
    newStudy.save();
    _dispatch(newStudy.id);
  }

  Future<void> pinStudy(String modelId) => _runStudyAction(modelId, () async {
    final wasUnpinned = !_userRepository.user.preferences.pinnedStudies
        .contains(modelId);
    final wasLoading =
        state.isLoadingInitial ||
        state.isLoadingMore ||
        state.isLoadingPinned ||
        state.isRefreshing;
    final wasLoaded = state.loadedStudies.any((study) => study.id == modelId);
    await _userRepository.updatePreferences(PreferenceAction.pin, modelId);
    if (!ref.mounted) return;

    final studyIndex = state.loadedStudies.indexWhere(
      (study) => study.id == modelId,
    );
    final canUpdateLocally =
        wasUnpinned &&
        wasLoaded &&
        !wasLoading &&
        !state.isLoadingInitial &&
        !state.isLoadingMore &&
        !state.isLoadingPinned &&
        !state.isRefreshing &&
        state.retainedStudies == null &&
        studyIndex != -1;
    if (!canUpdateLocally) {
      await _refreshAfterMutation();
      return;
    }

    final updatedLoaded = [...state.loadedStudies]..removeAt(studyIndex);
    final updatedTotalCount = state.totalCount > 0 ? state.totalCount - 1 : 0;
    final updatedPageTotalCount = state.pageTotalCount > 0
        ? state.pageTotalCount - 1
        : 0;
    state = state.copyWith(
      loadedStudies: () => updatedLoaded,
      pinnedStudiesList: () => [
        ...state.pinnedStudiesList,
        state.loadedStudies[studyIndex],
      ],
      totalCount: updatedTotalCount,
      pageTotalCount: updatedPageTotalCount,
      hasMore: updatedLoaded.length < updatedTotalCount,
      retainedStudies: () => null,
    );
  });

  Future<void> pinOffStudy(String modelId) => _runStudyAction(
    modelId,
    () async {
      await _userRepository.updatePreferences(PreferenceAction.pinOff, modelId);
      if (!ref.mounted) return;
      await _refreshAfterMutation();
    },
  );

  void setSorting(StudiesTableColumn sortByColumn, bool ascending) {
    state = state.copyWith(
      retainedStudies: () => state.displayedStudies.asData?.value,
      sortByColumn: sortByColumn,
      sortAscending: ascending,
    );
    final pageKey = _getPageKey(state.studiesFilter);
    // Fire-and-forget: persistence failure should not block UI updates.
    unawaited(
      _userRepository.saveActiveSort(
        page: pageKey,
        sortColumn: sortByColumn.name,
        sortAscending: ascending,
      ),
    );
    unawaited(_resetAndReload());
  }

  /// Resolves the persisted sort for [pageKey] back to typed values, falling
  /// back to [DashboardState] defaults when nothing is stored or when the
  /// stored column name no longer maps to a known [StudiesTableColumn] (e.g.
  /// after an enum rename). When the column falls back, the direction falls
  /// back too — a stored direction is meaningless without its column.
  ({StudiesTableColumn sortByColumn, bool sortAscending}) _resolveActiveSort(
    String pageKey,
  ) {
    const defaultColumn = StudiesTableColumn.createdAt;
    const defaultAscending = false;
    final stored = _userRepository.getActiveSort(pageKey);
    final column = StudiesTableColumn.values.asNameMap()[stored.sortColumn];
    if (column == null) {
      return (sortByColumn: defaultColumn, sortAscending: defaultAscending);
    }
    return (
      sortByColumn: column,
      sortAscending: stored.sortAscending ?? defaultAscending,
    );
  }

  Future<void> filterStudies(String? query) async {
    final newQuery = query ?? '';
    if (newQuery == state.query) return;
    ++_fetchToken;
    state = state.copyWith(
      retainedStudies: () => state.displayedStudies.asData?.value,
      query: newQuery,
      isRefreshing:
          !state.isLoadingInitial && state.displayedStudies.asData != null,
    );
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      unawaited(_resetAndReload());
    });
  }

  bool isSortingActiveForColumn(StudiesTableColumn column) {
    return state.sortByColumn == column;
  }

  bool isSortAscending() {
    return state.sortAscending;
  }

  bool isPinned(Study study) {
    return _userRepository.user.preferences.pinnedStudies.contains(study.id);
  }

  ModelAction _wrapAction(
    ModelAction action,
    Future<void> Function() onExecute,
  ) {
    return ModelAction(
      type: action.type,
      label: action.label,
      icon: action.icon,
      tooltip: action.tooltip,
      confirmation: action.confirmation,
      isAvailable: action.isAvailable,
      isDestructive: action.isDestructive,
      isSeparator: action.isSeparator,
      isHeader: action.isHeader,
      isChecked: action.isChecked,
      showBadge: action.showBadge,
      onExecute: onExecute,
    );
  }

  @override
  List<ModelAction> availableActions(Study model) {
    final pinActions = [
      ModelAction(
        type: StudyActionType.pin,
        label: StudyActionType.pin.string,
        onExecute: () async {
          await pinStudy(model.id);
        },
        isAvailable: !isPinned(model),
      ),
      ModelAction(
        type: StudyActionType.pinoff,
        label: StudyActionType.pinoff.string,
        onExecute: () async {
          await pinOffStudy(model.id);
        },
        isAvailable: isPinned(model),
      ),
    ].where((action) => action.isAvailable).toList();

    final repoActions = _studyRepository
        .availableActions(model)
        .where((action) => action.type != StudyActionType.exportDefinition)
        .toList();

    // Keep rows visible and prevent repeat actions until the refresh finishes.
    final studyActions = repoActions.map((action) {
      final type = action.type as StudyActionType?;
      if (type == StudyActionType.delete ||
          type == StudyActionType.duplicate ||
          type == StudyActionType.duplicateDraft ||
          type == StudyActionType.close) {
        return _wrapAction(
          action,
          () => _runStudyAction(model.id, () async {
            final loadedStudyCountBeforeRefresh = state.loadedStudies.length;
            await action.onExecute();
            if (!ref.mounted) return;
            if (type == StudyActionType.delete) _removeStudyLocally(model.id);
            await _refreshAfterMutation(
              targetLoadedStudyCount: loadedStudyCountBeforeRefresh,
            );
          }),
        );
      }
      return action;
    }).toList();

    return withIcons([...pinActions, ...studyActions], studyActionIcons);
  }
}
