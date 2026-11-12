import 'package:flutter/material.dart';

import 'dashboard_glass_card.dart';
import 'segmented_progress_ring.dart';

class DashboardProgressCard extends StatelessWidget {
  final double progress;
  final double minimumHeight;
  final double ringDiameter;

  const DashboardProgressCard({
    super.key,
    this.progress = 0,
    this.minimumHeight = 0,
    this.ringDiameter = 148,
  });

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: minimumHeight),
    child: DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Today's Progress",
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Center(
            child: SegmentedProgressRing(
              progress: progress,
              diameter: ringDiameter,
            ),
          ),
        ],
      ),
    ),
  );
}
