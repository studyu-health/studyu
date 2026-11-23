import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:studyu_app/services/photo_gallery_service.dart';

const _photoManagerChannel = MethodChannel('com.fluttercandies/photo_manager');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_photoManagerChannel, null);
  });

  test('local day range uses calendar-day boundaries', () {
    final range = PhotoGalleryService.dayRange(DateTime(2026, 7, 15, 18, 30));

    expect(range.start, DateTime(2026, 7, 15));
    expect(range.end, DateTime(2026, 7, 16));
  });

  test('UTC range uses UTC midnight boundaries', () {
    final range = PhotoGalleryService.dayRange(DateTime.utc(2026, 7, 15, 18));

    expect(range.start, DateTime.utc(2026, 7, 15));
    expect(range.end, DateTime.utc(2026, 7, 16));
  });

  test('loads every photo from the aggregate album', () async {
    String? countedAlbumId;
    int? requestedSize;
    int? requestedStart;
    int? requestedEnd;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_photoManagerChannel, (call) async {
          switch (call.method) {
            case 'getPermissionState':
              return PermissionState.authorized.index;
            case 'getAssetPathList':
              final arguments = call.arguments as Map;
              final option = arguments['option'] as Map;
              final child = option['child'] as Map;
              final createDate = child['createDate'] as Map;
              requestedStart = createDate['min'] as int;
              requestedEnd = createDate['max'] as int;
              return {
                'data': [
                  {
                    'id': 'camera',
                    'name': 'Camera',
                    'assetCount': 3,
                    'albumType': 1,
                    'isAll': false,
                  },
                  {
                    'id': 'all',
                    'name': 'Recent',
                    'assetCount': 25,
                    'albumType': 1,
                    'isAll': true,
                  },
                ],
              };
            case 'getAssetCountFromPath':
              countedAlbumId = (call.arguments as Map)['id'] as String;
              return 25;
            case 'getAssetListPaged':
              final arguments = call.arguments as Map;
              requestedSize = arguments['size'] as int;
              return {
                'data': List.generate(
                  26,
                  (index) => {
                    'id': 'photo-$index',
                    'type': 1,
                    'width': 100,
                    'height': 100,
                    'createDt':
                        (index == 25
                                ? DateTime(2026, 7, 16)
                                : DateTime(2026, 7, 15, 12))
                            .millisecondsSinceEpoch ~/
                        1000,
                  },
                ),
              };
          }
          return null;
        });

    final photos = await PhotoGalleryService().getPhotosForDate(
      DateTime(2026, 7, 15),
    );

    expect(requestedStart, DateTime(2026, 7, 15).millisecondsSinceEpoch);
    expect(requestedEnd, DateTime(2026, 7, 16).millisecondsSinceEpoch);
    expect(countedAlbumId, 'all');
    expect(requestedSize, 25);
    expect(photos, hasLength(25));
  });
}
