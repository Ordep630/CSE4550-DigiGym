import 'package:flutter/material.dart';

import '../models/session.dart';
import '../services/digigym_api.dart';
import '../widgets/digigym_form_components.dart';

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
    if (isVerifying) return;
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
    return DigiGymFormPage(
      title: 'Verify Email',
      child: Column(
        children: [
          const DigiGymFormBranding(),
          const Text('Enter the verification code for your email.'),
          if (DigiGymSession.pendingUser?.email case final String email)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(email, textAlign: TextAlign.center),
            ),
          const SizedBox(height: 20),
          DigiGymGlassField(
            child: TextField(
              key: const ValueKey('verification-code'),
              controller: codeController,
              readOnly: isVerifying,
              // Serverpod's default email codes include letters and digits.
              keyboardType: TextInputType.text,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              onSubmitted: (_) => verifyEmail(),
              decoration: digiGymFormDecoration(
                'Verification Code',
                icon: Icons.verified_user_outlined,
              ),
            ),
          ),
          const SizedBox(height: 20),
          DigiGymPrimaryButton(
            label: 'Verify',
            loading: isVerifying,
            onPressed: verifyEmail,
          ),
        ],
      ),
    );
  }
}
