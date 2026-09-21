// ignore_for_file: prefer_function_declarations_over_variables

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/intervention.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

/// Full list of routing events used across the app.
///
/// Each [RoutingIntent] represents a call to [GoRouter.goNamed] and can be
/// dispatched through a [GoRouter] reference like so:
///
///   final router = ref.read(routerProvider) // get router ref via riverpod
///   router.dispatch(RoutingIntents.someIntent)
///
/// For parametrized routes, consider using [RoutingIntentFactory] instead.
///
/// Some guidelines:
/// - If your route has a parameter that takes a fixed set of values, you
/// probably want to specify multiple [RoutingIntent]s (one for each value)
/// - If your route has a parameter that takes an infinite range of values,
/// your [RoutingIntent] should be a [RoutingIntentFactory] instead.
///
class RoutingIntents() {
  static final root = RoutingIntent(route: RouterConf.route(rootRouteName));
  static final studies = RoutingIntent(
    route: RouterConf.route(studiesRouteName),
  );
  static final studiesShared = RoutingIntent(
    route: RouterConf.route(studiesRouteName),
    queryParams: {
      RouteParams.studiesFilter: StudiesFilter.shared.toShortString(),
    },
  );
  static final publicRegistry = RoutingIntent(
    route: RouterConf.route(studiesRouteName),
    queryParams: {
      RouteParams.studiesFilter: StudiesFilter.public.toShortString(),
    },
  );
  static final study = (StudyID studyId) => RoutingIntent(
    route: RouterConf.route(studyRouteName),
    params: {RouteParams.studyId: studyId},
  );
  static final studyEdit = (StudyID studyId) => RoutingIntent(
    route: RouterConf.route(studyEditRouteName),
    params: {RouteParams.studyId: studyId},
  );
  static final studyEditInfo = (StudyID studyId) => RoutingIntent(
    route: RouterConf.route(studyEditInfoRouteName),
    params: {RouteParams.studyId: studyId},
  );
  static final studyEditEnrollment = (StudyID studyId) => RoutingIntent(
    route: RouterConf.route(studyEditEnrollmentRouteName),
    params: {RouteParams.studyId: studyId},
  );
  static final studyEditInterventions = (StudyID studyId) => RoutingIntent(
    route: RouterConf.route(studyEditInterventionsRouteName),
    params: {RouteParams.studyId: studyId},
  );
  static final studyEditIntervention =
      (StudyID studyId, InterventionID interventionId) => RoutingIntent(
        route: RouterConf.route(studyEditInterventionRouteName),
        params: {
          RouteParams.studyId: studyId,
          RouteParams.interventionId: interventionId,
        },
      );
  static final studyEditMeasurements = (StudyID studyId) => RoutingIntent(
    route: RouterConf.route(studyEditMeasurementsRouteName),
    params: {RouteParams.studyId: studyId},
  );
  static final studyEditReports = (StudyID studyId) => RoutingIntent(
    route: RouterConf.route(studyEditReportsRouteName),
    params: {RouteParams.studyId: studyId},
  );
  static final studyEditMeasurement =
      (
        StudyID studyId,
        MeasurementID measurementId, {
        Map<String, String>? queryParameters,
      }) => RoutingIntent(
        route: RouterConf.route(studyEditMeasurementRouteName),
        params: {
          RouteParams.studyId: studyId,
          RouteParams.measurementId: measurementId,
        },
        queryParams: queryParameters ?? {},
      );
  static RoutingIntent studyTest(StudyID studyId, {String? appRoute}) =>
      RoutingIntent(
        route: RouterConf.route(studyTestRouteName),
        params: {RouteParams.studyId: studyId},
        queryParams: {RouteParams.testAppRoute: ?appRoute},
      );
  static final studyRecruit = (StudyID studyId) => RoutingIntent(
    route: RouterConf.route(studyRecruitRouteName),
    params: {RouteParams.studyId: studyId},
  );
  static final studyMonitor = (StudyID studyId) => RoutingIntent(
    route: RouterConf.route(studyMonitorRouteName),
    params: {RouteParams.studyId: studyId},
  );
  static final studyAnalyze = (StudyID studyId) => RoutingIntent(
    route: RouterConf.route(studyAnalyzeRouteName),
    params: {RouteParams.studyId: studyId},
  );
  static final studySettings = (StudyID studyId) => RoutingIntent(
    route: RouterConf.route(studySettingsRouteName),
    params: {RouteParams.studyId: studyId},
    dispatch: RoutingIntentDispatch.push, // modal route
  );
  static final accountSettings = RoutingIntent(
    route: RouterConf.route(accountSettingsRouteName),
    dispatch: RoutingIntentDispatch.push, // modal route
  );
  static final studyNew = studyEdit(Config.newStudyId);
  static final login = RoutingIntent(route: RouterConf.route(loginRouteName));
  static final signup = RoutingIntent(route: RouterConf.route(signupRouteName));
  static final passwordForgot = RoutingIntent(
    route: RouterConf.route(forgotPasswordRouteName),
  );
  static final passwordForgot2 = (String email) => RoutingIntent(
    route: RouterConf.route(forgotPasswordRouteName),
    extra: email,
  );
  static final passwordRecovery = RoutingIntent(
    route: RouterConf.route(recoverPasswordRouteName),
  );
  static final error = (Exception error) =>
      RoutingIntent(route: RouterConf.route(errorRouteName), extra: error);
}

