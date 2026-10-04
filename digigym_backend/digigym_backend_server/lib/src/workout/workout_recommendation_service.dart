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

  String _getWorkoutType(String fitnessGoal) {
    // Placeholder rules for workout recommendation until workout logic is finalized.
    if (fitnessGoal == 'lose_weight') {
      return 'cardio';
    }

    if (fitnessGoal == 'build_muscle') {
      return 'strength';
    }

    return 'general_fitness';
  }

  String _getDifficulty(String fitnessLevel) {
    // Placeholder rules for difficulty until workout logic is finalized.
    switch (fitnessLevel) {
      case 'beginner':
        return 'beginner';
      case 'intermediate':
        return 'intermediate';
      default:
        return 'beginner';
    }
  }
}
