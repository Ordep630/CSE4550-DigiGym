import 'package:flutter/material.dart';
import 'package:digigym_backend_client/digigym_backend_client.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import '../client.dart';
import '../models/session.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Enter the verification code for your email.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final code = codeController.text.trim();
                  final requestId =
                      DigiGymSession.registrationRequestId;

                  if (code.isEmpty || requestId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter the verification code.'),
                      ),
                    );
                    return;
                  }

                  try {
                    final registrationToken =
                        await client.emailIdp.verifyRegistrationCode(
                      accountRequestId: UuidValue.fromString(requestId),
                      verificationCode: code,
                    );

                    final user = DigiGymSession.pendingUser;

                    if (user == null) {
                      throw Exception('Registration information is missing.');
                    }

                    final authSuccess = await client.emailIdp.finishRegistration(
                    registrationToken: registrationToken,
                    password: user.password,
                    );

                    await client.auth.updateSignedInUser(authSuccess);

                    DigiGymSession.registeredUser = user;

                    if (!context.mounted) return;

                    Navigator.pushReplacementNamed(
                      context,
                      '/assessment',
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verification failed: $e'),
                      ),
                    );
                  }
                },
                child: const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}