import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_item.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_operator_dropdown.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';

class const EnumFilter<T>({
  required final String title,
  required final List<T> values,
  required final T? selected,
  required final FilterOperator op,
  required final ValueChanged<T?> onChanged,
  required final ValueChanged<FilterOperator> onOpChanged,
  required final bool isExpanded,
  required final ValueChanged<bool> onExpansionChanged,
  final String Function(T)? getValueLabel,
  super.key,
}) extends StatelessWidget {
  String _getSelectLabel(BuildContext context, FilterOperator op) {
    switch (op) {
      case FilterOperator.equals:
        return AppLocalizations.of(context)!.filter_operator_is;
      case FilterOperator.notEquals:
        return AppLocalizations.of(context)!.filter_operator_is_not;
      default:
        final name = op.name;
        return "${name[0].toUpperCase()}${name.substring(1)}";
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return "${s[0].toUpperCase()}${s.substring(1)}";
  }

  @override
  Widget build(BuildContext context) {
    return FilterItem(
      keyName: title,
      title: title,
      isActive: selected != null,
      isInitiallyExpanded: isExpanded,
      onExpansionChanged: onExpansionChanged,
      onReset: () => onChanged(null),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: FilterOperatorDropdown(
              options: const [FilterOperator.equals, FilterOperator.notEquals],
              selected: op,
              onChanged: onOpChanged,
              getLabel: (op) => _getSelectLabel(context, op),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<T>(
              // ignore: deprecated_member_use
              value: selected,
              items: values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        getValueLabel?.call(e) ??
                            _capitalize(e.toString().split('.').last),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
