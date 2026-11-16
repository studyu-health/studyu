import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const MeasurementSelectionCards({
  required final VoidCallback? onNewSurvey,
  required final VoidCallback? onNewNutrition,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          tr.form_measurement_type_select,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onNewSurvey != null)
              _buildCard(
                context,
                title: tr.form_measurement_type_survey,
                description: tr.form_measurement_type_survey_description,
                icon: Icons.assignment_outlined,
                onTap: onNewSurvey!,
              ),
            if (onNewSurvey != null && onNewNutrition != null)
              const SizedBox(width: 24.0),
            if (onNewNutrition != null)
              _buildCard(
                context,
                title: tr.form_measurement_type_nutrition,
                description: tr.form_measurement_type_nutrition_description,
                icon: Icons.restaurant,
                onTap: onNewNutrition!,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return MouseEventsRegion(
      builder: (context, state) {
        final isHovered = state.contains(WidgetState.hovered);
        return SizedBox(
          width: 300,
          height: 350,
          child: Card(
            elevation: isHovered ? 8.0 : 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: isHovered
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2.0,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 64.0, color: theme.colorScheme.primary),
                    const SizedBox(height: 24.0),
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
