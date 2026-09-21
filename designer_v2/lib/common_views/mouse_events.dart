import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef MouseEventsRegionBuilder = Widget Function(
  BuildContext context,
  Set<WidgetState> state,
);

typedef MaterialStatesChangedCallback = void Function(Set<WidgetState> state);

/// Helper widget that allows specifying both [onHover] and [onTap] callbacks
/// for the widget it contains while exposing the current interaction state
/// as a [WidgetInteractionState] to the child widget [builder]
class const MouseEventsRegion({
  required final MouseEventsRegionBuilder builder,
  final MaterialStatesChangedCallback? onStateChanged,
  final PointerHoverEventListener? onHover,
  final GestureTapCallback? onTap,
  final PointerEnterEventListener? onEnter,
  final PointerExitEventListener? onExit,
  final SystemMouseCursor cursor = defaultCursor,
  final bool autoselectCursor = true,
  super.key,
}) extends StatefulWidget {
  static const defaultCursor = SystemMouseCursors.basic;

  SystemMouseCursor get autoCursor {
    if (!autoselectCursor || cursor != defaultCursor) {
      return cursor;
    }
    if (onTap != null) {
      return SystemMouseCursors.click;
    }
    return SystemMouseCursors.basic;
  }

  @override
  State<MouseEventsRegion> createState() => _MouseEventsRegionState();
}

class _MouseEventsRegionState() extends State<MouseEventsRegion> {
  late final WidgetStatesController statesController;

  void handleStatesControllerChange() {
    widget.onStateChanged?.call(statesController.value);
    // Force a rebuild to resolve MaterialStateProperty properties
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    statesController = WidgetStatesController();
    statesController.addListener(handleStatesControllerChange);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => statesController.update(WidgetState.pressed, true),
      onTapUp: (_) => statesController.update(WidgetState.pressed, false),
      onTapCancel: () => statesController.update(WidgetState.pressed, false),
      child: MouseRegion(
        cursor: widget.autoCursor,
        onHover: (e) {
          widget.onHover?.call(e);
        },
        onEnter: (e) {
          statesController.update(WidgetState.hovered, true);
          widget.onEnter?.call(e);
        },
        onExit: (e) {
          statesController.update(WidgetState.hovered, false);
          widget.onExit?.call(e);
        },
        child: widget.builder(context, statesController.value),
      ),
    );
  }

  @override
  void dispose() {
    statesController.removeListener(handleStatesControllerChange);
    statesController.dispose();
    super.dispose();
  }
}
