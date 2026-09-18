import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../widgets/profile_information.dart';
import 'edit_profile_screen.dart';

class ProfilePage extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onLogout;
  final Function(UserProfile) onUpdateProfile;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onUpdateProfile,
  });

  void editProfile(BuildContext context) async {
    final updatedUser =
        await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          user: user,
        ),
      ),
    );

    if (updatedUser != null) {
      onUpdateProfile(updatedUser);
    }
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),

        content: const Text(
          'Are you sure you want to logout?',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 55,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              user.email,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            ProfileInformation(
              title: 'Age',
              value: '${user.age} years',
            ),

            ProfileInformation(
              title: 'Height',
              value: '${user.height} cm',
            ),

            ProfileInformation(
              title: 'Weight',
              value: '${user.weight} kg',
            ),

            ProfileInformation(
              title: 'BMI',
              value: user.bmi.toStringAsFixed(1),
            ),

            ProfileInformation(
              title: 'Fitness Level',
              value: user.fitnessLevel,
            ),

            ProfileInformation(
              title: 'Fitness Goal',
              value: user.fitnessGoal,
            ),

            ProfileInformation(
              title: 'Workout Time',
              value: '${user.workoutTime} minutes',
            ),

            ProfileInformation(
              title: 'Diet',
              value: user.dietaryPreference,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: () {
                  editProfile(context);
                },

                icon: const Icon(Icons.edit),

                label: const Text(
                  'EDIT PROFILE',
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: OutlinedButton.icon(
                onPressed: () {
                  logout(context);
                },

                icon: const Icon(Icons.logout),

                label: const Text(
                  'LOGOUT',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}