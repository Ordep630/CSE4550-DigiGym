import '../models/user_profile.dart';
import '../models/workout_plan.dart';
import '../models/workout_schedule_day.dart';

/// A derived local calendar assignment, never a completion or backend record.
class AssignedWorkoutDay {
  final DateTime date;
  final bool configured;
  final bool isWorkout;
  final WorkoutPlan? plan;
  const AssignedWorkoutDay({
    required this.date,
    required this.configured,
    required this.isWorkout,
    this.plan,
  });

  WorkoutScheduleDay get presentation => WorkoutScheduleDay(
    date: date,
    workoutType: configured && isWorkout
        ? plan?.workoutType ?? ScheduledWorkoutType.fullBody
        : null,
    isRestDay: configured && !isWorkout,
  );
}

abstract final class WorkoutScheduling {
  static List<DateTime> weekDates(DateTime date) {
    final local = date.toLocal();
    final sunday = DateTime(
      local.year,
      local.month,
      local.day - local.weekday % 7,
    );
    return List.generate(
      7,
      (i) => DateTime(sunday.year, sunday.month, sunday.day + i),
    );
  }

  static List<AssignedWorkoutDay> week({
    required UserProfile user,
    required Set<int>? workoutDays,
    required DateTime date,
  }) {
    final primary = WorkoutPlan.forUser(user);
    final alternatives = WorkoutPlan.alternativesForUser(user);
    final strength = [
      if (primary.fitsTimeBudget) primary,
      ...alternatives.where((plan) => !plan.isRecovery),
    ];
    final recovery = alternatives.where((plan) => plan.isRecovery).firstOrNull;
    var strengthIndex = 0;
    // Respect Saturday-to-Sunday adjacency in this repeating weekly pattern.
    var previousStrength = workoutDays?.contains(6) ?? false;
    return List.unmodifiable(
      weekDates(date).asMap().entries.map((entry) {
        final scheduled = workoutDays?.contains(entry.key) ?? false;
        WorkoutPlan? plan;
        if (scheduled) {
          plan = previousStrength && recovery != null
              ? recovery
              : strength.isEmpty
              ? recovery
              : strength[strengthIndex++ % strength.length];
        }
        previousStrength = scheduled && plan != null && !plan.isRecovery;
        return AssignedWorkoutDay(
          date: entry.value,
          configured: workoutDays != null,
          isWorkout: scheduled,
          plan: plan,
        );
      }),
    );
  }
}
