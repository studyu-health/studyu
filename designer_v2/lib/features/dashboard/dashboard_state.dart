import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_evaluator.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/study_repository_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class const DashboardState({
  /// Paginated studies fetched so far (excludes pinned, which render above).
  final List<Study> loadedStudies = const [],

  /// Pinned studies fetched separately, always shown above the paginated list.
  final List<Study> pinnedStudiesList = const [],

  /// Total number of studies that match the current query (from PostgREST
  /// exact count). Used to know when [hasMore] should flip to false.
  final int totalCount = 0,

  /// Total number of studies available on the current page before search or
  /// additional filter refinements are applied. Excludes pinned rows, which
  /// are added back via derived getters.
  final int pageTotalCount = 0,

  /// True while the first page (and pinned set) is loading.
  final bool isLoadingInitial = true,

  /// True while a "load more" page is in flight.
  final bool isLoadingMore = false,

  /// True while pinned studies are being refreshed.
  final bool isLoadingPinned = false,

  /// True while existing results refresh in the background.
  final bool isRefreshing = false,

  /// Visible rows retained until replacement results arrive, including on failure.
  final List<Study>? retainedStudies,

  /// Study actions remain disabled until their requests and refreshes finish.
  final Set<String> pendingStudyIds = const {},

  /// Whether more pages remain on the server.
  final bool hasMore = true,

  /// Last error from a fetch attempt, or null.
  final Object? loadError,

  /// Currently selected filter preset (e.g. Owned, Shared, Public)
  /// Used for UI highlighting. If null, a custom filter is active.
  final StudiesFilter? studiesFilter = defaultFilter,

  /// The actual filter logic to be applied.
  /// If null, it falls back to the [studiesFilter] logic.
  final FilterGroup? activeFilter,

  /// True if the current [activeFilter] contains a condition that cannot be
  /// expressed in PostgREST. When true the
  /// list is empty and the UI should show a "filter not supported" message
  /// rather than silently dropping rows.
  final bool advancedFilterUnsupported = false,
  final String query = '',

  /// Currently selected sort column applied server-side.
  final StudiesTableColumn sortByColumn = StudiesTableColumn.createdAt,

  /// Currently selected sort direction applied server-side.
  final bool sortAscending = false,

  /// List of saved custom filters
  final List<SavedFilter> savedFilters = const [],

  /// The ID of the currently selected saved filter preset
  final String? selectedSavedFilterId,

  /// Currently authenticated user (used for filtering studies)
  required final User currentUser,

  /// Search controller for managing search functionality
  required final SearchController searchController,
}) extends Equatable {
  static const defaultFilter = StudiesFilter.owned;
  static const pageSize = 20;

  /// Studies actually rendered: pinned first, then the paginated list.
  /// Wrapped in [AsyncValue] for backwards-compatible UI scaffolding that
  /// expects a loading/data state for the initial fetch. Errors stay in
  /// [loadError] and are rendered by the studies table's error notices, so
  /// they keep the unsupported-filter and retry affordances even with an
  /// empty list.
  AsyncValue<List<Study>> get displayedStudies {
    if (retainedStudies != null) return AsyncValue.data(retainedStudies!);

    final pinnedStudies = pinnedStudiesList
        .where(_matchesPagePreset)
        .where(_matchesSearchQuery)
        .where(_matchesActiveFilter)
        .toList();

    if (isLoadingInitial && loadedStudies.isEmpty && pinnedStudies.isEmpty) {
      return const AsyncValue.loading();
    }
    return AsyncValue.data([
      ...pinnedStudies,
      ...loadedStudies.where(_matchesSearchQuery),
    ]);
  }

  DashboardState copyWith({
    List<Study> Function()? loadedStudies,
    List<Study> Function()? pinnedStudiesList,
    int? totalCount,
    int? pageTotalCount,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? isLoadingPinned,
    bool? isRefreshing,
    List<Study>? Function()? retainedStudies,
    Set<String>? pendingStudyIds,
    bool? hasMore,
    Object? Function()? loadError,
    bool? advancedFilterUnsupported,
    StudiesFilter? Function()? studiesFilter,
    FilterGroup? Function()? activeFilter,
    List<SavedFilter> Function()? savedFilters,
    User Function()? currentUser,
    String? query,
    StudiesTableColumn? sortByColumn,
    bool? sortAscending,
    SearchController? searchController,
    String? Function()? selectedSavedFilterId,
  }) {
    return DashboardState(
      loadedStudies: loadedStudies != null
          ? loadedStudies()
          : this.loadedStudies,
      pinnedStudiesList: pinnedStudiesList != null
          ? pinnedStudiesList()
          : this.pinnedStudiesList,
      totalCount: totalCount ?? this.totalCount,
      pageTotalCount: pageTotalCount ?? this.pageTotalCount,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingPinned: isLoadingPinned ?? this.isLoadingPinned,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      retainedStudies: retainedStudies != null
          ? retainedStudies()
          : this.retainedStudies,
      pendingStudyIds: pendingStudyIds ?? this.pendingStudyIds,
      hasMore: hasMore ?? this.hasMore,
      loadError: loadError != null ? loadError() : this.loadError,
      advancedFilterUnsupported:
          advancedFilterUnsupported ?? this.advancedFilterUnsupported,
      studiesFilter: studiesFilter != null
          ? studiesFilter()
          : this.studiesFilter,
      activeFilter: activeFilter != null ? activeFilter() : this.activeFilter,
      savedFilters: savedFilters != null ? savedFilters() : this.savedFilters,
      currentUser: currentUser != null ? currentUser() : this.currentUser,
      query: query ?? this.query,
      sortByColumn: sortByColumn ?? this.sortByColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      searchController: searchController ?? this.searchController,
      selectedSavedFilterId: selectedSavedFilterId != null
          ? selectedSavedFilterId()
          : this.selectedSavedFilterId,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [
    loadedStudies,
    pinnedStudiesList,
    totalCount,
    pageTotalCount,
    isLoadingInitial,
    isLoadingMore,
    isLoadingPinned,
    isRefreshing,
    retainedStudies,
    pendingStudyIds,
    hasMore,
    loadError,
    advancedFilterUnsupported,
    studiesFilter,
    activeFilter,
    savedFilters,
    query,
    sortByColumn,
    sortAscending,
    selectedSavedFilterId,
  ];
}

extension DashboardStateSafeViewProps on DashboardState {
  String get _trimmedQuery => query.trim().toLowerCase();

  bool _matchesPagePreset(Study study) {
    final preset = studiesFilter ?? DashboardState.defaultFilter;
    return preset.apply(studies: [study], user: currentUser).isNotEmpty;
  }

  bool _matchesSearchQuery(Study study) {
    if (_trimmedQuery.isEmpty) return true;
    return (study.title ?? '').toLowerCase().contains(_trimmedQuery);
  }

  bool _matchesActiveFilter(Study study) {
    if (activeFilter == null || activeFilter!.children.isEmpty) return true;
    return FilterEvaluator.evaluate(activeFilter!, study, currentUser);
  }

  int get pagePinnedStudyCount =>
      pinnedStudiesList.where(_matchesPagePreset).length;

  int get filteredPinnedStudyCount => pinnedStudiesList
      .where(_matchesPagePreset)
      .where(_matchesSearchQuery)
      .where(_matchesActiveFilter)
      .length;

  int get filteredStudyCount => totalCount + filteredPinnedStudyCount;

  int get visibleStudyCount => filteredPinnedStudyCount + loadedStudies.length;

  int get displayTotalStudyCount => pageTotalCount + pagePinnedStudyCount;

  bool get hasAppliedFilter =>
      activeFilter != null && activeFilter!.children.isNotEmpty;

  bool get hasActiveRefinement => hasAppliedFilter || _trimmedQuery.isNotEmpty;

  String get visibleListTitle {
    switch (studiesFilter) {
      case StudiesFilter.public:
        return tr.navlink_public_studies;
      case StudiesFilter.owned:
        return tr.navlink_my_studies;
      case StudiesFilter.shared:
        return tr.navlink_shared_studies;
      case StudiesFilter.all:
        return tr.navlink_all_studies;
      case null:
        return tr.navlink_my_studies;
    }
  }
}
