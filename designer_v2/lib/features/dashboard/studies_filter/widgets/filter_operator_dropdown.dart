import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';

class const FilterOperatorDropdown({
  required final List<FilterOperator> options,
  required final FilterOperator selected,
  required final ValueChanged<FilterOperator> onChanged,
  required final String Function(FilterOperator) getLabel,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<FilterOperator>(
      // ignore: deprecated_member_use
      value: selected,
      items: options
          .map((op) => DropdownMenuItem(value: op, child: Text(getLabel(op))))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(),
      ),
    );
  }
}
