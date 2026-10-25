import 'package:flutter/material.dart';

import '../services/digigym_api.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/digigym_form_components.dart';

enum _RecoveryStep { email, code, password, success }

/// Recovery secrets belong only to this route, never to the signed-in session.
class ForgotPasswordScreen extends StatefulWidget {
  final DigiGymApi api;

  const ForgotPasswordScreen({super.key, this.api = digiGymApi});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  var _step = _RecoveryStep.email;
  var _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _fields = {
    for (final id in ['email', 'code', 'password', 'confirmation'])
      id: GlobalKey<FormFieldState<String>>(),
  };
  final _focus = {
    for (final id in ['email', 'code', 'password', 'confirmation'])
      id: FocusNode(debugLabel: 'Password recovery $id'),
  };
  String? _requestId;
  String? _resetToken;
  String? _error;
  bool _busy = false;
  bool _submitted = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;

  @override
  void initState() {
    super.initState();
    _focus['password']!.addListener(_refreshHelper);
  }

  void _refreshHelper() => setState(() {});

  void _clearSecrets() {
    _requestId = null;
    _resetToken = null;
    _code.clear();
    _password.clear();
    _confirmation.clear();
  }

  @override
  void dispose() {
    _focus['password']!.removeListener(_refreshHelper);
    for (final node in _focus.values) {
      node.dispose();
    }
    _clearSecrets();
    for (final controller in [_email, _code, _password, _confirmation]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _recheck(String id) {
    final field = _fields[id]!.currentState;
    if (field?.hasError ?? false) field!.validate();
    if (id == 'password') {
      final confirmation = _fields['confirmation']!.currentState;
      if ((confirmation?.hasError ?? false) &&
          _confirmation.text.isNotEmpty &&
          _confirmation.text == _password.text) {
        confirmation!.validate();
      }
      _refreshHelper();
    }
  }

  void _advance(_RecoveryStep step) {
    FocusScope.of(context).unfocus();
    _step = step;
    _submitted = false;
    _formKey = GlobalKey<FormState>();
  }

  void _restart() {
    if (_busy) return;
    setState(() {
      _clearSecrets();
      _error = null;
      _advance(_RecoveryStep.email);
    });
  }

  void _focusFirstError() {
    for (final id in _fields.keys) {
      if (!(_fields[id]!.currentState?.hasError ?? false)) continue;
      _focus[id]!.requestFocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final target = _fields[id]!.currentContext;
        if (target != null) Scrollable.ensureVisible(target, alignment: .15);
      });
      break;
    }
  }

