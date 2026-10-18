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
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../user/fitness_goal.dart' as _iez7dbsx;
import '../user/fitness_level.dart' as _i0eft088;

/// A DigiGym user account and fitness profile linked to their Serverpod's auth account
abstract class DigiGymUser
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DigiGymUser._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.fitnessLevel,
    required this.fitnessGoal,
    required this.workoutTime,
    required this.dietaryPreference,
    required this.bodyType,
  });

  factory DigiGymUser({
    int? id,
    required _isc.UuidValue authUserId,
    _iacc.AuthUser? authUser,
    required String name,
    required int age,
    required double height,
    required double weight,
    required _i0eft088.FitnessLevel fitnessLevel,
    required _iez7dbsx.FitnessGoal fitnessGoal,
    required int workoutTime,
    required String dietaryPreference,
    required String bodyType,
  }) = _DigiGymUserImpl;

  factory DigiGymUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return DigiGymUser(
      id: jsonSerialization['id'] as int?,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _ikjknwtv.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['authUser'],
            ),
      name: jsonSerialization['name'] as String,
      age: jsonSerialization['age'] as int,
      height: (jsonSerialization['height'] as num).toDouble(),
      weight: (jsonSerialization['weight'] as num).toDouble(),
      fitnessLevel: _i0eft088.FitnessLevel.fromJson(
        (jsonSerialization['fitnessLevel'] as String),
      ),
      fitnessGoal: _iez7dbsx.FitnessGoal.fromJson(
        (jsonSerialization['fitnessGoal'] as String),
      ),
      workoutTime: jsonSerialization['workoutTime'] as int,
      dietaryPreference: jsonSerialization['dietaryPreference'] as String,
      bodyType: jsonSerialization['bodyType'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue authUserId;

  /// The linked Serverpod authentication account for this user.
  _iacc.AuthUser? authUser;

  /// The user's display name.
  String name;

  /// The user's age in years
  int age;

  /// The user's height in centimeters.
  double height;

  /// The user's weight in kilograms.
  double weight;

  /// The user's fitness experience level.
  _i0eft088.FitnessLevel fitnessLevel;

  /// The user's fitness goal.
  _iez7dbsx.FitnessGoal fitnessGoal;

  /// How many minutes the user has available to work out.
  int workoutTime;

  /// The user's dietary preference.
  String dietaryPreference;

  /// The user's body type
  String bodyType;

  /// Returns a shallow copy of this [DigiGymUser]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DigiGymUser copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    _iacc.AuthUser? authUser,
    String? name,
    int? age,
    double? height,
    double? weight,
    _i0eft088.FitnessLevel? fitnessLevel,
    _iez7dbsx.FitnessGoal? fitnessGoal,
    int? workoutTime,
    String? dietaryPreference,
    String? bodyType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DigiGymUser',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'fitnessLevel': fitnessLevel.toJson(),
      'fitnessGoal': fitnessGoal.toJson(),
      'workoutTime': workoutTime,
      'dietaryPreference': dietaryPreference,
      'bodyType': bodyType,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DigiGymUser',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'fitnessLevel': fitnessLevel.toJson(),
      'fitnessGoal': fitnessGoal.toJson(),
      'workoutTime': workoutTime,
      'dietaryPreference': dietaryPreference,
      'bodyType': bodyType,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DigiGymUserImpl extends DigiGymUser {
  _DigiGymUserImpl({
    int? id,
    required _isc.UuidValue authUserId,
    _iacc.AuthUser? authUser,
    required String name,
    required int age,
    required double height,
    required double weight,
    required _i0eft088.FitnessLevel fitnessLevel,
    required _iez7dbsx.FitnessGoal fitnessGoal,
    required int workoutTime,
    required String dietaryPreference,
    required String bodyType,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         name: name,
         age: age,
         height: height,
         weight: weight,
         fitnessLevel: fitnessLevel,
         fitnessGoal: fitnessGoal,
         workoutTime: workoutTime,
         dietaryPreference: dietaryPreference,
         bodyType: bodyType,
       );

  /// Returns a shallow copy of this [DigiGymUser]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DigiGymUser copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? name,
    int? age,
    double? height,
    double? weight,
    _i0eft088.FitnessLevel? fitnessLevel,
    _iez7dbsx.FitnessGoal? fitnessGoal,
    int? workoutTime,
    String? dietaryPreference,
    String? bodyType,
  }) {
    return DigiGymUser(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacc.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      workoutTime: workoutTime ?? this.workoutTime,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      bodyType: bodyType ?? this.bodyType,
    );
  }
}
