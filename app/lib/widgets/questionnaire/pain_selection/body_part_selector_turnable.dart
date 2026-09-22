// This code is taken from the package by Tim Lehmann (timcreatedit)
// Source: https://github.com/timcreatedit/body_part_selector
// Licensed under the MIT License.

import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/questionnaire/pain_selection/body_part_selector.dart';
import 'package:studyu_core/core.dart';

/// A widget that displays front and back views of a body for selection.
/// This widget provides a [SegmentedButton] to switch between [BodySide.front]
/// and [BodySide.back] views, wrapping the [BodyPartSelector].
class const BodyPartSelectorTurnable({
  /// The body object containing the full hierarchy of parts and their pain state.
  required final Body body,
  super.key,

  /// Called when pain details for a body part are updated via the dialog.
  final void Function(
    String parentPartId,
    String childPartId,
    BodyPain newPain,
  )?
  onPainChanged,

  /// The configuration for the pain scale, including styles and translations.
  final PainScale scale = PainScale.english,

  /// The color of body parts with no pain.
  final Color? unselectedColor,

  /// The color of the outline of body parts with no pain.
  final Color? unselectedOutlineColor,

  /// The padding around the rendered body.
  final EdgeInsets padding = const EdgeInsets.all(16),

  /// The text for the front button.
  final String frontButtonText = 'Front',

  /// The text for the back button.
  final String backButtonText = 'Back',

  /// The icon for the front button. Can be null.
  final Widget? frontButtonIcon = const Icon(Icons.face),

  /// The icon for the back button. Can be null.
  final Widget? backButtonIcon = const Icon(Icons.face_retouching_natural),
}) extends StatefulWidget {
  @override
  State<BodyPartSelectorTurnable> createState() =>
      _BodyPartSelectorTurnableState();
}

class _BodyPartSelectorTurnableState() extends State<BodyPartSelectorTurnable> {
  BodySide _side = BodySide.front;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SegmentedButton<BodySide>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                icon: widget.frontButtonIcon,
                value: BodySide.front,
                label: Text(widget.frontButtonText),
              ),
              ButtonSegment(
                icon: widget.backButtonIcon,
                value: BodySide.back,
                label: Text(widget.backButtonText),
              ),
            ],
            selected: {_side},
            onSelectionChanged: (newSelection) {
              setState(() {
                _side = newSelection.first;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: widget.padding,
          child: BodyPartSelector(
            side: _side,
            body: widget.body,
            onPainChanged: widget.onPainChanged,
            scale: widget.scale,
            unselectedColor: widget.unselectedColor,
            unselectedOutlineColor: widget.unselectedOutlineColor,
          ),
        ),
      ],
    );
  }
}
