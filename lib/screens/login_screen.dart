import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/session.dart';
import '../services/digigym_api.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/digigym_page_shell.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

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
    if (isLoggingIn) return;

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
    // Read above Scaffold, which removes consumed keyboard insets from its body.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return DigiGymPageShell(
      child: Builder(
        builder: (context) => LayoutBuilder(
          builder: (context, constraints) {
            final topSpace = keyboardOpen
                ? 24.0
                : (constraints.maxHeight * .14).clamp(32.0, 128.0);
            final brandingGap = keyboardOpen
                ? 32.0
                : (constraints.maxHeight * .18).clamp(48.0, 160.0);
            final availableWidth = (constraints.maxWidth - 40).clamp(
              0.0,
              440.0,
            );
            final dumbbellWidth = (availableWidth * .47).clamp(120.0, 180.0);
            final wordmarkWidth = (availableWidth * .60).clamp(152.0, 228.0);
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              excludeFromSemantics: true,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 440,
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: topSpace),
                            Semantics(
                              label: 'DigiGym',
                              image: true,
                              excludeSemantics: true,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/digigym_workout_icon.png',
                                    key: const ValueKey('login-dumbbell'),
                                    width: dumbbellWidth,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.none,
                                  ),
                                  const SizedBox(height: 18),
                                  Image.asset(
                                    'assets/images/digigym_wordmark.png',
                                    key: const ValueKey('login-wordmark'),
                                    width: wordmarkWidth,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.none,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: brandingGap),
                            AutofillGroup(
                              child: Column(
                                children: [
                                  _LoginGlassField(
                                    child: TextField(
                                      key: const ValueKey('login-email'),
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.username,
                                      ],
                                      autocorrect: false,
                                      readOnly: isLoggingIn,
                                      style: _inputStyle,
                                      decoration: _decoration(
                                        'Email',
                                        Icons.mail_outline_rounded,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _LoginGlassField(
                                    child: TextField(
                                      key: const ValueKey('login-password'),
                                      controller: passwordController,
                                      obscureText: obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      readOnly: isLoggingIn,
                                      onSubmitted: (_) => login(),
                                      style: _inputStyle,
                                      decoration:
                                          _decoration(
                                            'Password',
                                            Icons.lock_outline_rounded,
                                          ).copyWith(
                                            suffixIcon: IconButton(
                                              tooltip: obscurePassword
                                                  ? 'Show password'
                                                  : 'Hide password',
                                              icon: Icon(
                                                obscurePassword
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
                                                size: 24,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  obscurePassword =
                                                      !obscurePassword;
                                                });
                                              },
                                            ),
                                          ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                ForgotPasswordScreen(
                                                  api: widget.api,
                                                ),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            DigiGymDarkColors.secondaryText,
                                        overlayColor: DigiGymDarkColors
                                            .electricGreen
                                            .withValues(alpha: .10),
                                        minimumSize: const Size(48, 48),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      child: const Text('Forgot Password?'),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _LoginButton(
                                    loading: isLoggingIn,
                                    onPressed: isLoggingIn ? null : login,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),
                            const Text(
                              'Demo Login',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Semantics(
                              label: 'Demo credentials: demo@gym.com, password 123456',
                              excludeSemantics: true,
                              child: const Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                  Text(
                                    'demo@gym.com',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: DigiGymDarkColors.secondaryText,
                                    ),
                                  ),
                                  Text(
                                    '|',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: DigiGymDarkColors.secondaryText,
                                    ),
                                  ),
                                  Text(
                                    '123456',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: DigiGymDarkColors.electricGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 12),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: Color(0x404F6157)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      'or',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: Color(0x404F6157)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                children: [
                                  const Text(
                                    "Don't have an account?",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              RegisterScreen(api: widget.api),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          DigiGymDarkColors.electricGreen,
                                      minimumSize: const Size(48, 48),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      textStyle: const TextStyle(fontSize: 15),
                                    ),
                                    child: const Text('Sign Up'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static const _inputStyle = TextStyle(
    fontSize: 16,
    height: 1.4,
    color: DigiGymDarkColors.primaryText,
  );

  InputDecoration _decoration(String hint, IconData icon) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(_loginFieldRadius(context)),
      borderSide: BorderSide(color: color),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: _inputStyle.copyWith(color: DigiGymDarkColors.secondaryText),
      prefixIcon: Icon(icon, size: 24),
      prefixIconColor: DigiGymDarkColors.secondaryText,
      suffixIconColor: DigiGymDarkColors.secondaryText,
      prefixIconConstraints: const BoxConstraints(minWidth: 54, minHeight: 48),
      suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      isDense: true,
      filled: false,
      constraints: const BoxConstraints(minHeight: 64),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: border(const Color(0x25D9E7DE)),
      enabledBorder: border(const Color(0x25D9E7DE)),
      focusedBorder: border(
        DigiGymDarkColors.electricGreen.withValues(alpha: .55),
      ),
    );
  }
}

// Keep the outline and blur clip in agreement as accessible text grows.
double _loginFieldRadius(BuildContext context) =>
    (MediaQuery.textScalerOf(context).scale(16) * 1.4 + 36).clamp(
      64.0,
      double.infinity,
    ) /
    2;

class _LoginGlassField extends StatelessWidget {
  final Widget child;
  const _LoginGlassField({required this.child});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(_loginFieldRadius(context)),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x801F2925), Color(0x40101815)],
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: child,
        ),
      ),
    ),
  );
}

class _LoginButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  const _LoginButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          // Muted tonal companions to the official artwork's #3DFB65 green.
          const Color(0xFF3CBF5F).withValues(alpha: loading ? .40 : 1),
          const Color(0xFF67E780).withValues(alpha: loading ? .40 : 1),
        ],
      ),
      boxShadow: loading
          ? null
          : [
              BoxShadow(
                color: DigiGymDarkColors.electricGreen.withValues(alpha: .15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        foregroundColor: DigiGymDarkColors.graphite,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        minimumSize: const Size(double.infinity, 64),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      child: loading
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DigiGymDarkColors.graphite,
                semanticsLabel: 'Signing in',
              ),
            )
          : const Row(
              children: [
                SizedBox(width: 24),
                Expanded(child: Text('Login', textAlign: TextAlign.center)),
                SizedBox(
                  width: 24,
                  child: Icon(Icons.arrow_forward_rounded, size: 22),
                ),
              ],
            ),
    ),
  );
}
