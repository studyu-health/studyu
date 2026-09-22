import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
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
}
