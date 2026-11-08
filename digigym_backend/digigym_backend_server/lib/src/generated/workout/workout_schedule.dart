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

abstract class WorkoutSchedule
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  WorkoutSchedule._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.workoutDays,
  });

  factory WorkoutSchedule({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required List<int> workoutDays,
  }) = _WorkoutScheduleImpl;

  factory WorkoutSchedule.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkoutSchedule(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iy52kuyx.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      workoutDays: _iy52kuyx.Protocol().deserialize<List<int>>(
        jsonSerialization['workoutDays'],
      ),
    );
  }

  static final t = WorkoutScheduleTable();

  static const db = WorkoutScheduleRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  List<int> workoutDays;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [WorkoutSchedule]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WorkoutSchedule copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    List<int>? workoutDays,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkoutSchedule',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'workoutDays': workoutDays.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WorkoutSchedule',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'workoutDays': workoutDays.toJson(),
    };
  }

  static WorkoutScheduleInclude include({_iacs.AuthUserInclude? authUser}) {
    return WorkoutScheduleInclude._(authUser: authUser);
  }

  static WorkoutScheduleIncludeList includeList({
    _is.WhereExpressionBuilder<WorkoutScheduleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkoutScheduleTable>? orderBy,
    _is.OrderByListBuilder<WorkoutScheduleTable>? orderByList,
    WorkoutScheduleInclude? include,
  }) {
    return WorkoutScheduleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WorkoutSchedule.t),
      orderByList: orderByList?.call(WorkoutSchedule.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WorkoutScheduleImpl extends WorkoutSchedule {
  _WorkoutScheduleImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required List<int> workoutDays,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         workoutDays: workoutDays,
       );

  /// Returns a shallow copy of this [WorkoutSchedule]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WorkoutSchedule copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    List<int>? workoutDays,
  }) {
    return WorkoutSchedule(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      workoutDays: workoutDays ?? this.workoutDays.map((e0) => e0).toList(),
    );
  }
}

class WorkoutScheduleUpdateTable extends _is.UpdateTable<WorkoutScheduleTable> {
  WorkoutScheduleUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<List<int>, List<int>> workoutDays(List<int> value) =>
      _is.ColumnValue(
        table.workoutDays,
        value,
      );
}

class WorkoutScheduleTable extends _is.Table<int?> {
  WorkoutScheduleTable({super.tableRelation})
    : super(tableName: 'workout_schedule') {
    updateTable = WorkoutScheduleUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    workoutDays = _is.ColumnSerializable<List<int>>(
      'workoutDays',
      this,
    );
  }

