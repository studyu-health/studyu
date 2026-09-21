import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/main.dart' show navigatorKey;
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/app_error_screen.dart';
import 'package:studyu_app/screens/app_onboarding/iframe_helper.dart';
import 'package:studyu_app/screens/app_onboarding/preview.dart'
    as study_preview;
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/services/deep_link_error_helper.dart';
import 'package:studyu_app/services/deep_link_service.dart';
import 'package:studyu_app/services/deferred_link_service.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_app/widgets/deep_link_onboarding_widgets.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase/supabase.dart'
    show AuthApiException, PostgrestException;

class const SubjectDeletedException() implements Exception {
  @override
  String toString() =>
      'SubjectDeletedException: subject no longer exists in the backend';
}

class const SubjectCacheUnavailableException([final Object? cause])
    implements Exception {
  @override
  String toString() =>
      'SubjectCacheUnavailableException: cached subject is missing or unusable'
      '${cause == null ? '' : ' ($cause)'}';
}

@visibleForTesting
String initialRouteForMissingSubjectRoute({
  required bool isPreview,
  required bool isDebugMode,
  required bool onBoarded,
}) {
  if (isPreview) return '/${RouteNames.terms}';
  return onBoarded || isDebugMode
      ? '/${RouteNames.welcome}'
      : '/${RouteNames.onboarding}';
}

@visibleForTesting
AppErrorScreenArguments appErrorArgumentsForSubjectLoadFailure({
  required String selectedSubjectId,
  required Object error,
}) {
  return AppErrorScreenArguments(
    selectedSubjectId: selectedSubjectId,
    reason: switch (error) {
      SubjectDeletedException() => AppErrorReason.deletedStudy,
      SubjectCacheUnavailableException(:final cause) =>
        appErrorReasonForCacheUnavailable(cause),
      _ => AppErrorReason.loading,
    },
  );
}

@visibleForTesting
AppErrorReason appErrorReasonForCacheUnavailable(Object? cause) {
  final message = cause?.toString().toLowerCase() ?? '';
  if (message.contains('no cached subject found')) {
    return AppErrorReason.cacheUnavailableMissing;
  }
  return AppErrorReason.cacheUnavailableCorrupt;
}

@visibleForTesting
Future<T?> restoreCachedValueForStartup<T>({
  required Future<T?> Function() fetchRemote,
  required Future<T> Function() loadCached,
  required Future<bool> Function() signIn,
  required bool Function(Object error) isDeletedRemoteError,
}) async {
  var shouldRetryAuth = true;

  try {
    final value = await fetchRemote();
    appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
    return value;
  } catch (error) {
    if (isDeletedRemoteError(error)) {
      throw const SubjectDeletedException();
    }
    final status = connectionStatusFromError(error);
    if (status != null) {
      shouldRetryAuth = false;
      appConnectionStatusController.setStatus(status);
    }
    StudyULogger.warning(
      'Could not retrieve startup value. Trying cached data: $error',
    );
  }

  if (!shouldRetryAuth) {
    try {
      final cached = await loadCached();
      StudyULogger.info('Loaded startup value from cache: $cached');
      return cached;
    } catch (error) {
      StudyULogger.warning('No usable startup value found in cache: $error');
      throw SubjectCacheUnavailableException(error);
    }
  }

  try {
    if (await signIn()) {
      final value = await fetchRemote();
      appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
      return value;
    }
  } on AuthApiException catch (error) {
    StudyULogger.warning('Invalid credentials during sign-in: $error');
    throw const SubjectDeletedException();
  } catch (error) {
    final status = connectionStatusFromError(error);
    if (status != null) {
      appConnectionStatusController.setStatus(status);
    }
    StudyULogger.warning(
      'Could not sign in and retrieve startup value: $error',
    );
    try {
      final cached = await loadCached();
      StudyULogger.info('Loaded startup value from cache: $cached');
      return cached;
    } catch (cacheError) {
      StudyULogger.warning(
        'No usable startup value found in cache: $cacheError',
      );
      throw SubjectCacheUnavailableException(cacheError);
    }
  }

  return null;
}

