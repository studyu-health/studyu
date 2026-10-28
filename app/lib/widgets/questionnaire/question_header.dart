import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/html_text.dart';

class const QuestionHeader({
  super.key,
  final String? prompt,
  final String? subtitle,
  final String? rationale,
}) extends StatelessWidget {
  List<Widget> _buildSubtitle(BuildContext context) {
    if (subtitle == null || subtitle!.isEmpty) return [];
    return [
      const SizedBox(height: 8),
      Text(
        subtitle!,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlText(
          prompt,
          style: theme.textTheme.titleMedium,
          customStylesBuilder: (element) => element.localName == 'p'
              ? {
                  'margin': '0',
                  if (element.previousElementSibling != null)
                    'margin-top': '8px',
                }
              : null,
        ),
        ..._buildSubtitle(context),
        if (rationale != null && rationale!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          HtmlText(
            rationale,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            customStylesBuilder: (element) => element.localName == 'p'
                ? {
                    'margin': '0',
                    if (element.previousElementSibling != null)
                      'margin-top': '8px',
                  }
                : null,
          ),
        ],
      ],
    );
  }
}
