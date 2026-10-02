import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/about.dart';
import 'package:studyu_app/screens/study/dashboard/settings.dart';
import 'package:studyu_app/widgets/app_connection_status_banner.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

Widget _buildTestApp({required AppState appState, required Widget child}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: appState),
      ChangeNotifierProvider<AppLanguage>(
        create: (_) => AppLanguage(AppLocalizations.supportedLocales),
      ),
    ],
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      home: AppConnectionStatusBannerHost(child: child),
    ),
  );
}

StudySubject _buildSubject() {
  final study = Study('study', 'user')
    ..title = 'Study title'
    ..interventions = [
      Intervention('intervention-a', 'Intervention A'),
      Intervention('intervention-b', 'Intervention B'),
    ];

  return StudySubject.fromStudy(
    study,
    'user',
    study.interventions.map((intervention) => intervention.id).toList(),
    null,
  );
}

Future<void> _setLargeSurface(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1440, 2400);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

void main() {
  tearDown(() {
    appConnectionStatusController.reset();
  });

  testWidgets('banner hidden when connection is healthy', (tester) async {
    await _setLargeSurface(tester);
    final appState = AppState();
    addTearDown(appState.dispose);

    await tester.pumpWidget(
      _buildTestApp(appState: appState, child: const AboutScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Cached study data'), findsNothing);
  });

  testWidgets('offline banner appears with offline copy', (tester) async {
    await _setLargeSurface(tester);
    final appState = AppState();
    addTearDown(appState.dispose);

    await tester.pumpWidget(
      _buildTestApp(appState: appState, child: const AboutScreen()),
    );

    appState.setConnectionStatus(AppConnectionStatus.deviceOffline);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'You are offline. Cached study data is in use and changes will sync when you are online again.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
  });

  testWidgets('backend unavailable banner appears with backend copy', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    final appState = AppState();
    addTearDown(appState.dispose);

    await tester.pumpWidget(
      _buildTestApp(appState: appState, child: const AboutScreen()),
    );

    appState.setConnectionStatus(AppConnectionStatus.backendUnavailable);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'StudyU service is currently unavailable. Cached study data remains available and changes will sync later.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.cloud_queue), findsOneWidget);
  });

  testWidgets('banner updates in place without duplicates', (tester) async {
    await _setLargeSurface(tester);
    final appState = AppState();
    addTearDown(appState.dispose);

    await tester.pumpWidget(
      _buildTestApp(appState: appState, child: const AboutScreen()),
    );

    appState.setConnectionStatus(AppConnectionStatus.deviceOffline);
    await tester.pumpAndSettle();
    appState.setConnectionStatus(AppConnectionStatus.backendUnavailable);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cloud_queue), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsNothing);
    expect(
      find.text(
        'You are offline. Cached study data is in use and changes will sync when you are online again.',
      ),
      findsNothing,
    );
    expect(
      find.text(
        'StudyU service is currently unavailable. Cached study data remains available and changes will sync later.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'banner shown on onboarding and study screens through shared host',
    (tester) async {
      await _setLargeSurface(tester);
      final onboardingState = AppState()
        ..setConnectionStatus(AppConnectionStatus.deviceOffline);
      addTearDown(onboardingState.dispose);

      await tester.pumpWidget(
        _buildTestApp(appState: onboardingState, child: const AboutScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      final studyState = AppState()
        ..activeSubject = _buildSubject()
        ..setConnectionStatus(AppConnectionStatus.deviceOffline);
      addTearDown(studyState.dispose);

      await tester.pumpWidget(
        _buildTestApp(appState: studyState, child: const Settings()),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.byType(Settings), findsOneWidget);
    },
  );

  test('AppState only notifies when connection status changes', () {
    final appState = AppState();
    addTearDown(appState.dispose);

    var notifications = 0;
    appState.addListener(() {
      notifications++;
    });

    appState.setConnectionStatus(AppConnectionStatus.deviceOffline);
    expect(notifications, 1);

    appState.setConnectionStatus(AppConnectionStatus.deviceOffline);
    expect(notifications, 1);

    appState.setConnectionStatus(AppConnectionStatus.backendUnavailable);
    expect(notifications, 2);
  });
}
