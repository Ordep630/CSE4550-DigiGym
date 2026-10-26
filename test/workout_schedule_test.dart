import 'dart:async';
import 'dart:convert';

import 'package:digigym/models/user_profile.dart';
import 'package:digigym/models/workout_plan.dart';
import 'package:digigym/services/workout_schedule_controller.dart';
import 'package:digigym/services/workout_scheduling.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_schedule_storage.dart';

const accountA = '123e4567-e89b-12d3-a456-426614174000';
const accountB = '123e4567-e89b-12d3-a456-426614174001';
UserProfile scheduleUser({
  String level = 'Intermediate',
  String goal = 'Build Muscle',
  int minutes = 30,
}) => UserProfile(
  accountId: accountA,
  name: 'Test',
  email: 'test@example.com',
  fitnessLevel: level,
  fitnessGoal: goal,
  workoutTime: minutes,
);

void main() {
  test(
    'missing schedule stays unconfigured, including seven neutral dates',
    () async {
      final storage = MemoryScheduleStorage();
      final controller = WorkoutScheduleController(
        accountId: accountA,
        storage: storage,
      );
      await controller.initialize();
      expect(controller.configured, isFalse);
      expect(controller.workoutDays, isNull);
      final week = WorkoutScheduling.week(
        user: scheduleUser(),
        workoutDays: controller.workoutDays,
        date: DateTime(2026, 10, 31),
      );
      expect(week, hasLength(7));
      expect(week.first.date.weekday, DateTime.sunday);
      expect(week.last.date.weekday, DateTime.saturday);
      expect(
        week.every(
          (day) =>
              !day.configured &&
              day.plan == null &&
              !day.presentation.isRestDay,
        ),
        isTrue,
      );
      expect(storage.writes, 0);
      controller.dispose();
    },
  );

  test(
    'saved weekdays survive disposal logout and restart, separately by UUID',
    () async {
      final storage = MemoryScheduleStorage();
      final a = WorkoutScheduleController(
        accountId: accountA,
        storage: storage,
      );
      await a.initialize();
      expect(await a.save({0, 2, 6}), isTrue);
      expect(() => a.workoutDays!.clear(), throwsUnsupportedError);
      final key = a.storageKey!;
      expect(jsonDecode(storage.values[key]!), {
        'version': 1,
        'workoutDays': [0, 2, 6],
      });
      a.dispose();
      expect(a.workoutDays, isNull);
      final b = WorkoutScheduleController(
        accountId: accountB,
        storage: storage,
      );
      await b.initialize();
      expect(b.configured, isFalse);
      expect(await b.save({}), isTrue);
      expect(b.configured, isTrue);
      expect(b.workoutDays, isEmpty);
      b.dispose();
      final restored = WorkoutScheduleController(
        accountId: accountA,
        storage: storage,
      );
      await restored.initialize();
      expect(restored.workoutDays, {0, 2, 6});
      expect(storage.values, hasLength(2));
      expect(storage.values.keys.every((key) => !key.contains('@')), isTrue);
      expect(
        storage.values.values.every((value) => !value.contains('password')),
        isTrue,
      );
      restored.dispose();
    },
  );

  for (final raw in [
    'broken',
    '[]',
    '{"version":2,"workoutDays":[1]}',
    '{"version":1,"workoutDays":[-1]}',
    '{"version":1,"workoutDays":[7]}',
    '{"version":1,"workoutDays":[1,1]}',
    '{"version":1,"workoutDays":["1"]}',
  ]) {
    test('malformed or outdated data is unconfigured: $raw', () async {
      final storage = MemoryScheduleStorage();
      final controller = WorkoutScheduleController(
        accountId: accountA,
        storage: storage,
      );
      storage.values[controller.storageKey!] = raw;
      await controller.initialize();
      expect(controller.configured, isFalse);
      expect(controller.error, isNotNull);
      expect(await controller.save({3}), isTrue);
      expect(controller.workoutDays, {3});
      controller.dispose();
    });
  }

  test(
    'read failure blocks overwriting unknown data and supports retry',
    () async {
      final storage = MemoryScheduleStorage()
        ..readError = StateError('unavailable');
      final controller = WorkoutScheduleController(
        accountId: accountA,
        storage: storage,
      );
      await controller.initialize();
      expect(controller.error, isNotNull);
      expect(await controller.save({1}), isFalse);
      expect(storage.writes, 0);
      storage.readError = null;
      await controller.reload();
      expect(await controller.save({1}), isTrue);
      controller.dispose();
    },
  );

  test('save failure retains the previous choice and permits retry', () async {
    final storage = MemoryScheduleStorage();
    final controller = WorkoutScheduleController(
      accountId: accountA,
      storage: storage,
    );
    await controller.initialize();
    await controller.save({1, 3});
    storage.writeError = StateError('unavailable');
    expect(await controller.save({2, 4}), isFalse);
    expect(controller.workoutDays, {1, 3});
    storage.writeError = null;
    expect(await controller.save({2, 4}), isTrue);
    expect(controller.workoutDays, {2, 4});
    controller.dispose();
  });

  test('bounded storage reads and writes fail safely without credentials or account fallback', () async {
    final never = Completer<void>();
    final storage = MemoryScheduleStorage()..readWait = never.future;
    final controller = WorkoutScheduleController(
      accountId: accountA,
      storage: storage,
      storageTimeout: const Duration(milliseconds: 10),
    );
    await controller.initialize();
    expect(controller.loading, isFalse);
    expect(controller.canEdit, isFalse);
    never.complete();
    storage.readWait = null;
    await controller.reload();
    final slowWrite = Completer<void>();
    storage.writeWait = slowWrite.future;
    expect(await controller.save({0}), isFalse);
    expect(controller.configured, isFalse);
    slowWrite.complete();
    storage.writeWait = null;
    expect(await controller.save({6}), isTrue);
    expect(jsonDecode(storage.values[controller.storageKey!]!)['workoutDays'], [
      6,
    ]);
    controller.dispose();
    final anonymous = WorkoutScheduleController(
      accountId: null,
      storage: storage,
    );
    final reads = storage.reads;
    await anonymous.initialize();
    expect(anonymous.storageKey, isNull);
    expect(await anonymous.save({0}), isFalse);
    expect(storage.reads, reads);
    anonymous.dispose();
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