/// Signature for a function that returns a [RoutingIntent]
/// Helpful for parametrized routes with an infinite or indeterminate range of values
typedef RoutingIntentFactory = RoutingIntent Function(String);

/// The dispatch method to be used when calling [GoRouter.dispatch] with a
/// [RoutingIntent]
///
/// Note: [push] should be mostly reserved for non-opaque modal routes
enum RoutingIntentDispatch() {
  go,
  push,
}

/// Represent a unique routing event in the app, encapsulating a call to
/// [GoRouter.goNamed]. The intent is unpacked & results in a route change
/// when calling [GoRouter.dispatch].
class RoutingIntent({
  required final GoRoute route,
  final Map<String, String> params = const <String, String>{},
  final Map<String, String> queryParams = const <String, String>{},
  final Object? extra,
  final RoutingIntentDispatch? dispatch,
}) extends Equatable {
  this {
    _validateRoute();
  }

  String get routeName => route.name!;
  Map<String, String> get arguments => {...params, ...queryParams};

  void _validateRoute() {
    if (route.name == null) {
      throw Exception(
        "Failed to declare RoutingIntent for Route "
        "(path=${route.path}) because Route.name is not defined",
      );
    }
  }

  bool matches(RouteSettings settings) {
    if (settings.name != route.name) {
      return false;
    }
    if (settings.arguments is! Map) {
      return false;
    }
    if (!mapEquals(settings.arguments! as Map, arguments)) {
      return false;
    }
    return true;
  }

  // - Equatable

  @override
  List<Object?> get props => [route, params, queryParams, extra];
}

extension GoRouterX on GoRouter {
  /// Transforms a [RoutingIntent] into a call to [goNamed] or [pushNamed]
  ///
  /// The dispatch method is determined in order of priority based on this
  /// method's [push] parameter (if any) or the [RoutingIntent]'s default
  /// [RoutingIntent.dispatch] (if any). Otherwise defaults to [goNamed].
  void dispatch(RoutingIntent intent, {bool? push}) {
    const defaultDispatchMethod = RoutingIntentDispatch.go;

    final RoutingIntentDispatch dispatchMethod = (push != null)
        ? (push ? RoutingIntentDispatch.push : RoutingIntentDispatch.go)
        : ((intent.dispatch != null)
              ? intent.dispatch!
              : defaultDispatchMethod);

    if (dispatchMethod == RoutingIntentDispatch.push) {
      pushNamed(
        intent.route.name!,
        pathParameters: intent.params,
        queryParameters: intent.queryParams,
        extra: intent.extra,
      );
    } else if (dispatchMethod == RoutingIntentDispatch.go) {
      goNamed(
        intent.route.name!,
        pathParameters: intent.params,
        queryParameters: intent.queryParams,
        extra: intent.extra,
      );
    }
  }
}
