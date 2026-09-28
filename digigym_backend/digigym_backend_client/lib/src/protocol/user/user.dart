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

/// A DigiGym user account and fitness profile
abstract class User
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  User._({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.age,
    required this.height,
    required this.weight,
    required this.fitnessLevel,
    required this.fitnessGoal,
    required this.workoutTime,
    required this.dietaryPreference,
    required this.bodyType,
  });

  factory User({
    int? id,
    required String name,
    required String email,
    required String passwordHash,
    required int age,
    required double height,
    required double weight,
    required String fitnessLevel,
    required String fitnessGoal,
    required int workoutTime,
    required String dietaryPreference,
    required String bodyType,
  }) = _UserImpl;

  factory User.fromJson(Map<String, dynamic> jsonSerialization) {
    return User(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      email: jsonSerialization['email'] as String,
      passwordHash: jsonSerialization['passwordHash'] as String,
      age: jsonSerialization['age'] as int,
      height: (jsonSerialization['height'] as num).toDouble(),
      weight: (jsonSerialization['weight'] as num).toDouble(),
      fitnessLevel: jsonSerialization['fitnessLevel'] as String,
      fitnessGoal: jsonSerialization['fitnessGoal'] as String,
      workoutTime: jsonSerialization['workoutTime'] as int,
      dietaryPreference: jsonSerialization['dietaryPreference'] as String,
      bodyType: jsonSerialization['bodyType'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The user's display name.
  String name;

  /// The user's email address, used to log in.
  String email;

  /// A securely hashed version of the user's password.
  String passwordHash;

  /// The user's age in years
  int age;

  /// The user's height in centimeters.
  double height;

  /// The user's weight in kilograms.
  double weight;

  /// The user's fitness experience level.
  String fitnessLevel;

  /// The user's fitness goal.
  String fitnessGoal;

  /// How many minutes the user has available to work out.
  int workoutTime;

  /// The user's dietary preference.
  String dietaryPreference;

  /// The user's body type
  String bodyType;

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    int? age,
    double? height,
    double? weight,
    String? fitnessLevel,
    String? fitnessGoal,
    int? workoutTime,
    String? dietaryPreference,
    String? bodyType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'User',
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'age': age,
      'height': height,
      'weight': weight,
      'fitnessLevel': fitnessLevel,
      'fitnessGoal': fitnessGoal,
      'workoutTime': workoutTime,
      'dietaryPreference': dietaryPreference,
      'bodyType': bodyType,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'User',
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'age': age,
      'height': height,
      'weight': weight,
      'fitnessLevel': fitnessLevel,
      'fitnessGoal': fitnessGoal,
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

class _UserImpl extends User {
  _UserImpl({
    int? id,
    required String name,
    required String email,
    required String passwordHash,
    required int age,
    required double height,
    required double weight,
    required String fitnessLevel,
    required String fitnessGoal,
    required int workoutTime,
    required String dietaryPreference,
    required String bodyType,
  }) : super._(
         id: id,
         name: name,
         email: email,
         passwordHash: passwordHash,
         age: age,
         height: height,
         weight: weight,
         fitnessLevel: fitnessLevel,
         fitnessGoal: fitnessGoal,
         workoutTime: workoutTime,
         dietaryPreference: dietaryPreference,
         bodyType: bodyType,
       );

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  User copyWith({
    Object? id = _Undefined,
    String? name,
    String? email,
    String? passwordHash,
    int? age,
    double? height,
    double? weight,
    String? fitnessLevel,
    String? fitnessGoal,
    int? workoutTime,
    String? dietaryPreference,
    String? bodyType,
  }) {
    return User(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
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
