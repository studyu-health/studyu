import 'package:flutter/material.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_core/core.dart';

class const CustomSlider({
  super.key,
  // required
  final double? value,
  final double? minValue,
  final double? maxValue,
  //this.majorTick,
  final int? minorTick,
  final Function(double)? onChanged,
  final Function(double)? onChangeEnd,
  // not required
  final Color? activeColor,
  final Color? inactiveColor,
  final Color? minColor,
  final Color? maxColor,
  final Color? thumbColor,
  final bool isColored = false,
  final int labelValuePrecision = 2,
  final int tickValuePrecision = 1,
  final bool linearStep = true,
  final AnnotatedScaleQuestion? steps,
}) extends StatelessWidget {
  //final int majorTick;
  // nullable
  // nullable
  // nullable
  // nullable
  @override
  Widget build(BuildContext context) {
    final allocatedHeight = MediaQuery.of(context).size.height;
    final allocatedWidth =
        MediaQuery.of(context).size.width - 32; // -32 horizontal padding

    final divisions = (steps!.maximum - steps!.minimum) ~/ steps!.step;
    final double tickHeight = allocatedHeight * 0.0125 < 20
        ? 20
        : allocatedHeight * 0.0125;
    final labelOffset = (allocatedWidth / (divisions + 2)) * 0.5;

    final textTheme = Theme.of(context).textTheme;
    final labelTextStyle = textTheme.bodyLarge;

    // Only use annotations if they are present and non-empty
    final bool hasAnnotations = steps!.annotations.isNotEmpty;
    List<Annotation> annotations = hasAnnotations
        ? [...steps!.annotations]
        : [];

    // Ensure annotation order is correct for widget generation
    double startPosValue = steps!.minimum;
    if (hasAnnotations) {
      annotations.sort((a, b) => a.value.compareTo(b.value));
      if (steps!.maximum < steps!.minimum) {
        annotations = annotations.reversed.toList();
        startPosValue = steps!.maximum;
      }
      // Ensure that there is always an annotation object at the very start
      final missingStartPosLabel = annotations[0].value != startPosValue;
      if (missingStartPosLabel) {
        final startPosAnnotation = Annotation()
          ..annotation = ''
          ..value = startPosValue.toInt();
        annotations = [startPosAnnotation, ...annotations];
      }
    }

    bool isValueSelected(int index) {
      return index + minValue! == value;
    }

    String annotation(int index) {
      if (!hasAnnotations) return '';
      return annotations
          .firstWhere(
            (annotation) => annotation.value == index + minValue!,
            orElse: () => Annotation(),
          )
          .annotation;
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            divisions + 1,
            (index) => Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  onChanged!(index + minValue!);
                  onChangeEnd!(index + minValue!);
                },
                child: Column(
                  children: [
                    // Only show label if there are annotations and this tick has a non-empty annotation
                    if (hasAnnotations &&
                        index % (minorTick! + 1) == 0 &&
                        annotation(index).isNotEmpty)
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          annotation(index),
                          style: labelTextStyle!.copyWith(
                            fontWeight: isValueSelected(index)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Container(
                      alignment: Alignment.bottomCenter,
                      height: tickHeight,
                      child: VerticalDivider(
                        indent: index % (minorTick! + 1) == 0 ? 2 : 6,
                        thickness: 1.8,
                        color: isValueSelected(index)
                            ? thumbColor ?? primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: labelOffset),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: allocatedHeight * 0.0125 < 9
                  ? 9
                  : allocatedHeight * 0.0125,
              inactiveTickMarkColor: isColored ? activeColor : null,
              activeTrackColor: activeColor,
              inactiveTrackColor: inactiveColor,
              overlayColor: activeColor?.withValues(alpha: 0.1),
              thumbColor: thumbColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15.0),
              trackShape: CustomTrackShape(),
              showValueIndicator: ShowValueIndicator.never,
              valueIndicatorTextStyle: const TextStyle(fontSize: 12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isColored)
                  Container(
                    height: allocatedHeight * 0.0125 < 9
                        ? 9
                        : allocatedHeight * 0.0125,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      gradient: LinearGradient(colors: [minColor!, maxColor!]),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Slider(
                  value: value!,
                  min: minValue!,
                  max: maxValue!,
                  divisions: divisions,
                  onChanged: onChanged,
                  onChangeEnd: onChangeEnd,
                  label: value!.toStringAsFixed(labelValuePrecision),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTrackShape() extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
