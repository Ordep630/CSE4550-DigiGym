// Regression coverage for the Stage 1E reversion and calorie shadow.
import 'dart:ui' as ui;

import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/daily_streak_indicator.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/soft_glow_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dashboard_appearance_test.dart' as fixtures;

void main() {
  setUpAll(() async {
    for (final font in {
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
      DigiGymDashboardTheme.textFont: 'assets/fonts/Inter-Variable.ttf',
      DigiGymDashboardTheme.numberFont: 'assets/fonts/Doto-Variable.ttf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });

  ThemeData palette(bool light) => light
      ? DigiGymDashboardTheme.light(ThemeData(useMaterial3: true))
      : DigiGymDashboardTheme.dark(ThemeData(useMaterial3: true));

  test('pre-experiment yellow and green return with a compact warm shadow', () {
    final light = DigiGymSurfaces.light;
    expect(light.warmAccent, const Color(0xFFFFD35B));
    expect(light.warmAccent, DigiGymSurfaces.dark.warmAccent);
    expect(SoftGlowIcon.warmAmber, light.warmAccent);
    expect(light.streakAccent, const Color(0xFFFFAA58));
    expect(light.navigationActive, const Color(0xFF237C47));
    expect(light.navigationSurface, const Color(0x4DF8F9FB));
    expect(light.navigationBackdropSigma, 16);
    const shadow = DigiGymDashboardTheme.calorieFlameLightShadow;
    expect(shadow.color.a, lessThan(.3));
    expect(shadow.blurRadius, 2.2);
    expect(shadow.offset, const Offset(0, .75));
  });

  testWidgets('only the light calorie icon paints the new shadow', (
    tester,
  ) async {
    Rect? original;
    const shadow = DigiGymDashboardTheme.calorieFlameLightShadow;
    for (final light in [false, true]) {
      await tester.pumpWidget(fixtures.dashboard(theme: palette(light)));
      await tester.pumpAndSettle();
      final flame = find.descendant(
        of: find.byKey(const ValueKey('dashboard-calories-action')),
        matching: find.byType(SoftGlowIcon),
      );
      final widget = tester.widget<SoftGlowIcon>(flame);
      expect(widget.color, const Color(0xFFFFD35B));
      expect(widget.lightShadow, shadow);
      original ??= tester.getRect(flame);
      expect(tester.getRect(flame), original);
      final shadowGlyph = find.byWidgetPredicate(
        (w) =>
            w is Icon &&
            w.color == Colors.transparent &&
            (w.shadows?.contains(shadow) ?? false),
      );
      expect(shadowGlyph, light ? findsOneWidget : findsNothing);
      for (final element in find.byType(SoftGlowIcon).evaluate()) {
        if (element.widget != widget) {
          expect((element.widget as SoftGlowIcon).lightShadow, isNull);
        }
      }
      final streak = find.descendant(
        of: find.byType(DailyStreakIndicator),
        matching: find.byType(Icon),
      );
      expect(tester.widget<Icon>(streak).color, const Color(0xFFFFAA58));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'shadow stays local, preserves opaque yellow and leaves dark pixels unchanged',
    (tester) async {
      Future<List<int>> sample(bool light, bool shadow, double ratio) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: palette(light),
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: const ValueKey('flame-sample'),
                  child: ColoredBox(
                    color: const Color(0xFFF8F9FC),
                    child: SizedBox.square(
                      dimension: 64,
                      child: Center(
                        child: SoftGlowIcon(
                          icon: Icons.local_fire_department,
                          color: SoftGlowIcon.warmAmber,
                          lightShadow: shadow
                              ? DigiGymDashboardTheme.calorieFlameLightShadow
                              : null,
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
            find.byKey(const ValueKey('flame-sample')),
          );
          final image = await boundary.toImage(pixelRatio: ratio);
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

      for (final ratio in [1.0, 3.0]) {
        final plain = await sample(true, false, ratio);
        final shadowed = await sample(true, true, ratio);
        final width = (64 * ratio).round();
        var changed = 0;
        var yellow = 0;
        final local = Rect.fromLTRB(
          12 * ratio,
          12 * ratio,
          52 * ratio,
          52 * ratio,
        );
        for (var i = 0; i < plain.length; i += 4) {
          if (plain[i] == 0xFF &&
              plain[i + 1] == 0xD3 &&
              plain[i + 2] == 0x5B) {
            yellow++;
            expect(shadowed.sublist(i, i + 4), plain.sublist(i, i + 4));
          }
          if ([0, 1, 2, 3].any((c) => plain[i + c] != shadowed[i + c])) {
            changed++;
            expect(
              local.contains(
                Offset(
                  (i ~/ 4 % width).toDouble(),
                  (i ~/ 4 ~/ width).toDouble(),
                ),
              ),
              isTrue,
            );
          }
        }
        expect(yellow, greaterThan(0));
        expect(changed, greaterThan(0));
        expect(shadowed.take(4), plain.take(4));
      }
      expect(await sample(false, true, 1), await sample(false, false, 1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'all five active light states retain the original glow and label treatment',
    (tester) async {
      const labels = ['Home', 'Workout', 'Meals', 'Groceries', 'Profile'];
      for (var index = 0; index < labels.length; index++) {
        await tester.pumpWidget(
          MaterialApp(
            theme: palette(true),
            home: Scaffold(
              bottomNavigationBar: FloatingBottomNavigationBar(
                selectedIndex: index,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final slot = find.byKey(ValueKey('navigation-icon-$index'));
        expect(tester.getSize(slot), const Size(44, 32));
        final foreground = find.descendant(
          of: slot,
          matching: find.byKey(const ValueKey('navigation-icon-foreground')),
        );
        final color = index == 1
            ? tester
                  .widget<Image>(
                    find.descendant(
                      of: foreground,
                      matching: find.byType(Image),
                    ),
                  )
                  .color
            : tester
                  .widget<Icon>(
                    find.descendant(
                      of: foreground,
                      matching: find.byType(Icon),
                    ),
                  )
                  .color;
        expect(color, const Color(0xFF237C47));
        final glow = find.byKey(const ValueKey('navigation-icon-glow'));
        final filters = tester
            .widgetList<ImageFiltered>(
              find.descendant(of: glow, matching: find.byType(ImageFiltered)),
            )
            .map((w) => w.imageFilter);
        expect(
          filters,
          containsAll([
            ui.ImageFilter.blur(sigmaX: .45, sigmaY: .45),
            ui.ImageFilter.blur(sigmaX: 2.8, sigmaY: 2.8),
          ]),
        );
        expect(
          tester
              .widget<Opacity>(
                find.descendant(of: glow, matching: find.byType(Opacity)).first,
              )
              .opacity,
          .7,
        );
        expect(
          find.byKey(const ValueKey('navigation-icon-highlight')),
          findsOneWidget,
        );
        final label = tester.widget<Text>(find.text(labels[index]));
        expect(label.style!.color, const Color(0xFF237C47));
        expect(label.style!.shadows!.map((s) => s.blurRadius), [6, 12]);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
