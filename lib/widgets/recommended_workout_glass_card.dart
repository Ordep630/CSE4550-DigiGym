import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';
import 'dashboard_glass_card.dart';
import 'workout_glass_card.dart';

/// Isolated recommendation experiment. Other Workout cards keep their material.
class RecommendedWorkoutGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const RecommendedWorkoutGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  static const backdropSigma = 12.0;

  // Neutral transmission plus a localized diagonal reflection. A broad white
  // wash over this smooth silver backdrop reads as a panel even with blur.
  static const fill = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x6BFFFFFF),
        Color(0x2EFFFFFF),
        Color(0x24FFFFFF),
        Color(0x47FFFFFF),
      ],
      stops: [0, .30, .65, 1],
    ),
  );
  static const reflection = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment(-1, -.65),
      end: Alignment(1, .65),
      colors: [
        Color(0x42FFFFFF),
        Color(0x05FFFFFF),
        Color(0xA6FFFFFF),
        Color(0x08FFFFFF),
        Color(0x14FFFFFF),
      ],
      stops: [0, .32, .48, .60, 1],
    ),
  );
  static const edge = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0x8CFFFFFF),
      Color(0x24FFFFFF),
      Color(0x61FFFFFF),
    ],
    stops: [0, .12, .5, 1],
  );

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    if (base.brightness != Brightness.light) {
      return WorkoutGlassCard(padding: padding, child: child);
    }
    final surfaces = DigiGymSurfaces.of(context);
    return Theme(
      data: base.copyWith(
        extensions: [
          ...base.extensions.values.where((value) => value is! DigiGymSurfaces),
          surfaces.copyWith(
            glass: fill,
            glassLighting: reflection,
            glassEdge: edge,
          ),
        ],
      ),
      child: DashboardGlassCard(
        padding: padding,
        backdropSigma: backdropSigma,
        child: child,
      ),
    );
  }
}
