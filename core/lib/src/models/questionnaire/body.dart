import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'body.g.dart';

@JsonSerializable()
class const Body({
  @JsonKey(name: 'parts') final List<BodyPart> parts = const [],
}) {
  /// The maximum pain level that can be assigned to a body part.
  static const maxPainLevel = 10;

  /// Creates a default body structure.
  factory initial() {
    return const Body(
      parts: [
        BodyPart(
          id: 'head',
          name: 'Head',
          children: [
            BodyPart(
              id: 'headFront',
              name: 'Head (Front)',
              children: [
                BodyPart(id: 'face', name: 'Face'),
                BodyPart(id: 'forehead', name: 'Forehead'),
                BodyPart(id: 'eyes', name: 'Eyes'),
                BodyPart(id: 'nose', name: 'Nose'),
                BodyPart(id: 'mouth', name: 'Mouth'),
              ],
            ),
            BodyPart(id: 'headBack', name: 'Head (Back)'),
            BodyPart(id: 'vestibular', name: 'Vestibular System'),
          ],
        ),
        BodyPart(
          id: 'neck',
          name: 'Neck',
          children: [
            BodyPart(id: 'neckFront', name: 'Neck (Front)'),
            BodyPart(id: 'neckBack', name: 'Neck (Back)'),
          ],
        ),
        BodyPart(
          id: 'torso',
          name: 'Torso',
          children: [
            BodyPart(id: 'chest', name: 'Chest'),
            BodyPart(id: 'upperBack', name: 'Upper Back'),
            BodyPart(id: 'abdomen', name: 'Abdomen'),
            BodyPart(id: 'lowerBack', name: 'Lower Back'),
          ],
        ),
        BodyPart(
          id: 'arms',
          name: 'Arms',
          children: [
            BodyPart(
              id: 'leftArm',
              name: 'Left Arm',
              children: [
                BodyPart(id: 'leftShoulder', name: 'Left Shoulder'),
                BodyPart(id: 'leftUpperArm', name: 'Left Upper Arm'),
                BodyPart(id: 'leftElbow', name: 'Left Elbow'),
                BodyPart(id: 'leftLowerArm', name: 'Left Lower Arm'),
                BodyPart(id: 'leftHand', name: 'Left Hand'),
              ],
            ),
            BodyPart(
              id: 'right_arm',
              name: 'Right Arm',
              children: [
                BodyPart(id: 'right_shoulder', name: 'Right Shoulder'),
                BodyPart(id: 'right_upper_arm', name: 'Right Upper Arm'),
                BodyPart(id: 'right_elbow', name: 'Right Elbow'),
                BodyPart(id: 'right_lower_arm', name: 'Right Lower Arm'),
                BodyPart(id: 'right_hand', name: 'Right Hand'),
              ],
            ),
          ],
        ),
        BodyPart(
          id: 'lower_body',
          name: 'Lower Body',
          children: [
            BodyPart(id: 'pelvis', name: 'Pelvis'),
            BodyPart(id: 'buttocks', name: 'Buttocks'),
          ],
        ),
        BodyPart(
          id: 'legs',
          name: 'Legs',
          children: [
            BodyPart(
              id: 'leftLeg',
              name: 'Left Leg',
              children: [
                BodyPart(id: 'leftUpperLeg', name: 'Left Upper Leg'),
                BodyPart(id: 'leftKnee', name: 'Left Knee'),
                BodyPart(id: 'leftLowerLeg', name: 'Left Lower Leg'),
                BodyPart(id: 'leftFoot', name: 'Left Foot'),
              ],
            ),
            BodyPart(
              id: 'rightLeg',
              name: 'Right Leg',
              children: [
                BodyPart(id: 'rightUpperLeg', name: 'Right Upper Leg'),
                BodyPart(id: 'rightKnee', name: 'Right Knee'),
                BodyPart(id: 'rightLowerLeg', name: 'Right Lower Leg'),
                BodyPart(id: 'rightFoot', name: 'Right Foot'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Deserializes a JSON map into a [Body] object.
  factory fromJson(Map<String, dynamic> json) => _$BodyFromJson(json);

  /// Serializes this [Body] object into a JSON map.
  Map<String, dynamic> toJson() => _$BodyToJson(this);

  /// A helper getter to provide a flattened map of all body parts, keyed by their ID.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, BodyPart> get allPartsById {
    final map = <String, BodyPart>{};
    void traverse(BodyPart part) {
      map[part.id] = part;
      for (final child in part.children) {
        traverse(child);
      }
    }

    for (final part in parts) {
      traverse(part);
    }
    return map;
  }

  /// A helper getter to find all parts with a pain level greater than 0.
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<BodyPart> get painfulParts {
    return allPartsById.values
        .where((part) => part.pain.painLevel > 0)
        .toList();
  }

  /// Returns a new [Body] object with the pain details updated for a specific part.
  /// Because the class is immutable, this method is the proper way to update state.
  ///
  /// [partId]: The ID of the part to update.
  /// [newPain]: The new [BodyPain] object for the part.
  Body withPain(String partId, BodyPain newPain) {
    BodyPart updateRecursive(BodyPart currentPart) {
      if (currentPart.id == partId) {
        return currentPart.copyWith(pain: newPain);
      }

      return currentPart.copyWith(
        children: currentPart.children.map(updateRecursive).toList(),
      );
    }

    return Body(parts: parts.map(updateRecursive).toList());
  }

  Body withPainLevel(String partId, int painLevel) {
    final part = allPartsById[partId];
    if (part == null) {
      return this;
    }

    final newPain = part.pain.copyWith(
      painLevel: painLevel.clamp(0, maxPainLevel),
    );

    return withPain(partId, newPain);
  }
}

enum BodySide() {
  /// The front (ventral) side of the body.
  front,

  /// The back (dorsal) side of the body.
  back;

  /// Maps the side to a value of type [T], allowing for a clean switch.
  T map<T>({required T front, required T back}) {
    switch (this) {
      case BodySide.front:
        return front;
      case BodySide.back:
        return back;
    }
  }
}
