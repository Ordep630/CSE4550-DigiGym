import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    hide UserProfile;

import '../client.dart';
import '../models/profile_mapping.dart';
import '../models/user_profile.dart';

class ProfileSetupRequiredException implements Exception {
  final String email;

  const ProfileSetupRequiredException(this.email);
}

/// Frontend-facing wrapper around DigiGym's Serverpod API.
///
/// Keeping the API boundary here makes the screens testable without a live
/// backend while preserving the generated client as the source of truth.
class DigiGymApi {
  const DigiGymApi();

  bool get isAuthenticated => client.auth.isAuthenticated;

  Future<String> startRegistration(String email) async {
    final requestId = await client.emailIdp.startRegistration(email: email);
    return requestId.toString();
  }

  Future<void> finishRegistration({
    required String requestId,
    required String verificationCode,
    required String password,
  }) async {
    final registrationToken = await client.emailIdp.verifyRegistrationCode(
      accountRequestId: UuidValue.fromString(requestId),
      verificationCode: verificationCode,
    );
    final authSuccess = await client.emailIdp.finishRegistration(
      registrationToken: registrationToken,
      password: password,
    );
    await client.auth.updateSignedInUser(authSuccess);
  }

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    try {
      final authSuccess = await client.emailIdp.login(
        email: email,
        password: password,
      );
      await client.auth.updateSignedInUser(authSuccess);

      final profile = await client.profile.getMyProfile();
      final accountProfile = await client
          .modules
          .serverpod_auth_core
          .userProfileInfo
          .get();
      if (profile == null) {
        throw ProfileSetupRequiredException(accountProfile.email ?? email);
      }

      return userProfileFromBackend(
        profile,
        email: accountProfile.email ?? email,
      );
    } on ProfileSetupRequiredException {
      rethrow;
    } catch (_) {
      await signOut();
      rethrow;
    }
  }

  Future<UserProfile?> restoreProfile() async {
    if (!isAuthenticated) return null;

    final profile = await client.profile.getMyProfile();
    final accountProfile = await client
        .modules
        .serverpod_auth_core
        .userProfileInfo
        .get();
    if (profile == null) {
      throw ProfileSetupRequiredException(accountProfile.email ?? '');
    }

    return userProfileFromBackend(profile, email: accountProfile.email ?? '');
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final updatedProfile = await client.profile.updateMyProfile(
      profile.name,
      profile.age,
      profile.height,
      profile.weight,
      fitnessLevelToBackend(profile.fitnessLevel),
      fitnessGoalToBackend(profile.fitnessGoal),
      profile.workoutTime,
      profile.dietaryPreference,
      profile.bodyType,
    );
    return userProfileFromBackend(updatedProfile, email: profile.email);
  }

  Future<void> signOut() async {
    if (isAuthenticated) {
      await client.auth.signOutDevice();
    }
  }
}

const digiGymApi = DigiGymApi();
