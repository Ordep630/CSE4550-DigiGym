/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:digigym_backend_server/src/generated/protocol.dart'
    as _iy52kuyx;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import '../user/fitness_goal.dart' as _iez7dbsx;
import '../user/fitness_level.dart' as _i0eft088;

/// A DigiGym user account and fitness profile linked to their Serverpod's auth account
abstract class DigiGymUser
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
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
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iy52kuyx.Protocol().deserialize<_iacs.AuthUser>(
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

  static final t = DigiGymUserTable();

  static const db = DigiGymUserRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  /// The linked Serverpod authentication account for this user.
  _iacs.AuthUser? authUser;

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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DigiGymUser]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DigiGymUser copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
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

  static DigiGymUserInclude include({_iacs.AuthUserInclude? authUser}) {
    return DigiGymUserInclude._(authUser: authUser);
  }

  static DigiGymUserIncludeList includeList({
    _is.WhereExpressionBuilder<DigiGymUserTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DigiGymUserTable>? orderBy,
    _is.OrderByListBuilder<DigiGymUserTable>? orderByList,
    DigiGymUserInclude? include,
  }) {
    return DigiGymUserIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DigiGymUser.t),
      orderByList: orderByList?.call(DigiGymUser.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DigiGymUserImpl extends DigiGymUser {
  _DigiGymUserImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
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
  @_is.useResult
  @override
  DigiGymUser copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
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
      authUser: authUser is _iacs.AuthUser?
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

class DigiGymUserUpdateTable extends _is.UpdateTable<DigiGymUserTable> {
  DigiGymUserUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<int, int> age(int value) => _is.ColumnValue(
    table.age,
    value,
  );

  _is.ColumnValue<double, double> height(double value) => _is.ColumnValue(
    table.height,
    value,
  );

  _is.ColumnValue<double, double> weight(double value) => _is.ColumnValue(
    table.weight,
    value,
  );

  _is.ColumnValue<_i0eft088.FitnessLevel, _i0eft088.FitnessLevel> fitnessLevel(
    _i0eft088.FitnessLevel value,
  ) => _is.ColumnValue(
    table.fitnessLevel,
    value,
  );

  _is.ColumnValue<_iez7dbsx.FitnessGoal, _iez7dbsx.FitnessGoal> fitnessGoal(
    _iez7dbsx.FitnessGoal value,
  ) => _is.ColumnValue(
    table.fitnessGoal,
    value,
  );

  _is.ColumnValue<int, int> workoutTime(int value) => _is.ColumnValue(
    table.workoutTime,
    value,
  );

  _is.ColumnValue<String, String> dietaryPreference(String value) =>
      _is.ColumnValue(
        table.dietaryPreference,
        value,
      );

  _is.ColumnValue<String, String> bodyType(String value) => _is.ColumnValue(
    table.bodyType,
    value,
  );
}

class DigiGymUserTable extends _is.Table<int?> {
  DigiGymUserTable({super.tableRelation}) : super(tableName: 'digigym_user') {
    updateTable = DigiGymUserUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    age = _is.ColumnInt(
      'age',
      this,
    );
    height = _is.ColumnDouble(
      'height',
      this,
    );
    weight = _is.ColumnDouble(
      'weight',
      this,
    );
    fitnessLevel = _is.ColumnEnum(
      'fitnessLevel',
      this,
      _is.EnumSerialization.byName,
    );
    fitnessGoal = _is.ColumnEnum(
      'fitnessGoal',
      this,
      _is.EnumSerialization.byName,
    );
    workoutTime = _is.ColumnInt(
      'workoutTime',
      this,
    );
    dietaryPreference = _is.ColumnString(
      'dietaryPreference',
      this,
    );
    bodyType = _is.ColumnString(
      'bodyType',
      this,
    );
  }

  late final DigiGymUserUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  /// The linked Serverpod authentication account for this user.
  _iacs.AuthUserTable? _authUser;

  /// The user's display name.
  late final _is.ColumnString name;

  /// The user's age in years
  late final _is.ColumnInt age;

  /// The user's height in centimeters.
  late final _is.ColumnDouble height;

  /// The user's weight in kilograms.
  late final _is.ColumnDouble weight;

  /// The user's fitness experience level.
  late final _is.ColumnEnum<_i0eft088.FitnessLevel> fitnessLevel;

  /// The user's fitness goal.
  late final _is.ColumnEnum<_iez7dbsx.FitnessGoal> fitnessGoal;

  /// How many minutes the user has available to work out.
  late final _is.ColumnInt workoutTime;

  /// The user's dietary preference.
  late final _is.ColumnString dietaryPreference;

  /// The user's body type
  late final _is.ColumnString bodyType;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: DigiGymUser.t.authUserId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _authUser!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    name,
    age,
    height,
    weight,
    fitnessLevel,
    fitnessGoal,
    workoutTime,
    dietaryPreference,
    bodyType,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class DigiGymUserInclude extends _is.IncludeObject {
  DigiGymUserInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => DigiGymUser.t;
}

class DigiGymUserIncludeList extends _is.IncludeList {
  DigiGymUserIncludeList._({
    _is.WhereExpressionBuilder<DigiGymUserTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DigiGymUser.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DigiGymUser.t;
}

class DigiGymUserRepository {
  const DigiGymUserRepository._();

  final attachRow = const DigiGymUserAttachRowRepository._();

  /// Returns a list of [DigiGymUser]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<DigiGymUser>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DigiGymUserTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DigiGymUserTable>? orderBy,
    _is.OrderByListBuilder<DigiGymUserTable>? orderByList,
    _is.Transaction? transaction,
    DigiGymUserInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DigiGymUser>(
      where: where?.call(DigiGymUser.t),
      orderBy: orderBy?.call(DigiGymUser.t),
      orderByList: orderByList?.call(DigiGymUser.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DigiGymUser] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<DigiGymUser?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DigiGymUserTable>? where,
    int? offset,
    _is.OrderByBuilder<DigiGymUserTable>? orderBy,
    _is.OrderByListBuilder<DigiGymUserTable>? orderByList,
    _is.Transaction? transaction,
    DigiGymUserInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DigiGymUser>(
      where: where?.call(DigiGymUser.t),
      orderBy: orderBy?.call(DigiGymUser.t),
      orderByList: orderByList?.call(DigiGymUser.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DigiGymUser] by its [id] or null if no such row exists.
  Future<DigiGymUser?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    DigiGymUserInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DigiGymUser>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DigiGymUser]s in the list and returns the inserted rows.
  ///
  /// The returned [DigiGymUser]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DigiGymUser>> insert(
    _is.DatabaseSession session,
    List<DigiGymUser> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DigiGymUser>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DigiGymUser] and returns the inserted row.
  ///
  /// The returned [DigiGymUser] will have its `id` field set.
  Future<DigiGymUser> insertRow(
    _is.DatabaseSession session,
    DigiGymUser row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DigiGymUser>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DigiGymUser]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [DigiGymUser]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DigiGymUser>> upsert(
    _is.DatabaseSession session,
    List<DigiGymUser> rows, {
    required _is.ColumnSelections<DigiGymUserTable> conflictColumns,
    _is.ColumnSelections<DigiGymUserTable>? updateColumns,
    _is.WhereExpressionBuilder<DigiGymUserTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DigiGymUser>(
      rows,
      conflictColumns: conflictColumns(DigiGymUser.t),
      updateColumns: updateColumns?.call(DigiGymUser.t),
      updateWhere: updateWhere?.call(DigiGymUser.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DigiGymUser] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [DigiGymUser] will have its `id` field set.
  Future<DigiGymUser?> upsertRow(
    _is.DatabaseSession session,
    DigiGymUser row, {
    required _is.ColumnSelections<DigiGymUserTable> conflictColumns,
    _is.ColumnSelections<DigiGymUserTable>? updateColumns,
    _is.WhereExpressionBuilder<DigiGymUserTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DigiGymUser>(
      row,
      conflictColumns: conflictColumns(DigiGymUser.t),
      updateColumns: updateColumns?.call(DigiGymUser.t),
      updateWhere: updateWhere?.call(DigiGymUser.t),
      transaction: transaction,
    );
  }

  /// Updates all [DigiGymUser]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DigiGymUser>> update(
    _is.DatabaseSession session,
    List<DigiGymUser> rows, {
    _is.ColumnSelections<DigiGymUserTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DigiGymUser>(
      rows,
      columns: columns?.call(DigiGymUser.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DigiGymUser]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DigiGymUser> updateRow(
    _is.DatabaseSession session,
    DigiGymUser row, {
    _is.ColumnSelections<DigiGymUserTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DigiGymUser>(
      row,
      columns: columns?.call(DigiGymUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DigiGymUser] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DigiGymUser?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DigiGymUserUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DigiGymUser>(
      id,
      columnValues: columnValues(DigiGymUser.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DigiGymUser]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DigiGymUser>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DigiGymUserUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DigiGymUserTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DigiGymUserTable>? orderBy,
    _is.OrderByListBuilder<DigiGymUserTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DigiGymUser>(
      columnValues: columnValues(DigiGymUser.t.updateTable),
      where: where(DigiGymUser.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DigiGymUser.t),
      orderByList: orderByList?.call(DigiGymUser.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DigiGymUser]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DigiGymUser>> delete(
    _is.DatabaseSession session,
    List<DigiGymUser> rows, {
    _is.OrderByBuilder<DigiGymUserTable>? orderBy,
    _is.OrderByListBuilder<DigiGymUserTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DigiGymUser>(
      rows,
      orderBy: orderBy?.call(DigiGymUser.t),
      orderByList: orderByList?.call(DigiGymUser.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DigiGymUser].
  Future<DigiGymUser> deleteRow(
    _is.DatabaseSession session,
    DigiGymUser row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DigiGymUser>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DigiGymUser>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DigiGymUserTable> where,
    _is.OrderByBuilder<DigiGymUserTable>? orderBy,
    _is.OrderByListBuilder<DigiGymUserTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DigiGymUser>(
      where: where(DigiGymUser.t),
      orderBy: orderBy?.call(DigiGymUser.t),
      orderByList: orderByList?.call(DigiGymUser.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DigiGymUserTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DigiGymUser>(
      where: where?.call(DigiGymUser.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DigiGymUser] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DigiGymUserTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DigiGymUser>(
      where: where(DigiGymUser.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class DigiGymUserAttachRowRepository {
  const DigiGymUserAttachRowRepository._();

  /// Creates a relation between the given [DigiGymUser] and [AuthUser]
  /// by setting the [DigiGymUser]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    DigiGymUser digiGymUser,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (digiGymUser.id == null) {
      throw ArgumentError.notNull('digiGymUser.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $digiGymUser = digiGymUser.copyWith(authUserId: authUser.id);
    await session.db.updateRow<DigiGymUser>(
      $digiGymUser,
      columns: [DigiGymUser.t.authUserId],
      transaction: transaction,
    );
  }
}
