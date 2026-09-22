import 'package:flutter/widgets.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';

enum NotificationType() {
  snackbar,
  alert,
  custom,
}

/// Base class for notifications that are dispatched via [NotificationService]
/// to inform the user & capture their attention.
///
/// The currently supported notification types are:
///   [SnackbarIntent] - renders the notification as a snackbar
///   [AlertIntent] - renders the notification as an alert dialog
abstract class NotificationIntent({
  final String? message,
  final Widget? customContent,
  final IconData? icon,
  var List<NotificationAction>? actions,
  required final NotificationType type,
}) {
  this {
    if (message == null && customContent == null) {
      throw Exception("Invalid AlertIntent");
    }
  }

  void register(NotificationAction action) {
    actions ??= [];
    // upsert action by its label
    final existingIdx = actions!
        .map((action) => action.label)
        .toList()
        .indexOf(action.label);
    if (existingIdx != -1) {
      actions![existingIdx] = action;
    } else {
      actions!.add(action);
    }
  }
}

typedef FutureActionHandler = Future<void> Function();

class NotificationAction({
  required final String label,
  required final FutureActionHandler onSelect,
  final bool isDestructive = false,
});

/// Encapsulates a call to [showSnackbar]
class SnackbarIntent({
  required String super.message,
  super.icon,
  super.actions,
  final int? duration,
}) extends NotificationIntent {
  this : super(type: NotificationType.snackbar);
}

/// Encapsulates a call to [showDialog] using an alert-style widget
class AlertIntent({
  required final String title,
  super.message,
  super.customContent,
  super.icon,
  super.actions,
  final bool dismissOnAction = true,
}) extends NotificationIntent {
  this : super(type: NotificationType.alert);

  bool get isDestructive =>
      actions != null && actions!.any((action) => action.isDestructive);
}
