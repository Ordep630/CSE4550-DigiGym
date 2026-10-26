import 'dart:ui' as ui;

import 'package:digigym/main.dart';
import 'package:digigym/models/session.dart';

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/models/workout_plan.dart';
import 'package:digigym/services/workout_schedule_controller.dart';
import 'package:digigym/services/workout_scheduling.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/workouts_screen.dart';
import 'package:digigym/screens/workout_exercises_screen.dart';
import 'package:digigym/widgets/dashboard_number.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/workout_overview.dart';
import 'package:digigym/widgets/weekly_workout_schedule.dart';
import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/daily_streak_indicator.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/segmented_progress_ring.dart';
import 'package:digigym/widgets/workout_exercise_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';
import 'support/memory_schedule_storage.dart';

WorkoutScheduleController testSchedule(UserProfile user) {
  final controller = WorkoutScheduleController(
    accountId: user.accountId,
    storage: MemoryScheduleStorage(),
  );
  addTearDown(controller.dispose);
  return controller;
}

UserProfile profile({
  String level = 'Intermediate',
  String goal = 'Build Muscle',
  int minutes = 30,
}) => UserProfile(
  accountId: '123e4567-e89b-12d3-a456-426614174000',
  name: 'Isaac',
  email: 'test@example.com',
  fitnessLevel: level,
  fitnessGoal: goal,
  workoutTime: minutes,
);

