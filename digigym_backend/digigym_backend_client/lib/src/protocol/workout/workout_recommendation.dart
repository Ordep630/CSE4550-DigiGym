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

abstract class WorkoutRecommendation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WorkoutRecommendation._({
    required this.workoutType,
    required this.durationMinutes,
    required this.difficulty,
  });

  factory WorkoutRecommendation({
    required String workoutType,
    required int durationMinutes,
    required String difficulty,
  }) = _WorkoutRecommendationImpl;

  factory WorkoutRecommendation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return WorkoutRecommendation(
      workoutType: jsonSerialization['workoutType'] as String,
      durationMinutes: jsonSerialization['durationMinutes'] as int,
      difficulty: jsonSerialization['difficulty'] as String,
    );
  }

  String workoutType;

  int durationMinutes;

  String difficulty;

  /// Returns a shallow copy of this [WorkoutRecommendation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WorkoutRecommendation copyWith({
    String? workoutType,
    int? durationMinutes,
    String? difficulty,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkoutRecommendation',
      'workoutType': workoutType,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WorkoutRecommendation',
      'workoutType': workoutType,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _WorkoutRecommendationImpl extends WorkoutRecommendation {
  _WorkoutRecommendationImpl({
    required String workoutType,
    required int durationMinutes,
    required String difficulty,
  }) : super._(
         workoutType: workoutType,
         durationMinutes: durationMinutes,
         difficulty: difficulty,
       );

  /// Returns a shallow copy of this [WorkoutRecommendation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WorkoutRecommendation copyWith({
    String? workoutType,
    int? durationMinutes,
    String? difficulty,
  }) {
    return WorkoutRecommendation(
      workoutType: workoutType ?? this.workoutType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
