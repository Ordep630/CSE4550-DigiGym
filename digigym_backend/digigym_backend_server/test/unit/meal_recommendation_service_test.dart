import 'package:serverpod/serverpod.dart';
import 'package:digigym_backend_server/src/generated/protocol.dart';
import 'package:digigym_backend_server/src/meal/meal_recommendation_service.dart';
import 'package:test/test.dart';

void main() {
  final service = MealRecommendationService();

  DigiGymUser createUser({
    FitnessGoal goal = FitnessGoal.maintainWeight,
    String dietaryPreference = 'No Preference',
  }) {
    return DigiGymUser(
      authUserId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
      name: 'Test User',
      age: 20,
      height: 170,
      weight: 70,
      fitnessLevel: FitnessLevel.beginner,
      fitnessGoal: goal,
      workoutTime: 30,
      dietaryPreference: dietaryPreference,
      bodyType: 'Average',
    );
  }

  group('MealRecommendationService', () {
    test('provides default meal suggestions', () {
      final result = service.recommend(createUser());

      expect(result.breakfast, contains('Eggs'));
      expect(result.lunch, contains('chicken'));
      expect(result.dinner, contains('salmon'));
      expect(result.snack, contains('yogurt'));
      expect(result.goal, 'Weight maintenance');
    });

    test('provides vegetarian meal suggestions', () {
      final result = service.recommend(
        createUser(dietaryPreference: 'Vegetarian'),
      );

      expect(result.breakfast, contains('Greek yogurt'));
      expect(result.lunch, contains('Bean'));
      expect(result.dinner, contains('tofu'));
      expect(result.snack, contains('nut butter'));
    });

    test('provides vegan meal suggestions', () {
      final result = service.recommend(
        createUser(dietaryPreference: 'Vegan'),
      );

      expect(result.breakfast, contains('Oatmeal'));
      expect(result.lunch, contains('Lentil'));
      expect(result.dinner, contains('Tofu'));
      expect(result.snack, contains('Hummus'));
    });

    test(
      'preserves unsupported dietary preferences without assuming foods',
      () {
        final result = service.recommend(
          createUser(dietaryPreference: 'Peanut allergy'),
        );

        expect(result.dietaryPreference, 'Peanut allergy');
        expect(result.lunch, contains('matching your dietary needs'));
        expect(result.dinner, contains('matching your dietary needs'));
      },
    );

    test('maps each fitness goal to a description', () {
      expect(
        service.recommend(createUser(goal: FitnessGoal.loseWeight)).goal,
        'Weight management',
      );
      expect(
        service.recommend(createUser(goal: FitnessGoal.buildMuscle)).goal,
        'Muscle building',
      );
      expect(
        service.recommend(createUser(goal: FitnessGoal.gainWeight)).goal,
        'Weight gain',
      );
      expect(
        service.recommend(createUser(goal: FitnessGoal.maintainWeight)).goal,
        'Weight maintenance',
      );
    });
  });
}
