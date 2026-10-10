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
import '../user/fitness_goal.dart' as _iez7dbsx;
import '../user/fitness_level.dart' as _i0eft088;

abstract class FitnessData
    implements _is.SerializableModel, _is.ProtocolSerialization {
  FitnessData._({
    required this.fitnessLevel,
    required this.fitnessGoal,
  });

  factory FitnessData({
    required _i0eft088.FitnessLevel fitnessLevel,
    required _iez7dbsx.FitnessGoal fitnessGoal,
  }) = _FitnessDataImpl;

  factory FitnessData.fromJson(Map<String, dynamic> jsonSerialization) {
    return FitnessData(
      fitnessLevel: _i0eft088.FitnessLevel.fromJson(
        (jsonSerialization['fitnessLevel'] as String),
      ),
      fitnessGoal: _iez7dbsx.FitnessGoal.fromJson(
        (jsonSerialization['fitnessGoal'] as String),
      ),
    );
  }

  _i0eft088.FitnessLevel fitnessLevel;

  _iez7dbsx.FitnessGoal fitnessGoal;

  /// Returns a shallow copy of this [FitnessData]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FitnessData copyWith({
    _i0eft088.FitnessLevel? fitnessLevel,
    _iez7dbsx.FitnessGoal? fitnessGoal,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FitnessData',
      'fitnessLevel': fitnessLevel.toJson(),
      'fitnessGoal': fitnessGoal.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FitnessData',
      'fitnessLevel': fitnessLevel.toJson(),
      'fitnessGoal': fitnessGoal.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _FitnessDataImpl extends FitnessData {
  _FitnessDataImpl({
    required _i0eft088.FitnessLevel fitnessLevel,
    required _iez7dbsx.FitnessGoal fitnessGoal,
  }) : super._(
         fitnessLevel: fitnessLevel,
         fitnessGoal: fitnessGoal,
       );

  /// Returns a shallow copy of this [FitnessData]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FitnessData copyWith({
    _i0eft088.FitnessLevel? fitnessLevel,
    _iez7dbsx.FitnessGoal? fitnessGoal,
  }) {
    return FitnessData(
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
    );
  }
}
