import 'package:test/test.dart';
import 'package:digigym_backend_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('User persistence', (sessionBuilder, endpoints) {
    test('create and retrieve user', () async {
      final session = sessionBuilder.build();

      final user = User(
        name: 'Test User',
        email: 'test@example.com',
        passwordHash: 'test-hash',
        age: 25,
        height: 175.0,
        weight: 75.0,
        fitnessLevel: 'beginner',
        fitnessGoal: 'strength',
        workoutTime: 45,
        dietaryPreference: 'none',
        bodyType: 'average',
      );

      final created = await User.db.insertRow(session, user);

      final fetched = await User.db.findById(session, created.id!);

      expect(fetched, isNotNull);
      expect(fetched!.email, 'test@example.com');
      expect(fetched.name, 'Test User');
    });
  });
}