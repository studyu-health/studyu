// StudiesTable imports browser-only dashboard dependencies.
// Run with: `flutter test --platform chrome test/features/dashboard/studies_table_test.dart`.
@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class _DashboardController() extends DashboardController {
  @override
  bool isSortAscending() => false;

  @override
  bool isSortingActiveForColumn(StudiesTableColumn column) => false;
}

Study _study(int index) {
  return Study.withId('study-$index')
    ..title = 'Study $index'
    ..status = StudyStatus.draft
    ..participation = Participation.invite
    ..createdAt = DateTime(2024)
    ..participantCount = 0
    ..activeSubjectCount = 0
    ..endedCount = 0;
}

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('loads more studies when scrolling near the end', (tester) async {
    var loadMoreCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StudiesTable(
            studies: List.generate(20, _study),
            onSelect: (_) {},
            getActions: (_) => const [],
            emptyWidget: const SizedBox.shrink(),
            pinnedStudies: const [],
            dashboardController: _DashboardController(),
            hasMore: true,
            onLoadMore: () async => loadMoreCalls++,
          ),
        ),
      ),
    );

    expect(loadMoreCalls, 0);

    await tester.drag(
      find.byKey(const ValueKey('studies_table_rows')),
      const Offset(0, -1000),
    );
    await tester.pump();

    expect(loadMoreCalls, greaterThan(0));
  });
}
