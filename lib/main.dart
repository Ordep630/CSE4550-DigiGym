import 'package:flutter/material.dart';

import 'client.dart';
import 'models/user_profile.dart';
import 'models/session.dart';
import 'services/digigym_api.dart';
import 'services/dashboard_personalization.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/home_screen.dart';
import 'screens/meals_screen.dart';
import 'screens/grocery_screen.dart';
import 'screens/verify_email_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(const DigiGymApp());
}

class DigiGymApp extends StatefulWidget {
  final DigiGymApi api;
  final DashboardPersonalization? personalization;
  final DateTime Function()? clock;

  const DigiGymApp({
    super.key,
    this.api = digiGymApi,
    this.personalization,
    this.clock,
  });

  @override
  State<DigiGymApp> createState() => _DigiGymAppState();
}

class _DigiGymAppState extends State<DigiGymApp> with WidgetsBindingObserver {
  bool isRestoringSession = true;
  bool isClearingSession = false;
  bool isCompletingProfile = false;
  String? sessionRestoreError;
  late final DashboardPersonalization _personalization;
  String _motivationalMessage = DashboardPersonalization.defaultMessage;

  @override
  void initState() {
    super.initState();
    _personalization = widget.personalization ?? DashboardPersonalization();
    WidgetsBinding.instance.addObserver(this);
    restoreSession();
  }

  Future<void> restoreSession() async {
    setState(() {
      isRestoringSession = true;
      sessionRestoreError = null;
    });

    try {
      await _personalization.initialize();
      final user = await widget.api.restoreProfile();
      if (widget.api.isAuthenticated && user == null) {
        throw StateError('The signed-in account has no DigiGym profile.');
      }

      if (!mounted) return;
      if (user != null) {
        _motivationalMessage = _personalization.restoreSession(user.email);
      }
      setState(() {
        DigiGymSession.currentUser = user;
        isRestoringSession = false;
        isCompletingProfile = false;
      });
    } on ProfileSetupRequiredException catch (error) {
      if (!mounted) return;
      DigiGymSession.pendingUser = UserProfile(name: '', email: error.email);
      DigiGymSession.clearRegistrationPassword();
      setState(() {
        isRestoringSession = false;
        isCompletingProfile = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isRestoringSession = false;
        sessionRestoreError =
            'DigiGym could not restore your session. Check the backend '
            'connection and try again.';
      });
    }
  }

  void _finishProfileSetup() {
    setState(() {
      isCompletingProfile = false;
      DigiGymSession.currentUser = null;
    });
  }

  void _login(UserProfile user) {
    _motivationalMessage = _personalization.startSession(user.email);
    setState(() {
      DigiGymSession.currentUser = user;
    });
  }

  Future<void> _logout() async {
    await widget.api.signOut();

    if (!mounted) return;

    setState(() {
      DigiGymSession.currentUser = null;
      _motivationalMessage = DashboardPersonalization.defaultMessage;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _personalization.retryPersistence();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> clearStoredSession() async {
    setState(() {
      isClearingSession = true;
    });

    try {
      await _logout();
      if (!mounted) return;
      setState(() {
        sessionRestoreError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        sessionRestoreError = 'Unable to sign out this device. Check your connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isClearingSession = false;
        });
      }
    }
  }

  void _updateProfile(UserProfile user) {
    setState(() {
      DigiGymSession.currentUser = user;
      if (DigiGymSession.registeredUser?.email == user.email) {
        DigiGymSession.registeredUser = user;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget home;
    if (isRestoringSession) {
      home = const _SessionLoadingScreen();
    } else if (isCompletingProfile) {
      home = AssessmentScreen(api: widget.api, onComplete: _finishProfileSetup);
    } else if (sessionRestoreError != null) {
      home = _SessionRestoreErrorScreen(
        message: sessionRestoreError!,
        isClearingSession: isClearingSession,
        onRetry: restoreSession,
        onSignOut: clearStoredSession,
      );
    } else if (DigiGymSession.currentUser == null) {
      home = LoginScreen(onLogin: _login, api: widget.api);
    } else {
      home = HomeScreen(
        user: DigiGymSession.currentUser!,
        motivationalMessage: _motivationalMessage,
        clock: widget.clock,
        onLogout: _logout,
        onUpdateProfile: _updateProfile,
        api: widget.api,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DigiGym',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
      ),
      home: home,
      routes: {
        '/verify-email': (context) => VerifyEmailScreen(api: widget.api),
        '/register': (_) => RegisterScreen(api: widget.api),
        '/assessment': (_) => AssessmentScreen(api: widget.api),
        '/meals': (_) => const MealsScreen(),
        '/groceries': (_) => const GroceryScreen(),
      },
    );
  }
}

class _SessionLoadingScreen extends StatelessWidget {
  const _SessionLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Restoring your session...'),
          ],
        ),
      ),
    );
  }
}

class _SessionRestoreErrorScreen extends StatelessWidget {
  final String message;
  final bool isClearingSession;
  final Future<void> Function() onRetry;
  final Future<void> Function() onSignOut;

  const _SessionRestoreErrorScreen({
    required this.message,
    required this.isClearingSession,
    required this.onRetry,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 64),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isClearingSession ? null : onRetry,
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: isClearingSession ? null : onSignOut,
                  child: isClearingSession
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign out on this device'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
