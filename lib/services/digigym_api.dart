import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    hide UserProfile;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show
        EmailAccountPasswordResetException,
        EmailAccountPasswordResetExceptionReason;
import 'package:digigym_backend_client/digigym_backend_client.dart'
    show CompletedWorkout;

import '../client.dart';
import '../models/profile_mapping.dart';
import '../models/user_profile.dart';

class ProfileSetupRequiredException implements Exception {
  final String email;
  final UserProfile? profile;

  const ProfileSetupRequiredException(this.email, {this.profile});
}

/// An authenticated account has no row that updateMyProfile can update.
/// Recovery requires backend support; never treat this as a writable draft.
class MissingFitnessProfileException implements Exception {
  const MissingFitnessProfileException();

  static const message =
      'Your account is missing its fitness profile. Try again, or contact '
      'the DigiGym team if the problem continues.';
}

enum PasswordRecoveryFailure {
  invalid,
  expired,
  policyViolation,
  tooManyAttempts,
  unavailable,
}

/// Safe recovery errors; never carries server messages, passwords or tokens.
class PasswordRecoveryException implements Exception {
  final PasswordRecoveryFailure reason;
  const PasswordRecoveryException(this.reason);
}

/// Frontend-facing wrapper around DigiGym's Serverpod API.
///
/// Keeping the API boundary here makes the screens testable without a live
/// backend while preserving the generated client as the source of truth.
class DigiGymApi {
  const DigiGymApi();

  bool get isAuthenticated => client.auth.isAuthenticated;

  Future<String> startPasswordReset(String email) => _recover(() async {
    final id = await client.emailIdp.startPasswordReset(email: email);
    return id.toString();
  });

  Future<String> verifyPasswordResetCode({
    required String passwordResetRequestId,
    required String verificationCode,
  }) => _recover(
    () => client.emailIdp.verifyPasswordResetCode(
      passwordResetRequestId: UuidValue.withValidation(passwordResetRequestId),
      verificationCode: verificationCode,
    ),
  );

  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => _recover(
    () => client.emailIdp.finishPasswordReset(
      finishPasswordResetToken: finishPasswordResetToken,
      newPassword: newPassword,
    ),
  );

  // Recovery never signs in, signs out, or updates stored authentication tokens.
  Future<T> _recover<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on EmailAccountPasswordResetException catch (error) {
      throw PasswordRecoveryException(switch (error.reason) {
        EmailAccountPasswordResetExceptionReason.invalid =>
          PasswordRecoveryFailure.invalid,
        EmailAccountPasswordResetExceptionReason.expired =>
          PasswordRecoveryFailure.expired,
        EmailAccountPasswordResetExceptionReason.policyViolation =>
          PasswordRecoveryFailure.policyViolation,
        EmailAccountPasswordResetExceptionReason.tooManyAttempts =>
          PasswordRecoveryFailure.tooManyAttempts,
        EmailAccountPasswordResetExceptionReason.unknown =>
          PasswordRecoveryFailure.unavailable,
      });
    } on FormatException {
      throw const PasswordRecoveryException(PasswordRecoveryFailure.invalid);
    } on ServerpodClientHttpException catch (error) {
      throw PasswordRecoveryException(
        error.statusCode == 429
            ? PasswordRecoveryFailure.tooManyAttempts
            : PasswordRecoveryFailure.unavailable,
      );
    } catch (_) {
      throw const PasswordRecoveryException(
        PasswordRecoveryFailure.unavailable,
      );
    }
  }

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
      return await _loadProfile(fallbackEmail: email);
    } on ProfileSetupRequiredException {
      rethrow;
    } catch (_) {
      await signOut();
      rethrow;
    }
  }

  Future<UserProfile?> restoreProfile() async {
    if (!isAuthenticated) return null;
    return _loadProfile();
  }

  // Login and persisted-session restoration must use the same completion gate.
  Future<UserProfile> _loadProfile({String fallbackEmail = ''}) async {
    final profile = await client.profile.getMyProfile();
    if (profile == null) throw const MissingFitnessProfileException();
    final accountProfile = await client
        .modules
        .serverpod_auth_core
        .userProfileInfo
        .get();
    final user = userProfileFromBackend(
      profile,
      email: accountProfile.email ?? fallbackEmail,
    );
    if (!user.hasCompletedAssessment) {
      throw ProfileSetupRequiredException(user.email, profile: user);
    }
    return user;
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

  Future<List<int>?> getMyWorkoutSchedule() {
    return client.workoutSchedule.getMyWorkoutSchedule();
  }

  Future<List<int>> updateMyWorkoutSchedule(List<int> workoutDays) {
    return client.workoutSchedule.updateMyWorkoutSchedule(workoutDays);
  }

  Future<CompletedWorkout> completeWorkout({
    required String workoutName,
    required int durationMinutes,
    required String details,
  }) {
    if (!isAuthenticated) {
      throw StateError('Sign in to save completed workouts.');
    }

    return client.workoutHistory.completeWorkout(
      workoutName,
      durationMinutes,
      details,
    );
  }

  /// Local calendar day as yyyy-MM-dd; the streak is counted in this day.
  static String localDay(DateTime now) {
    final local = now.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-${two(local.day)}';
  }

  /// Creates or updates the streak for a completed workout; returns it.
  Future<int> recordWorkoutCompletion(DateTime now) {
    if (!isAuthenticated) {
      throw StateError('Sign in to track workout streaks.');
    }

    return client.workoutStreak.recordCompletion(localDay(now));
  }

  /// Current streak (0 when none or broken by a missed day).
  Future<int> getWorkoutStreak(DateTime now) {
    if (!isAuthenticated) {
      throw StateError('Sign in to view workout streaks.');
    }

    return client.workoutStreak.getMyStreak(localDay(now));
  }

  Future<List<CompletedWorkout>> getWorkoutHistory() {
    if (!isAuthenticated) {
      throw StateError('Sign in to view workout history.');
    }

    return client.workoutHistory.getMyWorkoutHistory();
  }

  Future<int> deleteWorkoutHistory(List<int> workoutIds) {
    if (!isAuthenticated) {
      throw StateError('Sign in to delete workout history.');
    }

    if (workoutIds.isEmpty) {
      return Future<int>.value(0);
    }

    return client.workoutHistory.deleteMyWorkoutHistory(workoutIds);
  }

  Future<void> signOut() async {
    if (isAuthenticated) {
      await client.auth.signOutDevice();
    }
  }
}

const digiGymApi = DigiGymApi();