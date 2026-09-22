import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:studyu_app/util/intervention.dart';
import 'package:studyu_app/widgets/intervention_card.dart';
import 'package:studyu_core/core.dart';

class const ProgressRow({super.key, final StudySubject? subject})
    extends StatefulWidget {
  @override
  State<ProgressRow> createState() => _ProgressRowState();
}

class _ProgressRowState() extends State<ProgressRow> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentPhase = widget.subject!.getInterventionIndexForDate(
      DateTime.now(),
    );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(MdiIcons.run, size: 30),
              const SizedBox(width: 8),
              ...intersperseIndexed(
                (index) => Expanded(
                  child: Divider(
                    indent: 5,
                    endIndent: 5,
                    thickness: 3,
                    color: currentPhase > index
                        ? theme.primaryColor
                        : theme.disabledColor,
                  ),
                ),
                widget.subject!.getInterventionsInOrder().asMap().entries.map((
                  entry,
                ) {
                  return InterventionSegment(
                    intervention: entry.value,
                    isCurrent: currentPhase == entry.key,
                    isFuture: currentPhase < entry.key,
                    phaseDuration: widget.subject!.study.schedule.phaseDuration,
                    percentCompleted: widget.subject!.percentCompletedForPhase(
                      entry.key,
                    ),
                    percentMissed: widget.subject!.percentMissedForPhase(
                      entry.key,
                      DateTime.now(),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              const Icon(MdiIcons.flagCheckered, size: 30),
            ],
          ),
        ],
      ),
    );
  }
}

class const InterventionSegment({
  required final Intervention intervention,
  required final double percentCompleted,
  required final double percentMissed,
  required final bool isCurrent,
  required final bool isFuture,
  required final int phaseDuration,
  super.key,
}) extends StatelessWidget {
  List<Widget> buildSeparators(int nbSeparators) {
    final sep = <Widget>[];
    for (var i = 0; i < nbSeparators; i++) {
      sep.add(
        Transform.rotate(
          angle: i * 1 / nbSeparators * 2 * pi,
          child: SizedBox(
            width: 2,
            height: 40,
            child: Column(
              children: <Widget>[
                Container(width: 8, height: 10, color: Colors.white),
              ],
            ),
          ),
        ),
      );
    }
    return sep;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isFuture
        ? Colors.grey
        : (isCurrent ? theme.colorScheme.secondary : theme.primaryColor);

    final emptyColor = Color.alphaBlend(theme.dividerColor, Colors.white);
    final activeColor = Color.alphaBlend(
      theme.colorScheme.secondary,
      Colors.white,
    );
    final completedColor = Color.alphaBlend(theme.primaryColor, Colors.white);

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
              value: 1,
              valueColor: AlwaysStoppedAnimation<Color>(emptyColor),
            ),
          ),
          if (isCurrent)
            AspectRatio(
              aspectRatio: 1,
              child: CircularProgressIndicator(
                value: percentMissed + percentCompleted + (1 / phaseDuration),
                valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              ),
            ),
          AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
              value: percentMissed + percentCompleted,
              valueColor: AlwaysStoppedAnimation<Color>(emptyColor),
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
              value: percentCompleted,
              valueColor: AlwaysStoppedAnimation<Color>(completedColor),
            ),
          ),
          Stack(children: buildSeparators(phaseDuration)),
          RawMaterialButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: InterventionCard(intervention),
                ),
              );
            },
            elevation: 0,
            fillColor: color,
            shape: const CircleBorder(
              side: BorderSide(color: Colors.white, width: 2),
            ),
            child: interventionIcon(intervention),
          ),
        ],
      ),
    );
  }
}

Iterable<T> intersperseIndexed<T>(
  T Function(int) generator,
  Iterable<T> iterable,
) sync* {
  final iterator = iterable.iterator;
  var index = 0;
  if (iterator.moveNext()) {
    yield iterator.current;
    while (iterator.moveNext()) {
      yield generator(index++);
      yield iterator.current;
    }
  }
}
