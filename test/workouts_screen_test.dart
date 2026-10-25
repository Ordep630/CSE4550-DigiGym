import 'dart:ui' as ui;

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/models/workout_plan.dart';
import 'package:digigym/models/workout_schedule_day.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/workout_exercises_screen.dart';
import 'package:digigym/widgets/dashboard_number.dart';
import 'package:digigym/widgets/daily_streak_indicator.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/segmented_progress_ring.dart';
import 'package:digigym/widgets/weekly_workout_schedule.dart';
import 'package:digigym/widgets/workout_week_view.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

UserProfile profile({
  String level = 'Intermediate',
  String goal = 'Build Muscle',
  int minutes = 30,
}) => UserProfile(
  name: 'Isaac',
  email: 'test@example.com',
  fitnessLevel: level,
  fitnessGoal: goal,
  workoutTime: minutes,
);

Widget host({UserProfile? user, double scale = 1, FakeDigiGymApi? api}) =>
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: const EdgeInsets.only(top: 52, bottom: 24),
          textScaler: TextScaler.linear(scale),
        ),
        child: child!,
      ),
      home: HomeScreen(
        user: user ?? profile(),
        api: api ?? FakeDigiGymApi(),
        onLogout: () async {},
        onUpdateProfile: (_) {},
      ),
    );

