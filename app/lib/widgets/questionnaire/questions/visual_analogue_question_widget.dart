import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

@Deprecated('Use [AnnotatedScaleQuestionWidget]')
class const VisualAnalogueQuestionWidget({
  super.key,
  required final VisualAnalogueQuestion question,
  final Function(Answer)? onDone,
  final Answer<num>? initialAnswer,
}) extends QuestionWidget {
  @Deprecated('Use [AnnotatedScaleQuestionWidget]')
  this;

  @override
  State<VisualAnalogueQuestionWidget> createState() =>
      _VisualAnalogueQuestionWidgetState();
}

@Deprecated('Use [_AnnotatedScaleQuestionWidgetState]')
class _VisualAnalogueQuestionWidgetState()
    extends State<VisualAnalogueQuestionWidget> {
  @Deprecated('Use [_AnnotatedScaleQuestionWidgetState]')
  this;

  late double value;

  @override
  void initState() {
    super.initState();
    value =
        widget.initialAnswer?.response.toDouble() ?? widget.question.initial;
  }

  void changed(double value) {
    setState(() {
      this.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.question.minimumAnnotation)),
                FittedBox(child: Text(widget.question.maximumAnnotation)),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(widget.question.minimumColor),
                    Color(widget.question.maximumColor),
                  ],
                ),
              ),
              constraints: const BoxConstraints.expand(height: 4),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: changed,
          onChangeEnd: (val) =>
              widget.onDone!(widget.question.constructAnswer(val)),
          min: widget.question.minimum,
          max: widget.question.maximum,
          divisions:
              (widget.question.maximum - widget.question.minimum) ~/
              widget.question.step,
        ),
      ],
    );
  }
}
