import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

class const CustomSlider({
  super.key,
  final double? value,
  final double? minValue,
  final double? maxValue,
  final int? minorTick,
  final Function(double)? onChanged,
  final Function(double)? onChangeEnd,
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final numberFormat = NumberFormat(
      '0.##########',
      Localizations.localeOf(context).toLanguageTag(),
    );
    final annotations =
        steps!.annotations
            .where(
              (annotation) =>
                  annotation.annotation.trim().isNotEmpty &&
                  annotation.value >= minValue! &&
                  annotation.value <= maxValue!,
            )
            .toList()
          ..sort((a, b) => a.value.compareTo(b.value));
    final hasIntermediateLabels = annotations.any(
      (annotation) =>
          annotation.value > minValue! && annotation.value < maxValue!,
    );

    String annotationFor(double number) =>
        annotations
            .where(
              (annotation) =>
                  ((annotation.value - number) / steps!.step).abs() < 1e-9,
            )
            .map((annotation) => annotation.annotation)
            .firstOrNull ??
        '';

    String semanticValue(double number) {
      final annotation = annotationFor(number);
      final formattedNumber = numberFormat.format(number);
      return annotation.isEmpty || annotation.trim() == formattedNumber
          ? formattedNumber
          : '$formattedNumber, $annotation';
    }

    Widget endpoint(double number, TextAlign alignment) {
      final annotation = annotationFor(number);
      return Expanded(
        child: Text(
          annotation,
          style: theme.textTheme.bodyMedium,
          textAlign: alignment,
        ),
      );
    }

    final selectedAnnotation = annotationFor(value!);
    final divisions = (steps!.maximum - steps!.minimum) ~/ steps!.step;
    final direction = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final labelStyle = theme.textTheme.bodyMedium!;
    final trackHeight = SliderTheme.of(context).trackHeight ?? 16;

    Size measure(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: MediaQuery.boldTextOf(context)
              ? style.copyWith(fontWeight: FontWeight.bold)
              : style,
        ),
        textDirection: direction,
        textScaler: textScaler,
        locale: Localizations.localeOf(context),
      )..layout();
      final size = painter.size;
      painter.dispose();
      return size;
    }

    final minNumber = numberFormat.format(minValue);
    final maxNumber = numberFormat.format(maxValue);
    final numberStyle = theme.textTheme.labelLarge!;
    final minNumberSize = measure(minNumber, numberStyle);
    final maxNumberSize = measure(maxNumber, numberStyle);
    final widestNumber = minNumberSize.width > maxNumberSize.width
        ? minNumberSize.width
        : maxNumberSize.width;
    final trackPadding = widestNumber / 2 > 24 ? widestNumber / 2 : 24.0;
    // Rounded discrete tracks inset the stop centers by half the track height.
    final stopInset = trackPadding + trackHeight / 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        double position(double number) {
          final fraction = (number - minValue!) / (maxValue! - minValue!);
          final visual = direction == TextDirection.ltr
              ? fraction
              : 1 - fraction;
          return stopInset + visual * (constraints.maxWidth - 2 * stopInset);
        }

        final labels = [
          for (final annotation in annotations)
            (
              text: annotation.annotation,
              center: position(annotation.value.toDouble()),
              size: measure(annotation.annotation, labelStyle),
            ),
          if (annotationFor(minValue!).isEmpty)
            (
              text: minNumber,
              center: position(minValue!),
              size: measure(minNumber, labelStyle),
            ),
          if (annotationFor(maxValue!).isEmpty)
            (
              text: maxNumber,
              center: position(maxValue!),
              size: measure(maxNumber, labelStyle),
            ),
        ]..sort((a, b) => a.center.compareTo(b.center));
        final showInlineLabels =
            labels.isNotEmpty &&
            labels.every(
              (label) =>
                  !label.text.contains('\n') &&
                  label.center - label.size.width / 2 >= 0 &&
                  label.center + label.size.width / 2 <= constraints.maxWidth,
            ) &&
            [
              for (var i = 1; i < labels.length; i++)
                labels[i].center - labels[i].size.width / 2 >=
                    labels[i - 1].center + labels[i - 1].size.width / 2 + 8,
            ].every((fits) => fits);
        final visibleLabels = showInlineLabels
            ? labels
            : [
                (
                  text: minNumber,
                  center: position(minValue!),
                  size: minNumberSize,
                ),
                (
                  text: maxNumber,
                  center: position(maxValue!),
                  size: maxNumberSize,
                ),
              ];
        final labelHeight = visibleLabels
            .map((label) => label.size.height)
            .reduce((a, b) => a > b ? a : b);
        final showHelp = hasIntermediateLabels && !showInlineLabels;
        final selectedLabelIsVisible =
            (showInlineLabels && selectedAnnotation.isNotEmpty) ||
            value == minValue ||
            value == maxValue;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHelp)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Tooltip(
                  message: l10n.scale_labels,
                  excludeFromSemantics: true,
                  child: TextButton.icon(
                    key: const ValueKey('slider_scale_labels'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.scale_labels),
                        scrollable: true,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final annotation in annotations)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  '${numberFormat.format(annotation.value)}: '
                                  '${annotation.annotation}',
                                ),
                              ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.close),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.info_outline),
                    label: Text(l10n.scale_labels),
                  ),
                ),
              ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                year2023: false,
                trackHeight: trackHeight,
                activeTrackColor: activeColor,
                inactiveTrackColor: inactiveColor,
                thumbColor: thumbColor,
                trackShape: isColored
                    ? _GradientSliderTrackShape(minColor!, maxColor!)
                    : null,
              ),
              child: Slider(
                value: value!,
                min: minValue!,
                max: maxValue!,
                divisions: divisions > 0 ? divisions : null,
                padding: EdgeInsets.symmetric(
                  horizontal: trackPadding,
                  vertical: 2,
                ),
                onChanged: onChanged,
                onChangeEnd: onChangeEnd,
                label: numberFormat.format(value),
                semanticFormatterCallback: semanticValue,
              ),
            ),
            SizedBox(
              height: labelHeight,
              child: Stack(
                children: [
                  for (final label in visibleLabels)
                    Positioned(
                      left: label.center - label.size.width / 2,
                      width: label.size.width,
                      child: Text(
                        label.text,
                        style: showInlineLabels ? labelStyle : numberStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            if (!showInlineLabels &&
                (annotationFor(minValue!).isNotEmpty ||
                    annotationFor(maxValue!).isNotEmpty))
              Padding(
                padding: EdgeInsets.fromLTRB(trackPadding, 4, trackPadding, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    endpoint(minValue!, TextAlign.start),
                    const SizedBox(width: 24),
                    endpoint(maxValue!, TextAlign.end),
                  ],
                ),
              ),
            if (!selectedLabelIsVisible)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  key: const ValueKey('slider_selected_value'),
                  selectedAnnotation.isEmpty
                      ? numberFormat.format(value)
                      : selectedAnnotation,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }
}

class const _GradientSliderTrackShape(
  final Color minColor,
  final Color maxColor,
) extends GappedSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    // Use the native track as a mask to preserve its gap and rounded corners.
    context.canvas.saveLayer(trackRect, Paint());
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme.copyWith(
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white,
      ),
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
    );
    context.canvas.drawRect(
      trackRect,
      Paint()
        ..shader = LinearGradient(
          colors: [minColor, maxColor],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ).createShader(trackRect, textDirection: textDirection)
        ..blendMode = BlendMode.srcIn,
    );
    context.canvas.restore();
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
    );
  }
}
