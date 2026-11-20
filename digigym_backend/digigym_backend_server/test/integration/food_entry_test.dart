import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Food entry data test', (sessionBuilder, endpoints) {
    Future<dynamic> authenticatedSession() async {
      final session = sessionBuilder.build();

      final authUser = await AuthUser.db.insertRow(
        session,
        AuthUser(scopeNames: {'user'}),
      );

      return sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUser.id!.toString(),
          {Scope('user')},
        ),
      );
    }

    test('adds a food entry', () async {
      final session = await authenticatedSession();

      final entry = await endpoints.foodEntry.addFoodEntry(
        session,
        'Breakfast',
        400,
        DateTime.utc(2026, 11, 19, 8),
      );

      expect(entry.name, 'Breakfast');
      expect(entry.calories, 400);
    });

    test('finds food entries for a day', () async {
      final session = await authenticatedSession();
      final day = DateTime.utc(2026, 11, 19, 8);

      await endpoints.foodEntry.addFoodEntry(
        session,
        'Breakfast',
        400,
        day,
      );

      final entries = await endpoints.foodEntry.findFoodEntries(
        session,
        day,
      );

      expect(entries, hasLength(1));
      expect(entries.first.calories, 400);
    });

    test('updates a food entry', () async {
      final session = await authenticatedSession();

      final entry = await endpoints.foodEntry.addFoodEntry(
        session,
        'Breakfast',
        200,
        DateTime.utc(2026, 11, 19, 8, 30),
      );

      final updated = await endpoints.foodEntry.updateFoodEntry(
        session,
        entry.id!,
        'Breakfast',
        200,
        entry.consumedAt,
      );

      expect(updated?.calories, 200);
    });

    test('deletes a food entry', () async {
      final session = await authenticatedSession();

      final entry = await endpoints.foodEntry.addFoodEntry(
        session,
        'Breakfast',
        400,
        DateTime.utc(2026, 11, 19, 8, 30),
      );

      await endpoints.foodEntry.deleteFoodEntry(
        session,
        entry.id!,
      );

      final entries = await endpoints.foodEntry.findFoodEntries(
        session,
        DateTime.utc(2026, 11, 19, 8, 30),
      );

      expect(entries, isEmpty);
    });
  });
}
