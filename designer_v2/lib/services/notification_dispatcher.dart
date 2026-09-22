import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/confirmation_dialog.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';

/// A wrapper widgets that is subscribed to the [NotificationService] and
/// automatically dispatches its [NotificationIntent]s to show a Snackbar.
class const NotificationDispatcher({
  /// Pass-through widget that is rendered as is
  required final Widget? child,

  /// The global key used for looking up the [Scaffold] reference
  /// If not specified explicitly, falls back `ScaffoldMessenger.of(context)`
  /// to look up the closest instance of [ScaffoldMessengerState]
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey,

  /// The global key used for looking up the [Navigator] reference
  /// If not specified explicitly, falls back `Navigator.of(context)`
  /// to look up the closest instance of [NavigatorState]
  final GlobalKey<NavigatorState>? navigatorKey,
  final double? snackbarWidth,
  final double snackbarInnerPadding = 16.0,
  final SnackBarBehavior snackbarBehavior = SnackBarBehavior.fixed,
  final int snackbarDefaultDuration = 2500,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationDispatcherState();
}

class _NotificationDispatcherState()
    extends ConsumerState<NotificationDispatcher> {
  /// Subscription to a stream of [NotificationIntent]s to be dispatched
  late final StreamSubscription<NotificationIntent> _subscription;

  bool _isValidated = false;

  @override
  void initState() {
    super.initState();
    _subscription = ref
        .read(notificationServiceProvider)
        .watchNotifications()
        .listen(_handleNotification);
  }

  ScaffoldMessengerState _getMessengerState() {
    final ScaffoldMessengerState messengerState;
    try {
      if (widget.scaffoldMessengerKey != null) {
        messengerState = widget.scaffoldMessengerKey!.currentState!;
      } else {
        messengerState = ScaffoldMessenger.of(context);
      }
    } catch (_) {
      throw Exception(
        "NotificationDispatcher could not obtain reference to "
        "ScaffoldMessengerState. Make sure the widget is placed below "
        "a Scaffold or MaterialApp in the widget tree, or provide a reference "
        "via the scaffoldMessengerKey global key.",
      );
    }
    return messengerState;
  }

  NavigatorState? _getNavigatorState() {
    final NavigatorState? navigatorState;
    try {
      if (widget.navigatorKey != null) {
        // [NavigatorState] may be null during initial build / validation when
        // navigator is not initialized yet. As long as there is a valid key
        // we should be good!
        navigatorState = widget.navigatorKey!.currentState;
      } else {
        navigatorState = Navigator.of(context);
      }
    } catch (_) {
      throw Exception(
        "NotificationDispatcher context could not obtain reference to "
        "NavigatorState. Make sure the NotificationDispatcher is placed below "
        "a Navigator in the widget tree, or provide a reference via the "
        "navigatorKey global key.",
      );
    }
    return navigatorState;
  }

  void _handleNotification(NotificationIntent notification) {
    switch (notification.type) {
      case NotificationType.snackbar:
        final messengerState = _getMessengerState();
        messengerState.showSnackBar(
          _buildSnackbar(notification as SnackbarIntent, messengerState),
        );
      case NotificationType.alert:
        final navigatorState = _getNavigatorState();
        if (navigatorState == null) {
          throw Exception(
            "NotificationDispatcher could not obtain reference to NavigatorState "
            "for alert notification. Make sure the widget is placed below a Navigator "
            "in the widget tree, or provide a reference via the navigatorKey global key.",
          );
        }
        showDialog(
          context: navigatorState.context,
          builder: (BuildContext context) =>
              _buildAlertDialog(notification as AlertIntent, navigatorState),
        );
      default:
        throw UnimplementedError(
          "Failed to handle NotificationIntent of unexpected type.",
        );
    }
  }

  Widget _buildAlertDialog(
    AlertIntent notification,
    NavigatorState navigatorState,
  ) {
    final List<ConfirmationDialogAction> actions = [];
    if (notification.actions != null) {
      for (final action in notification.actions!) {
        actions.add(
          ConfirmationDialogAction(
            label: action.label,
            isDestructive: action.isDestructive,
            onPressed: () {
              if (notification.dismissOnAction) {
                // always pop & don't wait for [action.onSelect]
                navigatorState.pop();
              }
              action.onSelect();
            },
          ),
        );
      }
    }

    return StandardConfirmationDialog(
      title: notification.title,
      message: notification.message,
      customContent: notification.customContent,
      icon: notification.icon,
      actions: actions,
    );
  }

  SnackBar _buildSnackbar(
    SnackbarIntent notification,
    ScaffoldMessengerState messengerState,
  ) {
    final theme = Theme.of(context);

    return SnackBar(
      width: (widget.snackbarBehavior == SnackBarBehavior.floating)
          ? widget.snackbarWidth
          : null,
      content: Row(
        children: [
          if (notification.icon != null)
            Padding(
              padding: EdgeInsets.all(0.5 * widget.snackbarInnerPadding),
              child: Icon(
                notification.icon,
                size: 2 / 3 * widget.snackbarInnerPadding,
                color: theme.snackBarTheme.actionTextColor,
              ),
            )
          else
            const SizedBox.shrink(),
          Text(
            notification.message!,
            style: theme.textTheme.titleMedium!.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
      duration: Duration(
        milliseconds: notification.duration ?? widget.snackbarDefaultDuration,
      ),
      // Keep actionable snackbars auto-dismissing; Flutter now defaults
      // `persist` to true when an action is present.
      persist: false,
      padding: EdgeInsets.fromLTRB(
        2.5 * widget.snackbarInnerPadding,
        widget.snackbarInnerPadding,
        1.5 * widget.snackbarInnerPadding,
        widget.snackbarInnerPadding,
      ),
      behavior: widget.snackbarBehavior,
      showCloseIcon: true,
      closeIconColor: theme.colorScheme.onPrimary,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Try to obtain a [ScaffoldMessengerState] as an initial check that this
    // widget is placed correctly in the widget tree
    if (!_isValidated) {
      _getMessengerState();
      _getNavigatorState();
      // Remember validation for future builds avoiding setState during build
      Future.delayed(Duration.zero, () => setState(() => _isValidated = true));
    }
    return widget.child ?? Container();
  }
}
