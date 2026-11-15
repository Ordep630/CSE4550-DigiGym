import 'dart:async';

import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    show KeyValueStorage;

import '../models/user_profile.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../theme/digigym_screen_theme.dart';
import '../widgets/floating_bottom_navigation_bar.dart';
import '../widgets/digigym_atmospheric_background.dart';
import '../services/digigym_api.dart';
import '../services/dashboard_personalization.dart';
import '../services/meal_recommendation_service.dart';
import '../services/grocery_list_controller.dart';
import '../services/workout_schedule_controller.dart';
import '../services/workout_session_controller.dart';
import '../services/workout_start_preference.dart';
import '../services/workout_scheduling.dart';
import '../models/workout_schedule_day.dart';
import '../widgets/workout_schedule_details.dart';
import 'dashboard_screen.dart';
import 'workouts_screen.dart';
import 'workout_history_screen.dart';
import 'meal_page.dart';
import 'grocery_screen.dart';
import 'profile_screen.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile user;
  final Future<void> Function() onLogout;
  final Function(UserProfile) onUpdateProfile;
  final DigiGymApi api;
  final String motivationalMessage;
  final DateTime Function()? clock;
  final WorkoutScheduleController? workoutSchedule;
  final KeyValueStorage? workoutSessionStorage;
  final KeyValueStorage? workoutPreferenceStorage;
  final Duration Function()? workoutMonotonicNow;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onUpdateProfile,
    this.api = digiGymApi,
    this.motivationalMessage = DashboardPersonalization.defaultMessage,
    this.clock,
    this.workoutSchedule,
    this.workoutSessionStorage,
    this.workoutPreferenceStorage,
    this.workoutMonotonicNow,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int selectedIndex = 0;
  GroceryListController? _groceries;
  late WorkoutScheduleController _schedule;
  WorkoutSessionController? _workoutSession;
  WorkoutStartPreference? _workoutStartPreference;
  bool _ownsSchedule = false;
  bool _focusSchedule = false;
  int? _streakDays;
  bool _streakUnavailable = false;
  int _streakRequest = 0;

  String? get _streakAccount =>
      widget.user.isDemo ? null : widget.user.accountId;

  Future<void> _loadStreak() async {
    final request = ++_streakRequest;
    final account = _streakAccount;
    if (account == null) return;
    int? days;
    bool unavailable = false;
    try {
      if (widget.api.authenticatedAccountId == account) {
        days = await widget.api.getWorkoutStreak(
          (widget.clock ?? DateTime.now)(),
        );
      }
    } catch (_) {
      unavailable = true;
    }
    if (!mounted || request != _streakRequest) return;
    setState(() {
      _streakDays = days;
      _streakUnavailable = unavailable;
    });
  }

  @override
  void initState() {
    super.initState();
    _bindSchedule();
    _bindWorkoutSession();
    _bindWorkoutStartPreference();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadStreak());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    _workoutSession?.foregroundChanged(foreground: foreground);
    if (foreground) unawaited(_loadStreak());
  }

  void _bindWorkoutSession() {
    _workoutSession?.dispose();
    _workoutSession = null;
    final account = _streakAccount;
    if (account == null || widget.api.authenticatedAccountId != account) return;
    final session = WorkoutSessionController(
      accountId: account,
      api: widget.api,
      storage: widget.workoutSessionStorage,
      monotonicNow: widget.workoutMonotonicNow,
      onStreakUpdated: () => unawaited(_loadStreak()),
    );
    _workoutSession = session;
    unawaited(session.initialize());
    unawaited(session.refreshHistory());
  }

  void _bindWorkoutStartPreference() {
    final account = _workoutSession?.accountId;
    _workoutStartPreference = account == null
        ? null
        : WorkoutStartPreference(
            accountId: account,
            storage: widget.workoutPreferenceStorage,
          );
  }

  Future<void> _logout() async {
    await _workoutSession?.prepareLogout();
    if (mounted) await widget.onLogout();
  }

  void _openActivity(DateTime day) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => WorkoutHistoryScreen(
          api: widget.api,
          session: _workoutSession,
          day: day,
        ),
      ),
    );
  }

  void _bindSchedule() {
    assert(
      widget.workoutSchedule == null ||
          widget.workoutSchedule!.accountId == widget.user.accountId,
    );
    _ownsSchedule = widget.workoutSchedule == null;
    _schedule =
        widget.workoutSchedule ??
        WorkoutScheduleController(
          accountId: widget.user.accountId,
          api: widget.api,
        );
    unawaited(_schedule.initialize());
    _schedule.addListener(_scheduleChanged);
  }

  void _scheduleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final workoutSessionChanged =
        oldWidget.user.accountId != widget.user.accountId ||
        oldWidget.user.isDemo != widget.user.isDemo ||
        oldWidget.api != widget.api ||
        oldWidget.workoutSessionStorage != widget.workoutSessionStorage;
    if (workoutSessionChanged) {
      _bindWorkoutSession();
      _streakDays = null;
      _streakUnavailable = false;
      unawaited(_loadStreak());
    }
    if (workoutSessionChanged ||
        oldWidget.workoutPreferenceStorage != widget.workoutPreferenceStorage) {
      _bindWorkoutStartPreference();
    }
    if (oldWidget.user.accountId != widget.user.accountId ||
        oldWidget.workoutSchedule != widget.workoutSchedule ||
        (widget.user.accountId == null &&
            oldWidget.user.email != widget.user.email)) {
      _schedule.removeListener(_scheduleChanged);
      if (_ownsSchedule) _schedule.dispose();
      _bindSchedule();
      _focusSchedule = false;
    }
  }

  void _openSchedule() => setState(() {
    selectedIndex = 1;
    _focusSchedule = true;
  });

  void _openDay(WorkoutScheduleDay day) {
    final assigned = WorkoutScheduling.week(
      user: widget.user,
      workoutDays: _schedule.workoutDays,
      date: day.date,
    ).firstWhere((entry) => entry.date == day.date);
    showWorkoutDay(context, assigned, onSetUp: _openSchedule);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _groceries?.dispose();
    _workoutSession?.dispose();
    _schedule.removeListener(_scheduleChanged);
    if (_ownsSchedule) _schedule.dispose();
    super.dispose();
  }

  void selectTab(int index) {
    setState(() => selectedIndex = index);
    if (index == 0) unawaited(_loadStreak());
  }

  Future<void> editProfile() async {
    final updatedUser = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: widget.user, api: widget.api),
      ),
    );
    if (mounted && updatedUser != null) widget.onUpdateProfile(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.user.email.trim().toLowerCase();
    if (_groceries?.accountKey != account) {
      _groceries?.dispose();
      _groceries = GroceryListController(accountKey: account);
    }
    final meals = const MealRecommendationService().recommend(widget.user);
    // Parent rebuild already updates the active page. Never notify descendants
    // while building; this controller survives replacement of the tab subtree.
    _groceries!.reconcile(meals, notify: false);
    final pages = [
      DashboardPage(
        user: widget.user,
        motivationalMessage: widget.motivationalMessage,
        streakDays: _streakDays,
        streakUnavailable: _streakUnavailable,
        clock: widget.clock,
        onSelectTab: selectTab,
        onEditProfile: editProfile,
        workoutSchedule: _schedule,
        onSeeWeek: _openSchedule,
        onScheduleDay: _openDay,
        session: _workoutSession,
        onActivitySelected: _openActivity,
        onActivityDayChanged: () {
          if (mounted) setState(() {});
        },
      ),
      WorkoutsScreen(
        user: widget.user,
        api: widget.api,
        session: _workoutSession,
        startPreference: _workoutStartPreference,
        schedule: _schedule,
        clock: widget.clock,
        focusSchedule: _focusSchedule,
        onScheduleShown: () => _focusSchedule = false,
      ),
      MealPage(user: widget.user, recommendations: meals),
      GroceryScreen(controller: _groceries),
      ProfilePage(
        user: widget.user,
        onLogout: _logout,
        onUpdateProfile: widget.onUpdateProfile,
        api: widget.api,
        workoutStartPreference: _workoutStartPreference,
      ),
    ];

    final base = Theme.of(context);
    final followsAppearance =
        selectedIndex == 0 || DigiGymScreenTheme.isLight(context);
    final theme = followsAppearance
        ? DigiGymDashboardTheme.resolve(base)
        : DigiGymDashboardTheme.dark(base);
    final contentTheme = DigiGymDashboardTheme.content(
      selectedIndex >= 2 ? DigiGymScreenTheme.lightControls(theme) : theme,
    );

    return Theme(
      data: theme,
      child: DigiGymAtmosphericBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: Theme(data: contentTheme, child: pages[selectedIndex]),
          bottomNavigationBar: FloatingBottomNavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: selectTab,
          ),
        ),
      ),
    );
  }
}
