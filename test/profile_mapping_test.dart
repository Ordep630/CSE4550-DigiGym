import 'package:digigym/models/profile_mapping.dart';
import 'package:digigym_backend_client/digigym_backend_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fitness level mapping', () {
    test('maps every frontend value to its backend enum', () {
      expect(fitnessLevelToBackend('Beginner'), FitnessLevel.beginner);
      expect(fitnessLevelToBackend('Intermediate'), FitnessLevel.intermediate);
      expect(fitnessLevelToBackend('Advanced'), FitnessLevel.advanced);
    });

    test('maps every backend enum to its frontend value', () {
      expect(fitnessLevelFromBackend(FitnessLevel.beginner), 'Beginner');
      expect(
        fitnessLevelFromBackend(FitnessLevel.intermediate),
        'Intermediate',
      );
      expect(fitnessLevelFromBackend(FitnessLevel.advanced), 'Advanced');
    });
  });

  group('fitness goal mapping', () {
    test('maps every supported frontend value to its backend enum', () {
      expect(fitnessGoalToBackend('Lose Weight'), FitnessGoal.loseWeight);
      expect(fitnessGoalToBackend('Build Muscle'), FitnessGoal.buildMuscle);
      expect(fitnessGoalToBackend('Gain Weight'), FitnessGoal.gainWeight);
      expect(
        fitnessGoalToBackend('Maintain Weight'),
        FitnessGoal.maintainWeight,
      );
    });

    test('maps every backend enum to its frontend value', () {
      expect(fitnessGoalFromBackend(FitnessGoal.loseWeight), 'Lose Weight');
      expect(fitnessGoalFromBackend(FitnessGoal.buildMuscle), 'Build Muscle');
      expect(fitnessGoalFromBackend(FitnessGoal.gainWeight), 'Gain Weight');
      expect(
        fitnessGoalFromBackend(FitnessGoal.maintainWeight),
        'Maintain Weight',
      );
    });

    test('rejects an unknown goal', () {
      expect(() => fitnessGoalToBackend('Unknown Goal'), throwsArgumentError);
    });
  });

  test('converts a backend profile without retaining a password', () {
    final backendProfile = DigiGymUser(
      authUserId: UuidValue.withValidation(
        '123e4567-e89b-12d3-a456-426614174000',
      ),
      name: 'Test User',
      age: 28,
      height: 172,
      weight: 68,
      fitnessLevel: FitnessLevel.intermediate,
      fitnessGoal: FitnessGoal.buildMuscle,
      workoutTime: 45,
      dietaryPreference: 'Vegetarian',
      bodyType: 'Athletic',
    );

    final profile = userProfileFromBackend(
      backendProfile,
      email: 'test@example.com',
    );

    expect(profile.name, 'Test User');
    expect(profile.email, 'test@example.com');
    expect(profile.fitnessLevel, 'Intermediate');
    expect(profile.fitnessGoal, 'Build Muscle');
  });
}
