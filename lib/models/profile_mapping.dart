import 'package:digigym_backend_client/digigym_backend_client.dart';

import 'user_profile.dart';

FitnessLevel fitnessLevelToBackend(String value) => switch (value) {
  'Beginner' => FitnessLevel.beginner,
  'Intermediate' => FitnessLevel.intermediate,
  'Advanced' => FitnessLevel.advanced,
  _ => throw ArgumentError.value(value, 'value', 'Unknown fitness level'),
};

String fitnessLevelFromBackend(FitnessLevel value) => switch (value) {
  FitnessLevel.beginner => 'Beginner',
  FitnessLevel.intermediate => 'Intermediate',
  FitnessLevel.advanced => 'Advanced',
};

FitnessGoal fitnessGoalToBackend(String value) => switch (value) {
  'Lose Weight' => FitnessGoal.loseWeight,
  'Build Muscle' => FitnessGoal.buildMuscle,
  'Gain Weight' => FitnessGoal.gainWeight,
  'Maintain Weight' => FitnessGoal.maintainWeight,
  _ => throw ArgumentError.value(value, 'value', 'Unknown fitness goal'),
};

String fitnessGoalFromBackend(FitnessGoal value) => switch (value) {
  FitnessGoal.loseWeight => 'Lose Weight',
  FitnessGoal.buildMuscle => 'Build Muscle',
  FitnessGoal.gainWeight => 'Gain Weight',
  FitnessGoal.maintainWeight => 'Maintain Weight',
};

UserProfile userProfileFromBackend(
  DigiGymUser profile, {
  required String email,
}) => UserProfile(
  accountId: profile.authUserId.toString(),
  name: profile.name,
  email: email,
  age: profile.age,
  height: profile.height,
  weight: profile.weight,
  fitnessLevel: fitnessLevelFromBackend(profile.fitnessLevel),
  fitnessGoal: fitnessGoalFromBackend(profile.fitnessGoal),
  workoutTime: profile.workoutTime,
  dietaryPreference: profile.dietaryPreference,
  bodyType: profile.bodyType,
);
