import '../utils/measurement_units.dart';

enum GroceryCategory {
  produce('Produce'),
  protein('Protein'),
  dairyAndEggs('Dairy & Eggs'),
  grains('Grains'),
  pantry('Pantry');

  final String label;
  const GroceryCategory(this.label);
}

enum IngredientUnit {
  gram,
  kilogram,
  milliliter,
  liter,
  item,
  ounce,
  fluidOunce,
}

/// Canonical quantities permit aggregation without adding mass to volume/count.
class IngredientQuantity {
  final double amount;
  final IngredientUnit unit;
  const IngredientQuantity(this.amount, this.unit)
    : assert(amount > 0 && amount < double.infinity);
  IngredientUnit get baseUnit => switch (unit) {
    IngredientUnit.gram ||
    IngredientUnit.kilogram ||
    IngredientUnit.ounce => IngredientUnit.gram,
    IngredientUnit.milliliter ||
    IngredientUnit.liter ||
    IngredientUnit.fluidOunce => IngredientUnit.milliliter,
    IngredientUnit.item => IngredientUnit.item,
  };
  double get baseAmount => switch (unit) {
    IngredientUnit.kilogram || IngredientUnit.liter => amount * 1000,
    IngredientUnit.ounce => MeasurementUnits.ouncesToGrams(amount),
    IngredientUnit.fluidOunce =>
      MeasurementUnits.usFluidOuncesToLiters(amount) * 1000,
    _ => amount,
  };
  String get label {
    final value = switch (baseUnit) {
      IngredientUnit.gram => MeasurementUnits.gramsToOunces(baseAmount),
      IngredientUnit.milliliter => MeasurementUnits.litersToUsFluidOunces(
        baseAmount / 1000,
      ),
      _ => baseAmount,
    };
    final suffix = switch (baseUnit) {
      IngredientUnit.gram => 'oz',
      IngredientUnit.milliliter => 'fl oz',
      _ => value == 1 ? 'item' : 'items',
    };
    final number = value < .1
        ? '<0.1'
        : value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
    return '$number $suffix';
  }
}

/// Rounded recipe estimates, not laboratory measurements or a prescription.
class MealNutrition {
  final double calories;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  const MealNutrition(
    this.calories,
    this.proteinGrams,
    this.carbohydrateGrams,
    this.fatGrams,
  );
  MealNutrition scaled(double factor) => MealNutrition(
    calories * factor,
    proteinGrams * factor,
    carbohydrateGrams * factor,
    fatGrams * factor,
  );
  MealNutrition operator +(MealNutrition other) => MealNutrition(
    calories + other.calories,
    proteinGrams + other.proteinGrams,
    carbohydrateGrams + other.carbohydrateGrams,
    fatGrams + other.fatGrams,
  );
}

class FoodIngredient {
  final String id;
  final String name;
  final GroceryCategory category;
  final bool vegan;
  final bool vegetarian;

  /// Typical approximate values per 100 g, for the stated preparation.
  final MealNutrition per100Grams;
  const FoodIngredient({
    required this.id,
    required this.name,
    required this.category,
    required this.per100Grams,
    this.vegan = true,
    this.vegetarian = true,
  });
}

class MealIngredient {
  final FoodIngredient ingredient;
  final IngredientQuantity quantity;
  MealIngredient(this.ingredient, this.quantity)
    : assert(quantity.baseUnit == IngredientUnit.gram);
  MealNutrition get nutrition =>
      ingredient.per100Grams.scaled(quantity.baseAmount / 100);
}

class Meal {
  final String id;
  final String name;
  final String description;
  final String serving;
  final List<MealIngredient> ingredients;
  final Set<String> supportedGoals;
  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.serving,
    required List<MealIngredient> ingredients,
    required Set<String> supportedGoals,
  }) : ingredients = List.unmodifiable(ingredients),
       supportedGoals = Set.unmodifiable(supportedGoals);
  MealNutrition get nutrition => ingredients.fold(
    const MealNutrition(0, 0, 0, 0),
    (sum, item) => sum + item.nutrition,
  );
  int get calories => (nutrition.calories / 10).round() * 10;
  int get proteinGrams => nutrition.proteinGrams.round();
  int get carbohydrateGrams => nutrition.carbohydrateGrams.round();
  int get fatGrams => nutrition.fatGrams.round();
  bool get vegan => ingredients.every((item) => item.ingredient.vegan);
  bool get vegetarian =>
      ingredients.every((item) => item.ingredient.vegetarian);

  /// App catalogue filter: >=25 g and >=20% estimated energy from protein.
  /// This is not a medical or regulated nutrition claim.
  bool get highProtein =>
      proteinGrams >= 25 &&
      nutrition.proteinGrams * 4 >= nutrition.calories * .20;
  Set<String> get compatibleDiets => {
    'No Preference',
    if (vegan) 'Vegan',
    if (vegetarian) 'Vegetarian',
    if (highProtein) 'High Protein',
  };
  static const estimateNotice =
      'Approximate recipe nutrition per serving. '
      'Ingredients and preparation vary. These options are not a complete daily meal plan.';
}
