import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/digigym_api.dart';
import '../widgets/profile_information.dart';
import 'edit_profile_screen.dart';

class ProfilePage extends StatefulWidget {
  final UserProfile user;
  final Future<void> Function() onLogout;
  final Function(UserProfile) onUpdateProfile;
  final DigiGymApi api;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onUpdateProfile,
    this.api = digiGymApi,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoggingOut = false;

  Future<void> editProfile(BuildContext context) async {
    final updatedUser = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: widget.user, api: widget.api),
      ),
    );

    if (updatedUser != null) {
      widget.onUpdateProfile(updatedUser);
    }
  }

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),

        content: const Text('Are you sure you want to logout?'),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      await widget.onLogout();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to log out. Check your connection and retry.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? Colors.transparent
          : null,
      appBar: AppBar(title: const Text('My Profile')),

      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          // Reserve the measured navigation inset inside the scroll content,
          // so the viewport does not cut glass surfaces off above the pill.
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.paddingOf(context).bottom,
          ),

          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 55),
              ),

              const SizedBox(height: 15),

              Text(
                widget.user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                widget.user.email,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),

              const SizedBox(height: 30),

              ProfileInformation(
                title: 'Age',
                value: '${widget.user.age} years',
              ),

              ProfileInformation(
                title: 'Height',
                value: '${widget.user.height} cm',
              ),

              ProfileInformation(
                title: 'Weight',
                value: '${widget.user.weight} kg',
              ),

              ProfileInformation(
                title: 'BMI',
                value: widget.user.bmi.toStringAsFixed(1),
              ),

              ProfileInformation(
                title: 'Fitness Level',
                value: widget.user.fitnessLevel,
              ),

              ProfileInformation(
                title: 'Fitness Goal',
                value: widget.user.fitnessGoal,
              ),

              ProfileInformation(
                title: 'Workout Time',
                value: '${widget.user.workoutTime} minutes',
              ),

              ProfileInformation(
                title: 'Diet',
                value: widget.user.dietaryPreference,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  onPressed: isLoggingOut
                      ? null
                      : () {
                          editProfile(context);
                        },

                  icon: const Icon(Icons.edit),

                  label: const Text('EDIT PROFILE'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: OutlinedButton.icon(
                  onPressed: isLoggingOut
                      ? null
                      : () {
                          logout();
                        },

                  icon: isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout),

                  label: Text(isLoggingOut ? 'LOGGING OUT...' : 'LOGOUT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
