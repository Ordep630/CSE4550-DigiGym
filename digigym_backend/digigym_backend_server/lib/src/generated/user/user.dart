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
import 'package:serverpod/serverpod.dart' as _is;

/// A DigiGym user account and fitness profile
abstract class User implements _is.TableRow<int?>, _is.ProtocolSerialization {
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

  static final t = UserTable();

  static const db = UserRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static UserInclude include() {
    return UserInclude._();
  }

  static UserIncludeList includeList({
    _is.WhereExpressionBuilder<UserTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    UserInclude? include,
  }) {
    return UserIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class UserUpdateTable extends _is.UpdateTable<UserTable> {
  UserUpdateTable(super.table);

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> email(String value) => _is.ColumnValue(
    table.email,
    value,
  );

  _is.ColumnValue<String, String> passwordHash(String value) => _is.ColumnValue(
    table.passwordHash,
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

  _is.ColumnValue<String, String> fitnessLevel(String value) => _is.ColumnValue(
    table.fitnessLevel,
    value,
  );

  _is.ColumnValue<String, String> fitnessGoal(String value) => _is.ColumnValue(
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

class UserTable extends _is.Table<int?> {
  UserTable({super.tableRelation}) : super(tableName: 'digigym_user') {
    updateTable = UserUpdateTable(this);
    name = _is.ColumnString(
      'name',
      this,
    );
    email = _is.ColumnString(
      'email',
      this,
    );
    passwordHash = _is.ColumnString(
      'passwordHash',
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
    fitnessLevel = _is.ColumnString(
      'fitnessLevel',
      this,
    );
    fitnessGoal = _is.ColumnString(
      'fitnessGoal',
      this,
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

  late final UserUpdateTable updateTable;

  /// The user's display name.
  late final _is.ColumnString name;

  /// The user's email address, used to log in.
  late final _is.ColumnString email;

  /// A securely hashed version of the user's password.
  late final _is.ColumnString passwordHash;

  /// The user's age in years
  late final _is.ColumnInt age;

  /// The user's height in centimeters.
  late final _is.ColumnDouble height;

  /// The user's weight in kilograms.
  late final _is.ColumnDouble weight;

  /// The user's fitness experience level.
  late final _is.ColumnString fitnessLevel;

  /// The user's fitness goal.
  late final _is.ColumnString fitnessGoal;

  /// How many minutes the user has available to work out.
  late final _is.ColumnInt workoutTime;

  /// The user's dietary preference.
  late final _is.ColumnString dietaryPreference;

  /// The user's body type
  late final _is.ColumnString bodyType;

  @override
  List<_is.Column> get columns => [
    id,
    name,
    email,
    passwordHash,
    age,
    height,
    weight,
    fitnessLevel,
    fitnessGoal,
    workoutTime,
    dietaryPreference,
    bodyType,
  ];
}

class UserInclude extends _is.IncludeObject {
  UserInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => User.t;
}

class UserIncludeList extends _is.IncludeList {
  UserIncludeList._({
    _is.WhereExpressionBuilder<UserTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(User.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => User.t;
}

class UserRepository {
  const UserRepository._();

  /// Returns a list of [User]s matching the given query parameters.
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
  Future<List<User>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<User>(
      where: where?.call(User.t),
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [User] matching the given query parameters.
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
  Future<User?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserTable>? where,
    int? offset,
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<User>(
      where: where?.call(User.t),
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [User] by its [id] or null if no such row exists.
  Future<User?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<User>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [User]s in the list and returns the inserted rows.
  ///
  /// The returned [User]s will have their `id` fields set.
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
  Future<List<User>> insert(
    _is.DatabaseSession session,
    List<User> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<User>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [User] and returns the inserted row.
  ///
  /// The returned [User] will have its `id` field set.
  Future<User> insertRow(
    _is.DatabaseSession session,
    User row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<User>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [User]s in the list and returns the resulting rows.
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
  /// The returned [User]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<User>> upsert(
    _is.DatabaseSession session,
    List<User> rows, {
    required _is.ColumnSelections<UserTable> conflictColumns,
    _is.ColumnSelections<UserTable>? updateColumns,
    _is.WhereExpressionBuilder<UserTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<User>(
      rows,
      conflictColumns: conflictColumns(User.t),
      updateColumns: updateColumns?.call(User.t),
      updateWhere: updateWhere?.call(User.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [User] and returns the resulting row.
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
  /// The returned [User] will have its `id` field set.
  Future<User?> upsertRow(
    _is.DatabaseSession session,
    User row, {
    required _is.ColumnSelections<UserTable> conflictColumns,
    _is.ColumnSelections<UserTable>? updateColumns,
    _is.WhereExpressionBuilder<UserTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<User>(
      row,
      conflictColumns: conflictColumns(User.t),
      updateColumns: updateColumns?.call(User.t),
      updateWhere: updateWhere?.call(User.t),
      transaction: transaction,
    );
  }

  /// Updates all [User]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<User>> update(
    _is.DatabaseSession session,
    List<User> rows, {
    _is.ColumnSelections<UserTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<User>(
      rows,
      columns: columns?.call(User.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [User]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<User> updateRow(
    _is.DatabaseSession session,
    User row, {
    _is.ColumnSelections<UserTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<User>(
      row,
      columns: columns?.call(User.t),
      transaction: transaction,
    );
  }

  /// Updates a single [User] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<User?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<UserUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<User>(
      id,
      columnValues: columnValues(User.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [User]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<User>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<UserUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<UserTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<User>(
      columnValues: columnValues(User.t.updateTable),
      where: where(User.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [User]s in the list and returns the deleted rows.
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
  Future<List<User>> delete(
    _is.DatabaseSession session,
    List<User> rows, {
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<User>(
      rows,
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [User].
  Future<User> deleteRow(
    _is.DatabaseSession session,
    User row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<User>(
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
  Future<List<User>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserTable> where,
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<User>(
      where: where(User.t),
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<User>(
      where: where?.call(User.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [User] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<User>(
      where: where(User.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
