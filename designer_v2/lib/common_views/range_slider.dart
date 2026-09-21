// Workaround to always show the value indicator for the range slider
// Source: https://github.com/flutter/flutter/issues/34704#issuecomment-1338849463
import 'package:flutter/material.dart';

class IndicatorRangeSliderThumbShape<T>(
  final BuildContext buildContext,
  var T start,
  var T end,
) extends RangeSliderThumbShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(15, 40);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool? isDiscrete,
    bool? isEnabled,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    if (thumb == null) return;

    final Canvas canvas = context.canvas;
    canvas.drawCircle(
      center,
      9,
      Paint()..color = Theme.of(buildContext).colorScheme.primary,
    );
    final value = thumb == Thumb.start ? start : end;

    // Customize the box style
    final boxPaint = Paint()
      ..color = const Color(0xff6d7073).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const borderRadius = Radius.circular(4.0); // Customize border radius

    // Calculate text size and position
    final text = value.toString();
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(color: Colors.white),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: textDirection ?? TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate the box size with padding
    final boxWidth = textPainter.width + 16.0;
    final boxHeight = textPainter.height + 6.0;

    // Draw the text in the middle of the box
    final textOffset = center + Offset(-textPainter.width / 2, 15);

    // Draw the rounded rectangle box with border centered around the text
    final boxOffset =
        textOffset +
        Offset(
          textPainter.width / 2 - boxWidth / 2,
          textPainter.height / 2 - boxHeight / 2,
        );
    final boxRect = Rect.fromLTWH(
      boxOffset.dx,
      boxOffset.dy,
      boxWidth,
      boxHeight,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, borderRadius), boxPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, borderRadius),
      borderPaint,
    );

    // Draw the text inside the box
    textPainter.paint(canvas, textOffset);
  }
}
