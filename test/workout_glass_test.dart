import 'dart:ui' as ui;

import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/workout_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Workout transmits more silver background than Home and softens detail',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 260);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      Future<List<Color>> sample({
        required bool workout,
        required Color background,
        bool stripes = false,
        bool blur = true,
      }) async {
        const content = SizedBox.expand();
        final card = workout
            ? blur
                  ? const WorkoutGlassCard(child: content)
                  : const DashboardGlassCard(
                      surfaceOpacity: .8,
                      lightingOpacity: .6,
                      child: content,
                    )
            : const DashboardGlassCard(child: content);
        await tester.pumpWidget(
          MaterialApp(
            theme: DigiGymDashboardTheme.light(ThemeData(useMaterial3: true)),
            home: Scaffold(
              body: RepaintBoundary(
                key: const ValueKey('sample'),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: background),
                    if (stripes) CustomPaint(painter: _SilverStripes()),
                    Padding(padding: const EdgeInsets.all(20), child: card),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        return (await tester.runAsync(() async {
          final image = await captureImage(
            tester.element(find.byKey(const ValueKey('sample'))),
          );
          try {
            final bytes = (await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!;
            return [
              for (var x = 100; x < 140; x++)
                Color.fromARGB(
                  255,
                  bytes.getUint8((180 * image.width + x) * 4),
                  bytes.getUint8((180 * image.width + x) * 4 + 1),
                  bytes.getUint8((180 * image.width + x) * 4 + 2),
                ),
            ];
          } finally {
            image.dispose();
          }
        }))!;
      }

      final differences = <double>[];
      for (final workout in [false, true]) {
        final pale = await sample(
          workout: workout,
          background: const Color(0xFFF0F1F3),
        );
        final silver = await sample(
          workout: workout,
          background: const Color(0xFFC5CBD4),
        );
        differences.add((pale.first.g - silver.first.g).abs());
      }
      expect(
        differences.last,
        greaterThan(differences.first * 1.5),
        reason: 'The actual layered material must transmit more backdrop, not just change a token.',
      );
      // A high-frequency neutral pattern should influence the frost without
      // remaining sharply visible behind text.
      final sharp = await sample(
        workout: true,
        background: Colors.white,
        stripes: true,
        blur: false,
      );
      final frosted = await sample(
        workout: true,
        background: Colors.white,
        stripes: true,
      );
      double range(List<Color> colors) {
        final values = colors.map((color) => color.g).toList()..sort();
        return values.last - values.first;
      }

      expect(range(frosted), lessThan(range(sharp) * .25));
      expect(tester.takeException(), isNull);
    },
  );
}

class _SilverStripes extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    for (var x = 0.0; x < size.width; x += 4) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, 2, size.height),
        Paint()..color = const Color(0xFFC5CBD4),
      );
    }
  }

  @override
  bool shouldRepaint(_SilverStripes oldDelegate) => false;
}
