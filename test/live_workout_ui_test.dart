import 'package:digigym/models/workout_plan.dart';
import 'package:digigym/models/workout_record_details.dart';
import 'package:digigym/models/workout_schedule_day.dart';
import 'package:digigym/models/user_profile.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/workout_history_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/theme/digigym_dot_typography.dart';
import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym/widgets/digigym_dialog.dart';
import 'package:digigym/widgets/dot_matrix_text.dart';
import 'package:digigym/widgets/floating_bottom_navigation_bar.dart';
import 'package:digigym/widgets/monthly_activity_calendar.dart';
import 'package:digigym/widgets/recommended_workout_glass_card.dart';
import 'package:digigym/widgets/segmented_progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fit_115_flows_test.dart' show FitApi, app, completionTime, visibleTap;
import 'support/memory_schedule_storage.dart';
import 'workout_theme_visual_test.dart' show loadWorkoutVisualFonts;
import 'workouts_screen_test.dart' as workout;

Finder key(String value) => find.byKey(ValueKey(value));

final countdown = key('workout-countdown');
final countdownGlyphs = find.descendant(
  of: countdown,
  matching: find.byType(DotMatrixText),
);
final recommendation = find.byType(RecommendedWorkoutGlassCard);
final startButton = key('start-live-workout');
final confirmStart = key('confirm-workout-start');
final skipStartConfirmation = key('skip-workout-start-confirmation');
final confirmDiscard = key('confirm-workout-discard');
final resumeLabel = find.descendant(
  of: key('pause-resume-workout'),
  matching: find.text('Resume'),
);

String countdownDigits(WidgetTester tester) => tester
    .widgetList<DotMatrixText>(countdownGlyphs)
    .map((dots) => dots.text)
    .join();

List<Rect> controlBounds(WidgetTester tester) {
  final origin = tester.getTopLeft(recommendation);
  return [
    for (final name in [
      'pause-resume-workout',
      'finish-workout',
      'discard-workout',
    ])
      tester.getRect(key(name)).shift(-origin),
  ];
}

List<Rect> countdownBounds(WidgetTester tester) => [
  for (var i = 0; i < countdownGlyphs.evaluate().length; i++)
    tester.getRect(countdownGlyphs.at(i)).shift(-tester.getTopLeft(countdown)),
];

