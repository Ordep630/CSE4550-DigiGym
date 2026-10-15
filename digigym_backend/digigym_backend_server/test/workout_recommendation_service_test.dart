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
      name: 'test123',
      age: 21,
      height: 171.0,
      weight: 71.0,
      fitnessLevel: fitnessLevel,
      fitnessGoal: fitnessGoal,
      workoutTime: workoutTime,
      dietaryPreference: 'vegan',
      bodyType: 'fit',
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

  test('recommends strength for intermediate, buildMuscle user', () {
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

  test('recommends strength for advanced, gainWeight user', () {
    final user = createUser(
      fitnessLevel: FitnessLevel.advanced,
      fitnessGoal: FitnessGoal.gainWeight,
      workoutTime: 60,
    );

    final recommendation = service.recommend(user);

    expect(recommendation.workoutType, 'strength');
    expect(recommendation.difficulty, 'advanced');
    expect(recommendation.durationMinutes, 60);
  });

  /* // TODO: Implement 'FitnessGoal.maintainWeight' enum in workout_recommendation_service.dart and update the recommendation logic accordingly.
   test('recommends strength and cardio for maintainWeight user', () {
    final user = createUser(fitnessGoal: FitnessGoal.maintainWeight, fitnessLevel: FitnessLevel.intermediate, workoutTime: 30);
    final recommendation = service.recommend(user);
    expect(recommendation.workoutType, 'strength and cardio');


   } );
   */
}

 
