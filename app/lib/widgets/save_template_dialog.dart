import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

class SaveTemplateResult({
  required final String name,
  required final List<String> tags,
});

enum TemplateType() {
  meal,
  food,
}

class const SaveTemplateDialog({
  required final String initialName,
  required final TemplateType templateType,
  super.key,
}) extends StatefulWidget {
  static Future<SaveTemplateResult?> show(
    BuildContext context, {
    required String initialName,
    required TemplateType templateType,
  }) {
    return showDialog<SaveTemplateResult>(
      context: context,
      builder: (_) => SaveTemplateDialog(
        initialName: initialName,
        templateType: templateType,
      ),
    );
  }

  @override
  State<SaveTemplateDialog> createState() => _SaveTemplateDialogState();
}

class _SaveTemplateDialogState() extends State<SaveTemplateDialog> {
  late TextEditingController _nameController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _tagsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  String _getTitle(AppLocalizations l10n) {
    switch (widget.templateType) {
      case TemplateType.meal:
        return l10n.save_as_reusable_meal;
      case TemplateType.food:
        return l10n.save_food;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isMeal = widget.templateType == TemplateType.meal;

    return AlertDialog(
      title: Text(_getTitle(l10n)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMeal) ...[
            Text(l10n.save_as_reusable_meal_description),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: isMeal
                  ? l10n.template_name_required
                  : l10n.template_name,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tagsController,
            decoration: InputDecoration(
              labelText: l10n.template_tags_optional,
              hintText: l10n.template_tags_hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;

            Navigator.pop(
              context,
              SaveTemplateResult(
                name: _nameController.text.trim(),
                tags: _tagsController.text
                    .split(',')
                    .map((t) => t.trim())
                    .where((t) => t.isNotEmpty)
                    .toList(),
              ),
            );
          },
          child: Text(isMeal ? l10n.save_meal : l10n.save),
        ),
      ],
    );
  }
}
