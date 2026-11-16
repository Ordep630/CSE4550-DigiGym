import 'dart:async';

import 'package:digigym/models/workout_record_details.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/workout_history_screen.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/digigym_brand_logo.dart';
import 'package:digigym/widgets/workout_streak_dialog.dart';
import 'package:digigym_backend_client/digigym_backend_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fit_115_flows_test.dart' as fit;
import 'live_workout_ui_test.dart' show startWorkout, tapWithCountdown;
import 'support/memory_schedule_storage.dart';
import 'workout_theme_visual_test.dart' show loadWorkoutVisualFonts;
import 'workouts_screen_test.dart' as workout;

final today = DateTime(2026, 11, 2, 8);
final streakButton = find.byKey(const ValueKey('view-workout-streak'));
final modal = find.byType(WorkoutStreakDialog);
final streakCount = find.byKey(const ValueKey('streak-count'));
final historyButton = find.byKey(const ValueKey('streak-view-history'));

Finder badge(String date) => find.byKey(ValueKey('streak-badge-$date'));
Finder popupIcon(IconData icon) =>
    find.descendant(of: modal, matching: find.byIcon(icon));

class StreakApi extends fit.FitApi {
  int historyReads = 0;

  @override
  Future<List<CompletedWorkout>> getWorkoutHistory() {
    historyReads++;
    return super.getWorkoutHistory();
  }
}

CompletedWorkout entry(
  int id,
  DateTime date, {
  String accountId = fit.accountId,
  String? title,
}) => CompletedWorkout(
  id: id,
  authUserId: UuidValue.fromString(accountId),
  workoutName: title ?? 'Test workout $id',
  durationMinutes: 25,
  details: fit.details,
  completedAt: date.toUtc(),
);

Widget shell(
  StreakApi api, {
  DateTime? clock,
  TargetPlatform platform = TargetPlatform.android,
  ThemeMode mode = ThemeMode.light,
}) => fit.app(
  HomeScreen(
    user: api.restoredProfile!,
    api: api,
    clock: () => clock ?? today,
    workoutSessionStorage: MemoryScheduleStorage(),
    workoutPreferenceStorage: MemoryScheduleStorage(),
    onLogout: () async {},
    onUpdateProfile: (_) {},
  ),
  platform: platform,
  mode: mode,
);

Future<void> openStreak(WidgetTester tester) async {
  await tester.tap(streakButton);
  await tester.pumpAndSettle();
  expect(modal, findsOneWidget);
}

Future<void> closeStreak(WidgetTester tester) async {
  await fit.visibleTap(tester, find.byTooltip('Close'));
  expect(modal, findsNothing);
}

