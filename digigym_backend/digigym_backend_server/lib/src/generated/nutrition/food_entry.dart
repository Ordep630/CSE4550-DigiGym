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

abstract class FoodEntry
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  FoodEntry._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.name,
    required this.calories,
    required this.consumedAt,
  });

  factory FoodEntry({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String name,
    required int calories,
    required DateTime consumedAt,
  }) = _FoodEntryImpl;

  factory FoodEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return FoodEntry(
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
      calories: jsonSerialization['calories'] as int,
      consumedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['consumedAt'],
      ),
    );
  }

  static final t = FoodEntryTable();

  static const db = FoodEntryRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  String name;

  int calories;

  DateTime consumedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [FoodEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FoodEntry copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? name,
    int? calories,
    DateTime? consumedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FoodEntry',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'name': name,
      'calories': calories,
      'consumedAt': consumedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FoodEntry',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'name': name,
      'calories': calories,
      'consumedAt': consumedAt.toJson(),
    };
  }

  static FoodEntryInclude include({_iacs.AuthUserInclude? authUser}) {
    return FoodEntryInclude._(authUser: authUser);
  }

  static FoodEntryIncludeList includeList({
    _is.WhereExpressionBuilder<FoodEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FoodEntryTable>? orderBy,
    _is.OrderByListBuilder<FoodEntryTable>? orderByList,
    FoodEntryInclude? include,
  }) {
    return FoodEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FoodEntry.t),
      orderByList: orderByList?.call(FoodEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FoodEntryImpl extends FoodEntry {
  _FoodEntryImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String name,
    required int calories,
    required DateTime consumedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         name: name,
         calories: calories,
         consumedAt: consumedAt,
       );

  /// Returns a shallow copy of this [FoodEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FoodEntry copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? name,
    int? calories,
    DateTime? consumedAt,
  }) {
    return FoodEntry(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      name: name ?? this.name,
      calories: calories ?? this.calories,
      consumedAt: consumedAt ?? this.consumedAt,
    );
  }
}

class FoodEntryUpdateTable extends _is.UpdateTable<FoodEntryTable> {
  FoodEntryUpdateTable(super.table);

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

  _is.ColumnValue<int, int> calories(int value) => _is.ColumnValue(
    table.calories,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> consumedAt(DateTime value) =>
      _is.ColumnValue(
        table.consumedAt,
        value,
      );
}

class FoodEntryTable extends _is.Table<int?> {
  FoodEntryTable({super.tableRelation}) : super(tableName: 'food_entry') {
    updateTable = FoodEntryUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    calories = _is.ColumnInt(
      'calories',
      this,
    );
    consumedAt = _is.ColumnDateTime(
      'consumedAt',
      this,
    );
  }

  late final FoodEntryUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString name;

  late final _is.ColumnInt calories;

