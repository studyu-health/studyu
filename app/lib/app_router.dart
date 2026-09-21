import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/about.dart';
import 'package:studyu_app/screens/app_onboarding/app_error_screen.dart';
import 'package:studyu_app/screens/app_onboarding/app_outdated_screen.dart';
import 'package:studyu_app/screens/app_onboarding/loading_screen.dart';
import 'package:studyu_app/screens/app_onboarding/onboarding_screen.dart';
import 'package:studyu_app/screens/app_onboarding/recovery_phrase_screen.dart';
import 'package:studyu_app/screens/app_onboarding/restore_account_screen.dart';
import 'package:studyu_app/screens/app_onboarding/study_unavailable_screen.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_app/screens/app_onboarding/welcome.dart';
import 'package:studyu_app/screens/study/dashboard/contact_tab/contact_screen.dart';
import 'package:studyu_app/screens/study/dashboard/contact_tab/faq.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_app/screens/study/dashboard/settings.dart';
import 'package:studyu_app/screens/study/dashboard/study_information.dart';
import 'package:studyu_app/screens/study/multimodal/capture_picture_screen.dart';
import 'package:studyu_app/screens/study/onboarding/consent.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/screens/study/onboarding/intervention_selection.dart';
import 'package:studyu_app/screens/study/onboarding/journey_overview.dart';
import 'package:studyu_app/screens/study/onboarding/study_overview.dart';
import 'package:studyu_app/screens/study/onboarding/study_selection.dart';
import 'package:studyu_app/screens/study/report/report_details.dart';
import 'package:studyu_app/screens/study/report/report_history.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/widgets/onboarding_shell.dart';
import 'package:studyu_core/core.dart';

/// Route name constants
class RouteNames() {
  static const String loading = 'loading';
  static const String preview = 'preview';
  static const String appOutdated = 'appOutdated';
  static const String appErrorScreen = 'appError';
  static const String studyUnavailable = 'studyUnavailable';
  static const String dashboard = 'dashboard';
  static const String welcome = 'welcome';
  static const String onboarding = 'onboarding';
  static const String terms = 'terms';
  static const String recoveryPhrase = 'recoveryPhrase';
  static const String restoreAccount = 'restoreAccount';
  static const String about = 'about';
  static const String studySelection = 'studySelection';
  static const String studyOverview = 'studyOverview';
  static const String interventionSelection = 'interventionSelection';
  static const String journey = 'journey';
  static const String consent = 'consent';
  static const String contact = 'contact';
  static const String studyInformation = 'studyInformation';
  static const String faq = 'faq';
  static const String appSettings = 'settings';
  static const String questionnaire = 'questionnaire';
  static const String reportHistory = 'reportHistory';
  static const String reportDetails = 'reportDetails';
  static const String performanceDetails = 'performanceDetails';
  static const String task = 'task';
  static const String eligibilityCheck = 'eligibilityCheck';
  static const String kickoff = 'kickoff';
  static const String capturePicture = 'capturePicture';
  static const String invite = 'invite';
  static const String study = 'study';
}

bool isStudyAvailableForTesting(Study study) =>
    study.interventions.length >= StudySchedule.numberOfInterventions;

/// Enrollment routes a started participant must not re-enter. `/terms`
/// stays readable as an informational document.
const Set<String> _enrollmentRoutePaths = <String>{
  '/${RouteNames.welcome}',
  '/${RouteNames.studySelection}',
  '/${RouteNames.studyOverview}',
  '/${RouteNames.interventionSelection}',
  '/${RouteNames.eligibilityCheck}',
  '/${RouteNames.journey}',
  '/${RouteNames.consent}',
  '/${RouteNames.kickoff}',
};

/// Phase guarded by each study onboarding route.
StudyOnboardingPhase? _phaseForRoute(String path) => switch (path) {
  '/${RouteNames.studyOverview}' => StudyOnboardingPhase.overview,
  '/${RouteNames.terms}' => StudyOnboardingPhase.terms,
  '/${RouteNames.eligibilityCheck}' => StudyOnboardingPhase.eligibility,
  '/${RouteNames.interventionSelection}' =>
    StudyOnboardingPhase.interventionSelection,
  '/${RouteNames.journey}' => StudyOnboardingPhase.journey,
  '/${RouteNames.consent}' => StudyOnboardingPhase.consent,
  _ => null,
};

