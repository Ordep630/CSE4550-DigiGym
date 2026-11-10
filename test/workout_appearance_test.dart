import 'package:digigym/models/session.dart';
import 'package:digigym/models/workout_plan.dart';
import 'package:digigym/screens/grocery_screen.dart';
import 'package:digigym/screens/meal_page.dart';
import 'package:digigym/screens/profile_screen.dart';
import 'package:digigym/theme/appearance_controller.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/recommended_workout_glass_card.dart';
import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/weekly_workout_schedule.dart';
import 'package:digigym/widgets/workout_exercise_list.dart';
import 'package:digigym/widgets/workout_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'appearance_app_test.dart' as app;
import 'support/memory_schedule_storage.dart';
import 'workout_theme_visual_test.dart' as visuals;
import 'workouts_screen_test.dart' as actions;

ThemeData themeAt(WidgetTester tester, Finder finder) =>
    Theme.of(tester.element(finder.first));

void expectLightSurface(WidgetTester tester, Finder finder) {
  final theme = themeAt(tester, finder);
  expect(theme.brightness, Brightness.light);
  final surfaces = theme.extension<DigiGymSurfaces>()!;
  expect(surfaces.background, DigiGymSurfaces.light.background);
  expect(surfaces.atmosphere, DigiGymSurfaces.light.atmosphere);
  expect(surfaces.accent, DigiGymSurfaces.light.accent);
  expect(theme.colorScheme.onSurface, const Color(0xFF121418));
}

