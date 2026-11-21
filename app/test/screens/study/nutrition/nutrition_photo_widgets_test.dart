import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:studyu_app/screens/study/nutrition/nutrition_photo_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resizes and orients a JPEG without keeping its metadata', () async {
    final source = image.Image(width: 2000, height: 1000);
    source.exif.imageIfd.orientation = 6;

    final bytes = await prepareNutritionPhoto(image.encodeJpg(source));
    final result = image.decodeJpg(bytes)!;

    expect(result.width, 800);
    expect(result.height, 1600);
    expect(result.exif.imageIfd.hasOrientation, isFalse);
  });

  test('normalizes a PNG to a JPEG', () async {
    final source = image.Image(width: 40, height: 60);
    final bytes = await prepareNutritionPhoto(image.encodePng(source));
    final result = image.decodeJpg(bytes)!;

    expect((result.width, result.height), (40, 60));
  });

  test('rejects input above the source size limit', () async {
    await expectLater(
      prepareNutritionPhoto(Uint8List(30000001)),
      throwsFormatException,
    );
  });
}
