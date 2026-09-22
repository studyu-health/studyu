import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/utils/typings.dart';

class const PrimaryButton({
  /// The text displayed as the button label
  required final String text,

  /// The icon displayed to the left of the label
  final IconData? icon = Icons.add,
  final String tooltip = "",
  final String tooltipDisabled = "",

  /// If true, a loading indicator is displayed instead of the text
  final bool isLoading = false,

  /// Callback to be called when the button is pressed
  final VoidCallback? onPressed,
  final FutureFactory? onPressedFuture,
  final bool enabled = true,
  final int showLoadingEarliestAfterMs = 100,
  final EdgeInsets innerPadding = const EdgeInsets.symmetric(
    horizontal: 4.0,
    vertical: 8.0,
  ),
  final Size? minimumSize,
  final Color? backgroundColor,
  final Color? foregroundColor,
  super.key,
}) extends StatefulWidget {
  bool get isDisabled =>
      !enabled || (onPressed == null && onPressedFuture == null);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState() extends State<PrimaryButton> {
  Future trackedFuture = Future.value();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryStyle = ElevatedButton.styleFrom(
      foregroundColor: widget.foregroundColor ?? theme.colorScheme.onPrimary,
      backgroundColor: widget.backgroundColor ?? theme.colorScheme.primary,
      minimumSize: widget.minimumSize,
    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));

    final tooltipMessage = (!widget.isDisabled)
        ? widget.tooltip
        : widget.tooltipDisabled;

    void onButtonPressed() {
      widget.onPressed?.call();
      if (widget.onPressedFuture != null) {
        final future = widget.onPressedFuture!().whenComplete(() {
          if (mounted) {
            setState(() {
              trackedFuture = Future.value();
            });
          }
        });
        Future.delayed(
          Duration(milliseconds: widget.showLoadingEarliestAfterMs),
          () {
            if (mounted) {
              setState(() {
                trackedFuture = future;
              });
            }
          },
        );
      }
    }

    if (widget.icon != null) {
      return Tooltip(
        message: tooltipMessage,
        child: ElevatedButton(
          style: primaryStyle,
          onPressed: (widget.isDisabled) ? null : onButtonPressed,
          child: Padding(
            padding: widget.innerPadding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: theme.iconTheme.size ?? 14.0,
                    height: theme.iconTheme.size ?? 14.0,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                else
                  Icon(widget.icon),
                const SizedBox(width: 6.0),
                Text(widget.text, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltipMessage,
      child: ElevatedButton(
        style: primaryStyle,
        onPressed: widget.isDisabled ? null : onButtonPressed,
        child: Padding(
          padding: widget.innerPadding,
          child: widget.isLoading
              ? SizedBox(
                  width: theme.iconTheme.size ?? 14.0,
                  height: theme.iconTheme.size ?? 14.0,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                )
              : Text(widget.text, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