/// Canonical route for each onboarding phase.
String onboardingStepRoute(StudyOnboardingPhase? phase) => switch (phase) {
  StudyOnboardingPhase.overview => '/${RouteNames.studyOverview}',
  StudyOnboardingPhase.terms => '/${RouteNames.terms}',
  StudyOnboardingPhase.eligibility => '/${RouteNames.eligibilityCheck}',
  StudyOnboardingPhase.interventionSelection =>
    '/${RouteNames.interventionSelection}',
  StudyOnboardingPhase.journey => '/${RouteNames.journey}',
  StudyOnboardingPhase.consent => '/${RouteNames.consent}',
  StudyOnboardingPhase.complete => '/${RouteNames.dashboard}',
  null => '/${RouteNames.loading}',
};

String? routePrerequisiteRedirect(
  String path,
  Object? extra,
  AppState appState,
) {
  final activeSubject = appState.activeSubject;
  final started = activeSubject?.startedAt != null;

  // Enrollment-phase restrictions apply only to the non-preview flow;
  // preview mode intentionally retains direct access to onboarding routes.
  if (!appState.isPreview) {
    // A started participant must not re-enter any enrollment route.
    if (started && _enrollmentRoutePaths.contains(path)) {
      return '/${RouteNames.dashboard}';
    }

    final phase = appState.effectiveOnboardingPhase;
    if (phase != null) {
      // `/welcome` must not stay open once a participant has an active
      // subject: the entry hub must not abandon or replace an in-progress
      // enrollment. A pending invite deep link has no subject yet and
      // still enters through the welcome dialog.
      if (path == '/${RouteNames.welcome}' && activeSubject != null) {
        return onboardingStepRoute(phase);
      }

      // An enrolling participant may open the current phase route and
      // navigate back to an earlier phase; every forward jump redirects
      // to the canonical current step.
      final routePhase = _phaseForRoute(path);
      if (routePhase != null && routePhase.index > phase.index) {
        return onboardingStepRoute(phase);
      }
    }
  }

  final hasPrerequisite = switch (path) {
    '/${RouteNames.studyOverview}' ||
    '/${RouteNames.interventionSelection}' => appState.selectedStudy != null,
    '/${RouteNames.eligibilityCheck}' =>
      appState.selectedStudy != null ||
          extra is Study ||
          extra is EligibilityScreenArguments && extra.study != null,
    '/${RouteNames.journey}' ||
    '/${RouteNames.consent}' => appState.activeSubject != null,
    '/${RouteNames.dashboard}' ||
    '/${RouteNames.appSettings}' ||
    '/${RouteNames.studyInformation}' ||
    '/${RouteNames.reportHistory}' => appState.activeSubject?.startedAt != null,
    // Route extras cannot be supplied through a URL, so a missing or
    // mismatched extra means the route was opened outside the app flow.
    '/${RouteNames.task}' => extra is TaskInstance,
    '/${RouteNames.reportDetails}' =>
      // Historical reports are loaded per user id
      // (StudySubject.getStudyHistory), so matching the signed-in
      // participant's user id is the trustworthy ownership invariant.
      appState.activeSubject?.startedAt != null &&
          extra is StudySubject &&
          extra.userId == appState.activeSubject!.userId,
    '/${RouteNames.capturePicture}' =>
      appState.activeSubject?.startedAt != null &&
          extra is Map<String, String> &&
          extra['studyId'] == appState.activeSubject!.studyId &&
          extra['userId'] == appState.activeSubject!.userId,
    _ => true,
  };

  return hasPrerequisite
      ? null
      : appState.activeSubject?.startedAt != null
      ? '/${RouteNames.dashboard}'
      : '/${RouteNames.loading}';
}

String initialRouteFromPlatformRoute(String platformRoute) {
  final uri = Uri.tryParse(platformRoute);
  if (uri == null) return '/${RouteNames.loading}';

  final isWebEntryRoute = switch (uri.pathSegments) {
    [RouteNames.preview] => true,
    [RouteNames.invite, final code] ||
    [RouteNames.study, final code] when code.isNotEmpty => true,
    _ => false,
  };
  final isAppLink =
      uri.scheme == appScheme &&
      (uri.host == RouteNames.invite || uri.host == RouteNames.study) &&
      uri.pathSegments.length == 1 &&
      uri.pathSegments.first.isNotEmpty;

  return isWebEntryRoute || isAppLink
      ? platformRoute
      : '/${RouteNames.loading}';
}

