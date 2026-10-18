import 'package:digigym/models/user_profile.dart';
import 'package:digigym/services/digigym_api.dart';

class FakeDigiGymApi extends DigiGymApi {
  bool authenticated = false;
  String registrationRequestId = '123e4567-e89b-12d3-a456-426614174000';
  UserProfile? restoredProfile;
  UserProfile? updatedProfile;
  Object? restoreError;
  Object? loginError;
  Object? updateError;

  String? startedRegistrationEmail;
  String? verifiedRequestId;
  String? verifiedCode;
  String? verifiedPassword;
  String? loginEmail;
  String? loginPassword;
  UserProfile? updateRequest;
  int signOutCalls = 0;

  Future<void>? startRegistrationWait;
  Future<void>? finishRegistrationWait;
  Future<void>? loginWait;
  Future<void>? restoreWait;
  Future<void>? updateWait;
  Future<void>? signOutWait;

  @override
  bool get isAuthenticated => authenticated;

  @override
  Future<String> startRegistration(String email) async {
    startedRegistrationEmail = email;
    await startRegistrationWait;
    return registrationRequestId;
  }

  @override
  Future<void> finishRegistration({
    required String requestId,
    required String verificationCode,
    required String password,
  }) async {
    verifiedRequestId = requestId;
    verifiedCode = verificationCode;
    verifiedPassword = password;
    await finishRegistrationWait;
    authenticated = true;
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    loginEmail = email;
    loginPassword = password;
    await loginWait;
    if (loginError != null) throw loginError!;
    authenticated = true;
    return restoredProfile ?? testUser(email: email);
  }

  @override
  Future<UserProfile?> restoreProfile() async {
    await restoreWait;
    if (restoreError != null) throw restoreError!;
    return restoredProfile;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    updateRequest = profile;
    await updateWait;
    if (updateError != null) throw updateError!;
    return updatedProfile ?? profile;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    await signOutWait;
    authenticated = false;
  }
}

UserProfile testUser({
  String name = 'Test User',
  String email = 'test@example.com',
  String fitnessGoal = 'Build Muscle',
  bool isDemo = false,
}) => UserProfile(
  name: name,
  email: email,
  age: 28,
  height: 172,
  weight: 68,
  fitnessLevel: 'Intermediate',
  fitnessGoal: fitnessGoal,
  workoutTime: 45,
  dietaryPreference: 'Vegetarian',
  bodyType: 'Athletic',
  isDemo: isDemo,
);
