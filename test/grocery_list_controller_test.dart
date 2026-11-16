import 'package:digigym/data/meal_data.dart';
import 'package:digigym/models/grocery_item.dart';
import 'package:digigym/models/meal.dart';
import 'package:digigym/services/grocery_list_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groceries are generated from exact meal ingredients and aggregate by stable identity', () {
    final selected = [mealCatalog[0], mealCatalog[1], mealCatalog[9]];
    final rows = generateGroceries(selected);
    final expected = <String, double>{};
    for (final meal in selected) {
      for (final item in meal.ingredients) {
        expected.update(
          item.ingredient.id,
          (amount) => amount + item.quantity.baseAmount,
          ifAbsent: () => item.quantity.baseAmount,
        );
      }
    }
    expect(rows.length, expected.length);
    for (final row in rows) {
      expect(row.quantities, hasLength(1));
      expect(row.quantities.single.baseAmount, expected[row.id]);
      expect(row.quantityLabel, contains('oz'));
      expect(row.custom, isFalse);
      expect(row.purchased, isFalse);
    }
    expect(
      rows
          .singleWhere((row) => row.id == 'rice-cooked')
          .quantities
          .single
          .amount,
      350,
    );
  });
  test('compatible units combine and incompatible units remain distinct in one ingredient row', () {
    final quantities = mergeIngredientQuantities([
      const IngredientQuantity(500, IngredientUnit.gram),
      const IngredientQuantity(.5, IngredientUnit.kilogram),
      const IngredientQuantity(1, IngredientUnit.ounce),
      const IngredientQuantity(250, IngredientUnit.milliliter),
      const IngredientQuantity(.75, IngredientUnit.liter),
      const IngredientQuantity(2, IngredientUnit.item),
    ]);
    expect(quantities, hasLength(3));
    expect(quantities[0].baseAmount, closeTo(1028.349523125, 1e-9));
    expect(quantities[1].baseAmount, 1000);
    expect(quantities[2].baseAmount, 2);
  });
  test(
    'purchases custom additions removals and undo survive reconciliation',
    () {
      final controller = GroceryListController(accountKey: 'a');
      addTearDown(controller.dispose);
      controller.reconcile([mealCatalog.first]);
      final first = controller.items.first;
      controller.setPurchased(first.id, true);
      expect(controller.purchasedCount, 1);
      controller.setPurchased(first.id, false);
      expect(controller.purchasedCount, 0);
      controller.setPurchased(first.id, true);
      final custom = controller.addCustom(
        '  Apples  ',
        category: GroceryCategory.produce,
        quantity: const IngredientQuantity(2, IngredientUnit.item),
      );
      expect(custom.name, 'Apples');
      expect(custom.quantityLabel, '2 items');
      controller.reconcile([mealCatalog.first]);
      expect(
        controller.items.singleWhere((row) => row.id == first.id).purchased,
        isTrue,
      );
      expect(controller.items, contains(custom));
      controller.remove(first.id);
      controller.reconcile([mealCatalog.first]);
      expect(controller.items.any((row) => row.id == first.id), isFalse);
      controller.restore(first);
      expect(
        controller.items.singleWhere((row) => row.id == first.id).purchased,
        isTrue,
      );
      controller.remove(custom.id);
      expect(controller.items, isNot(contains(custom)));
      controller.restore(custom);
      expect(controller.items, contains(custom));
      expect(() => controller.addCustom('   '), throwsArgumentError);
      expect(() => controller.addCustom('a' * 81), throwsArgumentError);
    },
  );
  test('changed meals update generated quantities, keep custom items and require purchase review', () {
    final controller = GroceryListController(accountKey: 'a');
    addTearDown(controller.dispose);
    controller.reconcile([mealCatalog.first]);
    controller.setPurchased('rice-cooked', true);
    final custom = controller.addCustom('Coffee');
    controller.reconcile([mealCatalog.first, mealCatalog[9]]);
    expect(
      controller.items.singleWhere((row) => row.id == 'rice-cooked').purchased,
      isFalse,
    );
    expect(
      controller.items
          .singleWhere((row) => row.id == 'rice-cooked')
          .quantities
          .single
          .amount,
      350,
    );
    expect(controller.items, contains(custom));
    controller.reconcile([]);
    expect(controller.items, [custom]);
    controller.remove(custom.id);
    expect(controller.purchasedCount, 0);
    expect(controller.items, isEmpty);
  });
  test('independent account controllers never share state and disposed undo is harmless', () {
    final a = GroceryListController(accountKey: 'a');
    final b = GroceryListController(accountKey: 'b');
    b.reconcile([mealCatalog.first]);
    a.reconcile([mealCatalog.first]);
    a.setPurchased(a.items.first.id, true);
    final custom = a.addCustom('Account A only');
    expect(b.purchasedCount, 0);
    expect(b.items.any((row) => row.custom), isFalse);
    a.dispose();
    expect(a.items, isEmpty);
    expect(() => a.restore(custom), returnsNormally);
    b.dispose();
  });
}
