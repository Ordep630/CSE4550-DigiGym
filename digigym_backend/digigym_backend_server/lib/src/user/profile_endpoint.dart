import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

/// Lets the currently logged-in user manage their DigiGym fitness profile.
class ProfileEndpoint extends Endpoint {
  /// Every method on this endpoint requires the caller to be logged in.
  @override
  bool get requireLogin => true;

  /// Creates a DigiGym profile for the currently authenticated user.
  Future<DigiGymUser> createMyProfile(
    Session session,
    String name,
    int age,
    double height,
    double weight,
    String fitnessLevel,
    String fitnessGoal,
    int workoutTime,
    String dietaryPreference,
    String bodyType,
  ) async {
    final authUserId = session.authenticated?.authUserId;

    if (authUserId == null) {
      throw StateError('User is not authenticated.');
    }

    final existingProfile = await DigiGymUser.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    if (existingProfile != null) {
      throw StateError('User profile already exists.');
    }

    final profile = DigiGymUser(
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

    return await DigiGymUser.db.insertRow(session, profile);
  }

  /// Returns the DigiGym profile for the currently authenticated user.
  Future<DigiGymUser?> getMyProfile(Session session) async {
    final authUserId = session.authenticated?.authUserId;

    if (authUserId == null) {
      return null;
    }

    return await DigiGymUser.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
  }

  /// Updates the DigiGym profile of the currently authenticated user.
  Future<DigiGymUser> updateMyProfile(
    Session session,
    String name,
    int age,
    double height,
    double weight,
    String fitnessLevel,
    String fitnessGoal,
    int workoutTime,
    String dietaryPreference,
    String bodyType,
  ) async {
    final authUserId = session.authenticated?.authUserId;

    if (authUserId == null) {
      throw StateError('User is not authenticated.');
    }

    final profile = await DigiGymUser.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    if (profile == null) {
      throw StateError('User profile not found.');
    }

    final updatedProfile = profile.copyWith(
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

    return await DigiGymUser.db.updateRow(
      session,
      updatedProfile,
    );
  }
}
