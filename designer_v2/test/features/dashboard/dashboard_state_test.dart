import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class _MockUser(@override final String id)
    extends Mock
    implements
        // ignore: avoid_implementing_value_types
        supabase.User;

void main() {
  test('dashboard search is case-insensitive', () {
    final study = Study('study-id', 'owner-id')..title = 'Sleep Study';
    final state = DashboardState(
      loadedStudies: [study],
      isLoadingInitial: false,
      currentUser: _MockUser('owner-id'),
      searchController: SearchController(),
      query: 'SLEEP',
    );

    expect(state.displayedStudies.value, [study]);
  });

  test(
    'copied draft is separate, deduplicated, and counted outside filters',
    () {
      final copy = Study('copy', 'owner-id')
        ..title = 'Copied study'
        ..status = StudyStatus.draft;
      final other = Study('other', 'owner-id')
        ..title = 'Running study'
        ..status = StudyStatus.running;
      final state = DashboardState(
        copiedStudy: copy,
        loadedStudies: [other],
        pinnedStudiesList: [copy],
        totalCount: 1,
        pageTotalCount: 1,
        isLoadingInitial: false,
        currentUser: _MockUser('owner-id'),
        searchController: SearchController(),
        activeFilter: FilterGroup(
          children: [
            FilterCondition(
              property: StudyProperty.status,
              operator: FilterOperator.equals,
              value: StudyStatus.running.name,
            ),
          ],
        ),
      );
      expect(state.displayedStudies.requireValue, [copy, other]);
      expect(state.filteredStudyCount, 1);
      expect(state.displayTotalStudyCount, 2);
      expect(state.visibleStudyCount, 2);
      expect(
        state
            .copyWith(isLoadingInitial: true, loadedStudies: () => [])
            .displayedStudies
            .requireValue,
        [copy],
      );
    },
  );
}
