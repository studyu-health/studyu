// StudiesTable imports browser-only dashboard dependencies.
// Run with: `flutter test --platform chrome test/features/dashboard/studies_table_test.dart`.
@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

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

  testWidgets('copied study stays labeled and opens with Enter', (
    tester,
  ) async {
    final copiedStudy = _study(1);
    Study? selectedStudy;
    final otherFocus = FocusNode();
    addTearDown(otherFocus.dispose);
    final highlighted = ValueNotifier(true);
    addTearDown(highlighted.dispose);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<bool>(
          valueListenable: highlighted,
          builder: (context, isHighlighted, _) => Scaffold(
            bottomNavigationBar: TextButton(
              focusNode: otherFocus,
              onPressed: () {},
              child: const Text('Other action'),
            ),
            body: StudiesTable(
              studies: [copiedStudy],
              onSelect: (study) {
                selectedStudy = study;
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) =>
                        const Scaffold(body: Text('Copied study opened')),
                  ),
                );
              },
              getActions: (_) => const [],
              emptyWidget: const SizedBox.shrink(),
              pinnedStudies: const [],
              dashboardController: _DashboardController(),
              advancedFilterUnsupported: true,
              copiedStudyId: copiedStudy.id,
              highlightedStudyId: isHighlighted ? copiedStudy.id : null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(AppLocalizationsEn().studies_filter_server_side_unsupported),
      findsOneWidget,
    );
    final row = find.byKey(ValueKey('study_row_ink_${copiedStudy.id}'));
    final cue = find.text('Copied draft');
    expect(cue, findsOneWidget);
    expect(
      find.semantics.byPredicate(
        (node) =>
            node.label.contains('Copied draft') &&
            node.getSemanticsData().hasAction(SemanticsAction.tap),
      ),
      findsOneWidget,
    );
    expect(tester.getSize(row).height, 60);

    final cueSemantics = find.semantics.byPredicate(
      (node) => node.label.contains('Copied draft'),
    );
    expect(cueSemantics, findsOneWidget);

    highlighted.value = false;
    await tester.pump();
    expect(cue, findsOneWidget);
    otherFocus.requestFocus();
    await tester.pumpAndSettle();
    expect(
      find.semantics.byPredicate(
        (node) =>
            node.label.contains('Copied draft') &&
            node.getSemanticsData().flagsCollection.isFocused.toString() ==
                'Tristate.isTrue',
      ),
      findsNothing,
    );
    tester.widget<InkWell>(row).focusNode!.requestFocus();
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selectedStudy, copiedStudy);
    expect(find.text('Copied study opened'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('new copied draft appears when my studies was scrolled down', (
    tester,
  ) async {
    final copied = ValueNotifier<Study?>(null);
    addTearDown(copied.dispose);
    final rows = List.generate(40, _study);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<Study?>(
            valueListenable: copied,
            builder: (context, copy, _) => StudiesTable(
              studies: [?copy, ...rows],
              copiedStudyId: copy?.id,
              highlightedStudyId: copy?.id,
              onSelect: (_) {},
              getActions: (_) => const [],
              emptyWidget: const SizedBox.shrink(),
              pinnedStudies: const [],
              dashboardController: _DashboardController(),
            ),
          ),
        ),
      ),
    );
    await tester.drag(
      find.byKey(const ValueKey('studies_table_rows')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    expect(find.text('Study 0'), findsNothing);
    copied.value = _study(99);
    await tester.pumpAndSettle();
    expect(find.text('Study 99'), findsOneWidget);
    expect(find.text('Copied draft'), findsOneWidget);
    expect(tester.getRect(find.text('Study 99')).top, inInclusiveRange(0, 150));
  });
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

class _DashboardController() extends DashboardController {
  @override
  bool isSortAscending() => false;

  @override
  bool isSortingActiveForColumn(StudiesTableColumn column) => false;
}
