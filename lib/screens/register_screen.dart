import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/session.dart';
import '../services/digigym_api.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/digigym_form_components.dart';

enum _RegistrationInput { name, email, password, confirmation }

class RegisterScreen extends StatefulWidget {
  final DigiGymApi api;

  const RegisterScreen({super.key, this.api = digiGymApi});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _fields = {
    for (final input in _RegistrationInput.values)
      input: GlobalKey<FormFieldState<String>>(),
  };
  final _focusNodes = {
    for (final input in _RegistrationInput.values)
      input: FocusNode(debugLabel: 'Registration ${input.name}'),
  };
  bool _submissionAttempted = false;
  bool obscurePassword = true;
  bool obscureConfirmation = true;
  bool isRegistering = false;

  @override
  void initState() {
    super.initState();
    _focusNodes[_RegistrationInput.password]!.addListener(
      _refreshPasswordHelper,
    );
  }

  void _refreshPasswordHelper() => setState(() {});

  void _recheckError(_RegistrationInput input) {
    final field = _fields[input]!.currentState;
    if (field?.hasError ?? false) field!.validate();
    if (input == _RegistrationInput.password) {
      // A corrected password can also resolve an existing confirmation error.
      // Never introduce an error in another field while typing.
      final confirmation =
          _fields[_RegistrationInput.confirmation]!.currentState;
      if ((confirmation?.hasError ?? false) &&
          confirmPasswordController.text.isNotEmpty &&
          confirmPasswordController.text == passwordController.text) {
        confirmation!.validate();
      }
      _refreshPasswordHelper();
    }
  }

  void _focusFirstError() {
    for (final input in _RegistrationInput.values) {
      if (!(_fields[input]!.currentState?.hasError ?? false)) continue;
      _focusNodes[input]!.requestFocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final fieldContext = _fields[input]!.currentContext;
        if (fieldContext != null) {
          Scrollable.ensureVisible(
            fieldContext,
            alignment: .15,
            duration: const Duration(milliseconds: 200),
          );
        }
      });
      break;
    }
  }

  InputDecoration _decoration(String label, {IconData? icon}) {
    final decoration = digiGymFormDecoration(label, icon: icon);
    // Errors remain readable below the field while focus stays DigiGym green.
    return decoration.copyWith(focusedErrorBorder: decoration.focusedBorder);
  }

  @override
  void dispose() {
    _focusNodes[_RegistrationInput.password]!.removeListener(
      _refreshPasswordHelper,
    );
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (isRegistering) return;
    setState(() => _submissionAttempted = true);
    if (!_formKey.currentState!.validate()) {
      _focusFirstError();
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

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
    return DigiGymFormPage(
      title: 'Create Account',
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Column(
          children: [
            const DigiGymFormBranding(),
            DigiGymGlassField(
              key: const ValueKey('registration-name'),
              child: TextFormField(
                key: _fields[_RegistrationInput.name],
                focusNode: _focusNodes[_RegistrationInput.name],
                onChanged: (_) => _recheckError(_RegistrationInput.name),
                controller: nameController,
                readOnly: isRegistering,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: _decoration('Name', icon: Icons.person_outline),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your name.'
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            DigiGymGlassField(
              key: const ValueKey('registration-email'),
              child: TextFormField(
                key: _fields[_RegistrationInput.email],
                focusNode: _focusNodes[_RegistrationInput.email],
                onChanged: (_) => _recheckError(_RegistrationInput.email),
                controller: emailController,
                readOnly: isRegistering,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                decoration: _decoration(
                  'Email',
                  icon: Icons.mail_outline_rounded,
                ),
                validator: (value) =>
                    value == null || !value.trim().contains('@')
                    ? 'Enter a valid email address.'
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            DigiGymGlassField(
              key: const ValueKey('registration-password'),
              child: TextFormField(
                key: _fields[_RegistrationInput.password],
                focusNode: _focusNodes[_RegistrationInput.password],
                onChanged: (_) => _recheckError(_RegistrationInput.password),
                controller: passwordController,
                readOnly: isRegistering,
                obscureText: obscurePassword,
                enableSuggestions: false,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                decoration:
                    _decoration(
                      'Password',
                      icon: Icons.lock_outline_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        tooltip: obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Use at least 8 characters.';
                  }
                  if (value.trim() != value) {
                    return 'Remove spaces at the start or end of your password.';
                  }
                  return null;
                },
              ),
            ),
            if (passwordController.text.length < 8 &&
                !(_fields[_RegistrationInput.password]!
                        .currentState
                        ?.hasError ??
                    false))
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 4, 18, 0),
                  child: Text(
                    'Use at least 8 characters.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: DigiGymDarkColors.secondaryText,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            DigiGymGlassField(
              key: const ValueKey('registration-confirm-password'),
              child: TextFormField(
                key: _fields[_RegistrationInput.confirmation],
                focusNode: _focusNodes[_RegistrationInput.confirmation],
                onChanged: (_) =>
                    _recheckError(_RegistrationInput.confirmation),
                controller: confirmPasswordController,
                readOnly: isRegistering,
                obscureText: obscureConfirmation,
                enableSuggestions: false,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => register(),
                decoration:
                    _decoration(
                      'Confirm Password',
                      icon: Icons.lock_outline_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        tooltip: obscureConfirmation
                            ? 'Show confirm password'
                            : 'Hide confirm password',
                        onPressed: () => setState(
                          () => obscureConfirmation = !obscureConfirmation,
                        ),
                        icon: Icon(
                          obscureConfirmation
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                validator: (value) {
                  if ((value == null || value.isEmpty) &&
                      !_submissionAttempted) {
                    return null;
                  }
                  return value == null ||
                          value.isEmpty ||
                          value != passwordController.text
                      ? 'Passwords must match exactly.'
                      : null;
                },
              ),
            ),
            const SizedBox(height: 24),
            DigiGymPrimaryButton(
              label: 'Register',
              loading: isRegistering,
              onPressed: register,
            ),
          ],
        ),
      ),
    );
  }
}
