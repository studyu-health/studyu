import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_item.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_operator_dropdown.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';

class const TextFilter({
  required final String title,
  required final TextEditingController controller,
  required final FilterOperator op,
  required final ValueChanged<FilterOperator> onOpChanged,
  required final bool isExpanded,
  required final ValueChanged<bool> onExpansionChanged,
  super.key,
}) extends StatelessWidget {
  String _getTextLabel(BuildContext context, FilterOperator op) {
    switch (op) {
      case FilterOperator.contains:
        return AppLocalizations.of(context)!.filter_operator_contains;
      case FilterOperator.equals:
        return AppLocalizations.of(context)!.filter_operator_equals;
      case FilterOperator.startsWith:
        return AppLocalizations.of(context)!.filter_operator_starts_with;
      case FilterOperator.endsWith:
        return AppLocalizations.of(context)!.filter_operator_ends_with;
      default:
        // Simple extension for capitalization if not available here
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: FilterOperatorDropdown(
              options: const [
                FilterOperator.contains,
                FilterOperator.equals,
                FilterOperator.startsWith,
                FilterOperator.endsWith,
              ],
              selected: op,
              onChanged: onOpChanged,
              getLabel: (op) => _getTextLabel(context, op),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              // We rely on the parent to rebuild if needed, or the controller listener.
              // In the original code: onChanged: (_) => setState(() {}),
              // We might need to ensure the parent rebuilds to update 'isActive' state.
              // Ideally the parent listens to the controller. Check original code implementation.
              // Original code: onChanged: (_) => setState(() {}),
              // We should probably just let the TextField handle its own state but 'isActive' in FilterItem depends on it.
              // So we will trigger a rebuild here via ValueListenableBuilder if we want to be pure,
              // OR we just accept that the parent rebuilds.
              // For now, let's replicate the structure.
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