Widget host({
  UserProfile? user,
  double scale = 1,
  FakeDigiGymApi? api,
  WorkoutScheduleController? schedule,
}) => MaterialApp(
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
    workoutSchedule: schedule ?? testSchedule(user ?? profile()),
    clock: () => DateTime(2026, 10, 25, 9),
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
  WorkoutScheduleController? schedule,
}) async {
  await tester.pumpWidget(
    host(user: user, scale: scale, api: api, schedule: schedule),
  );
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
  Future<WorkoutScheduleController> schedule({Set<int>? days}) async {
    final controller = WorkoutScheduleController(
      accountId: profile().accountId,
      storage: MemoryScheduleStorage(),
    );
    await controller.initialize();
    if (days != null) await controller.save(days);
    addTearDown(controller.dispose);
    return controller;
  }

  testWidgets(
    'My Plan is default with real recommendation and a single dynamic level subtitle',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final user = profile(
        level: 'Advanced',
        goal: 'Maintain Weight',
        minutes: 125,
      );
      await start(tester, user: user);
      expect(find.text('Advanced Plan'), findsOneWidget);
      expect(find.text('Advanced'), findsNothing);
      expect(find.text('Your Goals'), findsNothing);
      expect(find.text('Full Body Strength'), findsOneWidget);
      final plan = WorkoutPlan.forUser(user);
      expect(
        find.text('${plan.exercises.length} exercises · ${plan.fitnessGoal}'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<WorkoutDurationDisplay>(
              find.byKey(const ValueKey('workout-duration')),
            )
            .minutes,
        plan.durationMinutes,
      );
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('My Plan workout view'))
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        ui.Tristate.isTrue,
      );
      for (final view in ['myPlan', 'exercises', 'moreWorkouts']) {
        expect(
          tester.getSize(find.byKey(ValueKey('workout-view-$view'))).height,
          greaterThanOrEqualTo(48),
        );
      }
      expect(find.byType(SegmentedProgressRing), findsNothing);
      semantics.dispose();
    },
  );

  testWidgets(
    'duration reuses corrected glyphs and retains the featured number line box',
    (tester) async {
      Widget scene(bool updated, {double scale = 1, int minutes = 30}) =>
          MaterialApp(
            theme: DigiGymDashboardTheme.content(
              DigiGymDashboardTheme.dark(ThemeData()),
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 240,
                  child: DashboardGlassCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (updated)
                          WorkoutDurationDisplay(minutes: minutes)
                        else
                          DashboardNumber(
                            value: '$minutes MIN',
                            fontSize: 48,
                            unitFontSize: 22,
                            fitToWidth: true,
                          ),
                        const SizedBox(height: 12),
                        const Text('Plan title'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
      await tester.pumpWidget(scene(false));
      await tester.pumpAndSettle();
      final oldCard = tester.getRect(find.byType(DashboardGlassCard));
      final oldTitle = tester.getRect(find.text('Plan title'));
      await tester.pumpWidget(scene(true));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(DashboardGlassCard)), oldCard);
      expect(tester.getRect(find.text('Plan title')), oldTitle);
      for (final scale in [1.0, 2.0, 3.0]) {
        for (final minutes in [5, 30, 125]) {
          await tester.pumpWidget(scene(true, scale: scale, minutes: minutes));
          await tester.pumpAndSettle();
          final matrix = tester.widget<DotMatrixText>(
            find.byType(DotMatrixText),
          );
          expect(matrix.text, '$minutes');
          expect(matrix.softenedDigits, isTrue);
          expect(matrix.height / scale, closeTo(43.2, .0001));
          expect(matrix.fillRatio, .74);
          expect(
            matrix.height / scale / (48 * .7),
            inInclusiveRange(1.25, 1.30),
          );
          final unit = tester.widget<Text>(find.text('MIN'));
          expect(unit.style!.fontFamily, DigiGymDashboardTheme.textFont);
          expect(unit.style!.fontSize, 22);
          final bounds = tester.getRect(find.byType(WorkoutDurationDisplay));
          final digits = tester.getRect(find.byType(DotMatrixText));
          final unitBounds = tester.getRect(find.text('MIN'));
          expect(digits.left, greaterThanOrEqualTo(bounds.left));
          expect(digits.right, lessThan(unitBounds.left));
          expect(unitBounds.right, lessThanOrEqualTo(bounds.right + .01));
          expect(unitBounds.bottom, closeTo(digits.bottom, .01));
          expect(digits.top, greaterThanOrEqualTo(bounds.top - .01));
          expect(digits.bottom, lessThanOrEqualTo(bounds.bottom + .01));
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'insufficient time is honest in My Plan, Exercises and More Workouts',
    (tester) async {
      await start(tester, user: profile(minutes: 1));
      for (final view in ['myPlan', 'exercises', 'moreWorkouts']) {
        await activate(tester, 'workout-view-$view');
        expect(
          find.byKey(const ValueKey('workout-time-empty')),
          findsOneWidget,
        );
        expect(find.byType(WorkoutExerciseList), findsNothing);
        expect(find.byKey(const ValueKey('workout-start')), findsNothing);
      }
    },
  );

  testWidgets(
    'three views retain selection and use updated profile recommendations',
    (tester) async {
      final controller = await schedule();
      await start(tester, schedule: controller);
      final nav = tester.getRect(find.byType(FloatingBottomNavigationBar));
      await activate(tester, 'workout-view-moreWorkouts');
      final alternatives = WorkoutPlan.alternativesForUser(profile());
      for (final alternative in alternatives) {
        expect(find.text(alternative.title), findsOneWidget);
      }
      await tab(tester, 'Home');
      await tab(tester, 'Workout');
      expect(find.text('More workouts for you'), findsOneWidget);
      await tester.pumpWidget(
        host(
          user: profile(level: 'Beginner', goal: 'Lose Weight', minutes: 15),
          schedule: controller,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Beginner Plan'), findsOneWidget);
      expect(tester.getRect(find.byType(FloatingBottomNavigationBar)), nav);
      await activate(tester, 'workout-view-myPlan');
      expect(find.text('Cardio & Strength'), findsOneWidget);
    },
  );

  testWidgets(
    'Exercises tab preserves prescriptions and expands real timed instructions',
    (tester) async {
      final user = profile(goal: 'Lose Weight');
      await start(tester, user: user);
      await activate(tester, 'workout-view-exercises');
      final plan = WorkoutPlan.forUser(user);
      expect(find.byType(ExpansionTile), findsNWidgets(plan.exercises.length));
      final first = plan.exercises.first;
      expect(first.secondsPerSet, isNotNull);
      expect(find.text(first.sets), findsOneWidget);
      expect(find.text(first.description), findsNothing);
      await tester.tap(find.text(first.name));
      await tester.pumpAndSettle();
      expect(find.text(first.description), findsOneWidget);
      expect(find.text('How to perform'), findsOneWidget);
      expect(find.byType(WorkoutExercisesScreen), findsNothing);
      await tester.tap(find.text(first.name));
      await tester.pumpAndSettle();
      expect(find.text(first.description), findsNothing);
    },
  );

  testWidgets(
    'View Plan preview and browse-only alternatives open correct exercise details',
    (tester) async {
      await start(tester);
      for (final action in [
        'workout-featured-exercises',
        'workout-preview-all',
        'workout-library-exercises-0',
      ]) {
        if (action == 'workout-library-exercises-0') {
          await activate(tester, 'workout-view-moreWorkouts');
        }
        await activate(tester, action);
        final screen = tester.widget<WorkoutExercisesScreen>(
          find.byType(WorkoutExercisesScreen),
        );
        final expected = action == 'workout-library-exercises-0'
            ? WorkoutPlan.alternativesForUser(profile()).first
            : WorkoutPlan.forUser(profile());
        expect(screen.plan.title, expected.title);
        for (var i = 0; i < expected.exercises.length; i++) {
          final tile = find.byKey(PageStorageKey('exercise-$i'));
          await tester.ensureVisible(tile);
          await tester.pumpAndSettle();
          expect(
            (tester.widget<ExpansionTile>(tile).subtitle as Text).data,
            expected.exercises[i].sets,
          );
        }
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      await activate(tester, 'workout-view-myPlan');
      expect(find.text('Full Body Strength'), findsOneWidget);
    },
  );

  testWidgets(
    'guided walkthrough remains read-only and leaves progress and streak empty',
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
        await activate(tester, 'workout-step-next');
      }
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
    'schedule editor saves cancels toggles all seven days and permits all rest',
    (tester) async {
      final controller = await schedule();
      await start(tester, schedule: controller);
      expect(find.byKey(const ValueKey('workout-week-empty')), findsOneWidget);
      await activate(tester, 'workout-edit-schedule');
      expect(find.byType(CheckboxListTile), findsNWidgets(7));
      await tester.ensureVisible(
        find.byKey(const ValueKey('schedule-edit-day-0')),
      );
      await tester.tap(find.byKey(const ValueKey('schedule-edit-day-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('schedule-cancel')));
      await tester.pumpAndSettle();
      expect(controller.configured, isFalse);
      await activate(tester, 'workout-edit-schedule');
      await tester.ensureVisible(
        find.byKey(const ValueKey('schedule-edit-day-2')),
      );
      await tester.tap(find.byKey(const ValueKey('schedule-edit-day-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('schedule-save')));
      await tester.pumpAndSettle();
      expect(controller.workoutDays, {2});
      await activate(tester, 'workout-edit-schedule');
      await tester.ensureVisible(
        find.byKey(const ValueKey('schedule-edit-day-2')),
      );
      await tester.tap(find.byKey(const ValueKey('schedule-edit-day-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('schedule-save')));
      await tester.pumpAndSettle();
      expect(controller.configured, isTrue);
      expect(controller.workoutDays, isEmpty);
      expect(
        find.text('Tap a day to view its workout or rest day.'),
        findsOneWidget,
      );
      expect(find.textContaining('not synced through Serverpod'), findsNothing);
      await activate(tester, 'workout-edit-schedule');
      final disclosure = tester.widget<Text>(
        find.byKey(const ValueKey('schedule-local-storage-disclosure')),
      );
      expect(disclosure.data, contains('separately for your account'));
      expect(disclosure.data, contains('Not synced through Serverpod'));
      expect(disclosure.style!.color, DigiGymDarkColors.secondaryText);
      await tester.tap(find.byKey(const ValueKey('schedule-cancel')));
      await tester.pumpAndSettle();
    },
  );

  for (final rest in [false, true]) {
    testWidgets(
      'Home and Workout share current-day letter styling on ${rest ? 'rest' : 'workout'} days',
      (tester) async {
        final chosenDays = rest ? <int>{} : <int>{0, 2, 4};
        final controller = await schedule(days: chosenDays);
        await start(tester, schedule: controller);
        final now = DateTime(2026, 10, 25);
        final dates = WeeklyWorkoutSchedule.weekDates(now);
        List<TextStyle> labels() => dates
            .map(
              (date) => tester
                  .widget<Text>(
                    find.byKey(
                      ValueKey(
                        'week-label-${date.toIso8601String().split('T').first}',
                      ),
                    ),
                  )
                  .style!,
            )
            .toList();
        List<BoxDecoration> circles() => dates
            .map(
              (date) =>
                  tester
                          .widget<Container>(
                            find.byKey(
                              ValueKey(
                                'week-badge-${date.toIso8601String().split('T').first}',
                              ),
                            ),
                          )
                          .decoration!
                      as BoxDecoration,
            )
            .toList();
        final workoutStyles = labels();
        final workoutCircles = circles();
        for (var i = 0; i < dates.length; i++) {
          expect(
            workoutStyles[i].color,
            i == 0 ? const Color(0xFF67E780) : DigiGymDarkColors.secondaryText,
          );
          expect(
            workoutStyles[i].shadows,
            i == 0
                ? [
                    Shadow(
                      color: const Color(0xFF67E780).withValues(alpha: .30),
                      blurRadius: 6,
                    ),
                  ]
                : isNull,
          );
        }
        await tab(tester, 'Home');
        expect(labels(), workoutStyles);
        expect(circles(), workoutCircles);
        expect(controller.workoutDays, chosenDays);
        final assignment = WorkoutScheduling.week(
          user: profile(),
          workoutDays: controller.workoutDays,
          date: now,
        ).first;
        expect(assignment.presentation.isRestDay, rest);
        expect(assignment.isWorkout, !rest);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Home and Workout share configured assignments, day details and See All focus',
    (tester) async {
      final controller = await schedule(days: {0, 2, 4});
      final semantics = tester.ensureSemantics();
      await start(tester, schedule: controller);
      await tab(tester, 'Home');
      expect(find.bySemanticsLabel(RegExp('Rest Day')), findsNWidgets(4));
      await activate(tester, 'week-badge-2026-10-25');
      expect(find.byType(AlertDialog), findsOneWidget);
      final assigned = WorkoutScheduling.week(
        user: profile(),
        workoutDays: {0, 2, 4},
        date: DateTime(2026, 10, 25),
      ).first;
      expect(find.text(assigned.plan!.title), findsOneWidget);
      expect(
        find.text(
          'Estimated ${assigned.plan!.durationMinutes} min · ${assigned.plan!.exercises.length} exercises',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('schedule-view-workout')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<WorkoutExercisesScreen>(find.byType(WorkoutExercisesScreen))
            .plan
            .title,
        assigned.plan!.title,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await activate(tester, 'week-badge-2026-10-26');
      expect(find.text('Rest Day'), findsOneWidget);
      expect(find.textContaining('A scheduled rest day.'), findsOneWidget);
      expect(find.byKey(const ValueKey('schedule-view-workout')), findsNothing);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
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
      expect(find.byKey(const ValueKey('activity-state-25')), findsNothing);
      await activate(tester, 'dashboard-week-see-all');
      expect(find.text('Weekly Schedule'), findsOneWidget);
      expect(
        tester.getRect(find.text('Weekly Schedule')).top,
        greaterThanOrEqualTo(tester.getRect(find.byType(AppBar)).bottom),
      );
      expect(
        tester.getRect(find.text('Weekly Schedule')).bottom,
        lessThan(tester.getRect(find.byType(FloatingBottomNavigationBar)).top),
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'profile changes retain chosen weekdays and update Home and Workout plans',
    (tester) async {
      final controller = await schedule(days: {1, 3});
      await start(tester, schedule: controller);
      final updated = profile(
        level: 'Beginner',
        goal: 'Lose Weight',
        minutes: 15,
      );
      await tester.pumpWidget(host(user: updated, schedule: controller));
      await tester.pumpAndSettle();
      expect(controller.workoutDays, {1, 3});
      expect(find.text('Beginner Plan'), findsOneWidget);
      await tab(tester, 'Home');
      await activate(tester, 'week-badge-2026-10-26');
      expect(find.text('Cardio & Strength'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('schedule-view-workout')));
      await tester.pumpAndSettle();
      final plan = tester
          .widget<WorkoutExercisesScreen>(find.byType(WorkoutExercisesScreen))
          .plan;
      expect(plan.fitnessLevel, 'Beginner');
      expect(plan.fitnessGoal, 'Lose Weight');
      expect(plan.durationMinutes, lessThanOrEqualTo(15));
    },
  );

  testWidgets(
    'real shell lifecycle isolates account schedules across logout login and app restoration',
    (tester) async {
      const channel = MethodChannel(
        'plugins.it_nomads.com/flutter_secure_storage',
      );
      final disk = <String, String>{};
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        final args = call.arguments as Map;
        final key = args['key'] as String;
        if (call.method == 'read') return disk[key];
        if (call.method == 'write') {
          disk[key] = args['value'] as String;
          return null;
        }
        if (call.method == 'delete') {
          disk.remove(key);
          return null;
        }
        throw UnsupportedError(call.method);
      });
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        );
        DigiGymSession.currentUser = null;
      });
      final a = profile();
      final b = UserProfile(
        accountId: '123e4567-e89b-12d3-a456-426614174001',
        name: 'Other',
        email: 'other@example.com',
      );
      final api = FakeDigiGymApi()
        ..authenticated = true
        ..restoredProfile = a;
      await tester.pumpWidget(DigiGymApp(api: api));
      await tester.pumpAndSettle();
      await tab(tester, 'Workout');
      final first = tester
          .widget<WorkoutsScreen>(find.byType(WorkoutsScreen))
          .schedule!;
      expect(await first.save({2}), isTrue);
      await tester.pumpAndSettle();
      final stored = disk[first.storageKey];
      await tester.widget<HomeScreen>(find.byType(HomeScreen)).onLogout();
      await tester.pumpAndSettle();
      expect(first.workoutDays, isNull);
      expect(disk[first.storageKey], stored);
      Future<void> login(UserProfile user) async {
        api.restoredProfile = user;
        await tester.enterText(
          find.byKey(const ValueKey('login-email')),
          user.email,
        );
        await tester.enterText(
          find.byKey(const ValueKey('login-password')),
          'test-only-password',
        );
        final button = find.widgetWithText(ElevatedButton, 'Login');
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();
        await tab(tester, 'Workout');
      }

      await login(b);
      final other = tester
          .widget<WorkoutsScreen>(find.byType(WorkoutsScreen))
          .schedule!;
      expect(other.workoutDays, isNull);
      expect(await other.save({}), isTrue);
      await tester.pumpAndSettle();
      await tester.widget<HomeScreen>(find.byType(HomeScreen)).onLogout();
      await tester.pumpAndSettle();
      await login(a);
      expect(
        tester
            .widget<WorkoutsScreen>(find.byType(WorkoutsScreen))
            .schedule!
            .workoutDays,
        {2},
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(DigiGymApp(api: api));
      await tester.pumpAndSettle();
      await tab(tester, 'Workout');
      expect(
        tester
            .widget<WorkoutsScreen>(find.byType(WorkoutsScreen))
            .schedule!
            .workoutDays,
        {2},
      );
      expect(disk[first.storageKey], stored);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'all views editor and exercise details fit phones through 3x text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final controller = await schedule(days: {1, 3, 5});
      for (final width in [280.0, 320.0, 420.0, 1280 / 3]) {
        tester.view.physicalSize = Size(width, 912);
        for (final scale in [1.0, 3.0]) {
          await start(tester, scale: scale, schedule: controller);
          expectTitleFits(tester, 'Workout');
          for (final view in ['myPlan', 'exercises', 'moreWorkouts']) {
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
            final last = view == 'myPlan'
                ? find.byKey(const ValueKey('workout-timing-notice'))
                : view == 'exercises'
                ? find.byType(WorkoutExerciseList)
                : find.byKey(
                    ValueKey(
                      'workout-library-plan-${WorkoutPlan.alternativesForUser(profile()).length - 1}',
                    ),
                  );
            expect(
              tester.getRect(last).bottom,
              lessThanOrEqualTo(
                tester.getRect(find.byType(FloatingBottomNavigationBar)).top,
              ),
            );
          }
          await activate(tester, 'workout-view-myPlan');
          await activate(tester, 'workout-edit-schedule');
          await tester.ensureVisible(
            find.byKey(const ValueKey('schedule-edit-day-6')),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'editor $width / $scale',
          );
          await tester.tap(find.byKey(const ValueKey('schedule-cancel')));
          await tester.pumpAndSettle();
          await activate(tester, 'workout-preview-all');
          expectTitleFits(tester, 'Exercises');
          await tester.tap(find.text('Push Ups'));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('lower your chest under control.'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          await tester.pageBack();
          await tester.pumpAndSettle();
          await tab(tester, 'Home');
        }
      }
    },
  );
}
