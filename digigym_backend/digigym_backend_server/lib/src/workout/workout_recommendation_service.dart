import '../generated/protocol.dart';

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

  String _getWorkoutType(FitnessGoal fitnessGoal) {
    // Selects a workout type based on the user's fitness goal.
    switch (fitnessGoal) {
      case FitnessGoal.loseWeight:
        return 'cardio';
      case FitnessGoal.buildMuscle:
        return 'strength';
      case FitnessGoal.gainWeight:
        return 'strength';
    }
  }

  String _getDifficulty(FitnessLevel fitnessLevel) {
    // Matches workout difficulty to the user's fitness level.
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
