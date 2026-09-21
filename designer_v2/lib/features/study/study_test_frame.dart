import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_test_app_routes.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_controls.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:web/web.dart' as web;

class const PreviewFrame(
  final StudyID studyId, {
  final StudyFormRouteArgs? routeArgs,
  final String? route,
  super.key,
}) extends ConsumerStatefulWidget {
  this
    : assert(
        (routeArgs != null && route == null) ||
            (routeArgs == null && route != null) ||
            (routeArgs == null && route == null),
        "Must not specify both routeArgs and route",
      );

  @override
  ConsumerState<PreviewFrame> createState() => _PreviewFrameState();
}

@visibleForTesting
({String route, String? extra}) previewRouteTarget(PreviewFrame frame) {
  if (frame.route != null) return (route: frame.route!, extra: null);

  return switch (frame.routeArgs) {
    final InterventionFormRouteArgs args => (
      route: 'intervention',
      extra: args.interventionId,
    ),
    final MeasurementFormRouteArgs args => (
      route: 'observation',
      extra: args.measurementId,
    ),
    _ => (route: TestAppRoutes.studyOverview, extra: null),
  };
}

class _PreviewFrameState() extends ConsumerState<PreviewFrame> {
  static const Duration _healthCheckTimeout = Duration(seconds: 5);
  PlatformController? frameController;
  PlatformController? _activeFrameController;
  ProviderSubscription<StudyControllerState>? _studyReadySubscription;
  StreamSubscription<dynamic>? _formChangesSubscription;
  String? _lastPreviewUrl;
  PreviewOverlayStage _overlayStage = PreviewOverlayStage.healthChecking;
  String? _overlayMessage;
  int _appHealthRequestId = 0;
  bool _iframeConnected = false;
  bool _frameActivated = false;

  @override
  void initState() {
    super.initState();
    _subscribeStudyChanges();
  }

  void _subscribeStudyChanges() {
    final StudyControllerState controllerState = ref.read(
      studyControllerProvider(widget.studyId),
    );
    if (controllerState.studyValue != null) {
      _listenToFormChanges();
      return;
    }

    _studyReadySubscription?.close();
    _studyReadySubscription = ref.listenManual<StudyControllerState>(
      studyControllerProvider(widget.studyId),
      (previous, next) {
        if (next.studyValue != null) {
          _studyReadySubscription?.close();
          _studyReadySubscription = null;
          _listenToFormChanges();
        }
      },
      fireImmediately: false,
    );
  }

  void _listenToFormChanges() {
    final formViewModelCurrent = ref.read(
      studyFormViewModelProvider(widget.studyId),
    );
    _formChangesSubscription?.cancel();
    _formChangesSubscription = formViewModelCurrent.form.valueChanges.listen((
      event,
    ) {
      final controller = _activeFrameController;
      if (controller == null) return;

      final formJson = jsonEncode(
        formViewModelCurrent.buildFormData().toJson(),
      );
      try {
        controller.updateData(formJson);
      } catch (_) {
        // The preview iframe may reload while form changes are emitted.
      }
    });
  }

  void _updatePreviewRoute() {
    final controller = _activeFrameController;
    if (controller == null) return;

    final data = jsonEncode(
      ref
          .read(studyFormViewModelProvider(widget.studyId))
          .buildFormData()
          .toJson(),
    );
    final target = previewRouteTarget(widget);
    controller.generateUrl(
      route: target.route,
      extra: target.extra,
      data: data,
    );
  }

  Uri? _configuredAppUri(String appUrl) => Uri.tryParse(appUrl);

  bool _isLocalPreviewUrl(String appUrl) {
    final uri = _configuredAppUri(appUrl);
    final host = uri?.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1';
  }

  String _configuredPreviewOrigin(String appUrl) {
    final uri = _configuredAppUri(appUrl);
    if (uri == null) return appUrl;
    return uri.origin;
  }

  void _markLoadStarted() {
    if (!mounted) return;
    setState(() {
      _iframeConnected = false;
      _frameActivated = false;
      _overlayStage = PreviewOverlayStage.healthChecking;
      _overlayMessage = null;
    });
  }

  void _markIframeConnected() {
    if (!mounted) return;
    setState(() {
      _iframeConnected = true;
      _overlayStage = PreviewOverlayStage.appLoading;
      _overlayMessage = null;
    });
  }

  void _markAppLoading() {
    if (!mounted || !_iframeConnected) return;
    setState(() {
      _overlayStage = PreviewOverlayStage.appLoading;
      _overlayMessage = null;
    });
  }

  void _markAppReady() {
    if (!mounted) return;
    setState(() {
      _overlayStage = PreviewOverlayStage.none;
      _overlayMessage = null;
    });
  }

  void _markAppError(String message) {
    if (!mounted) return;
    setState(() {
      _overlayStage = PreviewOverlayStage.error;
      _overlayMessage = message;
    });
  }

