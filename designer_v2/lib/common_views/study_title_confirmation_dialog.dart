import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const StudyConfirmationCheckbox({
  required final Key key,
  required final Widget label,
});

class const StudyTitleConfirmationDialog({
  required final Study study,
  required final String title,
  required final String description,
  required final String instruction,
  required final String textFieldLabel,
  required final String confirmLabel,
  required final Future<void> Function() onConfirmed,
  final Key textFieldKey = const ValueKey('study_title_confirmation_field'),
  final List<Widget> additionalContent = const [],
  final List<StudyConfirmationCheckbox> confirmationCheckboxes = const [],
  final bool hideConfirmUntilValid = false,
  final bool destructive = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<StudyTitleConfirmationDialog> createState() =>
      _StudyTitleConfirmationDialogState();
}

class _StudyTitleConfirmationDialogState()
    extends State<StudyTitleConfirmationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _studyTitleController = TextEditingController();
  final Set<Key> _checkedConfirmationKeys = {};

  String get _studyTitle => widget.study.title ?? '';

  bool get _canConfirm {
    final titleMatches = _studyTitleController.text.trim() == _studyTitle;
    final allCheckboxesChecked = widget.confirmationCheckboxes.every(
      (checkbox) => _checkedConfirmationKeys.contains(checkbox.key),
    );
    return titleMatches && allCheckboxesChecked;
  }

  @override
  void initState() {
    super.initState();
    _studyTitleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _studyTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SelectionArea(
      child: StandardDialog(
        titleText: widget.title,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(widget.description),
              ...widget.additionalContent,
              if (widget.confirmationCheckboxes.isNotEmpty) ...[
                const SizedBox(height: 16.0),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        for (final checkbox in widget.confirmationCheckboxes)
                          CheckboxListTile(
                            key: checkbox.key,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _checkedConfirmationKeys.contains(
                              checkbox.key,
                            ),
                            onChanged: (value) {
                              setState(() {
                                if (value ?? false) {
                                  _checkedConfirmationKeys.add(checkbox.key);
                                } else {
                                  _checkedConfirmationKeys.remove(checkbox.key);
                                }
                              });
                            },
                            title: checkbox.label,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16.0),
              SelectableText(widget.instruction),
              const SizedBox(height: 16.0),
              TextFormField(
                key: widget.textFieldKey,
                controller: _studyTitleController,
                decoration: InputDecoration(labelText: widget.textFieldLabel),
                validator: (value) {
                  if (value == null || value.trim() != _studyTitle) {
                    return tr.dialog_study_title_mismatch;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actionButtons: [
          const DismissButton(),
          if (!widget.hideConfirmUntilValid || _canConfirm)
            PrimaryButton(
              text: widget.confirmLabel,
              icon: null,
              enabled: _canConfirm,
              backgroundColor: widget.destructive ? colorScheme.error : null,
              foregroundColor: widget.destructive ? colorScheme.onError : null,
              onPressedFuture: () async {
                if (_formKey.currentState!.validate()) {
                  await widget.onConfirmed();
                }
              },
            ),
        ],
        maxWidth: 650,
        minWidth: 610,
        minHeight: 200,
      ),
    );
  }
}
