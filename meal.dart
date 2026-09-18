class Meal {
  final String name;
  final int calories;
  final String protein;
  final String portion;
  final String description;
  final int carbs;
  final int fat;
  final List<String> ingredients;

  Meal({
    required this.name,
    required this.calories,
    required this.protein,
    required this.portion,
    this.description = '',
    this.carbs = 0,
    this.fat = 0,
    this.ingredients = const [],
  });
}