Future<void> tab(WidgetTester tester, String name) async {
  await tester.tap(
    find.descendant(
      of: find.byType(FloatingBottomNavigationBar),
      matching: find.text(name),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> activate(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  if (target.evaluate().isEmpty) {
    tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      target,
      100,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  // At 3x a quick-action card can exceed the exposed area above the pill.
  // Tap its visible portion, as a user would, rather than its obscured center.
  final viewport = tester.getRect(find.byType(Scrollable).first);
  final navigation = find.byType(FloatingBottomNavigationBar);
  final bottom = navigation.evaluate().isEmpty
      ? viewport.bottom
      : tester.getRect(navigation).top;
  final visible = tester
      .getRect(target)
      .intersect(
        Rect.fromLTRB(viewport.left, viewport.top, viewport.right, bottom),
      );
  expect(visible.height, greaterThan(0), reason: '$key remains reachable');
  await tester.tapAt(visible.center);
  await tester.pumpAndSettle();
}

Future<void> start(
  WidgetTester tester, {
  UserProfile? user,
  double scale = 1,
  FakeDigiGymApi? api,
}) async {
  await tester.pumpWidget(host(user: user, scale: scale, api: api));
  await tester.pumpAndSettle();
  await tab(tester, 'Workout');
}

void expectTitleFits(WidgetTester tester, String title) {
  final bar = tester.getRect(find.byType(AppBar));
  final text = tester.getRect(
    find.descendant(of: find.byType(AppBar), matching: find.text(title)),
  );
  expect(text.top, greaterThanOrEqualTo(bar.top));
  expect(text.bottom, lessThanOrEqualTo(bar.bottom));
  expect(text.left, greaterThanOrEqualTo(bar.left));
  expect(text.right, lessThanOrEqualTo(bar.right));
}

void main() {
  setUpAll(() async {
    for (final font in {
      'DigiGymInter': 'Inter',
      'DigiGymDoto': 'Doto',
    }.entries) {
      await (FontLoader(font.key)..addFont(
            rootBundle.load('assets/fonts/${font.value}-Variable.ttf'),
          ))
          .load();
    }
  });
  testWidgets(
    'Today is default and reflects saved level goal duration without progress',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await start(
        tester,
        user: profile(level: 'Advanced', goal: 'Maintain Weight', minutes: 125),
      );
      expect(find.text('Advanced Plan'), findsOneWidget);
      expect(find.text('Advanced Workout'), findsOneWidget);
      expect(find.text('Maintain Weight'), findsOneWidget);
      final number = tester.widget<DashboardNumber>(
        find.byKey(const ValueKey('workout-duration')),
      );
      expect(number.value, '125 MIN');
      expect(number.dotted, isTrue);
      final selected = tester
          .getSemantics(find.bySemanticsLabel('Today workout view'))
          .getSemanticsData();
      expect(selected.flagsCollection.isSelected, ui.Tristate.isTrue);
      expect(selected.hasAction(ui.SemanticsAction.tap), isTrue);
      for (final name in ['today', 'thisWeek', 'allWorkouts']) {
        expect(
          tester.getSize(find.byKey(ValueKey('workout-view-$name'))).height,
          greaterThanOrEqualTo(48),
        );
      }
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(SegmentedProgressRing), findsNothing);
      expect(find.textContaining('%'), findsNothing);
      semantics.dispose();
    },
  );

  testWidgets(
    'segments retain the selected view across tab switches and profile rebuilds',
    (tester) async {
      await start(tester);
      final navigation = tester.getRect(
        find.byType(FloatingBottomNavigationBar),
      );
      await activate(tester, 'workout-view-thisWeek');
      expect(find.byKey(const ValueKey('workout-week-empty')), findsOneWidget);
      await tab(tester, 'Home');
      await tab(tester, 'Workout');
      expect(find.byKey(const ValueKey('workout-week-empty')), findsOneWidget);
      await activate(tester, 'workout-view-allWorkouts');
      expect(
        find.byKey(const ValueKey('workout-library-plan')),
        findsOneWidget,
      );
      expect(find.text('Intermediate Workout'), findsOneWidget);
      expect(find.text('30 min • 6 exercises'), findsOneWidget);
      await tester.pumpWidget(
        host(user: profile(level: 'Advanced', minutes: 45)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Advanced Workout'), findsOneWidget);
      expect(find.text('45 min • 6 exercises'), findsOneWidget);
      expect(
        tester.getRect(find.byType(FloatingBottomNavigationBar)),
        navigation,
      );
      await activate(tester, 'workout-view-today');
      expect(find.byKey(const ValueKey('workout-featured')), findsOneWidget);
    },
  );

  testWidgets(
    'View Exercises and library preserve ordered expandable details and back navigation',
    (tester) async {
      await start(tester);
      final plan = WorkoutPlan.forUser(profile());
      for (final entry in [
        'workout-view-exercises',
        'workout-featured-exercises',
        'workout-library-exercises',
      ]) {
        if (entry == 'workout-library-exercises') {
          await activate(tester, 'workout-view-allWorkouts');
        }
        await activate(tester, entry);
        expect(find.byType(WorkoutExercisesScreen), findsOneWidget);
        expect(find.byType(FloatingBottomNavigationBar), findsNothing);
        for (var i = 0; i < plan.exercises.length; i++) {
          final tile = find.byKey(PageStorageKey('exercise-$i'));
          await tester.scrollUntilVisible(tile, 100);
          final widget = tester.widget<ExpansionTile>(tile);
          expect((widget.title as Text).data, plan.exercises[i].name);
          expect((widget.subtitle as Text).data, plan.exercises[i].sets);
        }
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .jumpTo(0);
        await tester.pumpAndSettle();
        expect(find.text(plan.exercises.first.description), findsNothing);
        await tester.tap(find.text(plan.exercises.first.name));
        await tester.pumpAndSettle();
        expect(find.text(plan.exercises.first.description), findsOneWidget);
        await tester.tap(find.text(plan.exercises.first.name));
        await tester.pumpAndSettle();
        expect(find.text(plan.exercises.first.description), findsNothing);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(FloatingBottomNavigationBar), findsOneWidget);
      }
    },
  );

  testWidgets(
    'Start Workout is a read-only ordered walkthrough and never marks completion',
    (tester) async {
      final api = FakeDigiGymApi();
      await start(tester, api: api);
      await activate(tester, 'workout-start');
      expect(
        find.textContaining('No workout session or completions are recorded.'),
        findsOneWidget,
      );
      final plan = WorkoutPlan.forUser(profile());
      for (var i = 0; i < plan.exercises.length; i++) {
        expect(find.text(plan.exercises[i].name), findsOneWidget);
        expect(find.text(plan.exercises[i].description), findsOneWidget);
        expect(
          find.text('Exercise ${i + 1} of ${plan.exercises.length}'),
          findsOneWidget,
        );
        if (i == 1) {
          await activate(tester, 'workout-step-previous');
          expect(find.text(plan.exercises.first.name), findsOneWidget);
          await activate(tester, 'workout-step-next');
        }
        await activate(tester, 'workout-step-next');
      }
      expect(find.byType(WorkoutExercisesScreen), findsNothing);
      expect(api.updateRequest, isNull);
      expect(api.signOutCalls, 0);
      await tab(tester, 'Home');
      expect(
        tester
            .widget<SegmentedProgressRing>(find.byType(SegmentedProgressRing))
            .progress,
        0,
      );
      expect(
        tester
            .widget<DailyStreakIndicator>(find.byType(DailyStreakIndicator))
            .days,
        isNull,
      );
    },
  );

  testWidgets(
    'This Week shows only unassigned days and an honest empty state',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await start(tester);
      await activate(tester, 'workout-view-thisWeek');
      expect(
        find.textContaining('A weekly schedule has not been configured.'),
        findsOneWidget,
      );
      final week = tester.widget<WeeklyWorkoutSchedule>(
        find.byType(WeeklyWorkoutSchedule),
      );
      expect(week.days, isEmpty);
      expect(find.bySemanticsLabel(RegExp('Unassigned Day')), findsNWidgets(7));
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(
        find.bySemanticsLabel(RegExp('Completed Workout|Rest Day')),
        findsNothing,
      );
      await tester.tap(find.text('See All'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('workout-library-plan')),
        findsOneWidget,
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'week interface renders only supplied schedule states for future integration',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: DigiGymDashboardTheme.content(
            DigiGymDashboardTheme.dark(ThemeData()),
          ),
          home: Scaffold(
            body: WorkoutWeekView(
              clock: () => DateTime(2026, 10, 25),
              onBrowseWorkouts: () {},
              days: [
                WorkoutScheduleDay(
                  date: DateTime(2026, 10, 25),
                  workoutType: ScheduledWorkoutType.fullBody,
                ),
                WorkoutScheduleDay(
                  date: DateTime(2026, 10, 26),
                  isRestDay: true,
                ),
                WorkoutScheduleDay(
                  date: DateTime(2026, 10, 27),
                  isCompleted: true,
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('workout-week-empty')), findsNothing);
      expect(find.bySemanticsLabel(RegExp('Unassigned Day')), findsNWidgets(5));
      expect(find.bySemanticsLabel(RegExp('Rest Day')), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets(
    'all views and exercise instructions fit narrow screens through 3x text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final width in [280.0, 320.0, 1280 / 3]) {
        tester.view.physicalSize = Size(width, 844);
        for (final scale in [1.0, 2.0, 3.0]) {
          await start(tester, scale: scale, user: profile(minutes: 125));
          expectTitleFits(tester, 'Workout');
          for (final view in ['today', 'thisWeek', 'allWorkouts']) {
            await activate(tester, 'workout-view-$view');
            expect(
              tester.takeException(),
              isNull,
              reason: '$view $width / $scale',
            );
            final scroll = tester.state<ScrollableState>(
              find.byType(Scrollable).first,
            );
            scroll.position.jumpTo(scroll.position.maxScrollExtent);
            await tester.pumpAndSettle();
            final last = view == 'today'
                ? find.textContaining('Moderate intensity')
                : find.byKey(
                    ValueKey(
                      view == 'thisWeek'
                          ? 'workout-week-empty'
                          : 'workout-library-plan',
                    ),
                  );
            expect(
              tester.getRect(last).bottom,
              lessThanOrEqualTo(
                tester.getRect(find.byType(FloatingBottomNavigationBar)).top,
              ),
              reason: '$view bottom clears navigation $width / $scale',
            );
          }
          await activate(tester, 'workout-library-exercises');
          expectTitleFits(tester, 'Exercises');
          await tester.scrollUntilVisible(find.text('Push Ups'), 100);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Push Ups'));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('lower your chest under control.'),
            findsOneWidget,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'exercises $width / $scale',
          );
          await tester.pageBack();
          await tester.pumpAndSettle();
          await activate(tester, 'workout-view-today');
          await activate(tester, 'workout-start');
          expectTitleFits(tester, 'Workout walkthrough');
          await activate(tester, 'workout-step-next');
          expect(
            tester.takeException(),
            isNull,
            reason: 'walkthrough $width / $scale',
          );
          await tester.pageBack();
          await tester.pumpAndSettle();
          await tab(tester, 'Home');
        }
      }
    },
  );
}
