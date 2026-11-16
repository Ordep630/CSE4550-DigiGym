import 'dart:ui' as ui;

import 'package:digigym/widgets/digigym_brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'packaged logo variants share geometry and green pixels at every density',
    () async {
      for (final layout in DigiGymLogoLayout.values) {
        for (final scale in [1.0, 2.0, 3.0]) {
          Future<ui.Image> load(Brightness brightness) async {
            final provider = AssetImage(
              DigiGymBrandLogo.assetName(layout, brightness),
            );
            final key = await provider.obtainKey(
              ImageConfiguration(bundle: rootBundle, devicePixelRatio: scale),
            );
            expect(key.scale, scale);
            final data = await key.bundle.load(key.name);
            final codec = await ui.instantiateImageCodec(
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
            );
            try {
              return (await codec.getNextFrame()).image;
            } finally {
              codec.dispose();
            }
          }

          final dark = await load(Brightness.dark);
          final light = await load(Brightness.light);
          try {
            expect((light.width, light.height), (dark.width, dark.height));
            final original = (await dark.toByteData(
              format: ui.ImageByteFormat.rawStraightRgba,
            ))!.buffer.asUint8List();
            final alternate = (await light.toByteData(
              format: ui.ImageByteFormat.rawStraightRgba,
            ))!.buffer.asUint8List();
            var green = 0;
            var neutral = 0;
            var transparent = 0;
            var antialiased = 0;
            var changedSilhouette = 0;
            var changedGreen = 0;
            for (var offset = 0; offset < original.length; offset += 4) {
              final alpha = original[offset + 3];
              if (alpha != alternate[offset + 3]) changedSilhouette++;
              if (alpha == 0) {
                transparent++;
                continue;
              }
              if (alpha != 255) antialiased++;
              final r = original[offset];
              final g = original[offset + 1];
              final b = original[offset + 2];
              if (g > r + 20 && g > b + 20) {
                green++;
                if (r != alternate[offset] ||
                    g != alternate[offset + 1] ||
                    b != alternate[offset + 2]) {
                  changedGreen++;
                }
              } else if (alpha == 255 && r == 255 && g == 255 && b == 255) {
                neutral++;
                expect(alternate.sublist(offset, offset + 3), [
                  0x18,
                  0x21,
                  0x1d,
                ]);
              }
            }
            expect(changedSilhouette, 0, reason: '${layout.name} at ${scale}x');
            expect(changedGreen, 0, reason: '${layout.name} at ${scale}x');
            expect([
              green,
              neutral,
              transparent,
              antialiased,
            ], everyElement(isPositive));
            expect(
              original[3],
              0,
              reason: 'Logo canvas corner must be transparent.',
            );
          } finally {
            dark.dispose();
            light.dispose();
          }
        }
      }
    },
  );
}
