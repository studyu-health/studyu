import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/icons.dart';

enum FormTableRowLayout() {
  vertical,
  horizontal,
}

class FormTableRow({
  final String? label,
  final WidgetBuilder? labelBuilder,
  required final Widget input,
  final TextStyle? labelStyle,
  final String? labelHelpText,
  final AbstractControl? control,
  final FormTableRowLayout? layout,
});

/// Renders a list of [FormTableRow]s in a two-column tabular layout
class const FormTableLayout({
  required final List<FormTableRow> rows,
  final Map<int, TableColumnWidth> columnWidths = const {
    0: FixedColumnWidth(160.0),
    1: FlexColumnWidth(),
  },
  final Widget? rowDivider,
  final FormTableRowLayout? rowLayout = FormTableRowLayout.horizontal,
  final TextStyle? rowLabelStyle,
  final double rowSpacing = 10.0,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Flutter uses "theme.textTheme.titleMedium" for input fields by default
    final inputTextTheme = theme.textTheme.titleMedium!;

    final List<TableRow> tableRows = [];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final isTrailing = i == rows.length - 1;

      final bottomSpacing = (!isTrailing) ? rowSpacing : 0.0;
      final stateColorStyle = (row.control != null && row.control!.disabled)
          ? TextStyle(color: theme.disabledColor)
          : null;
      final actualRowLayout =
          row.layout ?? rowLayout ?? FormTableRowLayout.horizontal;

      final labelWidget = (row.labelBuilder != null)
          ? row.labelBuilder!(context)
          : Wrap(
              children: [
                if (actualRowLayout == FormTableRowLayout.vertical)
                  const SizedBox(width: 2.0)
                else
                  const SizedBox.shrink(),
                FormLabel(
                  labelText: row.label,
                  helpText: row.labelHelpText,
                  labelTextStyle:
                      rowLabelStyle?.merge(row.labelStyle) ?? row.labelStyle,
                  layout: row.layout,
                ),
              ],
            );

      final contentWidget = Align(
        alignment: Alignment.topLeft,
        // Unfortunately need to override the theme here as a workaround to
        // change the text color for disabled controls
        child: Theme(
          data: theme.copyWith(
            textTheme: TextTheme(
              titleMedium: inputTextTheme.merge(stateColorStyle),
            ),
          ),
          child: row.input,
        ),
      );

      final TableRow tableRow;

      if (actualRowLayout == FormTableRowLayout.horizontal) {
        tableRow = TableRow(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 8.0,
                right: 8.0,
                bottom: bottomSpacing,
              ),
              child: labelWidget,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: bottomSpacing),
              child: contentWidget,
            ),
          ],
        );
      } else {
        // actualRowLayout == FormTableRowLayout.vertical
        tableRow = TableRow(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  labelWidget,
                  const SizedBox(height: 8.0),
                  Container(
                    padding: EdgeInsets.only(bottom: bottomSpacing * 2),
                    child: contentWidget,
                  ),
                ],
              ),
            ),
          ],
        );
      }

      tableRows.add(tableRow);

      if (rowDivider != null) {
        tableRows.add(TableRow(children: [rowDivider!, rowDivider!]));
      }
    }

    return Table(
      columnWidths:
          (rowLayout != null && rowLayout == FormTableRowLayout.vertical)
          ? const {0: FlexColumnWidth(), 1: FixedColumnWidth(0.0)}
          : columnWidths,
      children: tableRows,
    );
  }
}

class const FormSectionHeader({
  required final String title,
  final String? helpText,
  final bool helpTextDisabled = false,
  final TextStyle? titleTextStyle,
  final bool divider = true,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge!;

    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              label: title,
              labelHelpText: helpText,
              labelStyle: titleStyle.merge(titleTextStyle),
              input: Container(),
            ),
          ],
          columnWidths: const {0: IntrinsicColumnWidth()},
        ),
        if (divider) const Divider() else const SizedBox.shrink(),
      ],
    );
  }
}

class const FormLabel({
  final String? labelText,
  final String? helpText,
  final TextStyle? labelTextStyle,
  final FormTableRowLayout? layout = FormTableRowLayout.vertical,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        if (labelText != null && layout == FormTableRowLayout.vertical)
          const SizedBox(width: 2.0)
        else
          const SizedBox.shrink(),
        if (labelText != null)
          Text(
            labelText!,
            style: Theme.of(context).textTheme.bodySmall?.merge(labelTextStyle),
          )
        else
          const SizedBox.shrink(),
        if (helpText != null)
          const SizedBox(width: 8.0)
        else
          const SizedBox.shrink(),
        if (helpText != null)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: HelpIcon(tooltipText: helpText),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
