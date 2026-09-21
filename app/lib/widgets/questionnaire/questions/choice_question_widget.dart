import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_app/widgets/selectable_button.dart';
import 'package:studyu_core/core.dart';

class const ChoiceQuestionWidget({
  super.key,
  required final ChoiceQuestion question,
  required final Function(Answer) onDone,
  required final String multiSelectionText,
  required final String requiredMultiSelectionText,
  final Answer<List<String>>? initialAnswer,
  final VoidCallback? onCleared,
}) extends QuestionWidget {
  @override
  State<ChoiceQuestionWidget> createState() => _ChoiceQuestionWidgetState();

  @override
  String? get subtitle => question.multiple
      ? question.selectionRequired
            ? requiredMultiSelectionText
            : multiSelectionText
      : null;
}

class _ChoiceQuestionWidgetState() extends State<ChoiceQuestionWidget> {
  late List<Choice> selected;
  late bool confirmButtonTouched;

  @override
  void initState() {
    super.initState();
    final initialChoiceIds = widget.initialAnswer?.response ?? [];
    selected = widget.question.choices
        .where((choice) => initialChoiceIds.contains(choice.id))
        .toList();
    confirmButtonTouched = widget.initialAnswer != null;
  }

  void tapped(Choice choice) {
    final wasConfirmed = confirmButtonTouched;
    setState(() {
      if (!widget.question.multiple) selected.clear();
      if (selected.contains(choice)) {
        selected.remove(choice);
      } else {
        selected.add(choice);
      }
      if (selected.isEmpty) confirmButtonTouched = false;
    });

    if (selected.isEmpty) {
      if (wasConfirmed) widget.onCleared?.call();
      return;
    }

    // Auto-submit for single choice questions or multi-choice on subsequent answers
    if (!widget.question.multiple || confirmButtonTouched) {
      confirm();
    }
  }

  void confirm() {
    if (widget.question.selectionRequired && selected.isEmpty) return;

    setState(() {
      confirmButtonTouched = true;
    });
    widget.onDone(widget.question.constructAnswer(selected));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final choiceWidgets = widget.question.choices
        .map<Widget>(
          (choice) => SelectableButton(
            selected: selected.contains(choice),
            onTap: () => tapped(choice),
            child: Text(
              choice.text,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        )
        .toList();

    if (widget.question.multiple && !confirmButtonTouched) {
      choiceWidgets.add(
        OutlinedButton(
          onPressed: widget.question.selectionRequired && selected.isEmpty
              ? null
              : confirm,
          style: OutlinedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: colorScheme.surfaceContainerHighest,
            disabledForegroundColor: colorScheme.onSurfaceVariant,
          ),
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: choiceWidgets.length,
      itemBuilder: (context, index) => choiceWidgets[index],
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }
}
