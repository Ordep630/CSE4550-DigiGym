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
import '../meal/ingredient_unit.dart' as _izzh2v1j;

abstract class MealIngredientOption
    implements _is.SerializableModel, _is.ProtocolSerialization {
  MealIngredientOption._({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory MealIngredientOption({
    required String id,
    required String name,
    required double amount,
    required _izzh2v1j.IngredientUnit unit,
  }) = _MealIngredientOptionImpl;

  factory MealIngredientOption.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MealIngredientOption(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      unit: _izzh2v1j.IngredientUnit.fromJson(
        (jsonSerialization['unit'] as String),
      ),
    );
  }

  String id;

  String name;

  double amount;

  _izzh2v1j.IngredientUnit unit;

  /// Returns a shallow copy of this [MealIngredientOption]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MealIngredientOption copyWith({
    String? id,
    String? name,
    double? amount,
    _izzh2v1j.IngredientUnit? unit,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MealIngredientOption',
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MealIngredientOption',
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _MealIngredientOptionImpl extends MealIngredientOption {
  _MealIngredientOptionImpl({
    required String id,
    required String name,
    required double amount,
    required _izzh2v1j.IngredientUnit unit,
  }) : super._(
         id: id,
         name: name,
         amount: amount,
         unit: unit,
       );

  /// Returns a shallow copy of this [MealIngredientOption]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MealIngredientOption copyWith({
    String? id,
    String? name,
    double? amount,
    _izzh2v1j.IngredientUnit? unit,
  }) {
    return MealIngredientOption(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
    );
  }
}
