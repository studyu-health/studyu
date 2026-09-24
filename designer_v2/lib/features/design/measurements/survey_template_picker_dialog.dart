import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey_template_providers.dart';

/// A Material 3 dialog that lets researchers browse and apply premade survey templates.
class const SurveyTemplatePickerDialog({
  required final MeasurementsFormViewModel formViewModel,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final repository = ref.watch(surveyTemplateRepositoryProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
              child: Row(
                children: [
                  Icon(Icons.library_add_rounded, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Survey Templates',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Apply a premade survey to your study',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Template list
            Flexible(
              child: FutureBuilder<List<SurveyTemplate>>(
                future: repository.getTemplates(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final templates = snapshot.data ?? [];
                  if (templates.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No templates available',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: templates.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      return _TemplateItem(
                        template: template,
                        formViewModel: formViewModel,
                        onApplied: () => Navigator.of(context).pop(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class const _TemplateItem({
  required final SurveyTemplate template,
  required final MeasurementsFormViewModel formViewModel,
  required final VoidCallback onApplied,
}) extends StatefulWidget {
  @override
  State<_TemplateItem> createState() => _TemplateItemState();
}

class _TemplateItemState() extends State<_TemplateItem> {
  bool _expanded = false;

  bool get _isAlreadyAdded =>
      widget.formViewModel.isSurveyWithTitleAdded(widget.template.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final template = widget.template;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              template.isMultiDay
                  ? Icons.calendar_view_week_rounded
                  : Icons.assignment_outlined,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  template.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (template.isBuiltIn)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Chip(
                    label: Text(
                      'Built-in',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                    backgroundColor: colorScheme.tertiaryContainer,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              template.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: template.isMultiDay
              ? IconButton(
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                )
              : _isAlreadyAdded
              ? Chip(
                  label: Text(
                    'Added',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  backgroundColor: colorScheme.secondaryContainer,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )
              : FilledButton.tonal(
                  onPressed: () {
                    widget.formViewModel.applyTemplate(template);
                    widget.onApplied();
                  },
                  child: const Text('Apply'),
                ),
        ),
        // Multi-day expanded list
        if (template.isMultiDay && _expanded)
          ColoredBox(
            color: colorScheme.surfaceContainerLow,
            child: Column(
              children: [
                for (final entry in template.dayEntries!) ...[
                  _DayEntryTile(
                    entry: entry,
                    formViewModel: widget.formViewModel,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class const _DayEntryTile({
  required final SurveyTemplateDayEntry entry,
  required final MeasurementsFormViewModel formViewModel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAdded = formViewModel.isSurveyWithTitleAdded(entry.title);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 36),
      leading: Text(
        'Day ${entry.dayIndex + 1}',
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
      title: Text(entry.title, style: theme.textTheme.bodyMedium),
      trailing: isAdded
          ? Icon(
              Icons.check_circle_rounded,
              color: colorScheme.primary,
              size: 20,
            )
          : IconButton(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              onPressed: () {
                final newVm = formViewModel.applyTemplateDayEntry(entry);
                if (newVm != null) {
                  Navigator.of(context).pop();
                }
              },
            ),
    );
  }
}
