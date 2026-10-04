import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';

/// Lets the currently logged-in user fetch their own DigiGym fitness profile.
class ProfileEndpoint extends Endpoint {
  /// Every method on this endpoint requires the caller to be logged in.
  @override
  bool get requireLogin => true;

  /// Returns the DigiGymUser profile for whoever is currently authenticated.
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
    String fitnessLevel,
    String fitnessGoal,
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
