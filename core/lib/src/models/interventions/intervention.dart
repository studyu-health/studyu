import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/interventions/intervention_task.dart';
import 'package:uuid/uuid.dart';

part 'intervention.g.dart';

@JsonSerializable()
class Intervention {
  String id;
  String? name;
  String? description;
  String icon = '';

  List<InterventionTask> tasks = [];

  new(this.id, this.name);

  new withId() : id = const Uuid().v4();

  factory fromJson(Map<String, dynamic> data) => _$InterventionFromJson(data);

  Map<String, dynamic> toJson() => _$InterventionToJson(this);

  bool isBaseline() => name == 'Baseline';
}
