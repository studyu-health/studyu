import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/utils/color.dart';

/// Adaption of [ReactiveColorPicker] from 'reactive_color_picker' package
/// to work with [SerializableColor] & render a trigger/preview widget

/// A builder that builds a widget responsible to decide when to show
/// the picker dialog.
///
/// It has a property to access the [FormControl]
/// that is bound to [ReactiveCustomColorPicker].
///
/// The [formControlName] is required to bind this [ReactiveColorPicker]
/// to a [FormControl].
///
/// ## Example:
///
/// ```dart
/// ReactiveBlocColorPicker(
///   formControlName: 'birthday',
/// )
/// ```
class ReactiveCustomColorPicker<T>({
  super.key,
  super.formControlName,
  super.formControl,
  super.validationMessages,
  ////////////////////////////////////////////////////////////////////////////
  Color? contrastIconColorLight,
  Color contrastIconColorDark = Colors.white,
  InputDecoration? decoration,
  PaletteType paletteType = PaletteType.hsv,
  bool enableAlpha = true,
  @Deprecated('Use empty list in [labelTypes] to disable label.')
  bool showLabel = true,
  @Deprecated(
    'Use Theme.of(context).textTheme.bodyText1 & 2 to alter text style.',
  )
  TextStyle? labelTextStyle,
  bool displayThumbColor = false,
  bool portraitOnly = false,
  bool hexInputBar = false,
  double colorPickerWidth = 300.0,
  double pickerAreaHeightPercent = 1.0,
  BorderRadius pickerAreaBorderRadius = BorderRadius.zero,
  double disabledOpacity = 0.5,
  HSVColor? pickerHsvColor,
  List<ColorLabelType> labelTypes = const [
    ColorLabelType.rgb,
    ColorLabelType.hsv,
    ColorLabelType.hsl,
  ],
  TextEditingController? hexInputController,
  List<Color>? colorHistory,
  ValueChanged<List<Color>>? onHistoryChanged,
}) extends ReactiveFormField<T, Color> {
  /// Creates a [ReactiveCustomColorPicker] that wraps the function [showDatePicker].
  ///
  /// Can optionally provide a [formControl] to bind this widget to a control.
  ///
  /// Can optionally provide a [formControlName] to bind this ReactiveFormField
  /// to a [FormControl].
  ///
  /// Must provide one of the arguments [formControl] or a [formControlName],
  /// but not both at the same time.
  this
    : super(
        builder: (field) {
          void showColorDialog(
            BuildContext context, {
            required Color pickerColor,
            required ValueChanged<Color> onColorChanged,
          }) {
            showDialog<Color>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  titlePadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.zero,
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: onColorChanged,
                      paletteType: paletteType,
                      enableAlpha: enableAlpha,
                      pickerHsvColor: pickerHsvColor,
                      labelTypes: labelTypes,
                      displayThumbColor: displayThumbColor,
                      portraitOnly: portraitOnly,
                      colorPickerWidth: colorPickerWidth,
                      pickerAreaHeightPercent: pickerAreaHeightPercent,
                      pickerAreaBorderRadius: pickerAreaBorderRadius,
                      hexInputBar: hexInputBar,
                      hexInputController: hexInputController,
                      colorHistory: colorHistory,
                      onHistoryChanged: onHistoryChanged,
                    ),
                  ),
                );
              },
            );
          }

          final isEmptyValue =
              field.value == null || field.value.toString().isEmpty;

          final InputDecoration effectiveDecoration =
              (decoration ?? const InputDecoration()).applyDefaults(
                Theme.of(field.context).inputDecorationTheme,
              );

          final iconColor = (field.value?.computeLuminance() ?? 0) < 0.2
              ? contrastIconColorDark
              : contrastIconColorLight;

          return IgnorePointer(
            ignoring: !field.control.enabled,
            child: Opacity(
              opacity: field.control.enabled ? 1 : disabledOpacity,
              child: Listener(
                onPointerDown: (_) => field.control.markAsTouched(),
                child: InputDecorator(
                  decoration: effectiveDecoration.copyWith(
                    errorText: field.errorText,
                    enabled: field.control.enabled,
                    fillColor: field.value,
                    filled: field.value != null,
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          color: iconColor,
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showColorDialog(
                              field.context,
                              pickerColor: field.value ?? Colors.transparent,
                              onColorChanged: (color) {
                                // Convert between non-serializable [Color]
                                // superclass that color_picker expects &
                                // the [SerializableColor] type of the control
                                field.didChange(
                                  SerializableColor(color.toARGB32()),
                                );
                              },
                            );
                          },
                          splashRadius: 0.01,
                        ),
                        if (field.value != null)
                          IconButton(
                            color: iconColor,
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              field.didChange(null);
                            },
                            splashRadius: 0.01,
                          ),
                      ],
                    ),
                  ),
                  isEmpty: isEmptyValue && effectiveDecoration.hintText == null,
                  child: Container(color: field.value),
                ),
              ),
            ),
          );
        },
      );
}
