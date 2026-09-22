import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_item.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_operator_dropdown.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';

class const NumberFilter({
  required final String title,
  required final TextEditingController controller,
  required final FilterOperator op,
  required final ValueChanged<FilterOperator> onOpChanged,
  required final bool isExpanded,
  required final ValueChanged<bool> onExpansionChanged,
  super.key,
}) extends StatelessWidget {
  String _getNumberLabel(BuildContext context, FilterOperator op) {
    switch (op) {
      case FilterOperator.greaterThanOrEqual:
        return AppLocalizations.of(context)!.filter_operator_min;
      case FilterOperator.lessThanOrEqual:
        return AppLocalizations.of(context)!.filter_operator_max;
      case FilterOperator.equals:
        return AppLocalizations.of(context)!.filter_operator_exactly;
      case FilterOperator.greaterThan:
        return AppLocalizations.of(context)!.filter_operator_more_than;
      case FilterOperator.lessThan:
        return AppLocalizations.of(context)!.filter_operator_less_than;
      default:
        final name = op.name;
        return "${name[0].toUpperCase()}${name.substring(1)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilterItem(
      keyName: title,
      title: title,
      isActive: controller.text.isNotEmpty,
      isInitiallyExpanded: isExpanded,
      onExpansionChanged: onExpansionChanged,
      onReset: () => controller.clear(),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: FilterOperatorDropdown(
              options: const [
                FilterOperator.greaterThanOrEqual,
                FilterOperator.lessThanOrEqual,
                FilterOperator.equals,
                FilterOperator.greaterThan,
                FilterOperator.lessThan,
              ],
              selected: op,
              onChanged: onOpChanged,
              getLabel: (op) => _getNumberLabel(context, op),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                border: OutlineInputBorder(),
                hintText: "0",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
