import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/digigym_api.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;
  final DigiGymApi api;

  const EditProfileScreen({
    super.key,
    required this.user,
    this.api = digiGymApi,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController workoutTimeController;

  late String fitnessLevel;
  late String fitnessGoal;
  late String dietaryPreference;
  late String bodyType;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user.name);
    ageController = TextEditingController(text: widget.user.age.toString());
    heightController = TextEditingController(
      text: widget.user.height.toString(),
    );
    weightController = TextEditingController(
      text: widget.user.weight.toString(),
    );
    workoutTimeController = TextEditingController(
      text: widget.user.workoutTime.toString(),
    );

    fitnessLevel = widget.user.fitnessLevel;
    fitnessGoal = widget.user.fitnessGoal;
    dietaryPreference = widget.user.dietaryPreference;
    bodyType = widget.user.bodyType;
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    workoutTimeController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim());
    final height = double.tryParse(heightController.text.trim());
    final weight = double.tryParse(weightController.text.trim());
    final workoutTime = int.tryParse(workoutTimeController.text.trim());

    if (name.isEmpty ||
        age == null ||
        age <= 0 ||
        height == null ||
        height <= 0 ||
        weight == null ||
        weight <= 0 ||
        workoutTime == null ||
        workoutTime <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid profile values.')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      var updatedUser = UserProfile(
        name: name,
        email: widget.user.email,
        age: age,
        height: height,
        weight: weight,
        fitnessLevel: fitnessLevel,
        fitnessGoal: fitnessGoal,
        workoutTime: workoutTime,
        dietaryPreference: dietaryPreference,
        bodyType: bodyType,
        isDemo: widget.user.isDemo,
      );

      // The demo account is intentionally local-only.
      if (!widget.user.isDemo) {
        updatedUser = await widget.api.updateProfile(updatedUser);
      }

      if (!mounted) return;
      Navigator.pop(context, updatedUser);
    } on ArgumentError {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a supported fitness level and goal.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save your profile. Check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                prefixIcon: Icon(Icons.cake),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                prefixIcon: Icon(Icons.height),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: fitnessLevel,
              decoration: const InputDecoration(
                labelText: 'Fitness Level',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                DropdownMenuItem(
                  value: 'Intermediate',
                  child: Text('Intermediate'),
                ),
                DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => fitnessLevel = value);
                }
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: fitnessGoal,
              decoration: const InputDecoration(
                labelText: 'Fitness Goal',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Lose Weight',
                  child: Text('Lose Weight'),
                ),
                DropdownMenuItem(
                  value: 'Build Muscle',
                  child: Text('Build Muscle'),
                ),
                DropdownMenuItem(
                  value: 'Gain Weight',
                  child: Text('Gain Weight'),
                ),
                DropdownMenuItem(
                  value: 'Maintain Weight',
                  child: Text('Maintain Weight'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => fitnessGoal = value);
                }
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: workoutTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Available Workout Time (minutes)',
                prefixIcon: Icon(Icons.timer),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: dietaryPreference,
              decoration: const InputDecoration(
                labelText: 'Dietary Preference',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'No Preference',
                  child: Text('No Preference'),
                ),
                DropdownMenuItem(
                  value: 'Vegetarian',
                  child: Text('Vegetarian'),
                ),
                DropdownMenuItem(value: 'Vegan', child: Text('Vegan')),
                DropdownMenuItem(
                  value: 'High Protein',
                  child: Text('High Protein'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => dietaryPreference = value);
                }
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: bodyType,
              decoration: const InputDecoration(
                labelText: 'Body Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Slim', child: Text('Slim')),
                DropdownMenuItem(value: 'Average', child: Text('Average')),
                DropdownMenuItem(value: 'Athletic', child: Text('Athletic')),
                DropdownMenuItem(value: 'Heavy', child: Text('Heavy')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => bodyType = value);
                }
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveProfile,
                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isSaving ? 'SAVING...' : 'SAVE CHANGES',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