  late final WorkoutScheduleUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnSerializable<List<int>> workoutDays;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: WorkoutSchedule.t.authUserId,
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
    workoutDays,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class WorkoutScheduleInclude extends _is.IncludeObject {
  WorkoutScheduleInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => WorkoutSchedule.t;
}

class WorkoutScheduleIncludeList extends _is.IncludeList {
  WorkoutScheduleIncludeList._({
    _is.WhereExpressionBuilder<WorkoutScheduleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WorkoutSchedule.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => WorkoutSchedule.t;
}

class WorkoutScheduleRepository {
  const WorkoutScheduleRepository._();

  final attachRow = const WorkoutScheduleAttachRowRepository._();

  /// Returns a list of [WorkoutSchedule]s matching the given query parameters.
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
  Future<List<WorkoutSchedule>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkoutScheduleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkoutScheduleTable>? orderBy,
    _is.OrderByListBuilder<WorkoutScheduleTable>? orderByList,
    _is.Transaction? transaction,
    WorkoutScheduleInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WorkoutSchedule>(
      where: where?.call(WorkoutSchedule.t),
      orderBy: orderBy?.call(WorkoutSchedule.t),
      orderByList: orderByList?.call(WorkoutSchedule.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [WorkoutSchedule] matching the given query parameters.
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
  Future<WorkoutSchedule?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkoutScheduleTable>? where,
    int? offset,
    _is.OrderByBuilder<WorkoutScheduleTable>? orderBy,
    _is.OrderByListBuilder<WorkoutScheduleTable>? orderByList,
    _is.Transaction? transaction,
    WorkoutScheduleInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WorkoutSchedule>(
      where: where?.call(WorkoutSchedule.t),
      orderBy: orderBy?.call(WorkoutSchedule.t),
      orderByList: orderByList?.call(WorkoutSchedule.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WorkoutSchedule] by its [id] or null if no such row exists.
  Future<WorkoutSchedule?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    WorkoutScheduleInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WorkoutSchedule>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WorkoutSchedule]s in the list and returns the inserted rows.
  ///
  /// The returned [WorkoutSchedule]s will have their `id` fields set.
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
  Future<List<WorkoutSchedule>> insert(
    _is.DatabaseSession session,
    List<WorkoutSchedule> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WorkoutSchedule>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WorkoutSchedule] and returns the inserted row.
  ///
  /// The returned [WorkoutSchedule] will have its `id` field set.
  Future<WorkoutSchedule> insertRow(
    _is.DatabaseSession session,
    WorkoutSchedule row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WorkoutSchedule>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WorkoutSchedule]s in the list and returns the resulting rows.
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
  /// The returned [WorkoutSchedule]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkoutSchedule>> upsert(
    _is.DatabaseSession session,
    List<WorkoutSchedule> rows, {
    required _is.ColumnSelections<WorkoutScheduleTable> conflictColumns,
    _is.ColumnSelections<WorkoutScheduleTable>? updateColumns,
    _is.WhereExpressionBuilder<WorkoutScheduleTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WorkoutSchedule>(
      rows,
      conflictColumns: conflictColumns(WorkoutSchedule.t),
      updateColumns: updateColumns?.call(WorkoutSchedule.t),
      updateWhere: updateWhere?.call(WorkoutSchedule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WorkoutSchedule] and returns the resulting row.
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
  /// The returned [WorkoutSchedule] will have its `id` field set.
  Future<WorkoutSchedule?> upsertRow(
    _is.DatabaseSession session,
    WorkoutSchedule row, {
    required _is.ColumnSelections<WorkoutScheduleTable> conflictColumns,
    _is.ColumnSelections<WorkoutScheduleTable>? updateColumns,
    _is.WhereExpressionBuilder<WorkoutScheduleTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WorkoutSchedule>(
      row,
      conflictColumns: conflictColumns(WorkoutSchedule.t),
      updateColumns: updateColumns?.call(WorkoutSchedule.t),
      updateWhere: updateWhere?.call(WorkoutSchedule.t),
      transaction: transaction,
    );
  }

  /// Updates all [WorkoutSchedule]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkoutSchedule>> update(
    _is.DatabaseSession session,
    List<WorkoutSchedule> rows, {
    _is.ColumnSelections<WorkoutScheduleTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WorkoutSchedule>(
      rows,
      columns: columns?.call(WorkoutSchedule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WorkoutSchedule]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WorkoutSchedule> updateRow(
    _is.DatabaseSession session,
    WorkoutSchedule row, {
    _is.ColumnSelections<WorkoutScheduleTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WorkoutSchedule>(
      row,
      columns: columns?.call(WorkoutSchedule.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WorkoutSchedule] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WorkoutSchedule?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<WorkoutScheduleUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WorkoutSchedule>(
      id,
      columnValues: columnValues(WorkoutSchedule.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WorkoutSchedule]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkoutSchedule>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WorkoutScheduleUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<WorkoutScheduleTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkoutScheduleTable>? orderBy,
    _is.OrderByListBuilder<WorkoutScheduleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WorkoutSchedule>(
      columnValues: columnValues(WorkoutSchedule.t.updateTable),
      where: where(WorkoutSchedule.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WorkoutSchedule.t),
      orderByList: orderByList?.call(WorkoutSchedule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WorkoutSchedule]s in the list and returns the deleted rows.
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
  Future<List<WorkoutSchedule>> delete(
    _is.DatabaseSession session,
    List<WorkoutSchedule> rows, {
    _is.OrderByBuilder<WorkoutScheduleTable>? orderBy,
    _is.OrderByListBuilder<WorkoutScheduleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WorkoutSchedule>(
      rows,
      orderBy: orderBy?.call(WorkoutSchedule.t),
      orderByList: orderByList?.call(WorkoutSchedule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WorkoutSchedule].
  Future<WorkoutSchedule> deleteRow(
    _is.DatabaseSession session,
    WorkoutSchedule row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WorkoutSchedule>(
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
  Future<List<WorkoutSchedule>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WorkoutScheduleTable> where,
    _is.OrderByBuilder<WorkoutScheduleTable>? orderBy,
    _is.OrderByListBuilder<WorkoutScheduleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WorkoutSchedule>(
      where: where(WorkoutSchedule.t),
      orderBy: orderBy?.call(WorkoutSchedule.t),
      orderByList: orderByList?.call(WorkoutSchedule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkoutScheduleTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WorkoutSchedule>(
      where: where?.call(WorkoutSchedule.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WorkoutSchedule] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WorkoutScheduleTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WorkoutSchedule>(
      where: where(WorkoutSchedule.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class WorkoutScheduleAttachRowRepository {
  const WorkoutScheduleAttachRowRepository._();

  /// Creates a relation between the given [WorkoutSchedule] and [AuthUser]
  /// by setting the [WorkoutSchedule]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    WorkoutSchedule workoutSchedule,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (workoutSchedule.id == null) {
      throw ArgumentError.notNull('workoutSchedule.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $workoutSchedule = workoutSchedule.copyWith(authUserId: authUser.id);
    await session.db.updateRow<WorkoutSchedule>(
      $workoutSchedule,
      columns: [WorkoutSchedule.t.authUserId],
      transaction: transaction,
    );
  }
}