Future<void> expandFirst(WidgetTester tester) async {
  final tile = find.byKey(const PageStorageKey<String>('exercise-0'));
  if (tile.evaluate().isEmpty) {
    tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();
    for (var attempt = 0; attempt < 60 && tile.evaluate().isEmpty; attempt++) {
      final viewport = tester.getRect(find.byType(Scrollable).first);
      final navigation = find.byType(FloatingBottomNavigationBar);
      final bottom = navigation.evaluate().isEmpty
          ? viewport.bottom
          : tester.getRect(navigation).top;
      final visible = viewport.intersect(
        Rect.fromLTRB(viewport.left, viewport.top, viewport.right, bottom),
      );
      // At 3x on short phones the viewport's center is behind the floating
      // navigation. Start the user's drag in its exposed portion instead.
      await tester.dragFrom(visible.center, Offset(0, -visible.height * .6));
      await tester.pumpAndSettle();
    }
  }
  final header = find.descendant(of: tile, matching: find.byType(ListTile));
  await tester.ensureVisible(header);
  await tester.pumpAndSettle();
  final viewport = tester.getRect(find.byType(Scrollable).first);
  final navigation = find.byType(FloatingBottomNavigationBar);
  final bottom = navigation.evaluate().isEmpty
      ? viewport.bottom
      : tester.getRect(navigation).top;
  final visibleHeader = tester
      .getRect(header)
      .intersect(
        Rect.fromLTRB(viewport.left, viewport.top, viewport.right, bottom),
      );
  expect(visibleHeader.height, greaterThan(0));
  await tester.tapAt(visibleHeader.center);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(visuals.loadWorkoutVisualFonts);
  tearDown(() {
    DigiGymSession.currentUser = null;
    DigiGymSession.clearPendingRegistration();
  });

  testWidgets(
    'Workout reuses the exact Home background, glass, green and navigation',
    (tester) async {
      await visuals.pumpWorkoutTheme(tester, light: true);
      final featured = find.byKey(const ValueKey('workout-featured'));
      expectLightSurface(tester, featured);
      final surfaces = DigiGymSurfaces.of(tester.element(featured));
      expect(identical(surfaces, DigiGymSurfaces.light), isTrue);
      for (final decoration in [surfaces.background, surfaces.atmosphere]) {
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox && widget.decoration == decoration,
          ),
          findsOneWidget,
        );
      }
      expect(surfaces.glass, DigiGymSurfaces.light.glass);
      expect(surfaces.glassEdge, DigiGymSurfaces.light.glassEdge);
      final button = find.byKey(const ValueKey('workout-featured-exercises'));
      final material = tester.widget<Material>(
        find.descendant(of: button, matching: find.byType(Material)),
      );
      expect(material.color, surfaces.accent);
      expect(
        DefaultTextStyle.of(tester.element(find.text('View Plan'))).style.color,
        surfaces.onAccent,
      );
      final dots = tester.widget<DotMatrixText>(find.byType(DotMatrixText));
      expect(dots.height, 43.2);
      expect(dots.fillRatio, .74);
      final week = tester.widget<WeeklyWorkoutSchedule>(
        find.byType(WeeklyWorkoutSchedule),
      );
      expect(week.currentDayColor, surfaces.accent);
      expect(week.scheduledColor, surfaces.accent);
      expect(week.seeAllColor, surfaces.accent);
      final selected = find.descendant(
        of: find.byKey(const ValueKey('navigation-icon-1')),
        matching: find.byKey(const ValueKey('navigation-icon-foreground')),
      );
      expect(
        tester
            .widget<Image>(
              find.descendant(of: selected, matching: find.byType(Image)),
            )
            .color,
        surfaces.navigationActive,
      );
      expect(surfaces.navigationSurface, const Color(0x4DF8F9FB));
      expect(surfaces.navigationBackdropSigma, 16);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('all three light tabs preserve content and exercise expansion', (
    tester,
  ) async {
    await visuals.pumpWorkoutTheme(tester, light: true);
    final plan = WorkoutPlan.forUser(actions.profile());
    for (final view in ['myPlan', 'exercises', 'moreWorkouts']) {
      await actions.activate(tester, 'workout-view-$view');
      final card = find.byType(DashboardGlassCard).first;
      expectLightSurface(tester, card);
      expect(
        DigiGymSurfaces.of(tester.element(card)).glass,
        view == 'myPlan'
            ? RecommendedWorkoutGlassCard.fill
            : DigiGymSurfaces.light.glass,
      );
      if (view != 'moreWorkouts') {
        await expandFirst(tester);
        expect(find.text(plan.exercises.first.description), findsOneWidget);
        expect(
          themeAt(
            tester,
            find.byType(ExpansionTile),
          ).expansionTileTheme.textColor,
          DigiGymSurfaces.light.accent,
        );
        await expandFirst(tester);
        expect(find.text(plan.exercises.first.description), findsNothing);
      } else {
        expect(
          find.text(
            WorkoutPlan.alternativesForUser(actions.profile()).first.title,
          ),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'light exercise routes and walkthrough follow the saved appearance',
    (tester) async {
      final schedule = await visuals.pumpWorkoutTheme(tester, light: true);
      final originalDays = {...schedule.workoutDays!};
      await actions.activate(tester, 'workout-featured-exercises');
      expectLightSurface(tester, find.byType(WorkoutExerciseList));
      await expandFirst(tester);
      expect(find.text('How to perform'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await actions.activate(tester, 'workout-start');
      expectLightSurface(
        tester,
        find.byKey(const ValueKey('workout-walkthrough-step')),
      );
      await actions.activate(tester, 'workout-step-next');
      expect(
        find.text(
          'Exercise 2 of ${WorkoutPlan.forUser(actions.profile()).exercises.length}',
        ),
        findsOneWidget,
      );
      expect(schedule.workoutDays, originalDays);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Workout schedule dialogs reuse Home frosting and preserve schedule actions',
    (tester) async {
      final schedule = await visuals.pumpWorkoutTheme(tester, light: true);
      await actions.activate(tester, 'workout-edit-schedule');
      final dialog = find.byType(Dialog);
      expectLightSurface(tester, dialog);
      final frost = find.descendant(
        of: dialog,
        matching: find.byType(BackdropFilter),
      );
      expect(frost, findsOneWidget);
      final checkbox = tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('schedule-edit-day-1')),
      );
      expect(checkbox.activeColor, DigiGymSurfaces.light.accent);
      expect(checkbox.checkColor, DigiGymSurfaces.light.onAccent);
      await tester.tap(find.byKey(const ValueKey('schedule-edit-day-1')));
      await tester.tap(find.byKey(const ValueKey('schedule-save')));
      await tester.pumpAndSettle();
      expect(schedule.workoutDays, contains(1));
      final day = find.byKey(const ValueKey('week-day-2026-10-25'));
      await tester.ensureVisible(day);
      await tester.pumpAndSettle();
      await tester.tap(day);
      await tester.pumpAndSettle();
      expectLightSurface(tester, find.byType(Dialog));
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(BackdropFilter),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('schedule-view-workout')));
      await tester.pumpAndSettle();
      expectLightSurface(tester, find.byType(WorkoutExerciseList));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'only Home and Workout opt into light; remaining tabs stay dark',
    (tester) async {
      await visuals.pumpWorkoutTheme(tester, light: true);
      for (final entry in {
        'Meals': MealPage,
        'Groceries': GroceryScreen,
        'Profile': ProfilePage,
      }.entries) {
        await actions.tab(tester, entry.key);
        expect(
          themeAt(tester, find.byType(entry.value)).brightness,
          Brightness.dark,
        );
      }
      await actions.tab(tester, 'Workout');
      expectLightSurface(
        tester,
        find.byKey(const ValueKey('workout-featured')),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Workout switching, persistence and Follow System retain the selected view',
    (tester) async {
      final storage = MemoryScheduleStorage();
      final appearance = AppearanceController(storage: storage);
      addTearDown(appearance.dispose);
      await app.start(tester, appearance);
      await appearance.select(ThemeMode.light);
      await tester.pumpAndSettle();
      await app.tapTab(tester, 'Workout');
      await actions.activate(tester, 'workout-view-exercises');
      expectLightSurface(tester, find.byType(WorkoutExerciseList));
      await appearance.select(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(
        themeAt(tester, find.byType(WorkoutExerciseList)).brightness,
        Brightness.dark,
      );
      expect(find.byKey(const ValueKey('workout-featured')), findsNothing);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await appearance.select(ThemeMode.system);
      await tester.pumpAndSettle();
      expectLightSurface(tester, find.byType(WorkoutExerciseList));
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(
        themeAt(tester, find.byType(WorkoutExerciseList)).brightness,
        Brightness.dark,
      );
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      await appearance.flush();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      final restored = AppearanceController(storage: storage);
      addTearDown(restored.dispose);
      await app.start(tester, restored);
      await app.tapTab(tester, 'Workout');
      expect(restored.mode, ThemeMode.system);
      expectLightSurface(tester, find.byType(WorkoutOverview));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('insufficient-time states stay light in every Workout tab', (
    tester,
  ) async {
    await visuals.pumpWorkoutTheme(
      tester,
      light: true,
      user: actions.profile(minutes: 0),
    );
    for (final view in ['myPlan', 'exercises', 'moreWorkouts']) {
      await actions.activate(tester, 'workout-view-$view');
      expectLightSurface(
        tester,
        find.byKey(const ValueKey('workout-time-empty')),
      );
      expect(find.byKey(const ValueKey('workout-start')), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'light Android and iOS views, dialogs and routes fit phones through 3x text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        for (final size in [
          const Size(320, 640),
          const Size(390, 844),
          const Size(426, 952),
        ]) {
          tester.view.physicalSize = size;
          for (final scale in [1.0, 2.0, 3.0]) {
            await visuals.pumpWorkoutTheme(
              tester,
              light: true,
              platform: platform,
              scale: scale,
            );
            actions.expectTitleFits(tester, 'Workout');
            for (final view in ['myPlan', 'exercises', 'moreWorkouts']) {
              await actions.activate(tester, 'workout-view-$view');
              if (view == 'exercises') await expandFirst(tester);
              expect(
                tester.takeException(),
                isNull,
                reason: '$platform $size $scale $view',
              );
              final scroll = tester
                  .state<ScrollableState>(find.byType(Scrollable).first)
                  .position;
              scroll.jumpTo(scroll.maxScrollExtent);
              await tester.pumpAndSettle();
              final last = view == 'myPlan'
                  ? find.byKey(const ValueKey('workout-timing-notice'))
                  : view == 'exercises'
                  ? find.byType(WorkoutExerciseList)
                  : find.byKey(
                      ValueKey(
                        'workout-library-plan-${WorkoutPlan.alternativesForUser(actions.profile()).length - 1}',
                      ),
                    );
              expect(
                tester.getRect(last).bottom,
                lessThanOrEqualTo(
                  tester.getRect(find.byType(FloatingBottomNavigationBar)).top +
                      .01,
                ),
              );
            }
            await actions.activate(tester, 'workout-view-myPlan');
            await actions.activate(tester, 'workout-edit-schedule');
            await tester.ensureVisible(
              find.byKey(const ValueKey('schedule-edit-day-6')),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.tap(find.byKey(const ValueKey('schedule-cancel')));
            await tester.pumpAndSettle();
            await actions.activate(tester, 'workout-preview-all');
            actions.expectTitleFits(tester, 'Exercises');
            await expandFirst(tester);
            expectLightSurface(tester, find.byType(WorkoutExerciseList));
            expect(tester.takeException(), isNull);
          }
        }
      }
    },
  );
}
