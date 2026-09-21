import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_navigation.g.dart';

/// Navigates the user to a study editor page for the given study id.
typedef DashboardDispatch = void Function(String studyId);

/// Indirection between the dashboard controller and the app router.
///
/// The dashboard controller depends on this provider rather than the full
/// `routerProvider`, so importing the dashboard does not transitively pull in
/// every routed feature (some of which import web-only libraries that break
/// VM-target test compilation). The default body throws — production must
/// override it (see `main.dart`), and tests override it with a no-op.
@Riverpod(keepAlive: true)
DashboardDispatch dashboardDispatch(Ref ref) {
  throw UnimplementedError(
    'dashboardDispatchProvider must be overridden by the host application.',
  );
}
