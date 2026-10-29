import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

/// Lets the currently logged-in user manage their DigiGym fitness profile.
class ProfileEndpoint extends Endpoint {
  /// Every method on this endpoint requires the caller to be logged in.
  @override
  bool get requireLogin => true;

  /* createMyProfile() created through onAfterAuthUserCreated. */

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
    FitnessLevel fitnessLevel,
    FitnessGoal fitnessGoal,
    int workoutTime,
    String dietaryPreference,
    String bodyType,
  ) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty.');
    }
    if (age < 13 || age > 100) {
      throw ArgumentError('Age must be between 13 and 100.');
    }
    if (!height.isFinite || height < 50 || height > 275) {
      throw ArgumentError('Height must be between 50 and 275 cm.');
    }
    if (!weight.isFinite || weight < 20 || weight > 500) {
      throw ArgumentError('Weight must be between 20 and 500 kg.');
    }
    if (workoutTime < 1 || workoutTime > 300) {
      throw ArgumentError('Workout time must be between 1 and 300 minutes.');
    }
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

  Future<FitnessData?> getMyFitnessData(Session session) async {
    final authUserId = session.authenticated?.authUserId;

    if (authUserId == null) {
      return null;
    }

    final profile = await DigiGymUser.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    if (profile == null) {
      return null;
    }

    return FitnessData(
      fitnessLevel: profile.fitnessLevel,
      fitnessGoal: profile.fitnessGoal,
    );
  }

  /// Updates the fitness data for the currently authenticated user.
  Future<FitnessData> updateMyFitnessData(
    Session session,
    FitnessLevel fitnessLevel,
    FitnessGoal fitnessGoal,
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
      fitnessLevel: fitnessLevel,
      fitnessGoal: fitnessGoal,
    );

    final savedProfile = await DigiGymUser.db.updateRow(
      session,
      updatedProfile,
    );

    return FitnessData(
      fitnessLevel: savedProfile.fitnessLevel,
      fitnessGoal: savedProfile.fitnessGoal,
    );
  }
}
