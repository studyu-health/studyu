import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/photo_recall_section.dart';

const _photoManagerChannel = MethodChannel('com.fluttercandies/photo_manager');

Widget _testApp(Locale locale) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  locale: locale,
  home: Scaffold(body: PhotoRecallSection(date: DateTime(2026, 7, 15))),
);

void main() {
  var permissionState = PermissionState.authorized;

  setUp(() {
    permissionState = PermissionState.authorized;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_photoManagerChannel, (call) async {
          switch (call.method) {
            case 'getPermissionState':
              return permissionState.index;
            case 'getAssetPathList':
              return <dynamic>[];
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_photoManagerChannel, null);
  });

  testWidgets('keeps the empty gallery passive', (tester) async {
    await tester.pumpWidget(_testApp(const Locale('en')));
    await tester.pumpAndSettle();

    final emptyLabel = find.text('No photos found');
    expect(emptyLabel, findsOneWidget);
    expect(
      find.ancestor(of: emptyLabel, matching: find.byType(Card)),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: emptyLabel, matching: find.byType(InkWell)),
      findsNothing,
    );
  });

  testWidgets('keeps permission explanation and request in the content', (
    tester,
  ) async {
    permissionState = PermissionState.denied;

    await tester.pumpWidget(_testApp(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Enable Photo Access'), findsOneWidget);
    expect(
      find.text(
        'Access to your photos helps you recall what you ate. Photos are only displayed on your device.',
      ),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(FilledButton, 'Grant Permission'),
      findsOneWidget,
    );
  });

  testWidgets('uses natural German permission copy', (tester) async {
    permissionState = PermissionState.denied;

    await tester.pumpWidget(_testApp(const Locale('de')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Der Zugriff auf Ihre Fotos hilft Ihnen, sich an das Gegessene zu erinnern. Fotos werden nur auf Ihrem Gerät angezeigt.',
      ),
      findsOneWidget,
    );
  });
}
