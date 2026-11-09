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
import 'package:digigym_backend_server/src/generated/workout/completed_workout.dart'
    as _ihjluj51;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'fitness/fitness_data.dart' as _isdrmxyn;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'meal/meal_recommendation.dart' as _icj2h90j;
import 'user/fitness_goal.dart' as _ifss0aho;
import 'user/fitness_level.dart' as _ifclzg6e;
import 'user/user.dart' as _izvcgnx4;
import 'workout/completed_workout.dart' as _ikkxl43r;
import 'workout/workout_recommendation.dart' as _izdon4ck;
import 'workout/workout_schedule.dart' as _ikxcc35h;
export 'fitness/fitness_data.dart';
export 'greetings/greeting.dart';
export 'meal/meal_recommendation.dart';
export 'user/fitness_goal.dart';
export 'user/fitness_level.dart';
export 'user/user.dart';
export 'workout/completed_workout.dart';
export 'workout/workout_recommendation.dart';
export 'workout/workout_schedule.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'completed_workout',
      dartName: 'CompletedWorkout',
      schema: 'public',
      module: 'digigym_backend',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'workoutName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'durationMinutes',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'details',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'completedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'completed_workout_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'completed_workout_auth_user_completed_at_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'completedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'digigym_user',
      dartName: 'DigiGymUser',
      schema: 'public',
      module: 'digigym_backend',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'age',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'height',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'weight',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'fitnessLevel',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:FitnessLevel',
        ),
        _isp.ColumnDefinition(
          name: 'fitnessGoal',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:FitnessGoal',
        ),
        _isp.ColumnDefinition(
          name: 'workoutTime',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'dietaryPreference',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'bodyType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'digigym_user_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'digigym_user_auth_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'workout_schedule',
      dartName: 'WorkoutSchedule',
      schema: 'public',
      module: 'digigym_backend',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'workoutDays',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<int>',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'workout_schedule_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'workout_schedule_auth_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iacs.Protocol.targetTableDefinitions,
    ..._iais.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

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
      } on _is.DeserializationClassNameNotFoundException catch (_) {
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
    if (t == _ikkxl43r.CompletedWorkout) {
      return _ikkxl43r.CompletedWorkout.fromJson(data) as T;
    }
    if (t == _izdon4ck.WorkoutRecommendation) {
      return _izdon4ck.WorkoutRecommendation.fromJson(data) as T;
    }
    if (t == _ikxcc35h.WorkoutSchedule) {
      return _ikxcc35h.WorkoutSchedule.fromJson(data) as T;
    }
    if (t == _is.getType<_isdrmxyn.FitnessData?>()) {
      return (data != null ? _isdrmxyn.FitnessData.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_icj2h90j.MealRecommendation?>()) {
      return (data != null ? _icj2h90j.MealRecommendation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ifss0aho.FitnessGoal?>()) {
      return (data != null ? _ifss0aho.FitnessGoal.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ifclzg6e.FitnessLevel?>()) {
      return (data != null ? _ifclzg6e.FitnessLevel.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izvcgnx4.DigiGymUser?>()) {
      return (data != null ? _izvcgnx4.DigiGymUser.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ikkxl43r.CompletedWorkout?>()) {
      return (data != null ? _ikkxl43r.CompletedWorkout.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izdon4ck.WorkoutRecommendation?>()) {
      return (data != null
              ? _izdon4ck.WorkoutRecommendation.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ikxcc35h.WorkoutSchedule?>()) {
      return (data != null ? _ikxcc35h.WorkoutSchedule.fromJson(data) : null)
          as T;
    }
    if (t == List<_ihjluj51.CompletedWorkout>) {
      return (data as List)
              .map((e) => deserialize<_ihjluj51.CompletedWorkout>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == _is.getType<List<int>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<int>(e)).toList()
              : null)
          as T;
    }
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
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
      _ikkxl43r.CompletedWorkout => 'CompletedWorkout',
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
      case _ikkxl43r.CompletedWorkout():
        return 'CompletedWorkout';
      case _izdon4ck.WorkoutRecommendation():
        return 'WorkoutRecommendation';
      case _ikxcc35h.WorkoutSchedule():
        return 'WorkoutSchedule';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
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
    if (dataClassName == 'CompletedWorkout') {
      return deserialize<_ikkxl43r.CompletedWorkout>(data['data']);
    }
    if (dataClassName == 'WorkoutRecommendation') {
      return deserialize<_izdon4ck.WorkoutRecommendation>(data['data']);
    }
    if (dataClassName == 'WorkoutSchedule') {
      return deserialize<_ikxcc35h.WorkoutSchedule>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacs.Protocol().registerHostProtocol('digigym_backend', this);
    _iais.Protocol().registerHostProtocol('digigym_backend', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _izvcgnx4.DigiGymUser:
        return _izvcgnx4.DigiGymUser.t;
      case _ikkxl43r.CompletedWorkout:
        return _ikkxl43r.CompletedWorkout.t;
      case _ikxcc35h.WorkoutSchedule:
        return _ikxcc35h.WorkoutSchedule.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
