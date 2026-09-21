import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

abstract class const GenericSection(
  final StudySubject? subject, {
  super.key,
  final GestureTapCallback? onTap,
}) extends StatelessWidget {
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: buildContent(context),
      ),
    ),
  );
}
