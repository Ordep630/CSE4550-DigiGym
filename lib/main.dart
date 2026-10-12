import 'package:flutter/material.dart';
import 'client.dart';
import 'models/user_profile.dart';
import 'models/session.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/home_screen.dart';
import 'screens/meals_screen.dart';
import 'screens/grocery_screen.dart';
import 'screens/verify_email_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(const DigiGymApp());
}

class DigiGymApp extends StatefulWidget {
  const DigiGymApp({super.key});

  @override
  State<DigiGymApp> createState() => _DigiGymAppState();
}

class _DigiGymAppState extends State<DigiGymApp> {
  void _login(UserProfile user) {
    setState(() {
      DigiGymSession.currentUser = user;
    });
  }

  void _logout() {
    setState(() {
      DigiGymSession.currentUser = null;
    });
  }

  void _updateProfile(UserProfile user) {
    setState(() {
      DigiGymSession.currentUser = user;
      if (DigiGymSession.registeredUser?.email == user.email) {
        DigiGymSession.registeredUser = user;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DigiGym',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
      ),
      home: DigiGymSession.currentUser == null
          ? LoginScreen(onLogin: _login)
          : HomeScreen(
              user: DigiGymSession.currentUser!,
              onLogout: _logout,
              onUpdateProfile: _updateProfile,
            ),
      routes: {
        '/verify-email': (context) => const VerifyEmailScreen(),
        '/register': (_) => const RegisterScreen(),
        '/assessment': (_) => const AssessmentScreen(),
        '/meals': (_) => const MealsScreen(),
        '/groceries': (_) => const GroceryScreen(),
      },
    );
  }
}