import 'user_profile.dart';

class DigiGymSession {
  static UserProfile? currentUser;
  static UserProfile? registeredUser;
  static UserProfile? pendingUser;
  static String? registrationRequestId;
  static String? pendingRegistrationPassword;

  static void clearRegistrationPassword() {
    pendingRegistrationPassword = null;
  }

  static void clearPendingRegistration() {
    clearRegistrationPassword();
    pendingUser = null;
    registrationRequestId = null;
  }
}
