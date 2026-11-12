import 'dart:async';

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/models/workout_plan.dart';
import 'package:digigym/services/workout_schedule_controller.dart';
import 'package:digigym/services/workout_scheduling.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_digigym_api.dart';

const accountA = '123e4567-e89b-12d3-a456-426614174000';
const accountB = '123e4567-e89b-12d3-a456-426614174001';

UserProfile scheduleUser({
  String accountId = accountA,
  String level = 'Intermediate',
  String goal = 'Build Muscle',
  int minutes = 30,
}) => UserProfile(
  accountId: accountId,
  name: 'Test User',
  email: 'test@example.com',
  age: 28,
  height: 172,
  weight: 68,
  fitnessLevel: level,
  fitnessGoal: goal,
  workoutTime: minutes,
  dietaryPreference: 'Vegetarian',
  bodyType: 'Athletic',
);

FakeDigiGymApi authenticatedApi(String accountId) {
  return FakeDigiGymApi()
    ..authenticated = true
    ..restoredProfile = scheduleUser(accountId: accountId);
}

void main() {
  test('missing server schedule remains unconfigured', () async {
    final api = authenticatedApi(accountA);
    final controller = WorkoutScheduleController(accountId: accountA, api: api);

    await controller.initialize();

    expect(controller.loading, isFalse);
    expect(controller.configured, isFalse);
    expect(controller.workoutDays, isNull);
    expect(controller.error, isNull);
    expect(controller.canEdit, isTrue);

    controller.dispose();
  });

  test('server schedule persists and remains isolated by account', () async {
    final api = authenticatedApi(accountA);
    final firstController = WorkoutScheduleController(
      accountId: accountA,
      api: api,
    );

    await firstController.initialize();
    expect(firstController.configured, isFalse);

    expect(await firstController.save({0, 2, 6}), isTrue);
    expect(firstController.workoutDays, {0, 2, 6});
    expect(api.workoutSchedules[accountA], [0, 2, 6]);

    expect(() => firstController.workoutDays!.add(4), throwsUnsupportedError);

    firstController.dispose();

    // Simulate signing out of account A and signing in to account B.
    api.authenticated = false;
    api.restoredProfile = scheduleUser(accountId: accountB);
    api.authenticated = true;

    final secondController = WorkoutScheduleController(
      accountId: accountB,
      api: api,
    );

    await secondController.initialize();

    // Account B has no saved schedule.
    expect(secondController.configured, isFalse);
    expect(secondController.workoutDays, isNull);

    // An empty list is a deliberate saved choice, not an unconfigured state.
    expect(await secondController.save({}), isTrue);
    expect(secondController.configured, isTrue);
    expect(secondController.workoutDays, isEmpty);
    expect(api.workoutSchedules[accountB], isEmpty);

    secondController.dispose();

    // Sign back in to account A and verify its original schedule is intact.
    api.authenticated = false;
    api.restoredProfile = scheduleUser(accountId: accountA);
    api.authenticated = true;

    final restoredController = WorkoutScheduleController(
      accountId: accountA,
      api: api,
    );

    await restoredController.initialize();

    expect(restoredController.configured, isTrue);
    expect(restoredController.workoutDays, {0, 2, 6});
    expect(api.workoutSchedules[accountA], [0, 2, 6]);
    expect(api.workoutSchedules[accountB], isEmpty);

    restoredController.dispose();
  });

  test(
    'invalid server data blocks editing until a successful reload',
    () async {
      final api = authenticatedApi(accountA);

      for (final invalidDays in [
        [-1],
        [7],
        [1, 1],
      ]) {
        api.workoutSchedules[accountA] = invalidDays;

        final controller = WorkoutScheduleController(
          accountId: accountA,
          api: api,
        );

        await controller.initialize();

        expect(controller.configured, isFalse);
        expect(controller.workoutDays, isNull);
        expect(controller.error, isNotNull);
        expect(controller.canEdit, isFalse);

        // Do not overwrite data that could not be read safely.
        expect(await controller.save({3}), isFalse);
        expect(api.workoutSchedules[accountA], invalidDays);

        // Once the backend data is valid, a reload should restore editing.
        api.workoutSchedules[accountA] = [3];
        await controller.reload();

        expect(controller.configured, isTrue);
        expect(controller.workoutDays, {3});
        expect(controller.canEdit, isTrue);

        controller.dispose();
      }
    },
  );

  test(
    'read failure blocks overwriting unknown data and supports retry',
    () async {
      final api = authenticatedApi(accountA)
        ..workoutSchedules[accountA] = [1, 3]
        ..scheduleReadError = StateError('Temporary read failure');

      final controller = WorkoutScheduleController(
        accountId: accountA,
        api: api,
      );

      await controller.initialize();

      expect(controller.loading, isFalse);
      expect(controller.error, isNotNull);
      expect(controller.canEdit, isFalse);
      expect(await controller.save({2, 4}), isFalse);
      expect(api.workoutSchedules[accountA], [1, 3]);

      api.scheduleReadError = null;
      await controller.reload();

      expect(controller.workoutDays, {1, 3});
      expect(controller.canEdit, isTrue);

      expect(await controller.save({2, 4}), isTrue);
      expect(api.workoutSchedules[accountA], [2, 4]);

      controller.dispose();
    },
  );

  test(
    'save failure retains the previous selection and permits retry',
    () async {
      final api = authenticatedApi(accountA)
        ..workoutSchedules[accountA] = [1, 3];

      final controller = WorkoutScheduleController(
        accountId: accountA,
        api: api,
      );

      await controller.initialize();

      expect(controller.workoutDays, {1, 3});

      api.scheduleWriteError = StateError('Temporary write failure');

      expect(await controller.save({2, 4}), isFalse);
      expect(controller.workoutDays, {1, 3});
      expect(api.workoutSchedules[accountA], [1, 3]);
      expect(controller.error, isNotNull);

      api.scheduleWriteError = null;

      expect(await controller.save({2, 4}), isTrue);
      expect(controller.workoutDays, {2, 4});
      expect(api.workoutSchedules[accountA], [2, 4]);

      controller.dispose();
    },
  );

  test('timed-out writes remain ordered before newer saves', () async {
    final api = authenticatedApi(accountA);
    final controller = WorkoutScheduleController(
      accountId: accountA,
      api: api,
      requestTimeout: const Duration(milliseconds: 20),
    );

    await controller.initialize();

    final delayedWrite = Completer<void>();
    api.scheduleWriteWait = delayedWrite.future;

    // This request times out locally but remains pending at the API boundary.
    expect(await controller.save({0}), isFalse);

    expect(controller.workoutDays, isNull);
    expect(api.workoutSchedules.containsKey(accountA), isFalse);

    // Allow the delayed first write to finish.
    delayedWrite.complete();
    await delayedWrite.future;
    await Future<void>.delayed(Duration.zero);

    expect(api.workoutSchedules[accountA], [0]);

    // The next save must run after the delayed first write.
    api.scheduleWriteWait = null;

    expect(await controller.save({6}), isTrue);
    expect(controller.workoutDays, {6});
    expect(api.workoutSchedules[accountA], [6]);

    controller.dispose();
  });

  test('read timeout fails safely and a later reload can recover', () async {
    final api = authenticatedApi(accountA)..workoutSchedules[accountA] = [2, 5];

    final delayedRead = Completer<void>();
    api.scheduleReadWait = delayedRead.future;

    final controller = WorkoutScheduleController(
      accountId: accountA,
      api: api,
      requestTimeout: const Duration(milliseconds: 20),
    );

    await controller.initialize();

    expect(controller.loading, isFalse);
    expect(controller.configured, isFalse);
    expect(controller.canEdit, isFalse);
    expect(controller.error, isNotNull);

    delayedRead.complete();
    await delayedRead.future;

    api.scheduleReadWait = null;
    await controller.reload();

    expect(controller.configured, isTrue);
    expect(controller.workoutDays, {2, 5});
    expect(controller.canEdit, isTrue);

    controller.dispose();
  });

  test('anonymous or invalid account cannot load or save a schedule', () async {
    final api = FakeDigiGymApi();

    final anonymousController = WorkoutScheduleController(
      accountId: null,
      api: api,
    );

    await anonymousController.initialize();

    expect(anonymousController.canEdit, isFalse);
    expect(anonymousController.configured, isFalse);
    expect(await anonymousController.save({0}), isFalse);

    anonymousController.dispose();

    final invalidIdController = WorkoutScheduleController(
      accountId: 'not-an-account-id',
      api: authenticatedApi(accountA),
    );

    await invalidIdController.initialize();

    expect(invalidIdController.canEdit, isFalse);
    expect(invalidIdController.configured, isFalse);
    expect(await invalidIdController.save({0}), isFalse);

    invalidIdController.dispose();
  });

  test('schedule is deterministic and profile changes preserve choices while updating assignments', () {
    final user = scheduleUser();
    final selected = {0, 1, 3, 6};
    List<AssignedWorkoutDay> derive() => WorkoutScheduling.week(
      user: user,
      workoutDays: selected,
      date: DateTime(2026, 10, 31),
    );
    final first = derive();
    expect(
      derive().map((day) => day.plan?.title),
      first.map((day) => day.plan?.title),
    );
    expect(
      derive().map((day) => day.plan?.estimatedSeconds),
      first.map((day) => day.plan?.estimatedSeconds),
    );
    user.fitnessLevel = 'Beginner';
    user.fitnessGoal = 'Lose Weight';
    user.workoutTime = 15;
    final updated = derive();
    expect(
      updated
          .where((day) => day.isWorkout)
          .map((day) => day.date.weekday % 7)
          .toSet(),
      selected,
    );
    expect(
      updated
          .where((day) => day.plan != null)
          .every(
            (day) =>
                day.plan!.fitnessLevel == 'Beginner' &&
                day.plan!.fitnessGoal == 'Lose Weight' &&
                day.plan!.durationMinutes <= 15,
          ),
      isTrue,
    );
    expect(
      updated.every(
        (day) => !day.presentation.isCompleted && !day.presentation.isMissed,
      ),
      isTrue,
    );
  });

  test(
    'all-rest and seven-workout schedules are honest and recovery-aware',
    () {
      final user = scheduleUser();
      final rest = WorkoutScheduling.week(
        user: user,
        workoutDays: {},
        date: DateTime(2026, 10, 25),
      );
      expect(
        rest.every((day) => day.presentation.isRestDay && day.plan == null),
        isTrue,
      );
      final week = WorkoutScheduling.week(
        user: user,
        workoutDays: {0, 1, 2, 3, 4, 5, 6},
        date: DateTime(2026, 10, 25),
      );
      expect(
        week.every((day) => day.isWorkout && !day.presentation.isCompleted),
        isTrue,
      );
      expect(week.any((day) => day.plan!.isRecovery), isTrue);
      expect(week.any((day) => !day.plan!.isRecovery), isTrue);
      for (var i = 0; i < 7; i++) {
        expect(
          week[i].plan!.isRecovery || week[(i + 1) % 7].plan!.isRecovery,
          isTrue,
        );
      }
      final empty = WorkoutScheduling.week(
        user: scheduleUser(minutes: 1),
        workoutDays: {1},
        date: DateTime(2026, 10, 25),
      );
      expect(empty[1].isWorkout, isTrue);
      expect(empty[1].plan, isNull);
      expect(empty[1].presentation.isRestDay, isFalse);
    },
  );

  for (final level in ['Beginner', 'Intermediate', 'Advanced']) {
    for (final goal in [
      'Build Muscle',
      'Gain Weight',
      'Lose Weight',
      'Maintain Weight',
    ]) {
      test(
        '$level $goal alternatives preserve real prescriptions and time estimates',
        () {
          for (final time in [1, 5, 15, 30, 60, 125]) {
            final plans = WorkoutPlan.alternativesForUser(
              scheduleUser(level: level, goal: goal, minutes: time),
            );
            expect(
              plans.map((plan) => plan.title).toSet().length,
              plans.length,
            );
            for (final plan in plans) {
              expect(plan.fitsTimeBudget, isTrue);
              expect(plan.estimatedSeconds, lessThanOrEqualTo(time * 60));
              expect(plan.fitnessLevel, level);
              expect(plan.fitnessGoal, goal);
              expect(
                plan.exercises.every(
                  (e) => e.setCount > 0 && e.description.isNotEmpty,
                ),
                isTrue,
              );
              expect(
                plan.estimatedSeconds,
                180 +
                    plan.exercises.fold<int>(
                      0,
                      (sum, e) => sum + e.estimatedSeconds,
                    ) +
                    plan.exercises
                        .skip(1)
                        .fold<int>(0, (sum, e) => sum + e.transitionSeconds),
              );
            }
          }
        },
      );
    }
  }
}
