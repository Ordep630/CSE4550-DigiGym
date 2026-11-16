import 'package:digigym/models/workout_plan.dart';
import 'package:digigym/models/workout_record_details.dart';
import 'package:digigym/services/workout_session_controller.dart';
import 'package:digigym_backend_client/digigym_backend_client.dart'
    show CompletedWorkout;
import 'package:flutter_test/flutter_test.dart';

import 'fit_115_flows_test.dart'
    show FitApi, account, accountId, secondAccountId;
import 'support/memory_schedule_storage.dart';
import 'workouts_screen_test.dart' show profile;

class LostReplyApi extends FitApi {
  @override
  Future<CompletedWorkout> completeWorkout({
    required String workoutName,
    required int durationMinutes,
    required String details,
  }) async {
    await super.completeWorkout(
      workoutName: workoutName,
      durationMinutes: durationMinutes,
      details: details,
    );
    throw StateError('The response was lost after the insert');
  }
}

void main() {
  final plan = WorkoutPlan.forUser(profile());

  test(
    'monotonic time excludes pauses and survives background and restart',
    () async {
      final api = FitApi();
      final storage = MemoryScheduleStorage();
      var now = Duration.zero;
      final first = WorkoutSessionController(
        accountId: accountId,
        api: api,
        storage: storage,
        monotonicNow: () => now,
      );
      await first.initialize();
      first.start(plan);
      now += const Duration(seconds: 7, milliseconds: 120);
      first.start(WorkoutPlan.alternativesForUser(profile()).first);
      expect(first.title, plan.title);
      first.pause();
      now += const Duration(minutes: 4);
      expect(first.elapsed, const Duration(seconds: 7, milliseconds: 120));
      first.resume();
      first.foregroundChanged(foreground: false);
      now += const Duration(seconds: 13);
      first.foregroundChanged(foreground: true);
      expect(first.elapsed, const Duration(seconds: 20, milliseconds: 120));
      await first.prepareLogout();
      first.dispose();

      now = Duration.zero;
      final reloaded = WorkoutSessionController(
        accountId: accountId,
        api: api,
        storage: storage,
        monotonicNow: () => now,
      );
      addTearDown(reloaded.dispose);
      await reloaded.initialize();
      expect(reloaded.phase, WorkoutSessionPhase.paused);
      expect(reloaded.elapsed, const Duration(seconds: 20, milliseconds: 120));
      expect(reloaded.exercises, WorkoutRecordDetails.snapshot(plan));

      reloaded.resume();
      now = const Duration(seconds: 3);
      reloaded.foregroundChanged(foreground: false);
      await reloaded.retryStorage(); // Wait for the background checkpoint.
      expect(reloaded.elapsed, const Duration(seconds: 23, milliseconds: 120));
      final afterKill = WorkoutSessionController(
        accountId: accountId,
        api: api,
        storage: storage,
        monotonicNow: () => Duration.zero,
      );
      addTearDown(afterKill.dispose);
      await afterKill.initialize();
      expect(afterKill.phase, WorkoutSessionPhase.paused);
      expect(afterKill.elapsed, const Duration(seconds: 23, milliseconds: 120));
    },
  );

  test('storage and commands are scoped to the signed-in account', () async {
    final api = FitApi();
    final storage = MemoryScheduleStorage();
    final original = WorkoutSessionController(
      accountId: accountId,
      api: api,
      storage: storage,
    );
    addTearDown(original.dispose);
    await original.initialize();
    original.start(plan);
    await original.prepareLogout();

    api.restoredProfile = account(secondAccountId);
    final other = WorkoutSessionController(
      accountId: secondAccountId,
      api: api,
      storage: storage,
    );
    addTearDown(other.dispose);
    await other.initialize();
    expect(other.phase, isNull);
    await original.finish();
    expect(api.completionCalls, 0);
    other.start(plan);
    expect(await other.discard(), isTrue);
    expect(other.phase, isNull);
    expect(storage.values.keys.single, endsWith(accountId));
  });

  test(
    'a lost save is reconciled after restart without a duplicate insert',
    () async {
      final api = LostReplyApi();
      final storage = MemoryScheduleStorage();
      var now = Duration.zero;
      final first = WorkoutSessionController(
        accountId: accountId,
        api: api,
        storage: storage,
        monotonicNow: () => now,
      );
      await first.initialize();
      first.start(plan);
      now = const Duration(seconds: 37, milliseconds: 420);
      await Future.wait([first.finish(), first.finish()]);
      expect(first.phase, WorkoutSessionPhase.unconfirmed);
      expect(api.completionCalls, 1);
      expect(api.recordedDays, isEmpty);
      expect(first.history.value, isEmpty);
      first.dispose();

      final restored = WorkoutSessionController(
        accountId: accountId,
        api: api,
        storage: storage,
      );
      addTearDown(restored.dispose);
      await restored.initialize();
      expect(restored.phase, WorkoutSessionPhase.unconfirmed);
      await restored.finish();
      expect(api.completionCalls, 1);
      await restored.checkSave();
      expect(api.completionCalls, 1);
      expect(restored.phase, WorkoutSessionPhase.saved);
      expect(api.recordedDays, [api.history.single.completedAt]);
      final saved = restored.history.value.single;
      final details = WorkoutRecordDetails.decode(saved.details);
      expect(saved.durationMinutes, plan.durationMinutes);
      expect(details.plannedSeconds, plan.estimatedSeconds);
      expect(
        details.activeTime,
        const Duration(seconds: 37, milliseconds: 420),
      );
      expect(storage.values, isEmpty);
    },
  );

  test(
    'failure stays unconfirmed and local checkpoint failure prevents posting',
    () async {
      final api = FitApi()..saveError = StateError('Network unavailable');
      final storage = MemoryScheduleStorage();
      final session = WorkoutSessionController(
        accountId: accountId,
        api: api,
        storage: storage,
      );
      addTearDown(session.dispose);
      await session.initialize();
      session.start(plan);
      storage.writeError = StateError('Storage unavailable');
      await session.finish();
      expect(session.storageFailed, isTrue);
      expect(session.phase, WorkoutSessionPhase.paused);
      expect(api.completionCalls, 0);

      storage.writeError = null;
      await session.finish();
      expect(session.phase, WorkoutSessionPhase.unconfirmed);
      await session.checkSave();
      expect(api.completionCalls, 1);
      expect(api.recordedDays, isEmpty);
      expect(session.history.value, isEmpty);
      expect(await session.discard(), isTrue);
      expect(session.phase, isNull);
    },
  );

  test('streak retry survives restart after history is confirmed', () async {
    final api = FitApi()..failStreakWrite = true;
    final storage = MemoryScheduleStorage();
    final session = WorkoutSessionController(
      accountId: accountId,
      api: api,
      storage: storage,
    );
    await session.initialize();
    session.start(plan);
    await session.finish();
    expect(session.phase, WorkoutSessionPhase.saved);
    expect(session.streakPending, isTrue);
    session.dispose();

    final restarted = WorkoutSessionController(
      accountId: accountId,
      api: api,
      storage: storage,
    );
    addTearDown(restarted.dispose);
    await restarted.initialize();
    api.failStreakWrite = false;
    await restarted.retryStreak();
    expect(api.completionCalls, 1);
    expect(api.recordedDays, [
      api.history.single.completedAt,
      api.history.single.completedAt,
    ]);
    expect(restarted.streakPending, isFalse);
    expect(storage.values, isEmpty);
  });

  test('legacy details have exercises, with no fabricated elapsed time', () {
    final decoded = WorkoutRecordDetails.decode(
      '[{"name":"Squat","sets":"2 x 10"}]',
    );
    expect(decoded.exercises.single.name, 'Squat');
    expect(decoded.activeTime, isNull);
    expect(decoded.sessionId, isNull);
    expect(WorkoutRecordDetails.decode('broken').exercises, isEmpty);
  });

  test('UTC receipts group across device-local midnight', () {
    final before = DateTime(2026, 11, 18, 23, 59).toUtc();
    final after = DateTime(2026, 11, 19, 0, 1).toUtc();
    expect(workoutLocalDate(before), DateTime(2026, 11, 18));
    expect(workoutLocalDate(after), DateTime(2026, 11, 19));
    expect(after.difference(before), const Duration(minutes: 2));
  });
}
