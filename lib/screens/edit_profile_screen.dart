import 'package:flutter/material.dart';

import '../models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;

  const EditProfileScreen({
    super.key,
    required this.user,
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

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user.name);
    ageController = TextEditingController(
      text: widget.user.age.toString(),
    );
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

  void saveProfile() {
    final updatedUser = UserProfile(
      name: nameController.text.trim(),
      email: widget.user.email,
      password: widget.user.password,
      age: int.tryParse(ageController.text) ?? widget.user.age,
      height: double.tryParse(heightController.text) ??
          widget.user.height,
      weight: double.tryParse(weightController.text) ??
          widget.user.weight,
      fitnessLevel: fitnessLevel,
      fitnessGoal: fitnessGoal,
      workoutTime: int.tryParse(workoutTimeController.text) ??
          widget.user.workoutTime,
      dietaryPreference: dietaryPreference,
      bodyType: bodyType,
    );

    Navigator.pop(context, updatedUser);
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
              value: fitnessLevel,
              decoration: const InputDecoration(
                labelText: 'Fitness Level',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Beginner',
                  child: Text('Beginner'),
                ),
                DropdownMenuItem(
                  value: 'Intermediate',
                  child: Text('Intermediate'),
                ),
                DropdownMenuItem(
                  value: 'Advanced',
                  child: Text('Advanced'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => fitnessLevel = value);
                }
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: fitnessGoal,
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
              value: dietaryPreference,
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
                DropdownMenuItem(
                  value: 'Vegan',
                  child: Text('Vegan'),
                ),
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
              value: bodyType,
              decoration: const InputDecoration(
                labelText: 'Body Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Slim',
                  child: Text('Slim'),
                ),
                DropdownMenuItem(
                  value: 'Average',
                  child: Text('Average'),
                ),
                DropdownMenuItem(
                  value: 'Athletic',
                  child: Text('Athletic'),
                ),
                DropdownMenuItem(
                  value: 'Heavy',
                  child: Text('Heavy'),
                ),
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
                onPressed: saveProfile,
                icon: const Icon(Icons.save),
                label: const Text(
                  'SAVE CHANGES',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}