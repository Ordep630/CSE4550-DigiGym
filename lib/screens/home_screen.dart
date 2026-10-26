import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/floating_bottom_navigation_bar.dart';
import '../widgets/digigym_atmospheric_background.dart';
import '../services/digigym_api.dart';
import '../services/dashboard_personalization.dart';
import '../services/meal_recommendation_service.dart';
import '../services/grocery_list_controller.dart';
import '../services/workout_schedule_controller.dart';
import '../services/workout_scheduling.dart';
import '../models/workout_schedule_day.dart';
import '../widgets/workout_schedule_details.dart';
import 'dashboard_screen.dart';
import 'workouts_screen.dart';
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

  const HomeScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onUpdateProfile,
    this.api = digiGymApi,
    this.motivationalMessage = DashboardPersonalization.defaultMessage,
    this.clock,
    this.workoutSchedule,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  GroceryListController? _groceries;
  late WorkoutScheduleController _schedule;
  bool _ownsSchedule = false;
  bool _focusSchedule = false;

  @override
  void initState() {
    super.initState();
    _bindSchedule();
  }

  void _bindSchedule() {
    assert(
      widget.workoutSchedule == null ||
          widget.workoutSchedule!.accountId == widget.user.accountId,
    );
    _ownsSchedule = widget.workoutSchedule == null;
    _schedule =
        widget.workoutSchedule ??
        WorkoutScheduleController(accountId: widget.user.accountId);
    unawaited(_schedule.initialize());
    _schedule.addListener(_scheduleChanged);
  }

  void _scheduleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    _groceries?.dispose();
    _schedule.removeListener(_scheduleChanged);
    if (_ownsSchedule) _schedule.dispose();
    super.dispose();
  }

  void selectTab(int index) {
    setState(() => selectedIndex = index);
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
        clock: widget.clock,
        onSelectTab: selectTab,
        onEditProfile: editProfile,
        workoutSchedule: _schedule,
        onSeeWeek: _openSchedule,
        onScheduleDay: _openDay,
      ),
      WorkoutsScreen(
        user: widget.user,
        schedule: _schedule,
        clock: widget.clock,
        focusSchedule: _focusSchedule,
        onScheduleShown: () => _focusSchedule = false,
      ),
      MealPage(user: widget.user, recommendations: meals),
      GroceryScreen(controller: _groceries),
      ProfilePage(
        user: widget.user,
        onLogout: widget.onLogout,
        onUpdateProfile: widget.onUpdateProfile,
        api: widget.api,
      ),
    ];

    final darkTheme = DigiGymDashboardTheme.dark(Theme.of(context));

    return Theme(
      data: darkTheme,
      child: DigiGymAtmosphericBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: Theme(
            data: DigiGymDashboardTheme.content(darkTheme),
            child: pages[selectedIndex],
          ),
          bottomNavigationBar: FloatingBottomNavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: selectTab,
          ),
        ),
      ),
    );
  }
}
