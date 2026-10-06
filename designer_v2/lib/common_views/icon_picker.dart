import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/typings.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class IconPack() {
  static final defaultPack = IconPack.material;

  static final List<IconOption> material = () {
    final List<IconOption> iconOptions = [];

    // TODO: migrate app + designer to standard material icons & remove library
    final iconNames = MdiIconsHelper.getNames();
    for (final iconName in iconNames) {
      final iconData = MdiIconsHelper.fromString(iconName);
      if (iconData != null) {
        iconOptions.add(IconOption(iconName, iconData));
      }
    }

    return iconOptions;
  }();

  static IconOption? resolveIconByName(
    String? name, {
    List<IconOption>? iconPack,
  }) {
    iconPack ??= IconPack.defaultPack;
    if (name == null || name.isEmpty) {
      return null;
    }
    for (final iconOption in iconPack) {
      if (iconOption.name == name) {
        return iconOption;
      }
    }
    return null;
  }
}

class const IconOption(final String name, [final IconData? icon])
    extends Equatable {
  bool get isEmpty => name == '';

  @override
  List<Object?> get props => [name];

  String toJson() => name;
  IconOption fromJson(String json) => IconOption(json);
}

class ReactiveIconPicker({
  required List<IconOption> iconOptions,
  double? selectedIconSize = 20.0,
  double? galleryIconSize = 28.0,
  double? squareFieldSize,
  double? labeledFieldWidth,
  bool useSquareField = false,
  bool showFieldLabel = false,
  bool showInlineRemove = false,
  bool readOnly = false,
  ReactiveFormFieldCallback<IconOption>? onSelect,
  super.formControl,
  super.formControlName,
  super.showErrors,
  super.validationMessages,
  super.focusNode,
  super.key,
}) extends ReactiveFocusableFormField<IconOption, IconOption> {
  this
    : super(
        builder: (ReactiveFormFieldState<IconOption, IconOption> field) {
          // Unsupported: showErrors, validationMessages
          final isDisabled = readOnly || field.control.disabled;

          return IconPicker(
            iconOptions: iconOptions,
            isDisabled: isDisabled,
            focusNode: focusNode,
            selectedOption: field.value,
            galleryIconSize: galleryIconSize,
            selectedIconSize: selectedIconSize,
            squareFieldSize: squareFieldSize,
            labeledFieldWidth: labeledFieldWidth,
            useSquareField: useSquareField,
            showFieldLabel: showFieldLabel,
            showInlineRemove: showInlineRemove,
            onSelect: (iconOption) {
              if (isDisabled) return;
              field.didChange(iconOption.isEmpty ? null : iconOption);
              onSelect?.call(field.control);
            },
          );
        },
      );
}

class const IconPicker({
  required final List<IconOption> iconOptions,
  final IconOption? selectedOption,
  final double? selectedIconSize,
  final double? galleryIconSize = 28.0,
  final double? squareFieldSize,
  final double? labeledFieldWidth,
  final bool useSquareField = false,
  final bool showFieldLabel = false,
  final bool showInlineRemove = false,
  final VoidCallbackOn<IconOption>? onSelect,
  final bool isDisabled = false,
  final FocusNode? focusNode,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconPickerField(
      iconOptions: iconOptions,
      selectedOption: selectedOption,
      selectedIconSize: selectedIconSize,
      galleryIconSize: galleryIconSize,
      squareFieldSize: squareFieldSize,
      labeledFieldWidth: labeledFieldWidth,
      useSquareField: useSquareField,
      showFieldLabel: showFieldLabel,
      showInlineRemove: showInlineRemove,
      onSelect: onSelect,
      isDisabled: isDisabled,
      focusNode: focusNode,
    );
  }
}

