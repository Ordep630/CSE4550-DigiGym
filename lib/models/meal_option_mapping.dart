import 'package:digigym_backend_client/digigym_backend_client.dart' as backend;

import 'meal.dart';

Meal mealFromOption(backend.MealOption option) {
  return Meal(
    id: option.id,
    name: option.name,
    description: option.description,
    serving: option.serving,
    ingredients: option.ingredients
        .map(
          (item) => MealIngredient(
            FoodIngredient(
              id: item.id,
              name: item.name,
              category: GroceryCategory.pantry,
              per100Grams: const MealNutrition(0, 0, 0, 0),
            ),
            IngredientQuantity(
              item.amount,
              _ingredientUnitFromBackend(item.unit),
            ),
          ),
        )
        .toList(),
    supportedGoals: option.supportedGoals.map(_fitnessGoalLabel).toSet(),
    providedNutrition: MealNutrition(
      option.calories.toDouble(),
      option.proteinGrams.toDouble(),
      option.carbohydrateGrams.toDouble(),
      option.fatGrams.toDouble(),
    ),
    providedCompatibleDiets: option.compatibleDiets.toSet(),
  );
}

IngredientUnit _ingredientUnitFromBackend(backend.IngredientUnit unit) {
  return switch (unit) {
    backend.IngredientUnit.gram => IngredientUnit.gram,
    backend.IngredientUnit.kilogram => IngredientUnit.kilogram,
    backend.IngredientUnit.milliliter => IngredientUnit.milliliter,
    backend.IngredientUnit.liter => IngredientUnit.liter,
    backend.IngredientUnit.item => IngredientUnit.item,
    backend.IngredientUnit.ounce => IngredientUnit.ounce,
    backend.IngredientUnit.fluidOunce => IngredientUnit.fluidOunce,
  };
}

String _fitnessGoalLabel(backend.FitnessGoal goal) {
  return switch (goal) {
    backend.FitnessGoal.loseWeight => 'Lose Weight',
    backend.FitnessGoal.maintainWeight => 'Maintain Weight',
    backend.FitnessGoal.buildMuscle => 'Build Muscle',
    backend.FitnessGoal.gainWeight => 'Gain Weight',
  };
}
