import 'dart:convert';

import 'workout_plan.dart';

typedef WorkoutExerciseDetails = ({
  String name,
  String? sets,
  String? description,
});

/// Versioned workout details carried by the existing Serverpod text field.
/// The server's durationMinutes always means planned minutes.
class WorkoutRecordDetails {
  final String? sessionId;
  final Duration? activeTime;
  final int? plannedSeconds;

  /// Calories burned, frozen at save time with the user's weight then. Absent
  /// on workouts saved before the calorie tracker existed.
  final double? caloriesBurned;
  final List<WorkoutExerciseDetails> exercises;

  const WorkoutRecordDetails({
    this.sessionId,
    this.activeTime,
    this.plannedSeconds,
    this.caloriesBurned,
    this.exercises = const [],
  });

  static List<WorkoutExerciseDetails> snapshot(WorkoutPlan plan) =>
      List.unmodifiable([
        for (final exercise in plan.exercises)
          (
            name: exercise.name,
            sets: exercise.sets,
            description: exercise.description,
          ),
      ]);

  Map<String, Object?> toJson() => {
    'version': 1,
    'sessionId': sessionId,
    'activeMilliseconds': activeTime?.inMilliseconds,
    'plannedSeconds': plannedSeconds,
    'caloriesBurned': caloriesBurned,
    'exercises': [
      for (final exercise in exercises)
        {
          'name': exercise.name,
          'sets': exercise.sets,
          'description': exercise.description,
        },
    ],
  };

  factory WorkoutRecordDetails.decode(String source) {
    try {
      return WorkoutRecordDetails.fromJson(jsonDecode(source));
    } on FormatException {
      return const WorkoutRecordDetails();
    }
  }

  factory WorkoutRecordDetails.fromJson(Object? value) {
    final versioned = value is Map && value['version'] == 1 ? value : null;
    final rawExercises = versioned?['exercises'] ?? value;
    final elapsed = versioned?['activeMilliseconds'];
    final planned = versioned?['plannedSeconds'];
    final id = versioned?['sessionId'];
    final calories = versioned?['caloriesBurned'];
    return WorkoutRecordDetails(
      sessionId: id is String ? id : null,
      activeTime: elapsed is int && elapsed >= 0
          ? Duration(milliseconds: elapsed)
          : null,
      plannedSeconds: planned is int && planned > 0 ? planned : null,
      caloriesBurned: calories is num && calories.isFinite && calories >= 0
          ? calories.toDouble()
          : null,
      exercises: List.unmodifiable([
        if (rawExercises is List)
          for (final entry in rawExercises)
            if (entry is Map)
              (
                name: (entry['name'] ?? 'Exercise').toString(),
                sets: entry['sets']?.toString(),
                description: entry['description']?.toString(),
              ),
      ]),
    );
  }
}

/// Calendar dates follow the device's time zone at display time.
DateTime workoutLocalDate(DateTime time) {
  final local = time.toLocal();
  return DateTime(local.year, local.month, local.day);
}

String formatWorkoutTime(Duration duration) {
  String two(int value) => value.toString().padLeft(2, '0');
  final seconds = two(duration.inSeconds % 60);
  if (duration.inHours == 0) return '${two(duration.inMinutes)}:$seconds';
  return '${duration.inHours}:${two(duration.inMinutes % 60)}:$seconds';
}
