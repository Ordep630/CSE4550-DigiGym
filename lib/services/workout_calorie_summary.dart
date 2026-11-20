import 'package:digigym_backend_client/digigym_backend_client.dart'
    show CompletedWorkout;

import '../models/workout_record_details.dart';

/// Calories from saved workouts on one local calendar day.
typedef DailyCalories = ({double calories, int workouts});

/// Derived entirely from saved history, so it is identical after reopening the
/// app and starts from zero on a new day without deleting anything.
DailyCalories caloriesBurnedOn(List<CompletedWorkout> history, DateTime day) {
  final target = workoutLocalDate(day);
  var calories = 0.0;
  var workouts = 0;
  for (final row in history) {
    if (workoutLocalDate(row.completedAt) != target) continue;
    workouts++;
    calories += WorkoutRecordDetails.decode(row.details).caloriesBurned ?? 0;
  }
  return (calories: calories, workouts: workouts);
}
