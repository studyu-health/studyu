import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

void main() {
  testWidgets('trailing popup actions do not trigger row selection', (
    tester,
  ) async {
    var selectedItemCount = 0;
    var actionExecutionCount = 0;
    final columns = [StandardTableColumn(label: 'code')];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StandardTable<String>(
            items: const ['invite-1'],
            columns: columns,
            onSelectItem: (_) => selectedItemCount++,
            buildCellsAt: (_, item, rowIdx, states) => [Text(item)],
            trailingActionsAt: (_, rowIdx) => [
              ModelAction(
                type: ModelActionType.delete,
                label: 'Delete',
                onExecute: () => actionExecutionCount++,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(actionExecutionCount, 1);
    expect(selectedItemCount, 0);
  });

  testWidgets('non-trailing cells still trigger row selection', (tester) async {
    var selectedValue = '';
    final columns = [StandardTableColumn(label: 'code')];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StandardTable<String>(
            items: const ['invite-1'],
            columns: columns,
            onSelectItem: (item) => selectedValue = item,
            buildCellsAt: (_, item, rowIdx, states) => [Text(item)],
            trailingActionsAt: (_, rowIdx) => [
              ModelAction(
                type: ModelActionType.delete,
                label: 'Delete',
                onExecute: () {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('invite-1'));
    await tester.pumpAndSettle();

    expect(selectedValue, 'invite-1');
  });
}
