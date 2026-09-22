import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

Widget interventionIcon(Intervention intervention, {Color? color}) {
  if (intervention.isBaseline()) {
    return Icon(MdiIcons.rayStart, color: color ?? Colors.white);
  }

  return intervention.icon.isNotEmpty
      ? Icon(
          MdiIconsHelper.fromString(intervention.icon),
          color: color ?? Colors.white,
        )
      : Text(
          intervention.name![0].toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        );
}
