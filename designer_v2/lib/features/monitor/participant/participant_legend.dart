import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/striped_gradient.dart';
import 'package:studyu_designer_v2/features/monitor/participant/colors.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const ParticipantLegend() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.participant_details_color_legend_title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        _buildLegendItem(
          color: completeColor,
          tr.participant_details_color_legend_completed,
          tr.participant_details_completed_legend_tooltip,
        ),
        const SizedBox(height: 18.0),
        _buildLegendItem(
          color: partiallyCompleteColor,
          tr.participant_details_color_legend_partially_completed,
          tr.participant_details_partially_completed_legend_tooltip,
          gradient: true,
        ),
        const SizedBox(height: 16.0),
        _buildLegendItem(
          color: incompleteColor,
          tr.participant_details_color_legend_missed,
          tr.participant_details_incomplete_legend_tooltip,
        ),
        const SizedBox(height: 16.0),
        Text(
          tr.participant_details_color_tooltip_legend_title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            _buildLegendItem(
              widget: const Text('\u{2705}'),
              tr.participant_details_color_legend_completed_task,
              tr.participant_details_color_legend_completed_task_tooltip,
            ),
            const SizedBox(width: 16.0),
            _buildLegendItem(
              widget: const Text('\u{274C}'),
              tr.participant_details_color_legend_missed_task,
              tr.participant_details_color_legend_missed_task_tooltip,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    String text,
    String tooltipMessage, {
    Color? color,
    Widget? widget,
    bool gradient = false,
  }) {
    if (color == null && widget == null) {
      throw ArgumentError('Only color or widget can be provided.');
    }
    return Tooltip(
      message: tooltipMessage,
      child: Row(
        children: [
          if (color != null)
            Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: color,
                gradient: gradient
                    ? StripedGradient(
                        colors: [
                          partiallyCompleteColor,
                          partiallyCompleteColor,
                          incompleteColor,
                          incompleteColor,
                        ],
                      ).gradient
                    : null,
              ),
            ),
          ?widget,
          const SizedBox(width: 8.0),
          Text(text),
        ],
      ),
    );
  }
}
