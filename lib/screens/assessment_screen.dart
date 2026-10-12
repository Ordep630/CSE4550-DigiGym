import 'package:flutter/material.dart';
import '../models/session.dart';
import '../client.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Assessment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us about yourself',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: fitnessLevel,
              decoration: const InputDecoration(
                labelText: 'Fitness Level',
                border: OutlineInputBorder(),
              ),
              items: [
                'Beginner',
                'Intermediate',
                'Advanced',
              ]
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  fitnessLevel = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: goal,
              decoration: const InputDecoration(
                labelText: 'Fitness Goal',
                border: OutlineInputBorder(),
              ),
              items: [
                'Lose Weight',
                'Build Muscle',
                'Gain Weight',
                'Maintain Weight',
              ]
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  goal = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: diet,
              decoration: const InputDecoration(
                labelText: 'Diet',
                border: OutlineInputBorder(),
              ),
              items: [
                'No Restrictions',
                'Vegetarian',
                'Vegan',
                'High Protein',
              ]
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  diet = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
  value: bodyType,
  decoration: const InputDecoration(
    labelText: 'Body Type',
    border: OutlineInputBorder(),
  ),
  items: [
    'Slim',
    'Average',
    'Athletic',
    'Heavy',
  ]
      .map(
        (value) => DropdownMenuItem(
          value: value,
          child: Text(value),
        ),
      )
      .toList(),
  onChanged: (value) {
    setState(() {
      bodyType = value!;
    });
  },
),
const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              value: workoutTime,
              decoration: const InputDecoration(
                labelText: 'Available Workout Time',
                border: OutlineInputBorder(),
              ),
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isCreatingPlan
                  ? null
                  : () async {
                  final age = int.tryParse(ageController.text.trim());
                  final height =
                      double.tryParse(heightController.text.trim());
                  final weight =
                      double.tryParse(weightController.text.trim());
                  final user = DigiGymSession.pendingUser;

                  if (user == null ||
                      age == null ||
                      age <= 0 ||
                      height == null ||
                      height <= 0 ||
                      weight == null ||
                      weight <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Enter a valid age, height, and weight.',
                        ),
                      ),
                    );
                    return;
                  }
                  setState(() {
                  isCreatingPlan = true;
                  });
                  user.age = age;
                  user.height = height;
                  user.weight = weight;
                  user.fitnessLevel = fitnessLevel;
                  user.fitnessGoal = goal;
                  user.dietaryPreference =
                      diet == 'No Restrictions' ? 'No Preference' : diet;
                  user.workoutTime = workoutTime;

                  await client.user.createProfile(
                  name: user.name,
                  age: age,
                  height: height,
                  weight: weight,
                  fitnessLevel: fitnessLevel,
                  fitnessGoal: goal,
                  workoutTime: workoutTime,
                  dietaryPreference:
                      diet == 'No Restrictions' ? 'No Preference' : diet,
                  bodyType: bodyType,
                  );

                  if (!context.mounted) return;

                  DigiGymSession.registeredUser = user;
                  DigiGymSession.pendingUser = null;

                  Navigator.of(context).popUntil(
                    (route) => route.isFirst,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account created. Please log in.'),
                    ),
                  );
                },
                child: isCreatingPlan
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create My Plan',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}