  Future<void> _submit() async {
    if (_busy || _step == _RecoveryStep.success) return;
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) {
      _focusFirstError();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final step = _step;
    try {
      switch (step) {
        case _RecoveryStep.email:
          final id = await widget.api.startPasswordReset(_email.text.trim());
          if (!mounted) return;
          setState(() {
            _requestId = id;
            _advance(_RecoveryStep.code);
          });
        case _RecoveryStep.code:
          final token = await widget.api.verifyPasswordResetCode(
            passwordResetRequestId: _requestId!,
            verificationCode: _code.text.trim(),
          );
          if (!mounted) return;
          setState(() {
            _resetToken = token;
            _requestId = null;
            _code.clear();
            _advance(_RecoveryStep.password);
          });
        case _RecoveryStep.password:
          await widget.api.finishPasswordReset(
            finishPasswordResetToken: _resetToken!,
            newPassword: _password.text,
          );
          if (!mounted) return;
          setState(() {
            _clearSecrets();
            _email.clear();
            _advance(_RecoveryStep.success);
          });
        case _RecoveryStep.success:
          return;
      }
    } catch (error) {
      if (!mounted) return;
      final reason = error is PasswordRecoveryException
          ? error.reason
          : PasswordRecoveryFailure.unavailable;
      setState(() {
        _error = switch (reason) {
          PasswordRecoveryFailure.tooManyAttempts => 'Too many attempts. Please wait before trying again or requesting a new code.',
          PasswordRecoveryFailure.expired =>
            'This reset request has expired. Request a new code to continue.',
          PasswordRecoveryFailure.invalid when step == _RecoveryStep.code => 'The code or reset request is invalid. Check the code or request a new one.',
          PasswordRecoveryFailure.invalid => 'This reset request is no longer valid. Request a new code to continue.',
          PasswordRecoveryFailure.policyViolation =>
            'Use at least 8 characters with no spaces at the start or end.',
          PasswordRecoveryFailure.unavailable => 'Unable to complete this request. Check your connection and try again. If it persists, try again later.',
        };
        if (reason == PasswordRecoveryFailure.expired ||
            (reason == PasswordRecoveryFailure.invalid &&
                step != _RecoveryStep.code)) {
          _clearSecrets();
          _advance(_RecoveryStep.email);
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _input({
    required String id,
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
    bool secret = false,
    bool hidden = false,
    VoidCallback? toggle,
    TextInputType keyboard = TextInputType.text,
    TextInputAction action = TextInputAction.done,
    List<String>? autofillHints,
  }) {
    final decoration = digiGymFormDecoration(label, icon: icon);
    return DigiGymGlassField(
      key: ValueKey('recovery-$id'),
      child: TextFormField(
        key: _fields[id],
        focusNode: _focus[id],
        controller: controller,
        readOnly: _busy,
        obscureText: secret && hidden,
        autocorrect: false,
        enableSuggestions: false,
        keyboardType: keyboard,
        autofillHints: autofillHints,
        textInputAction: action,
        onFieldSubmitted: action == TextInputAction.done
            ? (_) => _submit()
            : null,
        onChanged: (_) => _recheck(id),
        validator: validator,
        decoration: decoration.copyWith(
          focusedErrorBorder: decoration.focusedBorder,
          suffixIcon: secret
              ? IconButton(
                  tooltip: '${hidden ? 'Show' : 'Hide'} ${label.toLowerCase()}',
                  onPressed: toggle,
                  icon: Icon(
                    hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_step) {
      _RecoveryStep.email => 'Forgot Password?',
      _RecoveryStep.code => 'Verify Reset Code',
      _RecoveryStep.password => 'New Password',
      _RecoveryStep.success => 'Password Updated',
    };
    final description = switch (_step) {
      _RecoveryStep.email =>
        'Enter your email address to request a password reset code.',
      _RecoveryStep.code => 'If an account matches that email, a reset code may be sent. Enter the code to continue. Delivery is not confirmed here.',
      _RecoveryStep.password =>
        'Choose a new password for your DigiGym account.',
      _RecoveryStep.success => 'Your password has been updated. You can now log in with your new password.',
    };
    return DigiGymFormPage(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DigiGymFormBranding(),
          Semantics(liveRegion: true, child: Text(description)),
          const SizedBox(height: 24),
          if (_step != _RecoveryStep.success)
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUnfocus,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_step == _RecoveryStep.email)
                    _input(
                      id: 'email',
                      label: 'Email',
                      controller: _email,
                      icon: Icons.mail_outline_rounded,
                      keyboard: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) =>
                          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                              .hasMatch(value?.trim() ?? '')
                          ? null
                          : 'Enter a valid email address.',
                    ),
                  if (_step == _RecoveryStep.code)
                    _input(
                      id: 'code',
                      label: 'Verification Code',
                      controller: _code,
                      icon: Icons.verified_user_outlined,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      // Custom Serverpod generators can produce alphanumeric codes.
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your reset code.'
                          : null,
                    ),
                  if (_step == _RecoveryStep.password) ...[
                    _input(
                      id: 'password',
                      label: 'New Password',
                      controller: _password,
                      icon: Icons.lock_outline_rounded,
                      secret: true,
                      hidden: _hidePassword,
                      toggle: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      action: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
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
                    if (_password.text.length < 8 &&
                        !(_fields['password']!.currentState?.hasError ?? false))
                      const Padding(
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
                    const SizedBox(height: 14),
                    _input(
                      id: 'confirmation',
                      label: 'Confirm New Password',
                      controller: _confirmation,
                      icon: Icons.lock_outline_rounded,
                      secret: true,
                      hidden: _hideConfirmation,
                      toggle: () => setState(
                        () => _hideConfirmation = !_hideConfirmation,
                      ),
                      validator: (value) {
                        if ((value == null || value.isEmpty) && !_submitted) {
                          return null;
                        }
                        return value == null ||
                                value.isEmpty ||
                                value != _password.text
                            ? 'Passwords must match exactly.'
                            : null;
                      },
                    ),
                  ],
                ],
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                key: const ValueKey('recovery-error'),
                style: const TextStyle(color: Color(0xFFFFB4AB)),
              ),
            ),
          ],
          const SizedBox(height: 24),
          DigiGymPrimaryButton(
            label: switch (_step) {
              _RecoveryStep.email => 'Send Reset Code',
              _RecoveryStep.code => 'Verify Code',
              _RecoveryStep.password => 'Update Password',
              _RecoveryStep.success => 'Back to Login',
            },
            loading: _busy,
            onPressed: _step == _RecoveryStep.success
                ? () => Navigator.maybePop(context)
                : _submit,
          ),
          if (_step == _RecoveryStep.code ||
              _step == _RecoveryStep.password) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : _restart,
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: const Text('Request a new code'),
            ),
          ],
        ],
      ),
    );
  }
}
