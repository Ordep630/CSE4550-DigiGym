import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
              'PROFILE',
              style: TextStyle(
                color: green,
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // PROFILE ICON
            Center(
              child: Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: green,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: green,
                  size: 65,
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Center(
              child: Text(
                'DigiGym User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            const Center(
              child: Text(
                'digigym@email.com',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Center(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined),
                label: const Text('EDIT PROFILE'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green),
                ),
              ),
            ),

            const SizedBox(height: 35),

            const SectionTitle(title: 'FITNESS STATS'),

            const SizedBox(height: 12),

            const Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.fitness_center,
                    value: '24',
                    label: 'Workouts',
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: StatCard(
                    icon: Icons.monitor_weight_outlined,
                    value: '175',
                    label: 'Weight',
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department_outlined,
                    value: '8',
                    label: 'Week Streak',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            const SectionTitle(
              title: 'PERSONAL INFORMATION',
            ),

            const SizedBox(height: 12),

            const ProfileCard(
              icon: Icons.person_outline,
              title: 'Name',
              value: 'DigiGym User',
            ),

            const ProfileCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: 'digigym@email.com',
            ),

            const ProfileCard(
              icon: Icons.cake_outlined,
              title: 'Age',
              value: '24 years',
            ),

            const SizedBox(height: 35),

            const SectionTitle(
              title: 'FITNESS GOALS',
            ),

            const SizedBox(height: 12),

            const ProfileCard(
              icon: Icons.fitness_center,
              title: 'Build Muscle',
              value: 'Primary Goal',
            ),

            const ProfileCard(
              icon: Icons.directions_run,
              title: 'Improve Cardio',
              value: '10 miles per week',
            ),

            const ProfileCard(
              icon: Icons.monitor_weight_outlined,
              title: 'Target Weight',
              value: '165 lbs',
            ),

            const SizedBox(height: 35),

            const SectionTitle(
              title: 'ACCOUNT',
            ),

            const SizedBox(height: 12),

            const ProfileCard(
              icon: Icons.settings_outlined,
              title: 'Settings',
              value: 'App preferences',
            ),

            const ProfileCard(
              icon: Icons.notifications_none,
              title: 'Notifications',
              value: 'Workout reminders',
            ),

            const ProfileCard(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              value: 'Manage account',
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout),
                label: const Text('LOG OUT'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green),
                  padding: const EdgeInsets.all(15),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// SECTION TITLE
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
        color: ProfilePage.green,
        fontSize: 13,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// FITNESS STAT CARD
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: ProfilePage.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ProfilePage.green.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: ProfilePage.green,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// PROFILE INFORMATION CARD
class ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: ProfilePage.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ProfilePage.green.withValues(alpha: 0.30),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ProfilePage.green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: ProfilePage.green,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

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

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            color: ProfilePage.green,
          ),
        ],
      ),
    );
  }
}