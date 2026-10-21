import 'package:flutter/material.dart';

import 'dashboard_glass_card.dart';

/// Shows the saved goal without implying any measured progress.
class FitnessGoalCard extends StatelessWidget {
  final String goal;
  final double minimumHeight;

  /// An optional future progress visual, supplied when real tracking exists.
  /// No space is allocated when this is omitted.
  final Widget? visual;

  const FitnessGoalCard({
    super.key,
    required this.goal,
    this.visual,
    this.minimumHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minimumHeight),
      child: DashboardGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Fitness goal',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: DashboardIconBadge(
                icon: switch (goal) {
                  'Lose Weight' => Icons.monitor_weight_outlined,
                  'Maintain Weight' => Icons.balance,
                  'Gain Weight' => Icons.trending_up,
                  _ => Icons.track_changes,
                },
                size: 68,
                child: goal == 'Build Muscle'
                    ? Image.asset(
                        'assets/icons/biceps_flexed.png',
                        width: 68 * 0.52,
                        height: 68 * 0.52,
                        color: theme.colorScheme.primary,
                        colorBlendMode: BlendMode.srcIn,
                        excludeFromSemantics: true,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              goal,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w600,
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
