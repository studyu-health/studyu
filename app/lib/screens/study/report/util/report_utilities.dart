import 'package:collection/collection.dart';
import 'package:studyu_app/screens/study/report/sections/average_section_widget.dart';
import 'package:studyu_app/screens/study/report/util/plot_utilities.dart';
import 'package:studyu_app/util/data_processing.dart';
import 'package:studyu_core/core.dart';

class ReportUtilities(final StudySubject subject) {
  Iterable<DiagramDatum> convertToDiagramData(Map<DateTime, num> values) {
    final data = values.entries.map((entry) {
      return DiagramDatum(
        getDayIndex(entry.key), // Determines day index for the key date.
        entry.value,
        entry.key,
        subject.getInterventionForDate(entry.key)!.id,
      );
    });

    return data;
  }

  /// Aggregates the provided [values] based on the [aggregate] type.
  /// If [aggregate] is null, the data is returned as-is.
  Iterable<DiagramDatum> aggregateDataBy(
    Map<DateTime, num> values,
    TemporalAggregation? aggregate,
  ) {
    final data = convertToDiagramData(values);

    // If no aggregation is requested, return the original mapped data.
    if (aggregate == null) return data;

    // Use a switch to determine the aggregation strategy.
    switch (aggregate) {
      case TemporalAggregation.day:
        return data
            .groupBy((datum) => datum.x)
            .aggregateWithKey((group, key) {
              return DiagramDatum(
                key,
                foldAggregateMean()(group.map((d) => d.value)),
                null,
                group.first.intervention,
              );
            })
            .map((entry) => entry.value);

      case TemporalAggregation.phase:
        return data
            .groupBy(
              (datum) => subject.getInterventionIndexForDate(datum.timestamp!),
            )
            .aggregateWithKey((group, key) {
              return DiagramDatum(
                key,
                foldAggregateMean()(group.map((d) => d.value)),
                null,
                group.first.intervention,
              );
            })
            .map((entry) => entry.value);

      default:
        // For other aggregation types, group by intervention and use the defined order.
        final order = getInterventionPositions(subject.selectedInterventions);
        return data
            .groupBy((datum) => datum.intervention)
            .aggregateWithKey((group, key) {
              return DiagramDatum(
                order[key]! as num,
                foldAggregateMean()(group.map((d) => d.value)),
                null,
                key,
              );
            })
            .map((entry) => entry.value);
    }
  }

  /// Returns the day index adjusted for baseline inclusion.
  int getDayIndex(DateTime key) {
    final dayOfStudy = subject.getDayOfStudyFor(key);
    if (subject.study.schedule.includeBaseline) {
      return dayOfStudy;
    }
    final schedule = subject.scheduleFor(subject.startedAt!);
    // The offset is the index of the first task that is not the baseline.
    final offset = schedule.indexWhere((task) => task.id != Study.baselineID);
    return dayOfStudy - offset;
  }

  /// Groups data by intervention (excluding baseline data)
  /// and returns a mapping from intervention IDs to a list of values.
  Map<String, List<num>> getInterventionGroups(List<DiagramDatum> data) {
    final filteredData = data.where(
      (datum) => datum.intervention != '__baseline',
    );
    // Group data by intervention
    final interventionGroups = filteredData.fold<Map<String, List<num>>>({}, (
      map,
      datum,
    ) {
      map.putIfAbsent(datum.intervention, () => []).add(datum.value);
      return map;
    });

    return interventionGroups;
  }

  String getInterventionName(String interventionId) {
    final intervention = subject.study.interventions.firstWhereOrNull(
      (intervention) => intervention.id == interventionId,
    );
    return intervention?.name ?? '';
  }
}