class const IconPickerField({
  required final List<IconOption> iconOptions,
  final IconOption? selectedOption,
  final double? selectedIconSize,
  final double? galleryIconSize,
  final double? squareFieldSize,
  final double? labeledFieldWidth,
  final bool useSquareField = false,
  final bool showFieldLabel = false,
  final bool showInlineRemove = false,
  final VoidCallbackOn<IconOption>? onSelect,
  final bool isDisabled = false,
  final FocusNode? focusNode,
  super.key,
}) extends StatelessWidget {
  static const double controlSize = 46.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actualGalleryIconSize =
        galleryIconSize ?? theme.iconTheme.size ?? 24.0;
    final actualSelectedIconSize =
        selectedIconSize ?? theme.iconTheme.size ?? 16.0;

    Future<void> openIconPicker() => showIconPickerDialog(
      context,
      iconOptions: iconOptions,
      selectedOption: selectedOption,
      galleryIconSize: actualGalleryIconSize,
      onSelect: onSelect,
    );

    final hasSelectedIcon = selectedOption != null && !selectedOption!.isEmpty;
    final selectedIcon = hasSelectedIcon
        ? selectedOption?.icon ??
              IconPack.resolveIconByName(
                selectedOption!.name,
                iconPack: iconOptions,
              )?.icon ??
              Icons.add
        : Icons.add;

    if (!useSquareField) {
      if (hasSelectedIcon) {
        return IconButton(
          tooltip: tr.iconpicker_nonempty_prompt,
          splashRadius: actualSelectedIconSize,
          onPressed: isDisabled ? null : openIconPicker,
          focusNode: focusNode,
          icon: Icon(selectedIcon, size: actualSelectedIconSize),
        );
      }

      return TextButton(
        onPressed: isDisabled ? null : openIconPicker,
        focusNode: focusNode,
        child: Text(tr.iconpicker_empty_prompt),
      );
    }

    final resolvedSquareSize = squareFieldSize ?? controlSize;
    final tooltipMessage = hasSelectedIcon
        ? tr.iconpicker_nonempty_prompt
        : tr.iconpicker_empty_prompt;
    final labelText = hasSelectedIcon
        ? tr.iconpicker_nonempty_prompt
        : tr.iconpicker_empty_prompt;
    final resolvedFieldWidth = showFieldLabel
        ? labeledFieldWidth ?? resolvedSquareSize * 3
        : resolvedSquareSize;
    final buttonChild = showFieldLabel
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selectedIcon, size: actualSelectedIconSize),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  labelText,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          )
        : Icon(selectedIcon, size: actualSelectedIconSize);
    final squareButton = OutlinedButton(
      onPressed: isDisabled ? null : openIconPicker,
      focusNode: focusNode,
      style:
          OutlinedButton.styleFrom(
            fixedSize: Size(resolvedFieldWidth, resolvedSquareSize),
            minimumSize: Size.zero,
            padding: showFieldLabel
                ? const EdgeInsets.symmetric(horizontal: 12)
                : EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: theme.inputDecorationTheme.fillColor,
            foregroundColor: theme.colorScheme.primary,
            disabledForegroundColor: theme.disabledColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            side:
                (theme.inputDecorationTheme.enabledBorder
                        as OutlineInputBorder?)
                    ?.borderSide,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return theme.colorScheme.primary.withValues(alpha: 0.12);
              }
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)) {
                return theme.colorScheme.primary.withValues(alpha: 0.08);
              }
              return null;
            }),
            side: WidgetStateProperty.resolveWith((states) {
              final decorationTheme = theme.inputDecorationTheme;
              if (states.contains(WidgetState.disabled)) {
                return (decorationTheme.disabledBorder as OutlineInputBorder?)
                        ?.borderSide ??
                    BorderSide(color: theme.disabledColor);
              }
              if (states.contains(WidgetState.focused)) {
                return (decorationTheme.focusedBorder as OutlineInputBorder?)
                        ?.borderSide ??
                    BorderSide(color: theme.colorScheme.primary);
              }
              return (decorationTheme.enabledBorder as OutlineInputBorder?)
                      ?.borderSide ??
                  BorderSide(color: theme.colorScheme.outline);
            }),
          ),
      child: buttonChild,
    );

    final squareControl = SizedBox(
      width: resolvedFieldWidth,
      height: resolvedSquareSize,
      child: Tooltip(message: tooltipMessage, child: squareButton),
    );

    if (!showInlineRemove || !hasSelectedIcon) {
      return squareControl;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        squareControl,
        SizedBox.square(
          dimension: resolvedSquareSize,
          child: IconButton(
            tooltip: tr.action_remove,
            splashRadius: actualSelectedIconSize,
            onPressed: isDisabled
                ? null
                : () => onSelect?.call(const IconOption('')),
            icon: Icon(Icons.clear, size: actualSelectedIconSize),
          ),
        ),
      ],
    );
  }
}

class const IconPickerGallery({
  required final List<IconOption> iconOptions,
  required final double iconSize,
  final VoidCallbackOn<IconOption>? onSelect,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> iconWidgets = [];
    for (final iconOption in iconOptions) {
      final iconWidget = MouseEventsRegion(
        builder: (context, state) {
          final isHovered = state.contains(WidgetState.hovered);
          return Container(
            color: isHovered
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : null,
            child: Icon(iconOption.icon, size: iconSize),
          );
        },
        onTap: () => Navigator.pop(context, iconOption),
      );
      iconWidgets.add(iconWidget);
    }

    return GridView.extent(
      primary: false,
      maxCrossAxisExtent: iconSize * 2,
      crossAxisSpacing: 4.0,
      mainAxisSpacing: 4.0,
      //padding: const EdgeInsets.all(12.0),
      children: iconWidgets,
    );
  }
}

Future<void> showIconPickerDialog(
  BuildContext context, {
  required List<IconOption> iconOptions,
  IconOption? selectedOption,
  double? galleryIconSize,
  VoidCallbackOn<IconOption>? onSelect,
  double minWidth = 300,
  double minHeight = 300,
}) async {
  final hasSelectedIcon = selectedOption != null && !selectedOption.isEmpty;
  final IconOption? iconPicked = await showDialog(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      final dialogWidth = MediaQuery.of(context).size.width * 0.4;
      final dialogHeight = MediaQuery.of(context).size.height * 0.4;

      return StandardDialog(
        body: SizedBox(
          width: max(dialogWidth, minWidth),
          height: max(dialogHeight, minHeight),
          child: IconPickerGallery(
            iconOptions: iconOptions,
            iconSize: galleryIconSize ?? 48.0,
          ),
        ),
        title: SelectableText(
          tr.iconpicker_dialog_title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.normal,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        actionButtons: [
          if (hasSelectedIcon)
            TextButton(
              onPressed: () => Navigator.pop(context, const IconOption('')),
              child: Text(tr.action_remove),
            ),
        ],
      );
    },
  );

  if (iconPicked != null && onSelect != null) {
    onSelect(iconPicked);
  }
}
