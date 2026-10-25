import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/digigym_dashboard_theme.dart';
import 'digigym_atmospheric_background.dart';

/// Scoped page styling; applying it never changes sibling routes or main tabs.
class DigiGymPageShell extends StatelessWidget {
  final Widget child;

  const DigiGymPageShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = DigiGymDashboardTheme.content(
      DigiGymDashboardTheme.dark(Theme.of(context)),
    );
    return Theme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: DigiGymAtmosphericBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(child: child),
          ),
        ),
      ),
    );
  }
}
