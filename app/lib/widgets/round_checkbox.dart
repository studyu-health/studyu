import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class const RoundCheckbox({
  super.key,
  final Function(bool)? onChanged,
  final bool? value,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: () {
        onChanged!(!value!);
      },
      icon: value!
          ? Icon(
              MdiIcons.checkboxMarkedCircleOutline,
              size: 30,
              color: theme.colorScheme.secondary,
            )
          : Icon(
              MdiIcons.checkboxBlankCircleOutline,
              size: 30,
              color: theme.colorScheme.secondary,
            ),
    );
  }
}
