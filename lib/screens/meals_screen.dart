import 'package:flutter/material.dart';

import '../models/session.dart';
import '../models/user_profile.dart';
import '../widgets/digigym_page_shell.dart';
import '../widgets/digigym_form_components.dart';
import 'meal_page.dart';

/// Compatibility for /meals: display the same profile-based plan as the tab.
class MealsScreen extends StatelessWidget {
  final UserProfile? user;
  const MealsScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final profile = user ?? DigiGymSession.currentUser;
    if (profile == null) {
      return const DigiGymFormPage(
        title: 'Meals',
        child: Column(
          children: [
            DigiGymFormBranding(),
            Text(
              'Sign in to view your meal plan.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return DigiGymPageShell(child: MealPage(user: profile));
  }
}
