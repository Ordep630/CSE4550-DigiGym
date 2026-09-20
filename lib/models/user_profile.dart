class UserProfile {
  String name;
  String email;
  String password;

  int age;
  double height;
  double weight;

  String fitnessLevel;
  String fitnessGoal;
  int workoutTime;

  String dietaryPreference;
  String bodyType;

  UserProfile({
    required this.name,
    required this.email,
    required this.password,
    this.age = 20,
    this.height = 170,
    this.weight = 70,
    this.fitnessLevel = 'Beginner',
    this.fitnessGoal = 'Lose Weight',
    this.workoutTime = 30,
    this.dietaryPreference = 'No Preference',
    this.bodyType = 'Average',
  });

  double get bmi {
    if (height <= 0) return 0;

    final heightMeters = height / 100;

    return weight / (heightMeters * heightMeters);
  }

  int get estimatedCalories {
    double calories;

    // Basic estimate for prototype purposes.
    calories =
        (10 * weight) +
        (6.25 * height) -
        (5 * age) +
        5;

    if (fitnessGoal == 'Lose Weight') {
      calories -= 400;
    } else if (fitnessGoal == 'Build Muscle') {
      calories += 300;
    } else if (fitnessGoal == 'Gain Weight') {
      calories += 500;
    }

    return calories.round();
  }
}