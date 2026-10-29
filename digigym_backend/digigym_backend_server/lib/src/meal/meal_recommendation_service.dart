import '../generated/protocol.dart';

/// Generates basic meal suggestions from a user's fitness profile.
class MealRecommendationService {
  MealRecommendation recommend(DigiGymUser user) {
    final preference = user.dietaryPreference.trim();
    final normalizedPreference = preference.toLowerCase();

    final isVegetarian = normalizedPreference.contains('vegetarian');
    final isVegan = normalizedPreference.contains('vegan');
    final isNoPreference =
        preference.isEmpty ||
        normalizedPreference == 'none' ||
        normalizedPreference == 'no preference';

    late final String breakfast;
    late final String lunch;
    late final String dinner;
    late final String snack;

    if (isVegan) {
      breakfast = 'Oatmeal with fruit and nuts';
      lunch = 'Lentil and quinoa bowl';
      dinner = 'Tofu with brown rice and vegetables';
      snack = 'Hummus with carrots';
    } else if (isVegetarian) {
      breakfast = 'Greek yogurt with fruit and oats';
      lunch = 'Bean and vegetable bowl';
      dinner = 'Vegetable stir-fry with tofu and rice';
      snack = 'Apple with nut butter';
    } else if (isNoPreference) {
      breakfast = 'Eggs with whole-grain toast and fruit';
      lunch = 'Grilled chicken with brown rice and vegetables';
      dinner = 'Baked salmon with potatoes and vegetables';
      snack = 'Greek yogurt with fruit';
    } else {
      // Avoid assuming an unsupported dietary restriction is safe to ignore.
      breakfast = 'Oatmeal with fruit';
      lunch = 'A balanced meal matching your dietary needs';
      dinner = 'A balanced meal matching your dietary needs';
      snack = 'A snack matching your dietary needs';
    }

    return MealRecommendation(
      goal: _getGoalDescription(user.fitnessGoal),
      dietaryPreference: preference.isEmpty ? 'No Preference' : preference,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snack: snack,
    );
  }

  String _getGoalDescription(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.loseWeight:
        return 'Weight management';
      case FitnessGoal.buildMuscle:
        return 'Muscle building';
      case FitnessGoal.gainWeight:
        return 'Weight gain';
      case FitnessGoal.maintainWeight:
        return 'Weight maintenance';
    }
  }
}
