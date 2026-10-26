import 'meal.dart';

class GroceryItem {
  final String id;
  final String name;
  final GroceryCategory category;
  final List<IngredientQuantity> quantities;
  final bool purchased;
  final bool custom;
  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    List<IngredientQuantity> quantities = const [],
    this.purchased = false,
    this.custom = false,
  }) : quantities = List.unmodifiable(quantities);

  String get quantityLabel =>
      quantities.map((quantity) => quantity.label).join(' · ');
  GroceryItem withPurchased(bool value) => GroceryItem(
    id: id,
    name: name,
    category: category,
    quantities: quantities,
    purchased: value,
    custom: custom,
  );
}

/// Same dimensions combine; e.g. kg+g combine, but g+items never do.
List<IngredientQuantity> mergeIngredientQuantities(
  Iterable<IngredientQuantity> quantities,
) {
  final totals = <IngredientUnit, double>{};
  for (final quantity in quantities) {
    totals.update(
      quantity.baseUnit,
      (value) => value + quantity.baseAmount,
      ifAbsent: () => quantity.baseAmount,
    );
  }
  return List.unmodifiable([
    for (final unit in IngredientUnit.values)
      if (totals.containsKey(unit)) IngredientQuantity(totals[unit]!, unit),
  ]);
}

List<GroceryItem> generateGroceries(Iterable<Meal> meals) {
  final ingredients = <String, FoodIngredient>{};
  final amounts = <String, List<IngredientQuantity>>{};
  for (final meal in meals) {
    for (final item in meal.ingredients) {
      final id = item.ingredient.id;
      ingredients[id] = item.ingredient;
      amounts.putIfAbsent(id, () => []).add(item.quantity);
    }
  }
  return List.unmodifiable([
    for (final entry in ingredients.entries)
      GroceryItem(
        id: entry.key,
        name: entry.value.name,
        category: entry.value.category,
        quantities: mergeIngredientQuantities(amounts[entry.key]!),
      ),
  ]);
}
