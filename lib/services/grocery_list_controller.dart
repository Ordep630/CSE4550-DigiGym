import 'package:flutter/foundation.dart';

import '../models/grocery_item.dart';
import '../models/meal.dart';

/// Account-scoped, session-only list. No Serverpod or device persistence.
class GroceryListController extends ChangeNotifier {
  final String accountKey;
  GroceryListController({required this.accountKey});
  Map<String, GroceryItem> _generated = {};
  final Map<String, GroceryItem> _custom = {};
  final Set<String> _removed = {};
  int _nextCustom = 0;
  String? _signature;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _generated.clear();
    _custom.clear();
    _removed.clear();
    super.dispose();
  }

  List<GroceryItem> get items {
    final visible =
        [
          ..._generated.values.where((item) => !_removed.contains(item.id)),
          ..._custom.values,
        ]..sort((a, b) {
          final category = a.category.index.compareTo(b.category.index);
          return category != 0 ? category : a.name.compareTo(b.name);
        });
    return List.unmodifiable(visible);
  }

  int get purchasedCount => items.where((item) => item.purchased).length;

  String _amounts(GroceryItem item) => item.quantities
      .map((quantity) => '${quantity.baseUnit.name}:${quantity.baseAmount}')
      .join('|');

  void reconcile(List<Meal> meals, {bool notify = true}) {
    if (_disposed) return;
    final generated = generateGroceries(meals);
    final signature = generated
        .map((item) => '${item.id}:${_amounts(item)}')
        .join(';');
    if (signature == _signature) return;
    _signature = signature;
    final next = <String, GroceryItem>{};
    for (final item in generated) {
      final previous = _generated[item.id];
      // Changed quantities require review; an old checkbox cannot imply that
      // an increased requirement has already been purchased.
      final purchased =
          previous != null &&
          previous.purchased &&
          _amounts(previous) == _amounts(item);
      next[item.id] = item.withPurchased(purchased);
    }
    _generated = next;
    _removed.retainAll(next.keys);
    if (notify) notifyListeners();
  }

  void setPurchased(String id, bool value) {
    if (_disposed) return;
    final source = _custom.containsKey(id) ? _custom : _generated;
    final item = source[id];
    if (item == null || item.purchased == value) return;
    source[id] = item.withPurchased(value);
    notifyListeners();
  }

  GroceryItem addCustom(
    String name, {
    IngredientQuantity? quantity,
    GroceryCategory category = GroceryCategory.pantry,
  }) {
    final clean = name.trim();
    if (clean.isEmpty || clean.length > 80) {
      throw ArgumentError('Use a grocery name of 1–80 characters.');
    }
    if (quantity != null &&
        (!quantity.amount.isFinite ||
            quantity.amount <= 0 ||
            !quantity.baseAmount.isFinite)) {
      throw ArgumentError('Use a positive finite quantity.');
    }
    final item = GroceryItem(
      id: 'custom:${_nextCustom++}',
      name: clean,
      category: category,
      quantities: quantity == null ? [] : [quantity],
      custom: true,
    );
    _custom[item.id] = item;
    notifyListeners();
    return item;
  }

  void remove(String id) {
    if (_disposed) return;
    if (_custom.remove(id) == null) {
      if (!_generated.containsKey(id)) return;
      _removed.add(id);
    }
    notifyListeners();
  }

  void restore(GroceryItem item) {
    if (_disposed) return;
    if (item.custom) {
      _custom[item.id] = item;
    } else if (_generated.containsKey(item.id)) {
      _removed.remove(item.id);
    } else {
      return;
    }
    notifyListeners();
  }
}
