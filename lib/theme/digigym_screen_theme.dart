import 'package:flutter/material.dart';

import 'digigym_dashboard_theme.dart';

/// Applies the approved palette to controls on the remaining light screens.
/// Home and Workout keep their existing theme scopes.
abstract final class DigiGymScreenTheme {
  static bool isLight(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.light &&
        theme.extension<DigiGymSurfaces>() != null;
  }

  static ThemeData route(BuildContext context) {
    final base = Theme.of(context);
    return DigiGymDashboardTheme.content(
      isLight(context) ? lightControls(base) : DigiGymDashboardTheme.dark(base),
    );
  }

  static ThemeData lightControls(ThemeData base) {
    if (base.brightness != Brightness.light) return base;
    final surfaces = base.extension<DigiGymSurfaces>() ?? DigiGymSurfaces.light;
    final colors = base.colorScheme.copyWith(
      primary: surfaces.accent,
      onPrimary: surfaces.onAccent,
      onPrimaryContainer: surfaces.accent,
    );
    return base.copyWith(
      colorScheme: colors,
      listTileTheme: base.listTileTheme.copyWith(
        iconColor: colors.onSurfaceVariant,
      ),
      textSelectionTheme: base.textSelectionTheme.copyWith(
        cursorColor: surfaces.accent,
        selectionColor: surfaces.accent.withValues(alpha: .24),
        selectionHandleColor: surfaces.accent,
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        backgroundColor: colors.surface,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: colors.onSurface,
        ),
        actionTextColor: surfaces.accent,
      ),
    );
  }
}
