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
    // Placeholder rules for workout recommendation until workout logic is finalized.
    /* Updated rules & logic will be implemented in the future. */
    if (fitnessGoal == FitnessGoal.loseWeight) {
      return 'cardio';
    }

    if (fitnessGoal == FitnessGoal.buildMuscle) {
      return 'strength';
    }

    return 'general_fitness';
  }

  String _getDifficulty(FitnessLevel fitnessLevel) {
    // Placeholder rules for difficulty until workout logic is finalized.
    /* Updated rules & logic will be implemented in the future. */
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
