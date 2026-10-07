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

  /// Local serializer provenance, not availability inferred from numeric values.
  @JsonKey(defaultValue: false)
  bool availabilityVerified;

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
    this.availabilityVerified = true,
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
    this.availabilityVerified = true,
  }) : id = const Uuid().v4();

  factory fromJson(Map<String, dynamic> json) {
    final recall = _$DailyRecallFromJson(json);
    if (!recall.availabilityVerified) recall.setAvailabilityVerified(false);
    return recall;
  }

  bool get canWriteAvailability =>
      availabilityVerified &&
      meals
          .expand((meal) => meal.foods)
          .every((food) => food.canWriteAvailability);

  /// Use true only for newly constructed data or canonical server responses.
  void setAvailabilityVerified(bool verified) {
    availabilityVerified = verified;
    for (final food in meals.expand((meal) => meal.foods)) {
      food.setAvailabilityVerified(verified);
    }
  }

  Map<String, dynamic> toJson() {
    final json = _$DailyRecallToJson(this);
    if (!availabilityVerified) json.remove('availabilityVerified');
    return json;
  }

  Map<String, dynamic> toJsonForStorage() => toJson()
    ..remove('availabilityVerified')
    ..['meals'] = [
      for (final meal in meals)
        meal.toJson()
          ..['foods'] = [
            for (final food in meal.foods) food.toJsonForStorage(),
          ],
    ];

  @override
  String toString() => toJson().toString();
}
