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
import 'package:digigym_backend_client/src/protocol/protocol.dart' as _ikjknwtv;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../meal/meal_ingredient_opt.dart' as _i5od1r8r;
import '../user/fitness_goal.dart' as _iez7dbsx;

abstract class MealOption
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MealOption._({
    required this.id,
    required this.name,
    required this.description,
    required this.serving,
    required this.supportedGoals,
    required this.compatibleDiets,
    required this.ingredients,
    required this.calories,
    required this.carbohydrateGrams,
    required this.proteinGrams,
    required this.fatGrams,
  });

  factory MealOption({
    required String id,
    required String name,
    required String description,
    required String serving,
    required List<_iez7dbsx.FitnessGoal> supportedGoals,
    required List<String> compatibleDiets,
    required List<_i5od1r8r.MealIngredientOption> ingredients,
    required int calories,
    required int carbohydrateGrams,
    required int proteinGrams,
    required int fatGrams,
  }) = _MealOptionImpl;

  factory MealOption.fromJson(Map<String, dynamic> jsonSerialization) {
    return MealOption(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      serving: jsonSerialization['serving'] as String,
      supportedGoals: _ikjknwtv.Protocol()
          .deserialize<List<_iez7dbsx.FitnessGoal>>(
            jsonSerialization['supportedGoals'],
          ),
      compatibleDiets: _ikjknwtv.Protocol().deserialize<List<String>>(
        jsonSerialization['compatibleDiets'],
      ),
      ingredients: _ikjknwtv.Protocol()
          .deserialize<List<_i5od1r8r.MealIngredientOption>>(
            jsonSerialization['ingredients'],
          ),
      calories: jsonSerialization['calories'] as int,
      carbohydrateGrams: jsonSerialization['carbohydrateGrams'] as int,
      proteinGrams: jsonSerialization['proteinGrams'] as int,
      fatGrams: jsonSerialization['fatGrams'] as int,
    );
  }

  String id;

  String name;

  String description;

  String serving;

  List<_iez7dbsx.FitnessGoal> supportedGoals;

  List<String> compatibleDiets;

  List<_i5od1r8r.MealIngredientOption> ingredients;

  int calories;

  int carbohydrateGrams;

  int proteinGrams;

  int fatGrams;

  /// Returns a shallow copy of this [MealOption]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MealOption copyWith({
    String? id,
    String? name,
    String? description,
    String? serving,
    List<_iez7dbsx.FitnessGoal>? supportedGoals,
    List<String>? compatibleDiets,
    List<_i5od1r8r.MealIngredientOption>? ingredients,
    int? calories,
    int? carbohydrateGrams,
    int? proteinGrams,
    int? fatGrams,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MealOption',
      'id': id,
      'name': name,
      'description': description,
      'serving': serving,
      'supportedGoals': supportedGoals.toJson(valueToJson: (v) => v.toJson()),
      'compatibleDiets': compatibleDiets.toJson(),
      'ingredients': ingredients.toJson(valueToJson: (v) => v.toJson()),
      'calories': calories,
      'carbohydrateGrams': carbohydrateGrams,
      'proteinGrams': proteinGrams,
      'fatGrams': fatGrams,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MealOption',
      'id': id,
      'name': name,
      'description': description,
      'serving': serving,
      'supportedGoals': supportedGoals.toJson(valueToJson: (v) => v.toJson()),
      'compatibleDiets': compatibleDiets.toJson(),
      'ingredients': ingredients.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'calories': calories,
      'carbohydrateGrams': carbohydrateGrams,
      'proteinGrams': proteinGrams,
      'fatGrams': fatGrams,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _MealOptionImpl extends MealOption {
  _MealOptionImpl({
    required String id,
    required String name,
    required String description,
    required String serving,
    required List<_iez7dbsx.FitnessGoal> supportedGoals,
    required List<String> compatibleDiets,
    required List<_i5od1r8r.MealIngredientOption> ingredients,
    required int calories,
    required int carbohydrateGrams,
    required int proteinGrams,
    required int fatGrams,
  }) : super._(
         id: id,
         name: name,
         description: description,
         serving: serving,
         supportedGoals: supportedGoals,
         compatibleDiets: compatibleDiets,
         ingredients: ingredients,
         calories: calories,
         carbohydrateGrams: carbohydrateGrams,
         proteinGrams: proteinGrams,
         fatGrams: fatGrams,
       );

  /// Returns a shallow copy of this [MealOption]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MealOption copyWith({
    String? id,
    String? name,
    String? description,
    String? serving,
    List<_iez7dbsx.FitnessGoal>? supportedGoals,
    List<String>? compatibleDiets,
    List<_i5od1r8r.MealIngredientOption>? ingredients,
    int? calories,
    int? carbohydrateGrams,
    int? proteinGrams,
    int? fatGrams,
  }) {
    return MealOption(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      serving: serving ?? this.serving,
      supportedGoals:
          supportedGoals ?? this.supportedGoals.map((e0) => e0).toList(),
      compatibleDiets:
          compatibleDiets ?? this.compatibleDiets.map((e0) => e0).toList(),
      ingredients:
          ingredients ?? this.ingredients.map((e0) => e0.copyWith()).toList(),
      calories: calories ?? this.calories,
      carbohydrateGrams: carbohydrateGrams ?? this.carbohydrateGrams,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      fatGrams: fatGrams ?? this.fatGrams,
    );
  }
}
