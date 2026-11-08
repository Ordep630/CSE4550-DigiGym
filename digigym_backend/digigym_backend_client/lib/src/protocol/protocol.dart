/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'fitness/fitness_data.dart' as _isdrmxyn;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'meal/meal_recommendation.dart' as _icj2h90j;
import 'user/fitness_goal.dart' as _ifss0aho;
import 'user/fitness_level.dart' as _ifclzg6e;
import 'user/user.dart' as _izvcgnx4;
import 'workout/workout_recommendation.dart' as _izdon4ck;
import 'workout/workout_schedule.dart' as _ikxcc35h;
export 'fitness/fitness_data.dart';
export 'greetings/greeting.dart';
export 'meal/meal_recommendation.dart';
export 'user/fitness_goal.dart';
export 'user/fitness_level.dart';
export 'user/user.dart';
export 'workout/workout_recommendation.dart';
export 'workout/workout_schedule.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _isdrmxyn.FitnessData) {
      return _isdrmxyn.FitnessData.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _icj2h90j.MealRecommendation) {
      return _icj2h90j.MealRecommendation.fromJson(data) as T;
    }
    if (t == _ifss0aho.FitnessGoal) {
      return _ifss0aho.FitnessGoal.fromJson(data) as T;
    }
    if (t == _ifclzg6e.FitnessLevel) {
      return _ifclzg6e.FitnessLevel.fromJson(data) as T;
    }
    if (t == _izvcgnx4.DigiGymUser) {
      return _izvcgnx4.DigiGymUser.fromJson(data) as T;
    }
    if (t == _izdon4ck.WorkoutRecommendation) {
      return _izdon4ck.WorkoutRecommendation.fromJson(data) as T;
    }
    if (t == _ikxcc35h.WorkoutSchedule) {
      return _ikxcc35h.WorkoutSchedule.fromJson(data) as T;
    }
    if (t == _isc.getType<_isdrmxyn.FitnessData?>()) {
      return (data != null ? _isdrmxyn.FitnessData.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_icj2h90j.MealRecommendation?>()) {
      return (data != null ? _icj2h90j.MealRecommendation.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ifss0aho.FitnessGoal?>()) {
      return (data != null ? _ifss0aho.FitnessGoal.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ifclzg6e.FitnessLevel?>()) {
      return (data != null ? _ifclzg6e.FitnessLevel.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izvcgnx4.DigiGymUser?>()) {
      return (data != null ? _izvcgnx4.DigiGymUser.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izdon4ck.WorkoutRecommendation?>()) {
      return (data != null
              ? _izdon4ck.WorkoutRecommendation.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ikxcc35h.WorkoutSchedule?>()) {
      return (data != null ? _ikxcc35h.WorkoutSchedule.fromJson(data) : null)
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == _isc.getType<List<int>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<int>(e)).toList()
              : null)
          as T;
    }
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _isdrmxyn.FitnessData => 'FitnessData',
      _izw8z7ou.Greeting => 'Greeting',
      _icj2h90j.MealRecommendation => 'MealRecommendation',
      _ifss0aho.FitnessGoal => 'FitnessGoal',
      _ifclzg6e.FitnessLevel => 'FitnessLevel',
      _izvcgnx4.DigiGymUser => 'DigiGymUser',
      _izdon4ck.WorkoutRecommendation => 'WorkoutRecommendation',
      _ikxcc35h.WorkoutSchedule => 'WorkoutSchedule',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'digigym_backend.',
        '',
      );
    }

    switch (data) {
      case _isdrmxyn.FitnessData():
        return 'FitnessData';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _icj2h90j.MealRecommendation():
        return 'MealRecommendation';
      case _ifss0aho.FitnessGoal():
        return 'FitnessGoal';
      case _ifclzg6e.FitnessLevel():
        return 'FitnessLevel';
      case _izvcgnx4.DigiGymUser():
        return 'DigiGymUser';
      case _izdon4ck.WorkoutRecommendation():
        return 'WorkoutRecommendation';
      case _ikxcc35h.WorkoutSchedule():
        return 'WorkoutSchedule';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'FitnessData') {
      return deserialize<_isdrmxyn.FitnessData>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'MealRecommendation') {
      return deserialize<_icj2h90j.MealRecommendation>(data['data']);
    }
    if (dataClassName == 'FitnessGoal') {
      return deserialize<_ifss0aho.FitnessGoal>(data['data']);
    }
    if (dataClassName == 'FitnessLevel') {
      return deserialize<_ifclzg6e.FitnessLevel>(data['data']);
    }
    if (dataClassName == 'DigiGymUser') {
      return deserialize<_izvcgnx4.DigiGymUser>(data['data']);
    }
    if (dataClassName == 'WorkoutRecommendation') {
      return deserialize<_izdon4ck.WorkoutRecommendation>(data['data']);
    }
    if (dataClassName == 'WorkoutSchedule') {
      return deserialize<_ikxcc35h.WorkoutSchedule>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacc.Protocol().registerHostProtocol('digigym_backend', this);
    _iaic.Protocol().registerHostProtocol('digigym_backend', this);
  }

  @override
  String getModuleName() => 'digigym_backend';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
