import 'package:test/test.dart';
import 'package:uuid/uuid_value.dart';
import 'package:digigym_backend_server/src/generated/protocol.dart';
import 'package:digigym_backend_server/src/workout/workout_recommendation_service.dart';

void main() {
  late WorkoutRecommendationService service;

  setUp(() {
    service = WorkoutRecommendationService();
  });

  DigiGymUser createProfile({
    FitnessLevel fitnessLevel = FitnessLevel.beginner,
    FitnessGoal fitnessGoal = FitnessGoal.loseWeight,
    int workoutTime = 30,
  }) {
    return DigiGymUser(
      authUserId: UuidValue.fromString(
        '550e8400-e29b-41d4-a716-446655440000',
      ),
      name: 'Test User',
      age: 20,
      height: 170,
      weight: 70,
      fitnessLevel: fitnessLevel,
      fitnessGoal: fitnessGoal,
      workoutTime: workoutTime,
      dietaryPreference: 'No Preference',
      bodyType: 'Average',
    );
  }

  group('WorkoutRecommendationService', () {
    test('recommends cardio for weight loss', () {
      final profile = createProfile(
        fitnessGoal: FitnessGoal.loseWeight,
      );

      final recommendation = service.recommend(profile);

      expect(recommendation.workoutType, 'cardio');
    });

    test('recommends strength training for building muscle', () {
      final profile = createProfile(
        fitnessGoal: FitnessGoal.buildMuscle,
      );

      final recommendation = service.recommend(profile);

      expect(recommendation.workoutType, 'strength');
    });

    test('recommends strength training for gaining weight', () {
      final profile = createProfile(
        fitnessGoal: FitnessGoal.gainWeight,
      );

      final recommendation = service.recommend(profile);

      expect(recommendation.workoutType, 'strength');
    });

    test('recommends balanced workouts for maintaining weight', () {
      final profile = createProfile(
        fitnessGoal: FitnessGoal.maintainWeight,
        fitnessLevel: FitnessLevel.intermediate,
        workoutTime: 45,
      );

      final recommendation = service.recommend(profile);

      expect(recommendation.workoutType, 'balanced');
      expect(recommendation.difficulty, 'intermediate');
      expect(recommendation.durationMinutes, 45);
    });

    test('matches beginner fitness level to beginner difficulty', () {
      final profile = createProfile(
        fitnessLevel: FitnessLevel.beginner,
      );

      final recommendation = service.recommend(profile);

      expect(recommendation.difficulty, 'beginner');
    });

    test('matches intermediate fitness level to intermediate difficulty', () {
      final profile = createProfile(
        fitnessLevel: FitnessLevel.intermediate,
      );

      final recommendation = service.recommend(profile);

      expect(recommendation.difficulty, 'intermediate');
    });

    test('matches advanced fitness level to advanced difficulty', () {
      final profile = createProfile(
        fitnessLevel: FitnessLevel.advanced,
      );

      final recommendation = service.recommend(profile);

      expect(recommendation.difficulty, 'advanced');
    });

    test('preserves the workout duration from the user profile', () {
      final profile = createProfile(workoutTime: 45);

      final recommendation = service.recommend(profile);

      expect(recommendation.durationMinutes, 45);
    });

    test('combines goal, fitness level, and duration correctly', () {
      final profile = createProfile(
        fitnessLevel: FitnessLevel.intermediate,
        fitnessGoal: FitnessGoal.buildMuscle,
        workoutTime: 45,
      );

      final recommendation = service.recommend(profile);

      expect(recommendation.workoutType, 'strength');
      expect(recommendation.difficulty, 'intermediate');
      expect(recommendation.durationMinutes, 45);
    });
  });
}
