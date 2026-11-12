import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';

void main() {
  Finder foreground(int index) => find.descendant(
    of: find.byKey(ValueKey('navigation-icon-$index')),
    matching: find.byKey(const ValueKey('navigation-icon-foreground')),
  );

  Finder workoutImage() =>
      find.descendant(of: foreground(1), matching: find.byType(Image));

  Widget host({
    Brightness brightness = Brightness.light,
    int index = 0,
    ValueChanged<int>? onTap,
  }) {
    return MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        bottomNavigationBar: FloatingBottomNavigationBar(
          selectedIndex: index,
          onDestinationSelected: onTap ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('all five destinations dispatch their existing indices', (
    tester,
  ) async {
    final taps = <int>[];
    await tester.pumpWidget(host(onTap: taps.add));
    for (final label in ['Home', 'Workout', 'Meals', 'Groceries', 'Profile']) {
      await tester.tap(find.text(label));
    }
    expect(taps, [0, 1, 2, 3, 4]);
  });

  testWidgets(
    'glass stays clipped to the existing pill and keeps its palettes',
    (tester) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(host(brightness: brightness));
        await tester.pumpAndSettle();
        final blur = find.byType(BackdropFilter);
        expect(blur, findsOneWidget);
        expect(
          tester.widget<BackdropFilter>(blur).filter,
          ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        );
        final clip = find.ancestor(of: blur, matching: find.byType(ClipRRect));
        expect(clip, findsOneWidget);
        expect(
          tester.widget<ClipRRect>(clip).borderRadius,
          BorderRadius.circular(48),
        );
        expect(tester.widget<ClipRRect>(clip).clipBehavior, Clip.antiAlias);
        expect(tester.getRect(clip), tester.getRect(blur));
        final material = tester.widget<Material>(
          find.descendant(of: blur, matching: find.byType(Material)),
        );
        final shape = material.shape! as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(48));
        if (brightness == Brightness.dark) {
          expect(
            material.color,
            const Color(0xFF1A201E).withValues(alpha: .20),
          );
          expect(shape.side.color.a, closeTo(.15, .001));
        } else {
          expect(material.color, const Color(0xE6F5F8F5));
          expect(shape.side.color, const Color(0x99FFFFFF));
        }
      }
    },
  );

  testWidgets(
    'glass reveals and frosts the backdrop without blurring the margin',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 400);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Widget scene({Color? color}) => MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          extendBody: true,
          body: CustomPaint(
            painter: _NavigationBackdrop(color),
            child: const SizedBox.expand(),
          ),
          bottomNavigationBar: FloatingBottomNavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      );

      Future<List<List<int>>> sample(List<Offset> points) async {
        return (await tester.runAsync(() async {
          final image = await captureImage(
            tester.element(find.byType(Scaffold)),
          );
          try {
            final bytes = (await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!;
            return [
              for (final point in points)
                [
                  for (var channel = 0; channel < 3; channel++)
                    bytes.getUint8(
                      (point.dy.round() * image.width + point.dx.round()) * 4 +
                          channel,
                    ),
                ],
            ];
          } finally {
            image.dispose();
          }
        }))!;
      }

      await tester.pumpWidget(scene());
      await tester.pumpAndSettle();
      final pill = tester.getRect(find.byType(BackdropFilter));
      final pixels = await sample([
        Offset(pill.left + 96, pill.top + 6),
        Offset(pill.left + 104, pill.top + 6),
        Offset(2, pill.center.dy),
        Offset(10, pill.center.dy),
      ]);
      for (var channel = 0; channel < 3; channel++) {
        expect(
          (pixels[0][channel] - pixels[1][channel]).abs(),
          lessThan(10),
          reason: 'The striped backdrop must be frosted inside the pill.',
        );
        expect(
          (pixels[2][channel] - pixels[3][channel]).abs(),
          greaterThan(40),
          reason: 'The surrounding margin must retain sharp backdrop detail.',
        );
      }

      final backdropSamples = <List<int>>[];
      for (final color in [const Color(0xFF203830), const Color(0xFF90C0A0)]) {
        await tester.pumpWidget(scene(color: color));
        await tester.pumpAndSettle();
        backdropSamples.add(
          (await sample([Offset(pill.center.dx, pill.top + 6)])).single,
        );
      }
      expect(
        backdropSamples[1][1] - backdropSamples[0][1],
        greaterThan(136 * .65),
        reason: 'At least 65% of backdrop contrast must survive the glass, including its shadow.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'workout uses the official asset with sharp filtering and proportional width',
    (tester) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(host(brightness: brightness, index: 1));
        final image = tester.widget<Image>(workoutImage());
        expect(
          (image.image as AssetImage).assetName,
          'assets/images/digigym_workout_icon.png',
        );
        expect(image.width, 38);
        expect(image.height, isNull);
        expect(image.filterQuality, FilterQuality.none);
        expect(image.fit, BoxFit.contain);
        expect(
          find.ancestor(
            of: workoutImage(),
            matching: find.byType(ImageFiltered),
          ),
          findsNothing,
        );
        final glowImage = tester.widget<Image>(
          find.descendant(
            of: find.byKey(const ValueKey('navigation-icon-glow')),
            matching: find.byType(Image),
          ),
        );
        expect(glowImage.image, image.image);
        expect(glowImage.width, image.width);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('selection follows parent state and theme brightness', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(host(brightness: brightness, index: 1));
      expect(find.bySemanticsLabel('Workout'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Workout')),
        matchesSemantics(
          label: 'Workout',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      final selectedColor = tester.widget<Image>(workoutImage()).color;
      await tester.pumpWidget(host(brightness: brightness, index: 0));
      expect(tester.widget<Image>(workoutImage()).color, isNot(selectedColor));
    }
    semantics.dispose();
  });

  testWidgets(
    'only selected icons glow without a filled badge or layout shift',
    (tester) async {
      const labels = ['Home', 'Workout', 'Meals', 'Groceries', 'Profile'];
      Rect? originalBounds;
      final glowStrength = <Brightness, double>{};
      for (final brightness in Brightness.values) {
        final selected = brightness == Brightness.dark
            ? const Color(0xFF70FF45)
            : const Color(0xFF21865C);
        final inactive = brightness == Brightness.dark
            ? const Color(0xFFA6AEAA)
            : const Color(0xFF626C66);
        for (var index = 0; index < labels.length; index++) {
          await tester.pumpWidget(host(brightness: brightness, index: index));
          await tester.pumpAndSettle();
          final bar = tester.getRect(find.byType(FloatingBottomNavigationBar));
          originalBounds ??= bar;
          expect(bar, originalBounds);
          final glow = find.byKey(const ValueKey('navigation-icon-glow'));
          expect(glow, findsOneWidget);
          expect(find.byType(ImageFiltered), findsOneWidget);
          final slot = find.byKey(ValueKey('navigation-icon-$index'));
          expect(tester.getRect(glow), tester.getRect(slot));
          expect(
            tester.getRect(glow).bottom,
            lessThan(tester.getRect(find.text(labels[index])).top),
          );
          expect(tester.widget<IgnorePointer>(glow).ignoring, isTrue);
          glowStrength[brightness] = tester
              .widget<Opacity>(
                find.descendant(of: glow, matching: find.byType(Opacity)),
              )
              .opacity;
          for (
            var destination = 0;
            destination < labels.length;
            destination++
          ) {
            final iconSlot = find.byKey(
              ValueKey('navigation-icon-$destination'),
            );
            expect(tester.getSize(iconSlot), const Size(44, 32));
            expect(
              find.descendant(
                of: iconSlot,
                matching: find.byType(DecoratedBox),
              ),
              findsNothing,
            );
            final expectedColor = destination == index ? selected : inactive;
            final icon = foreground(destination);
            if (destination == 1) {
              expect(tester.widget<Image>(workoutImage()).color, expectedColor);
            } else {
              final glyph = tester.widget<Icon>(
                find.descendant(of: icon, matching: find.byType(Icon)),
              );
              expect(glyph.color, expectedColor);
              expect(glyph.size, 24);
            }
            final label = tester.widget<Text>(find.text(labels[destination]));
            expect(label.style?.color, expectedColor);
            expect(label.style?.fontSize, 10);
          }
          expect(tester.takeException(), isNull);
        }
      }
      expect(glowStrength[Brightness.light], greaterThan(0));
      expect(glowStrength[Brightness.dark], lessThan(1));
      expect(
        glowStrength[Brightness.light],
        lessThan(glowStrength[Brightness.dark]!),
      );
    },
  );

  testWidgets('fits narrow and wide layouts with safe area and enlarged text', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final width in [320.0, 1200.0]) {
      for (final scale in [1.0, 2.0, 3.0]) {
        tester.view.physicalSize = Size(width, 800);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 800),
                padding: const EdgeInsets.only(bottom: 34),
                textScaler: TextScaler.linear(scale),
              ),
              child: Scaffold(
                bottomNavigationBar: FloatingBottomNavigationBar(
                  selectedIndex: 0,
                  onDestinationSelected: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final surface = tester.getRect(find.byType(BackdropFilter));
        expect(surface.width, lessThanOrEqualTo(560));
        expect(surface.bottom, lessThanOrEqualTo(766));
      }
    }
  });
}

/// High-contrast stripes make real backdrop filtering observable without a
/// platform-dependent golden. A solid color isolates the transmission test.
class _NavigationBackdrop extends CustomPainter {
  final Color? color;

  const _NavigationBackdrop(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (color != null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = color!);
      return;
    }
    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, 8, size.height),
        Paint()
          ..color = (x ~/ 8).isEven
              ? const Color(0xFF95C5AF)
              : const Color(0xFF21352D),
      );
    }
  }

  @override
  bool shouldRepaint(_NavigationBackdrop oldDelegate) =>
      color != oldDelegate.color;
}
