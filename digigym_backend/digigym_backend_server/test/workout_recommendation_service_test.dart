import 'package:digigym_backend_server/src/generated/protocol.dart';
import 'package:digigym_backend_server/src/workout/workout_recommendation_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  final service = WorkoutRecommendationService();

  DigiGymUser createUser({
    required FitnessLevel fitnessLevel,
    required FitnessGoal fitnessGoal,
    required int workoutTime,
  }) {
    return DigiGymUser(
      authUserId: UuidValue.withValidation(
        '123e4567-e89b-12d3-a456-426614174000',
      ),
      name: 'Test User',
      age: 25,
      height: 175.0,
      weight: 75.0,
      fitnessLevel: fitnessLevel,
      fitnessGoal: fitnessGoal,
      workoutTime: workoutTime,
      dietaryPreference: 'none',
      bodyType: 'average',
    );
  }

  test('recommends cardio for beginner lose_weight user', () {
    final user = createUser(
      fitnessLevel: FitnessLevel.beginner,
      fitnessGoal: FitnessGoal.loseWeight,
      workoutTime: 30,
    );

    final recommendation = service.recommend(user);

    expect(recommendation.workoutType, 'cardio');
    expect(recommendation.difficulty, 'beginner');
    expect(recommendation.durationMinutes, 30);
  });

  test('recommends strength for intermediate build_muscle user', () {
    final user = createUser(
      fitnessLevel: FitnessLevel.intermediate,
      fitnessGoal: FitnessGoal.buildMuscle,
      workoutTime: 45,
    );

    final recommendation = service.recommend(user);

    expect(recommendation.workoutType, 'strength');
    expect(recommendation.difficulty, 'intermediate');
    expect(recommendation.durationMinutes, 45);
  });
}
