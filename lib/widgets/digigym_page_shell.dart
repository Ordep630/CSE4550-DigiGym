import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/digigym_screen_theme.dart';
import 'digigym_atmospheric_background.dart';

/// Scoped page styling; applying it never changes sibling routes or main tabs.
class DigiGymPageShell extends StatelessWidget {
  final Widget child;

  const DigiGymPageShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = DigiGymScreenTheme.route(context);
    return Theme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
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
