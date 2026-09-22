import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/unsaved_changes_dialog.dart';
import 'package:studyu_designer_v2/theme.dart';

/// Signature for a builder that renders the widget corresponding to the
/// [FormViewModel] of type [T]
typedef FormViewBuilder<T extends FormViewModel> = Widget Function(
  T formViewModel,
);

/// Signature for a builder that resolves the [FormViewModel] of type [T]
/// via a Riverpod [WidgetRef]
typedef FormViewModelBuilder<T extends FormViewModel> = T Function(
  WidgetRef ref,
);

class const FormScaffold<T extends FormViewModel>({
  required final T formViewModel,
  required final Widget body,
  final List<Widget>? actions,
  final Widget? drawer,
  final double actionsSpacing = 8.0,
  final double actionsPadding = 24.0,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<FormScaffold<T>> createState() => _FormScaffoldState();
}

class _FormScaffoldState<T extends FormViewModel>()
    extends ConsumerState<FormScaffold<T>>
    implements PopEntry {
  T get formViewModel => widget.formViewModel;

  ModalRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route?.unregisterPopEntry(this);
    _route = ModalRoute.of(context);
    _route?.registerPopEntry(this);
  }

  @override
  void dispose() {
    _route?.unregisterPopEntry(this);
    _route = null;
    super.dispose();
  }

  @override
  ValueListenable<bool> get canPopNotifier => ValueNotifier(false);

  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {
    if (didPop) {
      return;
    }
    _promptBackNavigationConfirmation();
  }

  Future<void> _promptBackNavigationConfirmation() async {
    if (!formViewModel.isDirty) {
      await formViewModel.cancel();
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    final shouldPop = await showDialog<bool>(
      context: context,
      barrierColor: ThemeConfig.modalBarrierColor(Theme.of(context)),
      builder: (context) => const UnsavedChangesDialog(),
    );
    if (shouldPop!) {
      await formViewModel.cancel();
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultActionButtons = buildFormButtons(
      formViewModel,
      formViewModel.formMode,
    );

    // Wraps the whole side sheet in a [ReactiveForm] widget
    Widget inForm(widget) {
      return ReactiveForm(
        formGroup: formViewModel.form,
        child: widget as Widget,
      );
    }

    final theme = Theme.of(context);

    return inForm(
      Scaffold(
        appBar: AppBar(
          iconTheme: theme.iconTheme,
          // TODO: enable async title here
          title: Text(
            formViewModel.title,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleSmall,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          actions: withSpacing(
            widget.actions ?? defaultActionButtons,
            spacing: widget.actionsSpacing,
            paddingStart: widget.actionsPadding,
            paddingEnd: widget.actionsPadding,
          ),
        ),
        body: widget.body,
        drawer: widget.drawer,
      ),
    );
  }

  @override
  void onPopInvoked(bool didPop) {
    // Deprecated
  }
}
