import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/workout_plan.dart';
import '../services/workout_schedule_controller.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/workout_overview.dart';
import '../widgets/workout_week_view.dart';
import '../widgets/workout_exercise_list.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/workout_app_bar.dart';
import 'workout_exercises_screen.dart';

enum WorkoutView { myPlan, exercises, moreWorkouts }

class WorkoutsScreen extends StatefulWidget {
  final UserProfile user;
  final WorkoutScheduleController? schedule;
  final DateTime Function()? clock;
  final bool focusSchedule;
  final VoidCallback? onScheduleShown;
  const WorkoutsScreen({
    super.key,
    required this.user,
    this.schedule,
    this.clock,
    this.focusSchedule = false,
    this.onScheduleShown,
  });
  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  WorkoutView _view = WorkoutView.myPlan;
  WorkoutScheduleController? _owned;
  final _scheduleKey = GlobalKey();
  bool _restored = false;
  WorkoutScheduleController get _schedule => widget.schedule ?? _owned!;
  Object get _storageKey =>
      ('workout-view', widget.user.accountId ?? widget.user.email);

  void _bind() {
    if (widget.schedule != null) {
      _owned?.dispose();
      _owned = null;
      return;
    }
    if (_owned == null || _owned!.accountId != widget.user.accountId) {
      _owned?.dispose();
      _owned = WorkoutScheduleController(accountId: widget.user.accountId);
      unawaited(_owned!.initialize());
    }
  }

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void dispose() {
    _owned?.dispose();
    super.dispose();
  }

  void _restoreView() {
    final stored = PageStorage.maybeOf(context)
        ?.readState(context, identifier: _storageKey);
    _view = widget.focusSchedule
        ? WorkoutView.myPlan
        : stored is WorkoutView
        ? stored
        : WorkoutView.myPlan;
    _restored = true;
    if (widget.focusSchedule) _focusSchedule();
  }

  void _focusSchedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _scheduleKey.currentContext;
      if (!mounted || target == null) return;
      Scrollable.ensureVisible(target, alignment: 0);
      widget.onScheduleShown?.call();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_restored) _restoreView();
  }

  @override
  void didUpdateWidget(WorkoutsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _bind();
    if (oldWidget.user.accountId != widget.user.accountId ||
        oldWidget.user.email != widget.user.email) {
      _restoreView();
    }
    if (widget.focusSchedule && !oldWidget.focusSchedule) {
      _view = WorkoutView.myPlan;
      _focusSchedule();
    }
  }

  void _select(WorkoutView view) {
    if (_view == view) return;
    setState(() => _view = view);
    PageStorage.maybeOf(context)
        ?.writeState(context, view, identifier: _storageKey);
  }

  void _openExercises(WorkoutPlan plan, {bool walkthrough = false}) {
    if (plan.exercises.isEmpty) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            WorkoutExercisesScreen(plan: plan, walkthrough: walkthrough),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = WorkoutPlan.forUser(widget.user);
    final alternatives = WorkoutPlan.alternativesForUser(widget.user);
    final base = Theme.of(context);
    final theme = base.copyWith(
      expansionTileTheme: base.expansionTileTheme.copyWith(
        textColor: DigiGymDarkColors.softGreen,
        iconColor: DigiGymDarkColors.softGreen,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: DigiGymDarkColors.softGreen,
        primaryContainer: DigiGymDarkColors.softGreen.withValues(alpha: .12),
      ),
    );
    Widget heading(String text) => Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
    Widget noTime() => WorkoutOverview(
      plan: plan,
      onViewExercises: () {},
      onStartWalkthrough: () {},
    );
    return Theme(
      data: theme,
      child: AnimatedBuilder(
        animation: _schedule,
        builder: (context, _) => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: workoutAppBar(
            context,
            title: 'Workout',
            large: true,
            theme: theme,
          ),
          body: SafeArea(
            top: false,
            bottom: false,
            child: ListView(
              key: PageStorageKey((
                'workout-scroll',
                widget.user.accountId ?? widget.user.email,
                _view,
              )),
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                Text(
                  '${widget.user.fitnessLevel} Plan',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: DigiGymFitnessLevelColors.forLevel(
                      widget.user.fitnessLevel,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _WorkoutSegments(selected: _view, onSelected: _select),
                const SizedBox(height: 20),
                switch (_view) {
                  WorkoutView.myPlan => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WorkoutOverview(
                        plan: plan,
                        onViewExercises: () => _openExercises(plan),
                        onStartWalkthrough: () =>
                            _openExercises(plan, walkthrough: true),
                      ),
                      const SizedBox(height: 20),
                      WorkoutWeekView(
                        key: _scheduleKey,
                        user: widget.user,
                        controller: _schedule,
                        clock: widget.clock,
                      ),
                      if (plan.exercises.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        heading('Exercise preview'),
                        const SizedBox(height: 12),
                        WorkoutExerciseList(plan: plan, limit: 3),
                        OutlinedButton(
                          key: const ValueKey('workout-preview-all'),
                          onPressed: () => _openExercises(plan),
                          child: const Text('View all exercises'),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        'Estimates include a 2-minute warm-up, 1-minute cool-down, set rests and transitions. Your pace may vary.',
                        key: const ValueKey('workout-timing-notice'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  WorkoutView.exercises =>
                    plan.exercises.isEmpty
                        ? noTime()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              heading(plan.title),
                              const SizedBox(height: 8),
                              Text(
                                '${plan.exercises.length} exercises · Estimated ${plan.durationMinutes} min',
                              ),
                              const SizedBox(height: 16),
                              WorkoutExerciseList(plan: plan),
                            ],
                          ),
                  WorkoutView.moreWorkouts => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      heading('More workouts for you'),
                      const SizedBox(height: 8),
                      const Text(
                        'Browse alternatives for your saved goal, level and available time. Viewing one does not replace your primary plan.',
                      ),
                      const SizedBox(height: 16),
                      if (alternatives.isEmpty) noTime(),
                      for (var i = 0; i < alternatives.length; i++)
                        DashboardGlassCard(
                          key: ValueKey('workout-library-plan-$i'),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                alternatives[i].title,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Estimated ${alternatives[i].durationMinutes} min · ${alternatives[i].exercises.length} exercises',
                              ),
                              const SizedBox(height: 8),
                              Text(alternatives[i].description),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                key: ValueKey('workout-library-exercises-$i'),
                                onPressed: () =>
                                    _openExercises(alternatives[i]),
                                child: const Text('View Workout'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkoutSegments extends StatelessWidget {
  final WorkoutView selected;
  final ValueChanged<WorkoutView> onSelected;
  const _WorkoutSegments({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: .65),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in const {
                WorkoutView.myPlan: 'My Plan',
                WorkoutView.exercises: 'Exercises',
                WorkoutView.moreWorkouts: 'More Workouts',
              }.entries)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: selected == entry.key,
                    label: '${entry.value} workout view',
                    onTap: () => onSelected(entry.key),
                    excludeSemantics: true,
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        color: selected == entry.key
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          key: ValueKey('workout-view-${entry.key.name}'),
                          borderRadius: BorderRadius.circular(25),
                          onTap: () => onSelected(entry.key),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 10,
                              ),
                              child: Center(
                                child: Text(
                                  entry.value,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    fontWeight: selected == entry.key
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected == entry.key
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
