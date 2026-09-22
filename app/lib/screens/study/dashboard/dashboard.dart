import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/study_unavailable_screen.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/task_overview.dart';
import 'package:studyu_app/theme.dart' as app_theme;
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_app/util/debug_screen.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

@visibleForTesting
bool isDashboardShowcaseEligible({
  required DateTime? startedAt,
  required DateTime now,
  required bool isPreview,
  required bool checkStarted,
}) {
  return !checkStarted &&
      !isPreview &&
      startedAt != null &&
      !startedAt.isAfter(now);
}

@visibleForTesting
bool shouldMarkDashboardShowcaseCompleted({required bool wasStarted}) {
  return wasStarted;
}

class const DashboardScreen({super.key, final String? error})
    extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class OverflowMenuItem(
  final String name,
  final IconData icon, {
  final String? routeName,
  final Future<void> Function()? onTap,
});

class _DashboardScreenState()
    extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final GlobalKey _progressShowcaseKey = GlobalKey();
  final GlobalKey _currentInterventionShowcaseKey = GlobalKey();
  final GlobalKey _todayTasksShowcaseKey = GlobalKey();
  final GlobalKey _contactShowcaseKey = GlobalKey();
  final GlobalKey _reportShowcaseKey = GlobalKey();
  final GlobalKey _menuShowcaseKey = GlobalKey();

  late final ShowcaseView _dashboardShowcase;
  late final TextStyle showcaseActionTextStyle;
  StudySubject? subject;
  List<TaskInstance>? scheduleToday;
  bool _showcaseCheckStarted = false;
  bool _dashboardShowcaseStarted = false;
  bool _redirectingToLoading = false;
  bool _isDisposing = false;

  bool get _studyIsAvailable => isStudyAvailableForTesting(subject!.study);

  bool get showNextDay =>
      (kDebugMode || context.read<AppState>().isPreview) &&
      !subject!.completedStudy;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    showcaseActionTextStyle = TextStyle(
      color: app_theme.theme.colorScheme.onPrimary,
    );
    _dashboardShowcase = ShowcaseView.register(
      blurValue: 1,
      globalTooltipActionConfig: const TooltipActionConfig(actionGap: 12),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          backgroundColor: Colors.transparent,
          textStyle: TextStyle(color: app_theme.theme.colorScheme.primary),
          hideActionWidgetForShowcase: [_menuShowcaseKey],
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          backgroundColor: app_theme.theme.colorScheme.primary,
          textStyle: showcaseActionTextStyle,
          hideActionWidgetForShowcase: [_menuShowcaseKey],
        ),
      ],
      onFinish: _markDashboardShowcaseCompleted,
      onDismiss: (_) => _markDashboardShowcaseCompleted(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (subject != null && _studyIsAvailable) {
          setState(() {
            scheduleToday = subject!.scheduleFor(DateTime.now());
          });
          unawaited(_startDashboardShowcaseIfNeeded());
        }
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subject = context.watch<AppState>().activeSubject;
    if (subject != null && _studyIsAvailable) {
      scheduleToday = subject!.scheduleFor(DateTime.now());
      if (widget.error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(widget.error!)));
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_startDashboardShowcaseIfNeeded());
      });
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    WidgetsBinding.instance.removeObserver(this);
    _dashboardShowcase.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (subject == null) {
      if (ModalRoute.of(context)?.isCurrent == true && !_redirectingToLoading) {
        _redirectingToLoading = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
          context.go('/${RouteNames.loading}');
        });
      }
      return const SizedBox.shrink();
    }

    if (!_studyIsAvailable) {
      return const StudyUnavailableScreen();
    }

    final isPreviewMode = context.read<AppState>().isPreview;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // Removes back button. We currently keep navigation stack to make developing easier
        automaticallyImplyLeading: false,
        title: Text(l10n.dashboard),
        forceMaterialTransparency: true,
        actions: [
          Showcase(
            key: _contactShowcaseKey,
            title: l10n.dashboard_showcase_contact_title,
            description: l10n.dashboard_showcase_contact_description,
            tooltipBackgroundColor: theme.colorScheme.surface,
            textColor: theme.colorScheme.onSurface,
            targetShapeBorder: const CircleBorder(),
            child: IconButton(
              tooltip: l10n.contact,
              icon: const Icon(MdiIcons.faceAgent),
              onPressed: () {
                context.push('/${RouteNames.contact}');
              },
            ),
          ),
          Showcase(
            key: _reportShowcaseKey,
            title: l10n.dashboard_showcase_report_title,
            description: l10n.dashboard_showcase_report_description,
            tooltipBackgroundColor: theme.colorScheme.surface,
            textColor: theme.colorScheme.onSurface,
            targetShapeBorder: const CircleBorder(),
            child: IconButton(
              tooltip: l10n.current_report,
              icon: const Icon(MdiIcons.chartBar),
              onPressed: () =>
                  context.push('/${RouteNames.reportDetails}', extra: subject),
            ),
          ),
          Showcase(
            key: _menuShowcaseKey,
            title: l10n.dashboard_showcase_menu_title,
            description: l10n.dashboard_showcase_menu_description,
            tooltipBackgroundColor: theme.colorScheme.surface,
            textColor: theme.colorScheme.onSurface,
            tooltipActions: [
              TooltipActionButton(
                type: TooltipDefaultActionType.skip,
                backgroundColor: Colors.transparent,
                textStyle: TextStyle(color: theme.colorScheme.primary),
              ),
              TooltipActionButton(
                type: TooltipDefaultActionType.next,
                name: l10n.dashboard_showcase_finish,
                backgroundColor: theme.colorScheme.primary,
                textStyle: showcaseActionTextStyle,
              ),
            ],
            targetShapeBorder: const CircleBorder(),
            child: PopupMenuButton<OverflowMenuItem>(
              onSelected: (value) async {
                if (value.routeName != null) {
                  final result = await context.push(value.routeName!);
                  if (!mounted) return;
                  if (value.routeName == '/${RouteNames.appSettings}' &&
                      result == true) {
                    await _restartDashboardShowcase();
                  }
                } else {
                  await value.onTap?.call();
                }
              },
              itemBuilder: (context) {
                return [
                  OverflowMenuItem(
                    AppLocalizations.of(context)!.report_history,
                    MdiIcons.history,
                    routeName: '/${RouteNames.reportHistory}',
                  ),
                  OverflowMenuItem(
                    AppLocalizations.of(context)!.faq,
                    MdiIcons.frequentlyAskedQuestions,
                    routeName: '/${RouteNames.faq}',
                  ),
                  OverflowMenuItem(
                    AppLocalizations.of(context)!.settings,
                    Icons.settings,
                    routeName: '/${RouteNames.appSettings}',
                  ),
                  OverflowMenuItem(
                    AppLocalizations.of(context)!.what_is_studyu,
                    MdiIcons.helpCircleOutline,
                    routeName: '/${RouteNames.about}',
                  ),
                  OverflowMenuItem(
                    AppLocalizations.of(context)!.about,
                    MdiIcons.informationOutline,
                    onTap: () async {
                      final iconAuthors = ['Kiranshastry'];
                      final PackageInfo packageInfo =
                          await PackageInfo.fromPlatform();
                      if (!context.mounted) return;
                      showAboutDialog(
                        context: context,
                        applicationIcon: InkWell(
                          onDoubleTap: () {
                            DebugScreen.showDebugScreen(context);
                          },
                          child: const Image(
                            image: AssetImage('assets/icon/icon.png'),
                            height: 32,
                          ),
                        ),
                        applicationVersion:
                            '${packageInfo.version} - ${packageInfo.buildNumber}',
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                                const TextSpan(text: 'Icons from '),
                                TextSpan(
                                  style: const TextStyle(color: Colors.blue),
                                  text: 'www.flaticon.com',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(
                                        Uri.parse('https://www.flaticon.com/'),
                                      );
                                    },
                                ),
                                const TextSpan(text: ' made by'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: iconAuthors
                                .map(
                                  (author) => InkWell(
                                    onTap: () {
                                      launchUrl(
                                        Uri.parse(
                                          'https://www.flaticon.com/authors/${author.replaceAll(RegExp(r'\s|_'), '-')}',
                                        ),
                                      );
                                    },
                                    child: Text(
                                      author,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      );
                    },
                  ),
                ].map((choice) {
                  return PopupMenuItem<OverflowMenuItem>(
                    value: choice,
                    child: Row(
                      children: [
                        Icon(choice.icon, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(choice.name),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview mode banner
          if (isPreviewMode)
            GestureDetector(
              onTap: () => _showPreviewModeInfo(context),
              child: Container(
                width: double.infinity,
                color: Colors.orange.shade100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.preview,
                      color: Colors.orange.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.preview_mode_active,
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade800,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          // Main content
          Expanded(
            child: Padding(
              padding: showNextDay
                  ? EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height / 10,
                    )
                  : EdgeInsets.zero,
              child: _buildBody(),
            ),
          ),
        ],
      ),
      bottomSheet: showNextDay
          ? Container(
              margin: const EdgeInsets.only(left: 16, bottom: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.fast_forward_rounded),
                onPressed: () async {
                  try {
                    await subject!.setStartDateBackBy(days: 1);
                    setState(() {
                      scheduleToday = subject!.scheduleFor(DateTime.now());
                    });
                    unawaited(_startDashboardShowcaseIfNeeded());
                  } catch (error) {
                    final status = connectionStatusFromError(error);
                    if (status == null) rethrow;
                    appConnectionStatusController.setStatus(status);
                    if (!context.mounted) return;
                    final theme = Theme.of(context);
                    final message = status == AppConnectionStatus.deviceOffline
                        ? AppLocalizations.of(context)!.no_internet_connection
                        : AppLocalizations.of(context)!
                              .connection_banner_backend_unavailable;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: theme.colorScheme.primary,
                        content: Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }
                },
                label: Text(AppLocalizations.of(context)!.next_day),
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange, width: 2.0),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : null,
    );
  }

  void _showPreviewModeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.preview, color: Colors.orange),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.preview_mode),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(AppLocalizations.of(context)!.preview_mode_description),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    if (subject!.completedStudy) {
      return const StudyFinishedPlaceholder();
    } else if (subject!.startedAt!.isAfter(DateTime.now())) {
      final l10n = AppLocalizations.of(context)!;
      final theme = Theme.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag_outlined,
                    size: 26,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.study_not_started_title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.study_not_started_description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return TaskOverview(
        subject: subject,
        scheduleToday: scheduleToday,
        interventionIcon: subject!.getInterventionForDate(DateTime.now())?.icon,
        progressShowcaseKey: _progressShowcaseKey,
        currentInterventionShowcaseKey: _currentInterventionShowcaseKey,
        todayTasksShowcaseKey: _todayTasksShowcaseKey,
      );
    }
  }

  Future<void> _startDashboardShowcaseIfNeeded() async {
    if (!isDashboardShowcaseEligible(
      startedAt: subject?.startedAt,
      now: DateTime.now(),
      isPreview: context.read<AppState>().isPreview,
      checkStarted: _showcaseCheckStarted,
    )) {
      return;
    }

    _showcaseCheckStarted = true;

    final completed = await DashboardShowcaseStorage.isCompleted();
    if (completed || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _dashboardShowcase.startShowCase([
        _progressShowcaseKey,
        _currentInterventionShowcaseKey,
        _todayTasksShowcaseKey,
        _contactShowcaseKey,
        _reportShowcaseKey,
        _menuShowcaseKey,
      ], delay: const Duration(milliseconds: 300));
      _dashboardShowcaseStarted = true;
    });
  }

  Future<void> _restartDashboardShowcase() async {
    _showcaseCheckStarted = false;
    await _startDashboardShowcaseIfNeeded();
  }

  void _markDashboardShowcaseCompleted() {
    if (_isDisposing ||
        !shouldMarkDashboardShowcaseCompleted(
          wasStarted: _dashboardShowcaseStarted,
        )) {
      return;
    }
    unawaited(DashboardShowcaseStorage.markCompleted());
  }
}

class const StudyFinishedPlaceholder({super.key}) extends StatelessWidget {
  static const space = SizedBox(height: 80);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.completed_study,
              style: TextStyle(
                fontSize: 20,
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            space,
            OutlinedButton.icon(
              onPressed: () => context.push('/${RouteNames.reportHistory}'),
              icon: const Icon(MdiIcons.history, size: 24),
              label: Text(
                AppLocalizations.of(context)!.report_history,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            space,
            OutlinedButton.icon(
              onPressed: () => context.push('/${RouteNames.studySelection}'),
              icon: const Icon(MdiIcons.clipboardArrowRightOutline, size: 24),
              label: Text(
                AppLocalizations.of(context)!.study_selection,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
