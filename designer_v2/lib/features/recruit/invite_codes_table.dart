import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table_column_header.dart';
import 'package:studyu_designer_v2/features/recruit/enrolled_badge.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

typedef ParticipantCountProvider = int Function(StudyInvite invite);

enum InviteCodesTableColumn() {
  code,
  enrolled,
  interventionA,
  interventionB,
}

class const _InviteCodeTableWidthConfig({
  required final double codeWidth,
  required final double enrolledWidth,
  required final double interventionWidth,
});

class const StudyInvitesTable({
  required final List<StudyInvite> invites,
  required final OnSelectHandler<StudyInvite> onSelect,
  required final ActionsProviderFor<StudyInvite> getInlineActions,
  required final ActionsProviderFor<StudyInvite> getActions,
  required final InterventionProvider getIntervention,
  required final ParticipantCountProvider getParticipantCountForInvite,
  required final InviteCodesSortColumn sortColumn,
  required final bool sortAscending,
  required final void Function(InviteCodesSortColumn column) onSortColumn,
  super.key,
}) extends StatelessWidget {
  static const _tableMinRowHeight = 34.0;
  static const _compactBreakpoint = 640.0;
  static const _narrowBreakpoint = 520.0;
  static const _codeColumnMinWidth = 168.0;
  static const _codeColumnMaxWidth = 256.0;
  static const _codeColumnWidthFactor = 0.3;
  static const _actionColumnWidth = 88.0;
  static const _enrolledColumnWidth = 132.0;
  static const _interventionColumnMinWidth = 96.0;
  static const _headerVerticalPadding = 12.0;
  static const _codeCellSpacing = 8.0;
  static const _copyIconSize = 18.0;
  static const _copyButtonSize = 20.0;
  static const _rowActionSplashRadius = 18.0;
  static const _rowSpacing = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final activeColumns = _visibleColumnsForWidth(constraints.maxWidth);
        final columns = [
          for (final column in activeColumns)
            _buildColumnDefinition(column, constraints.maxWidth, activeColumns),
        ];

        return StandardTable<StudyInvite>(
          items: invites,
          columns: columns,
          trailingActionsColumn: StandardTableColumn(
            label: '',
            columnWidth: const FixedColumnWidth(_actionColumnWidth),
          ),
          headerRowBuilder: (context, tableColumns) =>
              _buildHeaderRow(context, tableColumns, activeColumns),
          onSelectItem: onSelect,
          buildCellsAt: (context, item, rowIdx, states) =>
              _buildRow(context, item, states, activeColumns),
          trailingActionsAt: (item, _) => getActions(item),
          minRowHeight: _tableMinRowHeight,
          rowSpacing: _rowSpacing,
          rowStyle: StandardTableStyle.flat,
          tableWrapper: (table) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
          ),
        );
      },
    );
  }

  List<InviteCodesTableColumn> _visibleColumnsForWidth(double width) {
    final columns = [
      InviteCodesTableColumn.code,
      InviteCodesTableColumn.enrolled,
      InviteCodesTableColumn.interventionA,
      InviteCodesTableColumn.interventionB,
    ];

    if (width < _compactBreakpoint) {
      columns.remove(InviteCodesTableColumn.interventionB);
    }
    if (width < _narrowBreakpoint) {
      columns.remove(InviteCodesTableColumn.interventionA);
    }
    return columns;
  }

  StandardTableColumn _buildColumnDefinition(
    InviteCodesTableColumn column,
    double tableWidth,
    List<InviteCodesTableColumn> activeColumns,
  ) {
    final widthConfig = _columnWidthConfig(tableWidth, activeColumns);
    switch (column) {
      case InviteCodesTableColumn.code:
        return StandardTableColumn(
          label: tr.code_list_header_code,
          columnWidth: FixedColumnWidth(widthConfig.codeWidth),
          sortable: true,
        );
      case InviteCodesTableColumn.enrolled:
        return StandardTableColumn(
          label: tr.studies_list_header_participants_enrolled,
          columnWidth: FixedColumnWidth(widthConfig.enrolledWidth),
          sortable: true,
        );
      case InviteCodesTableColumn.interventionA:
        return StandardTableColumn(
          label: tr.form_field_preconfigured_schedule_intervention_a,
          columnWidth: FixedColumnWidth(widthConfig.interventionWidth),
        );
      case InviteCodesTableColumn.interventionB:
        return StandardTableColumn(
          label: tr.form_field_preconfigured_schedule_intervention_b,
          columnWidth: FixedColumnWidth(widthConfig.interventionWidth),
        );
    }
  }

  _InviteCodeTableWidthConfig _columnWidthConfig(
    double tableWidth,
    List<InviteCodesTableColumn> activeColumns,
  ) {
    final interventionColumnCount = activeColumns
        .where(
          (column) =>
              column == InviteCodesTableColumn.interventionA ||
              column == InviteCodesTableColumn.interventionB,
        )
        .length;

    final codeWidth = (tableWidth * _codeColumnWidthFactor).clamp(
      _codeColumnMinWidth,
      _codeColumnMaxWidth,
    );
    const enrolledWidth = _enrolledColumnWidth;

    final availableInterventionWidth =
        tableWidth - codeWidth - enrolledWidth - _actionColumnWidth;
    final interventionWidth = interventionColumnCount == 0
        ? 0.0
        : (availableInterventionWidth / interventionColumnCount).clamp(
            _interventionColumnMinWidth,
            double.infinity,
          );

    return _InviteCodeTableWidthConfig(
      codeWidth: codeWidth,
      enrolledWidth: enrolledWidth,
      interventionWidth: interventionWidth,
    );
  }

  TableRow _buildHeaderRow(
    BuildContext context,
    List<StandardTableColumn> columns,
    List<InviteCodesTableColumn> activeColumns,
  ) {
    final headerWidgets = <Widget>[
      for (var i = 0; i < activeColumns.length; i++)
        _buildHeaderCell(
          context,
          activeColumns[i],
          columns[i],
          sortTarget: _sortTargetForColumn(activeColumns[i]),
        ),
      _buildHeaderCell(context, null, columns.last, labelOverride: ''),
    ];

    return TableRow(children: headerWidgets);
  }

  InviteCodesSortColumn? _sortTargetForColumn(InviteCodesTableColumn column) {
    switch (column) {
      case InviteCodesTableColumn.code:
        return InviteCodesSortColumn.code;
      case InviteCodesTableColumn.enrolled:
        return InviteCodesSortColumn.enrolled;
      case InviteCodesTableColumn.interventionA:
      case InviteCodesTableColumn.interventionB:
        return null;
    }
  }

  Widget _buildHeaderCell(
    BuildContext context,
    InviteCodesTableColumn? tableColumn,
    StandardTableColumn column, {
    InviteCodesSortColumn? sortTarget,
    String? labelOverride,
  }) {
    final isSortable = sortTarget != null;
    final isSortingActive = isSortable && sortColumn == sortTarget;
    final effectiveAscending = !isSortingActive || sortAscending;
    final padding = _headerPaddingForColumn(tableColumn);
    return Padding(
      padding: padding,
      child: StudiesTableColumnHeader(
        labelOverride ?? column.label,
        sortable: isSortable,
        sortingActive: isSortingActive,
        sortAscending: effectiveAscending,
        onSort: isSortable ? () => onSortColumn(sortTarget) : null,
      ),
    );
  }

  EdgeInsets _headerPaddingForColumn(InviteCodesTableColumn? column) {
    return switch (column) {
      InviteCodesTableColumn.code => const EdgeInsets.fromLTRB(
        20,
        _headerVerticalPadding,
        8,
        _headerVerticalPadding,
      ),
      InviteCodesTableColumn.enrolled => const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: _headerVerticalPadding,
      ),
      InviteCodesTableColumn.interventionA ||
      InviteCodesTableColumn.interventionB => const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: _headerVerticalPadding,
      ),
      null => const EdgeInsets.fromLTRB(
        8,
        _headerVerticalPadding,
        20,
        _headerVerticalPadding,
      ),
    };
  }

  List<Widget> _buildRow(
    BuildContext context,
    StudyInvite item,
    Set<WidgetState> states,
    List<InviteCodesTableColumn> activeColumns,
  ) {
    final theme = Theme.of(context);
    final defaultInterventionTextStyle = theme.textTheme.bodyLarge?.copyWith(
      color: ThemeConfig.bodyTextMuted(theme).color,
    );

    Intervention? interventionA;
    Intervention? interventionB;
    final preselectedInterventionIds = item.preselectedInterventionIds;

    if (preselectedInterventionIds != null &&
        preselectedInterventionIds.isNotEmpty) {
      interventionA = getIntervention(preselectedInterventionIds[0]);
      if (preselectedInterventionIds.length > 1) {
        interventionB = getIntervention(preselectedInterventionIds[1]);
      }
    }

    Widget buildInterventionCell(Intervention? intervention) {
      final label =
          intervention?.name ??
          tr.form_field_preconfigured_schedule_intervention_default;
      final style = intervention != null ? null : defaultInterventionTextStyle;
      return Tooltip(
        message: label,
        child: Text(
          label,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      );
    }

    final participantCount = getParticipantCountForInvite(item);
    ModelAction? copyInviteLinkAction;
    for (final action in getInlineActions(item)) {
      if (action.type == ModelActionType.copyLink) {
        copyInviteLinkAction = action;
        break;
      }
    }

    Widget buildCell(InviteCodesTableColumn column) {
      switch (column) {
        case InviteCodesTableColumn.code:
          return Tooltip(
            message: item.code,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    item.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (copyInviteLinkAction != null) ...[
                  const SizedBox(width: _codeCellSpacing),
                  Tooltip(
                    message: copyInviteLinkAction.label,
                    child: IconButton(
                      onPressed: () => copyInviteLinkAction!.execute(context),
                      constraints: const BoxConstraints.tightFor(
                        width: _copyButtonSize,
                        height: _copyButtonSize,
                      ),
                      padding: EdgeInsets.zero,
                      splashRadius: _rowActionSplashRadius,
                      icon: Icon(
                        copyInviteLinkAction.icon,
                        size: _copyIconSize,
                        color: ThemeConfig.bodyTextMuted(theme).color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        case InviteCodesTableColumn.enrolled:
          return EnrolledBadge(enrolledCount: participantCount);
        case InviteCodesTableColumn.interventionA:
          return buildInterventionCell(interventionA);
        case InviteCodesTableColumn.interventionB:
          return buildInterventionCell(interventionB);
      }
    }

    return [for (final column in activeColumns) buildCell(column)];
  }
}
