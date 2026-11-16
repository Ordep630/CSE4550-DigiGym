import 'package:flutter/material.dart' show DateUtils;

/// Dated presentation of shared scheduling data. Completion is always explicit.
enum ScheduledWorkoutType {
  upperBody,
  lowerBody,
  fullBody,
  cardio,
  core,
  push,
  pull,
}

class WorkoutScheduleDay {
  /// Device-local calendar date; time-of-day is deliberately discarded.
  final DateTime date;
  final ScheduledWorkoutType? workoutType;
  final bool isRestDay;
  final bool isCompleted;

  /// Explicit schedule result only; a missing record is never a missed workout.
  final bool isMissed;

  WorkoutScheduleDay({
    required DateTime date,
    this.workoutType,
    this.isRestDay = false,
    this.isCompleted = false,
    this.isMissed = false,
  }) : date = DateUtils.dateOnly(date.toLocal()),
       assert(!isRestDay || workoutType == null),
       assert(!isMissed || (workoutType != null && !isCompleted));
}
