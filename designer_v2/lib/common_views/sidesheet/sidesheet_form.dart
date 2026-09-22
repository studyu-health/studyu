import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_scaffold.dart';
import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/unsaved_changes_dialog.dart';
import 'package:studyu_designer_v2/theme.dart';

class FormSideSheetTab<T extends FormViewModel>({
  required super.title,
  required super.index,

  /// The widget to be rendered as the sidesheet content with a [FormViewModel]
  /// of type [T] when the tab is selected
  required var FormViewBuilder<T> formViewBuilder,
  super.enabled,
}) extends NavbarTab;

class const _FormSidesheetPopEntry<T extends FormViewModel>({
  required final T formViewModel,
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<_FormSidesheetPopEntry<T>> createState() =>
      _FormSidesheetPopEntryState<T>();
}

class _FormSidesheetPopEntryState<T extends FormViewModel>()
    extends State<_FormSidesheetPopEntry<T>>
    implements PopEntry {
  ModalRoute<dynamic>? _route;
  final ValueNotifier<bool> _canPopNotifier = ValueNotifier(false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route?.unregisterPopEntry(this);
    _route = ModalRoute.of(context);
    debugPrint('[PopEntry] registering with route: ${_route.runtimeType}');
    _route?.registerPopEntry(this);
  }

  @override
  void dispose() {
    _route?.unregisterPopEntry(this);
    _route = null;
    _canPopNotifier.dispose();
    super.dispose();
  }

  @override
  ValueListenable<bool> get canPopNotifier => _canPopNotifier;

  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {
    debugPrint(
      '[PopEntry] onPopInvokedWithResult didPop=$didPop canPop=${_canPopNotifier.value}',
    );
    if (didPop) {
      return;
    }
    _handleDismiss();
  }

  @override
  void onPopInvoked(bool didPop) {
    // Deprecated
  }

  Future<void> _handleDismiss() async {
    debugPrint(
      '[PopEntry] _handleDismiss isDirty=${widget.formViewModel.isDirty}',
    );
    _canPopNotifier.value = false;

    if (!widget.formViewModel.isDirty) {
      await widget.formViewModel.cancel();
      if (mounted) {
        _schedulePop();
      }
      return;
    }

    // Dirty state logic
    final shouldDiscard = await showDialog<bool>(
      context: context,
      barrierColor: ThemeConfig.modalBarrierColor(Theme.of(context)),
      builder: (context) => const UnsavedChangesDialog(),
    );

    if (shouldDiscard == true && mounted) {
      await widget.formViewModel.cancel();
      if (mounted) {
        _schedulePop();
      }
    }
  }

  void _schedulePop() {
    _canPopNotifier.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _popCurrentRoute();
      }
    });
  }

  void _popCurrentRoute() {
    final navigator = _route?.navigator;
    if (navigator == null || !navigator.canPop()) {
      return;
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<Object?> showFormSideSheet<T extends FormViewModel>({
  required BuildContext context,
  required T formViewModel,
  FormViewBuilder<T>? formViewBuilder,
  List<FormSideSheetTab<T>>? tabs,
  List<Widget>? actionButtons,
  double? width,
  bool withCloseButton = false,
  bool ignoreAppBar = true,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  barrierColor ??= ThemeConfig.modalBarrierColor(Theme.of(context));

  // Wraps the whole side sheet in a [ReactiveForm] widget
  Widget wrapInForm(Widget widget) {
    return ReactiveForm(formGroup: formViewModel.form, child: widget);
  }

  // Bind the [formViewModel] to the [SidesheetTab]s' widget builder
  final List<SidesheetTab>? boundTabs = tabs
      ?.map(
        (t) => SidesheetTab(
          title: t.title,
          index: t.index,
          enabled: t.enabled,
          builder: (BuildContext context) => t.formViewBuilder(formViewModel),
        ),
      )
      .toList();

  return showModalSideSheet(
    context: context,
    title: formViewModel.title,
    body: formViewBuilder?.call(formViewModel), // inject viewmodel
    tabs: boundTabs,
    actionButtons:
        actionButtons ??
        buildFormButtons(formViewModel, formViewModel.formMode),
    wrapContent: wrapInForm,
    width: width,
    withCloseButton: withCloseButton,
    ignoreAppBar: ignoreAppBar,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    wrapRoute: (sidesheet) =>
        _FormSidesheetPopEntry(formViewModel: formViewModel, child: sidesheet),
  );
}
