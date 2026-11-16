import 'package:digigym/data/meal_data.dart';
import 'package:digigym/models/meal.dart';
import 'package:digigym/models/user_profile.dart';
import 'package:digigym/services/meal_recommendation_service.dart';
import 'package:flutter_test/flutter_test.dart';

UserProfile user(String goal, String diet) => UserProfile(
  name: 'Test',
  email: 'test@example.com',
  age: 31,
  height: 174,
  weight: 58,
  fitnessGoal: goal,
  dietaryPreference: diet,
);

void main() {
  const service = MealRecommendationService();
  const goals = [
    'Lose Weight',
    'Maintain Weight',
    'Gain Weight',
    'Build Muscle',
  ];
  const diets = ['No Preference', 'Vegetarian', 'Vegan', 'High Protein'];
  test('one complete catalogue has unique meal and consistent ingredient identities', () {
    expect(mealCatalog.length, inInclusiveRange(16, 24));
    expect(
      mealCatalog.map((meal) => meal.id).toSet().length,
      mealCatalog.length,
    );
    final ingredients = <String, FoodIngredient>{};
    for (final meal in mealCatalog) {
      expect(meal.name, isNotEmpty);
      expect(meal.description, isNotEmpty);
      expect(meal.serving, isNotEmpty);
      expect(meal.supportedGoals, isNotEmpty);
      expect(meal.ingredients, isNotEmpty);
      expect(meal.calories, greaterThan(0));
      expect(meal.proteinGrams, greaterThan(0));
      expect(meal.carbohydrateGrams, greaterThan(0));
      expect(meal.fatGrams, greaterThan(0));
      final energy =
          4 * meal.proteinGrams +
          4 * meal.carbohydrateGrams +
          9 * meal.fatGrams;
      expect((energy - meal.calories).abs() / meal.calories, lessThan(.20));
      for (final item in meal.ingredients) {
        expect(item.quantity.amount.isFinite, isTrue);
        expect(item.quantity.amount, greaterThan(0));
        expect(item.quantity.label, contains('oz'));
        expect(item.ingredient.id, isNotEmpty);
        expect(item.ingredient.name, isNotEmpty);
        final previous = ingredients[item.ingredient.id];
        if (previous != null) {
          expect(identical(previous, item.ingredient), isTrue);
        }
        ingredients[item.ingredient.id] = item.ingredient;
      }
    }
  });
  for (final goal in goals) {
    for (final diet in diets) {
      test(
        'saved $goal and $diet produce deterministic compatible options',
        () {
          final profile = user(goal, diet);
          final recommendations = service.recommend(profile);
          expect(recommendations, hasLength(3));
          expect(
            recommendations.map((meal) => meal.id),
            service.recommend(profile).map((meal) => meal.id),
          );
          for (final meal in recommendations) {
            expect(meal.supportedGoals, contains(goal));
            expect(meal.compatibleDiets, contains(diet));
            if (diet == 'Vegetarian' || diet == 'Vegan') {
              expect(
                meal.ingredients.map((item) => item.ingredient.id),
                isNot(
                  anyElement(
                    isIn(['chicken-cooked', 'salmon-cooked', 'tuna-drained']),
                  ),
                ),
              );
            }
            if (diet == 'Vegan') {
              expect(
                meal.ingredients.map((item) => item.ingredient.id),
                isNot(anyElement(isIn(['greek-yogurt', 'eggs']))),
              );
            }
            if (diet == 'High Protein') {
              expect(meal.proteinGrams, greaterThanOrEqualTo(25));
              expect(
                meal.nutrition.proteinGrams * 4 / meal.nutrition.calories,
                greaterThanOrEqualTo(.20),
              );
            }
          }
          expect(() => recommendations.clear(), throwsUnsupportedError);
        },
      );
    }
  }
  test('profile changes alter recommendations and unknown diets never fall back to meat', () {
    final profile = user('Build Muscle', 'No Preference');
    final original = service.recommend(profile).map((meal) => meal.id).toList();
    profile.fitnessGoal = 'Lose Weight';
    expect(
      service.recommend(profile).map((meal) => meal.id).toList(),
      isNot(original),
    );
    profile.dietaryPreference = 'Vegan';
    expect(service.recommend(profile).every((meal) => meal.vegan), isTrue);
    profile.dietaryPreference = 'Unsupported';
    expect(service.recommend(profile), isEmpty);
    expect(
      const MealRecommendationService(catalog: []).recommend(profile),
      isEmpty,
    );
  });
  test('assessment No Restrictions alias matches saved No Preference', () {
    expect(
      service
          .recommend(user('Build Muscle', 'No Restrictions'))
          .map((meal) => meal.id),
      service
          .recommend(user('Build Muscle', 'No Preference'))
          .map((meal) => meal.id),
    );
    expect(Meal.estimateNotice, contains('Approximate'));
  });
}
