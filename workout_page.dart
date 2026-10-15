import 'package:flutter/material.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  static const green = Color(0xFF00FF66);
  static const background = Color(0xFF080D0C);
  static const cardColor = Color(0xFF111A18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: green,
        elevation: 0,
        title: const Text(
          'DigiGym',
          style: TextStyle(
            color: green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WORKOUTS',
              style: TextStyle(
                color: green,
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Ready to train?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Here is your workout for today.',
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 25),

            // Today's Workout
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: green,
                        size: 34,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upper Body Strength',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'TODAY\'S WORKOUT',
                              style: TextStyle(
                                color: green,
                                fontSize: 11,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      WorkoutInfo(
                        icon: Icons.timer_outlined,
                        value: '45 min',
                      ),
                      WorkoutInfo(
                        icon: Icons.local_fire_department_outlined,
                        value: '320 kcal',
                      ),
                      WorkoutInfo(
                        icon: Icons.fitness_center,
                        value: '6 exercises',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('START WORKOUT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(15),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const SectionTitle(title: 'EXERCISES'),

            const SizedBox(height: 12),

            const ExerciseCard(
              number: '01',
              name: 'Bench Press',
              details: '4 sets  •  10 reps',
            ),

            const ExerciseCard(
              number: '02',
              name: 'Shoulder Press',
              details: '3 sets  •  12 reps',
            ),

            const ExerciseCard(
              number: '03',
              name: 'Dumbbell Row',
              details: '3 sets  •  10 reps',
            ),

            const ExerciseCard(
              number: '04',
              name: 'Bicep Curls',
              details: '3 sets  •  12 reps',
            ),

            const SizedBox(height: 25),

            const SectionTitle(title: 'RECOMMENDED FOR YOU'),

            const SizedBox(height: 12),

            const RecommendationCard(
              icon: Icons.directions_run,
              title: 'Cardio Finish',
              text:
                  'Add 20 minutes of light cardio after your workout.',
            ),

            const RecommendationCard(
              icon: Icons.self_improvement,
              title: 'Recovery',
              text:
                  'Take 5–10 minutes to stretch after training.',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class WorkoutInfo extends StatelessWidget {
  final IconData icon;
  final String value;

  const WorkoutInfo({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: WorkoutPage.green),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: WorkoutPage.green,
        fontSize: 13,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final String number;
  final String name;
  final String details;

  const ExerciseCard({
    super.key,
    required this.number,
    required this.name,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: WorkoutPage.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WorkoutPage.green.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: WorkoutPage.green,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  details,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            color: WorkoutPage.green,
          ),
        ],
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const RecommendationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WorkoutPage.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WorkoutPage.green.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: WorkoutPage.green,
            size: 30,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}