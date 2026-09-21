import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/data_reference_identifier.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class const DataReferenceEditor<T>({
  required final FormControl<DataReferenceIdentifier<T>> formControl,
  required final List<Task> availableTasks,
}) {
  ReactiveDropdownField get buildReactiveDropdownField {
    final items = _dataReferenceItems();
    return ReactiveDropdownField<DataReferenceIdentifier>(
      formControl: formControl,
      items: items,
      isExpanded: true,
      hint: items.isNotEmpty
          ? Text(tr.form_field_report_data_source_hint)
          : Text(tr.form_field_report_data_source_empty),
    );
  }

  FormTableRow buildFormTableRow(ThemeData theme) => FormTableRow(
    label: tr.form_field_report_data_source_title,
    labelHelpText: tr.form_field_report_data_source_tooltip,
    // TODO: extract custom dropdown component with theme + focus fix
    input: Theme(
      data: theme.copyWith(
        inputDecorationTheme: ThemeConfig.dropdownInputDecorationTheme(theme),
      ),
      child: buildReactiveDropdownField,
    ),
  );

  List<DropdownMenuItem<DataReferenceIdentifier>> _dataReferenceItems() {
    final items = <DropdownMenuItem<DataReferenceIdentifier>>[];
    for (final task in availableTasks) {
      for (final entry in task.getAvailableProperties().entries) {
        if (entry.value == T) {
          items.add(
            DropdownMenuItem<DataReferenceIdentifier<T>>(
              value: DataReferenceIdentifier(task.id, entry.key),
              child: Text(
                '${task.title} > ${task.getHumanReadablePropertyName(entry.key)}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
      }
    }
    return items;
  }
}
