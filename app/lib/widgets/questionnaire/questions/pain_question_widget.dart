import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/pain_selection/body_part_selector.dart';
import 'package:studyu_app/widgets/questionnaire/pain_selection/body_part_selector_turnable.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class const PainQuestionWidget({
  super.key,
  required final PainQuestion question,
  final Function(Answer)? onDone,
}) extends QuestionWidget {
  @override
  State<PainQuestionWidget> createState() => _PainQuestionWidgetState();
}

class _PainQuestionWidgetState() extends State<PainQuestionWidget> {
  Body? _body;
  PainScale? _scale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_body == null) {
      setState(() {
        _body = _generateLocalizedBody(context);
        _scale = _generateLocalizedScale(context);
      });
    }
  }

  List<String> _getPartHierarchy(BodyPart part) {
    final list = [part.id];
    for (final child in part.children) {
      list.addAll(_getPartHierarchy(child));
    }
    return list;
  }

  void _onPainChanged(
    String parentPartId,
    String childPartId,
    BodyPain newPain,
  ) {
    setState(() {
      var newBody = _body!;
      final parentPart = newBody.allPartsById[parentPartId]!;

      final hierarchyIds = _getPartHierarchy(parentPart);
      for (final id in hierarchyIds) {
        newBody = newBody.withPain(id, const BodyPain());
      }

      if (newPain.painLevel == 0) {
        _body = newBody;
        return;
      }

      newBody = newBody.withPain(childPartId, newPain);

      if (parentPartId != childPartId) {
        newBody = newBody.withPain(
          parentPartId,
          BodyPain(painLevel: newPain.painLevel),
        );
      }

      _body = newBody;
    });
  }

  void _onDone() {
    if (widget.onDone != null && _body != null) {
      widget.onDone!(widget.question.constructAnswer(_body!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_body == null || _scale == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        // TODO: Add instructions for the user on how to use the selector.
        BodyPartSelectorTurnable(
          body: _body!,
          onPainChanged: _onPainChanged,
          scale: _scale!,
          frontButtonIcon: const Icon(Icons.face_outlined),
          backButtonIcon: const Icon(Icons.accessibility_new_outlined),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: _onDone,
          child: Text(AppLocalizations.of(context)!.done),
        ),
      ],
    );
  }
}

