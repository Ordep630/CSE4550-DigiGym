import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/session.dart';
import '../services/digigym_api.dart';
import '../widgets/digigym_form_components.dart';

class AssessmentScreen extends StatefulWidget {
  final DigiGymApi api;
  final VoidCallback? onComplete;

  const AssessmentScreen({super.key, this.api = digiGymApi, this.onComplete});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late final TextEditingController nameController;
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  String fitnessLevel = 'Beginner';
  String goal = 'Lose Weight';
  String diet = 'No Restrictions';
  String bodyType = 'Average';
  int workoutTime = 30;

  bool isCreatingPlan = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: DigiGymSession.pendingUser?.name ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> createPlan() async {
    if (isCreatingPlan) return;
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim());
    final height = double.tryParse(heightController.text.trim());
    final weight = double.tryParse(weightController.text.trim());
    final user = DigiGymSession.pendingUser;

    if (user == null ||
        name.isEmpty ||
        age == null ||
        age <= 0 ||
        height == null ||
        height <= 0 ||
        weight == null ||
        weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a name and valid age, height, and weight.'),
        ),
      );
      return;
    }

    setState(() {
      isCreatingPlan = true;
    });

    try {
      final dietaryPreference = diet == 'No Restrictions'
          ? 'No Preference'
          : diet;

      final savedUser = await widget.api.updateProfile(
        UserProfile(
          name: name,
          email: user.email,
          age: age,
          height: height,
          weight: weight,
          fitnessLevel: fitnessLevel,
          fitnessGoal: goal,
          workoutTime: workoutTime,
          dietaryPreference: dietaryPreference,
          bodyType: bodyType,
        ),
      );

      // Registration signs the user in. Sign out after the assessment because
      // this flow intentionally returns to the login screen.
      await widget.api.signOut();

      if (!mounted) return;

      DigiGymSession.registeredUser = savedUser;
      DigiGymSession.clearPendingRegistration();

      if (widget.onComplete != null) {
        widget.onComplete!();
        return;
      }

      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please log in.')),
      );
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
            'Unable to save your assessment. Check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCreatingPlan = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DigiGymFormPage(
      title: 'Fitness Assessment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DigiGymFormBranding(),
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          DigiGymGlassField(
            child: TextField(
              controller: nameController,
              decoration: digiGymFormDecoration('Name'),
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: digiGymFormDecoration('Age'),
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: digiGymFormDecoration('Height (cm)'),
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: digiGymFormDecoration('Weight (kg)'),
            ),
          ),
          const SizedBox(height: 20),
          DigiGymGlassField(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: fitnessLevel,
              decoration: digiGymFormDecoration('Fitness Level'),
              items: ['Beginner', 'Intermediate', 'Advanced']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  fitnessLevel = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: goal,
              decoration: digiGymFormDecoration('Fitness Goal'),
              items:
                  [
                        'Lose Weight',
                        'Build Muscle',
                        'Gain Weight',
                        'Maintain Weight',
                      ]
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  goal = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: diet,
              decoration: digiGymFormDecoration('Diet'),
              items: ['No Restrictions', 'Vegetarian', 'Vegan', 'High Protein']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  diet = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: bodyType,
              decoration: digiGymFormDecoration('Body Type'),
              items: ['Slim', 'Average', 'Athletic', 'Heavy']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  bodyType = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: DropdownButtonFormField<int>(
              isExpanded: true,
              itemHeight: null,
              initialValue: workoutTime,
              decoration: digiGymFormDecoration('Available Workout Time'),
              items: [15, 30, 45, 60]
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text('$value minutes'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  workoutTime = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 30),
          DigiGymPrimaryButton(
            label: 'Create My Plan',
            loading: isCreatingPlan,
            onPressed: createPlan,
          ),
        ],
      ),
    );
  }
}
