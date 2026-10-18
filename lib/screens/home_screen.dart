import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/digigym_api.dart';
import 'dashboard_screen.dart';
import 'workouts_screen.dart';
import 'meal_page.dart';
import 'grocery_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile user;
  final Future<void> Function() onLogout;
  final Function(UserProfile) onUpdateProfile;
  final DigiGymApi api;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onUpdateProfile,
    this.api = digiGymApi,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(user: widget.user),
      WorkoutsScreen(user: widget.user),
      MealPage(user: widget.user),
      const GroceryScreen(),
      ProfilePage(
        user: widget.user,
        onLogout: widget.onLogout,
        onUpdateProfile: widget.onUpdateProfile,
        api: widget.api,
      ),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Meals'),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'Groceries',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
