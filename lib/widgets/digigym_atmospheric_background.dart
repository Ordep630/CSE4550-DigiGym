import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';

/// The approved dashboard background, shared by the authenticated tab shell.
class DigiGymAtmosphericBackground extends StatelessWidget {
  final Widget child;

  const DigiGymAtmosphericBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final surfaces = DigiGymSurfaces.of(context);
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: surfaces.background,
        child: DecoratedBox(decoration: surfaces.atmosphere, child: child),
      ),
    );
  }
}
