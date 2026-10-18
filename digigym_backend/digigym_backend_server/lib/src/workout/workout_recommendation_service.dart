import '../generated/protocol.dart';

/// Generates a workout recommendation from a user's fitness profile.
class WorkoutRecommendationService {
  WorkoutRecommendation recommend(DigiGymUser user) {
    final workoutType = _getWorkoutType(user.fitnessGoal);
    final difficulty = _getDifficulty(user.fitnessLevel);

    return WorkoutRecommendation(
      workoutType: workoutType,
      durationMinutes: user.workoutTime,
      difficulty: difficulty,
    );
  }
  /// Selects a workout category based on the user's fitness goal.
  String _getWorkoutType(FitnessGoal fitnessGoal) {
    switch (fitnessGoal) {
      case FitnessGoal.loseWeight:
        return 'cardio';
      case FitnessGoal.buildMuscle:
        return 'strength';
      case FitnessGoal.gainWeight:
        return 'strength';
      case FitnessGoal.maintainWeight:
        return 'balanced';
    }
  }

  /// Matches the recommendation difficulty to the user's fitness level.
  String _getDifficulty(FitnessLevel fitnessLevel) {
    switch (fitnessLevel) {
      case FitnessLevel.beginner:
        return 'beginner';
      case FitnessLevel.intermediate:
        return 'intermediate';
      case FitnessLevel.advanced:
        return 'advanced';
    }
  }
}
