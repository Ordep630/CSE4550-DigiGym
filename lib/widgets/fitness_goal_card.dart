import 'package:flutter/material.dart';

/// Shows the saved goal without implying any measured progress.
class FitnessGoalCard extends StatelessWidget {
  final String goal;

  /// An optional future progress visual, supplied when real tracking exists.
  /// No space is allocated when this is omitted.
  final Widget? visual;

  const FitnessGoalCard({super.key, required this.goal, this.visual});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.track_changes,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Fitness goal',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              goal,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.4,
              ),
            ),
            if (visual != null) ...[const SizedBox(height: 16), visual!],
          ],
        ),
      ),
    );
  }
}
