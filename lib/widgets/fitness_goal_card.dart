import 'package:flutter/material.dart';

import 'dashboard_glass_card.dart';

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
    return DashboardGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Fitness goal',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: DashboardIconBadge(icon: Icons.track_changes, size: 84),
          ),
          const SizedBox(height: 18),
          Text(
            goal,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 21,
              height: 1.25,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
          if (visual != null) ...[const SizedBox(height: 16), visual!],
        ],
      ),
    );
  }
}
