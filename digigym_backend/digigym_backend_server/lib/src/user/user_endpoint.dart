import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class UserEndpoint extends Endpoint {
  Future<DigiGymUser> createProfile(
    Session session, {
    required String name,
    required int age,
    required double height,
    required double weight,
    required String fitnessLevel,
    required String fitnessGoal,
    required int workoutTime,
    required String dietaryPreference,
    required String bodyType,
  }) async {
    final authenticated = session.authenticated;

    if (authenticated == null) {
      throw Exception('User must be logged in.');
    }

    final authUserId = UuidValue.fromString(authenticated.userIdentifier);

    final user = DigiGymUser(
      authUserId: authUserId,
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

    final existingUser = await DigiGymUser.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    if (existingUser != null) {
      return existingUser;
      }

    return await DigiGymUser.db.insertRow(session, user);
  }
  
  Future<DigiGymUser?> getProfile(Session session) async {
  final authenticated = session.authenticated;

  if (authenticated == null) {
    return null;
  }

  final authUserId = UuidValue.fromString(
    authenticated.userIdentifier,
  );

  return await DigiGymUser.db.findFirstRow(
    session,
    where: (t) => t.authUserId.equals(authUserId),
  );
}
}