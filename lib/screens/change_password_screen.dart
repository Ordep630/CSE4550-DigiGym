
import 'package:flutter/material.dart';

import '../services/digigym_api.dart';
import '../widgets/digigym_form_components.dart';

class ChangePasswordScreen extends StatefulWidget {
  final DigiGymApi api;

  const ChangePasswordScreen({
    super.key,
    this.api = digiGymApi,
  });

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a new password.';
    }

    if (value.trim() != value) {
      return 'Password cannot begin or end with spaces.';
    }

    if (value.length < 8) {
      return 'Password must contain at least 8 characters.';
    }

    return null;
  }

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.api.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your password was changed successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to change your password. Check your current password '
            'and new password requirements, then try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _passwordField({
    required String label,
    required String id,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    String? autofillHint,
  }) {
    final decoration = digiGymFormDecoration(
      label,
      icon: Icons.lock_outline_rounded,
    );

    return DigiGymGlassField(
      key: ValueKey('change-password-$id'),
      child: TextFormField(
        controller: controller,
        obscureText: !visible,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: autofillHint == null ? null : [autofillHint],
        textInputAction: TextInputAction.next,
        validator: validator,
        decoration: decoration.copyWith(
          suffixIcon: IconButton(
            tooltip: visible ? 'Hide password' : 'Show password',
            onPressed: onToggle,
            icon: Icon(
              visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DigiGymFormPage(
      title: 'Change Password',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DigiGymFormBranding(),
          const SizedBox(height: 20),
          const Text(
            'Update your password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your current password and choose a new one '
            'to keep your account secure.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _passwordField(
                  id: 'current',
                  label: 'Current Password',
                  controller: _currentPasswordController,
                  visible: _showCurrentPassword,
                  onToggle: () => setState(
                    () => _showCurrentPassword = !_showCurrentPassword,
                  ),
                  autofillHint: AutofillHints.password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your current password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _passwordField(
                  id: 'new',
                  label: 'New Password',
                  controller: _newPasswordController,
                  visible: _showNewPassword,
                  onToggle: () => setState(
                    () => _showNewPassword = !_showNewPassword,
                  ),
                  autofillHint: AutofillHints.newPassword,
                  validator: _validateNewPassword,
                ),
                const SizedBox(height: 18),
                _passwordField(
                  id: 'confirm',
                  label: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  visible: _showConfirmPassword,
                  onToggle: () => setState(
                    () => _showConfirmPassword = !_showConfirmPassword,
                  ),
                  autofillHint: AutofillHints.newPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your new password.';
                    }

                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'Your new password must contain at least 8 characters.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                DigiGymPrimaryButton(
                  label: 'Update Password',
                  loading: _isLoading,
                  onPressed: _isLoading ? null : _changePassword,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}