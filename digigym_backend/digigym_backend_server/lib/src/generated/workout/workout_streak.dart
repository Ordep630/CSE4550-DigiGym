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

abstract class WorkoutStreak
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  WorkoutStreak._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.currentStreak,
    required this.lastCompletedDate,
  });

  factory WorkoutStreak({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required int currentStreak,
    required String lastCompletedDate,
  }) = _WorkoutStreakImpl;

  factory WorkoutStreak.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkoutStreak(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iy52kuyx.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      currentStreak: jsonSerialization['currentStreak'] as int,
      lastCompletedDate: jsonSerialization['lastCompletedDate'] as String,
    );
  }

  static final t = WorkoutStreakTable();

  static const db = WorkoutStreakRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  int currentStreak;

  String lastCompletedDate;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [WorkoutStreak]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WorkoutStreak copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
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

  static WorkoutStreakInclude include({_iacs.AuthUserInclude? authUser}) {
    return WorkoutStreakInclude._(authUser: authUser);
  }

  static WorkoutStreakIncludeList includeList({
    _is.WhereExpressionBuilder<WorkoutStreakTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkoutStreakTable>? orderBy,
    _is.OrderByListBuilder<WorkoutStreakTable>? orderByList,
    WorkoutStreakInclude? include,
  }) {
    return WorkoutStreakIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WorkoutStreak.t),
      orderByList: orderByList?.call(WorkoutStreak.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WorkoutStreakImpl extends WorkoutStreak {
  _WorkoutStreakImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
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
  @_is.useResult
  @override
  WorkoutStreak copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    int? currentStreak,
    String? lastCompletedDate,
  }) {
    return WorkoutStreak(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      currentStreak: currentStreak ?? this.currentStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }
}

class WorkoutStreakUpdateTable extends _is.UpdateTable<WorkoutStreakTable> {
  WorkoutStreakUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<int, int> currentStreak(int value) => _is.ColumnValue(
    table.currentStreak,
    value,
  );

  _is.ColumnValue<String, String> lastCompletedDate(String value) =>
      _is.ColumnValue(
        table.lastCompletedDate,
        value,
      );
}

class WorkoutStreakTable extends _is.Table<int?> {
  WorkoutStreakTable({super.tableRelation})
    : super(tableName: 'workout_streak') {
    updateTable = WorkoutStreakUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    currentStreak = _is.ColumnInt(
      'currentStreak',
      this,
    );
    lastCompletedDate = _is.ColumnString(
      'lastCompletedDate',
      this,
    );
  }

  late final WorkoutStreakUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnInt currentStreak;

