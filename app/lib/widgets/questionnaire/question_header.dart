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
      Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
    ];
  }

  List<Widget> _buildRationaleButton(BuildContext context) {
    if (rationale == null || rationale!.isEmpty) return [];
    return [
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.info_outline),
        color: Theme.of(context).primaryColor,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Information'),
            content: HtmlText(rationale),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HtmlText(prompt, style: Theme.of(context).textTheme.titleMedium),
              ..._buildSubtitle(context),
            ],
          ),
        ),
        ..._buildRationaleButton(context),
      ],
    );
  }
}
