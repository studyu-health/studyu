import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'study_schedule.g.dart';

@JsonSerializable()
class StudySchedule({var String sequenceCustom = 'ABAB'}) {
  static const int numberOfInterventions = 2;

  int numberOfCycles = 2;
  int phaseDuration = 7;
  bool includeBaseline = true;
  PhaseSequence sequence = PhaseSequence.alternating;
  factory fromJson(Map<String, dynamic> json) => _$StudyScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$StudyScheduleToJson(this);

  int getNumberOfPhases() =>
      numberOfCycles *
          (sequence == PhaseSequence.customized
              ? sequenceCustom.length
              : StudySchedule.numberOfInterventions) +
      (includeBaseline ? 1 : 0);

  int get numberOfPhases => getNumberOfPhases();

  int get length => getNumberOfPhases() * phaseDuration;

  int get baselineLength => includeBaseline ? phaseDuration : 0;

  List<int> generateWith(int firstIntervention, {String? participantId}) {
    final cycles = Iterable<int>.generate(numberOfCycles);
    final phases = cycles
        .expand(
          (cycle) => _generateCycle(firstIntervention, cycle, participantId),
        )
        .toList();
    return phases;
  }

  List<String> generateInterventionIdsInOrder(
    List<String> interventionsIds, {
    required String participantId,
  }) {
    return [
      if (includeBaseline) Study.baselineID,
      ...generateWith(
        0,
        participantId: participantId,
      ).map((index) => interventionsIds[index]),
    ];
  }

  int _nextIntervention(int index) => (index + 1) % numberOfInterventions;

  List<int> _generateCycle(int first, int cycle, String? participantId) {
    switch (sequence) {
      case PhaseSequence.alternating:
        return _generateAlternatingCycle(first, cycle);
      case PhaseSequence.counterBalanced:
        return _generateCounterBalancedCycle(first, cycle);
      case PhaseSequence.randomized:
        return _generateRandomizedCycle(first, cycle, participantId);
      case PhaseSequence.customized:
        return _generateCustomizedCycle(cycle);
    }
  }

  List<int> _generateAlternatingCycle(int first, int cycle) => [
    first,
    _nextIntervention(first),
  ];

  List<int> _generateCounterBalancedCycle(int first, int cycle) {
    final shift = ((cycle + 1) ~/ 2) % 2;
    final baseSequence = [first, _nextIntervention(first)];

    return shift == 0 ? baseSequence : baseSequence.reversed.toList();
  }

  List<int> _generateRandomizedCycle(
    int first,
    int cycle,
    String? participantId,
  ) {
    final order = [first, _nextIntervention(first)];
    if (cycle == 0) return order;
    if (participantId == null) return order..shuffle();

    // The recall save function uses the same digest to validate assignments.
    final digest = sha256.convert(utf8.encode('$participantId:$cycle'));
    return digest.bytes.first.isOdd ? order.reversed.toList() : order;
  }

  List<int> _generateCustomizedCycle(int cycle) {
    final String seqNum = sequenceCustom
        .replaceAll(RegExp('A', caseSensitive: false), '0')
        .replaceAll(RegExp('B', caseSensitive: false), '1');
    return seqNum.split('').map(int.parse).toList();
  }

  String get nameOfSequence {
    switch (sequence) {
      case PhaseSequence.alternating:
        return 'ABAB';
      case PhaseSequence.counterBalanced:
        return 'ABBA';
      case PhaseSequence.randomized:
        return 'Random';
      case PhaseSequence.customized:
        return 'Custom';
    }
  }

  @override
  String toString() {
    return 'StudySchedule{numberOfCycles: $numberOfCycles, phaseDuration: $phaseDuration, includeBaseline: $includeBaseline, sequence: $sequence}';
  }
}

enum PhaseSequence() {
  alternating,
  counterBalanced,
  randomized,
  customized;

  String toJson() => name;

  static PhaseSequence fromJson(String json) => values.byName(json);
}
