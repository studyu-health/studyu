import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:photo_manager/photo_manager.dart';
import 'package:record/record.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/assisted/assisted_nutrition_input.dart';

const _photoManager = MethodChannel('com.fluttercandies/photo_manager');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(_photoManager, (call) async {
      return call.method == 'getPermissionState'
          ? PermissionState.denied.index
          : null;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(_photoManager, null));

  testWidgets(
    'uses the diary day and keeps photo actions visible during scroll',
    (tester) async {
      final day = DateTime.utc(2025, 5, 3);
      int? start;
      int? end;
      messenger.setMockMethodCallHandler(_photoManager, (call) async {
        final arguments = call.arguments as Map<Object?, Object?>?;
        return switch (call.method) {
          'getPermissionState' => PermissionState.authorized.index,
          'getAssetPathList' => () {
            final option = arguments!['option']! as Map<Object?, Object?>;
            final child = option['child']! as Map<Object?, Object?>;
            final date = child['createDate']! as Map<Object?, Object?>;
            start = date['min'] as int?;
            end = date['max'] as int?;
            return {
              'data': [
                {
                  'id': 'all',
                  'name': 'Recent',
                  'assetCount': 12,
                  'isAll': true,
                  'albumType': 1,
                },
              ],
            };
          }(),
          'getAssetCountFromPath' => 12,
          'getAssetListPaged' => {
            'data': [
              for (var index = 0; index < 12; index++)
                {
                  'id': 'photo-$index',
                  'type': 1,
                  'width': 100,
                  'height': 100,
                  'createDt': day.millisecondsSinceEpoch ~/ 1000 + index,
                },
            ],
          },
          _ => null,
        };
      });
      await _open(tester, day: day, onGenerate: (input) async => input);

      expect(start, day.millisecondsSinceEpoch);
      expect(end, DateTime.utc(2025, 5, 4).millisecondsSinceEpoch);
      expect(find.text('Add photos'), findsOneWidget);
      final camera = find.text('Take photo');
      final gallery = find.text('Open gallery');
      final cameraPosition = tester.getCenter(camera);
      final galleryPosition = tester.getCenter(gallery);

      await tester.drag(find.byType(GridView), const Offset(0, -150));
      await tester.pumpAndSettle();

      expect(tester.getCenter(camera), cameraPosition);
      expect(tester.getCenter(gallery), galleryPosition);
      final scrollable = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(Scrollable),
      );
      expect(
        tester.state<ScrollableState>(scrollable).position.pixels,
        greaterThan(0),
      );
    },
    variant: const TargetPlatformVariant({TargetPlatform.iOS}),
  );

  testWidgets('an empty day gallery keeps photo actions available', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(
      _photoManager,
      (call) async => switch (call.method) {
        'getPermissionState' => PermissionState.authorized.index,
        'getAssetPathList' => {'data': <Object>[]},
        _ => null,
      },
    );
    await _open(tester, onGenerate: (input) async => input);

    expect(find.text('Add photos'), findsNothing);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Open gallery'), findsOneWidget);
  }, variant: const TargetPlatformVariant({TargetPlatform.iOS}));

  testWidgets(
    'canceling suggestions keeps the description and suppresses stale results',
    (tester) async {
      final result = Completer<AssistedNutritionInput>();
      AssistedNutritionInput? submitted;
      await _open(
        tester,
        onGenerate: (input) {
          submitted = input;
          return result.future;
        },
      );
      await tester.tap(find.text('Continue without photos'));
      await tester.pumpAndSettle();
      final description = find.byType(TextField);
      expect(tester.widget<TextField>(description).controller!.text, isEmpty);
      await tester.tap(description);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(description).decoration!.hintText,
        isNull,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Generate meal suggestions'),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(description, 'Oatmeal for breakfast');
      await tester.pump();
      await tester.tap(find.text('Generate meal suggestions'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(submitted?.description, 'Oatmeal for breakfast');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      result.complete(submitted);
      await tester.pumpAndSettle();

      expect(find.text('Oatmeal for breakfast'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Generate meal suggestions'),
            )
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('photo removal preserves the reference to the remaining photo', (
    tester,
  ) async {
    final pixels = image.encodePng(image.Image(width: 2, height: 2));
    final input = AssistedNutritionInput(
      description: 'Photo 1 is breakfast. Photo 2 is lunch.',
      photos: [
        AssistedNutritionPhoto(id: 'breakfast', bytes: pixels),
        AssistedNutritionPhoto(id: 'lunch', bytes: pixels),
      ],
    );
    AssistedNutritionInput? submitted;
    await _open(
      tester,
      initialInput: input,
      onGenerate: (input) async {
        submitted = input;
        return input;
      },
    );

    expect(find.text('Add photos'), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.byTooltip('Remove photo'), findsNWidgets(2));
    await tester.tap(find.text('Continue to description'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove photo').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep photo'));
    await tester.pumpAndSettle();
    expect(
      find.text('Photo 1 is breakfast. Photo 2 is lunch.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Remove photo'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Remove photo').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove photo'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Reorder photos'), findsNothing);
    await tester.tap(find.text('Generate meal suggestions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(submitted?.photos.map((photo) => photo.id), ['lunch']);
    expect(
      submitted?.description,
      'removed photo is breakfast. Photo 1 is lunch.',
    );
  });

  testWidgets('reorder applies by photo identity only after Done', (
    tester,
  ) async {
    const description =
        'Photo #1 is breakfast. PHOTO 2 is lunch. Photo 8 is missing.';
    final photos = _testPhotos();
    AssistedNutritionInput? submitted;
    await _open(
      tester,
      initialInput: AssistedNutritionInput(
        description: description,
        photos: photos,
      ),
      onGenerate: (input) async {
        submitted = input;
        return input;
      },
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reorder photos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('lunch')));
    await tester.pumpAndSettle();
    expect(find.text('Photo 2 selected'), findsOneWidget);
    await tester.tap(find.text('Move earlier'));
    await tester.pumpAndSettle();
    expect(find.text('Photo 1 selected'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to description'));
    await tester.pumpAndSettle();
    expect(find.text(description), findsOneWidget);

    await tester.tap(find.byTooltip('Reorder photos'));
    await tester.pumpAndSettle();
    final moveEarlier = find.widgetWithText(OutlinedButton, 'Move earlier');
    expect(tester.widget<OutlinedButton>(moveEarlier).onPressed, isNull);
    await tester.tap(find.text('Move later'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    const updated =
        'Photo #2 is breakfast. PHOTO 1 is lunch. Photo 8 is missing.';
    expect(find.text(updated), findsOneWidget);
    await tester.tap(find.text('Generate meal suggestions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(submitted?.photos.map((photo) => photo.id), ['lunch', 'breakfast']);
    expect(submitted?.description, updated);
  });

  testWidgets('dragging photos updates the order after Done', (tester) async {
    await _open(
      tester,
      initialInput: AssistedNutritionInput(
        description: 'Photo 1 is breakfast. Photo 2 is lunch.',
        photos: _testPhotos(),
      ),
      onGenerate: (input) async => input,
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reorder photos'));
    await tester.pumpAndSettle();
    final breakfast = find.byKey(const ValueKey('breakfast'));
    final lunch = find.byKey(const ValueKey('lunch'));
    final start = tester.getCenter(breakfast);
    final end = tester.getCenter(lunch);
    final drag = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 550));
    final done = find.widgetWithText(FilledButton, 'Done');
    expect(tester.widget<FilledButton>(done).onPressed, isNull);
    for (var step = 1; step <= 8; step++) {
      await drag.moveTo(Offset.lerp(start, end, step / 8)!);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await drag.up();
    await tester.pumpAndSettle();

    expect(
      tester.getCenter(lunch).dx,
      lessThan(tester.getCenter(breakfast).dx),
    );
    expect(find.text('Photo 2 selected'), findsOneWidget);
    final canceledDrag = await tester.startGesture(tester.getCenter(lunch));
    await tester.pump(const Duration(milliseconds: 550));
    await canceledDrag.cancel();
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(done).onPressed, isNotNull);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Assisted meal logging'), findsOneWidget);
    await tester.tap(find.text('Continue to description'));
    await tester.pumpAndSettle();
    expect(
      find.text('Photo 2 is breakfast. Photo 1 is lunch.'),
      findsOneWidget,
    );
  });

  testWidgets('move buttons keep the selected photo visible in a long row', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _open(
      tester,
      initialInput: AssistedNutritionInput(
        description: '',
        photos: _testPhotos(['breakfast', 'lunch', 'dinner', 'snack']),
      ),
      onGenerate: (input) async => input,
    );
    await tester.tap(find.byTooltip('Reorder photos'));
    await tester.pumpAndSettle();
    final moveLater = find.widgetWithText(OutlinedButton, 'Move later');
    for (var move = 0; move < 3; move++) {
      await tester.tap(moveLater);
      await tester.pumpAndSettle();
    }

    final list = tester.getRect(find.byType(ReorderableListView));
    final photo = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('breakfast')),
        matching: find.byType(Image),
      ),
    );
    expect(photo.right, lessThanOrEqualTo(list.right + 0.01));
    expect(find.text('Photo 4 selected'), findsOneWidget);
    expect(tester.widget<OutlinedButton>(moveLater).onPressed, isNull);
  });

  testWidgets('passes the edited sample transcript to suggestion generation', (
    tester,
  ) async {
    final platform = RecordPlatform.instance;
    final microphone = _TestMicrophone();
    RecordPlatform.instance = microphone;
    addTearDown(() => RecordPlatform.instance = platform);

    AssistedNutritionInput? submitted;
    await _open(
      tester,
      onGenerate: (input) async {
        submitted = input;
        return input;
      },
    );
    await tester.tap(find.text('Continue without photos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Start recording'));
    await tester.pumpAndSettle();
    expect(find.text('Generate meal suggestions'), findsNothing);
    expect(find.text('Stop and transcribe'), findsOneWidget);

    microphone.audio.add(Uint8List(16));
    await tester.pump();
    await tester.tap(find.text('Stop and transcribe'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 900));

    expect(
      find.text('Sample transcript. You can edit it before continuing.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byType(TextField),
      'A banana at about 8:15 am.',
    );
    await tester.pump();
    await tester.tap(find.text('Generate meal suggestions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(submitted?.description, 'A banana at about 8:15 am.');
  });
}

List<AssistedNutritionPhoto> _testPhotos([
  List<String> ids = const ['breakfast', 'lunch'],
]) {
  final pixels = image.encodePng(image.Image(width: 2, height: 2));
  return [for (final id in ids) AssistedNutritionPhoto(id: id, bytes: pixels)];
}

class _TestMicrophone() extends RecordPlatform {
  final audio = StreamController<Uint8List>.broadcast();

  @override
  Future<void> create(String recorderId) async {}

  @override
  Future<bool> hasPermission(String recorderId, {bool request = true}) async =>
      true;

  @override
  Stream<RecordState> onStateChanged(String recorderId) => const Stream.empty();

  @override
  Future<Stream<Uint8List>> startStream(
    String recorderId,
    RecordConfig config,
  ) async => audio.stream;

  @override
  Future<String?> stop(String recorderId) async {
    await audio.close();
    return null;
  }

  @override
  Future<bool> isRecording(String recorderId) async => false;

  @override
  Future<void> dispose(String recorderId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _open(
  WidgetTester tester, {
  DateTime? day,
  AssistedNutritionInput? initialInput,
  required Future<AssistedNutritionInput> Function(AssistedNutritionInput)
  onGenerate,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAssistedNutritionInput(
              context,
              diaryDay: day ?? DateTime(2025, 5, 3),
              initialInput: initialInput,
              onGenerate: onGenerate,
            ),
            child: const Text('Open assisted input'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open assisted input'));
  await tester.pumpAndSettle();
}
