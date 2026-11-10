import 'dart:ui' show ImageFilter;

import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/theme/digigym_dot_typography.dart';
import 'package:digigym/widgets/workout_overview.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/dashboard_information_dialogs.dart';
import 'package:digigym/widgets/dashboard_number.dart';
import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/segmented_progress_ring.dart';
import 'package:digigym/widgets/soft_glow_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ThemeData palette(bool light) => light
      ? DigiGymDashboardTheme.light(ThemeData(useMaterial3: true))
      : DigiGymDashboardTheme.dark(ThemeData(useMaterial3: true));

  test('light preserves the exact approved green and branding tokens', () {
    final theme = palette(true);
    final surfaces = theme.extension<DigiGymSurfaces>()!;
    expect(surfaces.accent, const Color(0xFF237C47));
    expect(surfaces.navigationActive, const Color(0xFF237C47));
    expect(theme.colorScheme.primary, const Color(0xFF70FF45));
    expect(theme.colorScheme.primaryContainer, const Color(0xFFE0F0E2));
    expect(theme.colorScheme.onPrimaryContainer, const Color(0xFF237C47));
    expect(surfaces.brandingInk, const Color(0xFF18211D));
    expect(surfaces.progressTrack, const Color(0xFFD4DDD5));
  });

  test(
    'background layers are neutral silver and white without a green wash',
    () {
      final surfaces = DigiGymSurfaces.light;
      for (final gradient in [
        surfaces.background.gradient!,
        surfaces.atmosphere.gradient!,
      ]) {
        for (final color in gradient.colors) {
          expect(
            color.g,
            lessThanOrEqualTo(color.r > color.b ? color.r : color.b),
          );
        }
      }
      expect(surfaces.background.gradient, isA<LinearGradient>());
      expect(
        (surfaces.atmosphere.gradient! as RadialGradient).radius,
        greaterThan(1.5),
      );
      expect(
        palette(true).colorScheme.onSurface.computeLuminance(),
        lessThan(.02),
      );
    },
  );

  test(
    'refinement defaults retain dark typography and decoration behavior',
    () {
      final dark = DigiGymSurfaces.dark;
      expect(dark.numberScale, 1);
      expect(dark.dotoWeightBoost, 0);
      expect(dark.dotFillRatio, DotMatrixPainter.dotRatio);
      expect(dark.bmiSurfaceOpacity, 1);
      expect(dark.bmiBackdropSigma, 0);
      expect(dark.selectionGlowOpacity, 0);
      expect(dark.glowIntensity, 1);
      expect(dark.navigationGlowOpacity, .85);
      expect(dark.navigationGlowSigma, 4);
    },
  );

  testWidgets(
    'shared Workout dots keep identical light and dark geometry and readable units',
    (tester) async {
      Size? darkSize;
      for (final light in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: palette(light),
            home: const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 240,
                  child: DashboardNumber(
                    value: '2075 Cal',
                    fontSize: 32,
                    unitFontSize: 17,
                    fitToWidth: true,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final digits = tester.widget<DotMatrixText>(find.byType(DotMatrixText));
        expect(digits.text, '2075');
        expect(digits.fillRatio, DigiGymDotTypography.fillRatio);
        expect(digits.softenedDigits, isTrue);
        expect(digits.height, 32 * .9);
        final unit = tester.widget<Text>(find.text('Cal'));
        expect(unit.style!.fontSize, 17);
        expect(unit.style!.fontFamily, DigiGymDashboardTheme.textFont);
        final size = tester.getSize(find.byType(DashboardNumber));
        if (!light) {
          darkSize = size;
        } else {
          expect(size, darkSize);
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('Workout duration is the shared reference in both appearances', (
    tester,
  ) async {
    for (final light in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: palette(light),
          home: const Scaffold(
            body: Column(
              children: [
                WorkoutDurationDisplay(minutes: 30),
                DashboardNumber(value: '30 min'),
                DashboardNumber(value: '2,075 Cal'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final displays = tester
          .widgetList<DotMatrixText>(find.byType(DotMatrixText))
          .toList();
      expect(displays, hasLength(3));
      expect(displays.first.height, DigiGymDotTypography.workoutHeight);
      for (final display in displays) {
        expect(display.fillRatio, displays.first.fillRatio);
        expect(display.softenedDigits, displays.first.softenedDigits);
      }
      expect(displays.last.text, '2,075');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'progress retains a fixed ring slot, separated dots, and fits every percentage',
    (tester) async {
      for (final light in [false, true]) {
        double? digitHeight;
        for (final value in [0.0, 25.0, 75.0, 100.0]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: palette(light),
              home: Scaffold(
                body: Center(child: SegmentedProgressRing(progress: value)),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.getSize(find.byType(SegmentedProgressRing)),
            const Size(148, 148),
          );
          final digits = tester.widget<DotMatrixText>(
            find.byKey(const ValueKey('progress-percentage')),
          );
          expect(digits.fillRatio, DigiGymDotTypography.fillRatio);
          expect(digits.softenedDigits, isTrue);
          expect(digits.fillRatio, lessThan(1));
          digitHeight ??= digits.height;
          expect(digits.height, digitHeight);
          final ring = tester.getRect(find.byType(SegmentedProgressRing));
          final bounds = tester.getRect(
            find.byKey(const ValueKey('progress-percentage')),
          );
          expect(ring.contains(bounds.topLeft), isTrue);
          expect(ring.contains(bounds.bottomRight), isTrue);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'light glow follows the glyph in two layers and dark glow stays unchanged',
    (tester) async {
      for (final light in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: palette(light),
            home: Scaffold(
              body: const SoftGlowIcon(
                icon: Icons.scale_outlined,
                color: Color(0xFF237C47),
              ),
              bottomNavigationBar: FloatingBottomNavigationBar(
                selectedIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final label = tester.widget<Text>(find.text('Home'));
        expect(label.style!.shadows, light ? isNotEmpty : isNull);
        final iconGlow = find.byKey(const ValueKey('navigation-icon-glow'));
        expect(
          tester
              .widget<Opacity>(
                find
                    .descendant(of: iconGlow, matching: find.byType(Opacity))
                    .first,
              )
              .opacity,
          light ? .7 : .85,
        );
        if (light) {
          final glow = find.descendant(
            of: find.byType(SoftGlowIcon),
            matching: find.byType(DigiGymGlyphGlow),
          );
          expect(glow, findsOneWidget);
          expect(
            find.descendant(of: glow, matching: find.byType(ImageFiltered)),
            findsNWidgets(2),
          );
          expect(
            find.descendant(
              of: find.byType(SoftGlowIcon),
              matching: find.byType(DecoratedBox),
            ),
            findsNothing,
          );
          final filters = tester
              .widgetList<ImageFiltered>(
                find.descendant(of: glow, matching: find.byType(ImageFiltered)),
              )
              .map((w) => w.imageFilter);
          expect(
            filters,
            containsAll([
              ImageFilter.blur(sigmaX: .45, sigmaY: .45),
              ImageFilter.blur(sigmaX: 2.8, sigmaY: 2.8),
            ]),
          );
        } else {
          expect(find.byType(DigiGymGlyphGlow), findsNothing);
          expect(
            find.descendant(
              of: find.byType(SoftGlowIcon),
              matching: find.byType(DecoratedBox),
            ),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('decorative light glow honors an explicitly disabled intensity', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: palette(true),
        home: const Scaffold(
          body: SoftGlowIcon(
            icon: Icons.scale_outlined,
            color: Color(0xFF237C47),
            glowIntensity: 0,
          ),
        ),
      ),
    );
    expect(find.byType(DigiGymGlyphGlow), findsNothing);
    expect(find.byIcon(Icons.scale_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'only the light BMI popup gains subtle translucency and local frosting',
    (tester) async {
      for (final light in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: palette(light),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showDashboardBmiDialog(context, bmi: 24.7),
                  child: const Text('Open BMI'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open BMI'));
        await tester.pumpAndSettle();
        final card = tester.widget<DashboardGlassCard>(
          find.byType(DashboardGlassCard),
        );
        expect(card.surfaceOpacity, light ? .94 : 1);
        expect(card.backdropSigma, light ? 14 : 0);
        if (light) {
          final surfaces = DigiGymSurfaces.of(
            tester.element(find.byType(DashboardGlassCard)),
          );
          expect(surfaces.glass.gradient!.colors, const [
            Color(0xEBFFFFFF),
            Color(0xCEF8F9FB),
            Color(0xD5E9ECF0),
            Color(0xE6FFFFFF),
          ]);
          expect(surfaces.glassLighting.gradient!.colors, const [
            Color(0xB8FFFFFF),
            Color(0x26FFFFFF),
            Color(0x00FFFFFF),
          ]);
          expect(surfaces.glassEdge.colors, const [
            Color(0xFFFFFFFF),
            Color(0xD9FFFFFF),
            Color(0x1A78818E),
            Color(0x3078818E),
            Color(0xF2FFFFFF),
          ]);
          expect(
            surfaces.glassShadow,
            const BoxShadow(
              color: Color(0x16545D6B),
              blurRadius: 24,
              offset: Offset(0, 9),
            ),
          );
        }
        expect(
          find.byType(BackdropFilter),
          light ? findsOneWidget : findsNothing,
        );
        if (light) {
          expect(
            tester.widget<BackdropFilter>(find.byType(BackdropFilter)).filter,
            ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          );
        }
        expect(find.text('Healthy weight'), findsOneWidget);
        await tester.tap(find.text('Got It'));
        await tester.pumpAndSettle();
        expect(find.text('What is BMI?'), findsNothing);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
