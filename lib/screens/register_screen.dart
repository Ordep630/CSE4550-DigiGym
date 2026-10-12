import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/session.dart';
import '../client.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
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
                onPressed: () async {
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  final password = passwordController.text;

                  if (name.isEmpty ||
                      !email.contains('@') ||
                      password.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Enter a name, valid email, and password '
                          'of at least 6 characters.',
                        ),
                      ),
                    );
                    return;
                  }

                  try {

  final accountRequestId = await client.emailIdp.startRegistration(
    email: email,
  );

  debugPrint('Registration request ID: $accountRequestId');
  DigiGymSession.registrationRequestId = accountRequestId.toString();
  DigiGymSession.pendingUser = UserProfile(
    name: name,
    email: email,
    password: password,
  );

  if (!context.mounted) return;

  Navigator.pushReplacementNamed(
  context,
  '/verify-email',
);

} catch (e) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Registration failed: $e'),
    ),
  );
}
                },
                child: const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}