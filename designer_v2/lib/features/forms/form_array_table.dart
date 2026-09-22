import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';

typedef FormArrayTableRowLabelProvider<T> = String Function(T item);
typedef WidgetBuilderAt<T> = Widget Function(
  BuildContext context,
  T item,
  int rowIdx,
);

class const FormArrayTable<T>({
  required final AbstractControl control,
  required final List<T> items,
  required final OnSelectHandler<T> onSelectItem,
  required final ActionsProviderAt<T> getActionsAt,
  final VoidCallback? onNewItem,
  required final String onNewItemLabel,
  required final FormArrayTableRowLabelProvider<T> rowTitle,
  final WidgetBuilderAt<T>? rowPrefix,
  final WidgetBuilderAt<T>? rowSuffix,
  final Widget? leadingWidget,
  final String? sectionTitle,
  final bool? sectionTitleDivider = true,
  final String? sectionDescription,
  final IconData? emptyIcon,
  final String? emptyTitle,
  final String? emptyDescription,
  final EdgeInsets? itemsSectionPadding = const EdgeInsets.symmetric(
    vertical: 8.0,
  ),
  final bool hideLeadingTrailingWhenEmpty = false,
  super.key,
}) extends StatelessWidget {
  this
    : assert(
        sectionTitle == null || leadingWidget == null,
        "Cannot specify both sectionTitle and leadingWidget",
      );

  static final List<StandardTableColumn> columns = [
    StandardTableColumn(
      label: '', // don't care (showTableHeader=false),),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hasEmptyWidget =
        emptyIcon != null || emptyTitle != null || emptyDescription != null;
    final isSection =
        sectionTitle != null ||
        sectionTitleDivider != null ||
        sectionDescription != null;

    const leadingWidgetsSpacing = 4.0;

    final Widget leading = Column(
      children: [
        if (leadingWidget != null) leadingWidget! else const SizedBox.shrink(),
        if (sectionTitle != null && leadingWidget != null)
          const SizedBox(height: leadingWidgetsSpacing)
        else
          const SizedBox.shrink(),
        if (sectionTitle != null)
          FormSectionHeader(title: sectionTitle!, divider: false)
        else
          const SizedBox.shrink(),
        if (sectionTitleDivider == true &&
            (sectionTitle != null || leadingWidget != null))
          const Divider()
        else
          const SizedBox.shrink(),
        if (sectionDescription != null &&
            (sectionTitle != null || leadingWidget != null))
          const SizedBox(height: leadingWidgetsSpacing)
        else
          const SizedBox.shrink(),
        if (sectionDescription != null)
          TextParagraph(text: sectionDescription)
        else
          const SizedBox.shrink(),
      ],
    );

    return StandardTable<T>(
      items: items,
      columns: columns,
      onSelectItem: onSelectItem,
      buildCellsAt: _buildRow,
      trailingActionsAt: getActionsAt,
      rowSpacing: 5.0,
      minRowHeight: 40.0,
      showTableHeader: false,
      tableWrapper: (table) => Padding(
        padding: (items.isNotEmpty && itemsSectionPadding != null)
            ? itemsSectionPadding!
            : EdgeInsets.zero,
        child: table,
      ),
      leadingWidget: leading,
      trailingWidget: ReactiveStatusListenableBuilder(
        formControl: control,
        builder: (context, form, child) {
          if (hasEmptyWidget && items.isEmpty) {
            return const SizedBox.shrink();
          }
          return _newItemButton();
        },
      ),
      emptyWidget: hasEmptyWidget
          ? Padding(
              padding: (itemsSectionPadding != null && isSection)
                  ? itemsSectionPadding!
                  : EdgeInsets.zero,
              child: EmptyBody(
                icon: emptyIcon,
                title: emptyTitle,
                description: emptyDescription,
                button: _newItemButton(),
              ),
            )
          : null,
      hideLeadingTrailingWhenEmpty: hideLeadingTrailingWhenEmpty,
    );
  }

  List<Widget> _buildRow(
    BuildContext context,
    T item,
    int rowIdx,
    Set<WidgetState> states,
  ) {
    final tableTextStyleSecondary = Theme.of(context).textTheme.bodyMedium;
    return [
      CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Row(
              children: [
                if (rowPrefix != null)
                  rowPrefix!(context, item, rowIdx)
                else
                  const SizedBox.shrink(),
                Text(
                  rowTitle(item),
                  style: tableTextStyleSecondary?.copyWith(
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
                const Spacer(),
                if (rowSuffix != null)
                  rowSuffix!(context, item, rowIdx)
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  Widget _newItemButton() {
    if (control.disabled) {
      return const SizedBox.shrink();
    }
    return PrimaryButton(text: onNewItemLabel, onPressed: onNewItem);
  }
}
