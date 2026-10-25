import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/workout_plan.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/workout_overview.dart';
import '../widgets/workout_week_view.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/workout_app_bar.dart';
import 'workout_exercises_screen.dart';

enum WorkoutView { today, thisWeek, allWorkouts }

class WorkoutsScreen extends StatefulWidget {
  final UserProfile user;
  const WorkoutsScreen({super.key, required this.user});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  WorkoutView _view = WorkoutView.today;
  bool _restored = false;

  // Route-local presentation state only: no schedule, session or disk storage.
  Object get _storageKey => ('workout-view', widget.user.email);

  void _restoreView() {
    final stored = PageStorage.maybeOf(context)
        ?.readState(context, identifier: _storageKey);
    _view = stored is WorkoutView ? stored : WorkoutView.today;
    _restored = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_restored) _restoreView();
  }

  @override
  void didUpdateWidget(WorkoutsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.email != widget.user.email) _restoreView();
  }

  void _select(WorkoutView view) {
    if (_view == view) return;
    setState(() => _view = view);
    PageStorage.maybeOf(context)
        ?.writeState(context, view, identifier: _storageKey);
  }

  void _openExercises(WorkoutPlan plan, {bool walkthrough = false}) {
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: workoutAppBar(context, title: 'Workout', large: true),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          key: PageStorageKey(('workout-scroll', widget.user.email, _view)),
          // Reserve the shell's measured inset inside the scroll content.
          // Cards can pass behind the frosted pill, then scroll clear of it.
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Text(
              '${plan.fitnessLevel} Plan',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: DigiGymFitnessLevelColors.forLevel(plan.fitnessLevel),
              ),
            ),
            const SizedBox(height: 18),
            _WorkoutSegments(selected: _view, onSelected: _select),
            const SizedBox(height: 20),
            switch (_view) {
              WorkoutView.today => WorkoutOverview(
                plan: plan,
                onViewExercises: () => _openExercises(plan),
                onStartWalkthrough: () =>
                    _openExercises(plan, walkthrough: true),
              ),
              WorkoutView.thisWeek => WorkoutWeekView(
                onBrowseWorkouts: () => _select(WorkoutView.allWorkouts),
              ),
              WorkoutView.allWorkouts => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your available plan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recommended from your saved fitness level and goal.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DashboardGlassCard(
                    key: const ValueKey('workout-library-plan'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(plan.title, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          '${plan.durationMinutes} min • ${plan.exercises.length} exercises',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(plan.fitnessGoal),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          key: const ValueKey('workout-library-exercises'),
                          onPressed: () => _openExercises(plan),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: const Icon(Icons.format_list_bulleted_rounded),
                          label: const Text('View Exercises'),
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
                WorkoutView.today: 'Today',
                WorkoutView.thisWeek: 'This Week',
                WorkoutView.allWorkouts: 'All Workouts',
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
