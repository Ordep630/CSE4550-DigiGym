import 'dart:convert';

import 'package:digigym_backend_client/digigym_backend_client.dart'
    show CompletedWorkout;
import 'package:flutter/material.dart';

import '../services/digigym_api.dart';
import '../theme/digigym_screen_theme.dart';
import '../theme/digigym_workout_theme.dart';
import '../widgets/workout_glass_card.dart';
import '../widgets/digigym_dialog.dart';
import '../widgets/digigym_atmospheric_background.dart';
import '../widgets/workout_app_bar.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  final DigiGymApi api;

  const WorkoutHistoryScreen({super.key, this.api = digiGymApi});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  late Future<List<CompletedWorkout>> _history;

  final Set<int> _selectedIds = <int>{};

  bool _selectionMode = false;
  bool _isDeleting = false;
  bool _confirmingDelete = false;

  @override
  void initState() {
    super.initState();
    _history = widget.api.getWorkoutHistory();
  }

  void _reload() {
    setState(() {
      _history = widget.api.getWorkoutHistory();
    });
  }

  Future<void> _refresh() async {
    final request = widget.api.getWorkoutHistory();

    setState(() {
      _history = request;
    });

    try {
      await request;
    } catch (_) {}
  }

  String _date(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(context).formatShortDate(value.toLocal());

  String _time(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(value.toLocal()),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );

  List<dynamic> _exercises(CompletedWorkout workout) {
    try {
      final decoded = jsonDecode(workout.details);

      if (decoded is List) {
        return decoded;
      }
    } catch (_) {}

    return const <dynamic>[];
  }

  void _toggleSelected(int id) {
    if (_isDeleting) return;
    setState(() {
      if (!_selectedIds.add(id)) {
        _selectedIds.remove(id);
      }

      if (_selectedIds.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty || _isDeleting || _confirmingDelete) {
      return;
    }

    final ids = _selectedIds.toList(growable: false);
    final count = ids.length;
    _confirmingDelete = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return DigiGymDialog(
          title: 'Delete $count ${count == 1 ? 'workout' : 'workouts'}?',
          content: const Text(
            'This removes the selected workouts from history. Your streak stays as it is.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const ValueKey('confirm-delete-workouts'),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    _confirmingDelete = false;
    if (!mounted || confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      final deleted = await widget.api.deleteWorkoutHistory(ids);

      if (!mounted) return;

      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
        _history = widget.api.getWorkoutHistory();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$deleted ${deleted == 1 ? 'workout' : 'workouts'} deleted from your history.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not delete the selected workouts. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showWorkoutDetails(BuildContext context, CompletedWorkout workout) {
    final exercises = _exercises(workout);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    workout.workoutName,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completed ${_date(context, workout.completedAt)} at ${_time(context, workout.completedAt)}',
                  ),
                  Text('Planned duration: ${workout.durationMinutes} minutes'),
                  const SizedBox(height: 18),
                  Text(
                    'Exercises',
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (exercises.isEmpty)
                    const Text(
                      'No exercise details were saved for this workout.',
                    )
                  else
                    for (final exercise in exercises)
                      if (exercise is Map)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${exercise['name'] ?? 'Exercise'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (exercise['sets'] != null)
                                Text('${exercise['sets']}'),
                              if (exercise['description'] != null)
                                Text('${exercise['description']}'),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = DigiGymWorkoutTheme.apply(DigiGymScreenTheme.route(context));

    return Theme(
      data: theme,
      child: DigiGymAtmosphericBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: workoutAppBar(
            context,
            title: _selectionMode
                ? '${_selectedIds.length} selected'
                : 'Workout History',
            showBack: true,
            theme: theme,
            actions: [
              if (_selectionMode)
                IconButton(
                  tooltip: 'Cancel selection',
                  onPressed: _isDeleting
                      ? null
                      : () {
                          setState(() {
                            _selectionMode = false;
                            _selectedIds.clear();
                          });
                        },
                  icon: const Icon(Icons.close),
                )
              else
                IconButton(
                  tooltip: 'Select workouts to delete',
                  onPressed: () {
                    setState(() {
                      _selectionMode = true;
                    });
                  },
                  icon: const Icon(Icons.checklist),
                ),
              if (_selectionMode)
                IconButton(
                  tooltip: 'Delete selected workouts',
                  onPressed: _selectedIds.isEmpty || _isDeleting
                      ? null
                      : _deleteSelected,
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: FutureBuilder<List<CompletedWorkout>>(
              future: _history,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Unable to load workout history.'),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _reload,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final workouts = snapshot.data ?? const <CompletedWorkout>[];

                if (workouts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No completed workouts yet',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Workouts you mark as completed will appear here.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: workouts.length,
                    separatorBuilder: (_, _) {
                      return const SizedBox(height: 10);
                    },
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      final workoutId = workout.id!;
                      final selected = _selectedIds.contains(workoutId);

                      return WorkoutGlassCard(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          leading: _selectionMode
                              ? Checkbox(
                                  value: selected,
                                  onChanged: _isDeleting
                                      ? null
                                      : (_) => _toggleSelected(workoutId),
                                )
                              : Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                ),
                          title: Text(
                            workout.workoutName,
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            'Completed ${_date(context, workout.completedAt)} · ${workout.durationMinutes} min planned',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onLongPress: !_selectionMode
                              ? () {
                                  setState(() {
                                    _selectionMode = true;
                                    _selectedIds.add(workoutId);
                                  });
                                }
                              : null,
                          onTap: () {
                            if (_selectionMode) {
                              _toggleSelected(workoutId);
                            } else {
                              _showWorkoutDetails(context, workout);
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
