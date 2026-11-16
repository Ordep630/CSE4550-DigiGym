import 'dart:ui' as ui;

import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/theme/digigym_dot_typography.dart';
import 'package:digigym/widgets/daily_streak_indicator.dart';
import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:digigym/widgets/dashboard_number.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/soft_glow_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dashboard_appearance_test.dart' as fixtures;

void main() {
  ThemeData palette(bool light) => light
      ? DigiGymDashboardTheme.light(ThemeData(useMaterial3: true))
      : DigiGymDashboardTheme.dark(ThemeData(useMaterial3: true));

  setUpAll(() async {
    for (final font in {
      DigiGymDashboardTheme.textFont: 'assets/fonts/Inter-Variable.ttf',
      DigiGymDashboardTheme.numberFont: 'assets/fonts/Doto-Variable.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });

  test('standard typography is Stage 1C; scoped statistics retain full dots and shrink five percent', () {
    expect(DigiGymDotTypography.fillRatio, .74);
    expect(DigiGymDotTypography.workoutHeight, 43.2);
    const previousStatisticHeight = 43.2 * .92;
    final previousDots = DotMatrixPainter.dotsFor(
      '30',
      previousStatisticHeight,
      softenedDigits: true,
      fillRatio: .88,
    );
    final correctedDots = DotMatrixPainter.dotsFor(
      '30',
      previousStatisticHeight * DigiGymDotTypography.statisticPaintScale,
      softenedDigits: true,
      fillRatio: DigiGymDotTypography.statisticFillRatio,
    );
    expect(correctedDots, hasLength(previousDots.length));
    expect(
      correctedDots.first.radius / previousDots.first.radius,
      closeTo(.95, .0001),
    );
    expect(DigiGymDotTypography.statisticFillRatio, .88);
  });

  test(
    'flames match their dark references and silver/green colors remain exact',
    () {
      final light = DigiGymSurfaces.light;
      final dark = DigiGymSurfaces.dark;
      expect(light.warmAccent, dark.warmAccent);
      expect(light.streakAccent, dark.streakAccent);
      expect(light.warmAccent, SoftGlowIcon.warmAmber);
      expect(light.accent, const Color(0xFF237C47));
      expect(light.navigationActive, const Color(0xFF237C47));
      expect(light.navigationBorder, const Color(0xEBFFFFFF));
      expect(
        light.navigationShadow,
        const BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 18,
          offset: Offset(0, 5),
        ),
      );
      expect(light.navigationSurface.a, closeTo(.30, .003));
      expect(light.navigationBackdropSigma, 16);
      expect(dark.navigationBackdropSigma, 14);
      expect(dark.iconStrokeHighlight, 0);
      expect(dark.numeralInk, DigiGymDarkColors.primaryText);
      expect(light.lerp(dark, 1).numeralInk, dark.numeralInk);
      expect(light.copyWith(numeralInk: Colors.red).numeralInk, Colors.red);
    },
  );

  testWidgets(
    'only the three statistics use black full dots; other numerals and flames retain their roles',
    (tester) async {
      await tester.pumpWidget(fixtures.dashboard(theme: palette(true)));
      await tester.pumpAndSettle();
      final statistics = find.byWidgetPredicate(
        (w) => w is DashboardNumber && w.statisticTypography,
      );
      expect(statistics, findsNWidgets(3));
      for (final element in statistics.evaluate()) {
        final digits = tester.widget<DotMatrixText>(
          find.descendant(
            of: find.byWidget(element.widget),
            matching: find.byType(DotMatrixText),
          ),
        );
        expect(digits.color, Colors.black);
        expect(digits.fillRatio, .88);
      }
      expect(
        find.byWidgetPredicate((w) => w is DotMatrixText && w.fillRatio == .88),
        findsNWidgets(3),
      );
      expect(
        tester
            .widget<DotMatrixText>(find.byKey(const ValueKey('activity-date')))
            .color,
        DigiGymSurfaces.light.accent,
      );
      expect(
        tester
            .widget<DotMatrixText>(
              find.byKey(const ValueKey('progress-percentage')),
            )
            .color,
        palette(true).colorScheme.onSurface,
      );
      final streak = find.byType(DailyStreakIndicator);
      expect(
        tester
            .widget<Icon>(
              find.descendant(of: streak, matching: find.byType(Icon)),
            )
            .color,
        DigiGymSurfaces.dark.streakAccent,
      );
      expect(
        tester
            .widget<SoftGlowIcon>(
              find.byWidgetPredicate(
                (w) =>
                    w is SoftGlowIcon && w.icon == Icons.local_fire_department,
              ),
            )
            .color,
        DigiGymSurfaces.dark.warmAccent,
      );
      expect(
        tester.widget<Text>(find.text('Cal')).style!.color,
        palette(true).colorScheme.onSurface,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'light core brightens actual stroke pixels and retains green edges',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      Future<List<int>> sample(bool illuminated, double pixelRatio) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: palette(true),
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: const ValueKey('glyph-sample'),
                  child: ColoredBox(
                    color: const Color(0xFFD9DFE7),
                    child: SizedBox.square(
                      dimension: 64,
                      child: Center(
                        child: DigiGymIlluminatedGlyph(
                          enabled: illuminated,
                          child: const Icon(
                            Icons.home,
                            size: 24,
                            color: Color(0xFF237C47),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        return (await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('glyph-sample')),
          );
          final image = await boundary.toImage(pixelRatio: pixelRatio);
          try {
            return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
                .buffer
                .asUint8List()
                .toList();
          } finally {
            image.dispose();
          }
        }))!;
      }

      for (final pixelRatio in [1.0, 3.0]) {
        final plain = await sample(false, pixelRatio);
        final lit = await sample(true, pixelRatio);
        var brighterStrokePixels = 0;
        var preservedEdgePixels = 0;
        for (var i = 0; i < plain.length; i += 4) {
          if (plain[i] == 0x23 &&
              plain[i + 1] == 0x7C &&
              plain[i + 2] == 0x47) {
            if (lit[i + 1] > plain[i + 1] + 15) {
              brighterStrokePixels++;
            }
            if (lit[i] == plain[i] &&
                lit[i + 1] == plain[i + 1] &&
                lit[i + 2] == plain[i + 2]) {
              preservedEdgePixels++;
            }
          }
        }
        expect(brighterStrokePixels, greaterThan(10));
        expect(preservedEdgePixels, greaterThan(0));
        expect(
          lit.take(4),
          plain.take(4),
          reason: 'The glyph highlight cannot fill its transparent bounding rectangle.',
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('light navigation transmits underlying color through the frost', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final greens = <int>[];
    for (final color in [const Color(0xFF203830), const Color(0xFF90C0A0)]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: palette(true),
          home: Scaffold(
            extendBody: true,
            body: ColoredBox(color: color, child: const SizedBox.expand()),
            bottomNavigationBar: FloatingBottomNavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final pill = tester.getRect(find.byType(BackdropFilter));
      greens.add(
        (await tester.runAsync(() async {
          final image = await captureImage(
            tester.element(find.byType(Scaffold)),
          );
          try {
            final bytes = (await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!;
            return bytes.getUint8(
              ((pill.top + 6).round() * image.width + pill.center.dx.round()) *
                      4 +
                  1,
            );
          } finally {
            image.dispose();
          }
        }))!,
      );
      expect(tester.takeException(), isNull);
    }
    expect(
      greens.last - greens.first,
      greaterThan(136 * .60),
      reason: 'More than 60% of backdrop contrast must survive the light glass, including its shadow.',
    );
  });
}
