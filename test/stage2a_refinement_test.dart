import 'dart:ui' as ui;

import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/theme/digigym_workout_theme.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/digigym_atmospheric_background.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/workout_glass_card.dart';
import 'package:digigym/widgets/recommended_workout_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'workout_appearance_test.dart' as interaction;
import 'workout_theme_visual_test.dart' as visuals;
import 'workouts_screen_test.dart' as actions;

void main() {
  setUpAll(visuals.loadWorkoutVisualFonts);

  testWidgets(
    'Home and Workout glass render identically at identical dimensions',
    (tester) async {
      final home = DigiGymDashboardTheme.content(
        DigiGymDashboardTheme.light(ThemeData(useMaterial3: true)),
      );
      final workout = DigiGymWorkoutTheme.apply(home);
      final samples = <List<int>>[];
      for (final theme in [home, workout]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: const ValueKey('glass-sample'),
                  child: SizedBox(
                    width: 280,
                    height: 200,
                    child: DigiGymAtmosphericBackground(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: DashboardGlassCard(
                          child: Center(
                            child: Text(
                              'Glass sample',
                              style: theme.textTheme.bodyMedium,
                            ),
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
        final card = tester.widget<DashboardGlassCard>(
          find.byType(DashboardGlassCard),
        );
        expect(card.surfaceOpacity, 1);
        expect(card.backdropSigma, 0);
        expect(card.cornerRadius, 16);
        samples.add(
          (await tester.runAsync(() async {
            final image = await captureImage(
              tester.element(find.byKey(const ValueKey('glass-sample'))),
            );
            try {
              return (await image.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              ))!.buffer.asUint8List().toList();
            } finally {
              image.dispose();
            }
          }))!,
        );
      }
      expect(
        samples.last,
        samples.first,
        reason: 'Same surface, lighting, edge, shadow and opacity must produce exactly the same pixels.',
      );
    },
  );

  testWidgets(
    'only the light recommendation opts out of regular Workout glass',
    (tester) async {
      for (final light in [true, false]) {
        await visuals.pumpWorkoutTheme(tester, light: light, configured: false);
        for (final view in ['myPlan', 'exercises', 'moreWorkouts']) {
          await actions.activate(tester, 'workout-view-$view');
          if (view == 'exercises') await interaction.expandFirst(tester);
          expect(find.byType(WorkoutGlassCard), findsWidgets);
          for (final element in find.byType(DashboardGlassCard).evaluate()) {
            final card = element.widget as DashboardGlassCard;
            final surfaces = DigiGymSurfaces.of(element);
            final recommendation =
                light &&
                find
                    .ancestor(
                      of: find.byWidget(card),
                      matching: find.byType(RecommendedWorkoutGlassCard),
                    )
                    .evaluate()
                    .isNotEmpty;
            if (recommendation) {
              expect(card.surfaceOpacity, 1);
              expect(card.lightingOpacity, 1);
              expect(card.backdropSigma, 12);
              expect(surfaces.glass, RecommendedWorkoutGlassCard.fill);
              expect(
                surfaces.glassLighting,
                RecommendedWorkoutGlassCard.reflection,
              );
              expect(surfaces.glassEdge, RecommendedWorkoutGlassCard.edge);
              expect(surfaces.glassShadow, DigiGymSurfaces.light.glassShadow);
              continue;
            }
            expect(card.surfaceOpacity, light ? .8 : 1);
            expect(card.lightingOpacity, light ? .6 : 1);
            expect(card.backdropSigma, light ? 8 : 0);
            expect(card.cornerRadius, 16);
            final expected = light
                ? DigiGymSurfaces.light
                : DigiGymSurfaces.dark;
            expect(surfaces.glass, expected.glass);
            expect(surfaces.glassLighting, expected.glassLighting);
            expect(surfaces.glassEdge, expected.glassEdge);
            expect(surfaces.glassShadow, expected.glassShadow);
            expect(
              find.descendant(
                of: find.byWidget(card),
                matching: find.byType(BackdropFilter),
              ),
              light ? findsOneWidget : findsNothing,
            );
          }
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'approved light orange changes only Intermediate Plan and retains dark semantics',
    (tester) async {
      for (final light in [false, true]) {
        for (final level in ['Intermediate', 'Beginner', 'Advanced']) {
          await visuals.pumpWorkoutTheme(
            tester,
            light: light,
            user: actions.profile(level: level),
          );
          final label = tester.widget<Text>(find.text('$level Plan'));
          final expected = !light
              ? DigiGymFitnessLevelColors.forLevel(level)
              : level == 'Intermediate'
              ? const Color(0xFF99570E)
              : const Color(0xFF606C65);
          expect(label.style!.color, expected);
          expect(label.style!.fontFamily, DigiGymDashboardTheme.textFont);
          expect(label.style!.fontSize, 14);
          expect(label.style!.fontWeight, FontWeight.w400);
          expect(tester.takeException(), isNull);
        }
      }
      double contrast(Color ink, Color background) =>
          (background.computeLuminance() + .05) /
          (ink.computeLuminance() + .05);
      for (final silver in [
        const Color(0xFFF9FAFC),
        const Color(0xFFF2F4F6),
        const Color(0xFFEEF0F3),
      ]) {
        expect(
          contrast(DigiGymFitnessLevelColors.intermediate, silver),
          lessThan(2.1),
        );
        expect(
          contrast(DigiGymWorkoutTheme.intermediatePlanAccent, silver),
          greaterThan(4.8),
        );
      }
    },
  );

  testWidgets(
    'navigation uses 30 percent fill without changing its blur, shape or foreground',
    (tester) async {
      await visuals.pumpWorkoutTheme(tester, light: true);
      final nav = find.byType(FloatingBottomNavigationBar);
      final blur = find.descendant(
        of: nav,
        matching: find.byType(BackdropFilter),
      );
      expect(
        tester.widget<BackdropFilter>(blur).filter,
        ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      );
      final material = tester.widget<Material>(
        find.descendant(of: blur, matching: find.byType(Material)),
      );
      expect(material.color, const Color(0x4DF8F9FB));
      expect(material.color!.a, closeTo(.30, .003));
      final shape = material.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(48));
      expect(shape.side.color, const Color(0xEBFFFFFF));
      final surfaces = DigiGymSurfaces.light;
      expect(surfaces.navigationActive, const Color(0xFF237C47));
      expect(surfaces.navigationInactive, const Color(0xFF626C66));
      expect(DigiGymWorkoutTheme.segmentSurface, const Color(0x6BF8F9FB));
      expect(DigiGymSurfaces.dark.navigationSurface, const Color(0x331A201E));
      expect(tester.takeException(), isNull);
    },
  );
}