  late final _is.ColumnString lastCompletedDate;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: WorkoutStreak.t.authUserId,
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
    currentStreak,
    lastCompletedDate,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class WorkoutStreakInclude extends _is.IncludeObject {
  WorkoutStreakInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => WorkoutStreak.t;
}

class WorkoutStreakIncludeList extends _is.IncludeList {
  WorkoutStreakIncludeList._({
    _is.WhereExpressionBuilder<WorkoutStreakTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WorkoutStreak.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => WorkoutStreak.t;
}

class WorkoutStreakRepository {
  const WorkoutStreakRepository._();

  final attachRow = const WorkoutStreakAttachRowRepository._();

  /// Returns a list of [WorkoutStreak]s matching the given query parameters.
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
  Future<List<WorkoutStreak>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkoutStreakTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkoutStreakTable>? orderBy,
    _is.OrderByListBuilder<WorkoutStreakTable>? orderByList,
    _is.Transaction? transaction,
    WorkoutStreakInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WorkoutStreak>(
      where: where?.call(WorkoutStreak.t),
      orderBy: orderBy?.call(WorkoutStreak.t),
      orderByList: orderByList?.call(WorkoutStreak.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [WorkoutStreak] matching the given query parameters.
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
  Future<WorkoutStreak?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkoutStreakTable>? where,
    int? offset,
    _is.OrderByBuilder<WorkoutStreakTable>? orderBy,
    _is.OrderByListBuilder<WorkoutStreakTable>? orderByList,
    _is.Transaction? transaction,
    WorkoutStreakInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WorkoutStreak>(
      where: where?.call(WorkoutStreak.t),
      orderBy: orderBy?.call(WorkoutStreak.t),
      orderByList: orderByList?.call(WorkoutStreak.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WorkoutStreak] by its [id] or null if no such row exists.
  Future<WorkoutStreak?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    WorkoutStreakInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WorkoutStreak>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WorkoutStreak]s in the list and returns the inserted rows.
  ///
  /// The returned [WorkoutStreak]s will have their `id` fields set.
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
  Future<List<WorkoutStreak>> insert(
    _is.DatabaseSession session,
    List<WorkoutStreak> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WorkoutStreak>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WorkoutStreak] and returns the inserted row.
  ///
  /// The returned [WorkoutStreak] will have its `id` field set.
  Future<WorkoutStreak> insertRow(
    _is.DatabaseSession session,
    WorkoutStreak row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WorkoutStreak>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WorkoutStreak]s in the list and returns the resulting rows.
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
  /// The returned [WorkoutStreak]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkoutStreak>> upsert(
    _is.DatabaseSession session,
    List<WorkoutStreak> rows, {
    required _is.ColumnSelections<WorkoutStreakTable> conflictColumns,
    _is.ColumnSelections<WorkoutStreakTable>? updateColumns,
    _is.WhereExpressionBuilder<WorkoutStreakTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WorkoutStreak>(
      rows,
      conflictColumns: conflictColumns(WorkoutStreak.t),
      updateColumns: updateColumns?.call(WorkoutStreak.t),
      updateWhere: updateWhere?.call(WorkoutStreak.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WorkoutStreak] and returns the resulting row.
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
  /// The returned [WorkoutStreak] will have its `id` field set.
  Future<WorkoutStreak?> upsertRow(
    _is.DatabaseSession session,
    WorkoutStreak row, {
    required _is.ColumnSelections<WorkoutStreakTable> conflictColumns,
    _is.ColumnSelections<WorkoutStreakTable>? updateColumns,
    _is.WhereExpressionBuilder<WorkoutStreakTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WorkoutStreak>(
      row,
      conflictColumns: conflictColumns(WorkoutStreak.t),
      updateColumns: updateColumns?.call(WorkoutStreak.t),
      updateWhere: updateWhere?.call(WorkoutStreak.t),
      transaction: transaction,
    );
  }

  /// Updates all [WorkoutStreak]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkoutStreak>> update(
    _is.DatabaseSession session,
    List<WorkoutStreak> rows, {
    _is.ColumnSelections<WorkoutStreakTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WorkoutStreak>(
      rows,
      columns: columns?.call(WorkoutStreak.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WorkoutStreak]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WorkoutStreak> updateRow(
    _is.DatabaseSession session,
    WorkoutStreak row, {
    _is.ColumnSelections<WorkoutStreakTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WorkoutStreak>(
      row,
      columns: columns?.call(WorkoutStreak.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WorkoutStreak] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WorkoutStreak?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<WorkoutStreakUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WorkoutStreak>(
      id,
      columnValues: columnValues(WorkoutStreak.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WorkoutStreak]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkoutStreak>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WorkoutStreakUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<WorkoutStreakTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkoutStreakTable>? orderBy,
    _is.OrderByListBuilder<WorkoutStreakTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WorkoutStreak>(
      columnValues: columnValues(WorkoutStreak.t.updateTable),
      where: where(WorkoutStreak.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WorkoutStreak.t),
      orderByList: orderByList?.call(WorkoutStreak.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WorkoutStreak]s in the list and returns the deleted rows.
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
  Future<List<WorkoutStreak>> delete(
    _is.DatabaseSession session,
    List<WorkoutStreak> rows, {
    _is.OrderByBuilder<WorkoutStreakTable>? orderBy,
    _is.OrderByListBuilder<WorkoutStreakTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WorkoutStreak>(
      rows,
      orderBy: orderBy?.call(WorkoutStreak.t),
      orderByList: orderByList?.call(WorkoutStreak.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WorkoutStreak].
  Future<WorkoutStreak> deleteRow(
    _is.DatabaseSession session,
    WorkoutStreak row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WorkoutStreak>(
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
  Future<List<WorkoutStreak>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WorkoutStreakTable> where,
    _is.OrderByBuilder<WorkoutStreakTable>? orderBy,
    _is.OrderByListBuilder<WorkoutStreakTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WorkoutStreak>(
      where: where(WorkoutStreak.t),
      orderBy: orderBy?.call(WorkoutStreak.t),
      orderByList: orderByList?.call(WorkoutStreak.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkoutStreakTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WorkoutStreak>(
      where: where?.call(WorkoutStreak.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WorkoutStreak] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WorkoutStreakTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WorkoutStreak>(
      where: where(WorkoutStreak.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class WorkoutStreakAttachRowRepository {
  const WorkoutStreakAttachRowRepository._();

  /// Creates a relation between the given [WorkoutStreak] and [AuthUser]
  /// by setting the [WorkoutStreak]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    WorkoutStreak workoutStreak,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (workoutStreak.id == null) {
      throw ArgumentError.notNull('workoutStreak.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $workoutStreak = workoutStreak.copyWith(authUserId: authUser.id);
    await session.db.updateRow<WorkoutStreak>(
      $workoutStreak,
      columns: [WorkoutStreak.t.authUserId],
      transaction: transaction,
    );
  }
}
