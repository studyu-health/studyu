import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

/// A purely visual tile showing study icon, title, and description.
///
/// Not interactive — no ink, no tap handler. Use [Hero] wrapping for
/// Hero transitions; wrap this in a gesture handler outside the Hero
/// when interaction is needed.
class StudyTile extends StatelessWidget {
  final String? title;
  final String? description;
  final String iconName;
  final EdgeInsetsGeometry contentPadding;

  const new({
    required this.title,
    required this.description,
    required this.iconName,
    this.contentPadding = const EdgeInsets.all(16),
    super.key,
  });

  new fromStudy({
    required Study study,
    this.contentPadding = const EdgeInsets.all(16),
    super.key,
  }) : title = study.title,
       description = study.description,
       iconName = study.iconName;

  new fromUserStudy({
    required StudySubject subject,
    this.contentPadding = const EdgeInsets.all(16),
    super.key,
  }) : title = subject.study.title,
       description = subject.study.description,
       iconName = subject.study.iconName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                child: Icon(
                  MdiIconsHelper.fromString(iconName),
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title ?? '',
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(description!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
