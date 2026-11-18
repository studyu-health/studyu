import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/multimodal/capture_picture_screen.dart';
import 'package:studyu_core/core.dart';

class _CaptureHarness(final WidgetTester tester) {
  late final Directory directory;
  late final GoRouter router;
  FutureBlobFile? answer;
  bool returned = false;
  int captures = 0;
  static const cameraChannel = MethodChannel('plugins.flutter.io/camera');
  static const pathChannel = MethodChannel('plugins.flutter.io/path_provider');

  Future<void> open() async {
    directory = Directory.systemTemp.createTempSync('studyu-preview-');
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      pathChannel,
      (_) async => directory.path,
    );
    messenger.setMockMethodCallHandler(cameraChannel, (call) async {
      switch (call.method) {
        case 'availableCameras':
          return [
            {
              'name': 'test-camera',
              'lensFacing': 'back',
              'sensorOrientation': 0,
            },
          ];
        case 'create':
          return {'cameraId': 1};
        case 'initialize':
          tester.binding.channelBuffers.push(
            'flutter.io/cameraPlugin/camera1',
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall('initialized', {
                'previewWidth': 640.0,
                'previewHeight': 480.0,
                'exposureMode': 'auto',
                'exposurePointSupported': false,
                'focusMode': 'auto',
                'focusPointSupported': false,
              }),
            ),
            (_) {},
          );
          return null;
        case 'takePicture':
          captures++;
          final file = File(path.join(directory.path, 'capture-$captures.png'));
          File(path.join('assets', 'icon', 'icon.png')).copySync(file.path);
          return file.path;
        default:
          return null;
      }
    });
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () async {
                answer = await context.push<FutureBlobFile>('/camera');
                returned = true;
              },
              child: const Text('Open camera'),
            ),
          ),
        ),
        GoRoute(
          path: '/camera',
          builder: (_, _) => const CapturePictureScreen(
            userId: 'test-user',
            studyId: 'test-study',
          ),
        ),
      ],
    );
    addTearDown(() async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        messenger.setMockMethodCallHandler(cameraChannel, null);
        messenger.setMockMethodCallHandler(pathChannel, null);
        await directory.delete(recursive: true);
      });
    });
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    );
    await tap(find.text('Open camera'));
  }

  Future<void> tap(Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> capture() async {
    final button = tester.widget<FloatingActionButton>(
      find.widgetWithIcon(FloatingActionButton, Icons.camera_alt),
    );
    await tester.runAsync(button.onPressed! as Future<void> Function());
    await tester.pumpAndSettle();
  }

  Future<void> retake() async {
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Retake'),
    );
    await tester.runAsync(button.onPressed! as Future<void> Function());
    await tester.pumpAndSettle();
  }

  Future<List<File>> stagedPhotos() async => (await tester.runAsync(() async {
    final staging = Directory(path.join(directory.path, 'multimodal-temp'));
    return await staging
        .list()
        .where((entry) => entry is File)
        .cast<File>()
        .toList();
  }))!;
}

void main() {
  testWidgets('shows the captured photo before returning an answer', (
    tester,
  ) async {
    final h = _CaptureHarness(tester);
    await h.open();
    await h.capture();

    expect(h.returned, isFalse);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Retake'), findsOneWidget);
    expect(find.text('Use photo'), findsOneWidget);
    expect(await h.stagedPhotos(), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'retake discards the first photo and accepts only the new photo',
    (tester) async {
      final h = _CaptureHarness(tester);
      await h.open();
      await h.capture();
      final first = (await h.stagedPhotos()).single;
      await h.retake();

      expect(h.returned, isFalse);
      expect(await tester.runAsync(first.exists), isFalse);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);

      await h.capture();
      final second = (await h.stagedPhotos()).single;
      expect(second.path, isNot(first.path));
      await h.tap(find.text('Use photo'));

      expect(h.returned, isTrue);
      expect(h.answer?.localFilePath, second.path);
      expect(
        h.answer?.futureBlobId,
        path.basename(second.path).replaceFirst('staging_', ''),
      );
      expect(await tester.runAsync(second.exists), isTrue);
    },
  );

  testWidgets('back discards an unconfirmed photo without an answer', (
    tester,
  ) async {
    final h = _CaptureHarness(tester);
    await h.open();
    await h.capture();
    final photo = (await h.stagedPhotos()).single;
    await h.tap(find.byType(BackButton));

    expect(h.returned, isTrue);
    expect(h.answer, isNull);
    await tester.runAsync(() async {
      await Future.doWhile(() async {
        await tester.pump();
        return await photo.exists();
      }).timeout(const Duration(seconds: 5));
    });
    expect(await tester.runAsync(photo.exists), isFalse);
  });

  testWidgets('preview controls remain available in landscape', (tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final h = _CaptureHarness(tester);
    await h.open();
    await h.capture();

    expect(find.text('Retake').hitTestable(), findsOneWidget);
    expect(find.text('Use photo').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
