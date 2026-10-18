import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/session.dart';
import '../services/digigym_api.dart';

class RegisterScreen extends StatefulWidget {
  final DigiGymApi api;

  const RegisterScreen({super.key, this.api = digiGymApi});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegistering = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || !email.contains('@') || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a name, valid email, and password of at least 6 characters.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isRegistering = true;
    });

    try {
      final accountRequestId = await widget.api.startRegistration(email);

      DigiGymSession.registrationRequestId = accountRequestId;
      DigiGymSession.pendingRegistrationPassword = password;
      DigiGymSession.pendingUser = UserProfile(name: name, email: email);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/verify-email');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration failed. Check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isRegistering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isRegistering ? null : register,
                child: isRegistering
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
