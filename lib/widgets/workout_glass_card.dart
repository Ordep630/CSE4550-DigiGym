import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';
import '../theme/digigym_workout_theme.dart';
import 'dashboard_glass_card.dart';

/// One light Workout material, retaining Home's tint, edge, shadow and geometry.
/// Dark cards delegate to the unchanged shared defaults.
class WorkoutGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const WorkoutGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return DashboardGlassCard(
      padding: padding,
      margin: margin,
      cornerRadius: DigiGymDashboardTheme.cardRadius,
      surfaceOpacity: light ? DigiGymWorkoutTheme.cardSurfaceOpacity : 1,
      lightingOpacity: light ? DigiGymWorkoutTheme.cardLightingOpacity : 1,
      backdropSigma: light ? DigiGymWorkoutTheme.cardBackdropSigma : 0,
      child: child,
    );
  }
}
