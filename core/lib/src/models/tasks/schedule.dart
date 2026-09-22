import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'schedule.g.dart';

typedef ScheduleParser = Schedule Function(Map<String, dynamic> data);

@JsonSerializable()
class Schedule() {
  List<CompletionPeriod> completionPeriods = [
    CompletionPeriod.noId(
      unlockTime: StudyUTimeOfDay(hour: 8),
      lockTime: StudyUTimeOfDay(hour: 20),
    ),
  ];
  List<StudyUTimeOfDay> reminders = [];

  factory fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable()
class CompletionPeriod {
  String id;
  final StudyUTimeOfDay unlockTime;
  final StudyUTimeOfDay lockTime;

  new({required this.id, required this.unlockTime, required this.lockTime});

  new noId({required this.unlockTime, required this.lockTime})
    : id = const Uuid().v4();

  factory fromJson(Map<String, dynamic> json) =>
      _$CompletionPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$CompletionPeriodToJson(this);

  String formatted() => '$unlockTime - $lockTime';

  @override
  String toString() => '$id: $unlockTime - $lockTime';

  bool contains(StudyUTimeOfDay time) {
    return unlockTime.earlierThan(time) && time.earlierThan(lockTime);
  }
}

class StudyUTimeOfDay {
  int hour = 0;
  int minute = 0;

  new({this.hour = 0, this.minute = 0}) : super();

  new fromDateTime(DateTime date) {
    hour = date.toLocal().hour;
    minute = date.toLocal().minute;
  }

  new now() {
    final now = StudyUTimeOfDay.fromDateTime(DateTime.now());
    hour = now.hour;
    minute = now.minute;
  }

  new fromJson(String value) {
    final elements = value.split(':').map(int.parse);
    hour = elements.elementAt(0);
    minute = elements.elementAt(1);
  }

  String toJson() => toString();

  @override
  String toString() => '$hour:${minute.toString().padLeft(2, '0')}';

  bool earlierThan(StudyUTimeOfDay time, {bool exact = false}) {
    if (exact) {
      return hour < time.hour || hour == time.hour && minute < time.minute;
    }
    return hour < time.hour || hour == time.hour && minute <= time.minute;
  }
}
