import 'package:flutter/material.dart';

import '../services/workout_schedule_controller.dart';
import '../theme/digigym_dashboard_theme.dart';
import 'digigym_dialog.dart';

Future<void> editWorkoutSchedule(
  BuildContext context,
  WorkoutScheduleController controller,
) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _ScheduleEditor(controller: controller),
);

class _ScheduleEditor extends StatefulWidget {
  final WorkoutScheduleController controller;
  const _ScheduleEditor({required this.controller});
  @override
  State<_ScheduleEditor> createState() => _ScheduleEditorState();
}

class _ScheduleEditorState extends State<_ScheduleEditor> {
  late final Set<int> _days = {...?widget.controller.workoutDays};
  static const names = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      return PopScope(
        canPop: !controller.saving,
        child: DigiGymDialog(
          title: 'Your workout days',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Workout or leave Rest for each day. All rest days is also a valid choice.',
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < 7; i++)
                CheckboxListTile(
                  key: ValueKey('schedule-edit-day-$i'),
                  contentPadding: EdgeInsets.zero,
                  activeColor: DigiGymDarkColors.softGreen,
                  title: Text(names[i]),
                  subtitle: Text(_days.contains(i) ? 'Workout' : 'Rest'),
                  value: _days.contains(i),
                  onChanged: controller.saving
                      ? null
                      : (checked) => setState(() {
                          checked! ? _days.add(i) : _days.remove(i);
                        }),
                ),
              const SizedBox(height: 12),
              Text(
                'Saved securely to your account through Serverpod.',
                key: const ValueKey('schedule-server-storage-disclosure'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (controller.error != null)
                Semantics(
                  liveRegion: true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      controller.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              key: const ValueKey('schedule-cancel'),
              onPressed: controller.saving
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const ValueKey('schedule-save'),
              onPressed: controller.saving
                  ? null
                  : () async {
                      final saved = await controller.save(_days);
                      if (saved && context.mounted) Navigator.pop(context);
                    },
              child: Text(controller.saving ? 'Saving…' : 'Save Schedule'),
            ),
          ],
        ),
      );
    },
  );
}
