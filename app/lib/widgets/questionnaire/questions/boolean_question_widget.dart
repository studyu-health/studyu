import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_app/widgets/selectable_button.dart';
import 'package:studyu_core/core.dart';

class const BooleanQuestionWidget({
  super.key,
  required final BooleanQuestion question,
  final Function(Answer)? onDone,
  final Answer<bool>? initialAnswer,
}) extends QuestionWidget {
  @override
  State<BooleanQuestionWidget> createState() => _BooleanQuestionWidgetState();
}

class _BooleanQuestionWidgetState() extends State<BooleanQuestionWidget> {
  bool? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialAnswer?.response;
  }

  void tapped({bool? choice}) {
    setState(() {
      selected = choice;
      widget.onDone!(widget.question.constructAnswer(selected!));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectableButton(
          selected: selected == true,
          onTap: () => tapped(choice: true),
          child: Text(AppLocalizations.of(context)!.yes),
        ),
        const SizedBox(height: 8),
        SelectableButton(
          selected: selected == false,
          onTap: () => tapped(choice: false),
          child: Text(AppLocalizations.of(context)!.no),
        ),
      ],
    );
  }
}
