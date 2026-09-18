import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../widgets/stat_card.dart';
import '../widgets/plan_card.dart';

class DashboardPage extends StatelessWidget {
  final UserProfile user;

  const DashboardPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DigiGym',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.name}! 👋',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s work toward your '
              '${user.fitnessGoal.toLowerCase()} goal.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'BMI',
                    value: user.bmi.toStringAsFixed(1),
                    icon: Icons.monitor_weight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Calories',
                    value: '${user.estimatedCalories}',
                    icon: Icons.local_fire_department,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Weight',
                    value: '${user.weight} kg',
                    icon: Icons.scale,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Workout',
                    value: '${user.workoutTime} min',
                    icon: Icons.timer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Your Plan',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            PlanCard(
              icon: Icons.fitness_center,
              title: 'Today\'s Workout',
              description:
                  '${user.fitnessLevel} '
                  '${user.workoutTime}-minute workout',
            ),
            PlanCard(
              icon: Icons.restaurant,
              title: 'Today\'s Nutrition',
              description:
                  'Target approximately '
                  '${user.estimatedCalories} calories',
            ),
            PlanCard(
              icon: Icons.shopping_cart,
              title: 'Grocery List',
              description: 'View ingredients for your meal plan',
            ),
          ],
        ),
      ),
    );
  }
}