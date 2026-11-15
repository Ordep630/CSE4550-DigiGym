import 'dart:async';
import 'dart:convert';

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/models/workout_plan.dart';
import 'package:digigym/screens/change_password_screen.dart';
import 'package:digigym/screens/home_screen.dart';
import 'package:digigym/screens/workout_exercises_screen.dart';
import 'package:digigym/screens/workout_history_screen.dart';
import 'package:digigym/services/digigym_api.dart';
import 'package:digigym/theme/digigym_dashboard_theme.dart';
import 'package:digigym/widgets/daily_streak_indicator.dart';
import 'package:digigym/widgets/digigym_brand_logo.dart';
import 'package:digigym/widgets/digigym_form_components.dart';
import 'package:digigym/widgets/segmented_progress_ring.dart';
import 'package:digigym_backend_client/digigym_backend_client.dart'
    show CompletedWorkout, UuidValue;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';
import 'workout_theme_visual_test.dart' show loadWorkoutVisualFonts;
import 'workouts_screen_test.dart' as workout;

const accountId = '123e4567-e89b-12d3-a456-426614174000';
const secondAccountId = '123e4567-e89b-12d3-a456-426614174001';

UserProfile account([String id = accountId]) =>
    UserProfile(accountId: id, name: 'Test User', email: 'sample@example.test');

final completionTime = DateTime(2026, 11, 18, 23, 59).toUtc();
const details =
    '[{"name":"Squat","sets":"3 × 8","description":"Move slowly."}]';

class FitApi extends FakeDigiGymApi {
  FitApi() {
    authenticated = true;
    restoredProfile = workout.profile();
  }

  final history = <CompletedWorkout>[];
  final recordedDays = <DateTime>[];
  final streakReads = <DateTime>[];
  Completer<CompletedWorkout>? pendingSave;
  Completer<List<CompletedWorkout>>? pendingHistory;
  Future<void>? pendingPassword;
  Future<int>? pendingStreak;
  Object? historyError;
  Object? passwordError;
  Object? saveError;
  bool failStreakWrite = false;
  bool failStreakRead = false;
  int streak = 0;
  int completionCalls = 0;
  int passwordCalls = 0;
  List<int>? deleted;

  @override
  String? get authenticatedAccountId =>
      authenticated ? restoredProfile?.accountId : null;

  @override
  Future<CompletedWorkout> completeWorkout({
    required String workoutName,
    required int durationMinutes,
    required String details,
  }) async {
    completionCalls++;
    if (saveError case final error?) throw error;
    final saved =
        await (pendingSave?.future ??
            Future.value(
              CompletedWorkout(
                id: history.length + 1,
                authUserId: UuidValue.fromString(accountId),
                workoutName: workoutName,
                durationMinutes: durationMinutes,
                details: details,
                completedAt: completionTime,
              ),
            ));
    history.add(saved);
    return saved;
  }

  @override
  Future<List<CompletedWorkout>> getWorkoutHistory() async {
    if (historyError case final error?) throw error;
    final pending = pendingHistory;
    if (pending != null) return pending.future;
    return List.of(history.reversed);
  }

  @override
  Future<int> deleteWorkoutHistory(List<int> ids) async {
    deleted = ids;
    final count = history.length;
    history.removeWhere((item) => ids.contains(item.id));
    return count - history.length;
  }

  @override
  Future<int> recordWorkoutCompletion(DateTime now) async {
    recordedDays.add(now);
    if (failStreakWrite) throw StateError('Unavailable');
    return ++streak;
  }

  @override
  Future<int> getWorkoutStreak(DateTime now) async {
    streakReads.add(now);
    if (failStreakRead) throw StateError('Unavailable');
    final pending = pendingStreak;
    if (pending != null) return pending;
    return streak;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    passwordCalls++;
    await pendingPassword;
    if (passwordError case final error?) throw error;
  }
}

CompletedWorkout sample() => CompletedWorkout(
  id: 1,
  authUserId: UuidValue.fromString(accountId),
  workoutName: 'Full Body Strength',
  durationMinutes: 26,
  details: details,
  completedAt: completionTime,
);

Finder get complete => find.byKey(const ValueKey('complete-workout-button'));
Finder get updatePassword =>
    find.widgetWithText(ElevatedButton, 'Update Password');

Widget app(
  Widget home, {
  ThemeMode mode = ThemeMode.light,
  TargetPlatform platform = TargetPlatform.android,
}) {
  final base = ThemeData(useMaterial3: true, platform: platform);
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: DigiGymDashboardTheme.light(base),
    darkTheme: DigiGymDashboardTheme.dark(base),
    themeMode: mode,
    home: home,
  );
}

Future<void> visibleTap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pump();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> fillPassword(WidgetTester tester, String confirmation) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'sample-current');
  await tester.enterText(fields.at(1), 'sample-new-value');
  await tester.enterText(fields.at(2), confirmation);
}

