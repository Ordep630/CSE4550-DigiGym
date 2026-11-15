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

abstract class CompletedWorkout
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CompletedWorkout._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.workoutName,
    required this.durationMinutes,
    required this.details,
    required this.completedAt,
  });

  factory CompletedWorkout({
    int? id,
    required _isc.UuidValue authUserId,
    _iacc.AuthUser? authUser,
    required String workoutName,
    required int durationMinutes,
    required String details,
    required DateTime completedAt,
  }) = _CompletedWorkoutImpl;

  factory CompletedWorkout.fromJson(Map<String, dynamic> jsonSerialization) {
    return CompletedWorkout(
      id: jsonSerialization['id'] as int?,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _ikjknwtv.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['authUser'],
            ),
      workoutName: jsonSerialization['workoutName'] as String,
      durationMinutes: jsonSerialization['durationMinutes'] as int,
      details: jsonSerialization['details'] as String,
      completedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['completedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue authUserId;

  _iacc.AuthUser? authUser;

  String workoutName;

  int durationMinutes;

  String details;

  DateTime completedAt;

  /// Returns a shallow copy of this [CompletedWorkout]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CompletedWorkout copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    _iacc.AuthUser? authUser,
    String? workoutName,
    int? durationMinutes,
    String? details,
    DateTime? completedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CompletedWorkout',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'workoutName': workoutName,
      'durationMinutes': durationMinutes,
      'details': details,
      'completedAt': completedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CompletedWorkout',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'workoutName': workoutName,
      'durationMinutes': durationMinutes,
      'details': details,
      'completedAt': completedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CompletedWorkoutImpl extends CompletedWorkout {
  _CompletedWorkoutImpl({
    int? id,
    required _isc.UuidValue authUserId,
    _iacc.AuthUser? authUser,
    required String workoutName,
    required int durationMinutes,
    required String details,
    required DateTime completedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         workoutName: workoutName,
         durationMinutes: durationMinutes,
         details: details,
         completedAt: completedAt,
       );

  /// Returns a shallow copy of this [CompletedWorkout]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CompletedWorkout copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? workoutName,
    int? durationMinutes,
    String? details,
    DateTime? completedAt,
  }) {
    return CompletedWorkout(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacc.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      workoutName: workoutName ?? this.workoutName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      details: details ?? this.details,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
