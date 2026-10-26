import '../data/meal_data.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';

/// Pure selection shared by Meals and Groceries. No API or storage.
class MealRecommendationService {
  final List<Meal>? catalog;
  const MealRecommendationService({this.catalog});
  List<Meal> recommend(UserProfile user) {
    final diet = user.dietaryPreference == 'No Restrictions'
        ? 'No Preference'
        : user.dietaryPreference;
    final candidates = (catalog ?? mealCatalog)
        .where(
          (meal) =>
              meal.supportedGoals.contains(user.fitnessGoal) &&
              meal.compatibleDiets.contains(diet),
        )
        .toList();
    // Options near one third of the existing estimate, not a prescribed or
    // calorie-matched full-day eating plan. Stable IDs resolve equal scores.
    final target = user.estimatedCalories / 3;
    candidates.sort((a, b) {
      final difference = (a.calories - target).abs().compareTo(
        (b.calories - target).abs(),
      );
      return difference != 0 ? difference : a.id.compareTo(b.id);
    });
    return List.unmodifiable(candidates.take(3));
  }
}
