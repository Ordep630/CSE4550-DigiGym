import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Compare a retained reference without weakening checks outside approved edits.
Future<void> expectOnlyRegionsChanged(
  WidgetTester tester,
  Finder root, {
  required String reference,
  required List<Rect> regions,
  List<Rect> backdropContributions = const [],
  required String reason,
}) async {
  await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(
      await File(reference).readAsBytes(),
    );
    final before = (await codec.getNextFrame()).image;
    final after = await captureImage(tester.element(root));
    try {
      expect(after.width, before.width);
      expect(after.height, before.height);
      final oldBytes = (await before.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      final newBytes = (await after.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      var changed = 0;
      final examples = <Offset>[];
      for (var y = 0; y < after.height; y++) {
        for (var x = 0; x < after.width; x++) {
          if (regions.any(
            (region) => region.contains(Offset(x + .5, y + .5)),
          )) {
            continue;
          }
          final offset = (y * after.width + x) * 4;
          if ([
            0,
            1,
            2,
            3,
          ].any((c) => oldBytes[offset + c] != newBytes[offset + c])) {
            // A changed surface may be sampled by another existing frost
            // layer. Limit that allowance to its computed blur footprint and
            // one quantized channel step, rather than masking the whole popup.
            if (backdropContributions.any(
                  (region) => region.contains(Offset(x + .5, y + .5)),
                ) &&
                [0, 1, 2, 3].every(
                  (c) =>
                      (oldBytes[offset + c] - newBytes[offset + c]).abs() <= 1,
                )) {
              continue;
            }
            changed++;
            if (examples.length < 12) {
              examples.add(Offset(x.toDouble(), y.toDouble()));
            }
          }
        }
      }
      expect(changed, 0, reason: '$reason First differences: $examples');
    } finally {
      before.dispose();
      after.dispose();
      codec.dispose();
    }
  });
}