void main() {
  setUpAll(loadWorkoutVisualFonts);

  testWidgets(
    'Home streak opens confirmed local dates and the existing History',
    (tester) async {
      final api = StreakApi()
        ..streak = 5
        ..history.addAll([
          entry(1, today, title: 'Workout to delete'),
          entry(2, DateTime(2026, 10, 27, 4)),
          entry(3, DateTime(2026, 10, 27, 23, 50)),
          entry(4, DateTime(2026, 10, 28), accountId: fit.secondAccountId),
          entry(5, DateTime(2026, 10, 26, 23, 59)),
          entry(6, DateTime(2026, 11, 3, 0, 1)),
        ]);
      await tester.pumpWidget(shell(api));
      await tester.pumpAndSettle();
      final semantics = tester.ensureSemantics();
      try {
        expect(
          find.bySemanticsLabel(RegExp('View Workout Streak')),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
      await tester.tapAt(
        tester.getTopRight(streakButton) + const Offset(-9, 13),
      );
      await tester.pumpAndSettle();
      expect(modal, findsOneWidget);
      expect(tester.widget<Text>(streakCount).data, '5');
      expect(find.text('Days Streak'), findsOneWidget);
      expect(find.text('Workout recorded today!'), findsOneWidget);
      expect(popupIcon(Icons.check_rounded), findsNWidgets(2));
      expect(popupIcon(Icons.remove_rounded), findsNWidgets(5));
      for (final date in [
        '2026-10-27',
        '2026-10-28',
        '2026-10-29',
        '2026-10-30',
        '2026-10-31',
        '2026-11-01',
        '2026-11-02',
      ]) {
        expect(badge(date), findsOneWidget);
      }
      expect(badge('2026-11-03'), findsNothing);
      expect(badge('2026-10-26'), findsNothing);
      final completed = badge('2026-10-27');
      final context = tester.element(completed);
      final surfaces = DigiGymSurfaces.of(context);
      final decor =
          tester.widget<DecoratedBox>(completed).decoration as BoxDecoration;
      expect(decor.border?.top, surfaces.streak.border?.top);
      expect(decor.boxShadow, containsAll(surfaces.streak.boxShadow!));
      expect(
        tester
            .widgetList<Icon>(popupIcon(Icons.check_rounded))
            .map((it) => it.color),
        everyElement(surfaces.streakAccent),
      );
      expect(
        tester
            .widgetList<Icon>(popupIcon(Icons.remove_rounded))
            .map((it) => it.color),
        everyElement(Theme.of(context).colorScheme.onSurfaceVariant),
      );
      final weeklyBadge = find.byKey(const ValueKey('week-badge-2026-11-02'));
      final weeklyDecor =
          tester.widget<Container>(weeklyBadge).decoration! as BoxDecoration;
      expect(
        (weeklyDecor.border as Border).top.color,
        surfaces.accent.withValues(alpha: .65),
      );
      expect(api.streakReads, [today, today]);
      expect(api.historyReads, 2);

      await fit.visibleTap(tester, historyButton);
      expect(modal, findsNothing);
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
      await tester.ensureVisible(find.text('Workout to delete'));
      await tester.pumpAndSettle();
      await tester.longPress(find.text('Workout to delete'));
      await tester.pumpAndSettle();
      await fit.visibleTap(tester, find.byTooltip('Delete selected workouts'));
      await fit.visibleTap(
        tester,
        find.byKey(const ValueKey('confirm-delete-workouts')),
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await openStreak(tester);
      expect(tester.widget<Text>(streakCount).data, '5');
      expect(find.text('No workout recorded today'), findsOneWidget);
      expect(popupIcon(Icons.check_rounded), findsOneWidget);
      await closeStreak(tester);
    },
  );

  testWidgets(
    'coalesces pending reads and retries partial failures independently',
    (tester) async {
      final count = Completer<int>();
      final rows = Completer<List<CompletedWorkout>>();
      final api = StreakApi()
        ..pendingStreak = count.future
        ..pendingHistory = rows;
      await tester.pumpWidget(shell(api));
      await tester.pumpAndSettle();
      await openStreak(tester);
      expect(find.text('Loading current streak…'), findsOneWidget);
      expect(find.text('Loading workout activity…'), findsOneWidget);
      expect(api.historyReads, 1);
      expect(api.streakReads, [today]);
      count.complete(1);
      rows.completeError(StateError('test history failure'));
      await tester.pumpAndSettle();
      expect(find.text('Day Streak'), findsOneWidget);
      expect(
        find.text('Recent workout activity is unavailable.'),
        findsOneWidget,
      );
      expect(find.text('No workout recorded today'), findsNothing);
      api.pendingHistory = null;
      await fit.visibleTap(tester, find.text('Retry activity'));
      expect(find.text('No workout recorded today'), findsOneWidget);
      expect(api.streakReads, [today]);
      await closeStreak(tester);

      api
        ..pendingStreak = null
        ..failStreakRead = true
        ..history.add(entry(1, today));
      await openStreak(tester);
      expect(streakCount, findsNothing);
      expect(find.text('Current streak unavailable'), findsOneWidget);
      expect(find.text('Workout recorded today!'), findsOneWidget);
      final historyReads = api.historyReads;
      api.failStreakRead = false;
      await fit.visibleTap(tester, find.text('Retry streak'));
      expect(tester.widget<Text>(streakCount).data, '0');
      expect(find.text('Days Streak'), findsOneWidget);
      expect(api.historyReads, historyReads);
    },
  );

  testWidgets('signed-out popup performs no workout data requests', (
    tester,
  ) async {
    final api = StreakApi()..authenticated = false;
    await tester.pumpWidget(shell(api));
    await tester.pumpAndSettle();
    await openStreak(tester);
    expect(
      find.text('Sign in to view your workout streak and recent activity.'),
      findsOneWidget,
    );
    expect(historyButton, findsNothing);
    expect(streakCount, findsNothing);
    expect(api.streakReads, isEmpty);
    expect(api.historyReads, 0);
    await closeStreak(tester);
  });

  testWidgets(
    'account change invalidates the open popup and drops old replies',
    (tester) async {
      final count = Completer<int>();
      final rows = Completer<List<CompletedWorkout>>();
      final previous = StreakApi()
        ..pendingStreak = count.future
        ..pendingHistory = rows;
      final current = StreakApi()
        ..restoredProfile = fit.account(fit.secondAccountId)
        ..streak = 2;
      await tester.pumpWidget(shell(previous));
      await tester.pumpAndSettle();
      await openStreak(tester);
      await tester.pumpWidget(shell(current));
      await tester.pumpAndSettle();
      count.complete(99);
      rows.complete([entry(1, today)]);
      await tester.pumpAndSettle();
      expect(streakCount, findsNothing);
      expect(historyButton, findsNothing);
      expect(popupIcon(Icons.check_rounded), findsNothing);
      await closeStreak(tester);
      await openStreak(tester);
      expect(tester.widget<Text>(streakCount).data, '2');
      expect(find.text('No workout recorded today'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final overlappingRead in [false, true]) {
    testWidgets(
      'open popup updates after a confirmed save (overlapping read: $overlappingRead)',
      (tester) async {
        final save = Completer<CompletedWorkout>();
        final staleHistory = Completer<List<CompletedWorkout>>();
        final date = workoutLocalDate(fit.completionTime);
        final earlier = entry(
          2,
          DateTime(date.year, date.month, date.day - 1, 8),
        );
        final api = StreakApi()
          ..pendingSave = save
          ..history.add(earlier);
        await tester.pumpWidget(shell(api, clock: date));
        await tester.pumpAndSettle();
        await workout.tab(tester, 'Workout');
        await startWorkout(tester);
        await tapWithCountdown(
          tester,
          find.byKey(const ValueKey('finish-workout')),
        );
        expect(api.completionCalls, 1);
        await workout.tab(tester, 'Home');
        if (overlappingRead) api.pendingHistory = staleHistory;
        await openStreak(tester);
        expect(
          find.text(
            overlappingRead
                ? 'Loading workout activity…'
                : 'No workout recorded today',
          ),
          findsOneWidget,
        );
        expect(tester.widget<Text>(streakCount).data, '0');
        final historyReads = api.historyReads;
        save.complete(entry(1, fit.completionTime));
        await tester.pumpAndSettle();
        if (overlappingRead) {
          api.pendingHistory = null;
          staleHistory.complete([earlier]);
          await tester.pumpAndSettle();
        }
        expect(find.text('Workout recorded today!'), findsOneWidget);
        expect(popupIcon(Icons.check_rounded), findsNWidgets(2));
        expect(tester.widget<Text>(streakCount).data, '1');
        expect(api.historyReads, historyReads + (overlappingRead ? 1 : 0));
      },
    );
  }

  testWidgets('small screen with 3× text can scroll to History and close', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(280, 510);
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final api = StreakApi()
      ..streak = 123
      ..history.add(entry(1, today));
    await tester.pumpWidget(shell(api, mode: ThemeMode.dark));
    await tester.pumpAndSettle();
    await openStreak(tester);
    expect(tester.getSize(find.byType(Dialog)).width, lessThanOrEqualTo(280));
    final close = find.byTooltip('Close');
    expect(tester.getSize(close).shortestSide, greaterThanOrEqualTo(48));
    await tester.ensureVisible(historyButton);
    await tester.pumpAndSettle();
    expect(historyButton.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await closeStreak(tester);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('streak popup golden ${platform.name} ${mode.name}', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(426, 952);
        tester.view.padding = platform == TargetPlatform.iOS
            ? const FakeViewPadding(top: 59, bottom: 34)
            : const FakeViewPadding(top: 52, bottom: 24);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetPadding);
        final shadows = debugDisableShadows;
        debugDisableShadows = false;
        try {
          final api = StreakApi()
            ..streak = 3
            ..history.addAll([
              entry(1, today),
              entry(2, DateTime(2026, 11, 1, 8)),
              entry(3, DateTime(2026, 10, 31, 8)),
              entry(4, DateTime(2026, 10, 28, 8)),
            ]);
          await tester.pumpWidget(shell(api, mode: mode, platform: platform));
          await tester.runAsync(() async {
            final context = tester.element(find.byType(HomeScreen));
            for (final asset in [
              'assets/images/digigym_workout_icon.png',
              DigiGymBrandLogo.assetName(
                DigiGymLogoLayout.horizontal,
                mode == ThemeMode.light ? Brightness.light : Brightness.dark,
              ),
            ]) {
              await precacheImage(AssetImage(asset), context);
            }
          });
          await tester.pumpAndSettle();
          await openStreak(tester);
          expect(find.text('Workout recorded today!'), findsOneWidget);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              'goldens/workout_streak_popup_${mode.name}_${platform.name}.png',
            ),
          );
          expect(tester.takeException(), isNull);
        } finally {
          debugDisableShadows = shadows;
        }
      });
    }
  }
}
