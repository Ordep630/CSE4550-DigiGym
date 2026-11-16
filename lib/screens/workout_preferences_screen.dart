import 'package:flutter/material.dart';

import '../services/workout_start_preference.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/profile_components.dart';

class WorkoutPreferencesScreen extends StatefulWidget {
  final WorkoutStartPreference preference;

  const WorkoutPreferencesScreen({super.key, required this.preference});

  @override
  State<WorkoutPreferencesScreen> createState() =>
      _WorkoutPreferencesScreenState();
}

class _WorkoutPreferencesScreenState extends State<WorkoutPreferencesScreen> {
  bool? _enabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    widget.preference.confirmationEnabled().then((enabled) {
      if (mounted) setState(() => _enabled = enabled);
    });
  }

  Future<void> _setConfirmation(bool enabled) async {
    setState(() => _saving = true);
    try {
      await widget.preference.setConfirmationEnabled(enabled);
      if (mounted) setState(() => _enabled = enabled);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the workout preference. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => ProfileDestinationScaffold(
    title: 'Preferences',
    child: Builder(
      builder: (context) {
        final surfaces = DigiGymSurfaces.of(context);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DashboardGlassCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                key: const ValueKey('confirm-before-starting-workouts'),
                title: const Text('Confirm Before Starting Workouts'),
                value: _enabled ?? true,
                onChanged: _enabled == null || _saving
                    ? null
                    : _setConfirmation,
                activeTrackColor: surfaces.accent,
                activeThumbColor: surfaces.onAccent,
              ),
            ),
          ],
        );
      },
    ),
  );
}
