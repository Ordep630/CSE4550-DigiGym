import 'package:flutter/material.dart';
import '../data/workout_data.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Workouts')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            child: ExpansionTile(
              leading: const CircleAvatar(
                child: Icon(Icons.fitness_center),
              ),
              title: Text(
                workout.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${workout.duration} minutes • ${workout.level}',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workout.description),
                      const SizedBox(height: 12),
                      Text(
                        '${workout.sets} sets × ${workout.reps} reps',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'How to perform:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Perform the movement slowly and maintain '
                        'proper form. Stop if you experience pain.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}