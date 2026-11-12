import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';

/// The approved dashboard background, shared by the authenticated tab shell.
class DigiGymAtmosphericBackground extends StatelessWidget {
  final Widget child;

  const DigiGymAtmosphericBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: DigiGymDarkColors.graphite,
          gradient: RadialGradient(
            center: Alignment(1.2, -0.6),
            radius: 1.6,
            colors: [Color(0xFF202C30), DigiGymDarkColors.graphite],
            stops: [0, 0.85],
          ),
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-1.1, 1.2),
              radius: 1.25,
              colors: [Color(0x0D39FF98), Color(0x0039FF98)],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
