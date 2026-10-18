import 'package:flutter/material.dart';

import '../models/session.dart';
import '../services/digigym_api.dart';

class VerifyEmailScreen extends StatefulWidget {
  final DigiGymApi api;

  const VerifyEmailScreen({super.key, this.api = digiGymApi});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final codeController = TextEditingController();
  bool isVerifying = false;
  bool didVerify = false;

  @override
  void dispose() {
    codeController.dispose();
    if (!didVerify) {
      DigiGymSession.clearPendingRegistration();
    }
    super.dispose();
  }

  Future<void> verifyEmail() async {
    final code = codeController.text.trim();
    final requestId = DigiGymSession.registrationRequestId;
    final user = DigiGymSession.pendingUser;
    final password = DigiGymSession.pendingRegistrationPassword;

    if (code.isEmpty || requestId == null || user == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration details are missing. Please try again.'),
        ),
      );
      return;
    }

    setState(() {
      isVerifying = true;
    });

    try {
      await widget.api.finishRegistration(
        requestId: requestId,
        verificationCode: code,
        password: password,
      );

      DigiGymSession.clearRegistrationPassword();
      DigiGymSession.registeredUser = user;
      didVerify = true;

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/assessment');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification failed. Check the code and try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Enter the verification code for your email.'),
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
                onPressed: isVerifying ? null : verifyEmail,
                child: isVerifying
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
