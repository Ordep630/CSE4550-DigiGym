import 'package:flutter/material.dart';
import 'workout_page.dart';
import 'meals_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const Color green = Color(0xFF00FF66);
  static const Color background = Color(0xFF080D0C);
  static const Color cardColor = Color(0xFF111A18);

  final List<Widget> _pages = const [
    HomePage(),
    WorkoutPage(),
    MealsPage(),
    ProfilePage(),
  ];

  void _changePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: cardColor,
          border: Border(
            top: BorderSide(
              color: green,
              width: 1,
            ),
          ),
        ),

        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _changePage,

          type: BottomNavigationBarType.fixed,

          backgroundColor: cardColor,

          selectedItemColor: green,
          unselectedItemColor: Colors.white54,

          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'Workouts',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant),
              label: 'Meals',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// HOME PAGE
// ======================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color green = Color(0xFF00FF66);
  static const Color background = Color(0xFF080D0C);
  static const Color cardColor = Color(0xFF111A18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                Container(
                  width: 95,
                  height: 95,

                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(22),

                    border: Border.all(
                      color: green,
                      width: 2,
                    ),
                  ),

                  child: const Icon(
                    Icons.fitness_center,
                    size: 50,
                    color: green,
                  ),
                ),

                const SizedBox(height: 18),

                // APP NAME
                const Text(
                  'DigiGym',
                  style: TextStyle(
                    color: green,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'YOUR FITNESS HUB',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 40),

                // WELCOME CARD
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(
                      color: green,
                    ),
                  ),

                  child: const Column(
                    children: [
                      Icon(
                        Icons.bolt,
                        color: green,
                        size: 35,
                      ),

                      SizedBox(height: 12),

                      Text(
                        'Welcome to DigiGym',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'Use the navigation bar below to view your workouts, meals, and profile.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // FEATURES
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeFeature(
                      icon: Icons.fitness_center,
                      text: 'Train',
                    ),

                    SizedBox(width: 30),

                    HomeFeature(
                      icon: Icons.restaurant,
                      text: 'Eat',
                    ),

                    SizedBox(width: 30),

                    HomeFeature(
                      icon: Icons.person,
                      text: 'Track',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// HOME FEATURE
// ======================================================

class HomeFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const HomeFeature({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,

          decoration: BoxDecoration(
            color: HomePage.cardColor,
            borderRadius: BorderRadius.circular(12),

            border: Border.all(
              color: HomePage.green,
            ),
          ),

          child: Icon(
            icon,
            color: HomePage.green,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          text,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}