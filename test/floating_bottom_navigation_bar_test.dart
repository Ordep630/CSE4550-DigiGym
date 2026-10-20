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
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 800),
              padding: const EdgeInsets.only(bottom: 34),
              textScaler: TextScaler.linear(2),
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
  });
}
