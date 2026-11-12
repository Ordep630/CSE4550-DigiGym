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

abstract class WorkoutStreak
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WorkoutStreak._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.currentStreak,
    required this.lastCompletedDate,
  });

  factory WorkoutStreak({
    int? id,
    required _isc.UuidValue authUserId,
    _iacc.AuthUser? authUser,
    required int currentStreak,
    required String lastCompletedDate,
  }) = _WorkoutStreakImpl;

  factory WorkoutStreak.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkoutStreak(
      id: jsonSerialization['id'] as int?,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _ikjknwtv.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['authUser'],
            ),
      currentStreak: jsonSerialization['currentStreak'] as int,
      lastCompletedDate: jsonSerialization['lastCompletedDate'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue authUserId;

  _iacc.AuthUser? authUser;

  int currentStreak;

  String lastCompletedDate;

  /// Returns a shallow copy of this [WorkoutStreak]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WorkoutStreak copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    _iacc.AuthUser? authUser,
    int? currentStreak,
    String? lastCompletedDate,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkoutStreak',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'currentStreak': currentStreak,
      'lastCompletedDate': lastCompletedDate,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WorkoutStreak',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'currentStreak': currentStreak,
      'lastCompletedDate': lastCompletedDate,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WorkoutStreakImpl extends WorkoutStreak {
  _WorkoutStreakImpl({
    int? id,
    required _isc.UuidValue authUserId,
    _iacc.AuthUser? authUser,
    required int currentStreak,
    required String lastCompletedDate,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         currentStreak: currentStreak,
         lastCompletedDate: lastCompletedDate,
       );

  /// Returns a shallow copy of this [WorkoutStreak]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WorkoutStreak copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? authUserId,
    Object? authUser = _Undefined,
    int? currentStreak,
    String? lastCompletedDate,
  }) {
    return WorkoutStreak(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacc.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      currentStreak: currentStreak ?? this.currentStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }
}
