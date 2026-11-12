/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

enum IngredientUnit implements _is.SerializableModel {
  gram,
  kilogram,
  milliliter,
  liter,
  item,
  ounce,
  fluidOunce;

  static IngredientUnit fromJson(String name) {
    switch (name) {
      case 'gram':
        return IngredientUnit.gram;
      case 'kilogram':
        return IngredientUnit.kilogram;
      case 'milliliter':
        return IngredientUnit.milliliter;
      case 'liter':
        return IngredientUnit.liter;
      case 'item':
        return IngredientUnit.item;
      case 'ounce':
        return IngredientUnit.ounce;
      case 'fluidOunce':
        return IngredientUnit.fluidOunce;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "IngredientUnit"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
