import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/floating_bottom_navigation_bar.dart';
import '../widgets/digigym_atmospheric_background.dart';
import '../services/digigym_api.dart';
import '../services/dashboard_personalization.dart';
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
  final String motivationalMessage;
  final DateTime Function()? clock;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onUpdateProfile,
    this.api = digiGymApi,
    this.motivationalMessage = DashboardPersonalization.defaultMessage,
    this.clock,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        user: widget.user,
        motivationalMessage: widget.motivationalMessage,
        clock: widget.clock,
      ),
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

    final darkTheme = DigiGymDashboardTheme.dark(Theme.of(context));

    return Theme(
      data: darkTheme,
      child: DigiGymAtmosphericBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: Theme(
            data: DigiGymDashboardTheme.content(darkTheme),
            child: pages[selectedIndex],
          ),
          bottomNavigationBar: FloatingBottomNavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
