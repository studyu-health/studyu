import 'package:flutter/material.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_app/widgets/questionnaire/custom_slider.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class const ScaleQuestionWidget({
  super.key,
  required final ScaleQuestion question,
  final Function(Answer)? onDone,
  final Answer<num>? initialAnswer,
}) extends QuestionWidget {
  @override
  State<ScaleQuestionWidget> createState() => _ScaleQuestionWidgetState();
}

class _ScaleQuestionWidgetState() extends State<ScaleQuestionWidget> {
  double? value;

  @override
  void initState() {
    super.initState();
    value =
        widget.initialAnswer?.response.toDouble() ?? widget.question.initial;
  }

  @override
  Widget build(BuildContext context) {
    final sliderRange = (widget.question.maximum - widget.question.minimum)
        .abs();

    Color? minColor = widget.question.minColor != null
        ? Color(widget.question.minColor!)
        : null;
    Color? maxColor = widget.question.maxColor != null
        ? Color(widget.question.maxColor!)
        : null;

    final isColored = minColor != null || maxColor != null;
    if (isColored) {
      // set defaults if one or the other is undefined
      minColor ??= Colors.white;
      maxColor ??= Colors.white;
    }

    final theme = Theme.of(context);
    final coloredSliderTheme = ThemeConfig.coloredSliderTheme(theme);
    final thumbColor = isColored
        ? Color.lerp(
            minColor,
            maxColor,
            (value! - widget.question.minimum) / sliderRange,
          )!.withValues(alpha: 1)
        : null;
    final activeTrackColor = isColored
        ? coloredSliderTheme.activeTrackColor
        : null;
    final inactiveTrackColor = isColored
        ? coloredSliderTheme.inactiveTrackColor
        : null;

    return Column(
      children: [
        Stack(
          children: [
            Theme(
              data: isColored
                  ? theme.copyWith(
                      sliderTheme: SliderThemeData(
                        overlayColor: thumbColor!.withValues(alpha: 0.5),
                      ),
                    )
                  : theme,
              child: CustomSlider(
                minValue: widget.question.minimum,
                maxValue: widget.question.maximum,
                value: value,
                minorTick: 0,
                labelValuePrecision: 0,
                tickValuePrecision: 0,
                onChanged: (val) => setState(() {
                  value = val;
                  //print('Slider value (linear): $value');
                }),
                onChangeEnd: (val) => setState(() {
                  value = val;
                  widget.onDone!(widget.question.constructAnswer(value!));
                }),
                activeColor: activeTrackColor,
                inactiveColor: inactiveTrackColor,
                thumbColor: thumbColor,
                minColor: minColor,
                maxColor: maxColor,
                isColored: isColored,
                linearStep: false,
                steps: widget.question,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
