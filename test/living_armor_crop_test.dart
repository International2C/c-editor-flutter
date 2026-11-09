import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/widgets/asset_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('living armor visible bounds', () async {
    for (final side in ['left', 'right']) {
      final data = await rootBundle.load(
        'assets/images/griditems/living_armor_$side.webp',
      );
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final img = frame.image;
      final rgba = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      final crop = livingArmorDisplayCrop(
        'assets/images/griditems/living_armor_$side.webp',
      )!;
      expect(img.width, 390);
      expect(img.height, 390);
      for (final threshold in [0]) {
        int minX = img.width, minY = img.height, maxX = 0, maxY = 0;
        for (var y = 0; y < img.height; y++) {
          for (var x = 0; x < img.width; x++) {
            if (rgba.getUint8((y * img.width + x) * 4 + 3) <= threshold)
              continue;
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
        expect(
          crop.contains(ui.Offset(minX.toDouble(), minY.toDouble())),
          isTrue,
        );
        expect(
          crop.contains(ui.Offset(maxX.toDouble(), maxY.toDouble())),
          isTrue,
        );
        expect(390 / crop.height, greaterThan(1.12));
      }
      img.dispose();
      codec.dispose();
    }
  });
  test('other item assets retain their original framing', () {
    expect(
      livingArmorDisplayCrop('assets/images/griditems/pumpkin_house.webp'),
      isNull,
    );
  });
}
