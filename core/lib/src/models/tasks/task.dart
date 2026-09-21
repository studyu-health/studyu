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