// A running countdown schedules frames continually, including during taps.
Future<void> tapWithCountdown(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pump();
  await tester.tap(target);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> startWorkout(WidgetTester tester) async {
  await visibleTap(tester, startButton);
  await tapWithCountdown(tester, confirmStart);
}

void expectWorkoutConfirmationMaterial(WidgetTester tester) {
  final dialog = find.byType(DigiGymDialog);
  final glass = find.descendant(
    of: dialog,
    matching: find.byType(DashboardGlassCard),
  );
  expect(tester.widget<DashboardGlassCard>(glass).backdropSigma, 16);
  expect(tester.widget<DashboardGlassCard>(glass).lightingOpacity, .35);
  expect(
    find.descendant(of: glass, matching: find.byType(BackdropFilter)),
    findsOneWidget,
  );
  final fill = DigiGymSurfaces.of(tester.element(glass)).glass.gradient!;
  expect(fill.colors.map((color) => color.a), everyElement(.92));
}

Finder navigationTab(String name) => find.descendant(
  of: find.byType(FloatingBottomNavigationBar),
  matching: find.text(name),
);

void main() {
  setUpAll(loadWorkoutVisualFonts);

  for (final (platform, mode) in [
    (TargetPlatform.android, ThemeMode.light),
    (TargetPlatform.iOS, ThemeMode.dark),
  ]) {
    testWidgets(
      'timed workout updates Home and saved activity on ${platform.name}',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final api = FitApi();
        final plan = WorkoutPlan.forUser(workout.profile());
        final day = workoutLocalDate(completionTime);
        final localClock = DateTime(day.year, day.month, day.day, 12);
        var now = Duration.zero;
        final appearance = ValueNotifier(mode);
        addTearDown(appearance.dispose);
        await tester.pumpWidget(
          ValueListenableBuilder<ThemeMode>(
            valueListenable: appearance,
            child: HomeScreen(
              user: workout.profile(),
              api: api,
              clock: () => localClock,
              workoutSessionStorage: MemoryScheduleStorage(),
              workoutPreferenceStorage: MemoryScheduleStorage(),
              workoutMonotonicNow: () => now,
              onLogout: () async {},
              onUpdateProfile: (_) {},
            ),
            builder: (context, value, child) =>
                app(child!, platform: platform, mode: value),
          ),
        );
        await tester.pumpAndSettle();
        await workout.tab(tester, 'Workout');
        expect(find.text('History'), findsOneWidget);
        final start = find.descendant(
          of: recommendation,
          matching: key('start-live-workout'),
        );
        expect(tester.getSize(start), const Size.square(53));
        expect(find.byTooltip('Start Workout'), findsOneWidget);
        expect(find.text('Guided walkthrough'), findsNothing);
        expect(
          tester.getRect(start).left,
          greaterThanOrEqualTo(tester.getRect(key('workout-duration')).right),
        );
        final startStyle = tester.widget<IconButton>(start).style!;
        expect(
          startStyle.foregroundColor!.resolve({}),
          Theme.of(tester.element(start)).colorScheme.primary,
        );
        expect(startStyle.shape!.resolve({}), isA<CircleBorder>());
        final badge = tester.widget<Container>(
          key('week-badge-${day.toIso8601String().split('T').first}'),
        );
        final startDecoration = find
            .ancestor(of: start, matching: find.byType(DecoratedBox))
            .first;
        expect(
          tester.widget<DecoratedBox>(startDecoration).decoration,
          badge.decoration,
        );
        final play = find.descendant(
          of: start,
          matching: find.byIcon(Icons.play_arrow_rounded),
        );
        expect(tester.getCenter(play), tester.getCenter(start));
        final idleGlyphs = find.descendant(
          of: key('workout-duration'),
          matching: find.byType(DotMatrixText),
        );
        final idleDigits = tester
            .widgetList<DotMatrixText>(idleGlyphs)
            .toList();
        expect(
          idleDigits.map((glyph) => glyph.text).join(),
          '${plan.durationMinutes}',
        );
        expect(
          tester.getRect(idleGlyphs.at(1)).left -
              tester.getRect(idleGlyphs.first).right,
          closeTo(DigiGymDotTypography.workoutHeight * .20, .01),
        );
        final planned = Duration(seconds: plan.estimatedSeconds);
        final plannedLabel = find.text(
          'Planned duration · ${formatWorkoutTime(planned)}',
        );
        await visibleTap(tester, start);
        expect(
          find.textContaining("You're about to begin ${plan.title}."),
          findsOneWidget,
        );
        expect(plannedLabel, findsOneWidget);
        expect(
          tester.widget<CheckboxListTile>(skipStartConfirmation).value,
          isFalse,
        );
        expectWorkoutConfirmationMaterial(tester);
        await tapWithCountdown(tester, confirmStart);
        expect(countdownDigits(tester), '${formatWorkoutTime(planned)}.00');
        final glyphBounds = countdownBounds(tester);
        final glyphs = tester
            .widgetList<DotMatrixText>(countdownGlyphs)
            .toList();
        expect(glyphs, hasLength(8));
        final expectedInk = mode == ThemeMode.light
            ? Colors.black
            : DigiGymDarkColors.primaryText;
        expect(glyphs.map((glyph) => glyph.color), everyElement(expectedInk));
        for (final glyph in idleDigits) {
          expect(glyph.fillRatio, glyphs.first.fillRatio);
          expect(glyph.softenedDigits, glyphs.first.softenedDigits);
          expect(glyph.height, glyphs.first.height);
          expect(glyph.color, glyphs.first.color);
        }
        for (var i = 0; i < glyphs.length; i++) {
          final glyph = glyphs[i];
          final height = DigiGymDotTypography.workoutHeight * (i < 5 ? 1 : .85);
          expect(glyph.fillRatio, .84);
          expect(glyph.softenedDigits, DigiGymDotTypography.softenedDigits);
          expect(glyphBounds[i].height, closeTo(height, .01));
          expect(glyphBounds[i].bottom, closeTo(glyphBounds.first.bottom, .01));
          if (i > 0) {
            expect(
              glyphBounds[i].left - glyphBounds[i - 1].right,
              closeTo(DigiGymDotTypography.workoutHeight * .20, .01),
            );
          }
        }
        expect(key('workout-duration'), findsNothing);
        expect(plannedLabel, findsOneWidget);
        for (final name in [
          'workout-countdown',
          'pause-resume-workout',
          'finish-workout',
          'discard-workout',
          'workout-featured-exercises',
        ]) {
          expect(
            find.descendant(of: recommendation, matching: key(name)),
            findsOneWidget,
          );
        }
        now = const Duration(seconds: 59);
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          countdownDigits(tester),
          '${formatWorkoutTime(planned - now)}.00',
        );
        now += const Duration(milliseconds: 370);
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          countdownDigits(tester),
          '${formatWorkoutTime(planned - now)}.63',
        );
        expect(
          countdownBounds(tester),
          glyphBounds.map((rect) => rectMoreOrLessEquals(rect, epsilon: .01)),
        );
        expect(api.completionCalls, 0);
        expect(plannedLabel, findsOneWidget);

        await workout.tab(tester, 'Home');
        final ring = find.byType(SegmentedProgressRing);
        expect(
          tester.widget<SegmentedProgressRing>(ring).caption,
          'Time target',
        );
        expect(
          tester.widget<SegmentedProgressRing>(ring).progress,
          closeTo(5937 / plan.estimatedSeconds, .01),
        );
        now = const Duration(seconds: 60);
        await tester.pump(const Duration(seconds: 1));
        expect(
          tester.widget<SegmentedProgressRing>(ring).progress,
          closeTo(6000 / plan.estimatedSeconds, .01),
        );
        expect(find.text('Active time'), findsOneWidget);

        await tapWithCountdown(tester, navigationTab('Workout'));
        final runningControls = controlBounds(tester);
        final runningCardSize = tester.getSize(recommendation);
        expect(
          runningControls.map((rect) => rect.center.dy).toSet(),
          hasLength(1),
          reason: 'Normal phone action bounds: $runningControls',
        );
        expect(
          runningControls.map((rect) => rect.shortestSide),
          everyElement(greaterThanOrEqualTo(48)),
        );
        final contentWidth = runningCardSize.width - 40;
        final [pauseRect, finishRect, discardRect] = runningControls;
        expect(finishRect.center.dx, closeTo(runningCardSize.width / 2, .01));
        expect(discardRect.right - pauseRect.left, closeTo(contentWidth, .01));
        expect(
          finishRect.left - pauseRect.right,
          closeTo(discardRect.left - finishRect.right, .01),
        );
        final discard = key('discard-workout');
        final discardStyle = tester.widget<TextButton>(discard).style!;
        final colors = Theme.of(tester.element(discard)).colorScheme;
        expect(
          discardStyle.foregroundColor!.resolve({}),
          mode == ThemeMode.light
              ? colors.error
              : DigiGymDarkColors.destructive,
        );
        expect(discardStyle.backgroundColor, isNull);
        await tapWithCountdown(tester, key('pause-resume-workout'));
        expect(controlBounds(tester), runningControls);
        expect(tester.getSize(recommendation), runningCardSize);
        expect(plannedLabel, findsOneWidget);
        now += const Duration(minutes: 9);
        await tester.pump(const Duration(seconds: 1));
        expect(
          countdownDigits(tester),
          '${formatWorkoutTime(planned - const Duration(minutes: 1))}.00',
        );
        await tapWithCountdown(tester, key('pause-resume-workout'));

        await tapWithCountdown(tester, key('workout-featured-exercises'));
        await workout.activate(tester, 'workout-start');
        expect(key('workout-walkthrough-step'), findsOneWidget);
        expect(find.text(plan.exercises.first.name), findsOneWidget);
        expect(countdown, findsNothing);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        now += planned - const Duration(minutes: 1);
        await tester.pump(const Duration(milliseconds: 16));
        expect(countdownDigits(tester), '00:00.00');
        expect(find.text('+'), findsNothing);
        expect(api.completionCalls, 0);
        const overtime = Duration(seconds: 2, milliseconds: 340);
        now += overtime;
        await tester.pump(const Duration(milliseconds: 16));
        expect(countdownDigits(tester), '00:02.34');
        expect(plannedLabel, findsOneWidget);
        expect(
          find.descendant(of: countdown, matching: find.text('+')),
          findsOneWidget,
        );
        expect(
          countdownBounds(tester),
          glyphBounds.map((rect) => rectMoreOrLessEquals(rect, epsilon: .01)),
        );
        expect(
          tester.getRect(find.text('+')).right,
          lessThanOrEqualTo(tester.getRect(countdownGlyphs.first).left),
        );
        expect(
          tester.getRect(countdownGlyphs.last).right,
          lessThan(tester.getRect(recommendation).right),
        );

        appearance.value = mode == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(countdownDigits(tester), '00:02.34');
        expect(
          tester.widget<DotMatrixText>(countdownGlyphs.first).color,
          mode == ThemeMode.light
              ? DigiGymDarkColors.primaryText
              : Colors.black,
        );
        expect(controlBounds(tester), runningControls);
        await workout.tab(tester, 'Home');
        expect(tester.widget<SegmentedProgressRing>(ring).progress, 100);
        expect(
          tester.widget<SegmentedProgressRing>(ring).caption,
          'Time target',
        );
        expect(api.completionCalls, 0);

        await tapWithCountdown(tester, navigationTab('Workout'));
        await tapWithCountdown(tester, key('finish-workout'));
        expect(api.completionCalls, 1);
        expect(api.recordedDays, [completionTime]);
        expect(find.text('Workout saved'), findsOneWidget);
        final activeTime = planned + overtime;
        expect(
          WorkoutRecordDetails.decode(api.history.single.details).activeTime,
          activeTime,
        );

        await workout.tab(tester, 'Home');
        expect(tester.widget<SegmentedProgressRing>(ring).caption, 'Saved');
        expect(key('activity-state-${day.day}'), findsOneWidget);
        final iso = day.toIso8601String().split('T').first;
        await visibleTap(tester, key('month-day-$iso'));
        final history = find.byType(WorkoutHistoryScreen);
        expect(tester.widget<WorkoutHistoryScreen>(history).day, day);
        await visibleTap(tester, find.text(plan.title));
        expect(
          find.text('Active time: ${formatWorkoutTime(activeTime)}'),
          findsOneWidget,
        );
        expect(
          find.text('Planned duration: ${plan.durationMinutes} minutes'),
          findsOneWidget,
        );

        tester.state<NavigatorState>(find.byType(Navigator)).pop();
        await tester.pumpAndSettle();
        await tester.longPress(find.text(plan.title));
        await tester.pumpAndSettle();
        await visibleTap(tester, find.byTooltip('Delete selected workouts'));
        await visibleTap(tester, key('confirm-delete-workouts'));
        expect(find.text('No workouts on this date'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(key('activity-state-${day.day}'), findsNothing);
        expect(api.recordedDays, [completionTime]);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'integrated timer goldens for ${platform.name} ${mode.name}',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(426, 952);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final shadows = debugDisableShadows;
          debugDisableShadows = false;
          try {
            final api = FitApi();
            var elapsed = Duration.zero;
            await tester.pumpWidget(
              app(
                Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      padding: platform == TargetPlatform.iOS
                          ? const EdgeInsets.only(top: 59, bottom: 34)
                          : const EdgeInsets.only(top: 52, bottom: 24),
                    ),
                    child: HomeScreen(
                      user: workout.profile(),
                      api: api,
                      clock: () => DateTime(2026, 11, 18, 12),
                      workoutSessionStorage: MemoryScheduleStorage(),
                      workoutPreferenceStorage: MemoryScheduleStorage(),
                      workoutMonotonicNow: () => elapsed,
                      onLogout: () async {},
                      onUpdateProfile: (_) {},
                    ),
                  ),
                ),
                mode: mode,
                platform: platform,
              ),
            );
            await tester.runAsync(() async {
              await precacheImage(
                const AssetImage('assets/images/digigym_workout_icon.png'),
                tester.element(find.byType(HomeScreen)),
              );
            });
            await tester.pumpAndSettle();
            await workout.tab(tester, 'Workout');
            final path = 'goldens/workout_${mode.name}_integrated_timer';
            final appRoot = find.byType(MaterialApp);
            await expectLater(
              appRoot,
              matchesGoldenFile('${path}_ready_${platform.name}.png'),
            );
            await tester.tap(startButton);
            await tester.pumpAndSettle();
            await expectLater(
              appRoot,
              matchesGoldenFile('${path}_confirm_start_${platform.name}.png'),
            );
            await tapWithCountdown(tester, confirmStart);
            elapsed = const Duration(seconds: 12, milliseconds: 340);
            await tester.pump(const Duration(milliseconds: 16));
            await expectLater(
              appRoot,
              matchesGoldenFile('${path}_running_${platform.name}.png'),
            );
            await tester.tap(key('discard-workout'));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 300));
            await expectLater(
              appRoot,
              matchesGoldenFile('${path}_confirm_discard_${platform.name}.png'),
            );
            expect(tester.takeException(), isNull);
          } finally {
            debugDisableShadows = shadows;
          }
        },
      );
    }
  }

  testWidgets('Workout countdown and actions fit a small screen at 3x text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 740);
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      app(
        HomeScreen(
          user: workout.profile(),
          api: FitApi(),
          workoutSessionStorage: MemoryScheduleStorage(),
          workoutPreferenceStorage: MemoryScheduleStorage(),
          onLogout: () async {},
          onUpdateProfile: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await workout.tab(tester, 'Workout');
    workout.expectTitleFits(tester, 'Workout');
    expect(find.text('History'), findsOneWidget);
    await visibleTap(tester, startButton);
    await visibleTap(tester, skipStartConfirmation);
    expect(
      tester.widget<CheckboxListTile>(skipStartConfirmation).value,
      isTrue,
    );
    await visibleTap(tester, skipStartConfirmation);
    await tapWithCountdown(tester, confirmStart);
    expect(tester.getRect(countdown).width, lessThan(320));
    final runningControls = controlBounds(tester);
    final runningCardSize = tester.getSize(recommendation);
    expect(runningControls.map((rect) => rect.center.dy).toSet(), hasLength(3));
    expect(
      runningControls.map((rect) => rect.shortestSide),
      everyElement(greaterThanOrEqualTo(48)),
    );
    await tapWithCountdown(tester, key('pause-resume-workout'));
    expect(resumeLabel, findsOneWidget);
    expect(controlBounds(tester), runningControls);
    expect(tester.getSize(recommendation), runningCardSize);

    tester.view.physicalSize = const Size(375, 844);
    tester.platformDispatcher.textScaleFactorTestValue = 1;
    await tester.pumpAndSettle();
    final compactControls = controlBounds(tester);
    expect(compactControls.map((rect) => rect.center.dy).toSet(), hasLength(2));
    await tapWithCountdown(tester, key('pause-resume-workout'));
    expect(controlBounds(tester), compactControls);
    await tapWithCountdown(tester, key('pause-resume-workout'));
    await workout.activate(tester, 'finish-workout');
    expect(find.text('Workout saved'), findsOneWidget);
    await workout.activate(tester, 'open-workout-history');
    expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a reopened workout shows its paused checkpoint', (tester) async {
    final api = FitApi();
    final storage = MemoryScheduleStorage();
    final planned = Duration(
      seconds: WorkoutPlan.forUser(workout.profile()).estimatedSeconds,
    );
    var now = Duration.zero;
    Future<void> openWorkout() async {
      await tester.pumpWidget(
        app(
          HomeScreen(
            user: workout.profile(),
            api: api,
            workoutSessionStorage: storage,
            workoutPreferenceStorage: MemoryScheduleStorage(),
            workoutMonotonicNow: () => now,
            onLogout: () async {},
            onUpdateProfile: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await workout.tab(tester, 'Workout');
    }

    await openWorkout();
    await startWorkout(tester);
    now = const Duration(seconds: 14, milliseconds: 210);
    await tester.pump(const Duration(milliseconds: 16));
    final checkpoint = '${formatWorkoutTime(planned - now)}.79';
    expect(countdownDigits(tester), checkpoint);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    now = Duration.zero;
    await openWorkout();
    expect(resumeLabel, findsOneWidget);
    expect(countdownDigits(tester), checkpoint);
    now = const Duration(minutes: 1);
    await tester.pump(const Duration(seconds: 1));
    expect(countdownDigits(tester), checkpoint);
    await tapWithCountdown(tester, key('pause-resume-workout'));
    now += const Duration(milliseconds: 120);
    await tester.pump(const Duration(milliseconds: 16));
    expect(
      countdownDigits(tester),
      '${formatWorkoutTime(planned - const Duration(seconds: 15))}.67',
    );
    expect(api.completionCalls, 0);
  });

  testWidgets(
    'discard requires confirmation and clears only the local session',
    (tester) async {
      final api = FitApi();
      final storage = MemoryScheduleStorage();
      await tester.pumpWidget(
        app(
          HomeScreen(
            user: workout.profile(),
            api: api,
            workoutSessionStorage: storage,
            workoutPreferenceStorage: MemoryScheduleStorage(),
            onLogout: () async {},
            onUpdateProfile: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await workout.tab(tester, 'Workout');
      await startWorkout(tester);
      await tapWithCountdown(tester, key('discard-workout'));
      expectWorkoutConfirmationMaterial(tester);
      final colorScheme = Theme.of(tester.element(confirmDiscard)).colorScheme;
      final style = tester.widget<FilledButton>(confirmDiscard).style!;
      expect(style.backgroundColor!.resolve({}), colorScheme.error);
      expect(style.foregroundColor!.resolve({}), colorScheme.onError);
      await tapWithCountdown(tester, find.text('Keep Workout'));
      expect(countdown, findsOneWidget);
      await tapWithCountdown(tester, key('discard-workout'));
      await tapWithCountdown(tester, confirmDiscard);
      expect(countdown, findsNothing);
      expect(key('workout-duration'), findsOneWidget);
      expect(storage.values, isEmpty);
      expect(api.completionCalls, 0);
    },
  );

  testWidgets(
    'start opt-out survives restart and can be reset per account in Profile',
    (tester) async {
      final preferences = MemoryScheduleStorage();
      final sessions = MemoryScheduleStorage();
      final first = workout.profile();
      final second = UserProfile(
        accountId: '123e4567-e89b-12d3-a456-426614174001',
        name: 'Second test user',
        email: 'second@example.com',
      );
      final settingsSwitch = key('confirm-before-starting-workouts');
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      Future<void> openAccount(UserProfile user) async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.pumpWidget(
          app(
            HomeScreen(
              user: user,
              api: FitApi()..restoredProfile = user,
              workoutSessionStorage: sessions,
              workoutPreferenceStorage: preferences,
              workoutMonotonicNow: () => Duration.zero,
              onLogout: () async {},
              onUpdateProfile: (_) {},
            ),
            mode: ThemeMode.system,
          ),
        );
        await tester.pumpAndSettle();
        await workout.tab(tester, 'Workout');
      }

      Future<void> discardWorkout() async {
        await tapWithCountdown(tester, key('discard-workout'));
        expect(find.text('Discard workout?'), findsOneWidget);
        expect(countdown, findsOneWidget);
        expectWorkoutConfirmationMaterial(tester);
        final destructive = tester.widget<FilledButton>(confirmDiscard).style!;
        expect(
          destructive.backgroundColor!.resolve({}),
          DigiGymDarkColors.destructive,
        );
        expect(
          destructive.foregroundColor!.resolve({}),
          DigiGymDarkColors.graphite,
        );
        await tapWithCountdown(tester, confirmDiscard);
      }

      await openAccount(first);
      await tester.tap(startButton);
      await tester.tap(startButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(confirmStart, findsOneWidget);
      expect(
        Theme.of(tester.element(confirmStart)).brightness,
        Brightness.light,
      );
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(confirmStart)).brightness,
        Brightness.dark,
      );
      await visibleTap(tester, skipStartConfirmation);
      await visibleTap(tester, key('cancel-workout-start'));
      expect(countdown, findsNothing);
      expect(sessions.writes, 0);
      expect(preferences.writes, 0);

      await visibleTap(tester, startButton);
      expect(
        tester.widget<CheckboxListTile>(skipStartConfirmation).value,
        isFalse,
      );
      await visibleTap(tester, skipStartConfirmation);
      final confirm = tester.widget<FilledButton>(confirmStart).onPressed!;
      confirm();
      confirm();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(countdown, findsOneWidget);
      expect(confirmStart, findsNothing);
      expect(sessions.writes, 1);
      expect(preferences.writes, 1);
      await discardWorkout();

      await openAccount(second);
      await visibleTap(tester, startButton);
      expect(confirmStart, findsOneWidget);
      expect(
        tester.widget<CheckboxListTile>(skipStartConfirmation).value,
        isFalse,
      );
      await visibleTap(tester, key('cancel-workout-start'));

      await openAccount(first);
      await tapWithCountdown(tester, startButton);
      expect(confirmStart, findsNothing);
      expect(countdown, findsOneWidget);
      await discardWorkout();

      await workout.tab(tester, 'Profile');
      await visibleTap(tester, find.text('Preferences'));
      expect(tester.widget<SwitchListTile>(settingsSwitch).value, isFalse);
      await visibleTap(tester, settingsSwitch);
      expect(tester.widget<SwitchListTile>(settingsSwitch).value, isTrue);
      expect(preferences.values, isEmpty);

      await openAccount(first);
      await visibleTap(tester, startButton);
      expect(confirmStart, findsOneWidget);
      expect(
        tester.widget<CheckboxListTile>(skipStartConfirmation).value,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('calendar browses earlier months and selects only saved dates', (
    tester,
  ) async {
    final selected = <DateTime>[];
    final earlier = DateTime(2026, 10, 31);
    await tester.pumpWidget(
      app(
        Scaffold(
          body: MonthlyActivityCalendar(
            clock: () => DateTime(2026, 11, 1, 3),
            days: [WorkoutScheduleDay(date: earlier, isCompleted: true)],
            onCompletedDate: selected.add,
          ),
        ),
      ),
    );
    expect(find.text('NOV'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous activity month'));
    await tester.pumpAndSettle();
    expect(find.text('OCT'), findsOneWidget);
    await tester.tap(key('month-day-2026-10-30'));
    expect(selected, isEmpty);
    await tester.tap(key('month-day-2026-10-31'));
    expect(selected, [earlier]);
    await tester.tap(find.byTooltip('Next activity month'));
    await tester.pumpAndSettle();
    expect(find.text('NOV'), findsOneWidget);
  });
}
