import 'dart:math';

import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table_column_header.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table_item.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/study_repository_interface.dart';

export 'package:studyu_designer_v2/repositories/study_repository_interface.dart'
    show StudiesTableColumn;

class StudiesTableColumnSize._(
  final int? flex,
  final double? width,
  final bool collapsed,
) {
  new fixedWidth(double width) : this._(null, width, false);
  new flexWidth(int flex) : this._(flex, null, false);
  new collapsed() : this._(null, null, true);

  Widget createContainer({required Widget child, double? height}) {
    if (collapsed) {
      return const SizedBox.shrink();
    }
    if (flex != null) {
      return Expanded(flex: flex!, child: child);
    }

    return SizedBox(width: width, height: height, child: child);
  }
}

class const StudiesTable({
  required final List<Study> studies,
  required final OnSelectHandler<Study> onSelect,
  required final ActionsProviderFor<Study> getActions,
  required final Widget emptyWidget,
  required final Iterable<String> pinnedStudies,
  required final DashboardController dashboardController,
  final Set<String> pendingStudyIds = const {},
  final bool isLoadingMore = false,
  final bool hasMore = false,
  final bool advancedFilterUnsupported = false,
  final bool showCreateStudyLink = false,
  final Object? loadError,
  final VoidCallback? onRetry,
  final Future<void> Function()? onLoadMore,
  final double itemHeight = 60.0,
  final double itemPadding = 10.0,
  final double rowSpacing = 9.0,
  final double columnSpacing = 10.0,
  final double compactWidthThreshold = 1000.0,
  final double superCompactWidthThreshold = 600.0,
  final double compactStatTitleThreshold = 1100.0,
  super.key,
}) extends StatelessWidget {
  static const _loadMorePrefetchThreshold = 5;

  @override
  Widget build(BuildContext context) {
    if (advancedFilterUnsupported) {
      return _AdvancedFilterUnsupportedNotice(onRetry: onRetry);
    }
    if (studies.isEmpty && loadError != null) {
      return _LoadErrorNotice(error: loadError!, onRetry: onRetry);
    }
    if (studies.isEmpty) {
      return emptyWidget;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < compactWidthThreshold;
        final isSuperCompact =
            constraints.maxWidth < superCompactWidthThreshold;
        final isCompactStatTitle =
            constraints.maxWidth < compactStatTitleThreshold;
        // Calculate the minimum stat column width
        final double enrolledColumnWidth =
            (isCompactStatTitle
                ? "Enrolled".length
                : tr.studies_list_header_participants_enrolled.length) *
            10;
        final double activeColumnWidth =
            (isCompactStatTitle
                ? "Active".length
                : tr.studies_list_header_participants_active.length) *
            10;
        final double completedColumnWidth =
            (isCompactStatTitle
                ? "Completed".length
                : tr.studies_list_header_participants_completed.length) *
            10;

        // Calculate the minimum status column width
        final maxStatusLength = [
          tr.study_status_draft,
          tr.study_status_running,
          tr.study_status_closed,
          tr.studies_list_header_status,
        ].map((label) => label.length).reduce(max);
        final double statusColumnWidth = maxStatusLength * 11.5;

        // Calculate the minimum participation column width
        final int maxParticipationLength = isCompact
            ? "Invite-only".length
            : tr.participation_invite_who.length;
        final double participationColumnWidth =
            20 + (maxParticipationLength * 7.5);

        // Set column definitions
        final columnDefinitionsMap = {
          StudiesTableColumn.pin: StudiesTableColumnSize.fixedWidth(itemHeight),
          StudiesTableColumn.title: StudiesTableColumnSize.flexWidth(32),
          StudiesTableColumn.status: StudiesTableColumnSize.fixedWidth(
            statusColumnWidth,
          ),
          StudiesTableColumn.participation: StudiesTableColumnSize.fixedWidth(
            participationColumnWidth,
          ),
          StudiesTableColumn.createdAt: isSuperCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.flexWidth(10),
          StudiesTableColumn.enrolled: isCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.fixedWidth(enrolledColumnWidth),
          StudiesTableColumn.active: isCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.fixedWidth(activeColumnWidth),
          StudiesTableColumn.completed: isCompact
              ? StudiesTableColumnSize.collapsed()
              : StudiesTableColumnSize.fixedWidth(completedColumnWidth),
          StudiesTableColumn.action: StudiesTableColumnSize.fixedWidth(
            itemHeight,
          ),
        };
        final columnDefinitions = columnDefinitionsMap.entries.toList();

        return Column(
          children: [
            SizedBox(
              height: itemHeight,
              child: Row(
                children: [
                  columnDefinitions[0].value.createContainer(
                    child: _buildColumnHeader(columnDefinitions[0].key),
                  ),
                  SizedBox(
                    width: columnDefinitions[0].value.collapsed
                        ? 0
                        : columnSpacing,
                  ),
                  columnDefinitions[1].value.createContainer(
                    child: _buildColumnHeader(columnDefinitions[1].key),
                  ),
                  SizedBox(
                    width: columnDefinitions[1].value.collapsed
                        ? 0
                        : columnSpacing,
                  ),
                  columnDefinitions[2].value.createContainer(
                    child: _buildColumnHeader(columnDefinitions[2].key),
                  ),
                  SizedBox(
                    width: columnDefinitions[2].value.collapsed
                        ? 0
                        : columnSpacing,
                  ),
                  columnDefinitions[3].value.createContainer(
                    child: _buildColumnHeader(columnDefinitions[3].key),
                  ),
                  SizedBox(
                    width: columnDefinitions[3].value.collapsed
                        ? 0
                        : columnSpacing,
                  ),
                  columnDefinitions[4].value.createContainer(
                    child: _buildColumnHeader(columnDefinitions[4].key),
                  ),
                  SizedBox(
                    width: columnDefinitions[4].value.collapsed
                        ? 0
                        : columnSpacing,
                  ),
                  columnDefinitions[5].value.createContainer(
                    child: _buildColumnHeader(columnDefinitions[5].key),
                  ),
                  SizedBox(
                    width: columnDefinitions[5].value.collapsed
                        ? 0
                        : columnSpacing,
                  ),
                  columnDefinitions[6].value.createContainer(
                    child: _buildColumnHeader(columnDefinitions[6].key),
                  ),
                  SizedBox(
                    width: columnDefinitions[6].value.collapsed
                        ? 0
                        : columnSpacing,
                  ),
                  columnDefinitions[7].value.createContainer(
                    child: _buildColumnHeader(columnDefinitions[7].key),
                  ),
                  SizedBox(
                    width: columnDefinitions[7].value.collapsed
                        ? 0
                        : columnSpacing,
                  ),
                  columnDefinitions[8].value.createContainer(
                    child: _buildColumnHeader(columnDefinitions[8].key),
                  ),
                  SizedBox(
                    width: columnDefinitions[8].value.collapsed
                        ? 0
                        : columnSpacing,
                  ),
                ],
              ),
            ),
            SizedBox(height: rowSpacing),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final needsScrolling =
                      studies.length * (itemHeight + rowSpacing) >
                      constraints.maxHeight;
                  final showsFooter = _showsFooter(needsScrolling);

                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: true),
                    child: ListView.builder(
                      key: const ValueKey('studies_table_rows'),
                      prototypeItem: StudiesTableItem.prototype(
                        columnSizes: columnDefinitionsMap.values.toList(),
                        itemHeight: itemHeight,
                        itemPadding: itemPadding,
                        rowSpacing: rowSpacing,
                        columnSpacing: columnSpacing,
                      ),
                      itemCount: studies.length + (showsFooter ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= studies.length) {
                          return _buildFooter(context);
                        }

                        if (hasMore &&
                            !isLoadingMore &&
                            index >=
                                studies.length - _loadMorePrefetchThreshold) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            onLoadMore?.call();
                          });
                        }

                        final item = studies[index];
                        return RepaintBoundary(
                          child: StudiesTableItem(
                            key: ValueKey('study_row_${item.id}'),
                            study: item,
                            columnSizes: columnDefinitionsMap.values.toList(),
                            actions: getActions(item),
                            isPinned: pinnedStudies.contains(item.id),
                            isBusy: pendingStudyIds.contains(item.id),
                            itemHeight: itemHeight,
                            itemPadding: itemPadding,
                            rowSpacing: rowSpacing,
                            columnSpacing: columnSpacing,
                            onPinnedChanged: (study, pinned) {
                              pinnedStudies.contains(item.id)
                                  ? dashboardController.pinOffStudy(item.id)
                                  : dashboardController.pinStudy(item.id);
                            },
                            onTap: (study) => onSelect.call(study),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColumnHeader(StudiesTableColumn column) {
    final String title;
    switch (column) {
      case StudiesTableColumn.title:
        title = tr.studies_list_header_title;
      case StudiesTableColumn.status:
        title = tr.studies_list_header_status;
      case StudiesTableColumn.participation:
        title = tr.studies_list_header_participation;
      case StudiesTableColumn.createdAt:
        title = tr.studies_list_header_created_at;
      case StudiesTableColumn.enrolled:
        title = tr.studies_list_header_participants_enrolled;
      case StudiesTableColumn.active:
        title = tr.studies_list_header_participants_active;
      case StudiesTableColumn.completed:
        title = tr.studies_list_header_participants_completed;
      case StudiesTableColumn.pin:
      case StudiesTableColumn.action:
        title = '';
    }

    final sortAscending = dashboardController.isSortAscending;
    final sortable =
        !(column == StudiesTableColumn.pin ||
            column == StudiesTableColumn.action);
    final sortingActive = dashboardController.isSortingActiveForColumn(column);

    return StudiesTableColumnHeader(
      title,
      sortable: sortable,
      sortingActive: sortingActive,
      sortAscending: sortAscending(),
      center:
          column != StudiesTableColumn.title &&
          column != StudiesTableColumn.pin,
      onSort: sortable
          ? () {
              dashboardController.setSorting(
                column,
                sortingActive ? !sortAscending() : sortAscending(),
              );
            }
          : null,
    );
  }

  bool _showsFooter(bool needsScrolling) =>
      isLoadingMore || loadError != null || (!hasMore && needsScrolling);

  Widget _buildFooter(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (loadError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(tr.action_button_retry),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final footerStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.hintColor,
    );

    return Padding(
      padding: EdgeInsets.only(top: rowSpacing, bottom: rowSpacing),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              showCreateStudyLink
                  ? tr.studies_end_of_list_public
                  : tr.studies_end_of_list,
              style: footerStyle,
            ),
            if (showCreateStudyLink)
              Hyperlink(
                text: tr.studies_end_of_list_create,
                onClick: dashboardController.onClickNewStudy,
                style: footerStyle?.copyWith(
                  decoration: TextDecoration.underline,
                ),
                hoverStyle: const TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class const _AdvancedFilterUnsupportedNotice({
  required final VoidCallback? onRetry,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 8),
            Text(
              tr.studies_filter_server_side_unsupported,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onRetry,
                child: Text(tr.filter_button_clear),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class const _LoadErrorNotice({
  required final Object error,
  required final VoidCallback? onRetry,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(height: 8),
            Text(
              tr.studies_load_failed,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(tr.action_button_retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
