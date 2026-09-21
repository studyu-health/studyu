import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/report/generic_section.dart';

class const DisclaimerSection(super.subject, {super.key, super.onTap})
    extends GenericSection {
  @override
  Widget buildContent(BuildContext context) =>
      Column(children: [Text(AppLocalizations.of(context)!.report_disclaimer)]);
}
