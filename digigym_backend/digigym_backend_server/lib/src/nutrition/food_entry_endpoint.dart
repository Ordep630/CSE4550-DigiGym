import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

class FoodEntryEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<FoodEntry> addFoodEntry( // add a food entry to the database in user's session
    Session session,
    String name,
    int calories,
    DateTime consumedAt,
  ) async {
    final authUserId = session.authenticated?.authUserId;
    if (authUserId == null) {
      throw StateError('User is not authenticated');
    }

    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name');
    }

    if (calories < 0) {
      throw ArgumentError.value(calories, 'calories');
    }

    return FoodEntry.db.insertRow(
      session,
      FoodEntry(
        authUserId: authUserId,
        name: name.trim(),
        calories: calories,
        consumedAt: consumedAt.toUtc(),
      ),
    );    
  }

  Future<List<FoodEntry>> findFoodEntries( // update and retrieve daily food entries in ascending order 
    Session session,
    DateTime day,
  ) async {
    final authUserId = session.authenticated?.authUserId;
    if (authUserId == null) { 
      throw StateError('User is not authenticated');
    }

    final dayUtc = day.toUtc();
    final start = DateTime.utc(dayUtc.year, dayUtc.month, dayUtc.day);
    final end = start.add(const Duration(days: 1));

    return FoodEntry.db.find(
      session,
      where: (t) => 
        t.authUserId.equals(authUserId) &
        (t.consumedAt >= start) &
        (t.consumedAt < end),
    orderBy: (t) => t.consumedAt.asc()
    );
  }

  Future<FoodEntry?> updateFoodEntry( // update a food entry in the database in user's session
    Session session,
    int entryId,
    String name,
    int calories,
    DateTime consumedAt,
  ) async {
    final authUserId = session.authenticated?.authUserId;
    if (authUserId == null) {
      throw StateError('User is not authenticated');
    }
    
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name');      
    }

    if (calories < 0) {
      throw ArgumentError.value(calories, 'calories');
    }

    final existingEntry = await FoodEntry.db.findFirstRow(
      session,
      where: (t) => 
        t.id.equals(entryId) & t.authUserId.equals(authUserId),
     );
    
    if (existingEntry == null) {
    return null;
    }

    return FoodEntry.db.updateRow(session,
    existingEntry.copyWith(
      name: name.trim(),
      calories: calories,
      consumedAt: consumedAt.toUtc()
      ),
    );
  } 

  Future<bool> deleteFoodEntry( // delete a user's food entry from the database from auth. session
    Session session,
    int entryId,
  )   async {
    final authUserId = session.authenticated?.authUserId;

    if (authUserId == null) {
      throw StateError('User is not authenticated.');
    }
      final deleted = await FoodEntry.db.deleteWhere(
        session,
        where: (t) =>
          t.id.equals(entryId) & t.authUserId.equals(authUserId),
      );
      return deleted.isNotEmpty;
    }
}