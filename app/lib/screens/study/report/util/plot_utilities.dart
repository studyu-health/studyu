import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

Map<String, int> getInterventionPositions(List<Intervention> interventions) {
  final order = <String, int>{};
  for (final intervention in interventions) {
    if (!order.containsKey(intervention.id)) {
      order[intervention.id] = order.length;
    }
  }
  return order;
}

// ignore: prefer_const_constructors_in_immutables
class LegendWidget({super.key, required Legend legend})
    extends StatelessWidget {
  final String name = legend.name;
  final Color color = legend.color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(name, style: textTheme.bodyLarge),
      ],
    );
  }
}

class const LegendsListWidget({super.key, required final List<Legend> legends})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: legends.map((legend) => LegendWidget(legend: legend)).toList(),
    );
  }
}

class Legend(final String name, final Color color);
