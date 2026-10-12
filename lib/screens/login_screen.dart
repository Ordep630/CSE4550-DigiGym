import 'package:flutter/material.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart'
    hide UserProfile;
import '../models/user_profile.dart';
import '../models/session.dart';
import '../client.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final void Function(UserProfile) onLogin;

  const LoginScreen({
    super.key,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  final UserProfile demoUser = UserProfile(
    name: 'Demo User',
    email: 'demo@gym.com',
    password: '123456',
    age: 22,
    height: 175,
    weight: 75,
    fitnessLevel: 'Beginner',
    fitnessGoal: 'Build Muscle',
    workoutTime: 45,
    dietaryPreference: 'No Preference',
    bodyType: 'Average',
  );

  Future<void> login() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  // Keep the demo account available.
  if (email == demoUser.email && password == demoUser.password) {
    widget.onLogin(demoUser);
    return;
  }

  try {
    final authSuccess = await client.emailIdp.login(
      email: email,
      password: password,
    );

    await client.auth.updateSignedInUser(authSuccess);
    final profile = await client.user.getProfile();
    print('PROFILE FROM SERVER: $profile');
    if (profile == null) {
  throw Exception('No DigiGym profile found.');
}

final loggedInUser = UserProfile(
  name: profile.name,
  email: email,
  password: password,
  age: profile.age,
  height: profile.height,
  weight: profile.weight,
  fitnessLevel: profile.fitnessLevel,
  fitnessGoal: profile.fitnessGoal,
  workoutTime: profile.workoutTime,
  dietaryPreference: profile.dietaryPreference,
  bodyType: profile.bodyType,
);

    if (!context.mounted) return;

DigiGymSession.currentUser = loggedInUser;
widget.onLogin(loggedInUser);
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid email or password.'),
      ),
    );
  }
}

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                const Text(
                  'DigiGym',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your personal fitness companion',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: login,
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Demo Login',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  'demo@gym.com\nPassword: 123456',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}