Body _generateLocalizedBody(BuildContext context) {
  final loc = AppLocalizations.of(context)!;
  return Body(
    parts: [
      BodyPart(
        id: 'head',
        name: loc.body_head,
        children: [
          BodyPart(
            id: 'headFront',
            name: loc.body_head_front,
            children: [
              BodyPart(id: 'face', name: loc.body_face),
              BodyPart(id: 'forehead', name: loc.body_forehead),
              BodyPart(id: 'eyes', name: loc.body_eyes),
              BodyPart(id: 'nose', name: loc.body_nose),
              BodyPart(id: 'mouth', name: loc.body_mouth),
            ],
          ),
          BodyPart(id: 'headBack', name: loc.body_head_back),
          BodyPart(
            id: 'vestibular',
            name: loc.body_inner_ear_balance,
          ), // Renamed for clarity
        ],
      ),
      BodyPart(
        id: 'neck',
        name: loc.body_neck,
        children: [
          BodyPart(id: 'neckFront', name: loc.body_neck_front),
          BodyPart(id: 'neckBack', name: loc.body_neck_back),
        ],
      ),
      BodyPart(
        id: 'torso',
        name: loc.body_torso,
        children: [
          BodyPart(
            id: 'chest',
            name: loc.body_chest,
            children: [
              BodyPart(id: 'leftChest', name: loc.body_left_chest),
              BodyPart(id: 'rightChest', name: loc.body_right_chest),
              BodyPart(
                id: 'sternum',
                name: loc.body_breastbone,
              ), // Renamed for clarity
            ],
          ),
          BodyPart(
            id: 'upperBack',
            name: loc.body_upper_back,
            children: [
              BodyPart(
                id: 'leftShoulderBlade',
                name: loc.body_left_shoulder_blade,
              ),
              BodyPart(
                id: 'rightShoulderBlade',
                name: loc.body_right_shoulder_blade,
              ),
              BodyPart(
                id: 'thoracicSpine',
                name: loc.body_spine_upper_middle,
              ), // Renamed for clarity
            ],
          ),
          BodyPart(
            id: 'abdomen',
            name: loc.body_abdomen,
            children: [
              BodyPart(id: 'upperAbdomen', name: loc.body_upper_abdomen),
              BodyPart(id: 'lowerAbdomen', name: loc.body_lower_abdomen),
              BodyPart(
                id: 'leftAbdominalSide',
                name: loc.body_left_side_abdomen,
              ),
              BodyPart(
                id: 'rightAbdominalSide',
                name: loc.body_right_side_abdomen,
              ),
            ],
          ),
          BodyPart(
            id: 'lowerBack',
            name: loc.body_lower_back,
            children: [
              BodyPart(
                id: 'lumbarSpine',
                name: loc.body_spine_lower,
              ), // Renamed for clarity
              BodyPart(id: 'leftFlank', name: loc.body_left_flank),
              BodyPart(id: 'rightFlank', name: loc.body_right_flank),
            ],
          ),
        ],
      ),
      BodyPart(
        id: 'arms',
        name: loc.body_arms,
        children: [
          BodyPart(
            id: 'leftArm',
            name: loc.body_left_arm,
            children: [
              BodyPart(id: 'leftShoulder', name: loc.body_left_shoulder),
              BodyPart(
                id: 'leftUpperArm',
                name: loc.body_left_upper_arm,
                children: [
                  BodyPart(id: 'leftBicep', name: loc.body_left_bicep),
                  BodyPart(id: 'leftTricep', name: loc.body_left_tricep),
                ],
              ),
              BodyPart(id: 'leftElbow', name: loc.body_left_elbow),
              BodyPart(
                id: 'leftLowerArm',
                name: loc.body_left_lower_arm,
                children: [
                  BodyPart(id: 'leftForearm', name: loc.body_left_forearm),
                  BodyPart(id: 'leftWrist', name: loc.body_left_wrist),
                ],
              ),
              BodyPart(
                id: 'leftHand',
                name: loc.body_left_hand,
                children: [
                  BodyPart(id: 'leftPalm', name: loc.body_left_palm),
                  BodyPart(id: 'leftFingers', name: loc.body_left_fingers),
                ],
              ),
            ],
          ),
          BodyPart(
            id: 'rightArm',
            name: loc.body_right_arm,
            children: [
              BodyPart(id: 'rightShoukder', name: loc.body_right_shoulder),
              BodyPart(
                id: 'rightUpperArm',
                name: loc.body_right_upper_arm,
                children: [
                  BodyPart(id: 'rightBicep', name: loc.body_right_bicep),
                  BodyPart(id: 'rightTricep', name: loc.body_right_tricep),
                ],
              ),
              BodyPart(id: 'rightElbow', name: loc.body_right_elbow),
              BodyPart(
                id: 'rightLowerArm',
                name: loc.body_right_lower_arm,
                children: [
                  BodyPart(id: 'rightForearm', name: loc.body_right_forearm),
                  BodyPart(id: 'rightWrist', name: loc.body_right_wrist),
                ],
              ),
              BodyPart(
                id: 'rightHand',
                name: loc.body_right_hand,
                children: [
                  BodyPart(id: 'rightPalm', name: loc.body_right_palm),
                  BodyPart(id: 'rightFingers', name: loc.body_right_fingers),
                ],
              ),
            ],
          ),
        ],
      ),
      BodyPart(
        id: 'lowerBody',
        name: loc.body_lower_body,
        children: [
          BodyPart(
            id: 'pelvis',
            name: loc.body_pelvis,
            children: [
              BodyPart(id: 'groin', name: loc.body_groin),
              BodyPart(id: 'hips', name: loc.body_hips),
            ],
          ),
          BodyPart(id: 'buttocks', name: loc.body_buttocks),
        ],
      ),
      BodyPart(
        id: 'legs',
        name: loc.body_legs,
        children: [
          BodyPart(
            id: 'leftLeg',
            name: loc.body_left_leg,
            children: [
              BodyPart(
                id: 'leftUpperLeg',
                name: loc.body_left_upper_leg,
                children: [
                  BodyPart(
                    id: 'leftThighFront',
                    name: loc.body_left_thigh_front,
                  ),
                  BodyPart(
                    id: 'leftThighBack',
                    name: loc.body_left_thigh_back,
                  ), // Hamstring area
                ],
              ),
              BodyPart(id: 'leftKnee', name: loc.body_left_knee),
              BodyPart(
                id: 'leftLowerLeg',
                name: loc.body_left_lower_leg,
                children: [
                  BodyPart(id: 'leftShin', name: loc.body_left_shin),
                  BodyPart(id: 'leftCalf', name: loc.body_left_calf),
                ],
              ),
              BodyPart(id: 'leftAnkle', name: loc.body_left_ankle),
              BodyPart(
                id: 'leftFoot',
                name: loc.body_left_foot,
                children: [
                  BodyPart(id: 'leftHeel', name: loc.body_left_heel),
                  BodyPart(id: 'leftArch', name: loc.body_left_foot_sole),
                  BodyPart(id: 'leftToes', name: loc.body_left_toes),
                ],
              ),
            ],
          ),
          BodyPart(
            id: 'rightLeg',
            name: loc.body_right_leg,
            children: [
              BodyPart(
                id: 'rightUpperLeg',
                name: loc.body_right_upper_leg,
                children: [
                  BodyPart(
                    id: 'rightThighFront',
                    name: loc.body_right_thigh_front,
                  ),
                  BodyPart(
                    id: 'rightThighBack',
                    name: loc.body_right_thigh_back,
                  ), // Hamstring area
                ],
              ),
              BodyPart(id: 'rightKnee', name: loc.body_right_knee),
              BodyPart(
                id: 'rightLowerLeg',
                name: loc.body_right_lower_leg,
                children: [
                  BodyPart(id: 'rightShin', name: loc.body_right_shin),
                  BodyPart(id: 'rightCalf', name: loc.body_right_calf),
                ],
              ),
              BodyPart(id: 'rightAnkle', name: loc.body_right_ankle),
              BodyPart(
                id: 'rightFoot',
                name: loc.body_right_foot,
                children: [
                  BodyPart(id: 'rightHeel', name: loc.body_right_heel),
                  BodyPart(id: 'rightArch', name: loc.body_right_foot_sole),
                  BodyPart(id: 'rightToes', name: loc.body_right_toes),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

PainScale _generateLocalizedScale(BuildContext context) {
  final loc = AppLocalizations.of(context)!;

  return PainScale(
    painIndicatorText: loc.painIndicatorText,
    dialogTitle: loc.dialogTitle,
    levels: {
      0: PainLevelStyle(
        face: '😄',
        description: loc.painLevel_0,
        color: const Color(0xFF4CAF50),
      ),
      2: PainLevelStyle(
        face: '😊',
        description: loc.painLevel_2,
        color: const Color(0xFF8BC34A),
      ),
      4: PainLevelStyle(
        face: '😐',
        description: loc.painLevel_4,
        color: const Color(0xFFFFEB3B),
        textColor: Colors.black87,
      ),
      6: PainLevelStyle(
        face: '😕',
        description: loc.painLevel_6,
        color: const Color(0xFFFF9800),
      ),
      8: PainLevelStyle(
        face: '😢',
        description: loc.painLevel_8,
        color: const Color(0xFFF44336),
      ),
      10: PainLevelStyle(
        face: '😭',
        description: loc.painLevel_10,
        color: const Color(0xFFB71C1C),
      ),
    },
  );
}
