import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/questionnaire/custom_slider.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class const AnnotatedScaleQuestionWidget({
  super.key,
  required final AnnotatedScaleQuestion question,
  final Function(Answer)? onDone,
  final Answer<num>? initialAnswer,
}) extends QuestionWidget {
  @override
  State<AnnotatedScaleQuestionWidget> createState() =>
      _AnnotatedScaleQuestionWidgetState();
}

class _AnnotatedScaleQuestionWidgetState()
    extends State<AnnotatedScaleQuestionWidget> {
  double? value;

  @override
  void initState() {
    super.initState();
    value =
        widget.initialAnswer?.response.toDouble() ?? widget.question.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomSlider(
          minValue: widget.question.minimum,
          maxValue: widget.question.maximum,
          value: value,
          minorTick: 0,
          labelValuePrecision: 0,
          tickValuePrecision: 0,
          onChanged: (val) => setState(() {
            value = val;
            // actualValue = annotations[(val / widget.question.maximum+1 * (annotations.length)).ceil().toInt()];
            // print('Slider value (linear): $value');
            // print('Actual value (non-linear): $actualValue');
            //widget.onDone(widget.question.constructAnswer(value));
          }),
          onChangeEnd: (val) => setState(() {
            value = val;
            widget.onDone!(widget.question.constructAnswer(value!));
          }),
          activeColor: Theme.of(context).primaryColor,
          linearStep: false,
          steps: widget.question,
        ),
      ],
    );
  }
}
