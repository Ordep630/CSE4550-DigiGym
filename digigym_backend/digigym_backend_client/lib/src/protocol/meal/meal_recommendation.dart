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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class MealRecommendation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MealRecommendation._({
    required this.goal,
    required this.dietaryPreference,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
  });

  factory MealRecommendation({
    required String goal,
    required String dietaryPreference,
    required String breakfast,
    required String lunch,
    required String dinner,
    required String snack,
  }) = _MealRecommendationImpl;

  factory MealRecommendation.fromJson(Map<String, dynamic> jsonSerialization) {
    return MealRecommendation(
      goal: jsonSerialization['goal'] as String,
      dietaryPreference: jsonSerialization['dietaryPreference'] as String,
      breakfast: jsonSerialization['breakfast'] as String,
      lunch: jsonSerialization['lunch'] as String,
      dinner: jsonSerialization['dinner'] as String,
      snack: jsonSerialization['snack'] as String,
    );
  }

  String goal;

  String dietaryPreference;

  String breakfast;

  String lunch;

  String dinner;

  String snack;

  /// Returns a shallow copy of this [MealRecommendation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MealRecommendation copyWith({
    String? goal,
    String? dietaryPreference,
    String? breakfast,
    String? lunch,
    String? dinner,
    String? snack,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MealRecommendation',
      'goal': goal,
      'dietaryPreference': dietaryPreference,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'snack': snack,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MealRecommendation',
      'goal': goal,
      'dietaryPreference': dietaryPreference,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'snack': snack,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _MealRecommendationImpl extends MealRecommendation {
  _MealRecommendationImpl({
    required String goal,
    required String dietaryPreference,
    required String breakfast,
    required String lunch,
    required String dinner,
    required String snack,
  }) : super._(
         goal: goal,
         dietaryPreference: dietaryPreference,
         breakfast: breakfast,
         lunch: lunch,
         dinner: dinner,
         snack: snack,
       );

  /// Returns a shallow copy of this [MealRecommendation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MealRecommendation copyWith({
    String? goal,
    String? dietaryPreference,
    String? breakfast,
    String? lunch,
    String? dinner,
    String? snack,
  }) {
    return MealRecommendation(
      goal: goal ?? this.goal,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snack: snack ?? this.snack,
    );
  }
}
