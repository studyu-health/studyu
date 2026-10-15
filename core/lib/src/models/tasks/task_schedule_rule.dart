import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/study_schedule/study_schedule.dart';

part 'task_schedule_rule.g.dart';

/// Defines when a scheduled survey appears during a study.
///
/// Three modes:
/// - [TaskScheduleType.specificDays] — exact study days (0-based)
/// - [TaskScheduleType.everyNDays] — repeating interval
/// - [TaskScheduleType.perCycle] — relative to cycle boundaries
@JsonSerializable()
class TaskScheduleRule({
  required var TaskScheduleType type,

  /// For [TaskScheduleType.specificDays]: 0-based study day indices.
  var List<int> specificDays = const [],

  /// For [TaskScheduleType.everyNDays]: repetition interval.
  var int? intervalDays,

  /// For [TaskScheduleType.everyNDays]: 0-based start offset.
  var int? startDayOffset,

  /// For [TaskScheduleType.perCycle]: 0-based day within each cycle.
  var int? dayOfCycle,

  /// For [TaskScheduleType.perCycle]: restrict to specific cycle indices
  /// (0-based). null or empty means all cycles.
  var List<int>? targetCycles,

  /// For [TaskScheduleType.perCycle]: whether the baseline phase counts
  /// as a cycle for this rule.
  var bool includeBaseline = false,
}) {
  factory fromJson(Map<String, dynamic> json) =>
      _$TaskScheduleRuleFromJson(json);

  Map<String, dynamic> toJson() => _$TaskScheduleRuleToJson(this);

  /// Convenience: create a rule for specific days.
  factory forSpecificDays(List<int> days) =>
      TaskScheduleRule(type: TaskScheduleType.specificDays, specificDays: days);

  /// Convenience: create a rule for every N days.
  factory forEveryNDays(int interval, {int startOffset = 0}) =>
      TaskScheduleRule(
        type: TaskScheduleType.everyNDays,
        intervalDays: interval,
        startDayOffset: startOffset,
      );

  /// Convenience: create a cycle-relative rule.
  factory forPerCycle(
    int dayOfCycle, {
    List<int>? targetCycles,
    bool includeBaseline = false,
  }) => TaskScheduleRule(
    type: TaskScheduleType.perCycle,
    dayOfCycle: dayOfCycle,
    targetCycles: targetCycles,
    includeBaseline: includeBaseline,
  );

  /// Resolves this rule into concrete 0-based study day indices.
  List<int> resolveScheduledDays(StudySchedule schedule) {
    final totalDays = schedule.length;
    switch (type) {
      case TaskScheduleType.specificDays:
        return specificDays.where((d) => d >= 0 && d < totalDays).toList()
          ..sort();

      case TaskScheduleType.everyNDays:
        final interval = intervalDays ?? 1;
        final start = startDayOffset ?? 0;
        if (interval <= 0) return [];
        final days = <int>[];
        for (int d = start; d < totalDays; d += interval) {
          if (d >= 0) days.add(d);
        }
        return days;

      case TaskScheduleType.perCycle:
        final dayInCycle = dayOfCycle ?? 0;
        final phaseDuration = schedule.phaseDuration;
        final baselineLen = schedule.baselineLength;
        final phasesPerCycle = schedule.sequence == PhaseSequence.customized
            ? schedule.sequenceCustom.length
            : StudySchedule.numberOfInterventions;
        final cycleLengthDays = phasesPerCycle * phaseDuration;

        final days = <int>[];

        // Optionally include baseline phase
        if (includeBaseline && schedule.includeBaseline) {
          final baselineDay = dayInCycle;
          if (baselineDay >= 0 && baselineDay < baselineLen) {
            days.add(baselineDay);
          }
        }

        // Iterate cycles
        for (int cycle = 0; cycle < schedule.numberOfCycles; cycle++) {
          if (targetCycles != null &&
              targetCycles!.isNotEmpty &&
              !targetCycles!.contains(cycle)) {
            continue;
          }
          final cycleStart = baselineLen + cycle * cycleLengthDays;
          final day = cycleStart + dayInCycle;
          if (day >= 0 && day < totalDays) {
            days.add(day);
          }
        }
        return days..sort();
    }
  }

  /// Whether this rule matches a given 0-based study day index.
  bool isScheduledForDay(int studyDayIndex, StudySchedule schedule) {
    return resolveScheduledDays(schedule).contains(studyDayIndex);
  }

  @override
  String toString() =>
      'TaskScheduleRule(type: $type, '
      'specificDays: $specificDays, '
      'intervalDays: $intervalDays, '
      'startDayOffset: $startDayOffset, '
      'dayOfCycle: $dayOfCycle, '
      'targetCycles: $targetCycles, '
      'includeBaseline: $includeBaseline)';
}

enum TaskScheduleType() {
  /// Show on exact study days.
  specificDays,

  /// Show every N days.
  everyNDays,

  /// Show relative to cycle boundaries.
  perCycle;

  String toJson() => name;

  static TaskScheduleType fromJson(String json) => values.byName(json);
}