  Future<void> _runHealthCheckAndLoad(String previewUrl) async {
    final uri = Uri.tryParse(previewUrl);
    final origin = uri?.origin;
    if (origin == null || origin.isEmpty) {
      if (!mounted) return;
      setState(() {
        _overlayStage = PreviewOverlayStage.error;
        _overlayMessage = 'The app preview URL is not configured correctly.';
      });
      return;
    }

    final requestId = ++_appHealthRequestId;
    if (mounted) {
      setState(() {
        _overlayStage = PreviewOverlayStage.healthChecking;
        _overlayMessage = 'Checking whether the app at $origin is reachable.';
        _iframeConnected = false;
        _frameActivated = false;
      });
    }

    try {
      await web.window
          .fetch(origin.toJS, web.RequestInit(method: 'GET', mode: 'no-cors'))
          .toDart
          .timeout(_healthCheckTimeout);

      if (!mounted || requestId != _appHealthRequestId) return;
      setState(() {
        _overlayStage = PreviewOverlayStage.connecting;
        _overlayMessage = 'Connecting to the app preview at $origin.';
      });

      _activeFrameController!.activate();
      _activeFrameController!.listen();
      _activeFrameController!.refresh(cmd: "reset");
      if (!mounted || requestId != _appHealthRequestId) return;
      setState(() {
        _frameActivated = true;
      });
    } catch (_) {
      if (!mounted || requestId != _appHealthRequestId) return;
      setState(() {
        _overlayStage = PreviewOverlayStage.error;
        _overlayMessage = _isLocalPreviewUrl(previewUrl)
            ? 'The local StudyU app at $origin is not reachable. Start the app in local mode, then click Reset.'
            : 'The StudyU mobile app is temporarily unavailable or under maintenance. Please try again in a little while.';
      });
    }
  }

  void _ensureFrameController() {
    final nextController = frameController;
    if (nextController == null) return;
    if (identical(_activeFrameController, nextController)) return;

    _activeFrameController = nextController;
    _activeFrameController!
      ..onLoadStarted = _markLoadStarted
      ..onConnected = _markIframeConnected
      ..onLoading = _markAppLoading
      ..onReady = _markAppReady
      ..onError = _markAppError;

    _lastPreviewUrl = null;
    _updatePreviewRoute();
    _lastPreviewUrl = _activeFrameController!.previewSrc;
    unawaited(_runHealthCheckAndLoad(_activeFrameController!.previewSrc));
  }

  @override
  void didUpdateWidget(covariant PreviewFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activeFrameController == null ||
        previewRouteTarget(widget) == previewRouteTarget(oldWidget)) {
      return;
    }

    _updatePreviewRoute();
    final nextPreviewUrl = _activeFrameController!.previewSrc;
    if (_lastPreviewUrl != nextPreviewUrl) {
      _lastPreviewUrl = nextPreviewUrl;
      unawaited(_runHealthCheckAndLoad(nextPreviewUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyTestControllerProvider(widget.studyId));
    final formViewModel = ref.watch(studyTestValidatorProvider(widget.studyId));
    final configuredPreviewOrigin = _configuredPreviewOrigin(state.appUrl);
    final isLocalDevelopment = _isLocalPreviewUrl(state.appUrl);

    // Rebuild iframe component and url
    frameController = ref.watch(
      studyTestPlatformControllerProvider(widget.studyId),
    );
    if (!formViewModel.form.hasErrors) {
      _ensureFrameController();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < PhoneContainer.minWidth) {
          // Not enough space to render app preview
          return Container();
        }

        final previewWidth = math.min(
          constraints.maxWidth,
          PhoneContainer.defaultWidth,
        );
        final previewHeight = constraints.hasBoundedHeight
            ? math.min(
                constraints.maxHeight,
                PhoneContainer.defaultHeight + 56.0,
              )
            : PhoneContainer.defaultHeight + 56.0;

        return Stack(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ReactiveForm(
                  formGroup: formViewModel.form,
                  child: ReactiveFormConsumer(
                    builder: (context, form, child) {
                      if (formViewModel.form.hasErrors) {
                        return const DisabledFrame();
                      }
                      return SizedBox(
                        width: previewWidth,
                        height: previewHeight,
                        child: FittedBox(
                          alignment: Alignment.topCenter,
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  if (_frameActivated)
                                    _activeFrameController!.frameWidget
                                  else
                                    const PhoneContainer(
                                      innerContent: SizedBox.expand(),
                                    ),
                                  if (_overlayStage ==
                                      PreviewOverlayStage.error)
                                    Positioned.fill(
                                      child: ErrorFrame(
                                        title: isLocalDevelopment
                                            ? tr.preview_overlay_local_unavailable_title
                                            : tr.preview_overlay_remote_unavailable_title,
                                        message:
                                            _overlayMessage ??
                                            (isLocalDevelopment
                                                ? tr.preview_overlay_local_unavailable_message
                                                : tr.preview_overlay_remote_unavailable_message),
                                      ),
                                    ),
                                  if (_overlayStage !=
                                          PreviewOverlayStage.none &&
                                      _overlayStage !=
                                          PreviewOverlayStage.error)
                                    Positioned.fill(
                                      child: LoadingFrame(
                                        configuredUrl: configuredPreviewOrigin,
                                        isLocalDevelopment: isLocalDevelopment,
                                        stage: _overlayStage,
                                        message: _overlayMessage,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              FrameControlsWidget(
                                onRefresh: () {
                                  unawaited(
                                    _runHealthCheckAndLoad(
                                      frameController!.previewSrc,
                                    ),
                                  );
                                },
                                onOpenNewTab:
                                    _activeFrameController?.openNewPage,
                                enabled: state.canTest,
                                openNewTabEnabled:
                                    state.canTest && _frameActivated,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _studyReadySubscription?.close();
    _studyReadySubscription = null;
    _formChangesSubscription?.cancel();
    super.dispose();
  }
}
