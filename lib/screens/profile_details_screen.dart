import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../utils/measurement_units.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/profile_components.dart';
import '../widgets/profile_information.dart';

/// Reads the same profile supplied by HomeScreen, without copying or persisting it.
class ProfileDetailsScreen extends StatelessWidget {
  final UserProfile user;

  const ProfileDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ProfileInformation(title: 'Name', value: user.name, connected: true),
      ProfileInformation(title: 'Email', value: user.email, connected: true),
      ProfileInformation(
        title: 'Age',
        value: '${user.age} years',
        connected: true,
      ),
      ProfileInformation(
        title: 'Height',
        value: MeasurementUnits.formatHeight(user.height),
        connected: true,
      ),
      ProfileInformation(
        title: 'Weight',
        value: MeasurementUnits.formatWeight(user.weight),
        connected: true,
      ),
      ProfileInformation(
        title: 'BMI',
        value: user.bmi.toStringAsFixed(1),
        connected: true,
      ),
      ProfileInformation(
        title: 'Fitness Level',
        value: user.fitnessLevel,
        connected: true,
        valueColor: DigiGymFitnessLevelColors.forLevel(user.fitnessLevel),
      ),
      ProfileInformation(
        title: 'Fitness Goal',
        value: user.fitnessGoal,
        connected: true,
      ),
      ProfileInformation(
        title: 'Workout Time',
        value: '${user.workoutTime} minutes',
        connected: true,
      ),
      ProfileInformation(
        title: 'Diet',
        value: user.dietaryPreference,
        connected: true,
      ),
      if (user.bodyType.trim().isNotEmpty)
        ProfileInformation(
          title: 'Body Type',
          value: user.bodyType,
          connected: true,
        ),
    ];
    return ProfileDestinationScaffold(
      title: 'Profile Details',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: ProfileAvatar(size: 100, name: user.name)),
            const SizedBox(height: 24),
            DashboardGlassCard(
              key: const ValueKey('profile-details-panel'),
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        thickness: .6,
                        indent: 16,
                        endIndent: 16,
                      ),
                    rows[i],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
