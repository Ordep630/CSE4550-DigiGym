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

abstract class CompletedWorkout
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String workoutName,
    required int durationMinutes,
    required String details,
    required DateTime completedAt,
  }) = _CompletedWorkoutImpl;

  factory CompletedWorkout.fromJson(Map<String, dynamic> jsonSerialization) {
    return CompletedWorkout(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iy52kuyx.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      workoutName: jsonSerialization['workoutName'] as String,
      durationMinutes: jsonSerialization['durationMinutes'] as int,
      details: jsonSerialization['details'] as String,
      completedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['completedAt'],
      ),
    );
  }

  static final t = CompletedWorkoutTable();

  static const db = CompletedWorkoutRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  String workoutName;

  int durationMinutes;

  String details;

  DateTime completedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CompletedWorkout]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CompletedWorkout copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
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

  static CompletedWorkoutInclude include({_iacs.AuthUserInclude? authUser}) {
    return CompletedWorkoutInclude._(authUser: authUser);
  }

  static CompletedWorkoutIncludeList includeList({
    _is.WhereExpressionBuilder<CompletedWorkoutTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CompletedWorkoutTable>? orderBy,
    _is.OrderByListBuilder<CompletedWorkoutTable>? orderByList,
    CompletedWorkoutInclude? include,
  }) {
    return CompletedWorkoutIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CompletedWorkout.t),
      orderByList: orderByList?.call(CompletedWorkout.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CompletedWorkoutImpl extends CompletedWorkout {
  _CompletedWorkoutImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
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
  @_is.useResult
  @override
  CompletedWorkout copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? workoutName,
    int? durationMinutes,
    String? details,
    DateTime? completedAt,
  }) {
    return CompletedWorkout(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      workoutName: workoutName ?? this.workoutName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      details: details ?? this.details,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class CompletedWorkoutUpdateTable
    extends _is.UpdateTable<CompletedWorkoutTable> {
  CompletedWorkoutUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> workoutName(String value) => _is.ColumnValue(
    table.workoutName,
    value,
  );

  _is.ColumnValue<int, int> durationMinutes(int value) => _is.ColumnValue(
    table.durationMinutes,
    value,
  );

  _is.ColumnValue<String, String> details(String value) => _is.ColumnValue(
    table.details,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> completedAt(DateTime value) =>
      _is.ColumnValue(
        table.completedAt,
        value,
      );
}

class CompletedWorkoutTable extends _is.Table<int?> {
  CompletedWorkoutTable({super.tableRelation})
    : super(tableName: 'completed_workout') {
    updateTable = CompletedWorkoutUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    workoutName = _is.ColumnString(
      'workoutName',
      this,
    );
    durationMinutes = _is.ColumnInt(
      'durationMinutes',
      this,
    );
    details = _is.ColumnString(
      'details',
      this,
    );
    completedAt = _is.ColumnDateTime(
      'completedAt',
      this,
    );
  }

  late final CompletedWorkoutUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString workoutName;

  late final _is.ColumnInt durationMinutes;

  late final _is.ColumnString details;

  late final _is.ColumnDateTime completedAt;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: CompletedWorkout.t.authUserId,
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
    workoutName,
    durationMinutes,
    details,
    completedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class CompletedWorkoutInclude extends _is.IncludeObject {
  CompletedWorkoutInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => CompletedWorkout.t;
}

class CompletedWorkoutIncludeList extends _is.IncludeList {
  CompletedWorkoutIncludeList._({
    _is.WhereExpressionBuilder<CompletedWorkoutTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CompletedWorkout.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CompletedWorkout.t;
}

class CompletedWorkoutRepository {
  const CompletedWorkoutRepository._();

  final attachRow = const CompletedWorkoutAttachRowRepository._();

  /// Returns a list of [CompletedWorkout]s matching the given query parameters.
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
  Future<List<CompletedWorkout>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CompletedWorkoutTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CompletedWorkoutTable>? orderBy,
    _is.OrderByListBuilder<CompletedWorkoutTable>? orderByList,
    _is.Transaction? transaction,
    CompletedWorkoutInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CompletedWorkout>(
      where: where?.call(CompletedWorkout.t),
      orderBy: orderBy?.call(CompletedWorkout.t),
      orderByList: orderByList?.call(CompletedWorkout.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CompletedWorkout] matching the given query parameters.
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
  Future<CompletedWorkout?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CompletedWorkoutTable>? where,
    int? offset,
    _is.OrderByBuilder<CompletedWorkoutTable>? orderBy,
    _is.OrderByListBuilder<CompletedWorkoutTable>? orderByList,
    _is.Transaction? transaction,
    CompletedWorkoutInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CompletedWorkout>(
      where: where?.call(CompletedWorkout.t),
      orderBy: orderBy?.call(CompletedWorkout.t),
      orderByList: orderByList?.call(CompletedWorkout.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CompletedWorkout] by its [id] or null if no such row exists.
  Future<CompletedWorkout?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    CompletedWorkoutInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CompletedWorkout>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CompletedWorkout]s in the list and returns the inserted rows.
  ///
  /// The returned [CompletedWorkout]s will have their `id` fields set.
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
  Future<List<CompletedWorkout>> insert(
    _is.DatabaseSession session,
    List<CompletedWorkout> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CompletedWorkout>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CompletedWorkout] and returns the inserted row.
  ///
  /// The returned [CompletedWorkout] will have its `id` field set.
  Future<CompletedWorkout> insertRow(
    _is.DatabaseSession session,
    CompletedWorkout row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CompletedWorkout>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CompletedWorkout]s in the list and returns the resulting rows.
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
  /// The returned [CompletedWorkout]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CompletedWorkout>> upsert(
    _is.DatabaseSession session,
    List<CompletedWorkout> rows, {
    required _is.ColumnSelections<CompletedWorkoutTable> conflictColumns,
    _is.ColumnSelections<CompletedWorkoutTable>? updateColumns,
    _is.WhereExpressionBuilder<CompletedWorkoutTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CompletedWorkout>(
      rows,
      conflictColumns: conflictColumns(CompletedWorkout.t),
      updateColumns: updateColumns?.call(CompletedWorkout.t),
      updateWhere: updateWhere?.call(CompletedWorkout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CompletedWorkout] and returns the resulting row.
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
  /// The returned [CompletedWorkout] will have its `id` field set.
  Future<CompletedWorkout?> upsertRow(
    _is.DatabaseSession session,
    CompletedWorkout row, {
    required _is.ColumnSelections<CompletedWorkoutTable> conflictColumns,
    _is.ColumnSelections<CompletedWorkoutTable>? updateColumns,
    _is.WhereExpressionBuilder<CompletedWorkoutTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CompletedWorkout>(
      row,
      conflictColumns: conflictColumns(CompletedWorkout.t),
      updateColumns: updateColumns?.call(CompletedWorkout.t),
      updateWhere: updateWhere?.call(CompletedWorkout.t),
      transaction: transaction,
    );
  }

  /// Updates all [CompletedWorkout]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CompletedWorkout>> update(
    _is.DatabaseSession session,
    List<CompletedWorkout> rows, {
    _is.ColumnSelections<CompletedWorkoutTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CompletedWorkout>(
      rows,
      columns: columns?.call(CompletedWorkout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CompletedWorkout]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CompletedWorkout> updateRow(
    _is.DatabaseSession session,
    CompletedWorkout row, {
    _is.ColumnSelections<CompletedWorkoutTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CompletedWorkout>(
      row,
      columns: columns?.call(CompletedWorkout.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CompletedWorkout] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CompletedWorkout?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CompletedWorkoutUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CompletedWorkout>(
      id,
      columnValues: columnValues(CompletedWorkout.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CompletedWorkout]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CompletedWorkout>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CompletedWorkoutUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CompletedWorkoutTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CompletedWorkoutTable>? orderBy,
    _is.OrderByListBuilder<CompletedWorkoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CompletedWorkout>(
      columnValues: columnValues(CompletedWorkout.t.updateTable),
      where: where(CompletedWorkout.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CompletedWorkout.t),
      orderByList: orderByList?.call(CompletedWorkout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CompletedWorkout]s in the list and returns the deleted rows.
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
  Future<List<CompletedWorkout>> delete(
    _is.DatabaseSession session,
    List<CompletedWorkout> rows, {
    _is.OrderByBuilder<CompletedWorkoutTable>? orderBy,
    _is.OrderByListBuilder<CompletedWorkoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CompletedWorkout>(
      rows,
      orderBy: orderBy?.call(CompletedWorkout.t),
      orderByList: orderByList?.call(CompletedWorkout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CompletedWorkout].
  Future<CompletedWorkout> deleteRow(
    _is.DatabaseSession session,
    CompletedWorkout row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CompletedWorkout>(
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
  Future<List<CompletedWorkout>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CompletedWorkoutTable> where,
    _is.OrderByBuilder<CompletedWorkoutTable>? orderBy,
    _is.OrderByListBuilder<CompletedWorkoutTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CompletedWorkout>(
      where: where(CompletedWorkout.t),
      orderBy: orderBy?.call(CompletedWorkout.t),
      orderByList: orderByList?.call(CompletedWorkout.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CompletedWorkoutTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CompletedWorkout>(
      where: where?.call(CompletedWorkout.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CompletedWorkout] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CompletedWorkoutTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CompletedWorkout>(
      where: where(CompletedWorkout.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class CompletedWorkoutAttachRowRepository {
  const CompletedWorkoutAttachRowRepository._();

  /// Creates a relation between the given [CompletedWorkout] and [AuthUser]
  /// by setting the [CompletedWorkout]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    CompletedWorkout completedWorkout,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (completedWorkout.id == null) {
      throw ArgumentError.notNull('completedWorkout.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $completedWorkout = completedWorkout.copyWith(authUserId: authUser.id);
    await session.db.updateRow<CompletedWorkout>(
      $completedWorkout,
      columns: [CompletedWorkout.t.authUserId],
      transaction: transaction,
    );
  }
}
