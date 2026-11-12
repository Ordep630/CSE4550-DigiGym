import 'package:digigym/models/user_profile.dart';
import 'package:digigym/services/digigym_api.dart';
import 'package:digigym_backend_client/digigym_backend_client.dart'
    show CompletedWorkout, UuidValue;

class FakeDigiGymApi extends DigiGymApi {
  bool authenticated = false;
  String registrationRequestId = '123e4567-e89b-12d3-a456-426614174000';
  UserProfile? restoredProfile;
  UserProfile? updatedProfile;
  Object? restoreError;
  Object? loginError;
  Object? updateError;

  final Map<String, List<int>> workoutSchedules = {};
  Object? scheduleReadError;
  Object? scheduleWriteError;

  Future<void>? scheduleReadWait;
  Future<void>? scheduleWriteWait;

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

  final completedWorkoutNames = <String>[];

  @override
  Future<CompletedWorkout> completeWorkout({
    required String workoutName,
    required int durationMinutes,
    required String details,
  }) async {
    completedWorkoutNames.add(workoutName);
    return CompletedWorkout(
      authUserId: UuidValue.fromString('123e4567-e89b-12d3-a456-426614174000'),
      workoutName: workoutName,
      durationMinutes: durationMinutes,
      details: details,
      completedAt: DateTime.now().toUtc(),
    );
  }

  /// Mirrors the backend streak rules for widget tests.
  int streak = 0;
  String? lastStreakDay;
  Object? streakError;
  final streakCompletions = <DateTime>[];

  @override
  Future<int> recordWorkoutCompletion(DateTime now) async {
    if (streakError != null) throw streakError!;
    streakCompletions.add(now);
    final today = DigiGymApi.localDay(now);
    if (lastStreakDay == today) return streak;
    final last = lastStreakDay == null ? null : DateTime.parse(lastStreakDay!);
    final day = DateTime.parse(today);
    streak = last != null && day.difference(last).inDays == 1 ? streak + 1 : 1;
    lastStreakDay = today;
    return streak;
  }

  @override
  Future<int> getWorkoutStreak(DateTime now) async {
    final last = lastStreakDay;
    if (last == null) return 0;
    final gap = DateTime.parse(DigiGymApi.localDay(now))
        .difference(DateTime.parse(last))
        .inDays;
    return gap > 1 ? 0 : streak;
  }

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
  Future<List<int>?> getMyWorkoutSchedule() async {
    await scheduleReadWait;
    if (scheduleReadError != null) throw scheduleReadError!;

    final accountId = restoredProfile?.accountId;
    if (!authenticated || accountId == null) {
      throw StateError('No authenticated account.');
    }

    final days = workoutSchedules[accountId];
    return days == null ? null : List<int>.of(days);
  }

  @override
  Future<List<int>> updateMyWorkoutSchedule(List<int> workoutDays) async {
    await scheduleWriteWait;
    if (scheduleWriteError != null) throw scheduleWriteError!;

    final accountId = restoredProfile?.accountId;
    if (!authenticated || accountId == null) {
      throw StateError('No authenticated account.');
    }

    if (workoutDays.any((day) => day < 0 || day > 6) ||
        workoutDays.toSet().length != workoutDays.length) {
      throw ArgumentError('Invalid weekdays.');
    }

    final orderedDays = workoutDays.toList()..sort();
    workoutSchedules[accountId] = orderedDays;
    return List<int>.of(orderedDays);
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