/// Creates and configures the GoRouter instance for the app
GoRouter createAppRouter({
  required Map<String, String> queryParameters,
  String initialLocation = '/${RouteNames.loading}',
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation,
    errorBuilder: (context, state) {
      // Unknown routes restart through the loading flow so the canonical
      // router (with its availability and prerequisite guards) decides
      // the next screen instead of stranding the user on an error page.
      return const LoadingScreen();
    },
    redirect: (context, state) {
      if (state.uri.scheme == appScheme) {
        if (state.uri.host == 'invite') {
          final code = state.uri.pathSegments.isNotEmpty
              ? state.uri.pathSegments.first
              : '';
          if (code.isNotEmpty) {
            return '/${RouteNames.invite}/${Uri.encodeComponent(code)}';
          }
        }

        if (state.uri.host == 'study') {
          final studyId = state.uri.pathSegments.isNotEmpty
              ? state.uri.pathSegments.first
              : '';
          if (studyId.isNotEmpty) {
            return '/${RouteNames.study}/$studyId';
          }
        }
      }

      final appState = context.read<AppState>();
      final study = switch (state.uri.path) {
        '/${RouteNames.studyOverview}' ||
        '/${RouteNames.interventionSelection}' ||
        '/${RouteNames.eligibilityCheck}' => appState.selectedStudy,
        '/${RouteNames.journey}' ||
        '/${RouteNames.consent}' ||
        '/${RouteNames.dashboard}' ||
        '/${RouteNames.appSettings}' ||
        '/${RouteNames.studyInformation}' ||
        '/${RouteNames.reportHistory}' =>
          appState.activeSubject?.study ?? appState.selectedStudy,
        _ => null,
      };
      if (study != null && !isStudyAvailableForTesting(study)) {
        return '/${RouteNames.studyUnavailable}';
      }

      final prerequisiteRedirect = routePrerequisiteRedirect(
        state.uri.path,
        state.extra,
        appState,
      );
      if (prerequisiteRedirect != null) return prerequisiteRedirect;

      // Remove splash screen when navigating away from loading screen
      if (state.uri.path != '/${RouteNames.loading}') {
        FlutterNativeSplash.remove();
      }
      return null; // No redirect, just proceed with the requested route
    },
    routes: [
      GoRoute(
        path: '/${RouteNames.loading}',
        name: RouteNames.loading,
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.preview}',
        name: RouteNames.preview,
        builder: (context, state) =>
            LoadingScreen(queryParameters: state.uri.queryParameters),
      ),
      GoRoute(
        path: '/${RouteNames.appOutdated}',
        name: RouteNames.appOutdated,
        builder: (context, state) => const AppOutdatedScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.appErrorScreen}',
        name: RouteNames.appErrorScreen,
        builder: (context, state) {
          final arguments = switch (state.extra) {
            final AppErrorScreenArguments args => args,
            final String selectedSubjectId => AppErrorScreenArguments(
              selectedSubjectId: selectedSubjectId,
            ),
            _ => const AppErrorScreenArguments(),
          };
          return AppErrorScreen(
            selectedSubjectId: arguments.selectedSubjectId,
            reason: arguments.reason,
          );
        },
      ),
      GoRoute(
        path: '/${RouteNames.studyUnavailable}',
        name: RouteNames.studyUnavailable,
        builder: (context, state) => const StudyUnavailableScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.dashboard}',
        name: RouteNames.dashboard,
        builder: (context, state) {
          final error = state.extra as String?;
          return DashboardScreen(error: error);
        },
      ),
      GoRoute(
        path: '/${RouteNames.welcome}',
        name: RouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.onboarding}',
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.about}',
        name: RouteNames.about,
        builder: (context, state) => const AboutScreen(),
      ),

      GoRoute(
        path: '/${RouteNames.restoreAccount}',
        name: RouteNames.restoreAccount,
        builder: (context, state) => const RestoreAccountScreen(),
      ),
      // Persistent onboarding shell: BottomOnboardingNavigation stays mounted
      // while only the child page changes during the study-onboarding flow.
      // Keep selection here so its study-tile Hero shares this navigator.
      ShellRoute(
        builder: (context, state, child) => OnboardingShell(
          routePath: state.uri.path,
          hideNavigation: state.uri.path == '/${RouteNames.studySelection}',
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/${RouteNames.studySelection}',
            name: RouteNames.studySelection,
            builder: (context, state) => const StudySelectionScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.studyOverview}',
            name: RouteNames.studyOverview,
            builder: (context, state) => const StudyOverviewScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.terms}',
            name: RouteNames.terms,
            builder: (context, state) {
              final arguments = state.extra;
              return TermsScreen(
                isPushed: arguments == true || arguments is TermsScreenArguments
                    ? true
                    : null,
                onAccepted: arguments is TermsScreenArguments
                    ? arguments.onAccepted
                    : null,
              );
            },
          ),
          GoRoute(
            path: '/${RouteNames.eligibilityCheck}',
            name: RouteNames.eligibilityCheck,
            builder: (context, state) {
              final extra = state.extra;
              final selectedStudy = context.read<AppState>().selectedStudy;
              if (extra is EligibilityScreenArguments) {
                return EligibilityScreen(
                  study: extra.study ?? selectedStudy,
                  onEligible: extra.onEligible,
                );
              }
              return EligibilityScreen(study: extra as Study? ?? selectedStudy);
            },
          ),
          GoRoute(
            path: '/${RouteNames.interventionSelection}',
            name: RouteNames.interventionSelection,
            builder: (context, state) => const InterventionSelectionScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.journey}',
            name: RouteNames.journey,
            builder: (context, state) => const JourneyOverviewScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.consent}',
            name: RouteNames.consent,
            builder: (context, state) => const ConsentScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.recoveryPhrase}',
            name: RouteNames.recoveryPhrase,
            builder: (context, state) => RecoveryPhraseScreen(
              continueToDashboard:
                  state.uri.queryParameters['next'] == RouteNames.dashboard,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/${RouteNames.contact}',
        name: RouteNames.contact,
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.studyInformation}',
        name: RouteNames.studyInformation,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          name: state.uri.path,
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          child: const StudyInformationScreen(),
        ),
      ),
      GoRoute(
        path: '/${RouteNames.faq}',
        name: RouteNames.faq,
        builder: (context, state) => const FAQ(),
      ),
      GoRoute(
        path: '/${RouteNames.appSettings}',
        name: RouteNames.appSettings,
        builder: (context, state) => const Settings(),
      ),
      GoRoute(
        path: '/${RouteNames.reportHistory}',
        name: RouteNames.reportHistory,
        builder: (context, state) => const ReportHistoryScreen(),
      ),
      GoRoute(
        path: '/${RouteNames.task}',
        name: RouteNames.task,
        builder: (context, state) {
          final taskInstance = state.extra as TaskInstance?;
          if (taskInstance == null) {
            return const Scaffold(
              body: SafeArea(
                child: Center(child: Text('Error: Task instance not provided')),
              ),
            );
          }
          return TaskScreen(taskInstance: taskInstance);
        },
      ),

      GoRoute(
        path: '/${RouteNames.reportDetails}',
        name: RouteNames.reportDetails,
        builder: (context, state) {
          final subject = state.extra as StudySubject?;
          if (subject == null) {
            return const Scaffold(
              body: SafeArea(
                child: Center(child: Text('Error: Subject not provided')),
              ),
            );
          }
          return ReportDetailsScreen(subject);
        },
      ),
      GoRoute(
        path: '/${RouteNames.capturePicture}',
        name: RouteNames.capturePicture,
        builder: (context, state) {
          final params = state.extra as Map<String, String>?;
          if (params == null ||
              params['studyId'] == null ||
              params['userId'] == null) {
            return const Scaffold(
              body: SafeArea(
                child: Center(
                  child: Text('Error: Missing required parameters'),
                ),
              ),
            );
          }
          return CapturePictureScreen(
            studyId: params['studyId']!,
            userId: params['userId']!,
          );
        },
      ),
      GoRoute(
        path: '/${RouteNames.invite}/:code',
        name: RouteNames.invite,
        builder: (context, state) =>
            LoadingScreen(deepLinkInviteCode: state.pathParameters['code']),
      ),
      GoRoute(
        path: '/${RouteNames.study}/:id',
        name: RouteNames.study,
        builder: (context, state) =>
            LoadingScreen(deepLinkStudyId: state.pathParameters['id']),
      ),
    ],
  );
}
