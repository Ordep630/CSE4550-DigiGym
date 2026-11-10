import 'dart:io';
import 'dart:ui' as ui;

import 'package:digigym/widgets/recommended_workout_glass_card.dart';
import 'package:digigym/widgets/workout_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'workout_theme_visual_test.dart' as visuals;

void main() {
  setUpAll(visuals.loadWorkoutVisualFonts);

  testWidgets(
    'recommended glass has a visible surface change and preserves the View Plan button pixels',
    (tester) async {
      final shadows = debugDisableShadows;
      debugDisableShadows = false;
      try {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(426, 952);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await visuals.pumpWorkoutTheme(tester, light: true);
        final recommendation = find.byType(RecommendedWorkoutGlassCard);
        expect(recommendation, findsOneWidget);
        final card = tester.getRect(recommendation).deflate(4);
        final button = tester.getRect(
          find.byKey(const ValueKey('workout-featured-exercises')),
        );
        // Exclude rounded-corner coverage over the newly translucent surface.
        final buttonCore = Rect.fromLTRB(
          button.left + 25,
          button.top + 1,
          button.right - 25,
          button.bottom - 1,
        );
        final content = [
          for (final type in [
            Text,
            WorkoutDurationDisplay,
            FilledButton,
            TextButton,
          ])
            for (final element
                in find
                    .descendant(of: recommendation, matching: find.byType(type))
                    .evaluate())
              tester.getRect(find.byWidget(element.widget)).inflate(1),
        ];
        await tester.runAsync(() async {
          final codec = await ui.instantiateImageCodec(
            await File(
              'test/goldens/workout_light_stage2a_glass_my_plan_android.png',
            ).readAsBytes(),
          );
          final oldImage = (await codec.getNextFrame()).image;
          final current = await captureImage(
            tester.element(find.byType(MaterialApp)),
          );
          try {
            expect(current.width, oldImage.width);
            expect(current.height, oldImage.height);
            final before = (await oldImage.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!.buffer.asUint8List();
            final after = (await current.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!.buffer.asUint8List();
            var total = 0;
            var changed = 0;
            var difference = 0;
            var buttonChanges = 0;
            for (var y = 0; y < current.height; y++) {
              for (var x = 0; x < current.width; x++) {
                final point = Offset(x + .5, y + .5);
                final offset = (y * current.width + x) * 4;
                final delta = [
                  for (var c = 0; c < 3; c++)
                    (before[offset + c] - after[offset + c]).abs(),
                ];
                if (buttonCore.contains(point) &&
                    delta.any((value) => value != 0)) {
                  buttonChanges++;
                }
                if (!card.contains(point) ||
                    content.any((rect) => rect.contains(point))) {
                  continue;
                }
                total++;
                difference += delta.reduce((a, b) => a + b);
                if (delta.any((value) => value >= 8)) changed++;
              }
            }
            expect(
              buttonChanges,
              0,
              reason: 'Button fill, icon and text must remain pixel-identical.',
            );
            expect(
              changed / total,
              greaterThan(.25),
              reason: 'A meaningful share of the exposed material must visibly differ from the last revision.',
            );
            expect(
              difference / (total * 3),
              greaterThan(4),
              reason: 'Reject another negligible opacity-only difference.',
            );
          } finally {
            oldImage.dispose();
            current.dispose();
            codec.dispose();
          }
        });
        expect(tester.takeException(), isNull);
      } finally {
        debugDisableShadows = shadows;
      }
    },
  );
}