@visibleForTesting
Future<void> tryRestoreParticipantSession({
  required bool Function() isLoggedIn,
  required Future<bool> Function() hasStoredCredentials,
  required Future<void> Function() signIn,
  void Function(AppConnectionStatus status)? onConnectionStatusChanged,
  void Function(Object error)? onError,
}) async {
  if (isLoggedIn()) return;
  if (!await hasStoredCredentials()) return;

  try {
    await signIn();
  } catch (error) {
    final status = connectionStatusFromError(error);
    if (status != null) {
      onConnectionStatusChanged?.call(status);
    }
    onError?.call(error);
  }
}

@visibleForTesting
String activeStudyDeepLinkRoute(bool? openSettings) =>
    '/${openSettings == true ? RouteNames.appSettings : RouteNames.dashboard}';

class const LoadingScreen({
  super.key,
  final String? sessionString,
  final Map<String, String>? queryParameters,
  final String? deepLinkStudyId,
  final String? deepLinkInviteCode,
}) extends StatefulWidget {
  bool get hasDeepLink => deepLinkStudyId != null || deepLinkInviteCode != null;

  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState() extends State<LoadingScreen> {
  final IFrameHelper _iFrameHelper = IFrameHelper();
  bool _previewNavigationInProgress = false;
  String? _pendingPreviewRoute;
  String? _error;

  Future<bool> _restoreParticipantSession() async {
    if (isUserLoggedIn()) return false;
    final hasStoredCredentials =
        await SecureStorage.containsKey(userEmailKey) &&
        await SecureStorage.containsKey(userPasswordKey);
    if (!hasStoredCredentials) return false;
    try {
      await signInParticipant();
      return false;
    } on AuthApiException catch (error, stackTrace) {
      StudyULogger.warning(
        'Stored participant credentials are invalid. Showing reset screen.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return true;
      context.go('/${RouteNames.appErrorScreen}');
      return true;
    } catch (error) {
      final status = connectionStatusFromError(error);
      if (status != null) {
        appConnectionStatusController.setStatus(status);
      }
      StudyULogger.warning(
        'Could not restore the participant session. Continuing startup: $error',
      );
      return false;
    }
  }

  Future<void> _storePendingDeepLink({
    required Study study,
    String? inviteCode,
    List<String>? preselectedInterventionIds,
    bool persist = false,
  }) async {
    final state = context.read<AppState>();
    PendingDeepLinkService.storeInState(
      state: state,
      study: study,
      inviteCode: inviteCode,
      preselectedInterventionIds: preselectedInterventionIds,
    );
    if (persist) {
      await PendingDeepLinkService.persist(
        studyId: inviteCode == null ? study.id : null,
        inviteCode: inviteCode,
      );
    }
  }

  Future<void> _handleIncomingDeepLink({
    String? studyId,
    String? inviteCode,
    bool isDeferred = false,
    bool persistPending = true,
  }) async {
    final state = context.read<AppState>();

    // 1. Check login status
    final loggedIn = isUserLoggedIn();

    // 2. Only try to get an active study if they are actually logged in
    final currentSubject = loggedIn ? await _getCurrentSubject(state) : null;
    final activeStudyId = currentSubject?.studyId;

    // 3. ALWAYS process/validate the deep link first
    final result = await DeepLinkService.processDeepLink(
      studyId: studyId,
      inviteCode: inviteCode,
      isAuthenticated: loggedIn,
      activeStudyId: activeStudyId,
    );

    if (!mounted) return;

    // 4. Handle the result (Errors will be caught here, NeedsAuth will route to onboarding)
    await _handleDeepLinkResult(
      result,
      isDeferred: isDeferred,
      persistPending: persistPending,
      currentSubject: currentSubject,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _runStartupFlow();
    });
  }

  @override
  void didUpdateWidget(LoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deepLinkInviteCode != oldWidget.deepLinkInviteCode ||
        widget.deepLinkStudyId != oldWidget.deepLinkStudyId ||
        widget.queryParameters != oldWidget.queryParameters) {
      if (widget.hasDeepLink) {
        // Reset state so loading spinner shows again instead of old error
        setState(() => _error = null);
        _initDeepLink();
      }
    }
  }

  Future<void> _runStartupFlow() async {
    if (await _restoreParticipantSession()) return;

    if (kIsWeb && widget.hasDeepLink) {
      return;
    }

    if (widget.hasDeepLink) {
      final storedLink = await PendingDeepLinkService.readStorage();
      if (storedLink.inviteCode != widget.deepLinkInviteCode ||
          storedLink.studyId != widget.deepLinkStudyId) {
        await PendingDeepLinkService.clearStorage();
      }
      await _handleIncomingDeepLink(
        studyId: widget.deepLinkStudyId,
        inviteCode: widget.deepLinkInviteCode,
      );
      return;
    }

    if (!kIsWeb) {
      final deferredLink = await DeferredLinkService.checkForDeferredLink();
      if (!mounted) return;
      if (deferredLink != null) {
        await _handleDeferredLink(deferredLink);
        return;
      }
      final storedLink = await PendingDeepLinkService.readStorage();
      final pendingLink = pendingDeferredLinkFromStorageValues(
        inviteCode: storedLink.inviteCode,
        studyId: storedLink.studyId,
      );
      if (pendingLink != null) {
        if (!mounted) return;
        await _handleDeferredLink(pendingLink);
        return;
      }
    }

    await initStudy();
  }

  Future<void> _handleDeferredLink(DeferredLink deferredLink) async {
    await _handleIncomingDeepLink(
      inviteCode: deferredLink.inviteCode,
      studyId: deferredLink.studyId,
      isDeferred: true,
    );
  }

  Future<void> _initDeepLink() async {
    await _handleIncomingDeepLink(
      studyId: widget.deepLinkStudyId,
      inviteCode: widget.deepLinkInviteCode,
    );
  }

  Future<void> _markDeferredLinkProcessed() async {
    await SecureStorage.write('has_processed_deferred_link', 'true');
    await PendingDeepLinkService.clearStorage();
  }

  Future<void> _markDeferredLinkHandedOff() async {
    await SecureStorage.write('has_processed_deferred_link', 'true');
  }

  Future<void> _showActiveStudyDeepLinkDialog(
    Study targetStudy,
    StudySubject currentSubject,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deep_link_switch_warning_title),
        content: Text(
          '${l10n.study_selection_single}\n\n'
          '${l10n.study_selection_single_reason}\n\n'
          '${l10n.deep_link_switch_warning_description(currentSubject.study.title ?? '', targetStudy.title ?? '')}\n\n'
          '${l10n.deep_link_switch_warning_opt_out_instruction(l10n.opt_out)}',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(l10n.deep_link_switch_open_settings),
          ),
          FilledButton(
            onPressed: () => context.pop(false),
            child: Text(l10n.deep_link_switch_continue_study),
          ),
        ],
      ),
    );
    if (!mounted) return;
    context.go(activeStudyDeepLinkRoute(openSettings));
  }

  Future<void> _handleDeepLinkResult(
    DeepLinkResult result, {
    bool isDeferred = false,
    bool persistPending = false,
    StudySubject? currentSubject,
  }) async {
    final state = context.read<AppState>();
    switch (result) {
      case DeepLinkNeedsAuth(
        :final study,
        :final inviteCode,
        :final preselectedInterventionIds,
      ):
        await _storePendingDeepLink(
          study: study,
          inviteCode: inviteCode,
          preselectedInterventionIds: preselectedInterventionIds,
          persist: persistPending,
        );
        if (isDeferred) {
          await _markDeferredLinkHandedOff();
        }

        final onBoarded = await SecureStorage.readBool('onboarded') ?? false;
        if (!mounted) return;
        context.go(
          '/${onBoarded ? RouteNames.welcome : RouteNames.onboarding}',
        );

      case DeepLinkError(type: final errorType, :final errorValue):
        setState(() => _error = _getErrorMessage(errorType, errorValue));
        if (isDeferred) {
          await _markDeferredLinkProcessed();
        }
      case DeepLinkSuccess(
        :final study,
        :final inviteCode,
        :final preselectedInterventionIds,
        :final alreadyEnrolled,
      ):
        if (alreadyEnrolled) {
          await PendingDeepLinkService.clear(state);
          if (isDeferred) await _markDeferredLinkProcessed();
          if (!mounted) return;
          context.go('/${RouteNames.dashboard}');
          return;
        }

        if (currentSubject != null) {
          await PendingDeepLinkService.clear(state);
          if (isDeferred) await _markDeferredLinkProcessed();
          if (!mounted) return;
          await _showActiveStudyDeepLinkDialog(study, currentSubject);
          return;
        }

        await _storePendingDeepLink(
          study: study,
          inviteCode: inviteCode,
          preselectedInterventionIds: preselectedInterventionIds,
          persist: persistPending,
        );
        if (isDeferred) {
          await _markDeferredLinkHandedOff();
        }

        final onBoarded = await SecureStorage.readBool('onboarded') ?? false;
        if (!mounted) return;
        context.go(
          '/${onBoarded ? RouteNames.welcome : RouteNames.onboarding}',
        );
    }
  }

  String _getErrorMessage(DeepLinkErrorType errorType, [String? errorValue]) {
    return getDeepLinkErrorMessage(
      AppLocalizations.of(context)!,
      errorType,
      errorValue,
    );
  }

  Future<void> _acknowledgeDeepLinkError() async {
    if (context.canPop()) {
      context.pop();
      return;
    }

    if (!mounted) return;
    context.goNamed(RouteNames.loading);
  }

  Future<StudySubject?> _getCurrentSubject(AppState state) async {
    final activeSubjectId = await getActiveSubjectId();
    if (activeSubjectId == null) {
      return null;
    }

    final activeSubject = state.activeSubject;
    if (activeSubject != null && activeSubject.id == activeSubjectId) {
      return activeSubject;
    }

    try {
      final cachedSubject = await Cache.loadSubject();
      if (cachedSubject.id == activeSubjectId) {
        state.activeSubject = cachedSubject;
        return cachedSubject;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> initStudy() async {
    final state = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final appLanguage = context.read<AppLanguage>();
    try {
      final previewHandledNavigation = await _initPreview(state, l10n);
      if (previewHandledNavigation) return;
    } catch (error, stackTrace) {
      StudyULogger.error(
        l10n.preview_failed_to_initialize,
        error: error,
        stackTrace: stackTrace,
      );
      _iFrameHelper.postPreviewStatus(
        status: 'error',
        message: l10n.preview_overlay_study_not_ready,
      );
      // Do not rethrow: the call site is unawaited; an unhandled async
      // exception would crash the app rather than showing a graceful error.
      return;
    }

    await appLanguage.synchronizeWithServer();
    if (!mounted) return;

    final selectedSubjectId = await getActiveSubjectId();
    if (!mounted) return;

    if (selectedSubjectId == null) {
      await noSubjectFound(state);
      return;
    }
    StudyULogger.info("Retrieving subject with ID: $selectedSubjectId");
    StudySubject? subject;
    try {
      subject = await _retrieveSubject(selectedSubjectId);
    } on SubjectDeletedException catch (error) {
      StudyULogger.warning(
        'Subject $selectedSubjectId was deleted from backend. Showing recovery screen.',
      );
      // The cached recovery secret belongs to the deleted account; clear it
      // so a subsequent user on this device cannot read it.
      RestoreAccountService.clearCache();
      if (!mounted) return;
      context.go(
        '/${RouteNames.appErrorScreen}',
        extra: appErrorArgumentsForSubjectLoadFailure(
          selectedSubjectId: selectedSubjectId,
          error: error,
        ),
      );
      return;
    } on SubjectCacheUnavailableException catch (error) {
      StudyULogger.warning(
        'Subject $selectedSubjectId could not be restored from cache. Showing recovery screen.',
      );
      if (!mounted) return;
      context.go(
        '/${RouteNames.appErrorScreen}',
        extra: appErrorArgumentsForSubjectLoadFailure(
          selectedSubjectId: selectedSubjectId,
          error: error,
        ),
      );
      return;
    }
    if (!mounted) return;
    if (subject != null) {
      subject = await Cache.synchronize(subject);
      if (!mounted) return;
      if (!isStudyAvailableForTesting(subject.study)) {
        context.go('/${RouteNames.studyUnavailable}');
        return;
      }
      state.activeSubject = subject;
      state.init(context);
      if (state.showParticipantRecovery &&
          await RecoveryPhraseStorage.isPending(subject.id)) {
        if (!mounted) return;
        context.goNamed(
          RouteNames.recoveryPhrase,
          queryParameters: {'next': RouteNames.dashboard},
        );
        return;
      }
      if (!mounted) return;
      context.go('/${RouteNames.dashboard}');
    } else {
      StudyULogger.warning("No subject found for ID: $selectedSubjectId.");
      if (!mounted) return;
      context.go('/${RouteNames.appErrorScreen}', extra: selectedSubjectId);
    }
  }

  Future<void> noSubjectFound(AppState state) async {
    StudyULogger.info("No subject found");
    await cancelNotifications(context);

    if (await _restoreParticipantSession()) return;
    if (isUserLoggedIn() && !state.isPreview) {
      if (!mounted) return;
      context.goNamed(RouteNames.welcome);
      return;
    }

    final route = initialRouteForMissingSubjectRoute(
      isPreview: state.isPreview,
      isDebugMode: kDebugMode,
      onBoarded: await SecureStorage.readBool('onboarded') ?? false,
    );

    if (!mounted) return;
    _iFrameHelper.postPreviewStatus(status: 'loaded');
    context.go(route);
  }

  Future<StudySubject?> _fetchRemoteSubject(String selectedStudyObjectId) {
    return SupabaseQuery.getById<StudySubject>(
      selectedStudyObjectId,
      selectedColumns: [
        '*',
        // Retrieve the related study along with its fitbit credentials
        'study!study_subject_studyId_fkey(*, study_fitbit_credentials:study_fitbit_credentials_studyId_fkey(*))',
        'subject_progress(*)',
      ],
    );
  }

  Future<StudySubject?> _retrieveSubject(String selectedStudyObjectId) {
    return restoreCachedValueForStartup<StudySubject>(
      fetchRemote: () => _fetchRemoteSubject(selectedStudyObjectId),
      loadCached: Cache.loadSubject,
      signIn: signInParticipant,
      isDeletedRemoteError: (error) =>
          error is PostgrestException && error.code == 'PGRST116',
    );
  }

  Future<bool> _initPreview(AppState state, AppLocalizations l10n) async {
    if (state.isPreview) previewSubjectIdKey();
    if (widget.queryParameters == null || widget.queryParameters!.isEmpty) {
      return false;
    }

    StudyULogger.info('Preview: Found preview configuration');
    final lang = AppLanguage(AppLocalizations.supportedLocales);
    final preview = study_preview.Preview(widget.queryParameters, lang);
    state.isPreview = true;
    _iFrameHelper.postPreviewStatus(status: 'loading');
    await preview.init();

    _iFrameHelper.listen(
      state,
      onNavigate: (route) => _navigatePreviewRoute(state, route, l10n),
      onStudy: (study) => preview.study = study,
    );
    final sessionFuture = _iFrameHelper.requestPreviewSession();
    final studyFuture = _iFrameHelper.requestPreviewStudy();
    final session = await sessionFuture;
    await studyFuture;
    final isAuthorized =
        session != null && await preview.handleAuthorization(session);
    if (!isAuthorized) {
      _iFrameHelper.postPreviewStatus(
        status: 'error',
        message: l10n.preview_overlay_reset_hint,
      );
      return true;
    }
    state.selectedStudy = preview.study;

    await preview.runCommands();

    if (preview.hasRoute()) {
      // print('[PreviewApp]: Found preview route:: ${preview.selectedRoute}');

      if (preview.selectedRoute == '/${RouteNames.studyOverview}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        context.go('/${RouteNames.studyOverview}');
        return true;
      }

      // ELIGIBILITY CHECK
      if (preview.selectedRoute == '/${RouteNames.eligibilityCheck}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        // if we remove the await, we can push multiple times. warning: do not run in while(true)
        await context.push<EligibilityResult>(
          '/${RouteNames.eligibilityCheck}',
          extra: EligibilityScreenArguments(
            study: preview.study,
            onEligible: continueAfterEligibility,
          ),
        );
        // either do the same navigator push again or --> send a message back to designer and let it reload the whole page <--
        _iFrameHelper.postRouteFinished();
        return true;
      }

      // INTERVENTION SELECTION
      if (preview.selectedRoute == '/${RouteNames.interventionSelection}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await context.push('/${RouteNames.interventionSelection}');
        _iFrameHelper.postRouteFinished();
        return true;
      }

      state.activeSubject = await preview.getStudySubject(
        state,
        createSubject: true,
      );

      // CONSENT
      if (preview.selectedRoute == '/${RouteNames.consent}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await context.push<bool>('/${RouteNames.consent}');
        _iFrameHelper.postRouteFinished();
        return true;
      }

      // JOURNEY
      if (preview.selectedRoute == '/${RouteNames.journey}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await context.push('/${RouteNames.journey}');
        _iFrameHelper.postRouteFinished();
        return true;
      }

      // DASHBOARD
      if (preview.selectedRoute == '/${RouteNames.dashboard}') {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        context.go('/${RouteNames.dashboard}');
        _iFrameHelper.postRouteFinished();
        return true;
      }

      // INTERVENTION [i]
      if (preview.selectedRoute == '/intervention') {
        // todo not sure which includeBaseline statement is needed.
        // Either one of here or in preview.createFakeSubject
        // maybe remove
        state.selectedStudy!.schedule.includeBaseline = false;
        state.activeSubject!.study.schedule.includeBaseline = false;
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        context.go('/${RouteNames.dashboard}');
        _iFrameHelper.postRouteFinished();
        return true;
      }

      // OBSERVATION [i]
      if (preview.selectedRoute == '/observation') {
        final tasks = <Task>[
          ...state.selectedStudy!.observations.where(
            (observation) => observation.id == preview.extra,
          ),
        ];
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        await context.push<bool>(
          '/${RouteNames.task}',
          extra: TaskInstance(
            tasks.first,
            tasks.first.schedule.completionPeriods.first.id,
          ),
        );
        _iFrameHelper.postRouteFinished();
        return true;
      }
    } else {
      if (isUserLoggedIn()) {
        final subject = await preview.getStudySubject(state);
        if (subject != null) {
          state.activeSubject = subject;
          if (!mounted) return true;
          _iFrameHelper.postPreviewStatus(status: 'loaded');
          context.go('/${RouteNames.dashboard}');
          return true;
        } else {
          if (!mounted) return true;
          _iFrameHelper.postPreviewStatus(status: 'loaded');
          context.go('/${RouteNames.studyOverview}');
          return true;
        }
      } else {
        if (!mounted) return true;
        _iFrameHelper.postPreviewStatus(status: 'loaded');
        context.go('/${RouteNames.welcome}');
        return true;
      }
    }
    return true;
  }

  Future<void> _navigatePreviewRoute(
    AppState state,
    String? route,
    AppLocalizations l10n,
  ) async {
    if (_previewNavigationInProgress) {
      _pendingPreviewRoute = route;
      return;
    }
    _previewNavigationInProgress = true;
    bool navigationPerformed = false;

    try {
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;

      Future<bool> ensureSubject() async {
        if (state.activeSubject != null) return true;
        if (state.selectedStudy == null) return false;

        final preview = study_preview.Preview({
          ...?widget.queryParameters,
          'route': ?route,
        }, AppLanguage(AppLocalizations.supportedLocales));
        await preview.init();
        preview.study = state.selectedStudy;
        state.activeSubject = await preview.getStudySubject(
          state,
          createSubject: true,
        );
        return state.activeSubject != null;
      }

      Future<void> waitForNavigator() async {
        await WidgetsBinding.instance.endOfFrame;
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }

      Future<void> replaceNamed(String routeName) async {
        await waitForNavigator();
        navigatorKey.currentContext?.go(routeName);
      }

      Future<void> replaceWithEligibility() async {
        if (state.selectedStudy == null) return;
        await waitForNavigator();
        navigatorKey.currentState?.pushReplacement(
          EligibilityScreen.routeFor(study: state.selectedStudy),
        );
      }

      if (route == null ||
          route.isEmpty ||
          route == 'studyOverview' ||
          route == '/${RouteNames.studyOverview}') {
        await replaceNamed('/${RouteNames.studyOverview}');
        navigationPerformed = true;
        return;
      }

      if (route == 'eligibilityCheck') {
        if (state.selectedStudy == null) return;
        await replaceWithEligibility();
        navigationPerformed = true;
        return;
      }

      if (route == '/${RouteNames.interventionSelection}' ||
          route == 'interventionSelection') {
        await replaceNamed('/${RouteNames.interventionSelection}');
        navigationPerformed = true;
        return;
      }

      if (!await ensureSubject()) {
        _iFrameHelper.postPreviewStatus(
          status: 'error',
          message: l10n.preview_overlay_route_open_failed,
        );
        return;
      }

      if (route == 'consent') {
        await replaceNamed('/${RouteNames.consent}');
        navigationPerformed = true;
      } else if (route == 'journey') {
        await replaceNamed('/${RouteNames.journey}');
        navigationPerformed = true;
      } else if (route == 'dashboard') {
        await replaceNamed('/${RouteNames.dashboard}');
        navigationPerformed = true;
      }
    } finally {
      _previewNavigationInProgress = false;
      final pendingRoute = _pendingPreviewRoute;
      _pendingPreviewRoute = null;
      if (pendingRoute != null && pendingRoute != route) {
        await _navigatePreviewRoute(state, pendingRoute, l10n);
      } else if (navigationPerformed) {
        _iFrameHelper.postPreviewStatus(status: 'loaded');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && widget.hasDeepLink) {
      return DeepLinkWebLandingPage(
        inviteCode: widget.deepLinkInviteCode,
        studyId: widget.deepLinkStudyId,
      );
    }
    if (_error != null) {
      FlutterNativeSplash.remove(); // Force remove splash to ensure visibility
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.error,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _acknowledgeDeepLinkError,
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${AppLocalizations.of(context)!.loading}...'),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

/*if (!signInRes) {
        final migrateRes = await migrateParticipantToNewDB(selectedStudyObjectId);
        if (migrateRes) {
          print("Successfully migrated to the new database");
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully migrated to the new database.')));
        } else {
          print("Error when trying to migrate to the new database");
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error when migrating to the new database.')));
        }
        initStudy();
        return;
      }*/

/*Future<bool> migrateParticipantToNewDB(String selectedStudyObjectId) async {
    if (await SecureStorage.containsKey(userEmailKey) && await SecureStorage.containsKey(userPasswordKey)) {
      try {
        // create new account
        if (await anonymousSignUp()) {
          // call supabase function to update user_id to new user id
          // by matching a study_subject entry with the current subject ID
          try {
            await Supabase.instance.client.rpc(
              'migrate_db',
              params: {
                'participant_user_id': Supabase.instance.client.auth.currentUser?.id,
                'participant_subject_id': selectedStudyObjectId,
              },
            ).single();
          } on PostgrestException catch (error) {
            print('Supabase migrate_db Error: ${error.message}');
          }
          return true;
        } else {
          return false;
        }
      } catch (error, stacktrace) {
        SupabaseQuery.catchSupabaseException(error, stacktrace);
      }
    }
    return false;
  }*/
