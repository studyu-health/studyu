import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const UnderConstruction({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.7,
      child: EmptyBody(
        icon: Icons.construction_rounded,
        title: tr.under_construction,
        description: tr.under_construction_description,
      ),
    );
  }
}