void main() {
  setUpAll(loadWorkoutVisualFonts);

  testWidgets(
    'one pending history write and a separate retry after a streak failure',
    (tester) async {
      final api = FitApi()
        ..pendingSave = Completer<CompletedWorkout>()
        ..failStreakWrite = true;

      final plan = WorkoutPlan.forUser(workout.profile());
      await tester.pumpWidget(
        app(WorkoutExercisesScreen(plan: plan, completionApi: api)),
      );
      await tester.scrollUntilVisible(complete, 250);
      await tester.tap(complete);
      await tester.tap(complete);
      await tester.pump();
      expect(api.completionCalls, 1);
      expect(api.recordedDays, isEmpty);
      expect(find.text('Workout saved'), findsNothing);

      api.pendingSave!.complete(sample());
      await tester.pumpAndSettle();
      expect(
        find.text('Workout saved. The streak could not be updated.'),
        findsOneWidget,
      );
      expect(api.history, hasLength(1));
      expect(api.recordedDays, [completionTime]);

      api.failStreakWrite = false;
      await visibleTap(tester, find.text('Retry streak update'));
      expect(api.completionCalls, 1);
      expect(api.recordedDays, [completionTime, completionTime]);
      expect(find.text('Workout saved'), findsOneWidget);
      expect(find.text('Retry streak update'), findsNothing);
    },
  );

  testWidgets(
    'failed history save reports no success and never updates streak',
    (tester) async {
      final api = FitApi()..saveError = StateError('Unavailable');
      await tester.pumpWidget(
        app(
          WorkoutExercisesScreen(
            plan: WorkoutPlan.forUser(workout.profile()),
            completionApi: api,
          ),
        ),
      );
      await tester.scrollUntilVisible(complete, 250);
      await visibleTap(tester, complete);
      expect(find.textContaining('Could not confirm the save'), findsOneWidget);
      expect(find.text('Workout saved'), findsNothing);
      expect(api.recordedDays, isEmpty);
    },
  );

  testWidgets(
    'Home loads, refreshes and handles an unavailable streak without changing progress',
    (tester) async {
      final api = FitApi()..streak = 6;
      final initial = DateTime(2026, 11, 19, 0, 1);
      await tester.pumpWidget(
        app(
          HomeScreen(
            user: workout.profile(),
            api: api,
            clock: () => initial,
            onLogout: () async {},
            onUpdateProfile: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(api.streakReads, [initial]);
      expect(
        tester
            .widget<DailyStreakIndicator>(find.byType(DailyStreakIndicator))
            .days,
        6,
      );

      await workout.tab(tester, 'Workout');
      await workout.activate(tester, 'workout-start');
      final plan = WorkoutPlan.forUser(workout.profile());
      for (var index = 1; index < plan.exercises.length; index++) {
        await workout.activate(tester, 'workout-step-next');
      }
      await visibleTap(tester, complete);
      expect(api.streakReads, [initial, initial]);
      expect(
        jsonDecode(api.history.single.details),
        hasLength(plan.exercises.length),
      );
      expect(api.history.single.durationMinutes, plan.durationMinutes);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await workout.tab(tester, 'Home');
      expect(
        tester
            .widget<DailyStreakIndicator>(find.byType(DailyStreakIndicator))
            .days,
        7,
      );
      expect(
        tester
            .widget<SegmentedProgressRing>(find.byType(SegmentedProgressRing))
            .progress,
        0,
      );

      api.failStreakRead = true;
      await workout.tab(tester, 'Workout');
      await workout.tab(tester, 'Home');
      expect(
        tester
            .widget<DailyStreakIndicator>(find.byType(DailyStreakIndicator))
            .unavailable,
        isTrue,
      );
      expect(
        find.descendant(
          of: find.byType(DailyStreakIndicator),
          matching: find.text('–'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('an earlier account cannot replace the current Home streak', (
    tester,
  ) async {
    final previous = Completer<int>();
    final first = FitApi()
      ..pendingStreak = previous.future
      ..restoredProfile = account();
    final second = FitApi()
      ..streak = 2
      ..restoredProfile = account(secondAccountId);

    Widget home(FitApi api) => app(
      HomeScreen(
        user: api.restoredProfile!,
        api: api,
        onLogout: () async {},
        onUpdateProfile: (_) {},
      ),
    );

    await tester.pumpWidget(home(first));
    await tester.pumpWidget(home(second));
    await tester.pumpAndSettle();
    previous.complete(19);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DailyStreakIndicator>(find.byType(DailyStreakIndicator))
          .days,
      2,
    );
  });

  testWidgets(
    'history loading, error retry, details, cancel and owned deletion',
    (tester) async {
      final api = FitApi();
      await tester.pumpWidget(
        app(
          HomeScreen(
            user: workout.profile(),
            api: api,
            onLogout: () async {},
            onUpdateProfile: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await workout.tab(tester, 'Workout');
      api.pendingHistory = Completer<List<CompletedWorkout>>();
      await tester.tap(find.byTooltip('Workout History'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      api.pendingHistory!.completeError(StateError('Unavailable'));
      await tester.pumpAndSettle();
      expect(find.text('Unable to load workout history.'), findsOneWidget);
      api.pendingHistory = null;
      api.history.add(sample());
      await visibleTap(tester, find.text('Try Again'));
      await visibleTap(tester, find.text('Full Body Strength'));
      expect(find.text('Planned duration: 26 minutes'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Full Body Strength'));
      await tester.pumpAndSettle();
      await visibleTap(tester, find.byTooltip('Delete selected workouts'));
      await visibleTap(tester, find.text('Cancel'));
      expect(api.deleted, isNull);
      await visibleTap(tester, find.byTooltip('Delete selected workouts'));
      expect(find.textContaining('Your streak stays as it is'), findsOneWidget);
      await visibleTap(
        tester,
        find.byKey(const ValueKey('confirm-delete-workouts')),
      );
      expect(api.deleted, [1]);
      expect(find.text('No completed workouts yet'), findsOneWidget);
      expect(find.text('1 workout deleted from your history.'), findsOneWidget);
      expect(api.recordedDays, isEmpty);
    },
  );

  testWidgets(
    'Profile password route validates confirmation and prevents duplicate submissions',
    (tester) async {
      final api = FitApi();
      await tester.pumpWidget(
        app(
          HomeScreen(
            user: workout.profile(),
            api: api,
            onLogout: () async {},
            onUpdateProfile: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await workout.tab(tester, 'Profile');
      await visibleTap(tester, find.text('Change Password'));

      await visibleTap(tester, updatePassword);
      expect(find.text('Enter your current password.'), findsOneWidget);
      await fillPassword(tester, 'sample-mismatch');
      await visibleTap(tester, updatePassword);
      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(api.passwordCalls, 0);

      final pending = Completer<void>();
      api.pendingPassword = pending.future;
      await fillPassword(tester, 'sample-new-value');
      await tester.ensureVisible(updatePassword);
      await tester.tap(updatePassword);
      await tester.tap(updatePassword);
      await tester.pump();
      expect(api.passwordCalls, 1);
      expect(
        find.text('Your password was changed successfully.'),
        findsNothing,
      );
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byType(ChangePasswordScreen), findsNothing);
      expect(
        find.text('Your password was changed successfully.'),
        findsOneWidget,
      );
      expect(api.signOutCalls, 0);
    },
  );

  for (final entry in {
    PasswordChangeFailure.incorrectCurrentPassword:
        'The current password is incorrect.',
    PasswordChangeFailure.policyViolation:
        'Choose a different password that meets the password requirements.',
  }.entries) {
    testWidgets('password form handles ${entry.key.name}', (tester) async {
      final api = FitApi()..passwordError = PasswordChangeException(entry.key);
      await tester.pumpWidget(app(ChangePasswordScreen(api: api)));
      await fillPassword(tester, 'sample-new-value');
      await visibleTap(tester, updatePassword);
      expect(find.text(entry.value), findsOneWidget);
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
      expect(
        find.text('Your password was changed successfully.'),
        findsNothing,
      );
    });
  }

  testWidgets('new routes follow a live platform brightness change', (
    tester,
  ) async {
    final dispatcher = tester.binding.platformDispatcher;
    addTearDown(dispatcher.clearPlatformBrightnessTestValue);
    final api = FitApi()..history.add(sample());

    for (final screen in [
      WorkoutHistoryScreen(api: api),
      ChangePasswordScreen(api: api),
    ]) {
      dispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpWidget(app(screen, mode: ThemeMode.system));
      await tester.pumpAndSettle();
      final content = screen is ChangePasswordScreen
          ? DigiGymGlassField
          : ListTile;
      expect(
        Theme.of(tester.element(find.byType(content).first)).brightness,
        Brightness.light,
      );
      dispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(content).first)).brightness,
        Brightness.dark,
      );
    }
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'FIT-115 history and password ${platform.name} ${mode.name}',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(430, 932);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);

          final api = FitApi()..history.add(sample());
          for (final (tab, route, name) in [
            ('Workout', find.byTooltip('Workout History'), 'workout_history'),
            (
              'Profile',
              find.byKey(const ValueKey('profile-change-password')),
              'change_password',
            ),
          ]) {
            await tester.pumpWidget(
              app(
                HomeScreen(
                  user: workout.profile(),
                  api: api,
                  onLogout: () async {},
                  onUpdateProfile: (_) {},
                ),
                platform: platform,
                mode: mode,
              ),
            );
            await tester.pumpAndSettle();
            await workout.tab(tester, tab);
            await visibleTap(tester, route);
            if (name == 'change_password') {
              final brand = tester.widget<DigiGymBrandLogo>(
                find.byType(DigiGymBrandLogo),
              );
              final logoContext = tester.element(find.byType(DigiGymBrandLogo));
              await tester.runAsync(
                () => precacheImage(
                  AssetImage(
                    mode == ThemeMode.light
                        ? DigiGymBrandLogo.lightFormAsset
                        : DigiGymBrandLogo.assetName(
                            brand.layout,
                            Brightness.dark,
                          ),
                  ),
                  logoContext,
                ),
              );
              await tester.pumpAndSettle();
            }
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile(
                'goldens/fit115_${name}_${mode.name}_${platform.name}.png',
              ),
            );
            await tester.pageBack();
            await tester.pumpAndSettle();
          }
        },
      );
    }
  }
}
