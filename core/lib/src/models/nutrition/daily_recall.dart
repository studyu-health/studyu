import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/nutrition/enums.dart';
import 'package:studyu_core/src/models/nutrition/meal_log.dart';
import 'package:uuid/uuid.dart';

part 'daily_recall.g.dart';

@JsonSerializable()
class DailyRecall {
  String id;
  DateTime date;
  bool? isUsualIntakeDay;
  String? specialOccasion;
  RecallMode recallMode;
  DateTime? entryStartedAt;
  DateTime? entryCompletedAt;
  List<MealLog> meals;
  int? studyDaySnapshot;
  DateTime? lastAutoSavedAt;

  new({
    required this.id,
    required this.date,
    this.isUsualIntakeDay,
    this.specialOccasion,
    required this.recallMode,
    this.entryStartedAt,
    this.entryCompletedAt,
    required this.meals,
    this.studyDaySnapshot,
    this.lastAutoSavedAt,
  });

  new withId({
    required this.date,
    this.isUsualIntakeDay,
    this.specialOccasion,
    required this.recallMode,
    this.entryStartedAt,
    this.entryCompletedAt,
    required this.meals,
    this.studyDaySnapshot,
    this.lastAutoSavedAt,
  }) : id = const Uuid().v4();

  factory fromJson(Map<String, dynamic> json) => _$DailyRecallFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecallToJson(this);

  @override
  String toString() => toJson().toString();
}
