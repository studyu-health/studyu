import 'package:studyu_core/src/models/models.dart';
import 'package:uuid/uuid.dart';

abstract class Task {
  static const String keyType = 'type';
  String type;

  late String id;
  String? title;

  String? header;
  String? footer;

  Schedule schedule = Schedule();

  /// When non-null, this task appears only on the study days
  /// resolved by the rule (specific days, every N days, or per cycle).
  TaskScheduleRule? scheduleRule;

  new(this.type);

  new withId(this.type) : id = const Uuid().v4();

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }

  Map<DateTime, T> extractPropertyResults<T>(
    String property,
    List<SubjectProgress> sourceResults,
  );

  Map<String, Type> getAvailableProperties();

  String? getHumanReadablePropertyName(String property);
}
