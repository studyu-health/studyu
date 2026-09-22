import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/report/report_section_widget.dart';
import 'package:studyu_app/screens/study/report/util/report_utilities.dart';
import 'package:studyu_app/widgets/report/gauges_widget.dart';
import 'package:studyu_core/core.dart';

class const GaugeComparisonSectionWidget(
  super.subject,
  final GaugeComparisonSection section, {
  super.key,
}) extends ReportSectionWidget {
  @override
  Widget build(BuildContext context) {
    return _GaugeComparisonSectionStatefulWidget(subject, section);
  }
}

class const _GaugeComparisonSectionStatefulWidget(
  final StudySubject subject,
  final GaugeComparisonSection section,
) extends StatefulWidget {
  @override
  State<_GaugeComparisonSectionStatefulWidget> createState() =>
      _GaugeComparisonSectionState();
}

class _GaugeComparisonSectionState()
    extends State<_GaugeComparisonSectionStatefulWidget> {
  bool _isLoading = true;
  bool showColorlessGauges = false;

  late final ReportUtilities _reportUtilities;
  late final Map<String, List<num>> _interventionValues;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _reportUtilities = ReportUtilities(widget.subject);

    final results = widget.section.resultProperty?.retrieveFromResults(
      widget.subject,
    );

    if (results == null || results.isEmpty) {
      _interventionValues = {};
    } else {
      final diagramDatums = _reportUtilities
          .convertToDiagramData(results)
          .toList();
      _interventionValues = _reportUtilities.getInterventionGroups(
        diagramDatums,
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_interventionValues.keys.length < 2) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          children: [Text(AppLocalizations.of(context)!.no_data_available_yet)],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)!.show_colorless_gauges),
            Checkbox(
              value: showColorlessGauges,
              onChanged: (bool? newValue) {
                setState(() {
                  showColorlessGauges = newValue ?? false;
                });
              },
            ),
          ],
        ),
        // Conditionally show either colorful or colorless gauges
        GaugesWidget(
          _reportUtilities.getInterventionName(_interventionValues.keys.first),
          _reportUtilities.getInterventionName(
            _interventionValues.keys.elementAt(1),
          ),
          _interventionValues.values.first,
          _interventionValues.values.elementAt(1),
          showColors: !showColorlessGauges,
        ),
      ],
    );
  }
}
