import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/loading_overlay.dart';

/// Configuration for the persistent onboarding navigation bar.
class OnboardingNavConfig {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? backLabel;
  final String? nextLabel;
  final bool hideNext;
  final bool hideBack;
  final bool backEnabled;
  final bool showNextIcon;
  final bool showBackIcon;
  final bool primaryNext;
  final Icon? nextIcon;
  final Icon? backIcon;
  final Widget? progress;
  final Key? backButtonKey;
  final Key? nextButtonKey;
  final String? loadingMessage;

  const new({
    this.onBack,
    this.onNext,
    this.backLabel,
    this.nextLabel,
    this.hideNext = false,
    this.hideBack = false,
    this.backEnabled = true,
    this.showNextIcon = true,
    this.showBackIcon = true,
    this.primaryNext = false,
    this.nextIcon,
    this.backIcon,
    this.progress,
    this.backButtonKey,
    this.nextButtonKey,
    this.loadingMessage,
  });

  /// Copies the page navigation properties into the shell configuration.
  new fromNav(BottomOnboardingNavigation navigation, {this.loadingMessage})
    : onBack = navigation.onBack,
      onNext = navigation.onNext,
      backLabel = navigation.backLabel,
      nextLabel = navigation.nextLabel,
      hideNext = navigation.hideNext,
      hideBack = navigation.hideBack,
      backEnabled = navigation.backEnabled,
      showNextIcon = navigation.showNextIcon,
      showBackIcon = navigation.showBackIcon,
      primaryNext = navigation.primaryNext,
      nextIcon = navigation.nextIcon,
      backIcon = navigation.backIcon,
      progress = navigation.progress,
      backButtonKey = navigation.backButtonKey,
      nextButtonKey = navigation.nextButtonKey;

  BottomOnboardingNavigation build() => BottomOnboardingNavigation(
    onBack: onBack,
    onNext: onNext,
    backLabel: backLabel,
    nextLabel: nextLabel,
    hideNext: hideNext,
    hideBack: hideBack,
    backEnabled: backEnabled,
    showNextIcon: showNextIcon,
    showBackIcon: showBackIcon,
    primaryNext: primaryNext,
    nextIcon: nextIcon,
    backIcon: backIcon,
    progress: progress,
    backButtonKey: backButtonKey,
    nextButtonKey: nextButtonKey,
  );

  OnboardingNavConfig disabled() => OnboardingNavConfig(
    backLabel: backLabel,
    nextLabel: nextLabel,
    hideNext: hideNext,
    hideBack: hideBack,
    backEnabled: false,
    showNextIcon: showNextIcon,
    showBackIcon: showBackIcon,
    primaryNext: primaryNext,
    nextIcon: nextIcon,
    backIcon: backIcon,
    progress: progress,
    backButtonKey: backButtonKey,
    nextButtonKey: nextButtonKey,
  );
}

class _OnboardingNavController(var String routePath) extends ChangeNotifier {
  OnboardingNavConfig? config;
  Object? _owner;
  bool _disposed = false;

  void activateRoute(String routePath) {
    if (this.routePath == routePath) return;
    this.routePath = routePath;
    _owner = null;
    config = config?.disabled();
  }

  bool claim(Object owner, String routePath) {
    if (_disposed || this.routePath != routePath) return false;
    _owner = owner;
    return true;
  }

  void update(Object owner, String routePath, OnboardingNavConfig config) {
    if (_disposed || this.routePath != routePath || !identical(_owner, owner)) {
      return;
    }
    this.config = config;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Lets onboarding pages register navigation for the active shell route.
class const OnboardingNavNotifier({
  required final _OnboardingNavController _controller,
  required final String routePath,
  required super.child,
}) extends InheritedWidget {
  static OnboardingNavNotifier? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OnboardingNavNotifier>();

  /// Schedules a navigation update only for the active route and page owner.
  void register(Object owner, String routePath, OnboardingNavConfig config) {
    if (!_controller.claim(owner, routePath)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.update(owner, routePath, config);
    });
  }

  @override
  bool updateShouldNotify(OnboardingNavNotifier oldWidget) =>
      routePath != oldWidget.routePath;
}

/// Keeps the onboarding navigation mounted while child routes change.
class const OnboardingShell({
  required final String routePath,
  final bool hideNavigation = false,
  required final Widget child,
  super.key,
}) extends StatefulWidget {
  @override
  State<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState() extends State<OnboardingShell> {
  late final _controller = _OnboardingNavController(widget.routePath);

  @override
  void didUpdateWidget(OnboardingShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.activateRoute(widget.routePath);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingNavNotifier(
      controller: _controller,
      routePath: widget.routePath,
      child: ListenableBuilder(
        listenable: _controller,
        child: widget.child,
        builder: (context, child) {
          final config = _controller.config;
          return Stack(
            children: [
              Scaffold(
                body: child,
                bottomNavigationBar: widget.hideNavigation
                    ? null
                    : config?.build() ??
                          const BottomOnboardingNavigation(
                            hideBack: true,
                            hideNext: true,
                          ),
              ),
              if (config?.loadingMessage != null)
                LoadingOverlay(message: config!.loadingMessage!),
            ],
          );
        },
      ),
    );
  }
}
