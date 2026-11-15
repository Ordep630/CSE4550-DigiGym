import 'package:flutter/material.dart';

import 'digigym_dashboard_theme.dart';

/// Workout styling built on the existing Home appearance palette.
abstract final class DigiGymWorkoutTheme {
  // Scale the Home fill and reflection together so the reflection cannot wash
  // out the extra transmission. Frost is clipped by the shared glass renderer.
  static const cardSurfaceOpacity = .80;
  static const cardLightingOpacity = .60;
  static const cardBackdropSigma = 8.0;

  // Retain the approved segmented-control surface independently of the shared
  // floating-navigation opacity experiment. This is its existing 42% tint.
  static const segmentSurface = Color(0x6BF8F9FB);

  // Approved light-only alternative to the low-contrast dark orange #F2A34A.
  static const intermediatePlanAccent = Color(0xFF99570E);

  static const confirmationOpacity = .92;
  static const confirmationBackdropSigma = 16.0;
  static const confirmationLightingOpacity = .35;

  static ThemeData confirmation(ThemeData theme) {
    final light = theme.brightness == Brightness.light;
    final base = light ? DigiGymDashboardTheme.bmiDialog(theme) : theme;
    final surfaces = base.extension<DigiGymSurfaces>()!;
    final gradient = surfaces.glass.gradient!;
    return base.copyWith(
      extensions: [
        ...base.extensions.values.where((value) => value is! DigiGymSurfaces),
        surfaces.copyWith(
          glass: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                for (final color in gradient.colors)
                  color.withValues(alpha: confirmationOpacity),
              ],
              stops: gradient.stops,
            ),
          ),
          glassShadow: light
              ? const BoxShadow(
                  color: Color(0x27545D6B),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                )
              : surfaces.glassShadow,
        ),
      ],
    );
  }

  static ThemeData apply(ThemeData base) {
    if (base.brightness == Brightness.dark) {
      // Preserve the existing Workout overrides exactly.
      return base.copyWith(
        expansionTileTheme: base.expansionTileTheme.copyWith(
          textColor: DigiGymDarkColors.softGreen,
          iconColor: DigiGymDarkColors.softGreen,
        ),
        colorScheme: base.colorScheme.copyWith(
          primary: DigiGymDarkColors.softGreen,
          primaryContainer: DigiGymDarkColors.softGreen.withValues(alpha: .12),
        ),
      );
    }
    final surfaces = base.extension<DigiGymSurfaces>() ?? DigiGymSurfaces.light;
    final colors = base.colorScheme.copyWith(
      primary: surfaces.accent,
      onPrimary: surfaces.onAccent,
      onPrimaryContainer: surfaces.accent,
    );
    return base.copyWith(
      colorScheme: colors,
      iconTheme: base.iconTheme.copyWith(color: surfaces.accent),
      listTileTheme: base.listTileTheme.copyWith(iconColor: surfaces.accent),
      expansionTileTheme: base.expansionTileTheme.copyWith(
        textColor: surfaces.accent,
        iconColor: surfaces.accent,
        collapsedTextColor: colors.onSurface,
        collapsedIconColor: colors.onSurfaceVariant,
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
      ),
    );
  }
}