  late final _is.ColumnDateTime consumedAt;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: FoodEntry.t.authUserId,
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
    calories,
    consumedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class FoodEntryInclude extends _is.IncludeObject {
  FoodEntryInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => FoodEntry.t;
}

class FoodEntryIncludeList extends _is.IncludeList {
  FoodEntryIncludeList._({
    _is.WhereExpressionBuilder<FoodEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FoodEntry.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => FoodEntry.t;
}

class FoodEntryRepository {
  const FoodEntryRepository._();

  final attachRow = const FoodEntryAttachRowRepository._();

  /// Returns a list of [FoodEntry]s matching the given query parameters.
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
  Future<List<FoodEntry>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FoodEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FoodEntryTable>? orderBy,
    _is.OrderByListBuilder<FoodEntryTable>? orderByList,
    _is.Transaction? transaction,
    FoodEntryInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FoodEntry>(
      where: where?.call(FoodEntry.t),
      orderBy: orderBy?.call(FoodEntry.t),
      orderByList: orderByList?.call(FoodEntry.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FoodEntry] matching the given query parameters.
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
  Future<FoodEntry?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FoodEntryTable>? where,
    int? offset,
    _is.OrderByBuilder<FoodEntryTable>? orderBy,
    _is.OrderByListBuilder<FoodEntryTable>? orderByList,
    _is.Transaction? transaction,
    FoodEntryInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FoodEntry>(
      where: where?.call(FoodEntry.t),
      orderBy: orderBy?.call(FoodEntry.t),
      orderByList: orderByList?.call(FoodEntry.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FoodEntry] by its [id] or null if no such row exists.
  Future<FoodEntry?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    FoodEntryInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FoodEntry>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FoodEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [FoodEntry]s will have their `id` fields set.
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
  Future<List<FoodEntry>> insert(
    _is.DatabaseSession session,
    List<FoodEntry> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FoodEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FoodEntry] and returns the inserted row.
  ///
  /// The returned [FoodEntry] will have its `id` field set.
  Future<FoodEntry> insertRow(
    _is.DatabaseSession session,
    FoodEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FoodEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FoodEntry]s in the list and returns the resulting rows.
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
  /// The returned [FoodEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FoodEntry>> upsert(
    _is.DatabaseSession session,
    List<FoodEntry> rows, {
    required _is.ColumnSelections<FoodEntryTable> conflictColumns,
    _is.ColumnSelections<FoodEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<FoodEntryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FoodEntry>(
      rows,
      conflictColumns: conflictColumns(FoodEntry.t),
      updateColumns: updateColumns?.call(FoodEntry.t),
      updateWhere: updateWhere?.call(FoodEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FoodEntry] and returns the resulting row.
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
  /// The returned [FoodEntry] will have its `id` field set.
  Future<FoodEntry?> upsertRow(
    _is.DatabaseSession session,
    FoodEntry row, {
    required _is.ColumnSelections<FoodEntryTable> conflictColumns,
    _is.ColumnSelections<FoodEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<FoodEntryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FoodEntry>(
      row,
      conflictColumns: conflictColumns(FoodEntry.t),
      updateColumns: updateColumns?.call(FoodEntry.t),
      updateWhere: updateWhere?.call(FoodEntry.t),
      transaction: transaction,
    );
  }

  /// Updates all [FoodEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FoodEntry>> update(
    _is.DatabaseSession session,
    List<FoodEntry> rows, {
    _is.ColumnSelections<FoodEntryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FoodEntry>(
      rows,
      columns: columns?.call(FoodEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FoodEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FoodEntry> updateRow(
    _is.DatabaseSession session,
    FoodEntry row, {
    _is.ColumnSelections<FoodEntryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FoodEntry>(
      row,
      columns: columns?.call(FoodEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FoodEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FoodEntry?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FoodEntryUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FoodEntry>(
      id,
      columnValues: columnValues(FoodEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FoodEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FoodEntry>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FoodEntryUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FoodEntryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FoodEntryTable>? orderBy,
    _is.OrderByListBuilder<FoodEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FoodEntry>(
      columnValues: columnValues(FoodEntry.t.updateTable),
      where: where(FoodEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FoodEntry.t),
      orderByList: orderByList?.call(FoodEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FoodEntry]s in the list and returns the deleted rows.
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
  Future<List<FoodEntry>> delete(
    _is.DatabaseSession session,
    List<FoodEntry> rows, {
    _is.OrderByBuilder<FoodEntryTable>? orderBy,
    _is.OrderByListBuilder<FoodEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FoodEntry>(
      rows,
      orderBy: orderBy?.call(FoodEntry.t),
      orderByList: orderByList?.call(FoodEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FoodEntry].
  Future<FoodEntry> deleteRow(
    _is.DatabaseSession session,
    FoodEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FoodEntry>(
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
  Future<List<FoodEntry>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FoodEntryTable> where,
    _is.OrderByBuilder<FoodEntryTable>? orderBy,
    _is.OrderByListBuilder<FoodEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FoodEntry>(
      where: where(FoodEntry.t),
      orderBy: orderBy?.call(FoodEntry.t),
      orderByList: orderByList?.call(FoodEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FoodEntryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FoodEntry>(
      where: where?.call(FoodEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FoodEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FoodEntryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FoodEntry>(
      where: where(FoodEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class FoodEntryAttachRowRepository {
  const FoodEntryAttachRowRepository._();

  /// Creates a relation between the given [FoodEntry] and [AuthUser]
  /// by setting the [FoodEntry]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    FoodEntry foodEntry,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (foodEntry.id == null) {
      throw ArgumentError.notNull('foodEntry.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $foodEntry = foodEntry.copyWith(authUserId: authUser.id);
    await session.db.updateRow<FoodEntry>(
      $foodEntry,
      columns: [FoodEntry.t.authUserId],
      transaction: transaction,
    );
  }
}
