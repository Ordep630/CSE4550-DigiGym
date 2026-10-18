import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/session.dart';
import '../services/digigym_api.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final void Function(UserProfile) onLogin;
  final DigiGymApi api;

  const LoginScreen({super.key, required this.onLogin, this.api = digiGymApi});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const demoEmail = 'demo@gym.com';
  static const demoPassword = '123456';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoggingIn = false;

  final UserProfile demoUser = UserProfile(
    name: 'Demo User',
    email: demoEmail,
    age: 22,
    height: 175,
    weight: 75,
    fitnessLevel: 'Beginner',
    fitnessGoal: 'Build Muscle',
    workoutTime: 45,
    dietaryPreference: 'No Preference',
    bodyType: 'Average',
    isDemo: true,
  );

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email and password.')),
      );
      return;
    }

    // Keep the demo account available without creating a backend session.
    if (email == demoEmail && password == demoPassword) {
      passwordController.clear();
      widget.onLogin(demoUser);
      return;
    }

    setState(() {
      isLoggingIn = true;
    });

    try {
      final loggedInUser = await widget.api.login(
        email: email,
        password: password,
      );
      passwordController.clear();

      if (!mounted) return;

      DigiGymSession.currentUser = loggedInUser;
      widget.onLogin(loggedInUser);
    } on ProfileSetupRequiredException catch (error) {
      passwordController.clear();
      DigiGymSession.pendingUser = UserProfile(name: '', email: error.email);
      DigiGymSession.clearRegistrationPassword();

      if (!mounted) return;
      Navigator.pushNamed(context, '/assessment');
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to sign in. Check your credentials and connection.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoggingIn = false;
        });
      }
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
                const Icon(Icons.fitness_center, size: 80, color: Colors.green),
                const SizedBox(height: 20),
                const Text(
                  'DigiGym',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your personal fitness companion',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
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
                    onPressed: isLoggingIn ? null : login,
                    child: isLoggingIn
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
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
                        builder: (_) => RegisterScreen(api: widget.api),
                      ),
                    );
                  },
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
